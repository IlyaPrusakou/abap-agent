CLASS zpru_cl_discard_save DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zpru_if_discard_strategy .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zpru_cl_discard_save IMPLEMENTATION.


  METHOD zpru_if_discard_strategy~discard.

    IF io_long_memory IS NOT BOUND.
      RETURN.
    ENDIF.

    io_long_memory->save_messages(
    IMPORTING ev_error = DATA(lv_error)
    CHANGING ct_messages = ct_message_2_discard ).


    IF lv_error = abap_false.
      COMMIT WORK.
    ELSE.
      ROLLBACK WORK.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
