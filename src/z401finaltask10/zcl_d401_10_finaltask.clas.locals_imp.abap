    TYPES ty_price TYPE p LENGTH 10 DECIMALS 2.
    TYPES ty_cargo TYPE p LENGTH 10 DECIMALS 2.
    types tt_vehicle_list type staNDARD TABLE OF string with empty key.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    class lcl_vehicle definiTION.
      PUBLIC SECTION.
      methods constructor
      importing
      iv_make type string
      iv_model type string
      iv_price type ty_price
      iv_color type string.

      mETHODs get_description
      returning valUE(rv_text) type string.


      protectED SECTION.
      data mv_make type string.
      data mv_model type string.
      data mv_price type ty_price.
      data mv_color type string.
    ENDCLASS.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    class lcl_truck definition inHERITING FROM lcl_vehicle.
    pubLIC SECTION.

    methODS constructor
    importing
      iv_make type string
      iv_model type string
      iv_price type ty_price
      iv_color type string
      iv_cargo type ty_cargo
      raising zcx_d401_10_failed.

    methods get_cargo
    returning value(rv_cargo) type ty_cargo.

    methods get_description redefinition.               "test cargo und seats

    privaTE SECTION.
    data mv_cargo type ty_cargo.
    enDCLASS.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    class lcl_bus definition inHERITING FROM lcl_vehicle.
    pubLIC SECTION.
        methODS constructor
        importing
      iv_make type string
      iv_model type string
      iv_price type ty_price
      iv_color type string
      iv_seats type i.

      methods get_seats
      returning value(rv_seats) type i.

      methods get_description redefinition.

    privatE SECTION.
    data mv_seats type i.

    enDCLASS.


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    class lcl_rental definition.
        pubLIC SECTION.
        methODS add_vehicle
            importiNG
                io_vehicle type ref to lcl_vehicle.

    methods get_vehicle_list                "ubung 3'
            returnING VALUE(rt_list) type tt_vehicle_list.

    meTHODS get_max_cargo
    returning value(rv_max_cargo) type ty_cargo.

    privatE SECTION.
    data mt_vehicle type stanDARD TABLE OF ref to lcl_vehicle with empty key.
    enDCLASS.


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
     class lcl_vehicle IMPLEMENTATION.
     metHOD constructor.
      mv_make = iv_make.
      mv_model = iv_model.
      mv_price = iv_price.
      mv_color = iv_color.
     endmethod.

     metHOD get_description.
     rv_text = |Make: { mv_make }, Model: { mv_model }, Price: { mv_price }, Color: { mv_color }|.
     eNDMETHOD.

    endcLASS.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    class lcl_truck IMPLEMENTATION.

        metHOD constructor.

        if iv_cargo < 2.                                        "ubung 5
        raISE excEPTION type zcx_d401_10_failed
        exporting
        textid = zcx_d401_10_failed=>cargo_too_low
        i_make = conv #( iv_make )
        i_model = conv #( iv_model ).

        endif.

        super->constructor(
          iv_make = iv_make
          iv_model = iv_model
          iv_price = iv_price
          iv_color = iv_color
        ).
        mv_cargo = iv_cargo.
      ENDMETHOD.

      method get_cargo.
        rv_cargo = mv_cargo.
      ENDMETHOD.

        method get_description.
        rv_text = |Make: { mv_make }, Model: { mv_model }, Price: { mv_price }, Color: { mv_color }, Cargo: { mv_cargo }|.   "test cargo
         ENDMETHOD.

    endcLASS.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    class lcl_bus IMPLEMENTATION.

    method constructor.
    super->constructor(
          iv_make = iv_make
          iv_model = iv_model
          iv_price = iv_price
          iv_color = iv_color
        ).
        mv_seats = iv_seats.
      ENDMETHOD.

      method get_seats.
        rv_seats = mv_seats.
      ENDMETHOD.

     method get_description.
        rv_text = |Make: { mv_make }, Model: { mv_model }, Price: { mv_price }, Color: { mv_color }, Seats: { mv_seats }|.  "test seats
         ENDMETHOD.

    endcLASS.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    class lcl_rental IMPLEMENTATION.

    method add_vehicle.
        append io_vehicle to mt_vehicle.
      ENDMETHOD.

    metHOD get_vehicle_list.
    loop at mt_vehicle into data(lo_vehicle).               "ubung 3
    append lo_vehicle->get_description( ) to rt_list.
    endloop.
    endmethod.

    metHOD get_max_cargo.                                   "ubung 4

    data lo_vehicle type ref to lcl_vehicle.                 "ubung 4 downcasting
    data lo_truck type reF TO lcl_truck.
    data lv_cargo type ty_cargo.

    rv_max_cargo = '0.00'.

    loop at mt_vehicle into lo_vehicle.
      try.
      lo_truck ?= lo_vehicle.
      lv_cargo = lo_truck->get_cargo( ).

      if lv_cargo > rv_max_cargo.
         rv_max_cargo = lv_cargo.
      endif.

      catch cx_sy_move_cast_error.

      endtry.
    endloop.

    eNDMETHOD.

    enDCLASS.
