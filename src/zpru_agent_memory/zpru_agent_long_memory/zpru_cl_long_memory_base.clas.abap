CLASS zpru_cl_long_memory_base DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zpru_if_agent_frw.
    INTERFACES zpru_if_long_memory_provider.

  PROTECTED SECTION.
    DATA mo_msg_persistence TYPE REF TO zpru_if_long_mem_persistence.
    DATA mo_sum_persistence TYPE REF TO zpru_if_long_mem_persistence.

    METHODS determine
      IMPORTING
        io_input  TYPE REF TO zpru_if_payload
      EXPORTING
        eo_output TYPE REF TO zpru_if_payload.

    METHODS validate
      IMPORTING
        io_input  TYPE REF TO zpru_if_payload
      EXPORTING
        eo_output TYPE REF TO zpru_if_payload
        ev_error  TYPE abap_boolean.

ENDCLASS.


CLASS zpru_cl_long_memory_base IMPLEMENTATION.
  METHOD zpru_if_long_memory_provider~retrieve_summary.
  ENDMETHOD.

  METHOD zpru_if_long_memory_provider~retrieve_message.
  ENDMETHOD.

  METHOD zpru_if_long_memory_provider~save_summary.

    IF io_input IS NOT BOUND.
      RETURN.
    ENDIF.

    DATA(lo_sum_prst) = zpru_if_long_memory_provider~get_sum_persistence( ).
    lo_sum_prst->persist(
      EXPORTING
        io_input  = io_input
      IMPORTING
        eo_output = eo_output
        ev_error  = DATA(lv_error) ).

    IF lv_error = abap_false.
      COMMIT WORK.
    ELSE.
      ROLLBACK WORK.
    ENDIF.
  ENDMETHOD.

  METHOD zpru_if_long_memory_provider~save_messages.

    DATA lt_message_db TYPE zpru_if_long_mem_persistence=>tt_summarization.
    DATA lo_determ_response TYPE REF TO zpru_if_payload.
    DATA lo_validate_request TYPE REF TO zpru_if_payload.
    DATA lo_validate_response TYPE REF TO zpru_if_payload.
    DATA lo_persist_request TYPE REF TO zpru_if_payload.

    IF io_input IS NOT BOUND.
      RETURN.
    ENDIF.

    lo_determ_response = NEW zpru_cl_payload( ).

    determine(
      EXPORTING
        io_input  = io_input
      IMPORTING
        eo_output =  lo_determ_response ).

    lo_validate_request = NEW  zpru_cl_payload( ).
    lo_validate_request->set_data( ir_data = lo_determ_response->get_data( ) ).

    validate(
      EXPORTING
        io_input  = lo_validate_request
      IMPORTING
        eo_output = lo_validate_response
        ev_error  = DATA(lv_error) ).

    IF lv_error = abap_true.
      RETURN.
    ENDIF.

    lo_persist_request = NEW  zpru_cl_payload( ).
    lo_persist_request->set_data( ir_data = lo_validate_response->get_data( ) ).

    DATA(lo_msg_prst) = zpru_if_long_memory_provider~get_msg_persistence( ).
    lo_msg_prst->persist(
      EXPORTING
        io_input  = lo_persist_request
      IMPORTING
        eo_output = eo_output
        ev_error  = lv_error ).

    IF lv_error = abap_false.
      COMMIT WORK.
    ELSE.
      ROLLBACK WORK.
    ENDIF.

  ENDMETHOD.

  METHOD zpru_if_long_memory_provider~summarize_conversation.
  ENDMETHOD.

  METHOD zpru_if_long_memory_provider~get_msg_persistence.
    IF mo_msg_persistence IS NOT BOUND.
      mo_msg_persistence = NEW zpru_cl_persistence_msg( ).
    ENDIF.

    ro_msg_persistence = mo_msg_persistence.
  ENDMETHOD.

  METHOD zpru_if_long_memory_provider~get_sum_persistence.
    IF mo_sum_persistence IS NOT BOUND.
      mo_sum_persistence = NEW zpru_cl_persistence_sum( ).
    ENDIF.

    ro_sum_persistence = mo_sum_persistence.
  ENDMETHOD.

  METHOD zpru_if_long_memory_provider~set_msg_persistence.
  ENDMETHOD.

  METHOD zpru_if_long_memory_provider~set_sum_persistence.
  ENDMETHOD.
  METHOD validate.
    FIELD-SYMBOLS: <lt_message> TYPE zpru_if_long_mem_persistence=>tt_message.

    IF io_input IS NOT BOUND.
      RETURN.
    ENDIF.

    ev_error = abap_false.

    DATA(lr_data) = io_input->get_data( ).

    ASSIGN lr_data->* TO <lt_message>.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    GET TIME STAMP FIELD DATA(lv_now).

*    LOOP AT <lt_message> ASSIGNING FIELD-SYMBOL(<ls_message>).
*
*      TRY.
*          <ls_message>-message_uuid = cl_system_uuid=>create_uuid_x16_static( ).
*        CATCH cx_uuid_error.
*          ASSERT 1 = 2.
*      ENDTRY.
*
*      <ls_message>-created_by = sy-uname.
*      <ls_message>-created_at = lv_now.
*      <ls_message>-changed_by = sy-uname.
*      <ls_message>-changed_at = lv_now.
*
*    ENDLOOP.

  ENDMETHOD.

  METHOD determine.

  ENDMETHOD.


ENDCLASS.
