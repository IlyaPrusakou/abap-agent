CLASS zpru_cl_long_memory_base DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zpru_if_agent_frw.
    INTERFACES zpru_if_long_memory_provider.

  PROTECTED SECTION.
    DATA mo_msg_persistence TYPE REF TO zpru_if_long_mem_persistence.
    DATA mo_sum_persistence TYPE REF TO zpru_if_long_mem_persistence.
    DATA mo_summarize TYPE REF TO zpru_if_summarization.

    METHODS prepare_db_msg
      IMPORTING io_input  TYPE REF TO zpru_if_payload
      EXPORTING eo_output TYPE REF TO zpru_if_payload.

    METHODS prepare_db_sum
      IMPORTING io_input  TYPE REF TO zpru_if_payload
      EXPORTING eo_output TYPE REF TO zpru_if_payload.

ENDCLASS.


CLASS zpru_cl_long_memory_base IMPLEMENTATION.
  METHOD zpru_if_long_memory_provider~retrieve_summary.
  ENDMETHOD.

  METHOD zpru_if_long_memory_provider~retrieve_message.
  ENDMETHOD.

  METHOD zpru_if_long_memory_provider~save_summary.
    DATA lo_prepar_response TYPE REF TO zpru_if_payload.
    DATA lo_persist_request TYPE REF TO zpru_if_payload.

    IF io_input IS NOT BOUND.
      RETURN.
    ENDIF.

    lo_prepar_response = NEW zpru_cl_payload( ).

    prepare_db_sum( EXPORTING io_input  = io_input
                    IMPORTING eo_output = lo_prepar_response ).

    lo_persist_request = lo_prepar_response.

    DATA(lo_sum_prst) = zpru_if_long_memory_provider~get_sum_persistence( ).
    lo_sum_prst->persist( EXPORTING io_input  = lo_persist_request
                          IMPORTING eo_output = eo_output
                                    ev_error  = DATA(lv_error) ).

    IF lv_error = abap_false.
      COMMIT WORK.
    ELSE.
      ROLLBACK WORK.
    ENDIF.
  ENDMETHOD.

  METHOD zpru_if_long_memory_provider~save_messages.
    DATA lo_prepar_response TYPE REF TO zpru_if_payload.
    DATA lo_persist_request TYPE REF TO zpru_if_payload.

    IF io_input IS NOT BOUND.
      RETURN.
    ENDIF.

    lo_prepar_response = NEW zpru_cl_payload( ).

    prepare_db_msg( EXPORTING io_input  = io_input
                     IMPORTING eo_output = lo_prepar_response ).

    lo_persist_request = lo_prepar_response.

    DATA(lo_msg_prst) = zpru_if_long_memory_provider~get_msg_persistence( ).
    lo_msg_prst->persist( EXPORTING io_input  = lo_persist_request
                          IMPORTING eo_output = eo_output
                                    ev_error  = DATA(lv_error) ).

    IF lv_error = abap_false.
      COMMIT WORK.
    ELSE.
      ROLLBACK WORK.
    ENDIF.
  ENDMETHOD.

  METHOD zpru_if_long_memory_provider~summarize_conversation.

    IF io_input IS NOT BOUND.
      RETURN.
    ENDIF.

    DATA(lo_summarization) = zpru_if_long_memory_provider~get_summarization( ).

    lo_summarization->summarize(
      EXPORTING
        io_input  = io_input
      IMPORTING
        eo_output = eo_output ).

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
    mo_msg_persistence = io_msg_persistence.
  ENDMETHOD.

  METHOD zpru_if_long_memory_provider~set_sum_persistence.
    mo_sum_persistence = io_sum_persistence.
  ENDMETHOD.

  METHOD prepare_db_msg.
    DATA lt_message_db TYPE zpru_if_long_mem_persistence=>tt_message_db.

    FIELD-SYMBOLS <lt_message> TYPE zpru_if_long_mem_persistence=>tt_message.

    IF io_input IS NOT BOUND.
      RETURN.
    ENDIF.

    DATA(lr_data) = io_input->get_data( ).

    ASSIGN lr_data->* TO <lt_message>.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    GET TIME STAMP FIELD DATA(lv_now).

    DATA(lv_count) = 1.
    LOOP AT <lt_message> ASSIGNING FIELD-SYMBOL(<ls_message>).

      APPEND INITIAL LINE TO lt_message_db ASSIGNING FIELD-SYMBOL(<ls_message_db>).
      <ls_message_db> = CORRESPONDING #( <ls_message> EXCEPT content ).

      TRY.
          <ls_message_db>-message_uuid = cl_system_uuid=>create_uuid_x16_static( ).
        CATCH cx_uuid_error.
          ASSERT 1 = 2.
      ENDTRY.

      IF <ls_message_db>-message_cid IS INITIAL.
        <ls_message_db>-message_cid = |{ sy-uname }-{ lv_now }-{ lv_count }|.
      ENDIF.

      IF <ls_message_db>-user_name IS INITIAL.
        <ls_message_db>-user_name = sy-uname.
      ENDIF.

      IF <ls_message_db>-message_type IS INITIAL.
        <ls_message_db>-message_type = zpru_if_short_memory_provider=>cs_msg_type-info.
      ENDIF.

      IF <ls_message_db>-content IS NOT INITIAL.
        <ls_message_db>-content = NEW zpru_cl_agent_util( )->zpru_if_agent_util~serialize_json_2_xstring(
                                          <ls_message>-content ).
      ENDIF.

      <ls_message_db>-created_by = sy-uname.
      <ls_message_db>-created_at = lv_now.
      <ls_message_db>-changed_by = sy-uname.
      <ls_message_db>-changed_at = lv_now.

      lv_count += 1.
    ENDLOOP.

    IF     lt_message_db IS NOT INITIAL.
      IF eo_output     IS BOUND.
        eo_output->set_data( ir_data = NEW zpru_if_long_mem_persistence=>tt_message_db( lt_message_db ) ).
      ELSE.
        eo_output = NEW zpru_cl_payload( ).
        eo_output->set_data( ir_data = NEW zpru_if_long_mem_persistence=>tt_message_db( lt_message_db ) ).
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD prepare_db_sum.
    DATA lt_summarization_db TYPE zpru_if_long_mem_persistence=>tt_summarization_db.

    FIELD-SYMBOLS <lt_summarization> TYPE zpru_if_long_mem_persistence=>tt_summarization.

    IF io_input IS NOT BOUND.
      RETURN.
    ENDIF.

    DATA(lr_data) = io_input->get_data( ).

    ASSIGN lr_data->* TO <lt_summarization>.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    GET TIME STAMP FIELD DATA(lv_now).

    DATA(lv_count) = 1.
    LOOP AT <lt_summarization> ASSIGNING FIELD-SYMBOL(<ls_summarization>).

      APPEND INITIAL LINE TO lt_summarization_db ASSIGNING FIELD-SYMBOL(<ls_summarization_db>).
      <ls_summarization_db> = CORRESPONDING #( <ls_summarization> EXCEPT content ).

      TRY.
          <ls_summarization_db>-summary_uuid = cl_system_uuid=>create_uuid_x16_static( ).
        CATCH cx_uuid_error.
          ASSERT 1 = 2.
      ENDTRY.

      IF <ls_summarization_db>-summary_cid IS INITIAL.
        <ls_summarization_db>-summary_cid = |{ sy-uname }-{ lv_now }-{ lv_count }|.
      ENDIF.

      IF <ls_summarization_db>-user_name IS INITIAL.
        <ls_summarization_db>-user_name = sy-uname.
      ENDIF.

      IF <ls_summarization_db>-content IS NOT INITIAL.
        <ls_summarization_db>-content = NEW zpru_cl_agent_util( )->zpru_if_agent_util~serialize_json_2_xstring(
                                          <ls_summarization>-content ).
      ENDIF.

      <ls_summarization_db>-created_by = sy-uname.
      <ls_summarization_db>-created_at = lv_now.
      <ls_summarization_db>-changed_by = sy-uname.
      <ls_summarization_db>-changed_at = lv_now.

      lv_count += 1.
    ENDLOOP.

    IF     lt_summarization_db IS NOT INITIAL.
      IF eo_output     IS BOUND.
        eo_output->set_data( ir_data = NEW zpru_if_long_mem_persistence=>tt_summarization_db( lt_summarization_db ) ).
      ELSE.
        eo_output = NEW zpru_cl_payload( ).
        eo_output->set_data( ir_data = NEW zpru_if_long_mem_persistence=>tt_summarization_db( lt_summarization_db ) ).
      ENDIF.
    ENDIF.
  ENDMETHOD.



  METHOD zpru_if_long_memory_provider~get_summarization.
    IF mo_summarize IS NOT BOUND.
      mo_summarize = NEW zpru_cl_summarize_simple( ).
    ENDIF.
    ro_summarization = mo_summarize.
  ENDMETHOD.

  METHOD zpru_if_long_memory_provider~set_summarization.
    mo_summarize = io_summarization.
  ENDMETHOD.

ENDCLASS.
