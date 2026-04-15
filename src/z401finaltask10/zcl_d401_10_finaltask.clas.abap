CLASS zcl_d401_10_finaltask DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.





CLASS zcl_d401_10_finaltask IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.


    DATA lo_rental TYPE REF TO lcl_rental.
    DATA lo_vehicle TYPE REF TO lcl_vehicle.
    DATA lv_max_cargo TYPE ty_cargo.
    DATA lx_failed TYPE REF TO zcx_d401_10_failed.

    "ubung 3

    lo_rental = NEW lcl_rental(  ).
    TRY.
        lo_vehicle = NEW lcl_truck(
          iv_make = 'Toyota'
          iv_model = 'test1'
          iv_price = '30000.00'
          iv_color = 'Schawarz'
          iv_cargo = '2.00'
          ).
        lo_rental->add_vehicle( lo_vehicle ).

      CATCH zcx_d401_10_failed INTO lx_failed.
        out->write( lx_failed->get_text( ) ).
    ENDTRY.

    TRY.
        lo_vehicle = NEW lcl_truck(
          iv_make = 'Mercedes'
          iv_model = 'test2'
          iv_price = '50000.00'
          iv_color = 'Rot'
          iv_cargo = '5.00'
          ).
        lo_rental->add_vehicle( lo_vehicle ).
      CATCH zcx_d401_10_failed INTO lx_failed.
        out->write( lx_failed->get_text( ) ).
    ENDTRY.

    TRY.
        lo_vehicle = NEW lcl_truck(
          iv_make = 'Volvo'
          iv_model = 'test3'
          iv_price = '25000.00'
          iv_color = 'Schwarz'
          iv_cargo = '25.00'
          ).
        lo_rental->add_vehicle( lo_vehicle ).

      CATCH zcx_d401_10_failed INTO lx_failed.
        out->write( lx_failed->get_text( ) ).
    ENDTRY.

    TRY.
        lo_vehicle = NEW lcl_truck(
          iv_make = 'MAN'
          iv_model = 'test4'
          iv_price = '15000.00'
          iv_color = 'White'
          iv_cargo = '1.00'
          ).
        lo_rental->add_vehicle( lo_vehicle ).

      CATCH zcx_d401_10_failed INTO lx_failed.
        out->write( lx_failed->get_text( ) ).
    ENDTRY.

    TRY.
        lo_vehicle = NEW lcl_truck(
          iv_make = 'BMW'
          iv_model = 'test5'
          iv_price = '60000.00'
          iv_color = 'Blau'
          iv_cargo = '2.00'
          ).
        lo_rental->add_vehicle( lo_vehicle ).

      CATCH zcx_d401_10_failed INTO lx_failed.
        out->write( lx_failed->get_text( ) ).
    ENDTRY.

    lo_vehicle = NEW lcl_bus(
      iv_make = 'Bus1'
      iv_model = 'test6'
      iv_price = '10000.00'
      iv_color = 'Schwarz'
      iv_seats = '45'
      ).
    lo_rental->add_vehicle( lo_vehicle ).

    lo_vehicle = NEW lcl_bus(
      iv_make = 'Bus2'
      iv_model = 'test7'
      iv_price = '20000.00'
      iv_color = 'Rot'
      iv_seats = '20'
      ).
    lo_rental->add_vehicle( lo_vehicle ).

    lo_vehicle = NEW lcl_bus(
       iv_make = 'Bus3'
       iv_model = 'test8'
       iv_price = '30000.00'
       iv_color = 'Blau'
       iv_seats = '35'
       ).
    lo_rental->add_vehicle( lo_vehicle ).

    lo_vehicle = NEW lcl_bus(
     iv_make = 'Bus4'
     iv_model = 'test9'
     iv_price = '50000.00'
     iv_color = 'Weis'
     iv_seats = '50'
     ).
    lo_rental->add_vehicle( lo_vehicle ).

    lo_vehicle = NEW lcl_bus(
     iv_make = 'Bus5'
     iv_model = 'test10'
     iv_price = '90000.00'
     iv_color = 'Scwarz'
     iv_seats = '100'
     ).
    lo_rental->add_vehicle( lo_vehicle ).


    DATA lt_list TYPE STANDARD TABLE OF string WITH EMPTY KEY.     "ubung 3

    lt_list = lo_rental->get_vehicle_list( ).

    LOOP AT lt_list INTO DATA(lv_text).
      out->write( lv_text ).
    ENDLOOP.

    lv_max_cargo = lo_rental->get_max_cargo(  ).
    out->write( |Maximum cargo capacity:{ lv_max_cargo }| ).


  ENDMETHOD.

ENDCLASS.






