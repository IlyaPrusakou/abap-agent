CLASS zpru_cl_api_agent DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zpru_if_agent_frw.
    INTERFACES zpru_if_api_agent.

  PROTECTED SECTION.
    DATA mo_controller   TYPE REF TO zpru_if_agent_controller.
    DATA mo_short_memory TYPE REF TO zpru_if_short_memory_provider.
    DATA mv_input_query  TYPE zpru_if_agent_frw=>ts_json.

    METHODS get_short_memory
      IMPORTING iv_agent_uuid   TYPE sysuuid_x16
      EXPORTING eo_short_memory TYPE REF TO zpru_if_short_memory_provider
      CHANGING  cs_reported     TYPE zpru_if_agent_frw=>ts_adf_reported
                cs_failed       TYPE zpru_if_agent_frw=>ts_adf_failed
      RAISING   zpru_cx_agent_core.

    METHODS process_execution_steps
      IMPORTING is_execution_query TYPE zpru_if_axc_type_and_constant=>ts_axc_query
                it_execution_steps TYPE zpru_if_axc_type_and_constant=>tt_axc_step
                it_agent_tools     TYPE zpru_if_adf_type_and_constant=>tt_agent_tool
      CHANGING  cs_axc_reported    TYPE zpru_if_agent_frw=>ts_axc_reported
                cs_axc_failed      TYPE zpru_if_agent_frw=>ts_axc_failed.

    METHODS prepare_execution
      IMPORTING iv_run_uuid        TYPE sysuuid_x16
                iv_query_uuid      TYPE sysuuid_x16 OPTIONAL
      EXPORTING es_execution_query TYPE zpru_if_axc_type_and_constant=>ts_axc_query
                et_execution_steps TYPE zpru_if_axc_type_and_constant=>tt_axc_step
                et_agent_tools     TYPE zpru_if_adf_type_and_constant=>tt_agent_tool
      CHANGING  cs_axc_reported    TYPE zpru_if_agent_frw=>ts_axc_reported
                cs_axc_failed      TYPE zpru_if_agent_frw=>ts_axc_failed
                cs_adf_reported    TYPE zpru_if_agent_frw=>ts_adf_reported
                cs_adf_failed      TYPE zpru_if_agent_frw=>ts_adf_failed
      RAISING   zpru_cx_agent_core.

ENDCLASS.


CLASS zpru_cl_api_agent IMPLEMENTATION.
  METHOD zpru_if_api_agent~save_execution.
    DATA lo_axc_service TYPE REF TO zpru_if_axc_service.

    lo_axc_service = zpru_cl_axc_factory=>zpru_if_axc_factory~get_zpru_if_axc_service( ).
    lo_axc_service->do_save( EXPORTING iv_do_commit = abap_false
                             CHANGING  cs_reported  = cs_axc_reported
                                       cs_failed    = cs_axc_failed
                                       cs_mapped    = cs_axc_mapped ).

    IF    cs_axc_failed-header IS NOT INITIAL
       OR cs_axc_failed-query  IS NOT INITIAL
       OR cs_axc_failed-step   IS NOT INITIAL.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    IF iv_do_commit = abap_false.
      RETURN.
    ENDIF.

    lo_axc_service->do_save( EXPORTING iv_do_commit = abap_true
                             CHANGING  cs_reported  = cs_axc_reported
                                       cs_failed    = cs_axc_failed
                                       cs_mapped    = cs_axc_mapped ).
  ENDMETHOD.

  METHOD zpru_if_api_agent~build_execution.
    DATA lo_decision_provider      TYPE REF TO zpru_if_decision_provider.
    DATA lo_query                  TYPE REF TO zpru_if_payload.
    DATA lt_execution_plan         TYPE zpru_if_decision_provider=>tt_execution_plan.
    DATA lo_short_memory           TYPE REF TO zpru_if_short_memory_provider.
    DATA lo_long_memory            TYPE REF TO zpru_if_long_memory_provider.
    DATA lo_agent_info_provider    TYPE REF TO zpru_if_agent_info_provider.
    DATA lo_system_prompt_provider TYPE REF TO zpru_if_prompt_provider.
    DATA lo_first_tool_input       TYPE REF TO zpru_if_payload.
    DATA lo_execution_plan         TYPE REF TO zpru_if_payload.
    DATA lo_langu                  TYPE REF TO zpru_if_payload.
    DATA lo_decision_log           TYPE REF TO zpru_if_payload.
    DATA lt_message_in             TYPE zpru_tt_key_value_tuple.
    DATA lv_langu                  TYPE sylangu.
    DATA lv_decision_log           TYPE zpru_if_agent_frw=>ts_json.
    DATA lv_first_tool_input       TYPE zpru_if_agent_frw=>ts_json.
    DATA lo_axc_service            TYPE REF TO zpru_if_axc_service.
    DATA ls_execution_header       TYPE zpru_axc_head.
    DATA ls_execution_query        TYPE zpru_axc_query.
    DATA lt_execution_steps        TYPE STANDARD TABLE OF zpru_axc_step WITH EMPTY KEY.
    DATA lo_adf_service            TYPE REF TO zpru_if_adf_service.

    CLEAR ev_built_run_uuid.

    IF    iv_agent_uuid  IS INITIAL
       OR mv_input_query IS INITIAL.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    lo_adf_service = zpru_cl_adf_factory=>zpru_if_adf_factory~get_zpru_if_adf_service( ).

    lo_adf_service->read_agent( EXPORTING it_agent_read_k = VALUE #( ( agent_uuid                     = iv_agent_uuid
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
                                CHANGING  cs_reported     = cs_adf_reported
                                          cs_failed       = cs_adf_failed ).

    DATA(ls_agent) = VALUE #( lt_agent[ 1 ] OPTIONAL ).
    IF ls_agent IS INITIAL.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    lo_adf_service->rba_tool( EXPORTING it_rba_tool_k = VALUE #( ( agent_uuid                    = ls_agent-agent_uuid
                                                                   control-tool_uuid             = abap_true
                                                                   control-agent_uuid            = abap_true
                                                                   control-tool_name             = abap_true
                                                                   control-tool_provider         = abap_true
                                                                   control-step_type             = abap_true
                                                                   control-input_schema_provider = abap_true
                                                                   control-tool_info_provider    = abap_true    ) )
                              IMPORTING et_tool       = DATA(lt_agent_tools)
                              CHANGING  cs_reported   = cs_adf_reported
                                        cs_failed     = cs_adf_failed ).

    CREATE OBJECT lo_decision_provider TYPE (ls_agent-decision_provider).

    get_short_memory( EXPORTING iv_agent_uuid   = ls_agent-agent_uuid
                      IMPORTING eo_short_memory = lo_short_memory
                      CHANGING  cs_reported     = cs_adf_reported
                                cs_failed       = cs_adf_failed ).

    IF ls_agent-long_memory_provider IS NOT INITIAL.
      CREATE OBJECT lo_long_memory TYPE (ls_agent-long_memory_provider).
    ENDIF.

    IF ls_agent-agent_info_provider IS NOT INITIAL.
      CREATE OBJECT lo_agent_info_provider TYPE (ls_agent-agent_info_provider).
    ENDIF.

    IF ls_agent-system_prompt_provider IS NOT INITIAL.
      CREATE OBJECT lo_system_prompt_provider TYPE (ls_agent-system_prompt_provider).
    ENDIF.

    lo_query = NEW zpru_cl_payload( ).
    lo_query->set_data( ir_data = NEW zpru_if_agent_frw=>ts_json( mv_input_query ) ).

    mo_controller->mv_agent_uuid = ls_agent-agent_uuid.

    lt_message_in = VALUE #( ( name  = 'STAGE'
                               value = 'BUILD_EXECUTION' )
                             ( name  = 'SUB STAGE'
                               value = 'BEFORE DECISION' )
                             ( name  = 'AGENT_NAME'
                               value = ls_agent-agent_name )
                             ( name  = 'SYSTEM PROMPT'
                               value = lo_system_prompt_provider->get_system_prompt( ) )
                             ( name  = 'AGENT INFO'
                               value = lo_agent_info_provider->get_agent_info( ) ) ).

    lo_short_memory->save_message( iv_agent_uuid   = ls_agent-agent_uuid
                                   iv_message_type = zpru_if_short_memory_provider=>info
                                   ir_message      = REF #( lt_message_in ) ).

    lo_first_tool_input = NEW zpru_cl_payload( ).
    lo_execution_plan   = NEW zpru_cl_payload( ).
    lo_langu            = NEW zpru_cl_payload( ).
    lo_decision_log     = NEW zpru_cl_payload( ).

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
                               value = ls_agent-agent_name )
                             ( name  = 'FIRST TOOL INPUT'
                               value = lv_first_tool_input )
                             ( name  = 'DECISION LOG'
                               value = lv_decision_log ) ).

    LOOP AT lt_execution_plan ASSIGNING FIELD-SYMBOL(<ls_execution_plan>).
      APPEND INITIAL LINE TO lt_message_in ASSIGNING FIELD-SYMBOL(<ls_message>).
      <ls_message>-name  = 'TOOL TO BE BUILD'.
      <ls_message>-value = <ls_execution_plan>-tool_name.
    ENDLOOP.

    lo_short_memory->save_message( iv_agent_uuid   = ls_agent-agent_uuid
                                   iv_message_type = zpru_if_short_memory_provider=>info
                                   ir_message      = REF #( lt_message_in ) ).

    lo_axc_service = zpru_cl_axc_factory=>zpru_if_axc_factory~get_zpru_if_axc_service( ).

    " create execution header
    GET TIME STAMP FIELD DATA(lv_now).

    TRY.
        " header
        ls_execution_header-run_uuid           = cl_system_uuid=>create_uuid_x16_static( ).
        ls_execution_header-agent_uuid         = ls_agent-agent_uuid.
        ls_execution_header-user_id            = sy-uname.
        ls_execution_header-start_timestamp    = lv_now.
        ls_execution_header-created_by         = sy-uname.
        ls_execution_header-created_at         = lv_now.
        ls_execution_header-changed_by         = sy-uname.
        ls_execution_header-last_changed       = lv_now.
        ls_execution_header-local_last_changed = lv_now.

        IF lo_langu IS BOUND.
          lv_langu = lo_langu->get_data( )->*.
        ENDIF.

        lo_axc_service->create_header(
          EXPORTING it_head_create_imp = VALUE #( ( run_uuid           = ls_execution_header-run_uuid
                                                    agent_uuid         = ls_execution_header-agent_uuid
                                                    user_id            = ls_execution_header-user_id
                                                    start_timestamp    = ls_execution_header-start_timestamp
                                                    end_timestamp      = ls_execution_header-end_timestamp
                                                    created_by         = ls_execution_header-created_by
                                                    created_at         = ls_execution_header-created_at
                                                    changed_by         = ls_execution_header-changed_by
                                                    last_changed       = ls_execution_header-last_changed
                                                    local_last_changed = ls_execution_header-local_last_changed
                                                    control            = VALUE #( run_uuid           = abap_true
                                                                                  agent_uuid         = abap_true
                                                                                  user_id            = abap_true
                                                                                  start_timestamp    = abap_true
                                                                                  end_timestamp      = abap_true
                                                                                  created_by         = abap_true
                                                                                  created_at         = abap_true
                                                                                  changed_by         = abap_true
                                                                                  last_changed       = abap_true
                                                                                  local_last_changed = abap_true ) ) )
          CHANGING  cs_reported        = cs_axc_reported
                    cs_failed          = cs_axc_failed
                    cs_mapped          = cs_axc_mapped ).

        " query
        ls_execution_query-query_uuid       = cl_system_uuid=>create_uuid_x16_static( ).
        ls_execution_query-run_uuid         = ls_execution_header-run_uuid.
        ls_execution_query-language         = COND #( WHEN lv_langu IS NOT INITIAL
                                                      THEN lv_langu
                                                      ELSE sy-langu ).
        ls_execution_query-execution_status = zpru_if_agent_frw=>cs_execution_status-new.
        ls_execution_query-start_timestamp  = lv_now.
        ls_execution_query-input_prompt     = mv_input_query.
        ls_execution_query-decision_log     = lv_decision_log.

        lo_axc_service->cba_query(
          EXPORTING it_axc_query_imp = VALUE #( ( query_uuid       = ls_execution_query-query_uuid
                                                  run_uuid         = ls_execution_query-run_uuid
                                                  language         = ls_execution_query-language
                                                  execution_status = ls_execution_query-execution_status
                                                  start_timestamp  = ls_execution_query-start_timestamp
                                                  end_timestamp    = ls_execution_query-end_timestamp
                                                  input_prompt     = ls_execution_query-input_prompt
                                                  decision_log     = ls_execution_query-decision_log
                                                  output_response  = ls_execution_query-output_response
                                                  control          = VALUE #( query_uuid       = abap_true
                                                                              run_uuid         = abap_true
                                                                              language         = abap_true
                                                                              execution_status = abap_true
                                                                              start_timestamp  = abap_true
                                                                              end_timestamp    = abap_true
                                                                              input_prompt     = abap_true
                                                                              decision_log     = abap_true
                                                                              output_response  = abap_true ) ) )
          CHANGING  cs_reported      = cs_axc_reported
                    cs_failed        = cs_axc_failed
                    cs_mapped        = cs_axc_mapped ).

        " execution plan
        LOOP AT lt_execution_plan ASSIGNING FIELD-SYMBOL(<ls_tool>).

          ASSIGN lt_agent_tools[ agent_uuid = <ls_tool>-agent_uuid
                                 tool_name  = <ls_tool>-tool_name ] TO FIELD-SYMBOL(<ls_tool_master_data>).
          IF sy-subrc <> 0.
            RETURN.
          ENDIF.

          APPEND INITIAL LINE TO lt_execution_steps ASSIGNING FIELD-SYMBOL(<ls_execution_step>).
          <ls_execution_step>-step_uuid       = cl_system_uuid=>create_uuid_x16_static( ).
          <ls_execution_step>-query_uuid      = ls_execution_query-query_uuid.
          <ls_execution_step>-run_uuid        = ls_execution_header-run_uuid.
          <ls_execution_step>-tool_uuid       = <ls_tool_master_data>-tool_uuid.
          <ls_execution_step>-execution_seq   = <ls_tool>-sequence.
          <ls_execution_step>-start_timestamp = lv_now.
          <ls_execution_step>-input_prompt    = lv_first_tool_input.
        ENDLOOP.

        lo_axc_service->cba_step( EXPORTING it_axc_step_imp = VALUE #( FOR <ls_s> IN lt_execution_steps
                                                                       ( step_uuid       = <ls_s>-step_uuid
                                                                         query_uuid      = <ls_s>-query_uuid
                                                                         run_uuid        = <ls_s>-run_uuid
                                                                         tool_uuid       = <ls_s>-tool_uuid
                                                                         execution_seq   = <ls_s>-execution_seq
                                                                         start_timestamp = <ls_s>-start_timestamp
                                                                         end_timestamp   = <ls_s>-end_timestamp
                                                                         input_prompt    = <ls_s>-input_prompt
                                                                         output_prompt   = <ls_s>-output_prompt
                                                                         control         = VALUE #(
                                                                             step_uuid       = abap_true
                                                                             query_uuid      = abap_true
                                                                             run_uuid        = abap_true
                                                                             tool_uuid       = abap_true
                                                                             execution_seq   = abap_true
                                                                             start_timestamp = abap_true
                                                                             end_timestamp   = abap_true
                                                                             input_prompt    = abap_true
                                                                             output_prompt   = abap_true ) ) )
                                  CHANGING  cs_reported     = cs_axc_reported
                                            cs_failed       = cs_axc_failed
                                            cs_mapped       = cs_axc_mapped ).

      CATCH cx_uuid_error.
        RETURN.
    ENDTRY.

    ev_built_run_uuid = ls_execution_header-run_uuid.
  ENDMETHOD.

  METHOD zpru_if_api_agent~initialize.
    DATA lo_adf_service  TYPE REF TO zpru_if_adf_service.
    DATA lo_short_memory TYPE REF TO zpru_if_short_memory_provider.
    DATA lt_message      TYPE zpru_tt_key_value_tuple.

    CLEAR: es_agent,
           et_tools.

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
      CHANGING  cs_reported     = cs_adf_reported
                cs_failed       = cs_adf_failed ).

    lo_adf_service->rba_tool( EXPORTING it_rba_tool_k = VALUE #( FOR <ls_k2> IN lt_agent_k
                                                                 ( agent_uuid                    = <ls_k2>-agent_uuid
                                                                   control-tool_uuid             = abap_true
                                                                   control-agent_uuid            = abap_true
                                                                   control-tool_name             = abap_true
                                                                   control-tool_provider         = abap_true
                                                                   control-step_type             = abap_true
                                                                   control-input_schema_provider = abap_true
                                                                   control-tool_info_provider    = abap_true    ) )
                              IMPORTING et_tool       = et_tools
                              CHANGING  cs_reported   = cs_adf_reported
                                        cs_failed     = cs_adf_failed ).

    es_agent = VALUE #( lt_agent[ 1 ] OPTIONAL ).

    IF es_agent IS INITIAL.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    get_short_memory( EXPORTING iv_agent_uuid   = es_agent-agent_uuid
                      IMPORTING eo_short_memory = lo_short_memory
                      CHANGING  cs_reported     = cs_adf_reported
                                cs_failed       = cs_adf_failed ).

    lt_message = VALUE #( ( name  = 'STAGE'
                            value = 'INITIALIZE' )
                          ( name  = 'AGENT_NAME'
                            value = iv_agent_name ) ).

    LOOP AT et_tools ASSIGNING FIELD-SYMBOL(<ls_tool>).
      APPEND INITIAL LINE TO lt_message ASSIGNING FIELD-SYMBOL(<ls_message>).
      <ls_message>-name  = 'ASSIGNED TOOL'.
      <ls_message>-value = <ls_tool>-tool_name.
    ENDLOOP.

    lo_short_memory->save_message( iv_agent_uuid   = es_agent-agent_uuid
                                   iv_message_type = zpru_if_short_memory_provider=>info
                                   ir_message      = REF #( lt_message ) ).
  ENDMETHOD.

  METHOD zpru_if_api_agent~rerun.
    prepare_execution( EXPORTING iv_run_uuid        = iv_run_uuid
                                 iv_query_uuid      = iv_query_uuid
                       IMPORTING es_execution_query = DATA(ls_execution_query)
                                 et_execution_steps = DATA(lt_execution_steps)
                                 et_agent_tools     = DATA(lt_agent_tools)
                       CHANGING  cs_axc_reported    = cs_axc_reported
                                 cs_axc_failed      = cs_axc_failed
                                 cs_adf_reported    = cs_adf_reported
                                 cs_adf_failed      = cs_adf_failed ).

    IF    lt_execution_steps IS INITIAL
       OR lt_agent_tools     IS INITIAL
       OR ls_execution_query IS INITIAL.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    IF ls_execution_query-execution_status = zpru_if_axc_type_and_constant=>sc_query_status-new OR
       ls_execution_query-execution_status = zpru_if_axc_type_and_constant=>sc_query_status-complete.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    process_execution_steps( EXPORTING is_execution_query = ls_execution_query
                                       it_execution_steps = lt_execution_steps
                                       it_agent_tools     = lt_agent_tools
                             CHANGING  cs_axc_reported    = cs_axc_reported
                                       cs_axc_failed      = cs_axc_failed ).
  ENDMETHOD.

  METHOD zpru_if_api_agent~rerun_from_step.
    DATA lt_valid_steps TYPE zpru_if_axc_type_and_constant=>tt_axc_step.

    IF iv_starting_step_uuid IS INITIAL.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    prepare_execution( EXPORTING iv_run_uuid        = iv_run_uuid
                                 iv_query_uuid      = iv_query_uuid
                       IMPORTING es_execution_query = DATA(ls_execution_query)
                                 et_execution_steps = DATA(lt_execution_steps)
                                 et_agent_tools     = DATA(lt_agent_tools)
                       CHANGING  cs_axc_reported    = cs_axc_reported
                                 cs_axc_failed      = cs_axc_failed
                                 cs_adf_reported    = cs_adf_reported
                                 cs_adf_failed      = cs_adf_failed ).

    IF    lt_execution_steps IS INITIAL
       OR lt_agent_tools     IS INITIAL
       OR ls_execution_query IS INITIAL.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    IF ls_execution_query-execution_status = zpru_if_axc_type_and_constant=>sc_query_status-complete.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    ASSIGN lt_execution_steps[ step_uuid = iv_starting_step_uuid ] TO FIELD-SYMBOL(<ls_step_2_start>).
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    LOOP AT lt_execution_steps TRANSPORTING NO FIELDS
         WHERE execution_seq < <ls_step_2_start>-execution_seq.
      EXIT.
    ENDLOOP.
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    IF <ls_step_2_start>-step_status = zpru_if_axc_type_and_constant=>sc_step_status-complete.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    LOOP AT lt_execution_steps ASSIGNING FIELD-SYMBOL(<ls_step_2_exec>)
         WHERE execution_seq >= <ls_step_2_start>-execution_seq.
      APPEND INITIAL LINE TO lt_valid_steps ASSIGNING FIELD-SYMBOL(<ls_valid_step>).
      <ls_valid_step> = <ls_step_2_exec>.

      CLEAR <ls_valid_step>-input_prompt.
      CLEAR <ls_valid_step>-output_prompt.

      IF     iv_new_step_prompt        IS NOT INITIAL
         AND <ls_valid_step>-step_uuid  = iv_starting_step_uuid.
        <ls_valid_step>-input_prompt = iv_new_step_prompt.
      ENDIF.

    ENDLOOP.

    IF lt_valid_steps IS INITIAL.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    process_execution_steps( EXPORTING is_execution_query = ls_execution_query
                                       it_execution_steps = lt_execution_steps
                                       it_agent_tools     = lt_agent_tools
                             CHANGING  cs_axc_reported    = cs_axc_reported
                                       cs_axc_failed      = cs_axc_failed ).
  ENDMETHOD.

  METHOD zpru_if_api_agent~run.
    prepare_execution( EXPORTING iv_run_uuid        = iv_run_uuid
                                 iv_query_uuid      = iv_query_uuid
                       IMPORTING es_execution_query = DATA(ls_execution_query)
                                 et_execution_steps = DATA(lt_execution_steps)
                                 et_agent_tools     = DATA(lt_agent_tools)
                       CHANGING  cs_axc_reported    = cs_axc_reported
                                 cs_axc_failed      = cs_axc_failed
                                 cs_adf_reported    = cs_adf_reported
                                 cs_adf_failed      = cs_adf_failed ).

    IF    lt_execution_steps IS INITIAL
       OR lt_agent_tools     IS INITIAL
       OR ls_execution_query IS INITIAL.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    IF ls_execution_query-execution_status = zpru_if_axc_type_and_constant=>sc_query_status-complete OR
       ls_execution_query-execution_status = zpru_if_axc_type_and_constant=>sc_query_status-error.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    process_execution_steps( EXPORTING is_execution_query = ls_execution_query
                                       it_execution_steps = lt_execution_steps
                                       it_agent_tools     = lt_agent_tools
                             CHANGING  cs_axc_reported    = cs_axc_reported
                                       cs_axc_failed      = cs_axc_failed ).
  ENDMETHOD.

  METHOD zpru_if_api_agent~set_input_query.
    DATA lo_short_memory TYPE REF TO zpru_if_short_memory_provider.
    DATA lt_message      TYPE zpru_tt_key_value_tuple.
    DATA lo_adf_service  TYPE REF TO zpru_if_adf_service.

    IF    iv_input_query IS INITIAL
       OR iv_agent_uuid  IS INITIAL.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    lo_adf_service = zpru_cl_adf_factory=>zpru_if_adf_factory~get_zpru_if_adf_service( ).

    lo_adf_service->read_agent( EXPORTING it_agent_read_k = VALUE #( ( agent_uuid         = iv_agent_uuid
                                                                       control-agent_uuid = abap_true
                                                                       control-agent_name = abap_true  ) )
                                IMPORTING et_agent        = DATA(lt_agent)
                                CHANGING  cs_reported     = cs_adf_reported
                                          cs_failed       = cs_adf_failed ).

    ASSIGN lt_agent[ 1 ] TO FIELD-SYMBOL(<ls_agent>).
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    mv_input_query = iv_input_query.

    get_short_memory( EXPORTING iv_agent_uuid   = iv_agent_uuid
                      IMPORTING eo_short_memory = lo_short_memory
                      CHANGING  cs_reported     = cs_adf_reported
                                cs_failed       = cs_adf_failed ).

    lt_message = VALUE #( ( name  = 'STAGE'
                            value = 'SET_INPUT_QUERY' )
                          ( name  = 'AGENT_NAME'
                            value = <ls_agent>-agent_name )
                          ( name  = 'INPUT_QUERY'
                            value = mv_input_query )   ).

    lo_short_memory->save_message( iv_agent_uuid   = <ls_agent>-agent_uuid
                                   iv_message_type = zpru_if_short_memory_provider=>query
                                   ir_message      = REF #( lt_message ) ).
  ENDMETHOD.

  METHOD get_short_memory.
    DATA lo_adf_service TYPE REF TO zpru_if_adf_service.

    lo_adf_service = zpru_cl_adf_factory=>zpru_if_adf_factory~get_zpru_if_adf_service( ).

    CLEAR eo_short_memory.

    lo_adf_service->read_agent( EXPORTING it_agent_read_k = VALUE #( ( agent_uuid         = iv_agent_uuid
                                                                       control-agent_uuid = abap_true
                                                                       control-agent_name = abap_true  ) )
                                IMPORTING et_agent        = DATA(lt_agent)
                                CHANGING  cs_reported     = cs_reported
                                          cs_failed       = cs_failed ).

    ASSIGN lt_agent[ 1 ] TO FIELD-SYMBOL(<ls_agent>).
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    IF mo_short_memory IS BOUND.
      eo_short_memory = mo_short_memory.
      RETURN.
    ENDIF.

    IF <ls_agent>-short_memory_provider IS NOT INITIAL.
      CREATE OBJECT mo_short_memory TYPE (<ls_agent>-short_memory_provider).
      eo_short_memory = mo_short_memory.
    ENDIF.
  ENDMETHOD.

  METHOD process_execution_steps.
    DATA lo_executor         TYPE REF TO zpru_if_tool_executor.
    DATA lo_input            TYPE REF TO zpru_if_payload.
    DATA lo_output           TYPE REF TO zpru_if_payload.
    DATA lo_axc_service      TYPE REF TO zpru_if_axc_service.
    DATA lt_query_update_imp TYPE zpru_if_axc_type_and_constant=>tt_query_update_imp.
    DATA lt_step_update_imp  TYPE zpru_if_axc_type_and_constant=>tt_step_update_imp.
    DATA lv_error_flag       TYPE abap_boolean.

    lo_axc_service = zpru_cl_axc_factory=>zpru_if_axc_factory~get_zpru_if_axc_service( ).

    LOOP AT it_execution_steps ASSIGNING FIELD-SYMBOL(<ls_execution_step>).

      DATA(lv_tabix) = sy-tabix.

      ASSIGN it_agent_tools[ tool_uuid = <ls_execution_step>-tool_uuid ] TO FIELD-SYMBOL(<ls_tool_master_data>).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      CREATE OBJECT lo_executor TYPE (<ls_tool_master_data>-tool_provider).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      IF lv_tabix = 1.
        lo_input = NEW zpru_cl_payload( ).
        lo_input->set_data( ir_data = REF #( <ls_execution_step>-input_prompt ) ).
        lo_output = NEW zpru_cl_payload( ).
      ELSE.
        DATA(lr_output) = lo_output->get_data( ).
        IF lr_output IS BOUND AND lr_output->* IS NOT INITIAL.
          lo_input->set_data( ir_data = lo_output->get_data( ) ).
        ELSE.
          lo_input->clear_data( ).
        ENDIF.
        lo_output->clear_data( ).
      ENDIF.

      lv_error_flag = abap_false.

      GET TIME STAMP FIELD DATA(lv_now).

      lo_executor->execute_tool( EXPORTING io_controller = mo_controller
                                           io_request    = lo_input
                                 IMPORTING eo_response   = lo_output
                                           ev_error_flag = lv_error_flag ).

      IF lv_error_flag = abap_true.
        APPEND INITIAL LINE TO lt_step_update_imp ASSIGNING FIELD-SYMBOL(<ls_step_2_upd>).
        <ls_step_2_upd>-step_uuid     = <ls_execution_step>-step_uuid.
        <ls_step_2_upd>-query_uuid    = <ls_execution_step>-query_uuid.
        <ls_step_2_upd>-run_uuid      = <ls_execution_step>-run_uuid.
        <ls_step_2_upd>-step_status   = zpru_if_axc_type_and_constant=>sc_step_status-error.
        <ls_step_2_upd>-end_timestamp = lv_now.
        <ls_step_2_upd>-control-step_status   = abap_true.
        <ls_step_2_upd>-control-end_timestamp = abap_true.

        APPEND INITIAL LINE TO lt_query_update_imp ASSIGNING FIELD-SYMBOL(<ls_query_2_upd>).
        <ls_query_2_upd>-query_uuid       = is_execution_query-query_uuid.
        <ls_query_2_upd>-run_uuid         = is_execution_query-run_uuid.
        <ls_query_2_upd>-execution_status = zpru_if_axc_type_and_constant=>sc_query_status-error.
        <ls_query_2_upd>-end_timestamp    = lv_now.
        <ls_query_2_upd>-control-execution_status = abap_true.
        <ls_query_2_upd>-control-end_timestamp    = abap_true.
        EXIT.
      ENDIF.

      APPEND INITIAL LINE TO lt_step_update_imp ASSIGNING <ls_step_2_upd>.
      <ls_step_2_upd>-step_uuid     = <ls_execution_step>-step_uuid.
      <ls_step_2_upd>-query_uuid    = <ls_execution_step>-query_uuid.
      <ls_step_2_upd>-run_uuid      = <ls_execution_step>-run_uuid.
      <ls_step_2_upd>-step_status   = zpru_if_axc_type_and_constant=>sc_step_status-complete.
      <ls_step_2_upd>-end_timestamp = lv_now.
      <ls_step_2_upd>-control-step_status   = abap_true.
      <ls_step_2_upd>-control-end_timestamp = abap_true.

      IF mo_controller->mv_stop_agent = abap_true.
        EXIT.
      ENDIF.

    ENDLOOP.

    IF lt_step_update_imp IS NOT INITIAL.
      lo_axc_service->update_step( EXPORTING it_step_update_imp = lt_step_update_imp
                                   CHANGING  cs_reported        = cs_axc_reported
                                             cs_failed          = cs_axc_failed ).
    ENDIF.

    IF lt_query_update_imp IS NOT INITIAL.
      lo_axc_service->update_query( EXPORTING it_query_update_imp = lt_query_update_imp
                                    CHANGING  cs_reported         = cs_axc_reported
                                              cs_failed           = cs_axc_failed ).
    ELSE.
      lo_axc_service->rba_step( EXPORTING it_rba_step_k = VALUE #( ( query_uuid          = is_execution_query-query_uuid
                                                                     control-run_uuid    = abap_true
                                                                     control-query_uuid  = abap_true
                                                                     control-step_status = abap_true  ) )
                                IMPORTING et_axc_step   = DATA(lt_step_final_state)
                                CHANGING  cs_reported   = cs_axc_reported
                                          cs_failed     = cs_axc_failed ).

      LOOP AT lt_step_final_state TRANSPORTING NO FIELDS WHERE step_status <> zpru_if_axc_type_and_constant=>sc_step_status-complete.
        EXIT.
      ENDLOOP.
      IF sy-subrc <> 0.

        GET TIME STAMP FIELD lv_now.

        APPEND INITIAL LINE TO lt_query_update_imp ASSIGNING <ls_query_2_upd>.
        <ls_query_2_upd>-query_uuid       = is_execution_query-query_uuid.
        <ls_query_2_upd>-run_uuid         = is_execution_query-run_uuid.
        <ls_query_2_upd>-execution_status = zpru_if_axc_type_and_constant=>sc_query_status-complete.
        <ls_query_2_upd>-end_timestamp    = lv_now.
        <ls_query_2_upd>-control-execution_status = abap_true.
        <ls_query_2_upd>-control-end_timestamp    = abap_true.

        lo_axc_service->update_step( EXPORTING it_step_update_imp = lt_step_update_imp
                                     CHANGING  cs_reported        = cs_axc_reported
                                               cs_failed          = cs_axc_failed ).
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD prepare_execution.
    DATA lv_query_to_run     TYPE sysuuid_x16.
    DATA lo_axc_service      TYPE REF TO zpru_if_axc_service.
    DATA ls_execution_header TYPE zpru_axc_head.
    DATA ls_execution_query  TYPE zpru_axc_query.
    DATA lo_adf_service      TYPE REF TO zpru_if_adf_service.

    CLEAR: et_agent_tools,
           et_execution_steps,
           es_execution_query.

    IF iv_run_uuid IS INITIAL.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    lo_axc_service->read_header( EXPORTING it_head_read_k = VALUE #( ( run_uuid = iv_run_uuid
                                                                       control  = VALUE #(
                                                                           run_uuid           = abap_true
                                                                           agent_uuid         = abap_true
                                                                           user_id            = abap_true
                                                                           start_timestamp    = abap_true
                                                                           end_timestamp      = abap_true
                                                                           created_by         = abap_true
                                                                           created_at         = abap_true
                                                                           changed_by         = abap_true
                                                                           last_changed       = abap_true
                                                                           local_last_changed = abap_true ) ) )
                                 IMPORTING et_axc_head    = DATA(lt_axc_head)
                                 CHANGING  cs_reported    = cs_axc_reported
                                           cs_failed      = cs_axc_failed ).

    ASSIGN lt_axc_head[ 1 ] TO FIELD-SYMBOL(<ls_execution_header>).
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    ls_execution_header = <ls_execution_header>.

    IF iv_query_uuid IS INITIAL.

      lo_axc_service->get_actual_query( EXPORTING it_axc_head_k          = CORRESPONDING #( lt_axc_head )
                                        IMPORTING et_axc_head_query_link = DATA(lt_query_to_read)
                                        CHANGING  cs_reported            = cs_axc_reported
                                                  cs_failed              = cs_axc_failed ).

      lv_query_to_run = VALUE #( lt_query_to_read[ 1 ]-query_uuid OPTIONAL ).
    ELSE.
      lv_query_to_run = iv_query_uuid.
    ENDIF.

    lo_axc_service->read_query( EXPORTING it_query_read_k = VALUE #( ( query_uuid = lv_query_to_run
                                                                       control    = VALUE #(
                                                                           run_uuid         = abap_true
                                                                           query_uuid       = abap_true
                                                                           language         = abap_true
                                                                           execution_status = abap_true
                                                                           start_timestamp  = abap_true
                                                                           end_timestamp    = abap_true
                                                                           input_prompt     = abap_true
                                                                           decision_log     = abap_true
                                                                           output_response  = abap_true ) ) )
                                IMPORTING et_axc_query    = DATA(lt_axc_query)
                                CHANGING  cs_reported     = cs_axc_reported
                                          cs_failed       = cs_axc_failed ).

    ASSIGN lt_axc_query[ 1 ] TO FIELD-SYMBOL(<ls_execution_query>).
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    ls_execution_query = <ls_execution_query>.

    lo_axc_service->rba_step( EXPORTING it_rba_step_k = VALUE #( ( query_uuid = ls_execution_query-query_uuid
                                                                   control    = VALUE #(
                                                                       step_uuid       = abap_true
                                                                       query_uuid      = abap_true
                                                                       run_uuid        = abap_true
                                                                       tool_uuid       = abap_true
                                                                       execution_seq   = abap_true
                                                                       start_timestamp = abap_true
                                                                       end_timestamp   = abap_true
                                                                       input_prompt    = abap_true
                                                                       output_prompt   = abap_true ) ) )
                              IMPORTING et_axc_step   = DATA(lt_execution_steps)
                              CHANGING  cs_reported   = cs_axc_reported
                                        cs_failed     = cs_axc_failed ).

    IF    ls_execution_header IS INITIAL
       OR ls_execution_query  IS INITIAL
       OR lt_execution_steps  IS INITIAL.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    lo_adf_service = zpru_cl_adf_factory=>zpru_if_adf_factory~get_zpru_if_adf_service( ).

    lo_adf_service->read_agent(
      EXPORTING it_agent_read_k = VALUE #( ( agent_uuid                     = ls_execution_header-agent_uuid
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
      CHANGING  cs_reported     = cs_adf_reported
                cs_failed       = cs_adf_failed ).

    DATA(ls_agent) = VALUE #( lt_agent[ 1 ] OPTIONAL ).
    IF ls_agent IS INITIAL.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    lo_adf_service->rba_tool( EXPORTING it_rba_tool_k = VALUE #( ( agent_uuid                    = ls_agent-agent_uuid
                                                                   control-tool_uuid             = abap_true
                                                                   control-agent_uuid            = abap_true
                                                                   control-tool_name             = abap_true
                                                                   control-tool_provider         = abap_true
                                                                   control-step_type             = abap_true
                                                                   control-input_schema_provider = abap_true
                                                                   control-tool_info_provider    = abap_true    ) )
                              IMPORTING et_tool       = DATA(lt_agent_tools)
                              CHANGING  cs_reported   = cs_adf_reported
                                        cs_failed     = cs_adf_failed ).

    et_agent_tools = lt_agent_tools.
    et_execution_steps = lt_execution_steps.
  ENDMETHOD.
ENDCLASS.
