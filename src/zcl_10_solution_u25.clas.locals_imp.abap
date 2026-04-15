
INTERFACE lif_output.
  TYPES t_output TYPE  string.
  "ubung 06
  TYPES tt_output TYPE STANDARD TABLE OF t_output
                  WITH NON-UNIQUE DEFAULT KEY.
  "ubung 18

  METHODS get_output RETURNING VALUE(r_result) TYPE tt_output.



ENDINTERFACE.


CLASS lcl_flight DEFINITION ABSTRACT.

  PUBLIC SECTION.
    INTERFACES lif_output. "ubung 21
    ALIASES get_output FOR lif_output~get_output.

    TYPES tab TYPE STANDARD TABLE OF REF TO lcl_flight WITH DEFAULT KEY. "ubung 20
    TYPES: BEGIN OF st_connection_details,
             airport_from_id TYPE /dmo/airport_from_id,
             airport_to_id   TYPE /dmo/airport_to_id,
             departure_time  TYPE /dmo/flight_departure_time,
             arrival_time    TYPE /dmo/flight_departure_time,
             duration        TYPE i,
           END OF st_connection_details.

    DATA connection_id TYPE /dmo/connection_id    READ-ONLY.
    DATA flight_date   TYPE /dmo/flight_date      READ-ONLY.
    DATA carrier_id    TYPE /dmo/carrier_id       READ-ONLY.
    METHODS: get_connection_details
      RETURNING
        VALUE(r_result) TYPE st_connection_details.

    METHODS constructor
      IMPORTING
        i_connection_id TYPE /dmo/connection_id
        i_flight_date   TYPE /dmo/flight_date
        i_carrier_id    TYPE /dmo/carrier_id.



  PROTECTED SECTION.
    DATA planetype TYPE /dmo/plane_type_id.
    DATA connection_details TYPE st_connection_details.
    METHODS get_description RETURNING VALUE(r_result) TYPE string_table.

  PRIVATE SECTION.

ENDCLASS.

CLASS lcl_flight IMPLEMENTATION.

  METHOD constructor.

    me->connection_id = i_connection_id.
    me->flight_date = i_flight_date.
    me->carrier_id = i_carrier_id.

  ENDMETHOD.

  METHOD get_connection_details.
    r_result = me->connection_details.
  ENDMETHOD.

  METHOD get_description.

    DATA txt TYPE string.

    txt = TEXT-005.


    txt = replace( val = txt sub = '&1'  with = carrier_id ).
    txt = replace( val = txt sub = '&2'  with = connection_id ).
    txt = replace( val = txt sub = '&date&'  with = |{ flight_date  DATE = USER }| ).
    txt = replace( val = txt sub = '&from&'  with = connection_details-airport_from_id ).
    txt = replace( val = txt sub = '&to&'  with = connection_details-airport_to_id ).

    APPEND txt TO r_result.



*    APPEND |Flight { carrier_id } { connection_id } on { flight_date DATE = USER } | &&
*           |from { connection_details-airport_from_id } to { connection_details-airport_to_id } |
*           TO r_result.
*





    APPEND |Planetype:      { planetype  } | TO r_result.



  ENDMETHOD.

  METHOD lif_output~get_output.      "ubung 21
    r_result = get_description(  ).
  ENDMETHOD.

ENDCLASS.



CLASS lcl_passenger_flight DEFINITION INHERITING FROM lcl_flight .

  PUBLIC SECTION.





    METHODS constructor
      IMPORTING
        i_carrier_id    TYPE /dmo/carrier_id
        i_connection_id TYPE /dmo/connection_id
        i_flight_date   TYPE /dmo/flight_date.



    TYPES
      tt_flights TYPE STANDARD TABLE OF REF TO lcl_passenger_flight WITH DEFAULT KEY.



    METHODS
      get_free_seats
        RETURNING
          VALUE(r_result) TYPE i.


    CLASS-METHODS class_constructor.
    CLASS-METHODS
      get_flights_by_carrier
        IMPORTING
          i_carrier_id    TYPE /dmo/carrier_id
        RETURNING
          VALUE(r_result) TYPE tt_flights.

  PROTECTED SECTION.
    METHODS
      get_description REDEFINITION.


  PRIVATE SECTION.



    DATA seats_max  TYPE /dmo/plane_seats_max.
    DATA seats_occ  TYPE /dmo/plane_seats_occupied.
    DATA seats_free TYPE i.

    DATA price TYPE /dmo/flight_price.
    CONSTANTS currency TYPE /dmo/currency_code VALUE 'EUR'.




    "ubung 04 ->
    TYPES: BEGIN OF st_flights_buffer,
             carrier_id     TYPE /dmo/carrier_id,
             connection_id  TYPE /dmo/connection_id,
             flight_date    TYPE /dmo/flight_date,
             price          TYPE /dmo/flight_price,
             currency_code  TYPE /dmo/currency_code,
             plane_type_id  TYPE /dmo/plane_type_id,
             seats_max      TYPE /dmo/plane_seats_max,
             seats_occupied TYPE /dmo/plane_seats_occupied,
             seats_free     TYPE i,   "ubung 11
           END OF st_flights_buffer.
    CLASS-DATA flights_buffer TYPE HASHED TABLE OF st_flights_buffer    "ubung 17
               WITH UNIQUE KEY carrier_id connection_id flight_date
               WITH NON-UNIQUE SORTED KEY sk_carrier COMPONENTS carrier_id.


    TYPES : BEGIN OF st_connections_buffer,
              carrier_id      TYPE /dmo/carrier_id,
              connection_id   TYPE /dmo/connection_id,
              airport_from_id TYPE /dmo/airport_from_id,
              airport_to_id   TYPE /dmo/airport_to_id,
              departure_time  TYPE /dmo/flight_departure_time,
              arrival_time    TYPE /dmo/flight_arrival_time,
              timzone_from    TYPE /lrn/airport-timzone,          "ubung 10
              timzone_to      TYPE /lrn/airport-timzone,          "ubung 10
              duration        TYPE i,
            END OF st_connections_buffer.
    CLASS-DATA connections_buffer TYPE HASHED  TABLE OF st_connections_buffer      "ubung 16
                                     WITH UNIQUE KEY carrier_id connection_id.

ENDCLASS.

CLASS lcl_passenger_flight IMPLEMENTATION.

  METHOD class_constructor.
*    "ubung 05
*    SELECT  FROM /dmo/connection
*     FIELDS carrier_id, connection_id, airport_from_id, airport_to_id, departure_time, arrival_time
*        INTO TABLE @connections_buffer.
*    "ubung 07
*    SELECT FROM /lrn/airport FIELDS airport_id, timzone INTO TABLE @DATA(airports).


    "ubung 07
    DATA(today) = cl_abap_context_info=>get_system_date(  ).


    "ubung 10 ->
    SELECT  FROM /dmo/connection
       LEFT OUTER JOIN /lrn/airport AS a
          ON /dmo/connection~airport_from_id = a~airport_id
       LEFT OUTER JOIN /lrn/airport AS b
          ON /dmo/connection~airport_to_id = b~airport_id
       FIELDS  carrier_id, connection_id, airport_from_id, airport_to_id, departure_time, arrival_time,
         a~timzone AS timzone_from, b~timzone AS timzone_to,

        "ubung 12
        div( tstmp_seconds_between( tstmp1 = dats_tims_to_tstmp( date = @today, time = departure_time, tzone = a~timzone ),
                                    tstmp2 = dats_tims_to_tstmp( date = @today, time = arrival_time, tzone = b~timzone ) )  ,  60 ) AS duration

          INTO TABLE @connections_buffer.
*
*
*    LOOP AT connections_buffer INTO DATA(connection).
*
*       CONVERT DATE today TIME connection-departure_time
*       TIME ZONE connection-timzone_from                      "
*       INTO UTCLONG DATA(departure_utclong).
*
*
*      CONVERT DATE today TIME connection-arrival_time
*       TIME ZONE connection-timzone_to                        "
*       INTO UTCLONG DATA(arrival_utclong).
*
*      connection-duration = utclong_diff( high = arrival_utclong low = departure_utclong ) / 60.
*      IF connection-duration < 0.
*        arrival_utclong = utclong_add( val = arrival_utclong   days    = 1 ).
*        connection-duration = utclong_diff( high = arrival_utclong low = departure_utclong ) / 60.
*      ENDIF.
*
*      MODIFY connections_buffer FROM connection TRANSPORTING duration .
*
*    ENDLOOP.


  ENDMETHOD.

  METHOD get_flights_by_carrier.

    IF NOT line_exists( flights_buffer[ KEY sk_carrier carrier_id = i_carrier_id ] ).

      SELECT FROM /lrn/passflight
          FIELDS carrier_id,connection_id,flight_date,

           currency_conversion(                                          "ubung 12
                               amount = price,
                               source_currency = currency_code,
                               target_currency = @currency,
                               exchange_rate_date = flight_date,
                               on_error = @sql_currency_conversion=>c_on_error-set_to_null
                               )     AS   price,
             @currency AS currency_code,
             plane_type_id,seats_max, seats_occupied,
             seats_max - seats_occupied AS seats_free   "ubung 11
            WHERE carrier_id    = @i_carrier_id
*          ORDER BY flight_date   "ubung 13
            APPENDING CORRESPONDING FIELDS OF TABLE @flights_buffer.  "ubung 14
*      SORT flights_buffer BY carrier_id connection_id flight_date.
*      DELETE ADJACENT DUPLICATES FROM flights_buffer COMPARING carrier_id connection_id flight_date. "ubung 14
    ENDIF.
*    LOOP AT flights_buffer INTO DATA(flight) WHERE carrier_id = i_carrier_id.
*      APPEND NEW lcl_passenger_flight( i_carrier_id    = flight-carrier_id
*                                       i_connection_id = flight-connection_id
*                                       i_flight_date   = flight-flight_date )
*              TO r_result.
*    ENDLOOP.



*    LOOP AT flights_buffer ASSIGNING FIELD-SYMBOL(<fs>).  "Inline Field Symbols <fs>
*
*
*    ENDLOOP.





    r_result = VALUE #( FOR <line> IN flights_buffer
                               USING KEY sk_carrier
                               WHERE ( carrier_id = i_carrier_id )
                              (
                                     NEW lcl_passenger_flight(
                                    i_carrier_id    = <line>-carrier_id
                                    i_connection_id = <line>-connection_id
                                    i_flight_date   = <line>-flight_date )
                              )
                        ).

  ENDMETHOD.


  METHOD constructor.
    super->constructor(
      i_connection_id = i_connection_id
      i_flight_date   = i_flight_date
      i_carrier_id    = i_carrier_id ).
    "ubung 04 ->
    TRY.
        DATA(flight_raw) = flights_buffer[ carrier_id    = i_carrier_id
                                           connection_id = i_connection_id
                                           flight_date   = i_flight_date ].
      CATCH cx_root.
        SELECT SINGLE
          FROM /lrn/passflight
        FIELDS carrier_id, connection_id, flight_date,  plane_type_id, seats_max, seats_occupied,

        currency_conversion(                                          "ubung 12
                             amount = price,
                             source_currency = currency_code,
                             target_currency = @currency,
                             exchange_rate_date = flight_date,
                             on_error = @sql_currency_conversion=>c_on_error-set_to_null
                             )     AS   price,
           @currency AS currency_code,
         seats_max - seats_occupied AS seats_free  "ubung 11
         WHERE carrier_id    = @i_carrier_id
           AND connection_id = @i_connection_id
           AND flight_date   = @i_flight_date
          INTO CORRESPONDING FIELDS OF @flight_raw.
    ENDTRY.

    IF flight_raw IS NOT INITIAL.
      "ubung 04 <-
      me->carrier_id    = i_carrier_id.
      me->connection_id = i_connection_id.
      me->flight_date   = i_flight_date.

      planetype = flight_raw-plane_type_id.
      seats_max = flight_raw-seats_max.
      seats_occ = flight_raw-seats_occupied.
*      seats_free = flight_raw-seats_max - flight_raw-seats_occupied.  " ubung 11
      seats_free = flight_raw-seats_free.   "ubung 11
      price     = flight_raw-price.         "ubung 12
* convert currencies                        "ubung 12
*      TRY.
*          cl_exchange_rates=>convert_to_local_currency(
*            EXPORTING
*              date              = me->flight_date
*              foreign_amount    = flight_raw-price
*              foreign_currency  = flight_raw-currency_code
*              local_currency    = me->currency
*            IMPORTING
*              local_amount      = me->price
*          ).
*        CATCH cx_exchange_rates.
*          price = flight_raw-price.
*      ENDTRY.

* Set connection details
*      SELECT SINGLE
*        FROM /dmo/connection
*      FIELDS airport_from_id, airport_to_id, departure_time, arrival_time
*       WHERE carrier_id    = @carrier_id
*         AND connection_id = @connection_id
*        INTO @connection_details .
      "ubung 05 ->
      connection_details =  CORRESPONDING #(  connections_buffer[ carrier_id    = i_carrier_id
                                               connection_id = i_connection_id ] ).
      "ubung 05 <-

*      connection_details-duration = connection_details-arrival_time
*                                  - connection_details-departure_time.

    ENDIF.
  ENDMETHOD.




  METHOD get_free_seats.
    r_result = me->seats_free.
  ENDMETHOD.

  METHOD get_description.

    r_result = super->get_description(  ).
    APPEND |Maximum Seats:  { seats_max  } | TO r_result.
    APPEND |Occupied Seats: { seats_occ } | TO r_result.
    APPEND |Free Seats:     { seats_free } | TO r_result.
    APPEND |Ticket Price:   { price CURRENCY = currency } { currency } | TO r_result.
    APPEND |Duration:   { connection_details-duration } minutes | TO r_result.

  ENDMETHOD.

ENDCLASS.

CLASS lcl_cargo_flight DEFINITION  INHERITING FROM lcl_flight.

  PUBLIC SECTION.


    TYPES
       tt_flights TYPE STANDARD TABLE OF REF TO lcl_cargo_flight WITH DEFAULT KEY.



    METHODS constructor
      IMPORTING
        i_carrier_id    TYPE /dmo/carrier_id
        i_connection_id TYPE /dmo/connection_id
        i_flight_date   TYPE /dmo/flight_date.


    METHODS
      get_free_capacity
        RETURNING
          VALUE(r_result) TYPE /lrn/plane_actual_load.


    CLASS-METHODS
      get_flights_by_carrier
        IMPORTING
          i_carrier_id    TYPE /dmo/carrier_id
        RETURNING
          VALUE(r_result) TYPE tt_flights.

  PROTECTED SECTION.
    METHODS get_description
        REDEFINITION.


  PRIVATE SECTION.

    TYPES: BEGIN OF st_flights_buffer,
             carrier_id      TYPE /dmo/carrier_id,
             connection_id   TYPE /dmo/connection_id,
             flight_date     TYPE /dmo/flight_date,
             plane_type_id   TYPE /dmo/plane_type_id,
             maximum_load    TYPE /lrn/plane_maximum_load,
             actual_load     TYPE /lrn/plane_actual_load,
             load_unit       TYPE /lrn/plane_weight_unit,
             airport_from_id TYPE /dmo/airport_from_id,
             airport_to_id   TYPE /dmo/airport_to_id,
             departure_time  TYPE /dmo/flight_departure_time,
             arrival_time    TYPE /dmo/flight_arrival_time,
           END OF st_flights_buffer.

    TYPES tt_flights_buffer TYPE HASHED TABLE OF st_flights_buffer
                            WITH UNIQUE KEY carrier_id connection_id flight_date.

    DATA maximum_load TYPE /lrn/plane_maximum_load.
    DATA actual_load TYPE /lrn/plane_actual_load.
    DATA load_unit    TYPE /lrn/plane_weight_unit.

    CLASS-DATA flights_buffer TYPE tt_flights_buffer.

ENDCLASS.

CLASS lcl_cargo_flight IMPLEMENTATION.

  METHOD get_flights_by_carrier.

    SELECT
      FROM /lrn/cargoflight
    FIELDS carrier_id, connection_id, flight_date,
           plane_type_id, maximum_load, actual_load, load_unit,
           airport_from_id, airport_to_id, departure_time, arrival_time
     WHERE carrier_id    = @i_carrier_id
      ORDER BY flight_date
      INTO CORRESPONDING FIELDS OF TABLE @flights_buffer.

    LOOP AT flights_buffer INTO DATA(flight).
      APPEND NEW lcl_cargo_flight( i_carrier_id    = flight-carrier_id
                                   i_connection_id = flight-connection_id
                                   i_flight_date   = flight-flight_date )
              TO r_result.

    ENDLOOP.
  ENDMETHOD.

  METHOD constructor.

    super->constructor(
      i_connection_id = i_connection_id
      i_flight_date   = i_flight_date
      i_carrier_id    = i_carrier_id ).

    " Read buffer
    TRY.
        DATA(flight_raw) = flights_buffer[ carrier_id    = i_carrier_id
                                           connection_id = i_connection_id
                                           flight_date   = i_flight_date ].

      CATCH cx_sy_itab_line_not_found.
        " Read from database if data not found in buffer
        SELECT SINGLE
          FROM /lrn/cargoflight
        FIELDS plane_type_id, maximum_load, actual_load, load_unit,
               airport_from_id, airport_to_id, departure_time, arrival_time
         WHERE carrier_id    = @i_carrier_id
           AND connection_id = @i_connection_id
           AND flight_date   = @i_flight_date
          INTO CORRESPONDING FIELDS OF @flight_raw.
    ENDTRY.

    carrier_id    =   i_carrier_id  .
    connection_id =  i_connection_id .
    flight_date   = i_flight_date.

    planetype = flight_raw-plane_type_id.
    maximum_load = flight_raw-maximum_load.
    actual_load = flight_raw-actual_load.
    load_unit = flight_raw-load_unit.

    connection_details = CORRESPONDING #( flight_raw ).

    connection_details-duration = me->connection_details-arrival_time
                                    - me->connection_details-departure_time.

  ENDMETHOD.




  METHOD get_free_capacity.
    r_result = maximum_load - actual_load.
  ENDMETHOD.

  METHOD get_description.

    r_result = super->get_description(  ).
*    APPEND |Flight { carrier_id } { connection_id } on { flight_date DATE = USER } | &&
*           |from { connection_details-airport_from_id } to { connection_details-airport_to_id } |
*           TO r_result.
*    APPEND |Planetype:     { planetype } |                         TO r_result.
    APPEND |Maximum Load:  { maximum_load         } { load_unit }| TO r_result.
    APPEND |Free Capacity: { get_free_capacity( ) } { load_unit }| TO r_result.

  ENDMETHOD.

ENDCLASS.

CLASS lcl_carrier DEFINITION CREATE PRIVATE.

  PUBLIC SECTION.

    INTERFACES lif_output.  "ubung 21
    ALIASES: get_output FOR lif_output~get_output,
             t_output FOR lif_output~t_output,
             tt_output FOR lif_output~tt_output.


    CLASS-METHODS get_instance                            "ubung 23
      IMPORTING i_carrier_id    TYPE /dmo/carrier_id
      RETURNING VALUE(r_result) TYPE REF TO lcl_carrier
      RAISING   zcx_10_failed.








    DATA carrier_id TYPE /dmo/carrier_id READ-ONLY.

    METHODS constructor
      IMPORTING
                i_carrier_id TYPE /dmo/carrier_id
      RAISING   cx_abap_invalid_value
                cx_abap_auth_check_exception.

    METHODS find_passenger_flight
      IMPORTING
        i_airport_from_id TYPE /dmo/airport_from_id
        i_airport_to_id   TYPE /dmo/airport_to_id
        i_from_date       TYPE /dmo/flight_date
        i_seats           TYPE i
      EXPORTING
        e_flight          TYPE REF TO lcl_flight
        e_days_later      TYPE i.

    METHODS find_cargo_flight
      IMPORTING
        i_airport_from_id TYPE /dmo/airport_from_id
        i_airport_to_id   TYPE /dmo/airport_to_id
        i_from_date       TYPE /dmo/flight_date
        i_cargo           TYPE /lrn/plane_actual_load
      EXPORTING
        e_flight          TYPE REF TO lcl_flight
        e_days_later      TYPE i.

  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA name          TYPE /dmo/carrier_name .
    DATA currency_code TYPE /dmo/currency_code  ##NEEDED.

*    DATA passenger_flights TYPE lcl_passenger_flight=>tt_flights.
*
*    DATA cargo_flights TYPE lcl_cargo_flight=>tt_flights.

    DATA flights  TYPE lcl_flight=>tab.
    DATA pf_count TYPE i.
    DATA cf_count TYPE i.

    CLASS-DATA banane.

    METHODS get_average_free_seats
      RETURNING VALUE(r_result) TYPE i.

    CLASS-DATA instances TYPE TABLE OF REF TO lcl_carrier WITH DEFAULT KEY.


ENDCLASS.

CLASS lcl_carrier IMPLEMENTATION.

  METHOD constructor.

    me->carrier_id = i_carrier_id.
*    name = carrier_id && ` ` && name.

    DATA(passenger_flights) =
        lcl_passenger_flight=>get_flights_by_carrier(
              i_carrier_id    = i_carrier_id ).
    pf_count = lines( passenger_flights  ).


    DATA(cargo_flights) =
        lcl_cargo_flight=>get_flights_by_carrier(
              i_carrier_id    = i_carrier_id ).
    cf_count = lines( cargo_flights  ).

    LOOP AT passenger_flights INTO DATA(passflight).
      APPEND passflight TO flights.
    ENDLOOP.

    LOOP AT cargo_flights INTO DATA(cargoflight).
      APPEND cargoflight TO flights.
    ENDLOOP.




  ENDMETHOD.

  METHOD lif_output~get_output.   "ubung 21

    APPEND |{ 'Carrier:'(001) } { me->name } | TO r_result.
    APPEND |{ 'Passenger Flights:'(002) }  { pf_count } | TO r_result.  "ubung 20
    APPEND |{ 'Average free seats:'(003) }  { get_average_free_seats(  ) } | TO r_result.
    APPEND |{ 'Cargo Flights:'(004) }      { cf_count } | TO r_result.  "ubung 20

  ENDMETHOD.

  METHOD find_cargo_flight.

    e_days_later = 99999999.

    LOOP AT me->flights INTO DATA(flight)
        WHERE table_line->flight_date >= i_from_date AND table_line IS INSTANCE OF lcl_cargo_flight.  "ubung 20

      DATA(connection_details) = flight->get_connection_details(  ).

      IF connection_details-airport_from_id = i_airport_from_id
       AND connection_details-airport_to_id = i_airport_to_id
       AND CAST lcl_cargo_flight( flight )->get_free_capacity(  ) >= i_cargo.      "ubung 20  Down Cast

        DATA(days_later) =   flight->flight_date - i_from_date.

        IF days_later < e_days_later. "earlier than previous one?
          e_flight = flight.
          e_days_later = days_later.
        ENDIF.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD find_passenger_flight.

    e_days_later = 99999999.

    LOOP AT me->flights INTO DATA(flight)
         WHERE table_line->flight_date >= i_from_date AND table_line IS INSTANCE OF lcl_passenger_flight. "ubung 20

      DATA(connection_details) = flight->get_connection_details(  ).

      IF connection_details-airport_from_id = i_airport_from_id
       AND connection_details-airport_to_id = i_airport_to_id
       AND  CAST lcl_passenger_flight( flight )->get_free_seats( ) >= i_seats.   "ubung 20 Down Cast
        DATA(days_later) = flight->flight_date - i_from_date.

        IF days_later < e_days_later. "earlier than previous one?
          e_flight = flight.
          e_days_later = days_later.
        ENDIF.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_average_free_seats.


*ubung 20

    r_result = REDUCE #(  INIT i = 0
                           FOR <line> IN flights WHERE ( table_line IS INSTANCE OF lcl_passenger_flight )
                           NEXT i = i + CAST lcl_passenger_flight( <line> )->get_free_seats( )            "ubung 20 Down Cast

                         ) / pf_count.

**ubung 14
*
*    r_result = REDUCE #(  INIT i = 0
*                           FOR <line> IN passenger_flights
*                           NEXT i = i + <line>->get_free_seats( )
*
*                         ) / lines( passenger_flights ) .

  ENDMETHOD.

  METHOD get_instance.    "ubung 23
*    DATA name TYPE string.

    AUTHORITY-CHECK OBJECT '/LRN/CARR'
                 ID '/LRN/CARR' FIELD i_carrier_id
                 ID 'ACTVT' FIELD '03'.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_10_failed
        EXPORTING
          textid     = zcx_10_failed=>carrier_no_read_auth
          carrier_id =  i_carrier_id.
    ENDIF.



    SELECT SINGLE
      FROM /dmo/carrier
*       from /LRN/I_Carrier
*    FIELDS name, currency_code        ubung 11
*     FIELDS concat_with_space( carrier_id, name, 1 ) as name, currency_code    "ubung 11
     FIELDS concat_with_space( carrier_id, name, 1 ) AS name, currency_code    "ubung 11
     WHERE carrier_id = @i_carrier_id
     INTO @DATA(details).

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_10_failed
      exporting
      textid = zcx_10_failed=>carrier_not_exist
      carrier_id = i_carrier_id.


    ENDIF.

    "ubung 23
    TRY.
        r_result = instances[ table_line->carrier_id = i_carrier_id    ].
      CATCH  cx_root.
        r_result = NEW #( i_carrier_id = i_carrier_id  ).
        r_result->name = details-name.
        r_result->currency_code = details-currency_code.
        APPEND r_result TO instances.

    ENDTRY.
  ENDMETHOD.

ENDCLASS.


CLASS lcl_rental DEFINITION.

  PUBLIC SECTION.
    INTERFACES lif_output.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.

CLASS lcl_rental IMPLEMENTATION.

  METHOD lif_output~get_output.

    APPEND 'Ausgabe-1 aus der Klasse lcl_rental' TO r_result.
    APPEND 'Ausgabe-2 aus der Klasse lcl_rental' TO r_result.
    APPEND 'Ausgabe-3 aus der Klasse lcl_rental' TO r_result.
    APPEND 'Ausgabe-4 aus der Klasse lcl_rental' TO r_result.
    APPEND 'Ausgabe-5 aus der Klasse lcl_rental' TO r_result.

  ENDMETHOD.

ENDCLASS.
