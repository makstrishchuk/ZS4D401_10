CLASS zcl_d401_10_01comment DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_d401_10_01comment IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    SELECT FROM /dmo/connection FIELDS * INTO TABLE @DATA(lt_result). "#EC CI_NOWHERE
    out->write( EXPORTING data = lt_result name = 'Connections'). ##NO_TEXT


    SELECT FROM /dmo/connection FIELDS * INTO TABLE @lt_result.
    out->write( EXPORTING data = lt_result name = 'Connections').

  ENDMETHOD.
ENDCLASS.
