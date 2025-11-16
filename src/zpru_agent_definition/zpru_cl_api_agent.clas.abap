CLASS zpru_cl_api_agent DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zpru_if_agent_frw.
    INTERFACES zpru_if_api_agent.

  PROTECTED SECTION.
    DATA ms_agent            TYPE zpru_agent.
    DATA mt_agent_tools      TYPE STANDARD TABLE OF zpru_agent_tool WITH EMPTY KEY.
    DATA mv_input_query      TYPE zpru_if_agent_frw=>ts_json.

    DATA ms_execution_header TYPE zpru_axc_head.
    DATA ms_execution_query  TYPE zpru_axc_query.
    DATA ms_execution_steps  TYPE STANDARD TABLE OF zpru_axc_step WITH EMPTY KEY.

ENDCLASS.


CLASS zpru_cl_api_agent IMPLEMENTATION.

  METHOD zpru_if_api_agent~save_execution.

  ENDMETHOD.

  METHOD zpru_if_api_agent~build_execution.
    DATA lo_decision_provider      TYPE REF TO zpru_if_decision_provider.
    DATA lo_query                  TYPE REF TO zpru_if_request.
    DATA lt_decision_engine_out    TYPE zpru_if_decision_provider=>tt_execution_plan.
    DATA lo_short_memory           TYPE REF TO zpru_if_short_memory_provider.
    DATA lo_long_memory            TYPE REF TO zpru_if_long_memory_provider.
    DATA lo_agent_info_provider    TYPE REF TO zpru_if_agent_info_provider.
    DATA lo_system_prompt_provider TYPE REF TO zpru_if_prompt_provider.
    DATA lo_first_tool_input TYPE REF TO zpru_if_response.

    IF    ms_agent       IS INITIAL
       OR mv_input_query IS INITIAL.
      RETURN.
    ENDIF.

    CREATE OBJECT lo_decision_provider TYPE (ms_agent-decision_provider).

    IF ms_agent-short_memory_provider IS NOT INITIAL.
      CREATE OBJECT lo_short_memory TYPE (ms_agent-short_memory_provider).
    ENDIF.

    IF ms_agent-long_memory_provider IS NOT INITIAL.
      CREATE OBJECT lo_long_memory TYPE (ms_agent-long_memory_provider).
    ENDIF.

    IF ms_agent-agent_info_provider IS NOT INITIAL.
      CREATE OBJECT lo_agent_info_provider TYPE (ms_agent-agent_info_provider).
    ENDIF.

    IF ms_agent-system_prompt_provider IS NOT INITIAL.
      CREATE OBJECT lo_system_prompt_provider TYPE (ms_agent-system_prompt_provider).
    ENDIF.

    lo_query = NEW zpru_cl_request( ).
    lo_query->set_data( ir_data = NEW zpru_if_agent_frw=>ts_json( mv_input_query ) ).

    lo_decision_provider->call_decision_engine( EXPORTING io_input               = lo_query
                                                          io_system_prompt       = lo_system_prompt_provider
                                                          io_short_memory        = lo_short_memory
                                                          io_long_memory         = lo_long_memory
                                                          io_agent_info_provider = lo_agent_info_provider
                                                IMPORTING eo_execution_plan      = lt_decision_engine_out
                                                          eo_first_tool_input    = lo_first_tool_input ).


    IF lt_decision_engine_out IS INITIAL.
      RETURN.
    ENDIF.

    " create execution header
    GET TIME STAMP FIELD DATA(lv_now).

    TRY.
        ms_execution_header-run_uuid        = cl_system_uuid=>create_uuid_x16_static( ).
        ms_execution_header-agent_uuid      = ms_agent-agent_uuid.
        ms_execution_header-user_id         = sy-uname.
        ms_execution_header-start_timestamp = lv_now.
*        ms_execution_header-end_timestamp        =  .
        ms_execution_header-run_status      = 'N'.

        DATA(lt_history) = lo_short_memory->get_history( ).

        ms_execution_query-query_uuid   = cl_system_uuid=>create_uuid_x16_static( ).
        ms_execution_query-run_uuid     = ms_execution_header-run_uuid.
        ms_execution_query-language     = sy-langu. " where to take?
        ms_execution_query-input_prompt = VALUE #( lt_history[ 1 ]-history OPTIONAL ). " only user input or full first prompt?
*ms_execution_query-output_response     =  .

        LOOP AT lt_decision_engine_out ASSIGNING FIELD-SYMBOL(<ls_tool>).

          ASSIGN mt_agent_tools[ agent_uuid = <ls_tool>-agent_uuid
                                 tool_name  = <ls_tool>-tool_name ] TO FIELD-SYMBOL(<ls_tool_master_data>).
          IF sy-subrc <> 0.
            RETURN.
          ENDIF.

          APPEND INITIAL LINE TO ms_execution_steps ASSIGNING FIELD-SYMBOL(<ls_execution_step>).
          <ls_execution_step>-query_uuid          =  ms_execution_query-query_uuid.
          <ls_execution_step>-run_uuid            =  ms_execution_header-run_uuid.
          <ls_execution_step>-tool_uuid           = <ls_tool_master_data>-tool_uuid.
          <ls_execution_step>-execution_seq       =  <ls_tool>-sequence.
          <ls_execution_step>-start_timestamp     =  lv_now.
*          <ls_execution_step>-end_timestamp       =  .
          IF lo_first_tool_input IS BOUND.
            <ls_execution_step>-input_prompt        = lo_first_tool_input->get_data( )->*.
          ENDIF.
*          <ls_execution_step>-output_prompt       =  .
        ENDLOOP.

      CATCH cx_uuid_error.
        RETURN.
    ENDTRY.

  ENDMETHOD.

  METHOD zpru_if_api_agent~initialize.
    SELECT * FROM zpru_agent
      WHERE agent_name = @iv_agent_name
      INTO TABLE @DATA(lt_agent).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    ms_agent = VALUE #( lt_agent[ 1 ] OPTIONAL ).

    IF ms_agent IS INITIAL.
      RETURN.
    ENDIF.

    SELECT * FROM zpru_agent_tool
      WHERE agent_uuid = @ms_agent-agent_uuid
      INTO TABLE @mt_agent_tools.
  ENDMETHOD.

  METHOD zpru_if_api_agent~rerun_execution.
  ENDMETHOD.

  METHOD zpru_if_api_agent~rerun_from_step.
  ENDMETHOD.

  METHOD zpru_if_api_agent~run.
  ENDMETHOD.

  METHOD zpru_if_api_agent~set_input_query.
    DATA lo_short_memory TYPE REF TO zpru_if_short_memory_provider.

    IF iv_input_query IS INITIAL.
      RETURN.
    ENDIF.

    IF ms_agent-short_memory_provider IS NOT INITIAL.
      CREATE OBJECT lo_short_memory TYPE (ms_agent-short_memory_provider).
    ENDIF.

    lo_short_memory->save_message( iv_message_type = zpru_if_short_memory_provider=>query
                                   is_message      = iv_input_query ).

    mv_input_query = iv_input_query.
  ENDMETHOD.
ENDCLASS.
