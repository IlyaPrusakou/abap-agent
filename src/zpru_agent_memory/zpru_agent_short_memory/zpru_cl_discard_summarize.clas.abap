CLASS zpru_cl_discard_summarize DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zpru_if_discard_strategy .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zpru_cl_discard_summarize IMPLEMENTATION.


  METHOD zpru_if_discard_strategy~discard.

*    IF io_long_memory IS NOT BOUND.
*      RETURN.
*    ENDIF.
*
*    io_long_memory->summarize_conversation( ).
*
*
*    IF lv_error = abap_false.
*      COMMIT WORK.
*    ELSE.
*      ROLLBACK WORK.
*    ENDIF.

  ENDMETHOD.
ENDCLASS.
