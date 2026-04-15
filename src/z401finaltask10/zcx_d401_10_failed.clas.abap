CLASS zcx_d401_10_failed DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    interFACES if_t100_message.
    interFACES if_t100_dyn_msg.

    data i_model type c leNGTH 30 rEAD-ONLY.
    data i_make type c leNGTH 30 rEAD-ONLY.

    CONSTANTS:
  BEGIN OF cargo_too_low,
    msgid TYPE symsgid VALUE 'Z10_FT_MESSAGES',
    msgno TYPE symsgno VALUE '010',
    attr1 TYPE scx_attrname VALUE 'i_model',
    attr2 TYPE scx_attrname VALUE 'i_make',
    attr3 TYPE scx_attrname VALUE 'attr3',
    attr4 TYPE scx_attrname VALUE 'attr4',
  END OF cargo_too_low.

    METHODS constructor
      IMPORTING
        !textid like if_t100_message=>t100key opTIONAL
        !previous like previous optional
        i_make like i_make optional
        i_model like i_model optioNAL.



  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcx_d401_10_failed IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    super->constructor( previous = previous ).
    clear me->textid.
    if textid is initial.
      if_t100_message~t100key = if_t100_message=>default_textid.
    else.
      if_t100_message~t100key = textid.
    endif.

    if i_make is not iniTIAL.
    me->i_make = i_make.
    eNDIF.

    if i_model is not initial.
    me->i_model = i_model.
    eNDIF.

    ENDMETHOD.
ENDCLASS.
