CLASS zpru_cl_persistence_sum DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zpru_if_long_mem_persistence .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zpru_cl_persistence_sum IMPLEMENTATION.


  METHOD zpru_if_long_mem_persistence~persist.
    DATA lt_summarization_db TYPE zpru_if_long_mem_persistence=>tt_summarization_db.

    IF io_input IS NOT BOUND.
      RETURN.
    ENDIF.

    ev_error = abap_false.

    lt_summarization_db = io_input->get_data( )->*.

    MODIFY zpru_mem_sum FROM TABLE @lt_summarization_db.
    IF sy-subrc <> 0.
      ev_error = abap_true.
    ELSE.
      ev_error = abap_false.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
