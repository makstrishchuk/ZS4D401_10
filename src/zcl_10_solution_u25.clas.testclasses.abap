CLASS ltcl_flights DEFINITION FINAL FOR TESTING
  DURATION LONG
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS:
      test_find_cargo_flight FOR TESTING RAISING cx_static_check.

    CLASS-METHODS class_setup.
    CLASS-DATA the_carrier TYPE REF TO lcl_carrier.
    CLASS-DATA some_flight_data TYPE /lrn/cargoflight.
ENDCLASS.


CLASS ltcl_flights IMPLEMENTATION.

  METHOD  test_find_cargo_flight.

*    "Test 1
*    SELECT SINGLE FROM /lrn/cargoflight FIELDS carrier_id, connection_id,flight_date,
*                                        airport_from_id, airport_to_id
*                    INTO @DATA(some_flight_data).
*    IF sy-subrc <> 0.
*      cl_abap_unit_assert=>fail( 'Keine Daten in der Tabelle: /lrn/cargoflight' ).
*    ENDIF.
*
*    "Test 2
*    TRY.
*        DATA(the_carrier) = NEW lcl_carrier( i_carrier_id = some_flight_data-carrier_id  ).
*      CATCH cx_root.
*        cl_abap_unit_assert=>fail( 'Die Klasse: lcl_carrier konnet nicht instanziiert werden' ).
*    ENDTRY.

    "Test 3



    ltcl_flights=>the_carrier->find_cargo_flight(
         EXPORTING
           i_airport_from_id = some_flight_data-airport_from_id
           i_airport_to_id   = some_flight_data-airport_to_id
           i_from_date       = some_flight_data-flight_date
           i_cargo           = 1
         IMPORTING
           e_flight =     DATA(cargo_flight)
           e_days_later = DATA(days_later) ).

    cl_abap_unit_assert=>assert_bound(
      EXPORTING
        act              = cargo_flight
        msg              = 'Die Methode: find_cargo_flight gibt kein Ergbniss zurück!' ).

    cl_abap_unit_assert=>assert_equals(
      EXPORTING
        act                  = days_later
        exp                  = 0
        msg                  = 'Die Methode: find_cargo_flight gibt falsches Ergbniss zurück!' ).





  ENDMETHOD.

  METHOD class_setup.
*    "Test 1
    SELECT SINGLE FROM /lrn/cargoflight FIELDS carrier_id, connection_id,flight_date,
                                        airport_from_id, airport_to_id
                    INTO  CORRESPONDING FIELDS OF @some_flight_data.
    IF sy-subrc <> 0.
      cl_abap_unit_assert=>fail( 'Keine Daten in der Tabelle: /lrn/cargoflight' ).
    ENDIF.

    "Test 2
    TRY.
        ltcl_flights=>the_carrier = lcl_carrier=>get_instance( i_carrier_id = some_flight_data-carrier_id  ).
*        DATA(the_carrier) = NEW lcl_carrier( i_carrier_id = some_flight_data-carrier_id  ).  "Falsch

*      ltcl_flights=>the_carrier = the_carrier.

       CATCH cx_abap_auth_check_exception INTO DATA(lx_excp).  "Übung 18
*        out->write( lx_excp->get_text(  ) ).
       cl_abap_unit_assert=>fail( 'Keine Berechtigung für die Fluggesellschaft: '  ).
      CATCH cx_root.
        cl_abap_unit_assert=>fail( 'Die Klasse: lcl_carrier konnet nicht instanziiert werden' ).
    ENDTRY.



  ENDMETHOD.

ENDCLASS.
