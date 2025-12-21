CLASS zpru_cl_persistence_msg DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zpru_if_long_mem_persistence.
ENDCLASS.


CLASS zpru_cl_persistence_msg IMPLEMENTATION.
  METHOD zpru_if_long_mem_persistence~persist.
    DATA lt_message_db TYPE zpru_if_long_mem_persistence=>tt_message_db.

    IF io_input IS NOT BOUND.
      RETURN.
    ENDIF.

    ev_error = abap_false.

    lt_message_db = io_input->get_data( )->*.

    MODIFY zpru_mem_msg FROM TABLE @lt_message_db.
    IF sy-subrc <> 0.
      ev_error = abap_true.
    ELSE.
      ev_error = abap_false.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
