CLASS zpru_cl_api_agent DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zpru_if_agent_frw.
    INTERFACES zpru_if_api_agent.

  PROTECTED SECTION.
    DATA mo_controller       TYPE REF TO zpru_if_agent_controller.
    DATA mo_short_memory     TYPE REF TO zpru_if_short_memory_provider.

    DATA ms_agent            TYPE zpru_agent.
    DATA mt_agent_tools      TYPE STANDARD TABLE OF zpru_agent_tool WITH EMPTY KEY.
    DATA mv_input_query      TYPE zpru_if_agent_frw=>ts_json.

    DATA ms_execution_header TYPE zpru_axc_head.
    DATA ms_execution_query  TYPE zpru_axc_query.
    DATA mt_execution_steps  TYPE STANDARD TABLE OF zpru_axc_step WITH EMPTY KEY.

    METHODS get_short_memory
      RETURNING VALUE(ro_short_memory) TYPE REF TO zpru_if_short_memory_provider.

ENDCLASS.


CLASS zpru_cl_api_agent IMPLEMENTATION.
  METHOD zpru_if_api_agent~save_execution.
    DATA lo_axc_database_access TYPE REF TO zpru_if_axc_database_access.

    " PREFETCH VIA IMPORTED UUID

    IF ms_execution_header IS INITIAL.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
      RETURN.
    ENDIF.

    lo_axc_database_access = NEW zpru_cl_axc_database_access( ).

    lo_axc_database_access->modify_head( EXPORTING it_axc_head = VALUE #( ( ms_execution_header ) )
                                         IMPORTING ev_error    = DATA(lv_head_error) ).
    IF lv_head_error = abap_true.
      IF iv_do_commit = abap_true.
        ROLLBACK WORK.
      ENDIF.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    lo_axc_database_access->modify_query( EXPORTING it_axc_query = VALUE #( ( ms_execution_query ) )
                                          IMPORTING ev_error     = DATA(lv_query_error) ).
    IF lv_query_error = abap_true.
      IF iv_do_commit = abap_true.
        ROLLBACK WORK.
      ENDIF.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    lo_axc_database_access->modify_step( EXPORTING it_axc_step = mt_execution_steps
                                         IMPORTING ev_error    = DATA(lv_step_error) ).
    IF lv_step_error = abap_true.
      IF iv_do_commit = abap_true.
        ROLLBACK WORK.
      ENDIF.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    IF iv_do_commit = abap_true.
      COMMIT WORK AND WAIT.
    ENDIF.

    rv_saved_run_uuid = ms_execution_header-run_uuid.
  ENDMETHOD.

  METHOD zpru_if_api_agent~build_execution.
    DATA lo_decision_provider      TYPE REF TO zpru_if_decision_provider.
    DATA lo_query                  TYPE REF TO zpru_if_request.
    DATA lt_execution_plan         TYPE zpru_if_decision_provider=>tt_execution_plan.
    DATA lo_short_memory           TYPE REF TO zpru_if_short_memory_provider.
    DATA lo_long_memory            TYPE REF TO zpru_if_long_memory_provider.
    DATA lo_agent_info_provider    TYPE REF TO zpru_if_agent_info_provider.
    DATA lo_system_prompt_provider TYPE REF TO zpru_if_prompt_provider.
    DATA lo_first_tool_input       TYPE REF TO zpru_if_response.
    DATA lo_execution_plan         TYPE REF TO zpru_if_response.
    DATA lo_langu                  TYPE REF TO zpru_if_response.
    DATA lo_decision_log           TYPE REF TO zpru_if_response.
    DATA lt_message_in             TYPE zpru_tt_key_value_tuple.
    DATA lv_langu                  TYPE sylangu.
    DATA lv_decision_log           TYPE zpru_if_agent_frw=>ts_json.
    DATA lv_first_tool_input       TYPE zpru_if_agent_frw=>ts_json.

    IF    ms_agent       IS INITIAL
       OR mv_input_query IS INITIAL.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
      RETURN.
    ENDIF.

    CREATE OBJECT lo_decision_provider TYPE (ms_agent-decision_provider).

    lo_short_memory = get_short_memory( ).

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

    mo_controller->mv_agent_uuid = ms_agent-agent_uuid.

    lt_message_in = VALUE #( ( name  = 'STAGE'
                               value = 'BUILD_EXECUTION' )
                             ( name  = 'SUB STAGE'
                               value = 'BEFORE DECISION' )
                             ( name  = 'AGENT_NAME'
                               value = ms_agent-agent_name )
                             ( name  = 'SYSTEM PROMPT'
                               value = lo_system_prompt_provider->get_system_prompt( ) )
                             ( name  = 'AGENT INFO'
                               value = lo_agent_info_provider->get_agent_info( ) ) ).

    lo_short_memory->save_message( iv_agent_uuid   = ms_agent-agent_uuid
                                   iv_message_type = zpru_if_short_memory_provider=>info
                                   ir_message      = REF #( lt_message_in ) ).
    lo_first_tool_input = NEW zpru_cl_response( ).
    lo_execution_plan   = NEW zpru_cl_response( ).
    lo_langu            = NEW zpru_cl_response( ).
    lo_decision_log     = NEW zpru_cl_response( ).

    lo_decision_provider->call_decision_engine( EXPORTING io_controller          = mo_controller
                                                          io_input               = lo_query
                                                          io_system_prompt       = lo_system_prompt_provider
                                                          io_short_memory        = lo_short_memory
                                                          io_long_memory         = lo_long_memory
                                                          io_agent_info_provider = lo_agent_info_provider
                                                IMPORTING eo_execution_plan      = lo_execution_plan
                                                          eo_first_tool_input    = lo_first_tool_input
                                                          eo_langu               = lo_langu
                                                          eo_decision_log        = lo_decision_log ).

    IF lo_execution_plan IS BOUND.
      lt_execution_plan = lo_execution_plan->get_data( )->*.
    ENDIF.

    IF lt_execution_plan IS INITIAL.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
      RETURN.
    ENDIF.

    IF lo_decision_log IS BOUND.
      lv_decision_log = lo_decision_log->get_data( )->*.
    ENDIF.

    IF lo_first_tool_input IS BOUND.
      lv_first_tool_input = lo_first_tool_input->get_data( )->*.
    ENDIF.

    lt_message_in = VALUE #( ( name  = 'STAGE'
                               value = 'BUILD_EXECUTION' )
                             ( name  = 'SUB STAGE'
                               value = 'AFTER DECISION' )
                             ( name  = 'AGENT_NAME'
                               value = ms_agent-agent_name )
                             ( name  = 'FIRST TOOL INPUT'
                               value = lv_first_tool_input )
                             ( name  = 'DECISION LOG'
                               value = lv_decision_log ) ).

    LOOP AT lt_execution_plan ASSIGNING FIELD-SYMBOL(<ls_execution_plan>).
      APPEND INITIAL LINE TO lt_message_in ASSIGNING FIELD-SYMBOL(<ls_message>).
      <ls_message>-name  = 'TOOL TO BE BUILD'.
      <ls_message>-value = <ls_execution_plan>-tool_name.
    ENDLOOP.

    lo_short_memory->save_message( iv_agent_uuid   = ms_agent-agent_uuid
                                   iv_message_type = zpru_if_short_memory_provider=>info
                                   ir_message      = REF #( lt_message_in ) ).

    " create execution header
    GET TIME STAMP FIELD DATA(lv_now).

    TRY.
        " header
        ms_execution_header-run_uuid           = cl_system_uuid=>create_uuid_x16_static( ).
        ms_execution_header-agent_uuid         = ms_agent-agent_uuid.
        ms_execution_header-user_id            = sy-uname.
        ms_execution_header-start_timestamp    = lv_now.
        ms_execution_header-created_by         = sy-uname.
        ms_execution_header-created_at         = lv_now.
        ms_execution_header-changed_by         = sy-uname.
        ms_execution_header-last_changed       = lv_now.
        ms_execution_header-local_last_changed = lv_now.

        IF lo_langu IS BOUND.
          lv_langu = lo_langu->get_data( )->*.
        ENDIF.

        " query
        ms_execution_query-query_uuid       = cl_system_uuid=>create_uuid_x16_static( ).
        ms_execution_query-run_uuid         = ms_execution_header-run_uuid.
        ms_execution_query-language         = COND #( WHEN lv_langu IS NOT INITIAL
                                                      THEN lv_langu
                                                      ELSE sy-langu ).
        ms_execution_query-execution_status = zpru_if_agent_frw=>cs_execution_status-new.
        ms_execution_query-start_timestamp  = lv_now.
        ms_execution_query-input_prompt     = mv_input_query.
        ms_execution_query-decision_log     = lv_decision_log.

        " execution plan
        LOOP AT lt_execution_plan ASSIGNING FIELD-SYMBOL(<ls_tool>).

          ASSIGN mt_agent_tools[ agent_uuid = <ls_tool>-agent_uuid
                                 tool_name  = <ls_tool>-tool_name ] TO FIELD-SYMBOL(<ls_tool_master_data>).
          IF sy-subrc <> 0.
            RETURN.
          ENDIF.

          APPEND INITIAL LINE TO mt_execution_steps ASSIGNING FIELD-SYMBOL(<ls_execution_step>).
          <ls_execution_step>-step_uuid       = cl_system_uuid=>create_uuid_x16_static( ).
          <ls_execution_step>-query_uuid      = ms_execution_query-query_uuid.
          <ls_execution_step>-run_uuid        = ms_execution_header-run_uuid.
          <ls_execution_step>-tool_uuid       = <ls_tool_master_data>-tool_uuid.
          <ls_execution_step>-execution_seq   = <ls_tool>-sequence.
          <ls_execution_step>-start_timestamp = lv_now.
          <ls_execution_step>-input_prompt    = lv_first_tool_input.
        ENDLOOP.

      CATCH cx_uuid_error.
        RETURN.
    ENDTRY.

    rv_built_run_uuid = ms_execution_header-run_uuid.
  ENDMETHOD.

  METHOD zpru_if_api_agent~initialize.
    DATA lo_adf_service  TYPE REF TO zpru_if_adf_service.
    DATA lo_short_memory TYPE REF TO zpru_if_short_memory_provider.
    DATA lt_message      TYPE zpru_tt_key_value_tuple.
    DATA ls_reported     TYPE zpru_if_agent_frw=>ts_adf_reported.
    DATA ls_failed       TYPE zpru_if_agent_frw=>ts_adf_failed.

    IF iv_agent_name IS INITIAL.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
      RETURN.
    ENDIF.

    mo_controller = NEW zpru_cl_agent_controller( ).

    lo_adf_service = zpru_cl_adf_factory=>zpru_if_adf_factory~get_zpru_if_adf_service( ).

    lo_adf_service->query_agent( EXPORTING it_agent_name = VALUE #( ( sign   = zpru_if_agent_frw=>cs_sign-include
                                                                      option = zpru_if_agent_frw=>cs_option-equal
                                                                      low    = iv_agent_name ) )
                                 IMPORTING et_agent_k    = DATA(lt_agent_k) ).

    lo_adf_service->read_agent(
      EXPORTING it_agent_read_k = VALUE #( FOR <ls_k> IN lt_agent_k
                                           ( agent_uuid                     = <ls_k>-agent_uuid
                                             control-agent_uuid             = abap_true
                                             control-agent_name             = abap_true
                                             control-decision_provider      = abap_true
                                             control-short_memory_provider  = abap_true
                                             control-long_memory_provider   = abap_true
                                             control-agent_info_provider    = abap_true
                                             control-system_prompt_provider = abap_true
                                             control-status                 = abap_true
                                             control-created_by             = abap_true
                                             control-created_at             = abap_true
                                             control-changed_by             = abap_true
                                             control-last_changed           = abap_true
                                             control-local_last_changed     = abap_true ) )
      IMPORTING et_agent        = DATA(lt_agent)
      CHANGING  cs_reported     = ls_reported
                cs_failed       = ls_failed ).

    lo_adf_service->rba_tool( EXPORTING it_rba_tool_k = VALUE #( FOR <ls_k2> IN lt_agent_k
                                                                 ( agent_uuid                    = <ls_k2>-agent_uuid
                                                                   control-tool_uuid             = abap_true
                                                                   control-agent_uuid            = abap_true
                                                                   control-tool_name             = abap_true
                                                                   control-tool_provider         = abap_true
                                                                   control-step_type             = abap_true
                                                                   control-input_schema_provider = abap_true
                                                                   control-tool_info_provider    = abap_true    ) )
                              IMPORTING et_tool       = mt_agent_tools
                              CHANGING  cs_reported   = ls_reported
                                        cs_failed     = ls_failed ).

    ms_agent = VALUE #( lt_agent[ 1 ] OPTIONAL ).

    IF ms_agent IS INITIAL.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
      RETURN.
    ENDIF.

    lo_short_memory = get_short_memory( ).

    lt_message = VALUE #( ( name  = 'STAGE'
                            value = 'INITIALIZE' )
                          ( name  = 'AGENT_NAME'
                            value = iv_agent_name ) ).

    LOOP AT mt_agent_tools ASSIGNING FIELD-SYMBOL(<ls_tool>).
      APPEND INITIAL LINE TO lt_message ASSIGNING FIELD-SYMBOL(<ls_message>).
      <ls_message>-name  = 'ASSIGNED TOOL'.
      <ls_message>-value = <ls_tool>-tool_name.
    ENDLOOP.

    lo_short_memory->save_message( iv_agent_uuid   = ms_agent-agent_uuid
                                   iv_message_type = zpru_if_short_memory_provider=>info
                                   ir_message      = REF #( lt_message ) ).
  ENDMETHOD.

  METHOD zpru_if_api_agent~rerun.
  ENDMETHOD.

  METHOD zpru_if_api_agent~rerun_from_step.
  ENDMETHOD.

  METHOD zpru_if_api_agent~run.
    DATA lo_executor     TYPE REF TO zpru_if_tool_executor.
    DATA lo_input        TYPE REF TO zpru_if_request.
    DATA lo_output       TYPE REF TO zpru_if_response.
    DATA lv_query_to_run TYPE sysuuid_x16.

    IF iv_run_uuid IS INITIAL.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    DATA(lo_axc_database_access) = NEW zpru_cl_axc_database_access( ).
    DATA(lt_execution_header) = lo_axc_database_access->zpru_if_axc_database_access~select_head(
                                    it_axc_head_k = VALUE #( ( run_uuid = iv_run_uuid ) ) ).

    ASSIGN lt_execution_header[ 1 ] TO FIELD-SYMBOL(<ls_execution_header>).
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    ms_execution_header = <ls_execution_header>.

    IF iv_query_uuid IS INITIAL.
      " lv_query_to_run = QUERY_EXECUTION MAKE SERVICE FOR THAT QQQ
    ELSE.
      lv_query_to_run = iv_query_uuid.
    ENDIF.

    DATA(lt_execution_query) = lo_axc_database_access->zpru_if_axc_database_access~select_query(
                                   it_axc_query_k = VALUE #( ( query_uuid = lv_query_to_run ) ) ).

    ASSIGN lt_execution_query[ 1 ] TO FIELD-SYMBOL(<ls_execution_query>).
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    ms_execution_query = <ls_execution_query>.

    IF    ms_execution_header IS INITIAL
       OR ms_execution_query  IS INITIAL
       OR mt_execution_steps  IS INITIAL.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    LOOP AT mt_execution_steps ASSIGNING FIELD-SYMBOL(<ls_execution_step>).

      DATA(lv_tabix) = sy-tabix.

      ASSIGN mt_agent_tools[ tool_uuid = <ls_execution_step>-tool_uuid ] TO FIELD-SYMBOL(<ls_tool_master_data>).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      CREATE OBJECT lo_executor TYPE (<ls_tool_master_data>-tool_provider).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      IF lv_tabix = 1.
        lo_input = NEW zpru_cl_request( ).
        lo_input->set_data( ir_data = REF #( <ls_execution_step>-input_prompt ) ).
        lo_output = NEW zpru_cl_response( ).
      ELSE.
        DATA(lr_output) = lo_output->get_data( ).
        IF lr_output IS BOUND AND lr_output->* IS NOT INITIAL.
          lo_input->set_data( ir_data = lo_output->get_data( ) ).
        ELSE.
          lo_input->clear_data( ).
        ENDIF.
        lo_output->clear_data( ).
      ENDIF.

      lo_executor->execute_tool( EXPORTING io_controller = mo_controller
                                           io_request    = lo_input
                                 IMPORTING eo_response   = lo_output ).

      " SET INPUT AND OUTPUT PROMPT FOR EACH TOOL

      IF mo_controller->mv_stop_agent = abap_true.
        EXIT.
      ENDIF.

    ENDLOOP.

    " set output prompt on query node
  ENDMETHOD.

  METHOD zpru_if_api_agent~set_input_query.
    DATA lo_short_memory TYPE REF TO zpru_if_short_memory_provider.
    DATA lt_message      TYPE zpru_tt_key_value_tuple.

    IF iv_input_query IS INITIAL.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
      RETURN.
    ENDIF.

    mv_input_query = iv_input_query.

    lo_short_memory = get_short_memory( ).

    lt_message = VALUE #( ( name  = 'STAGE'
                            value = 'SET_INPUT_QUERY' )
                          ( name  = 'AGENT_NAME'
                            value = ms_agent-agent_name )
                          ( name  = 'INPUT_QUERY'
                            value = mv_input_query )   ).

    lo_short_memory->save_message( iv_agent_uuid   = ms_agent-agent_uuid
                                   iv_message_type = zpru_if_short_memory_provider=>query
                                   ir_message      = REF #( lt_message ) ).
  ENDMETHOD.

  METHOD get_short_memory.
    IF mo_short_memory IS BOUND.
      ro_short_memory = mo_short_memory.
      RETURN.
    ENDIF.

    IF ms_agent-short_memory_provider IS NOT INITIAL.
      CREATE OBJECT mo_short_memory TYPE (ms_agent-short_memory_provider).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
