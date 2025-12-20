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

    IF io_input IS NOT BOUND.
      RETURN.
    ENDIF.

    DATA(lr_messages) = io_input->get_data( ).

    ASSIGN lr_messages->* TO FIELD-SYMBOL(<lt_messaged>).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    CLEAR: <lt_messaged>.

    IF eo_output IS BOUND.
      eo_output->set_data( ir_data = lr_messages ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
