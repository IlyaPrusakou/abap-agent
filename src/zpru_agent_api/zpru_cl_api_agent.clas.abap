CLASS zpru_cl_api_agent DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zpru_if_agent_frw.
    INTERFACES zpru_if_api_agent.

  PROTECTED SECTION.
    DATA mo_controller   TYPE REF TO zpru_if_agent_controller.
    DATA mo_short_memory TYPE REF TO zpru_if_short_memory_provider.
    DATA mo_long_memory  TYPE REF TO zpru_if_long_memory_provider.
    DATA mv_input_query  TYPE zpru_if_agent_frw=>ts_json.

    METHODS get_short_memory
      IMPORTING iv_agent_uuid   TYPE sysuuid_x16
      EXPORTING eo_short_memory TYPE REF TO zpru_if_short_memory_provider
      CHANGING  cs_reported     TYPE zpru_if_agent_frw=>ts_adf_reported
                cs_failed       TYPE zpru_if_agent_frw=>ts_adf_failed
      RAISING   zpru_cx_agent_core.

    METHODS get_long_memory
      IMPORTING iv_agent_uuid  TYPE sysuuid_x16
      EXPORTING eo_long_memory TYPE REF TO zpru_if_long_memory_provider
      CHANGING  cs_reported    TYPE zpru_if_agent_frw=>ts_adf_reported
                cs_failed      TYPE zpru_if_agent_frw=>ts_adf_failed
      RAISING   zpru_cx_agent_core.

    METHODS process_execution_steps
      IMPORTING is_agent            TYPE zpru_if_adf_type_and_constant=>ts_agent
                is_execution_header TYPE zpru_axc_head
                is_execution_query  TYPE zpru_if_axc_type_and_constant=>ts_axc_query
                it_execution_steps  TYPE zpru_if_axc_type_and_constant=>tt_axc_step
                it_agent_tools      TYPE zpru_if_adf_type_and_constant=>tt_agent_tool
      EXPORTING eo_final_response   TYPE REF TO zpru_if_payload
      CHANGING  cs_axc_reported     TYPE zpru_if_agent_frw=>ts_axc_reported
                cs_axc_failed       TYPE zpru_if_agent_frw=>ts_axc_failed
                cs_adf_reported     TYPE zpru_if_agent_frw=>ts_adf_reported
                cs_adf_failed       TYPE zpru_if_agent_frw=>ts_adf_failed
      RAISING   zpru_cx_agent_core.

    METHODS prepare_execution
      IMPORTING iv_run_uuid         TYPE sysuuid_x16
                iv_query_uuid       TYPE sysuuid_x16 OPTIONAL
      EXPORTING es_agent            TYPE zpru_if_adf_type_and_constant=>ts_agent
                es_execution_header TYPE zpru_axc_head
                es_execution_query  TYPE zpru_if_axc_type_and_constant=>ts_axc_query
                et_execution_steps  TYPE zpru_if_axc_type_and_constant=>tt_axc_step
                et_agent_tools      TYPE zpru_if_adf_type_and_constant=>tt_agent_tool
      CHANGING  cs_axc_reported     TYPE zpru_if_agent_frw=>ts_axc_reported
                cs_axc_failed       TYPE zpru_if_agent_frw=>ts_axc_failed
                cs_adf_reported     TYPE zpru_if_agent_frw=>ts_adf_reported
                cs_adf_failed       TYPE zpru_if_agent_frw=>ts_adf_failed
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
    DATA lt_message_in             TYPE zpru_if_short_memory_provider=>tt_message.
    DATA lv_langu                  TYPE sylangu.
    DATA lv_decision_log           TYPE zpru_if_agent_frw=>ts_json.
    DATA lv_first_tool_input       TYPE zpru_if_agent_frw=>ts_json.
    DATA lo_axc_service            TYPE REF TO zpru_if_axc_service.
    DATA ls_execution_header       TYPE zpru_axc_head.
    DATA ls_execution_query        TYPE zpru_axc_query.
    DATA lt_execution_steps        TYPE STANDARD TABLE OF zpru_axc_step WITH EMPTY KEY.
    DATA lo_adf_service            TYPE REF TO zpru_if_adf_service.
    DATA lv_step_number_base       TYPE zpru_de_step_number.
    DATA lo_utility                TYPE REF TO zpru_if_agent_util.

    CLEAR ev_built_run_uuid.
    CLEAR ev_built_query_uuid.

    IF    iv_agent_uuid  IS INITIAL
       OR mv_input_query IS INITIAL.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    lo_utility = NEW zpru_cl_agent_util( ).

    lo_adf_service = zpru_cl_adf_factory=>zpru_if_adf_factory~get_zpru_if_adf_service( ).

    lo_adf_service->read_agent( EXPORTING it_agent_read_k = VALUE #( ( agent_uuid                     = iv_agent_uuid
                                                                       control-agent_uuid             = abap_true
                                                                       control-agent_name             = abap_true
                                                                       control-agent_type             = abap_true
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

    IF ls_agent-status <> zpru_if_adf_type_and_constant=>cs_agent_status-active.
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

    get_long_memory( EXPORTING iv_agent_uuid  = ls_agent-agent_uuid
                     IMPORTING eo_long_memory = lo_long_memory
                     CHANGING  cs_reported    = cs_adf_reported
                               cs_failed      = cs_adf_failed ).

    IF ls_agent-agent_info_provider IS NOT INITIAL.
      CREATE OBJECT lo_agent_info_provider TYPE (ls_agent-agent_info_provider).
    ENDIF.

    IF ls_agent-system_prompt_provider IS NOT INITIAL.
      CREATE OBJECT lo_system_prompt_provider TYPE (ls_agent-system_prompt_provider).
    ENDIF.

    lo_query = NEW zpru_cl_payload( ).
    lo_query->set_data( ir_data = NEW zpru_if_agent_frw=>ts_json( lo_utility->search_node_in_json(
                                                                      iv_json           = mv_input_query
                                                                      iv_field_2_search = 'CONTENT' ) ) ).

    mo_controller->mv_agent_uuid = ls_agent-agent_uuid.

    GET TIME STAMP FIELD DATA(lv_now).

    DATA(lv_system_prompt) = |\{ "USER": "{ sy-uname }", "TOPIC" : "SYSTEM_PROMPT", "TIMESTAMP" : "{ lv_now }",| &&
                             | "CONTENT" : "{ lo_system_prompt_provider->get_system_prompt( ) }" \}|.

    DATA(lv_agent_info) = |\{ "USER": "{ sy-uname }", "TOPIC" : "AGENT_INFO", "TIMESTAMP" : "{ lv_now }",| &&
                             | "CONTENT" : "{ lo_agent_info_provider->get_agent_info( ) }" \}|.

    lt_message_in = VALUE #( ( message_cid  = |{ lv_now }-{ sy-uname }-BUILD_EXECUTION_{ 1 }|
                               stage        = 'BUILD_EXECUTION'
                               sub_stage    = 'BEFORE_DECISION'
                               namespace    = |{ sy-uname }.{ ls_agent-agent_name }|
                               user_name    = sy-uname
                               agent_uuid   = ls_agent-agent_uuid
                               message_time = lv_now
                               content      = |\{ "AGENT_NAME" : "{ ls_agent-agent_name }", | &&
                                              | "DECISION_PROVIDER" : "{ ls_agent-decision_provider }", | &&
                                              | "QUERY" : { mv_input_query }, | &&
                                              | "SYSTEM PROMPT" : { lv_system_prompt }, | &&
                                              | "AGENT INFO" : "{ lv_agent_info }" \}|
                               message_type = zpru_if_short_memory_provider=>cs_msg_type-info ) ).

    lo_short_memory->save_message( lt_message_in ).

    lo_first_tool_input = NEW zpru_cl_payload( ).
    lo_execution_plan   = NEW zpru_cl_payload( ).
    lo_langu            = NEW zpru_cl_payload( ).
    lo_decision_log     = NEW zpru_cl_payload( ).

    lo_decision_provider->call_decision_engine( EXPORTING is_agent               = ls_agent
                                                          it_tool                = lt_agent_tools
                                                          io_controller          = mo_controller
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
    ENDIF.

    IF lo_decision_log IS BOUND.
      lv_decision_log = lo_decision_log->get_data( )->*.
    ENDIF.

    IF lo_first_tool_input IS BOUND.
      lv_first_tool_input = lo_first_tool_input->get_data( )->*.
    ENDIF.

    IF lo_langu IS BOUND.
      lv_langu = lo_langu->get_data( )->*.
    ENDIF.

    GET TIME STAMP FIELD lv_now.

    DATA(lv_decision_log_message) = |\{ "USER": "{ sy-uname }", "TOPIC" : "DECISION_LOG", "TIMESTAMP" : "{ lv_now }",| &&
                                    | "CONTENT" : "{ lv_decision_log }" \}|.

    DATA(lv_first_tool_input_message) = |\{ "USER": "{ sy-uname }", "TOPIC" : "FIRST_TOOL_INPUT", "TIMESTAMP" : "{ lv_now }",| &&
                                   | "CONTENT" : "{ lv_first_tool_input }" \}|.

    lt_message_in = VALUE #( ( message_cid  = |{ lv_now }-{ sy-uname }-BUILD_EXECUTION_{ 2 }|
                               stage        = 'BUILD_EXECUTION'
                               sub_stage    = 'AFTER_DECISION'
                               namespace    = |{ sy-uname }.{ ls_agent-agent_name }|
                               user_name    = sy-uname
                               agent_uuid   = ls_agent-agent_uuid
                               message_time = lv_now
                               content      = |\{ "AGENT_NAME" : "{ ls_agent-agent_name }", | &&
                                              | "DECISION_PROVIDER" : "{ ls_agent-decision_provider }", | &&
                                              | "QUERY" : { mv_input_query }, | &&
                                              | "FIRST TOOL INPUT" : { lv_first_tool_input_message }, | &&
                                              | "LANGUAGE" : "{ lv_langu }", | &&
                                              | "DECISION LOG" : { lv_decision_log_message } \}|
                               message_type = zpru_if_short_memory_provider=>cs_msg_type-info ) ).

    DATA(lv_count) = 3.
    LOOP AT lt_execution_plan ASSIGNING FIELD-SYMBOL(<ls_execution_plan>).
      APPEND INITIAL LINE TO lt_message_in ASSIGNING FIELD-SYMBOL(<ls_message>).
      <ls_message> = VALUE #( message_cid  = |{ lv_now }-{ sy-uname }-BUILD_EXECUTION_{ lv_count }|
                              stage        = 'BUILD_EXECUTION'
                              sub_stage    = 'TOOL_ANALYSIS'
                              namespace    = |{ sy-uname }.{ ls_agent-agent_name }|
                              user_name    = sy-uname
                              agent_uuid   = ls_agent-agent_uuid
                              message_time = lv_now
                              content      = |\{ "AGENT_NAME" : "{ ls_agent-agent_name }", | &&
                                             | "EXECUTION_SEQUENCE" : "{ <ls_execution_plan>-sequence }", | &&
                                             | "TOOL_NAME" : "{ <ls_execution_plan>-tool_name }" \}|
                              message_type = zpru_if_short_memory_provider=>cs_msg_type-info  ).

      lv_count += 1.
    ENDLOOP.

    lo_short_memory->save_message( lt_message_in ).

    lo_axc_service = zpru_cl_axc_factory=>zpru_if_axc_factory~get_zpru_if_axc_service( ).

    TRY.
        " header
        ls_execution_header-run_uuid           = cl_system_uuid=>create_uuid_x16_static( ).
        ls_execution_header-run_id             = lo_axc_service->generate_run_id( ).
        ls_execution_header-agent_uuid         = ls_agent-agent_uuid.
        ls_execution_header-user_id            = sy-uname.
        ls_execution_header-start_timestamp    = lv_now.
        ls_execution_header-created_by         = sy-uname.
        ls_execution_header-created_at         = lv_now.
        ls_execution_header-changed_by         = sy-uname.
        ls_execution_header-last_changed       = lv_now.
        ls_execution_header-local_last_changed = lv_now.

        lo_axc_service->create_header(
          EXPORTING it_head_create_imp = VALUE #( ( run_uuid           = ls_execution_header-run_uuid
                                                    run_id             = ls_execution_header-run_id
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
                                                                                  run_id             = abap_true
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
        ls_execution_query-query_number     = lo_axc_service->generate_query_number(
                                                  iv_run_uuid = ls_execution_header-run_uuid ).
        ls_execution_query-run_uuid         = ls_execution_header-run_uuid.
        ls_execution_query-language         = COND #( WHEN lv_langu IS NOT INITIAL
                                                      THEN lv_langu
                                                      ELSE sy-langu ).
        ls_execution_query-execution_status = zpru_if_axc_type_and_constant=>sc_query_status-new.
        ls_execution_query-start_timestamp  = lv_now.
        ls_execution_query-input_prompt     = lo_utility->search_node_in_json( iv_json           = mv_input_query
                                                                               iv_field_2_search = 'CONTENT' ).
        ls_execution_query-decision_log     = lo_utility->search_node_in_json(
                                                  iv_json           = lv_decision_log_message
                                                  iv_field_2_search = 'CONTENT' ).

        lo_axc_service->cba_query(
          EXPORTING it_axc_query_imp = VALUE #( ( query_uuid       = ls_execution_query-query_uuid
                                                  query_number     = ls_execution_query-query_number
                                                  run_uuid         = ls_execution_query-run_uuid
                                                  language         = ls_execution_query-language
                                                  execution_status = ls_execution_query-execution_status
                                                  start_timestamp  = ls_execution_query-start_timestamp
                                                  end_timestamp    = ls_execution_query-end_timestamp
                                                  input_prompt     = ls_execution_query-input_prompt
                                                  decision_log     = ls_execution_query-decision_log
                                                  output_response  = ls_execution_query-output_response
                                                  control          = VALUE #( query_uuid       = abap_true
                                                                              query_number     = abap_true
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

        GET TIME STAMP FIELD lv_now.

        lt_message_in = VALUE #( ( message_cid  = |{ lv_now }-{ sy-uname }-BUILD_EXECUTION_{ lv_count }|
                                   stage        = 'BUILD_EXECUTION'
                                   sub_stage    = 'AFTER_QUERY_CREATION'
                                   namespace    = |{ sy-uname }.{ ls_agent-agent_name }.{ ls_execution_header-run_id }|
                                   user_name    = sy-uname
                                   agent_uuid   = ls_agent-agent_uuid
                                   run_uuid     = ls_execution_header-run_uuid
                                   query_uuid   = ls_execution_query-query_uuid
                                   message_time = lv_now
                                   content      = |\{ "AGENT_NAME" : "{ ls_agent-agent_name }", | &&
                                                  | "RUN_ID" : "{ ls_execution_header-run_id }", | &&
                                                  | "QUERY_NUMBER" : "{ ls_execution_query-query_number }", | &&
                                                  | "LANGUAGE" : "{ ls_execution_query-language }", | &&
                                                  | "QUERY" : { mv_input_query }, | &&
                                                  | "DECISION LOG" : { lv_decision_log_message } \}|
                                   message_type = zpru_if_short_memory_provider=>cs_msg_type-query ) ).

        SORT lt_execution_plan BY sequence ASCENDING.
        DATA(lv_min_seq) = VALUE #( lt_execution_plan[ 1 ]-sequence OPTIONAL ).

        lv_count += 1.
        LOOP AT lt_execution_plan ASSIGNING FIELD-SYMBOL(<ls_tool>).

          ASSIGN lt_agent_tools[ agent_uuid = <ls_tool>-agent_uuid
                                 tool_name  = <ls_tool>-tool_name ] TO FIELD-SYMBOL(<ls_tool_master_data>).
          IF sy-subrc <> 0.
            RETURN.
          ENDIF.

          APPEND INITIAL LINE TO lt_execution_steps ASSIGNING FIELD-SYMBOL(<ls_execution_step>).
          <ls_execution_step>-step_uuid       = cl_system_uuid=>create_uuid_x16_static( ).
          <ls_execution_step>-step_number     = lo_axc_service->generate_step_number(
                                                    iv_query_uuid       = ls_execution_query-query_uuid
                                                    iv_step_number_base = lv_step_number_base ).
          <ls_execution_step>-query_uuid      = ls_execution_query-query_uuid.
          <ls_execution_step>-run_uuid        = ls_execution_header-run_uuid.
          <ls_execution_step>-tool_uuid       = <ls_tool_master_data>-tool_uuid.
          <ls_execution_step>-execution_seq   = <ls_tool>-sequence.
          <ls_execution_step>-step_status     = zpru_if_axc_type_and_constant=>sc_step_status-new.
          <ls_execution_step>-start_timestamp = lv_now.
          IF <ls_tool>-sequence = lv_min_seq.
            <ls_execution_step>-input_prompt = lv_first_tool_input.
          ENDIF.

          IF <ls_execution_step>-input_prompt IS NOT INITIAL.
            DATA(lv_tool_prompt_message) = |\{ "USER": "{ sy-uname }", "TOPIC" : "TOOL_INPUT_PROMPT", "TIMESTAMP" : "{ lv_now }",| &&
                                           | "CONTENT" : "{ <ls_execution_step>-input_prompt }" \}|.
          ELSE.
            CLEAR lv_tool_prompt_message.
          ENDIF.

          APPEND INITIAL LINE TO lt_message_in ASSIGNING <ls_message>.
          <ls_message> = VALUE #(
              message_cid  = |{ lv_now }-{ sy-uname }-BUILD_EXECUTION_{ lv_count }|
              stage        = 'BUILD_EXECUTION'
              sub_stage    = 'STEP_ANALYSIS'
              namespace    = |{ sy-uname }.{ ls_agent-agent_name }.{ ls_execution_header-run_id }.{ ls_execution_query-query_number }|
              user_name    = sy-uname
              agent_uuid   = ls_agent-agent_uuid
              run_uuid     = ls_execution_header-run_uuid
              query_uuid   = ls_execution_query-query_uuid
              step_uuid    = <ls_execution_step>-step_uuid
              message_time = lv_now
              content      = |\{ "STEP_NUMBER" : "{ <ls_execution_step>-step_number }", | &&
                             | "QUERY_NUMBER" : "{ ls_execution_query-query_number }", | &&
                             | "RUN_ID" : "{ ls_execution_header-run_id }", | &&
                             | "EXECUTION_SEQUENCE" : "{ <ls_execution_step>-execution_seq }", | &&
                             | "INPUT_PROMPT" : { lv_tool_prompt_message } \}|
              message_type = zpru_if_short_memory_provider=>cs_msg_type-step_input  ).

          lv_count += 1.
          lv_step_number_base = <ls_execution_step>-step_number.
        ENDLOOP.

        lo_short_memory->save_message( lt_message_in ).

        lo_axc_service->cba_step( EXPORTING it_axc_step_imp = VALUE #( FOR <ls_s> IN lt_execution_steps
                                                                       ( step_uuid       = <ls_s>-step_uuid
                                                                         step_number     = <ls_s>-step_number
                                                                         query_uuid      = <ls_s>-query_uuid
                                                                         run_uuid        = <ls_s>-run_uuid
                                                                         tool_uuid       = <ls_s>-tool_uuid
                                                                         execution_seq   = <ls_s>-execution_seq
                                                                         step_status     = <ls_s>-step_status
                                                                         start_timestamp = <ls_s>-start_timestamp
                                                                         end_timestamp   = <ls_s>-end_timestamp
                                                                         input_prompt    = <ls_s>-input_prompt
                                                                         output_prompt   = <ls_s>-output_prompt
                                                                         control         = VALUE #(
                                                                             step_uuid       = abap_true
                                                                             step_number     = abap_true
                                                                             query_uuid      = abap_true
                                                                             run_uuid        = abap_true
                                                                             tool_uuid       = abap_true
                                                                             execution_seq   = abap_true
                                                                             step_status     = abap_true
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
    ev_built_query_uuid = ls_execution_query-query_uuid.
  ENDMETHOD.

  METHOD zpru_if_api_agent~initialize.
    DATA lo_adf_service  TYPE REF TO zpru_if_adf_service.
    DATA lo_short_memory TYPE REF TO zpru_if_short_memory_provider.
    DATA lt_message      TYPE zpru_if_short_memory_provider=>tt_message.

    CLEAR: es_agent,
           et_tools.

    IF iv_agent_name IS INITIAL.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    mo_controller = NEW zpru_cl_agent_controller( ).

    IF io_parent_controller IS BOUND.
      mo_controller->mo_parent_controller = io_parent_controller.
    ENDIF.

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
                                             control-agent_type             = abap_true
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

    es_agent = VALUE #( lt_agent[ 1 ] OPTIONAL ).

    IF es_agent IS INITIAL OR es_agent-status = zpru_if_adf_type_and_constant=>cs_agent_status-inactive.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    IF es_agent-status = zpru_if_adf_type_and_constant=>cs_agent_status-new.
      lo_adf_service->update_agent(
        EXPORTING it_agent_update_imp = VALUE #( ( agent_uuid = es_agent-agent_uuid
                                                   status     = zpru_if_adf_type_and_constant=>cs_agent_status-active
                                                   control    = VALUE #( status = abap_true ) ) )
        CHANGING  cs_reported         = cs_adf_reported
                  cs_failed           = cs_adf_failed ).

      IF line_exists( cs_adf_failed-agent[ agent_uuid = es_agent-agent_uuid ] ).
        RAISE EXCEPTION NEW zpru_cx_agent_core( ).
      ENDIF.
    ENDIF.

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

    get_short_memory( EXPORTING iv_agent_uuid   = es_agent-agent_uuid
                      IMPORTING eo_short_memory = lo_short_memory
                      CHANGING  cs_reported     = cs_adf_reported
                                cs_failed       = cs_adf_failed ).

    GET TIME STAMP FIELD DATA(lv_now).

    DATA(lv_count) = 1.

    lt_message = VALUE #( ( message_cid  = |{ lv_now }-{ sy-uname }-INITIALIZE_{ lv_count }|
                            stage        = 'INITIALIZE'
                            sub_stage    = 'INITIALIZE_AGENT'
                            namespace    = |{ sy-uname }.{ es_agent-agent_name }|
                            user_name    = sy-uname
                            agent_uuid   = es_agent-agent_uuid
                            message_time = lv_now
                            content      = |\{ "AGENT_NAME" : "{ es_agent-agent_name }", | &&
                                           |"DECISION_PROVIDER" : "{ es_agent-decision_provider }",| &&
                                           |"SYSTEM_PROMPT_PROVIDER" : "{ es_agent-system_prompt_provider }" \}|
                            message_type = zpru_if_short_memory_provider=>cs_msg_type-info ) ).

    lv_count += 1.
    LOOP AT et_tools ASSIGNING FIELD-SYMBOL(<ls_tool>).
      APPEND INITIAL LINE TO lt_message ASSIGNING FIELD-SYMBOL(<ls_message>).
      <ls_message> = VALUE #( message_cid  = |{ lv_now }-{ sy-uname }-INITIALIZE_{ lv_count }|
                              stage        = 'INITIALIZE'
                              sub_stage    = 'INITIALIZE_TOOL'
                              namespace    = |{ sy-uname }.{ es_agent-agent_name }|
                              user_name    = sy-uname
                              agent_uuid   = es_agent-agent_uuid
                              message_time = lv_now
                              content      = |\{ "TOOL_NAME" : "{ <ls_tool>-tool_name }", | &&
                                             |"TOOL_PROVIDER" : "{ <ls_tool>-tool_provider }" \}|
                              message_type = zpru_if_short_memory_provider=>cs_msg_type-info ).

      lv_count += 1.

    ENDLOOP.

    lo_short_memory->save_message( lt_message ).
  ENDMETHOD.

  METHOD zpru_if_api_agent~rerun.
    prepare_execution( EXPORTING iv_run_uuid         = iv_run_uuid
                                 iv_query_uuid       = iv_query_uuid
                       IMPORTING es_agent            = DATA(ls_agent)
                                 es_execution_header = DATA(ls_execution_header)
                                 es_execution_query  = DATA(ls_execution_query)
                                 et_execution_steps  = DATA(lt_execution_steps)
                                 et_agent_tools      = DATA(lt_agent_tools)
                       CHANGING  cs_axc_reported     = cs_axc_reported
                                 cs_axc_failed       = cs_axc_failed
                                 cs_adf_reported     = cs_adf_reported
                                 cs_adf_failed       = cs_adf_failed ).

    IF    lt_execution_steps IS INITIAL
       OR lt_agent_tools     IS INITIAL
       OR ls_execution_query IS INITIAL.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    IF    ls_execution_query-execution_status = zpru_if_axc_type_and_constant=>sc_query_status-new
       OR ls_execution_query-execution_status = zpru_if_axc_type_and_constant=>sc_query_status-complete.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    process_execution_steps( EXPORTING is_agent            = ls_agent
                                       is_execution_header = ls_execution_header
                                       is_execution_query  = ls_execution_query
                                       it_execution_steps  = lt_execution_steps
                                       it_agent_tools      = lt_agent_tools
                             IMPORTING eo_final_response   = eo_final_response
                             CHANGING  cs_axc_reported     = cs_axc_reported
                                       cs_axc_failed       = cs_axc_failed
                                       cs_adf_reported     = cs_adf_reported
                                       cs_adf_failed       = cs_adf_failed ).
  ENDMETHOD.

  METHOD zpru_if_api_agent~rerun_from_step.
    DATA lt_valid_steps TYPE zpru_if_axc_type_and_constant=>tt_axc_step.

    IF iv_starting_step_uuid IS INITIAL.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    prepare_execution( EXPORTING iv_run_uuid         = iv_run_uuid
                                 iv_query_uuid       = iv_query_uuid
                       IMPORTING es_agent            = DATA(ls_agent)
                                 es_execution_header = DATA(ls_execution_header)
                                 es_execution_query  = DATA(ls_execution_query)
                                 et_execution_steps  = DATA(lt_execution_steps)
                                 et_agent_tools      = DATA(lt_agent_tools)
                       CHANGING  cs_axc_reported     = cs_axc_reported
                                 cs_axc_failed       = cs_axc_failed
                                 cs_adf_reported     = cs_adf_reported
                                 cs_adf_failed       = cs_adf_failed ).

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

    process_execution_steps( EXPORTING is_agent            = ls_agent
                                       is_execution_header = ls_execution_header
                                       is_execution_query  = ls_execution_query
                                       it_execution_steps  = lt_execution_steps
                                       it_agent_tools      = lt_agent_tools
                             IMPORTING eo_final_response   = eo_final_response
                             CHANGING  cs_axc_reported     = cs_axc_reported
                                       cs_axc_failed       = cs_axc_failed
                                       cs_adf_reported     = cs_adf_reported
                                       cs_adf_failed       = cs_adf_failed ).
  ENDMETHOD.

  METHOD zpru_if_api_agent~run.
    prepare_execution( EXPORTING iv_run_uuid         = iv_run_uuid
                                 iv_query_uuid       = iv_query_uuid
                       IMPORTING es_agent            = DATA(ls_agent)
                                 es_execution_header = DATA(ls_execution_header)
                                 es_execution_query  = DATA(ls_execution_query)
                                 et_execution_steps  = DATA(lt_execution_steps)
                                 et_agent_tools      = DATA(lt_agent_tools)
                       CHANGING  cs_axc_reported     = cs_axc_reported
                                 cs_axc_failed       = cs_axc_failed
                                 cs_adf_reported     = cs_adf_reported
                                 cs_adf_failed       = cs_adf_failed ).

    IF    lt_execution_steps IS INITIAL
       OR lt_agent_tools     IS INITIAL
       OR ls_execution_query IS INITIAL.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    IF    ls_execution_query-execution_status = zpru_if_axc_type_and_constant=>sc_query_status-complete
       OR ls_execution_query-execution_status = zpru_if_axc_type_and_constant=>sc_query_status-error.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    process_execution_steps( EXPORTING is_agent            = ls_agent
                                       is_execution_header = ls_execution_header
                                       is_execution_query  = ls_execution_query
                                       it_execution_steps  = lt_execution_steps
                                       it_agent_tools      = lt_agent_tools
                             IMPORTING eo_final_response   = eo_final_response
                             CHANGING  cs_axc_reported     = cs_axc_reported
                                       cs_axc_failed       = cs_axc_failed
                                       cs_adf_reported     = cs_adf_reported
                                       cs_adf_failed       = cs_adf_failed ).
  ENDMETHOD.

  METHOD zpru_if_api_agent~set_input_query.
    DATA lo_short_memory TYPE REF TO zpru_if_short_memory_provider.
    DATA lt_message      TYPE zpru_if_short_memory_provider=>tt_message.
    DATA lo_adf_service  TYPE REF TO zpru_if_adf_service.

    IF    iv_input_query IS INITIAL
       OR iv_agent_uuid  IS INITIAL.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    lo_adf_service = zpru_cl_adf_factory=>zpru_if_adf_factory~get_zpru_if_adf_service( ).

    lo_adf_service->read_agent( EXPORTING it_agent_read_k = VALUE #( ( agent_uuid                     = iv_agent_uuid
                                                                       control-agent_uuid             = abap_true
                                                                       control-agent_name             = abap_true
                                                                       control-agent_type             = abap_true
                                                                       control-decision_provider      = abap_true
                                                                       control-system_prompt_provider = abap_true
                                                                       control-status                 = abap_true  ) )
                                IMPORTING et_agent        = DATA(lt_agent)
                                CHANGING  cs_reported     = cs_adf_reported
                                          cs_failed       = cs_adf_failed ).

    ASSIGN lt_agent[ 1 ] TO FIELD-SYMBOL(<ls_agent>).
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    IF <ls_agent>-status <> zpru_if_adf_type_and_constant=>cs_agent_status-active.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    GET TIME STAMP FIELD DATA(lv_now).
    mv_input_query = |\{ "USER": "{ sy-uname }", "TOPIC" : "QUERY", "TIMESTAMP" : "{ lv_now }", "CONTENT" : "{ iv_input_query }"  \}|.

    get_short_memory( EXPORTING iv_agent_uuid   = iv_agent_uuid
                      IMPORTING eo_short_memory = lo_short_memory
                      CHANGING  cs_reported     = cs_adf_reported
                                cs_failed       = cs_adf_failed ).

    GET TIME STAMP FIELD lv_now.

    lt_message = VALUE #( ( message_cid  = |{ lv_now }-{ sy-uname }-SET_INPUT_QUERY_{ 1 }|
                            stage        = 'SET_INPUT_QUERY'
                            sub_stage    = 'SET_INPUT_QUERY'
                            namespace    = |{ sy-uname }.{ <ls_agent>-agent_name }|
                            user_name    = sy-uname
                            agent_uuid   = <ls_agent>-agent_uuid
                            message_time = lv_now
                            content      = |\{ "AGENT_NAME" : "{ <ls_agent>-agent_name }", | &&
                                           |"DECISION_PROVIDER" : "{ <ls_agent>-decision_provider }",| &&
                                           |"SYSTEM_PROMPT_PROVIDER" : "{ <ls_agent>-system_prompt_provider }", | &&
                                           |"INPUT_QUERY" : { mv_input_query } \}|
                            message_type = zpru_if_short_memory_provider=>cs_msg_type-query ) ).

    lo_short_memory->save_message( lt_message ).
  ENDMETHOD.

  METHOD get_short_memory.
    DATA lo_adf_service      TYPE REF TO zpru_if_adf_service.
    DATA lo_discard_strategy TYPE REF TO zpru_if_discard_strategy.
    DATA lo_summary_strategy TYPE REF TO zpru_if_summarization.

    IF mo_short_memory IS BOUND.
      eo_short_memory = mo_short_memory.
      RETURN.
    ENDIF.

    IF iv_agent_uuid IS INITIAL.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    lo_adf_service = zpru_cl_adf_factory=>zpru_if_adf_factory~get_zpru_if_adf_service( ).
    lo_adf_service->read_agent( EXPORTING it_agent_read_k = VALUE #( ( agent_uuid                    = iv_agent_uuid
                                                                       control-agent_uuid            = abap_true
                                                                       control-agent_name            = abap_true
                                                                       control-agent_type            = abap_true
                                                                       control-short_memory_provider = abap_true
                                                                       control-long_memory_provider  = abap_true ) )
                                IMPORTING et_agent        = DATA(lt_agent)
                                CHANGING  cs_reported     = cs_reported
                                          cs_failed       = cs_failed ).

    ASSIGN lt_agent[ 1 ] TO FIELD-SYMBOL(<ls_agent>).
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    CREATE OBJECT mo_short_memory TYPE (<ls_agent>-short_memory_provider).
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    CREATE OBJECT mo_long_memory TYPE (<ls_agent>-long_memory_provider).
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    mo_short_memory->set_long_memory( io_long_memory = mo_long_memory ).

    eo_short_memory = mo_short_memory.

    SELECT SINGLE type~agent_type,
                  type~discard_strategy,
                  type~summary_strategy,
                  disc~strategy_provider AS disc_provider,
                  summ~strategy_provider AS summ_provider,
                  short_mem_volume
      FROM zpru_agent_type AS type
             LEFT OUTER JOIN
               zpru_disc_strat AS disc ON disc~discard_strategy = type~discard_strategy
                 LEFT OUTER JOIN
                   zpru_summ_strat AS summ ON summ~summary_strategy = type~summary_strategy
      WHERE type~agent_type = @<ls_agent>-agent_type
      INTO @DATA(ls_agent_config).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    mo_short_memory->set_mem_volume( iv_mem_volume = ls_agent_config-short_mem_volume ).

    CREATE OBJECT lo_discard_strategy TYPE (ls_agent_config-disc_provider).
    IF sy-subrc = 0.
      mo_short_memory->set_discard_strategy( io_discard_strategy = lo_discard_strategy ).
    ELSE.
      mo_short_memory->set_discard_strategy( io_discard_strategy = NEW zpru_cl_discard_delete( ) ).
    ENDIF.

    CREATE OBJECT lo_summary_strategy TYPE (ls_agent_config-summ_provider).
    IF sy-subrc = 0.
      mo_long_memory->set_summarization( io_summarization = lo_summary_strategy ).
    ELSE.
      mo_long_memory->set_summarization( io_summarization = NEW zpru_cl_summarize_simple( ) ).
    ENDIF.
  ENDMETHOD.

  METHOD process_execution_steps.
    DATA lo_tool_provider     TYPE REF TO zpru_if_tool_provider.
    DATA lo_executor          TYPE REF TO zpru_if_tool_executor.
    DATA lo_input             TYPE REF TO zpru_if_payload.
    DATA lo_output            TYPE REF TO zpru_if_payload.
    DATA lo_last_output       TYPE REF TO zpru_if_payload.
    DATA lo_axc_service       TYPE REF TO zpru_if_axc_service.
    DATA lt_query_update_imp  TYPE zpru_if_axc_type_and_constant=>tt_query_update_imp.
    DATA lt_step_update_imp   TYPE zpru_if_axc_type_and_constant=>tt_step_update_imp.
    DATA lv_error_flag        TYPE abap_boolean.
    DATA lt_message           TYPE zpru_if_short_memory_provider=>tt_message.
    DATA lv_input_prompt      TYPE string.
    DATA lv_output_prompt     TYPE string.
    DATA lo_short_memory      TYPE REF TO zpru_if_short_memory_provider.
    DATA lo_decision_provider TYPE REF TO zpru_if_decision_provider.

    lo_axc_service = zpru_cl_axc_factory=>zpru_if_axc_factory~get_zpru_if_axc_service( ).

    get_short_memory( EXPORTING iv_agent_uuid   = is_agent-agent_uuid
                      IMPORTING eo_short_memory = lo_short_memory
                      CHANGING  cs_reported     = cs_adf_reported
                                cs_failed       = cs_adf_failed ).

    DATA(lv_count) = 1.
    LOOP AT it_execution_steps ASSIGNING FIELD-SYMBOL(<ls_execution_step>).

      ASSIGN it_agent_tools[ tool_uuid = <ls_execution_step>-tool_uuid ] TO FIELD-SYMBOL(<ls_tool_master_data>).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      CREATE OBJECT lo_tool_provider TYPE (<ls_tool_master_data>-tool_provider).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      lo_executor = lo_tool_provider->get_tool( is_tool_master_data = <ls_tool_master_data>
                                                is_execution_step   = <ls_execution_step> ).

      IF lv_count = 1.
        lo_input = NEW zpru_cl_payload( ).
        lo_input->set_data( ir_data = REF #( <ls_execution_step>-input_prompt ) ).
        lo_output = NEW zpru_cl_payload( ).
      ELSE.
        IF lv_output_prompt IS NOT INITIAL.
          lo_input->set_data( ir_data = REF #( lv_output_prompt ) ).
        ELSE.
          lo_input->clear_data( ).
        ENDIF.
        lo_output->clear_data( ).
      ENDIF.

      lv_error_flag = abap_false.

      GET TIME STAMP FIELD DATA(lv_now).

      CASE <ls_tool_master_data>-step_type.
        WHEN zpru_if_adf_type_and_constant=>cs_step_type-simple_code.
          lo_executor->execute_tool( EXPORTING io_controller = mo_controller

                                               io_request    = lo_input
                                     IMPORTING eo_response   = lo_output
                                               ev_error_flag = lv_error_flag ).
        WHEN zpru_if_adf_type_and_constant=>cs_step_type-knowledge_source.
          lo_executor->lookup_knowledge( EXPORTING io_controller = mo_controller
                                                   io_request    = lo_input
                                         IMPORTING eo_response   = lo_output
                                                   ev_error_flag = lv_error_flag ).
        WHEN zpru_if_adf_type_and_constant=>cs_step_type-nested_agent.
          lo_executor->run_nested_agent( EXPORTING io_controller = mo_controller
                                                   io_request    = lo_input
                                         IMPORTING eo_response   = lo_output
                                                   ev_error_flag = lv_error_flag ).
        WHEN OTHERS.
      ENDCASE.

      lv_input_prompt  = lo_input->get_data( )->*.
      lv_output_prompt = lo_output->get_data( )->*.

      DATA(lv_input_tool_prompt_message) = |\{ "USER": "{ sy-uname }", "TOPIC" : "TOOL_INPUT_PROMPT", "TIMESTAMP" : "{ lv_now }",| &&
                                     | "CONTENT" : "{ lv_input_prompt }" \}|.

      DATA(lv_output_tool_prompt_message) = |\{ "USER": "{ sy-uname }", "TOPIC" : "TOOL_OUTPUT_PROMPT", "TIMESTAMP" : "{ lv_now }",| &&
                                     | "CONTENT" : "{ lv_output_prompt }" \}|.

      APPEND INITIAL LINE TO lt_message ASSIGNING FIELD-SYMBOL(<ls_message>).
      <ls_message> = VALUE #(
          message_cid  = |{ lv_now }-{ sy-uname }-PROCESS_EXECUTION_STEPS_{ lv_count }|
          stage        = 'PROCESS_EXECUTION_STEPS'
          sub_stage    = |STEP_{ <ls_execution_step>-execution_seq }|
          namespace    = |{ sy-uname }.{ is_agent-agent_name }.{ is_execution_header-run_id }.{ is_execution_query-query_number }|
          user_name    = sy-uname
          agent_uuid   = is_agent-agent_uuid
          run_uuid     = <ls_execution_step>-run_uuid
          query_uuid   = <ls_execution_step>-query_uuid
          step_uuid    = <ls_execution_step>-step_uuid
          message_time = lv_now
          content      = |\{ "RUN_ID" : "{ is_execution_header-run_id }", | &&
                         | "QUERY_NUMBER" : "{ is_execution_query-query_number }", | &&
                         | "STEP_NUMBER" : "{ <ls_execution_step>-step_number }", | &&
                         | "EXECUTION_SEQ" : "{ <ls_execution_step>-execution_seq }", | &&
                         | "TOOL_NAME" : "{ <ls_tool_master_data>-tool_name }", | &&
                         | "STEP_TYPE" : "{ <ls_tool_master_data>-step_type }", | &&
                         | "INPUT_PROMPT" : { lv_input_tool_prompt_message }, | &&
                         | "OUTPUT_PROMPT" : { lv_output_tool_prompt_message }, | &&
                         | "ERROR" : "{ lv_error_flag }"  \}|
          message_type = zpru_if_short_memory_provider=>cs_msg_type-step_output ).

      lv_count += 1.

      IF lv_error_flag = abap_true.
        APPEND INITIAL LINE TO lt_step_update_imp ASSIGNING FIELD-SYMBOL(<ls_step_2_upd>).
        <ls_step_2_upd>-step_uuid     = <ls_execution_step>-step_uuid.
        <ls_step_2_upd>-query_uuid    = <ls_execution_step>-query_uuid.
        <ls_step_2_upd>-run_uuid      = <ls_execution_step>-run_uuid.
        <ls_step_2_upd>-step_status   = zpru_if_axc_type_and_constant=>sc_step_status-error.
        <ls_step_2_upd>-end_timestamp = lv_now.
        <ls_step_2_upd>-input_prompt  = lv_input_prompt.
        <ls_step_2_upd>-output_prompt = lv_output_prompt.
        <ls_step_2_upd>-control-step_status   = abap_true.
        <ls_step_2_upd>-control-end_timestamp = abap_true.
        <ls_step_2_upd>-control-input_prompt  = abap_true.
        <ls_step_2_upd>-control-output_prompt = abap_true.

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
      <ls_step_2_upd>-input_prompt  = lv_input_prompt.
      <ls_step_2_upd>-output_prompt = lv_output_prompt.
      <ls_step_2_upd>-control-step_status   = abap_true.
      <ls_step_2_upd>-control-end_timestamp = abap_true.
      <ls_step_2_upd>-control-input_prompt  = abap_true.
      <ls_step_2_upd>-control-output_prompt = abap_true.

      IF mo_controller->mv_stop_agent = abap_true.
        EXIT.
      ENDIF.

    ENDLOOP.

    DATA(lv_last_output) = lv_output_prompt.
    lo_last_output = NEW zpru_cl_payload( ).
    lo_last_output->set_data( ir_data = NEW string( lv_last_output ) ).

    IF lt_message IS NOT INITIAL.
      lo_short_memory->save_message( it_message = lt_message ).
    ENDIF.

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

        CREATE OBJECT lo_decision_provider TYPE (is_agent-decision_provider).

        eo_final_response = NEW zpru_cl_payload( ).

        lo_decision_provider->prepare_final_response( EXPORTING iv_run_uuid       = is_execution_query-run_uuid
                                                                iv_query_uuid     = is_execution_query-query_uuid
                                                                io_last_output    = lo_last_output
                                                      IMPORTING eo_final_response = eo_final_response
                                                      CHANGING  cs_axc_reported   = cs_axc_reported
                                                                cs_axc_failed     = cs_axc_failed
                                                                cs_adf_reported   = cs_adf_reported
                                                                cs_adf_failed     = cs_adf_failed   ).
        IF eo_final_response IS BOUND.
          <ls_query_2_upd>-output_response = eo_final_response->get_data( )->*.
          <ls_query_2_upd>-control-output_response = abap_true.
        ENDIF.

        lo_axc_service->update_query( EXPORTING it_query_update_imp = lt_query_update_imp
                                      CHANGING  cs_reported         = cs_axc_reported
                                                cs_failed           = cs_axc_failed ).

        DATA(lv_final_response_message) = |\{ "USER": "{ sy-uname }", "TOPIC" : "FINAL_RESPONSE", "TIMESTAMP" : "{ lv_now }",| &&
                                       | "CONTENT" : "{ <ls_query_2_upd>-output_response }" \}|.

        lv_count += 1.
        APPEND INITIAL LINE TO lt_message ASSIGNING <ls_message>.
        <ls_message> = VALUE #(
            message_cid  = |{ lv_now }-{ sy-uname }-PROCESS_EXECUTION_STEPS_{ lv_count }|
            stage        = 'PROCESS_EXECUTION_STEPS'
            sub_stage    = |FINAL_RESPONSE|
            namespace    = |{ sy-uname }.{ is_agent-agent_name }.{ is_execution_header-run_id }.{ is_execution_query-query_number }|
            user_name    = sy-uname
            agent_uuid   = is_agent-agent_uuid
            run_uuid     = is_execution_query-run_uuid
            query_uuid   = is_execution_query-query_uuid
            message_time = lv_now
            content      = |\{ "RUN_ID" : "{ is_execution_header-run_id }", | &&
                           | "QUERY_NUMBER" : "{ is_execution_query-query_number }", | &&
                           | "FINAL_RESPONSE" : { lv_final_response_message }  \}|
            message_type = zpru_if_short_memory_provider=>cs_msg_type-step_output  ).

        lo_short_memory->save_message( it_message = lt_message ).

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
           es_execution_query,
           es_agent,
           es_execution_header.

    IF iv_run_uuid IS INITIAL.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    lo_axc_service = zpru_cl_axc_factory=>zpru_if_axc_factory~get_zpru_if_axc_service( ).

    lo_axc_service->read_header( EXPORTING it_head_read_k = VALUE #( ( run_uuid = iv_run_uuid
                                                                       control  = VALUE #(
                                                                           run_uuid           = abap_true
                                                                           run_id             = abap_true
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
    es_execution_header = <ls_execution_header>.

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
                                                                           query_number     = abap_true
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
    es_execution_query = ls_execution_query.

    lo_axc_service->rba_step( EXPORTING it_rba_step_k = VALUE #( ( query_uuid = ls_execution_query-query_uuid
                                                                   control    = VALUE #(
                                                                       step_uuid       = abap_true
                                                                       step_number     = abap_true
                                                                       query_uuid      = abap_true
                                                                       run_uuid        = abap_true
                                                                       tool_uuid       = abap_true
                                                                       execution_seq   = abap_true
                                                                       step_status     = abap_true
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
                                             control-agent_type             = abap_true
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

    es_agent = VALUE #( lt_agent[ 1 ] OPTIONAL ).
    IF es_agent IS INITIAL.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    IF es_agent-status <> zpru_if_adf_type_and_constant=>cs_agent_status-active.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    lo_adf_service->rba_tool( EXPORTING it_rba_tool_k = VALUE #( ( agent_uuid                    = es_agent-agent_uuid
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

  METHOD zpru_if_api_agent~add_query_2_run.
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
    DATA lt_message_in             TYPE zpru_if_short_memory_provider=>tt_message.
    DATA lv_langu                  TYPE sylangu.
    DATA lv_decision_log           TYPE zpru_if_agent_frw=>ts_json.
    DATA lv_first_tool_input       TYPE zpru_if_agent_frw=>ts_json.
    DATA lo_axc_service            TYPE REF TO zpru_if_axc_service.
    DATA ls_execution_query        TYPE zpru_axc_query.
    DATA lt_execution_steps        TYPE STANDARD TABLE OF zpru_axc_step WITH EMPTY KEY.
    DATA lo_adf_service            TYPE REF TO zpru_if_adf_service.
    DATA lv_step_number_base       TYPE zpru_de_step_number.
    DATA lo_utility                TYPE REF TO zpru_if_agent_util.

    CLEAR ev_run_uuid.
    CLEAR ev_query_uuid.

    IF    iv_run_uuid    IS INITIAL
       OR iv_input_query IS INITIAL.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    lo_utility = NEW zpru_cl_agent_util( ).
    lo_axc_service = zpru_cl_axc_factory=>zpru_if_axc_factory~get_zpru_if_axc_service( ).

    lo_axc_service->read_header(
      EXPORTING it_head_read_k = VALUE #( ( run_uuid = iv_run_uuid
                                            control  = VALUE #( run_uuid           = abap_true
                                                                run_id             = abap_true
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

    ASSIGN lt_axc_head[ 1 ] TO FIELD-SYMBOL(<ls_axc_head>).
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    GET TIME STAMP FIELD DATA(lv_now).
    mv_input_query = |\{ "USER": "{ sy-uname }", "TOPIC" : "QUERY", "TIMESTAMP" : "{ lv_now }", "CONTENT" : "{ iv_input_query }"  \}|.

    lo_adf_service = zpru_cl_adf_factory=>zpru_if_adf_factory~get_zpru_if_adf_service( ).

    lo_adf_service->read_agent(
      EXPORTING it_agent_read_k = VALUE #( ( agent_uuid                     = <ls_axc_head>-agent_uuid
                                             control-agent_uuid             = abap_true
                                             control-agent_name             = abap_true
                                             control-agent_type             = abap_true
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

    IF ls_agent-status <> zpru_if_adf_type_and_constant=>cs_agent_status-active.
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

    get_long_memory( EXPORTING iv_agent_uuid  = ls_agent-agent_uuid
                     IMPORTING eo_long_memory = lo_long_memory
                     CHANGING  cs_reported    = cs_adf_reported
                               cs_failed      = cs_adf_failed ).

    IF ls_agent-agent_info_provider IS NOT INITIAL.
      CREATE OBJECT lo_agent_info_provider TYPE (ls_agent-agent_info_provider).
    ENDIF.

    IF ls_agent-system_prompt_provider IS NOT INITIAL.
      CREATE OBJECT lo_system_prompt_provider TYPE (ls_agent-system_prompt_provider).
    ENDIF.

    lo_query = NEW zpru_cl_payload( ).
    lo_query->set_data( ir_data = NEW zpru_if_agent_frw=>ts_json( lo_utility->search_node_in_json(
                                                                      iv_json           = mv_input_query
                                                                      iv_field_2_search = 'CONTENT' ) ) ).

    mo_controller->mv_agent_uuid = ls_agent-agent_uuid.

    GET TIME STAMP FIELD lv_now.

    DATA(lv_system_prompt) = |\{ "USER": "{ sy-uname }", "TOPIC" : "SYSTEM_PROMPT", "TIMESTAMP" : "{ lv_now }",| &&
                             | "CONTENT" : "{ lo_system_prompt_provider->get_system_prompt( ) }" \}|.

    DATA(lv_agent_info) = |\{ "USER": "{ sy-uname }", "TOPIC" : "AGENT_INFO", "TIMESTAMP" : "{ lv_now }",| &&
                             | "CONTENT" : "{ lo_agent_info_provider->get_agent_info( ) }" \}|.

    lt_message_in = VALUE #( ( message_cid  = |{ lv_now }-{ sy-uname }-ADD_QUERY_2_RUN_{ 1 }|
                               stage        = 'ADD_QUERY_2_RUN'
                               sub_stage    = 'BEFORE_DECISION'
                               namespace    = |{ sy-uname }.{ ls_agent-agent_name }|
                               user_name    = sy-uname
                               agent_uuid   = ls_agent-agent_uuid
                               message_time = lv_now
                               content      = |\{ "AGENT_NAME" : "{ ls_agent-agent_name }", | &&
                                              | "DECISION_PROVIDER" : "{ ls_agent-decision_provider }", | &&
                                              | "QUERY" : { mv_input_query }, | &&
                                              | "SYSTEM PROMPT" : { lv_system_prompt }, | &&
                                              | "AGENT INFO" : { lv_agent_info } \}|
                               message_type = zpru_if_short_memory_provider=>cs_msg_type-info ) ).

    lo_short_memory->save_message( lt_message_in ).

    lo_first_tool_input = NEW zpru_cl_payload( ).
    lo_execution_plan   = NEW zpru_cl_payload( ).
    lo_langu            = NEW zpru_cl_payload( ).
    lo_decision_log     = NEW zpru_cl_payload( ).

    lo_decision_provider->call_decision_engine( EXPORTING is_agent               = ls_agent
                                                          it_tool                = lt_agent_tools
                                                          io_controller          = mo_controller
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
    ENDIF.

    IF lo_decision_log IS BOUND.
      lv_decision_log = lo_decision_log->get_data( )->*.
    ENDIF.

    IF lo_first_tool_input IS BOUND.
      lv_first_tool_input = lo_first_tool_input->get_data( )->*.
    ENDIF.

    IF lo_langu IS BOUND.
      lv_langu = lo_langu->get_data( )->*.
    ENDIF.

    GET TIME STAMP FIELD lv_now.
    DATA(lv_decision_log_message) = |\{ "USER": "{ sy-uname }", "TOPIC" : "DECISION_LOG", "TIMESTAMP" : "{ lv_now }",| &&
                                    | "CONTENT" : "{ lv_decision_log }" \}|.

    DATA(lv_first_tool_input_message) = |\{ "USER": "{ sy-uname }", "TOPIC" : "FIRST_TOOL_INPUT", "TIMESTAMP" : "{ lv_now }",| &&
                                   | "CONTENT" : "{ lv_first_tool_input }" \}|.

    lt_message_in = VALUE #( ( message_cid  = |{ lv_now }-{ sy-uname }-ADD_QUERY_2_RUN_{ 2 }|
                               stage        = 'ADD_QUERY_2_RUN'
                               sub_stage    = 'AFTER_DECISION'
                               namespace    = |{ sy-uname }.{ ls_agent-agent_name }|
                               user_name    = sy-uname
                               agent_uuid   = ls_agent-agent_uuid
                               message_time = lv_now
                               content      = |\{ "AGENT_NAME" : "{ ls_agent-agent_name }", | &&
                                              | "DECISION_PROVIDER" : "{ ls_agent-decision_provider }", | &&
                                              | "QUERY" : { mv_input_query }, | &&
                                              | "FIRST TOOL INPUT" : { lv_first_tool_input_message }, | &&
                                              | "LANGUAGE" : "{ lv_langu }", | &&
                                              | "DECISION LOG" : { lv_decision_log_message } \}|
                               message_type = zpru_if_short_memory_provider=>cs_msg_type-info ) ).

    DATA(lv_count) = 3.
    LOOP AT lt_execution_plan ASSIGNING FIELD-SYMBOL(<ls_execution_plan>).
      APPEND INITIAL LINE TO lt_message_in ASSIGNING FIELD-SYMBOL(<ls_message>).
      <ls_message> = VALUE #( message_cid  = |{ lv_now }-{ sy-uname }-ADD_QUERY_2_RUN_{ lv_count }|
                              stage        = 'ADD_QUERY_2_RUN'
                              sub_stage    = 'TOOL_ANALYSIS'
                              namespace    = |{ sy-uname }.{ ls_agent-agent_name }|
                              user_name    = sy-uname
                              agent_uuid   = ls_agent-agent_uuid
                              message_time = lv_now
                              content      = |\{ "AGENT_NAME" : "{ ls_agent-agent_name }", | &&
                                             | "EXECUTION_SEQUENCE" : "{ <ls_execution_plan>-sequence }", | &&
                                             | "TOOL_NAME" : "{ <ls_execution_plan>-tool_name }" \}|
                              message_type = zpru_if_short_memory_provider=>cs_msg_type-info  ).

      lv_count += 1.
    ENDLOOP.

    lo_short_memory->save_message( lt_message_in ).

    TRY.

        " query
        ls_execution_query-query_uuid       = cl_system_uuid=>create_uuid_x16_static( ).
        ls_execution_query-query_number     = lo_axc_service->generate_query_number(
                                                  iv_run_uuid = <ls_axc_head>-run_uuid ).
        ls_execution_query-run_uuid         = <ls_axc_head>-run_uuid.
        ls_execution_query-language         = COND #( WHEN lv_langu IS NOT INITIAL
                                                      THEN lv_langu
                                                      ELSE sy-langu ).
        ls_execution_query-execution_status = zpru_if_axc_type_and_constant=>sc_query_status-new.
        ls_execution_query-start_timestamp  = lv_now.
        ls_execution_query-input_prompt     = lo_utility->search_node_in_json( iv_json           = mv_input_query
                                                                               iv_field_2_search = 'CONTENT' ).
        ls_execution_query-decision_log     = lo_utility->search_node_in_json(
                                                  iv_json           = lv_decision_log_message
                                                  iv_field_2_search = 'CONTENT' ).

        lo_axc_service->cba_query(
          EXPORTING it_axc_query_imp = VALUE #( ( query_uuid       = ls_execution_query-query_uuid
                                                  query_number     = ls_execution_query-query_number
                                                  run_uuid         = ls_execution_query-run_uuid
                                                  language         = ls_execution_query-language
                                                  execution_status = ls_execution_query-execution_status
                                                  start_timestamp  = ls_execution_query-start_timestamp
                                                  end_timestamp    = ls_execution_query-end_timestamp
                                                  input_prompt     = ls_execution_query-input_prompt
                                                  decision_log     = ls_execution_query-decision_log
                                                  output_response  = ls_execution_query-output_response
                                                  control          = VALUE #( query_uuid       = abap_true
                                                                              query_number     = abap_true
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

        GET TIME STAMP FIELD lv_now.

        lt_message_in = VALUE #( ( message_cid  = |{ lv_now }-{ sy-uname }-ADD_QUERY_2_RUN_{ lv_count }|
                                   stage        = 'ADD_QUERY_2_RUN'
                                   sub_stage    = 'AFTER_QUERY_CREATION'
                                   namespace    = |{ sy-uname }.{ ls_agent-agent_name }.{ <ls_axc_head>-run_id }|
                                   user_name    = sy-uname
                                   agent_uuid   = ls_agent-agent_uuid
                                   run_uuid     = <ls_axc_head>-run_uuid
                                   query_uuid   = ls_execution_query-query_uuid
                                   message_time = lv_now
                                   content      = |\{ "AGENT_NAME" : "{ ls_agent-agent_name }", | &&
                                                  | "RUN_ID" : "{ <ls_axc_head>-run_id }", | &&
                                                  | "QUERY_NUMBER" : "{ ls_execution_query-query_number }", | &&
                                                  | "LANGUAGE" : "{ ls_execution_query-language }", | &&
                                                  | "QUERY" : { mv_input_query }, | &&
                                                  | "DECISION LOG" : { lv_decision_log_message } \}|
                                   message_type = zpru_if_short_memory_provider=>cs_msg_type-query ) ).

        SORT lt_execution_plan BY sequence ASCENDING.
        DATA(lv_min_seq) = VALUE #( lt_execution_plan[ 1 ]-sequence OPTIONAL ).

        lv_count += 1.
        LOOP AT lt_execution_plan ASSIGNING FIELD-SYMBOL(<ls_tool>).

          ASSIGN lt_agent_tools[ agent_uuid = <ls_tool>-agent_uuid
                                 tool_name  = <ls_tool>-tool_name ] TO FIELD-SYMBOL(<ls_tool_master_data>).
          IF sy-subrc <> 0.
            RETURN.
          ENDIF.

          APPEND INITIAL LINE TO lt_execution_steps ASSIGNING FIELD-SYMBOL(<ls_execution_step>).
          <ls_execution_step>-step_uuid       = cl_system_uuid=>create_uuid_x16_static( ).
          <ls_execution_step>-step_number     = lo_axc_service->generate_step_number(
                                                    iv_query_uuid       = ls_execution_query-query_uuid
                                                    iv_step_number_base = lv_step_number_base ).
          <ls_execution_step>-query_uuid      = ls_execution_query-query_uuid.
          <ls_execution_step>-run_uuid        = <ls_axc_head>-run_uuid.
          <ls_execution_step>-tool_uuid       = <ls_tool_master_data>-tool_uuid.
          <ls_execution_step>-execution_seq   = <ls_tool>-sequence.
          <ls_execution_step>-step_status     = zpru_if_axc_type_and_constant=>sc_step_status-new.
          <ls_execution_step>-start_timestamp = lv_now.
          IF <ls_tool>-sequence = lv_min_seq.
            <ls_execution_step>-input_prompt = lv_first_tool_input.
          ENDIF.

          IF <ls_execution_step>-input_prompt IS NOT INITIAL.
            DATA(lv_tool_prompt_message) = |\{ "USER": "{ sy-uname }", "TOPIC" : "TOOL_INPUT_PROMPT", "TIMESTAMP" : "{ lv_now }",| &&
                                           | "CONTENT" : "{ <ls_execution_step>-input_prompt }" \}|.
          ELSE.
            CLEAR lv_tool_prompt_message.
          ENDIF.

          APPEND INITIAL LINE TO lt_message_in ASSIGNING <ls_message>.
          <ls_message> = VALUE #(
              message_cid  = |{ lv_now }-{ sy-uname }-ADD_QUERY_2_RUN_{ lv_count }|
              stage        = 'ADD_QUERY_2_RUN'
              sub_stage    = 'STEP_ANALYSIS'
              namespace    = |{ sy-uname }.{ ls_agent-agent_name }.{ <ls_axc_head>-run_id }.{ ls_execution_query-query_number }|
              user_name    = sy-uname
              agent_uuid   = ls_agent-agent_uuid
              run_uuid     = <ls_axc_head>-run_uuid
              query_uuid   = ls_execution_query-query_uuid
              step_uuid    = <ls_execution_step>-step_uuid
              message_time = lv_now
              content      = |\{ "STEP_NUMBER" : "{ <ls_execution_step>-step_number }", | &&
                             | "QUERY_NUMBER" : "{ ls_execution_query-query_number }", | &&
                             | "RUN_ID" : "{ <ls_axc_head>-run_id }", | &&
                             | "EXECUTION_SEQUENCE" : "{ <ls_execution_step>-execution_seq }", | &&
                             | "INPUT_PROMPT" : { lv_tool_prompt_message } \}|
              message_type = zpru_if_short_memory_provider=>cs_msg_type-step_input  ).

          lv_count += 1.
          lv_step_number_base = <ls_execution_step>-step_number.
        ENDLOOP.

        lo_short_memory->save_message( lt_message_in ).

        lo_axc_service->cba_step( EXPORTING it_axc_step_imp = VALUE #( FOR <ls_s> IN lt_execution_steps
                                                                       ( step_uuid       = <ls_s>-step_uuid
                                                                         step_number     = <ls_s>-step_number
                                                                         query_uuid      = <ls_s>-query_uuid
                                                                         run_uuid        = <ls_s>-run_uuid
                                                                         tool_uuid       = <ls_s>-tool_uuid
                                                                         execution_seq   = <ls_s>-execution_seq
                                                                         step_status     = <ls_s>-step_status
                                                                         start_timestamp = <ls_s>-start_timestamp
                                                                         end_timestamp   = <ls_s>-end_timestamp
                                                                         input_prompt    = <ls_s>-input_prompt
                                                                         output_prompt   = <ls_s>-output_prompt
                                                                         control         = VALUE #(
                                                                             step_uuid       = abap_true
                                                                             step_number     = abap_true
                                                                             query_uuid      = abap_true
                                                                             run_uuid        = abap_true
                                                                             tool_uuid       = abap_true
                                                                             execution_seq   = abap_true
                                                                             step_status     = abap_true
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

    ev_run_uuid   = <ls_axc_head>-run_uuid.
    ev_query_uuid = ls_execution_query-query_uuid.
  ENDMETHOD.

  METHOD get_long_memory.
    IF iv_agent_uuid IS INITIAL.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    get_short_memory( EXPORTING iv_agent_uuid   = iv_agent_uuid
                      IMPORTING eo_short_memory = DATA(lo_short_memory)
                      CHANGING  cs_reported     = cs_reported
                                cs_failed       = cs_failed ).

    IF lo_short_memory IS NOT BOUND.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    eo_long_memory = lo_short_memory->get_long_memory( ).
  ENDMETHOD.
ENDCLASS.
