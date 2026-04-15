*"* use this source file for your ABAP unit test classes
CLASS ltcl_flights DEFINITION FINAL FOR TESTING
DURATION LONG
RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS:
      test_find_cargo_flight FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_flights IMPLEMENTATION.

  METHOD test_find_cargo_flight.
    "test1
    SELECT SINGLE FROM /lrn/cargoflight FIELDS carrier_id, connection_id, flight_date,
                                        airport_from_id, airport_to_id
                                        INTO @DATA(some_flight_data).
    IF sy-subrc <> 0.
      cl_abap_unit_assert=>fail( 'Keine Daten in der Tabelle:/lrn/cargoflight ' ).
    ENDIF.

    "test2
    TRY.
        DATA(the_carrier) = NEW lcl_carrier( i_carrier_id = some_flight_data-carrier_id ).
      CATCH cx_root.
        cl_abap_unit_assert=>fail( 'Die Klasse: lcl_carrier konnet nicht instanziert werden' ).
    ENDTRY.

    "test3

    the_carrier->find_cargo_flight(
      EXPORTING
        i_airport_from_id = some_flight_data-airport_from_id
        i_airport_to_id   = some_flight_data-airport_to_id
        i_from_date       = some_flight_data-flight_date
        i_cargo           = 1
      IMPORTING
        e_flight          = DATA(cargo_flight)
        e_days_later      = DATA(days_later) ).
    cl_abap_unit_assert=>assert_bound(
    EXPORTING
        act = cargo_flight
        msg = 'Die Methode find_cargo_flight gibt kein Ergebniss zuruck' ).

    cl_abap_unit_assert=>assert_equals(
    EXPORTING
        act = days_later
        exp = 0
        msg = 'Die Methode find_cargo_flight gibt falsches Ergebniss zuruck' ).


  ENDMETHOD.
ENDCLASS.
