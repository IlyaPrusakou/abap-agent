CLASS zpru_cl_discard_delete DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zpru_if_discard_strategy .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zpru_cl_discard_delete IMPLEMENTATION.

  METHOD zpru_if_discard_strategy~discard.

    IF ct_message_2_discard IS INITIAL.
      RETURN.
    ENDIF.

    CLEAR: ct_message_2_discard.
  ENDMETHOD.
ENDCLASS.
