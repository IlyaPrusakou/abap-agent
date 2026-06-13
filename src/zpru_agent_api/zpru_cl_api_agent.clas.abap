CLASS zpru_cl_api_agent DEFINITION
  PUBLIC
  CREATE PRIVATE
  GLOBAL FRIENDS zpru_cl_agent_service_mngr.

  PUBLIC SECTION.
    INTERFACES zpru_if_agent_frw.
    INTERFACES zpru_if_api_agent.
    INTERFACES if_serializable_object.

  PROTECTED SECTION.
    TYPES: BEGIN OF ts_map_tempuuid_2_finaluuid,
             temp_uuid    TYPE sysuuid_x16,
             stepsequence TYPE zpru_de_step_sequence,
             final_uuid   TYPE sysuuid_x16,
           END OF ts_map_tempuuid_2_finaluuid.

    TYPES tt_map_tempuuid_2_finaluuid TYPE STANDARD TABLE OF ts_map_tempuuid_2_finaluuid WITH EMPTY KEY.

    DATA mo_controller           TYPE REF TO zpru_if_agent_controller.
    DATA mo_short_memory         TYPE REF TO zpru_if_short_memory_provider.
    DATA mo_long_memory          TYPE REF TO zpru_if_long_memory_provider.
    DATA mv_input_query          TYPE zpru_if_agent_frw=>ts_json.
    DATA ms_input_prompt         TYPE zpru_s_prompt.
    DATA mv_output_response      TYPE zpru_if_agent_frw=>ts_json.
    DATA mv_output_response_prev TYPE zpru_if_agent_frw=>ts_json.

    METHODS is_execute_miniloop
      IMPORTING io_controller               TYPE REF TO zpru_if_agent_controller
                is_agent                    TYPE zpru_if_adf_type_and_constant=>ts_agent
      RETURNING VALUE(rv_continue_miniloop) TYPE abap_boolean
      RAISING   zpru_cx_agent_core.

    METHODS write_2_data_board
      IMPORTING it_key_value_pairs TYPE zpru_tt_key_value
                io_controller      TYPE REF TO zpru_if_agent_controller
      RAISING   zpru_cx_agent_core.

    METHODS get_payload
      RETURNING VALUE(ro_payload) TYPE REF TO zpru_if_payload
      RAISING   zpru_cx_agent_core.

    METHODS get_utility
      RETURNING VALUE(ro_util) TYPE REF TO zpru_if_agent_util
      RAISING   zpru_cx_agent_core.

    METHODS get_controller
      RETURNING VALUE(ro_controller) TYPE REF TO zpru_if_agent_controller
      RAISING   zpru_cx_agent_core.

    METHODS get_short_memory
      IMPORTING iv_agent_uuid   TYPE sysuuid_x16
      EXPORTING eo_short_memory TYPE REF TO zpru_if_short_memory_provider
      CHANGING  cs_reported     TYPE zpru_if_agent_frw=>ts_adf_reported OPTIONAL
                cs_failed       TYPE zpru_if_agent_frw=>ts_adf_failed   OPTIONAL
      RAISING   zpru_cx_agent_core.

    METHODS get_long_memory
      IMPORTING iv_agent_uuid  TYPE sysuuid_x16
      EXPORTING eo_long_memory TYPE REF TO zpru_if_long_memory_provider
      CHANGING  cs_reported    TYPE zpru_if_agent_frw=>ts_adf_reported OPTIONAL
                cs_failed      TYPE zpru_if_agent_frw=>ts_adf_failed   OPTIONAL
      RAISING   zpru_cx_agent_core.

    METHODS process_execution_steps
      IMPORTING is_agent            TYPE zpru_if_adf_type_and_constant=>ts_agent
                is_execution_header TYPE zpru_s_axc_head
                is_execution_query  TYPE zpru_if_axc_type_and_constant=>ts_axc_query
                it_execution_steps  TYPE zpru_if_axc_type_and_constant=>tt_axc_step
                it_agent_tools      TYPE zpru_if_adf_type_and_constant=>tt_agent_tool
      EXPORTING eo_final_response   TYPE REF TO zpru_if_payload
      CHANGING  cs_axc_reported     TYPE zpru_if_agent_frw=>ts_axc_reported OPTIONAL
                cs_axc_failed       TYPE zpru_if_agent_frw=>ts_axc_failed   OPTIONAL
                cs_adf_reported     TYPE zpru_if_agent_frw=>ts_adf_reported OPTIONAL
                cs_adf_failed       TYPE zpru_if_agent_frw=>ts_adf_failed   OPTIONAL
      RAISING   zpru_cx_agent_core.

    METHODS prepare_execution
      IMPORTING iv_run_uuid         TYPE sysuuid_x16
                iv_query_uuid       TYPE sysuuid_x16                        OPTIONAL
      EXPORTING es_agent            TYPE zpru_if_adf_type_and_constant=>ts_agent
                es_execution_header TYPE zpru_s_axc_head
                es_execution_query  TYPE zpru_if_axc_type_and_constant=>ts_axc_query
                et_execution_steps  TYPE zpru_if_axc_type_and_constant=>tt_axc_step
                et_agent_tools      TYPE zpru_if_adf_type_and_constant=>tt_agent_tool
      CHANGING  cs_axc_reported     TYPE zpru_if_agent_frw=>ts_axc_reported OPTIONAL
                cs_axc_failed       TYPE zpru_if_agent_frw=>ts_axc_failed   OPTIONAL
                cs_adf_reported     TYPE zpru_if_agent_frw=>ts_adf_reported OPTIONAL
                cs_adf_failed       TYPE zpru_if_agent_frw=>ts_adf_failed   OPTIONAL
      RAISING   zpru_cx_agent_core.

    METHODS execute_mini_loop
      IMPORTING is_agent            TYPE zpru_if_adf_type_and_constant=>ts_agent
                is_execution_header TYPE zpru_s_axc_head
                is_execution_query  TYPE zpru_if_axc_type_and_constant=>ts_axc_query
                it_additional_steps TYPE zpru_if_axc_type_and_constant=>tt_axc_step
                it_additional_tools TYPE zpru_if_adf_type_and_constant=>tt_agent_tool
                is_tool_master_data TYPE zpru_if_adf_type_and_constant=>ts_agent_tool
                is_current_step     TYPE zpru_if_axc_type_and_constant=>ts_axc_step
                iv_output_prompt    TYPE string
      EXPORTING eo_final_response   TYPE REF TO zpru_if_payload
      CHANGING  cs_axc_reported     TYPE zpru_if_agent_frw=>ts_axc_reported OPTIONAL
                cs_axc_failed       TYPE zpru_if_agent_frw=>ts_axc_failed OPTIONAL
                cs_adf_reported     TYPE zpru_if_agent_frw=>ts_adf_reported OPTIONAL
                cs_adf_failed       TYPE zpru_if_agent_frw=>ts_adf_failed OPTIONAL
      RAISING   zpru_cx_agent_core.

    METHODS execute_tool_logic
      IMPORTING is_agent            TYPE zpru_if_adf_type_and_constant=>ts_agent
                io_controller       TYPE REF TO zpru_if_agent_controller
                io_input            TYPE REF TO zpru_if_payload
                is_tool_master_data TYPE zpru_if_adf_type_and_constant=>ts_agent_tool
                is_execution_step   TYPE zpru_if_axc_type_and_constant=>ts_axc_step
      EXPORTING eo_response         TYPE REF TO zpru_if_payload
                et_key_value_pairs  TYPE zpru_tt_key_value
                ev_error_flag       TYPE abap_boolean
                et_additional_steps TYPE zpru_if_axc_type_and_constant=>tt_axc_step
                et_additional_tools TYPE zpru_if_adf_type_and_constant=>tt_agent_tool
      RAISING   zpru_cx_agent_core.

    METHODS finalize_successful_query
      IMPORTING is_agent            TYPE zpru_if_adf_type_and_constant=>ts_agent
                is_execution_header TYPE zpru_s_axc_head
                is_execution_query  TYPE zpru_if_axc_type_and_constant=>ts_axc_query
                io_last_output      TYPE REF TO zpru_if_payload
                io_short_memory     TYPE REF TO zpru_if_short_memory_provider
                io_controller       TYPE REF TO zpru_if_agent_controller
      EXPORTING eo_final_response   TYPE REF TO zpru_if_payload
      CHANGING  cs_axc_reported     TYPE zpru_if_agent_frw=>ts_axc_reported OPTIONAL
                cs_axc_failed       TYPE zpru_if_agent_frw=>ts_axc_failed   OPTIONAL
                cs_adf_reported     TYPE zpru_if_agent_frw=>ts_adf_reported OPTIONAL
                cs_adf_failed       TYPE zpru_if_agent_frw=>ts_adf_failed   OPTIONAL
      RAISING   zpru_cx_agent_core.

    METHODS log_step_execution
      IMPORTING is_agent            TYPE zpru_if_adf_type_and_constant=>ts_agent
                is_execution_header TYPE zpru_s_axc_head
                is_execution_query  TYPE zpru_if_axc_type_and_constant=>ts_axc_query
                is_execution_step   TYPE zpru_if_axc_type_and_constant=>ts_axc_step
                is_tool_master_data TYPE zpru_if_adf_type_and_constant=>ts_agent_tool
                iv_input_prompt     TYPE string
                iv_output_prompt    TYPE string
                iv_error_flag       TYPE abap_boolean
                iv_count            TYPE i
      RETURNING VALUE(rs_message)   TYPE zpru_if_short_memory_provider=>ts_message
      RAISING   zpru_cx_agent_core.

    METHODS setup_agent_context
      IMPORTING iv_agent_uuid             TYPE sysuuid_x16
      EXPORTING es_agent                  TYPE zpru_if_adf_type_and_constant=>ts_agent
                et_agent_tools            TYPE zpru_if_adf_type_and_constant=>tt_agent_tool
                eo_decision_provider      TYPE REF TO zpru_if_decision_provider
                eo_short_memory           TYPE REF TO zpru_if_short_memory_provider
                eo_long_memory            TYPE REF TO zpru_if_long_memory_provider
                eo_agent_info_provider    TYPE REF TO zpru_if_agent_info_provider
                eo_system_prompt_provider TYPE REF TO zpru_if_prompt_provider
      CHANGING  cs_adf_reported           TYPE zpru_if_agent_frw=>ts_adf_reported OPTIONAL
                cs_adf_failed             TYPE zpru_if_agent_frw=>ts_adf_failed OPTIONAL
      RAISING   zpru_cx_agent_core.

    METHODS process_decision_engine
      IMPORTING is_agent                  TYPE zpru_if_adf_type_and_constant=>ts_agent
                it_agent_tools            TYPE zpru_if_adf_type_and_constant=>tt_agent_tool
                io_controller             TYPE REF TO zpru_if_agent_controller
                iv_input_query            TYPE string
                is_input_prompt           TYPE zpru_s_prompt
                io_decision_provider      TYPE REF TO zpru_if_decision_provider
                io_system_prompt_provider TYPE REF TO zpru_if_prompt_provider
                io_short_memory           TYPE REF TO zpru_if_short_memory_provider
                io_long_memory            TYPE REF TO zpru_if_long_memory_provider
                io_agent_info_provider    TYPE REF TO zpru_if_agent_info_provider
                iv_stage                  TYPE string
      EXPORTING eo_execution_plan         TYPE REF TO zpru_if_payload
                eo_first_tool_input       TYPE REF TO zpru_if_payload
                eo_langu                  TYPE REF TO zpru_if_payload
                eo_decision_log           TYPE REF TO zpru_if_payload
      RAISING   zpru_cx_agent_core.

    METHODS construct_execution_steps
      IMPORTING it_agent_tools      TYPE zpru_if_adf_type_and_constant=>tt_agent_tool
                is_agent            TYPE zpru_if_adf_type_and_constant=>ts_agent
                is_execution_header TYPE zpru_s_axc_head
                is_execution_query  TYPE zpru_s_axc_query
                iv_first_tool_input TYPE zpru_if_agent_frw=>ts_json
                io_short_memory     TYPE REF TO zpru_if_short_memory_provider
                iv_stage            TYPE string
                iv_count            TYPE i
      EXPORTING et_execution_steps  TYPE zpru_if_axc_type_and_constant=>tt_axc_step
      CHANGING  ct_execution_plan   TYPE zpru_if_decision_provider=>tt_execution_plan
                cs_axc_reported     TYPE zpru_if_agent_frw=>ts_axc_reported OPTIONAL
                cs_axc_failed       TYPE zpru_if_agent_frw=>ts_axc_failed OPTIONAL
                cs_axc_mapped       TYPE zpru_if_agent_frw=>ts_axc_mapped OPTIONAL
      RAISING   zpru_cx_agent_core.

    METHODS resequence_steps
      IMPORTING it_additional_steps         TYPE zpru_if_axc_type_and_constant=>tt_axc_step
                is_execution_header         TYPE zpru_s_axc_head
                is_execution_query          TYPE zpru_if_axc_type_and_constant=>ts_axc_query
                iv_output_prompt            TYPE string
      EXPORTING et_map_tempuuid_2_finaluuid TYPE tt_map_tempuuid_2_finaluuid
      CHANGING  ct_step_all                 TYPE zpru_if_axc_type_and_constant=>tt_axc_step
                ct_step_after               TYPE zpru_if_axc_type_and_constant=>tt_axc_step
                ct_step_update_imp          TYPE zpru_if_axc_type_and_constant=>tt_step_update_imp
                ct_step_create_imp          TYPE zpru_if_axc_type_and_constant=>tt_step_create_imp.

    METHODS clear_internal_state.

    METHODS assign_controller_context
      IMPORTING io_parent_controller TYPE REF TO zpru_if_agent_controller OPTIONAL
      RAISING   zpru_cx_agent_core.

    METHODS fetch_agent_configuration
      IMPORTING iv_agent_name TYPE zpru_if_api_agent=>tv_agent_name
      EXPORTING es_agent      TYPE zpru_if_adf_type_and_constant=>ts_agent
                eo_service    TYPE REF TO zpru_if_adf_service
                et_agent_k    TYPE zpru_if_adf_type_and_constant=>tt_agent_k
      CHANGING  cs_reported   TYPE zpru_if_agent_frw=>ts_adf_reported OPTIONAL
                cs_failed     TYPE zpru_if_agent_frw=>ts_adf_failed   OPTIONAL
      RAISING   zpru_cx_agent_core.

    METHODS ensure_agent_is_active
      IMPORTING is_agent    TYPE zpru_if_adf_type_and_constant=>ts_agent
                io_service  TYPE REF TO zpru_if_adf_service
      CHANGING  cs_reported TYPE zpru_if_agent_frw=>ts_adf_reported OPTIONAL
                cs_failed   TYPE zpru_if_agent_frw=>ts_adf_failed   OPTIONAL
      RAISING   zpru_cx_agent_core.

    METHODS identify_available_tools
      IMPORTING it_agent_k  TYPE zpru_if_adf_type_and_constant=>tt_agent_k
                io_service  TYPE REF TO zpru_if_adf_service
      EXPORTING et_tools    TYPE zpru_if_adf_type_and_constant=>tt_agent_tool
      CHANGING  cs_reported TYPE zpru_if_agent_frw=>ts_adf_reported OPTIONAL
                cs_failed   TYPE zpru_if_agent_frw=>ts_adf_failed   OPTIONAL
      RAISING   zpru_cx_agent_core.

    METHODS prepare_memory_provider
      IMPORTING iv_agent_uuid   TYPE sysuuid_x16
      EXPORTING eo_short_memory TYPE REF TO zpru_if_short_memory_provider
      CHANGING  cs_reported     TYPE zpru_if_agent_frw=>ts_adf_reported OPTIONAL
                cs_failed       TYPE zpru_if_agent_frw=>ts_adf_failed   OPTIONAL
      RAISING   zpru_cx_agent_core.

    METHODS record_initialization_event
      IMPORTING is_agent        TYPE zpru_if_adf_type_and_constant=>ts_agent
                it_tools        TYPE zpru_if_adf_type_and_constant=>tt_agent_tool
                io_short_memory TYPE REF TO zpru_if_short_memory_provider
      RAISING   zpru_cx_agent_core.

    METHODS fetch_agent_definition_by_uuid
      IMPORTING iv_agent_uuid TYPE sysuuid_x16
      EXPORTING es_agent      TYPE zpru_if_adf_type_and_constant=>ts_agent
                eo_service    TYPE REF TO zpru_if_adf_service
      CHANGING  cs_reported   TYPE zpru_if_agent_frw=>ts_adf_reported OPTIONAL
                cs_failed     TYPE zpru_if_agent_frw=>ts_adf_failed   OPTIONAL
      RAISING   zpru_cx_agent_core.

    METHODS update_query_internal_state
      IMPORTING is_input_query TYPE zpru_s_prompt
      RAISING   zpru_cx_agent_core.

    METHODS append_query_to_controller
      RAISING zpru_cx_agent_core.

    METHODS record_query_event
      IMPORTING is_agent        TYPE zpru_if_adf_type_and_constant=>ts_agent
                io_short_memory TYPE REF TO zpru_if_short_memory_provider
      RAISING   zpru_cx_agent_core.

    METHODS initialize_run_controller
      IMPORTING iv_agent_uuid        TYPE sysuuid_x16
      RETURNING VALUE(ro_controller) TYPE REF TO zpru_if_agent_controller
      RAISING   zpru_cx_agent_core.

    METHODS create_execution_header
      IMPORTING iv_agent_uuid       TYPE sysuuid_x16
                io_axc_service      TYPE REF TO zpru_if_axc_service
      EXPORTING es_execution_header TYPE zpru_if_axc_type_and_constant=>ts_head_create_imp
      CHANGING  cs_axc_reported     TYPE zpru_if_agent_frw=>ts_axc_reported OPTIONAL
                cs_axc_failed       TYPE zpru_if_agent_frw=>ts_axc_failed   OPTIONAL
                cs_axc_mapped       TYPE zpru_if_agent_frw=>ts_axc_mapped   OPTIONAL
      RAISING   zpru_cx_agent_core.

    METHODS load_execution_header
      IMPORTING iv_run_uuid         TYPE sysuuid_x16
                io_axc_service      TYPE REF TO zpru_if_axc_service
      EXPORTING es_execution_header TYPE zpru_s_axc_head
      CHANGING  cs_axc_reported     TYPE zpru_if_agent_frw=>ts_axc_reported OPTIONAL
                cs_axc_failed       TYPE zpru_if_agent_frw=>ts_axc_failed   OPTIONAL
      RAISING   zpru_cx_agent_core.

    METHODS create_execution_query
      IMPORTING iv_run_uuid         TYPE sysuuid_x16
                iv_input_query      TYPE string
                iv_langu            TYPE sylangu
                iv_decision_log     TYPE zpru_if_agent_frw=>ts_json
                io_axc_service      TYPE REF TO zpru_if_axc_service
                io_utility          TYPE REF TO zpru_if_agent_util
      EXPORTING es_execution_query  TYPE zpru_if_axc_type_and_constant=>ts_query_create_imp
                ev_decision_log_msg TYPE string
      CHANGING  cs_axc_reported     TYPE zpru_if_agent_frw=>ts_axc_reported OPTIONAL
                cs_axc_failed       TYPE zpru_if_agent_frw=>ts_axc_failed OPTIONAL
                cs_axc_mapped       TYPE zpru_if_agent_frw=>ts_axc_mapped OPTIONAL
      RAISING   zpru_cx_agent_core.

    METHODS log_query_to_memory
      IMPORTING is_agent            TYPE zpru_if_adf_type_and_constant=>ts_agent
                is_execution_header TYPE zpru_s_axc_head
                is_execution_query  TYPE zpru_if_axc_type_and_constant=>ts_query_create_imp
                iv_input_query      TYPE string
                iv_decision_log_msg TYPE string
                iv_stage            TYPE string
                io_short_memory     TYPE REF TO zpru_if_short_memory_provider
      RAISING   zpru_cx_agent_core.

    METHODS prepare_controller_4_return
      EXPORTING eo_executed_controller TYPE REF TO zpru_if_agent_controller
      RAISING   zpru_cx_agent_core.

    METHODS attach_run_2_controller
      IMPORTING is_execution_header TYPE zpru_s_axc_head
                is_execution_query  TYPE zpru_if_axc_type_and_constant=>ts_axc_query
                io_controller       TYPE REF TO zpru_if_agent_controller
      RAISING   zpru_cx_agent_core.

    METHODS detach_run_from_controller
      IMPORTING io_controller TYPE REF TO zpru_if_agent_controller
      RAISING   zpru_cx_agent_core.

  PRIVATE SECTION.

ENDCLASS.


CLASS zpru_cl_api_agent IMPLEMENTATION.
  METHOD zpru_if_api_agent~save_execution.
    DATA lo_axc_service TYPE REF TO zpru_if_axc_service.

    lo_axc_service ?= zpru_cl_agent_service_mngr=>get_service( iv_service = `ZPRU_IF_AXC_SERVICE`
                                                               iv_context = zpru_if_agent_frw=>cs_context-standard ).

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
    DATA lt_execution_plan   TYPE zpru_if_decision_provider=>tt_execution_plan.
    DATA lv_first_tool_input TYPE zpru_if_agent_frw=>ts_json.
    DATA lv_langu            TYPE sylangu.
    DATA lv_decision_log     TYPE zpru_if_agent_frw=>ts_json.

    CLEAR ev_built_run_uuid.
    CLEAR ev_built_query_uuid.

    IF    iv_agent_uuid  IS INITIAL
       OR mv_input_query IS INITIAL.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    setup_agent_context( EXPORTING iv_agent_uuid             = iv_agent_uuid
                         IMPORTING es_agent                  = DATA(ls_agent)
                                   et_agent_tools            = DATA(lt_agent_tools)
                                   eo_decision_provider      = DATA(lo_decision_provider)
                                   eo_short_memory           = DATA(lo_short_memory)
                                   eo_long_memory            = DATA(lo_long_memory)
                                   eo_agent_info_provider    = DATA(lo_agent_info_provider)
                                   eo_system_prompt_provider = DATA(lo_system_prompt_provider)
                         CHANGING  cs_adf_reported           = cs_adf_reported
                                   cs_adf_failed             = cs_adf_failed ).

    DATA(lo_controller) = initialize_run_controller( ls_agent-agentuuid ).

    process_decision_engine( EXPORTING is_agent                  = ls_agent
                                       it_agent_tools            = lt_agent_tools
                                       io_controller             = lo_controller
                                       iv_input_query            = mv_input_query
                                       is_input_prompt           = ms_input_prompt
                                       io_decision_provider      = lo_decision_provider
                                       io_system_prompt_provider = lo_system_prompt_provider
                                       io_short_memory           = lo_short_memory
                                       io_long_memory            = lo_long_memory
                                       io_agent_info_provider    = lo_agent_info_provider
                                       iv_stage                  = 'BUILD_EXECUTION'
                             IMPORTING eo_execution_plan         = DATA(lo_execution_plan)
                                       eo_first_tool_input       = DATA(lo_first_tool_input)
                                       eo_langu                  = DATA(lo_langu)
                                       eo_decision_log           = DATA(lo_decision_log) ).

    IF lo_execution_plan IS BOUND.
      lt_execution_plan = lo_execution_plan->get_data( )->*.
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

    DATA(lo_axc_service) = CAST zpru_if_axc_service( zpru_cl_agent_service_mngr=>get_service(
                                                         iv_service = `ZPRU_IF_AXC_SERVICE`
                                                         iv_context = zpru_if_agent_frw=>cs_context-standard ) ).

    DATA(lo_utility) = get_utility( ).

    create_execution_header( EXPORTING iv_agent_uuid       = ls_agent-agentuuid
                                       io_axc_service      = lo_axc_service
                             IMPORTING es_execution_header = DATA(ls_execution_header)
                             CHANGING  cs_axc_reported     = cs_axc_reported
                                       cs_axc_failed       = cs_axc_failed
                                       cs_axc_mapped       = cs_axc_mapped ).

    create_execution_query( EXPORTING iv_run_uuid         = ls_execution_header-runuuid
                                      iv_input_query      = mv_input_query
                                      iv_langu            = lv_langu
                                      iv_decision_log     = lv_decision_log
                                      io_axc_service      = lo_axc_service
                                      io_utility          = lo_utility
                            IMPORTING es_execution_query  = DATA(ls_execution_query)
                                      ev_decision_log_msg = DATA(lv_decision_log_msg)
                            CHANGING  cs_axc_reported     = cs_axc_reported
                                      cs_axc_failed       = cs_axc_failed
                                      cs_axc_mapped       = cs_axc_mapped ).

    log_query_to_memory( is_agent            = ls_agent
                         is_execution_header = CORRESPONDING #( ls_execution_header )
                         is_execution_query  = ls_execution_query
                         iv_input_query      = mv_input_query
                         iv_decision_log_msg = lv_decision_log_msg
                         iv_stage            = 'BUILD_EXECUTION'
                         io_short_memory     = lo_short_memory ).

    construct_execution_steps( EXPORTING it_agent_tools      = lt_agent_tools
                                         is_agent            = ls_agent
                                         is_execution_header = CORRESPONDING #( ls_execution_header )
                                         is_execution_query  = CORRESPONDING #( ls_execution_query )
                                         iv_first_tool_input = lv_first_tool_input
                                         io_short_memory     = lo_short_memory
                                         iv_stage            = 'BUILD_EXECUTION'
                                         iv_count            = 4
                               CHANGING  ct_execution_plan   = lt_execution_plan
                                         cs_axc_reported     = cs_axc_reported
                                         cs_axc_failed       = cs_axc_failed ).

    ev_built_run_uuid = ls_execution_header-runuuid.
    ev_built_query_uuid = ls_execution_query-queryuuid.
  ENDMETHOD.

  METHOD zpru_if_api_agent~setup_agent.
    CLEAR: es_agent,
           et_tools.

    IF iv_agent_name IS INITIAL.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    clear_internal_state( ).

    assign_controller_context( io_parent_controller ).

    fetch_agent_configuration( EXPORTING iv_agent_name = iv_agent_name
                               IMPORTING es_agent      = es_agent
                                         eo_service    = DATA(lo_adf_service)
                                         et_agent_k    = DATA(lt_agent_k)
                               CHANGING  cs_reported   = cs_adf_reported
                                         cs_failed     = cs_adf_failed ).

    ensure_agent_is_active( EXPORTING is_agent    = es_agent
                                      io_service  = lo_adf_service
                            CHANGING  cs_reported = cs_adf_reported
                                      cs_failed   = cs_adf_failed ).

    identify_available_tools( EXPORTING it_agent_k  = lt_agent_k
                                        io_service  = lo_adf_service
                              IMPORTING et_tools    = et_tools
                              CHANGING  cs_reported = cs_adf_reported
                                        cs_failed   = cs_adf_failed ).

    prepare_memory_provider( EXPORTING iv_agent_uuid   = es_agent-agentuuid
                             IMPORTING eo_short_memory = DATA(lo_short_memory)
                             CHANGING  cs_reported     = cs_adf_reported
                                       cs_failed       = cs_adf_failed ).

    record_initialization_event( is_agent        = es_agent
                                 it_tools        = et_tools
                                 io_short_memory = lo_short_memory ).
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

    IF    ls_execution_query-querystatus = zpru_if_axc_type_and_constant=>sc_query_status-new
       OR ls_execution_query-querystatus = zpru_if_axc_type_and_constant=>sc_query_status-complete.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    attach_run_2_controller( is_execution_header = ls_execution_header
                             is_execution_query  = ls_execution_query
                             io_controller       = get_controller( ) ).

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

    detach_run_from_controller( io_controller = get_controller( ) ).

    prepare_controller_4_return( IMPORTING eo_executed_controller = eo_executed_controller ).
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

    IF ls_execution_query-querystatus = zpru_if_axc_type_and_constant=>sc_query_status-complete.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    ASSIGN lt_execution_steps[ stepuuid = iv_starting_step_uuid ] TO FIELD-SYMBOL(<ls_step_2_start>).
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    LOOP AT lt_execution_steps TRANSPORTING NO FIELDS
         WHERE stepsequence < <ls_step_2_start>-stepsequence.
      EXIT.
    ENDLOOP.
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    IF <ls_step_2_start>-stepstatus = zpru_if_axc_type_and_constant=>sc_step_status-complete.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    LOOP AT lt_execution_steps ASSIGNING FIELD-SYMBOL(<ls_step_2_exec>)
         WHERE stepsequence >= <ls_step_2_start>-stepsequence.
      APPEND INITIAL LINE TO lt_valid_steps ASSIGNING FIELD-SYMBOL(<ls_valid_step>).
      <ls_valid_step> = <ls_step_2_exec>.

      CLEAR <ls_valid_step>-stepinputprompt.
      CLEAR <ls_valid_step>-stepoutputresponse.

      IF     iv_new_step_prompt       IS NOT INITIAL
         AND <ls_valid_step>-stepuuid  = iv_starting_step_uuid.
        <ls_valid_step>-stepinputprompt = iv_new_step_prompt.
      ENDIF.

    ENDLOOP.

    IF lt_valid_steps IS INITIAL.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    attach_run_2_controller( is_execution_header = ls_execution_header
                             is_execution_query  = ls_execution_query
                             io_controller       = get_controller( ) ).

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

    detach_run_from_controller( io_controller = get_controller( ) ).

    prepare_controller_4_return( IMPORTING eo_executed_controller = eo_executed_controller ).
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

    IF    ls_execution_query-querystatus = zpru_if_axc_type_and_constant=>sc_query_status-complete
       OR ls_execution_query-querystatus = zpru_if_axc_type_and_constant=>sc_query_status-error.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    attach_run_2_controller( is_execution_header = ls_execution_header
                             is_execution_query  = ls_execution_query
                             io_controller       = get_controller( ) ).

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

    detach_run_from_controller( io_controller = get_controller( ) ).

    prepare_controller_4_return( IMPORTING eo_executed_controller = eo_executed_controller ).
  ENDMETHOD.

  METHOD zpru_if_api_agent~set_input_query.
    IF    is_input_query IS INITIAL
       OR iv_agent_uuid  IS INITIAL.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    fetch_agent_definition_by_uuid( EXPORTING iv_agent_uuid = iv_agent_uuid
                                    IMPORTING es_agent      = DATA(ls_agent)
                                              eo_service    = DATA(lo_adf_service)
                                    CHANGING  cs_reported   = cs_adf_reported
                                              cs_failed     = cs_adf_failed ).

    ensure_agent_is_active( EXPORTING is_agent    = ls_agent
                                      io_service  = lo_adf_service
                            CHANGING  cs_reported = cs_adf_reported
                                      cs_failed   = cs_adf_failed ).

    update_query_internal_state( is_input_query ).

    append_query_to_controller( ).

    prepare_memory_provider( EXPORTING iv_agent_uuid   = iv_agent_uuid
                             IMPORTING eo_short_memory = DATA(lo_short_memory)
                             CHANGING  cs_reported     = cs_adf_reported
                                       cs_failed       = cs_adf_failed ).

    record_query_event( is_agent        = ls_agent
                        io_short_memory = lo_short_memory ).
  ENDMETHOD.

  METHOD get_short_memory.
    DATA lo_discard_strategy TYPE REF TO zpru_if_discard_strategy.
    DATA lo_summary_strategy TYPE REF TO zpru_if_summarization.
    DATA lo_agty_service     TYPE REF TO zpru_if_agty_service.

    IF mo_short_memory IS BOUND.
      eo_short_memory = mo_short_memory.
      RETURN.
    ENDIF.

    IF iv_agent_uuid IS INITIAL.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    fetch_agent_definition_by_uuid( EXPORTING iv_agent_uuid = iv_agent_uuid
                                    IMPORTING es_agent      = DATA(ls_agent)
                                    CHANGING  cs_reported   = cs_reported
                                              cs_failed     = cs_failed ).

    CREATE OBJECT mo_short_memory TYPE (ls_agent-shortmemoryprovider).
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    DATA(lo_controller) = get_controller( ).
    lo_controller->mo_short_memory = mo_short_memory.

    CREATE OBJECT mo_long_memory TYPE (ls_agent-longmemoryprovider).
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    lo_controller->mo_long_memory = mo_long_memory.

    mo_short_memory->set_long_memory( io_long_memory = mo_long_memory ).

    eo_short_memory = mo_short_memory.

    lo_agty_service ?= zpru_cl_agent_service_mngr=>get_service( iv_service = `ZPRU_IF_AGTY_SERVICE`
                                                                iv_context = zpru_if_agent_frw=>cs_context-standard ).

    lo_agty_service->read_agent_type(
      EXPORTING it_agty_read_k = VALUE #( ( agenttype                   = ls_agent-agenttype
                                            control-agenttype           = abap_true
                                            control-shortmemoryvolume   = abap_true
                                            control-discardstrategy     = abap_true
                                            control-summarystrategy     = abap_true
                                            control-maximumnumberofloop = abap_true
                                            control-createdby           = abap_true
                                            control-createdat           = abap_true
                                            control-changedby           = abap_true
                                            control-lastchanged         = abap_true
                                            control-locallastchanged    = abap_true ) )
      IMPORTING et_agty        = DATA(lt_agent_type) ).

    DATA(ls_agent_type) = VALUE #( lt_agent_type[ 1 ] OPTIONAL ).
    IF ls_agent_type IS INITIAL.
      RETURN.
    ENDIF.

    SELECT SINGLE * FROM zpru_disc_strat AS disc
      WHERE disc~discardstrategy = @ls_agent_type-discardstrategy
      INTO @DATA(ls_disc_strat).

    SELECT SINGLE * FROM zpru_summ_strat AS summ
      WHERE summ~summarystrategy = @ls_agent_type-summarystrategy
      INTO @DATA(ls_summ_strat).

    mo_short_memory->set_mem_volume( iv_mem_volume = ls_agent_type-shortmemoryvolume ).

    CREATE OBJECT lo_discard_strategy TYPE (ls_disc_strat-discardprovider).
    IF sy-subrc = 0.
      mo_short_memory->set_discard_strategy( io_discard_strategy = lo_discard_strategy ).
    ELSE.

      lo_discard_strategy ?= zpru_cl_agent_service_mngr=>get_service(
                                 iv_service = `ZPRU_IF_DISCARD_STRATEGY`
                                 iv_context = zpru_if_agent_frw=>cs_context-st_discard_strategy_delete ).

      mo_short_memory->set_discard_strategy( io_discard_strategy = lo_discard_strategy ).
    ENDIF.

    CREATE OBJECT lo_summary_strategy TYPE (ls_summ_strat-summaryprovider).
    IF sy-subrc = 0.
      mo_long_memory->set_summarization( io_summarization = lo_summary_strategy ).
    ELSE.

      lo_summary_strategy ?= zpru_cl_agent_service_mngr=>get_service(
                                 iv_service = `ZPRU_IF_SUMMARIZATION`
                                 iv_context = zpru_if_agent_frw=>cs_context-st_summarize ).

      mo_long_memory->set_summarization( io_summarization = lo_summary_strategy ).
    ENDIF.
  ENDMETHOD.

  METHOD process_execution_steps.
    DATA lo_input            TYPE REF TO zpru_if_payload.
    DATA lo_output           TYPE REF TO zpru_if_payload.
    DATA lo_last_output      TYPE REF TO zpru_if_payload.
    DATA lo_axc_service      TYPE REF TO zpru_if_axc_service.
    DATA lt_query_update_imp TYPE zpru_if_axc_type_and_constant=>tt_query_update_imp.
    DATA lt_step_update_imp  TYPE zpru_if_axc_type_and_constant=>tt_step_update_imp.
    DATA lv_error_flag       TYPE abap_boolean.
    DATA lt_message          TYPE zpru_if_short_memory_provider=>tt_message.
    DATA lv_input_prompt     TYPE string.
    DATA lv_output_prompt    TYPE string.
    DATA lo_short_memory     TYPE REF TO zpru_if_short_memory_provider.

    lo_axc_service ?= zpru_cl_agent_service_mngr=>get_service( iv_service = `ZPRU_IF_AXC_SERVICE`
                                                               iv_context = zpru_if_agent_frw=>cs_context-standard ).

    prepare_memory_provider( EXPORTING iv_agent_uuid   = is_agent-agentuuid
                             IMPORTING eo_short_memory = lo_short_memory
                             CHANGING  cs_reported     = cs_adf_reported
                                       cs_failed       = cs_adf_failed ).

    DATA(lo_controller) = get_controller( ).
    CLEAR lo_controller->mt_run_context.
    lo_controller->mt_execution_steps = it_execution_steps.

    SORT lo_controller->mt_input_output BY number ASCENDING.
    ASSIGN lo_controller->mt_input_output[ number = lines( lo_controller->mt_input_output ) ] TO FIELD-SYMBOL(<ls_input_output>).
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    <ls_input_output>-execution_steps = it_execution_steps.

    DATA(lv_count) = 1.
    LOOP AT it_execution_steps ASSIGNING FIELD-SYMBOL(<ls_execution_step>) USING KEY sequence.

      ASSIGN it_agent_tools[ tooluuid = <ls_execution_step>-tooluuid ] TO FIELD-SYMBOL(<ls_tool_master_data>).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      APPEND INITIAL LINE TO lo_controller->mt_run_context ASSIGNING FIELD-SYMBOL(<ls_run_context>).
      <ls_run_context>-tool_master_data = <ls_tool_master_data>.
      <ls_run_context>-execution_step   = <ls_execution_step>.

      IF lv_count = 1.

        lo_input = get_payload( ).

        lo_input->set_data( ir_data = REF #( <ls_execution_step>-stepinputprompt ) ).
      ELSE.
        IF lv_output_prompt IS NOT INITIAL.
          lo_input->set_data( ir_data = REF #( lv_output_prompt ) ).
        ELSE.
          lo_input->clear_data( ).
        ENDIF.
      ENDIF.

      lv_error_flag = abap_false.

      IF lo_output IS NOT BOUND.
        lo_output = get_payload( ).
      ENDIF.

      execute_tool_logic( EXPORTING is_agent            = is_agent
                                    io_controller       = lo_controller
                                    io_input            = lo_input
                                    is_tool_master_data = <ls_tool_master_data>
                                    is_execution_step   = <ls_execution_step>
                          IMPORTING eo_response         = lo_output
                                    et_key_value_pairs  = DATA(lt_key_value_pairs)
                                    ev_error_flag       = lv_error_flag
                                    et_additional_steps = DATA(lt_additional_steps)
                                    et_additional_tools = DATA(lt_additional_tools) ).

      write_2_data_board( it_key_value_pairs = lt_key_value_pairs
                          io_controller      = lo_controller ).

      IF     lt_additional_steps IS NOT INITIAL
         AND lt_additional_tools IS NOT INITIAL.
        execute_mini_loop(
          EXPORTING
            is_agent            = is_agent
            is_execution_header = is_execution_header
            is_execution_query  = is_execution_query
            it_additional_steps = lt_additional_steps
            it_additional_tools = lt_additional_tools
            is_tool_master_data = <ls_tool_master_data>
            is_current_step     = <ls_execution_step>
            iv_output_prompt    = lo_output->get_data( )->*
          IMPORTING
            eo_final_response   = lo_output
          CHANGING
            cs_axc_reported     = cs_axc_reported
            cs_axc_failed       = cs_axc_failed
            cs_adf_reported     = cs_adf_reported
            cs_adf_failed       = cs_adf_failed ).
      ENDIF.

      lv_input_prompt  = lo_input->get_data( )->*.
      lv_output_prompt = lo_output->get_data( )->*.

      APPEND log_step_execution( is_agent            = is_agent
                                 is_execution_header = is_execution_header
                                 is_execution_query  = is_execution_query
                                 is_execution_step   = <ls_execution_step>
                                 is_tool_master_data = <ls_tool_master_data>
                                 iv_input_prompt     = lv_input_prompt
                                 iv_output_prompt    = lv_output_prompt
                                 iv_error_flag       = lv_error_flag
                                 iv_count            = lv_count ) TO lt_message.

      lv_count += 1.

      GET TIME STAMP FIELD DATA(lv_now).

      IF lv_error_flag = abap_true.
        APPEND INITIAL LINE TO lt_step_update_imp ASSIGNING FIELD-SYMBOL(<ls_step_2_upd>).
        <ls_step_2_upd>-stepuuid           = <ls_execution_step>-stepuuid.
        <ls_step_2_upd>-queryuuid          = <ls_execution_step>-queryuuid.
        <ls_step_2_upd>-runuuid            = <ls_execution_step>-runuuid.
        <ls_step_2_upd>-stepstatus         = zpru_if_axc_type_and_constant=>sc_step_status-error.
        <ls_step_2_upd>-stependdatetime    = lv_now.
        <ls_step_2_upd>-stepinputprompt    = lv_input_prompt.
        <ls_step_2_upd>-stepoutputresponse = lv_output_prompt.
        <ls_step_2_upd>-control-stepstatus         = abap_true.
        <ls_step_2_upd>-control-stependdatetime    = abap_true.
        <ls_step_2_upd>-control-stepinputprompt    = abap_true.
        <ls_step_2_upd>-control-stepoutputresponse = abap_true.

        <ls_run_context>-execution_step-stepstatus         = zpru_if_axc_type_and_constant=>sc_step_status-error.
        <ls_run_context>-execution_step-stependdatetime    = lv_now.
        <ls_run_context>-execution_step-stepinputprompt    = lv_input_prompt.
        <ls_run_context>-execution_step-stepoutputresponse = lv_output_prompt.

        APPEND INITIAL LINE TO lt_query_update_imp ASSIGNING FIELD-SYMBOL(<ls_query_2_upd>).
        <ls_query_2_upd>-queryuuid        = is_execution_query-queryuuid.
        <ls_query_2_upd>-runuuid          = is_execution_query-runuuid.
        <ls_query_2_upd>-querystatus      = zpru_if_axc_type_and_constant=>sc_query_status-error.
        <ls_query_2_upd>-queryenddatetime = lv_now.
        <ls_query_2_upd>-control-querystatus      = abap_true.
        <ls_query_2_upd>-control-queryenddatetime = abap_true.
        EXIT.
      ENDIF.

      APPEND INITIAL LINE TO lt_step_update_imp ASSIGNING <ls_step_2_upd>.
      <ls_step_2_upd>-stepuuid           = <ls_execution_step>-stepuuid.
      <ls_step_2_upd>-queryuuid          = <ls_execution_step>-queryuuid.
      <ls_step_2_upd>-runuuid            = <ls_execution_step>-runuuid.
      <ls_step_2_upd>-stepstatus         = zpru_if_axc_type_and_constant=>sc_step_status-complete.
      <ls_step_2_upd>-stependdatetime    = lv_now.
      <ls_step_2_upd>-stepinputprompt    = lv_input_prompt.
      <ls_step_2_upd>-stepoutputresponse = lv_output_prompt.
      <ls_step_2_upd>-control-stepstatus         = abap_true.
      <ls_step_2_upd>-control-stependdatetime    = abap_true.
      <ls_step_2_upd>-control-stepinputprompt    = abap_true.
      <ls_step_2_upd>-control-stepoutputresponse = abap_true.

      <ls_run_context>-execution_step-stepstatus         = zpru_if_axc_type_and_constant=>sc_step_status-complete.
      <ls_run_context>-execution_step-stependdatetime    = lv_now.
      <ls_run_context>-execution_step-stepinputprompt    = lv_input_prompt.
      <ls_run_context>-execution_step-stepoutputresponse = lv_output_prompt.

      IF lo_controller->mv_stop_agent = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.

    <ls_input_output>-run_context = lo_controller->mt_run_context.

    DATA(lv_last_output) = lv_output_prompt.

    lo_last_output = get_payload( ).

    lo_last_output->set_data( ir_data = NEW string( lv_last_output ) ).

    IF lt_message IS NOT INITIAL.
      lo_short_memory->save_message( it_message    = lt_message
                                     io_controller = get_controller( ) ).
    ENDIF.

    IF lt_step_update_imp IS NOT INITIAL.
      lo_axc_service->update_step( EXPORTING it_step_update_imp = lt_step_update_imp
                                   CHANGING  cs_reported        = cs_axc_reported
                                             cs_failed          = cs_axc_failed ).
    ENDIF.

    IF lv_error_flag = abap_true.
      IF lt_query_update_imp IS NOT INITIAL.
        lo_axc_service->update_query( EXPORTING it_query_update_imp = lt_query_update_imp
                                      CHANGING  cs_reported         = cs_axc_reported
                                                cs_failed           = cs_axc_failed ).
      ENDIF.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ELSE.
      finalize_successful_query( EXPORTING is_agent            = is_agent
                                           is_execution_header = is_execution_header
                                           is_execution_query  = is_execution_query
                                           io_last_output      = lo_last_output
                                           io_short_memory     = lo_short_memory
                                           io_controller       = lo_controller
                                 IMPORTING eo_final_response   = eo_final_response
                                 CHANGING  cs_axc_reported     = cs_axc_reported
                                           cs_axc_failed       = cs_axc_failed
                                           cs_adf_reported     = cs_adf_reported
                                           cs_adf_failed       = cs_adf_failed ).
    ENDIF.
  ENDMETHOD.

  METHOD prepare_execution.
    DATA lv_query_to_run     TYPE sysuuid_x16.
    DATA lo_axc_service      TYPE REF TO zpru_if_axc_service.
    DATA ls_execution_header TYPE zpru_s_axc_head.
    DATA ls_execution_query  TYPE zpru_s_axc_query.
    DATA lo_adf_service      TYPE REF TO zpru_if_adf_service.

    CLEAR: et_agent_tools,
           et_execution_steps,
           es_execution_query,
           es_agent,
           es_execution_header.

    IF iv_run_uuid IS INITIAL.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    lo_axc_service ?= zpru_cl_agent_service_mngr=>get_service( iv_service = `ZPRU_IF_AXC_SERVICE`
                                                               iv_context = zpru_if_agent_frw=>cs_context-standard ).

    lo_axc_service->read_header( EXPORTING it_head_read_k = VALUE #( ( runuuid = iv_run_uuid
                                                                       control = VALUE #(
                                                                           runuuid          = abap_true
                                                                           runid            = abap_true
                                                                           agentuuid        = abap_true
                                                                           userid           = abap_true
                                                                           runstartdatetime = abap_true
                                                                           runenddatetime   = abap_true
                                                                           createdby        = abap_true
                                                                           createdat        = abap_true
                                                                           changedby        = abap_true
                                                                           lastchanged      = abap_true
                                                                           locallastchanged = abap_true ) ) )
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

      lv_query_to_run = VALUE #( lt_query_to_read[ 1 ]-queryuuid OPTIONAL ).
    ELSE.
      lv_query_to_run = iv_query_uuid.
    ENDIF.

    lo_axc_service->read_query( EXPORTING it_query_read_k = VALUE #( ( queryuuid = lv_query_to_run
                                                                       control   = VALUE #(
                                                                           runuuid             = abap_true
                                                                           querynumber         = abap_true
                                                                           queryuuid           = abap_true
                                                                           querylanguage       = abap_true
                                                                           querystatus         = abap_true
                                                                           querystartdatetime  = abap_true
                                                                           queryenddatetime    = abap_true
                                                                           queryinputprompt    = abap_true
                                                                           querydecisionlog    = abap_true
                                                                           queryoutputresponse = abap_true ) ) )
                                IMPORTING et_axc_query    = DATA(lt_axc_query)
                                CHANGING  cs_reported     = cs_axc_reported
                                          cs_failed       = cs_axc_failed ).

    ASSIGN lt_axc_query[ 1 ] TO FIELD-SYMBOL(<ls_execution_query>).
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    ls_execution_query = <ls_execution_query>.
    es_execution_query = ls_execution_query.

    lo_axc_service->rba_step(
      EXPORTING it_rba_step_k = VALUE #( ( queryuuid = ls_execution_query-queryuuid
                                           control   = VALUE #( stepuuid           = abap_true
                                                                stepnumber         = abap_true
                                                                queryuuid          = abap_true
                                                                runuuid            = abap_true
                                                                tooluuid           = abap_true
                                                                stepsequence       = abap_true
                                                                stepstatus         = abap_true
                                                                stepstartdatetime  = abap_true
                                                                stependdatetime    = abap_true
                                                                stepinputprompt    = abap_true
                                                                stepoutputresponse = abap_true ) ) )
      IMPORTING et_axc_step   = DATA(lt_execution_steps)
      CHANGING  cs_reported   = cs_axc_reported
                cs_failed     = cs_axc_failed ).

    IF    ls_execution_header IS INITIAL
       OR ls_execution_query  IS INITIAL
       OR lt_execution_steps  IS INITIAL.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    fetch_agent_definition_by_uuid( EXPORTING iv_agent_uuid = ls_execution_header-agentuuid
                                    IMPORTING es_agent      = es_agent
                                              eo_service    = lo_adf_service
                                    CHANGING  cs_reported   = cs_adf_reported
                                              cs_failed     = cs_adf_failed ).

    IF es_agent-agentstatus <> zpru_if_adf_type_and_constant=>cs_agent_status-active.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    lo_adf_service->rba_tool( EXPORTING it_rba_tool_k = VALUE #( ( agentuuid                  = es_agent-agentuuid
                                                                   control-tooluuid           = abap_true
                                                                   control-agentuuid          = abap_true
                                                                   control-toolname           = abap_true
                                                                   control-toolprovider       = abap_true
                                                                   control-steptype           = abap_true
                                                                   control-toolschemaprovider = abap_true
                                                                   control-toolinfoprovider   = abap_true
                                                                   control-toolisborrowed     = abap_true
                                                                   control-toolistransient    = abap_true    ) )
                              IMPORTING et_tool       = DATA(lt_agent_tools)
                              CHANGING  cs_reported   = cs_adf_reported
                                        cs_failed     = cs_adf_failed ).

    et_agent_tools = lt_agent_tools.
    et_execution_steps = lt_execution_steps.
    SORT et_execution_steps BY stepsequence ASCENDING.
  ENDMETHOD.

  METHOD zpru_if_api_agent~add_query_2_run.
    DATA lo_axc_service      TYPE REF TO zpru_if_axc_service.
    DATA lt_execution_plan   TYPE zpru_if_decision_provider=>tt_execution_plan.
    DATA lv_first_tool_input TYPE zpru_if_agent_frw=>ts_json.
    DATA lv_langu            TYPE sylangu.
    DATA lv_decision_log     TYPE zpru_if_agent_frw=>ts_json.

    CLEAR ev_run_uuid.
    CLEAR ev_query_uuid.

    IF    iv_run_uuid    IS INITIAL
       OR is_input_query IS INITIAL.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    lo_axc_service ?= zpru_cl_agent_service_mngr=>get_service( iv_service = `ZPRU_IF_AXC_SERVICE`
                                                               iv_context = zpru_if_agent_frw=>cs_context-standard ).

    DATA(lo_utility) = get_utility( ).

    load_execution_header( EXPORTING iv_run_uuid         = iv_run_uuid
                                     io_axc_service      = lo_axc_service
                           IMPORTING es_execution_header = DATA(ls_execution_header)
                           CHANGING  cs_axc_reported     = cs_axc_reported
                                     cs_axc_failed       = cs_axc_failed ).

    setup_agent_context( EXPORTING iv_agent_uuid             = ls_execution_header-agentuuid
                         IMPORTING es_agent                  = DATA(ls_agent)
                                   et_agent_tools            = DATA(lt_agent_tools)
                                   eo_decision_provider      = DATA(lo_decision_provider)
                                   eo_short_memory           = DATA(lo_short_memory)
                                   eo_long_memory            = DATA(lo_long_memory)
                                   eo_agent_info_provider    = DATA(lo_agent_info_provider)
                                   eo_system_prompt_provider = DATA(lo_system_prompt_provider)
                         CHANGING  cs_adf_reported           = cs_adf_reported
                                   cs_adf_failed             = cs_adf_failed ).

    DATA(lo_controller) = initialize_run_controller( ls_agent-agentuuid ).

    IF io_parent_controller IS BOUND.
      assign_controller_context( io_parent_controller ).
    ENDIF.

    update_query_internal_state( is_input_query = is_input_query ).

    append_query_to_controller( ).

    process_decision_engine( EXPORTING is_agent                  = ls_agent
                                       it_agent_tools            = lt_agent_tools
                                       io_controller             = lo_controller
                                       iv_input_query            = is_input_query-string_content
                                       is_input_prompt           = is_input_query
                                       io_decision_provider      = lo_decision_provider
                                       io_system_prompt_provider = lo_system_prompt_provider
                                       io_short_memory           = lo_short_memory
                                       io_long_memory            = lo_long_memory
                                       io_agent_info_provider    = lo_agent_info_provider
                                       iv_stage                  = 'ADD_QUERY_2_RUN'
                             IMPORTING eo_execution_plan         = DATA(lo_execution_plan)
                                       eo_first_tool_input       = DATA(lo_first_tool_input)
                                       eo_langu                  = DATA(lo_langu)
                                       eo_decision_log           = DATA(lo_decision_log) ).

    IF lo_execution_plan IS BOUND.
      lt_execution_plan = lo_execution_plan->get_data( )->*.
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

    create_execution_query( EXPORTING iv_run_uuid         = ls_execution_header-runuuid
                                      iv_input_query      = is_input_query-string_content
                                      iv_langu            = lv_langu
                                      iv_decision_log     = lv_decision_log
                                      io_axc_service      = lo_axc_service
                                      io_utility          = lo_utility
                            IMPORTING es_execution_query  = DATA(ls_execution_query)
                                      ev_decision_log_msg = DATA(lv_decision_log_msg)
                            CHANGING  cs_axc_reported     = cs_axc_reported
                                      cs_axc_failed       = cs_axc_failed
                                      cs_axc_mapped       = cs_axc_mapped ).

    log_query_to_memory( is_agent            = ls_agent
                         is_execution_header = ls_execution_header
                         is_execution_query  = ls_execution_query
                         iv_input_query      = is_input_query-string_content
                         iv_decision_log_msg = lv_decision_log_msg
                         iv_stage            = 'ADD_QUERY_2_RUN'
                         io_short_memory     = lo_short_memory ).

    construct_execution_steps( EXPORTING it_agent_tools      = lt_agent_tools
                                         is_agent            = ls_agent
                                         is_execution_header = ls_execution_header
                                         is_execution_query  = CORRESPONDING #( ls_execution_query )
                                         iv_first_tool_input = lv_first_tool_input
                                         io_short_memory     = lo_short_memory
                                         iv_stage            = 'ADD_QUERY_2_RUN'
                                         iv_count            = 4
                               CHANGING  ct_execution_plan   = lt_execution_plan
                                         cs_axc_reported     = cs_axc_reported
                                         cs_axc_failed       = cs_axc_failed ).

    ev_run_uuid   = ls_execution_header-runuuid.
    ev_query_uuid = ls_execution_query-queryuuid.
  ENDMETHOD.

  METHOD get_long_memory.
    IF iv_agent_uuid IS INITIAL.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    prepare_memory_provider( EXPORTING iv_agent_uuid   = iv_agent_uuid
                             IMPORTING eo_short_memory = DATA(lo_short_memory)
                             CHANGING  cs_reported     = cs_reported
                                       cs_failed       = cs_failed ).

    IF lo_short_memory IS NOT BOUND.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    eo_long_memory = lo_short_memory->get_long_memory( ).
  ENDMETHOD.

  METHOD get_controller.
    IF mo_controller IS BOUND.
      ro_controller = mo_controller.
      RETURN.
    ENDIF.

    mo_controller ?= zpru_cl_agent_service_mngr=>get_service( iv_service = `ZPRU_IF_AGENT_CONTROLLER`
                                                              iv_context = zpru_if_agent_frw=>cs_context-standard ).

    mo_controller->mo_api_agent = me.
    ro_controller = mo_controller.
  ENDMETHOD.

  METHOD execute_mini_loop.
    DATA lo_input            TYPE REF TO zpru_if_payload.
    DATA lo_output           TYPE REF TO zpru_if_payload.
    DATA lo_last_output      TYPE REF TO zpru_if_payload.
    DATA lo_axc_service      TYPE REF TO zpru_if_axc_service.
    DATA lt_query_update_imp TYPE zpru_if_axc_type_and_constant=>tt_query_update_imp.
    DATA lt_step_update_imp  TYPE zpru_if_axc_type_and_constant=>tt_step_update_imp.
    DATA lt_step_create_imp  TYPE zpru_if_axc_type_and_constant=>tt_step_create_imp.
    DATA lv_error_flag       TYPE abap_boolean.
    DATA lt_message          TYPE zpru_if_short_memory_provider=>tt_message.
    DATA lv_input_prompt     TYPE string.
    DATA lv_output_prompt    TYPE string.
    DATA lo_short_memory     TYPE REF TO zpru_if_short_memory_provider.
    DATA ls_mapped           TYPE zpru_if_agent_frw=>ts_axc_mapped.

    DATA(lo_controller) = get_controller( ).

    IF is_execute_miniloop( io_controller = lo_controller
                            is_agent      = is_agent ) = abap_false.
      RETURN.
    ENDIF.

    lo_axc_service ?= zpru_cl_agent_service_mngr=>get_service( iv_service = `ZPRU_IF_AXC_SERVICE`
                                                               iv_context = zpru_if_agent_frw=>cs_context-standard ).

    prepare_memory_provider( EXPORTING iv_agent_uuid   = is_agent-agentuuid
                             IMPORTING eo_short_memory = lo_short_memory
                             CHANGING  cs_reported     = cs_adf_reported
                                       cs_failed       = cs_adf_failed ).

    DATA(lt_step_all) = lo_controller->mt_execution_steps.
    DELETE lt_step_all WHERE stepsequence > is_current_step-stepsequence.
    DATA(lt_step_after) = lo_controller->mt_execution_steps.
    DELETE lt_step_after WHERE stepsequence <= is_current_step-stepsequence.

    resequence_steps( EXPORTING it_additional_steps         = it_additional_steps
                                is_execution_header         = is_execution_header
                                is_execution_query          = is_execution_query
                                iv_output_prompt            = iv_output_prompt
                      IMPORTING et_map_tempuuid_2_finaluuid = DATA(lt_map_tempuuid_2_finaluuid)
                      CHANGING  ct_step_all                 = lt_step_all
                                ct_step_after               = lt_step_after
                                ct_step_update_imp          = lt_step_update_imp
                                ct_step_create_imp          = lt_step_create_imp ).

    IF lt_step_update_imp IS NOT INITIAL.
      lo_axc_service->update_step( EXPORTING it_step_update_imp = lt_step_update_imp
                                   CHANGING  cs_reported        = cs_axc_reported
                                             cs_failed          = cs_axc_failed ).
    ENDIF.

    IF lt_step_create_imp IS INITIAL.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    lo_axc_service->cba_step( EXPORTING it_axc_step_imp = lt_step_create_imp
                              CHANGING  cs_reported     = cs_axc_reported
                                        cs_failed       = cs_axc_failed
                                        cs_mapped       = ls_mapped ).

    lo_axc_service->read_step( EXPORTING it_step_read_k = VALUE #( FOR <ls_s> IN ls_mapped-step
                                                                   ( stepuuid                   = <ls_s>-stepuuid
                                                                     control-stepuuid           = abap_true
                                                                     control-stepnumber         = abap_true
                                                                     control-queryuuid          = abap_true
                                                                     control-runuuid            = abap_true
                                                                     control-tooluuid           = abap_true
                                                                     control-stepsequence       = abap_true
                                                                     control-stepstatus         = abap_true
                                                                     control-stepstartdatetime  = abap_true
                                                                     control-stependdatetime    = abap_true
                                                                     control-stepinputprompt    = abap_true
                                                                     control-stepoutputresponse = abap_true ) )
                               IMPORTING et_axc_step    = DATA(lt_new_steps)
                               CHANGING  cs_reported    = cs_axc_reported
                                         cs_failed      = cs_axc_failed ).

    LOOP AT lt_new_steps ASSIGNING FIELD-SYMBOL(<ls_new_step>).

      ASSIGN lt_step_all[ KEY sequence COMPONENTS stepsequence = <ls_new_step>-stepsequence ] TO FIELD-SYMBOL(<ls_step_all>).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      <ls_step_all>-stepuuid   = <ls_new_step>-stepuuid.
      <ls_step_all>-stepnumber = <ls_new_step>-stepnumber.

      ASSIGN lt_map_tempuuid_2_finaluuid[ stepsequence = <ls_step_all>-stepsequence ] TO FIELD-SYMBOL(<ls_map_tempuuid_2_finaluuid>).
      <ls_map_tempuuid_2_finaluuid>-final_uuid = <ls_new_step>-stepuuid.

    ENDLOOP.

    CLEAR lt_step_update_imp.

    lo_controller->mt_execution_steps = lt_step_all.

    ASSIGN lo_controller->mt_input_output[ number = lines( lo_controller->mt_input_output ) ] TO FIELD-SYMBOL(<ls_input_output>).
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    <ls_input_output>-execution_steps = lt_step_all.

    DATA(lv_count) = 1.
    LOOP AT it_additional_steps ASSIGNING FIELD-SYMBOL(<ls_additional_step>) USING KEY sequence.

      ASSIGN it_additional_tools[ tooluuid = <ls_additional_step>-tooluuid ] TO FIELD-SYMBOL(<ls_additional_tool>).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      ASSIGN lt_map_tempuuid_2_finaluuid[ temp_uuid = <ls_additional_step>-stepuuid ] TO <ls_map_tempuuid_2_finaluuid>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      ASSIGN lt_new_steps[ stepuuid = <ls_map_tempuuid_2_finaluuid>-final_uuid ] TO <ls_new_step>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      APPEND INITIAL LINE TO lo_controller->mt_run_context ASSIGNING FIELD-SYMBOL(<ls_run_context>).
      <ls_run_context>-tool_master_data = <ls_additional_tool>.
      <ls_run_context>-execution_step   = <ls_new_step>.

      IF lv_count = 1.

        lo_input = get_payload( ).

        lo_input->set_data( ir_data = REF #( iv_output_prompt ) ).

        lo_output = get_payload( ).

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

      IF lo_output IS NOT BOUND.
        lo_output = get_payload( ).
      ENDIF.

      execute_tool_logic( EXPORTING is_agent            = is_agent
                                    io_controller       = lo_controller
                                    io_input            = lo_input
                                    is_tool_master_data = <ls_additional_tool>
                                    is_execution_step   = <ls_new_step>
                          IMPORTING eo_response         = lo_output
                                    et_key_value_pairs  = DATA(lt_key_value_pairs)
                                    ev_error_flag       = lv_error_flag
                                    et_additional_steps = DATA(lt_additional_steps)
                                    et_additional_tools = DATA(lt_additional_tools) ).

      write_2_data_board( it_key_value_pairs = lt_key_value_pairs
                          io_controller      = lo_controller ).

      IF     lt_additional_steps IS NOT INITIAL
         AND lt_additional_tools IS NOT INITIAL.
        execute_mini_loop(
          EXPORTING
            is_agent            = is_agent
            is_execution_header = is_execution_header
            is_execution_query  = is_execution_query
            it_additional_steps = lt_additional_steps
            it_additional_tools = lt_additional_tools
            is_tool_master_data = <ls_additional_tool>
            is_current_step     = <ls_new_step>
            iv_output_prompt    = lo_output->get_data( )->*
          IMPORTING
            eo_final_response   = lo_output
          CHANGING
            cs_axc_reported     = cs_axc_reported
            cs_axc_failed       = cs_axc_failed
            cs_adf_reported     = cs_adf_reported
            cs_adf_failed       = cs_adf_failed ).
      ENDIF.

      lv_input_prompt  = lo_input->get_data( )->*.
      lv_output_prompt = lo_output->get_data( )->*.

      APPEND log_step_execution( is_agent            = is_agent
                                 is_execution_header = is_execution_header
                                 is_execution_query  = is_execution_query
                                 is_execution_step   = <ls_new_step>
                                 is_tool_master_data = <ls_additional_tool>
                                 iv_input_prompt     = lv_input_prompt
                                 iv_output_prompt    = lv_output_prompt
                                 iv_error_flag       = lv_error_flag
                                 iv_count            = lv_count ) TO lt_message.

      lv_count += 1.

      IF lv_error_flag = abap_true.
        APPEND INITIAL LINE TO lt_step_update_imp ASSIGNING FIELD-SYMBOL(<ls_step_2_upd>).
        <ls_step_2_upd>-stepuuid           = <ls_new_step>-stepuuid.
        <ls_step_2_upd>-queryuuid          = <ls_new_step>-queryuuid.
        <ls_step_2_upd>-runuuid            = <ls_new_step>-runuuid.
        <ls_step_2_upd>-stepstatus         = zpru_if_axc_type_and_constant=>sc_step_status-error.
        <ls_step_2_upd>-stependdatetime    = lv_now.
        <ls_step_2_upd>-stepinputprompt    = lv_input_prompt.
        <ls_step_2_upd>-stepoutputresponse = lv_output_prompt.
        <ls_step_2_upd>-control-stepstatus         = abap_true.
        <ls_step_2_upd>-control-stependdatetime    = abap_true.
        <ls_step_2_upd>-control-stepinputprompt    = abap_true.
        <ls_step_2_upd>-control-stepoutputresponse = abap_true.

        <ls_run_context>-execution_step-stepstatus         = zpru_if_axc_type_and_constant=>sc_step_status-error.
        <ls_run_context>-execution_step-stependdatetime    = lv_now.
        <ls_run_context>-execution_step-stepinputprompt    = lv_input_prompt.
        <ls_run_context>-execution_step-stepoutputresponse = lv_output_prompt.

        APPEND INITIAL LINE TO lt_query_update_imp ASSIGNING FIELD-SYMBOL(<ls_query_2_upd>).
        <ls_query_2_upd>-queryuuid        = is_execution_query-queryuuid.
        <ls_query_2_upd>-runuuid          = is_execution_query-runuuid.
        <ls_query_2_upd>-querystatus      = zpru_if_axc_type_and_constant=>sc_query_status-error.
        <ls_query_2_upd>-queryenddatetime = lv_now.
        <ls_query_2_upd>-control-querystatus      = abap_true.
        <ls_query_2_upd>-control-queryenddatetime = abap_true.

        EXIT.
      ENDIF.

      APPEND INITIAL LINE TO lt_step_update_imp ASSIGNING <ls_step_2_upd>.
      <ls_step_2_upd>-stepuuid           = <ls_new_step>-stepuuid.
      <ls_step_2_upd>-queryuuid          = <ls_new_step>-queryuuid.
      <ls_step_2_upd>-runuuid            = <ls_new_step>-runuuid.
      <ls_step_2_upd>-stepstatus         = zpru_if_axc_type_and_constant=>sc_step_status-complete.
      <ls_step_2_upd>-stependdatetime    = lv_now.
      <ls_step_2_upd>-stepinputprompt    = lv_input_prompt.
      <ls_step_2_upd>-stepoutputresponse = lv_output_prompt.
      <ls_step_2_upd>-control-stepstatus         = abap_true.
      <ls_step_2_upd>-control-stependdatetime    = abap_true.
      <ls_step_2_upd>-control-stepinputprompt    = abap_true.
      <ls_step_2_upd>-control-stepoutputresponse = abap_true.

      <ls_run_context>-execution_step-stepstatus         = zpru_if_axc_type_and_constant=>sc_step_status-complete.
      <ls_run_context>-execution_step-stependdatetime    = lv_now.
      <ls_run_context>-execution_step-stepinputprompt    = lv_input_prompt.
      <ls_run_context>-execution_step-stepoutputresponse = lv_output_prompt.

      IF lo_controller->mv_stop_agent = abap_true.
        EXIT.
      ENDIF.

    ENDLOOP.

    <ls_input_output>-run_context = lo_controller->mt_run_context.

    DATA(lv_last_output) = lv_output_prompt.

    lo_last_output = get_payload( ).

    lo_last_output->set_data( ir_data = NEW string( lv_last_output ) ).

    IF lt_message IS NOT INITIAL.
      lo_short_memory->save_message( it_message    = lt_message
                                     io_controller = get_controller( ) ).
    ENDIF.

    IF lt_step_update_imp IS NOT INITIAL.
      lo_axc_service->update_step( EXPORTING it_step_update_imp = lt_step_update_imp
                                   CHANGING  cs_reported        = cs_axc_reported
                                             cs_failed          = cs_axc_failed ).
    ENDIF.

    IF lv_error_flag = abap_true.
      IF lt_query_update_imp IS NOT INITIAL.
        lo_axc_service->update_query( EXPORTING it_query_update_imp = lt_query_update_imp
                                      CHANGING  cs_reported         = cs_axc_reported
                                                cs_failed           = cs_axc_failed ).

      ENDIF.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ELSE.
      eo_final_response = lo_last_output.
    ENDIF.
  ENDMETHOD.

  METHOD execute_tool_logic.
    DATA lo_tool_provider TYPE REF TO zpru_if_tool_provider.
    DATA lo_executor      TYPE REF TO zpru_if_tool_executor.

    CLEAR: et_additional_steps,
           et_additional_tools,
           et_key_value_pairs,
           ev_error_flag.

    CREATE OBJECT lo_tool_provider TYPE (is_tool_master_data-toolprovider).
    lo_executor = lo_tool_provider->get_tool( is_agent            = is_agent
                                              io_controller       = io_controller
                                              io_input            = io_input
                                              is_tool_master_data = is_tool_master_data
                                              is_execution_step   = is_execution_step ).

    CASE is_tool_master_data-steptype.
      WHEN zpru_if_adf_type_and_constant=>cs_step_type-abap_code.
        CAST zpru_if_abap_executor( lo_executor )->execute_code( EXPORTING io_controller       = io_controller
                                                                           io_request          = io_input
                                                                           is_agent            = is_agent
                                                                           is_tool_master_data = is_tool_master_data
                                                                           is_execution_step   = is_execution_step
                                                                 IMPORTING eo_response         = eo_response
                                                                           et_key_value_pairs  = et_key_value_pairs
                                                                           ev_error_flag       = ev_error_flag
                                                                           et_additional_steps = et_additional_steps
                                                                           et_additional_tools = et_additional_tools ).

      WHEN zpru_if_adf_type_and_constant=>cs_step_type-knowledge_source.
        CAST zpru_if_knowledge_provider( lo_executor )->lookup_knowledge(
                                                       EXPORTING io_controller       = io_controller
                                                                 io_request          = io_input
                                                                 is_agent            = is_agent
                                                                 is_tool_master_data = is_tool_master_data
                                                                 is_execution_step   = is_execution_step
                                                       IMPORTING eo_response         = eo_response
                                                                 et_key_value_pairs  = et_key_value_pairs
                                                                 ev_error_flag       = ev_error_flag
                                                                 et_additional_steps = et_additional_steps
                                                                 et_additional_tools = et_additional_tools ).

      WHEN zpru_if_adf_type_and_constant=>cs_step_type-nested_agent.
        CAST zpru_if_nested_agent_runner( lo_executor )->run_nested_agent(
                                                        EXPORTING io_controller       = io_controller
                                                                  io_request          = io_input
                                                                  is_agent            = is_agent
                                                                  is_tool_master_data = is_tool_master_data
                                                                  is_execution_step   = is_execution_step
                                                        IMPORTING eo_response         = eo_response
                                                                  et_key_value_pairs  = et_key_value_pairs
                                                                  ev_error_flag       = ev_error_flag
                                                                  et_additional_steps = et_additional_steps
                                                                  et_additional_tools = et_additional_tools ).

      WHEN zpru_if_adf_type_and_constant=>cs_step_type-http_request.
        CAST zpru_if_http_request_sender( lo_executor )->send_http(
                                                        EXPORTING io_controller       = io_controller
                                                                  io_request          = io_input
                                                                  is_agent            = is_agent
                                                                  is_tool_master_data = is_tool_master_data
                                                                  is_execution_step   = is_execution_step
                                                        IMPORTING eo_response         = eo_response
                                                                  et_key_value_pairs  = et_key_value_pairs
                                                                  ev_error_flag       = ev_error_flag
                                                                  et_additional_steps = et_additional_steps
                                                                  et_additional_tools = et_additional_tools ).

      WHEN zpru_if_adf_type_and_constant=>cs_step_type-service_consumption_model.
        CAST zpru_if_service_model_consumer( lo_executor )->consume_service_model(
                                                           EXPORTING io_controller       = io_controller
                                                                     io_request          = io_input
                                                                     is_agent            = is_agent
                                                                     is_tool_master_data = is_tool_master_data
                                                                     is_execution_step   = is_execution_step
                                                           IMPORTING eo_response         = eo_response
                                                                     et_key_value_pairs  = et_key_value_pairs
                                                                     ev_error_flag       = ev_error_flag
                                                                     et_additional_steps = et_additional_steps
                                                                     et_additional_tools = et_additional_tools ).

      WHEN zpru_if_adf_type_and_constant=>cs_step_type-call_llm.
        CAST zpru_if_llm_caller( lo_executor )->call_large_language_model(
                                               EXPORTING io_controller       = io_controller
                                                         io_request          = io_input
                                                         is_agent            = is_agent
                                                         is_tool_master_data = is_tool_master_data
                                                         is_execution_step   = is_execution_step
                                               IMPORTING eo_response         = eo_response
                                                         et_key_value_pairs  = et_key_value_pairs
                                                         ev_error_flag       = ev_error_flag
                                                         et_additional_steps = et_additional_steps
                                                         et_additional_tools = et_additional_tools ).

      WHEN zpru_if_adf_type_and_constant=>cs_step_type-dynamic_abap_code.
        CAST zpru_if_dynamic_abap_processor( lo_executor )->process_dynamic_abap(
                                                           EXPORTING io_controller       = io_controller
                                                                     io_request          = io_input
                                                                     is_agent            = is_agent
                                                                     is_tool_master_data = is_tool_master_data
                                                                     is_execution_step   = is_execution_step
                                                           IMPORTING eo_response         = eo_response
                                                                     et_key_value_pairs  = et_key_value_pairs
                                                                     ev_error_flag       = ev_error_flag
                                                                     et_additional_steps = et_additional_steps
                                                                     et_additional_tools = et_additional_tools ).

      WHEN zpru_if_adf_type_and_constant=>cs_step_type-infer_ml_model.
        CAST zpru_if_ml_model_inference( lo_executor )->get_machine_learning_inference(
                                                       EXPORTING io_controller       = io_controller
                                                                 io_request          = io_input
                                                                 is_agent            = is_agent
                                                                 is_tool_master_data = is_tool_master_data
                                                                 is_execution_step   = is_execution_step
                                                       IMPORTING eo_response         = eo_response
                                                                 et_key_value_pairs  = et_key_value_pairs
                                                                 ev_error_flag       = ev_error_flag
                                                                 et_additional_steps = et_additional_steps
                                                                 et_additional_tools = et_additional_tools ).

      WHEN zpru_if_adf_type_and_constant=>cs_step_type-user_tool.
        CAST zpru_if_user_tool( lo_executor )->execute_user_tool( EXPORTING io_controller       = io_controller
                                                                            io_request          = io_input
                                                                            is_agent            = is_agent
                                                                            is_tool_master_data = is_tool_master_data
                                                                            is_execution_step   = is_execution_step
                                                                  IMPORTING eo_response         = eo_response
                                                                            et_key_value_pairs  = et_key_value_pairs
                                                                            ev_error_flag       = ev_error_flag
                                                                            et_additional_steps = et_additional_steps
                                                                            et_additional_tools = et_additional_tools ).
    ENDCASE.
  ENDMETHOD.

  METHOD finalize_successful_query.
    DATA: BEGIN OF ls_json_type,
            user      TYPE string,
            topic     TYPE string,
            timestamp TYPE timestampl,
            content   TYPE string,
          END OF ls_json_type.

    DATA: BEGIN OF ls_json_type_2,
            run_id         TYPE timestampl,
            query_number   TYPE string,
            final_response TYPE string,
          END OF ls_json_type_2.

    DATA lv_content           TYPE string.
    DATA lt_query_update_imp  TYPE zpru_if_axc_type_and_constant=>tt_query_update_imp.
    DATA lo_decision_provider TYPE REF TO zpru_if_decision_provider.
    DATA lo_axc_service       TYPE REF TO zpru_if_axc_service.
    DATA lt_step_final_state  TYPE zpru_if_axc_type_and_constant=>tt_axc_step.
    DATA lo_util              TYPE REF TO zpru_if_agent_util.
    DATA lv_final_response    TYPE string.

    lo_util = get_utility( ).

    lo_axc_service ?= zpru_cl_agent_service_mngr=>get_service( iv_service = `ZPRU_IF_AXC_SERVICE`
                                                               iv_context = zpru_if_agent_frw=>cs_context-standard ).

    lo_axc_service->rba_step( EXPORTING it_rba_step_k = VALUE #( ( queryuuid          = is_execution_query-queryuuid
                                                                   control-runuuid    = abap_true
                                                                   control-queryuuid  = abap_true
                                                                   control-stepstatus = abap_true  ) )
                              IMPORTING et_axc_step   = lt_step_final_state
                              CHANGING  cs_reported   = cs_axc_reported
                                        cs_failed     = cs_axc_failed ).

    LOOP AT lt_step_final_state TRANSPORTING NO FIELDS WHERE stepstatus <> zpru_if_axc_type_and_constant=>sc_step_status-complete.
      RETURN.
    ENDLOOP.

    LOOP AT io_controller->mt_execution_steps ASSIGNING FIELD-SYMBOL(<ls_upd_context_step_status>).
      <ls_upd_context_step_status>-stepstatus = zpru_if_axc_type_and_constant=>sc_step_status-complete.
    ENDLOOP.

    GET TIME STAMP FIELD DATA(lv_now).

    APPEND INITIAL LINE TO lt_query_update_imp ASSIGNING FIELD-SYMBOL(<ls_query_2_upd>).
    <ls_query_2_upd>-queryuuid        = is_execution_query-queryuuid.
    <ls_query_2_upd>-runuuid          = is_execution_query-runuuid.
    <ls_query_2_upd>-querystatus      = zpru_if_axc_type_and_constant=>sc_query_status-complete.
    <ls_query_2_upd>-queryenddatetime = lv_now.
    <ls_query_2_upd>-control-querystatus      = abap_true.
    <ls_query_2_upd>-control-queryenddatetime = abap_true.

    lo_axc_service->update_query( EXPORTING it_query_update_imp = lt_query_update_imp
                                  CHANGING  cs_reported         = cs_axc_reported
                                            cs_failed           = cs_axc_failed ).

    CREATE OBJECT lo_decision_provider TYPE (is_agent-decisionprovider).

    lo_decision_provider->prepare_final_response( EXPORTING iv_run_uuid       = is_execution_query-runuuid
                                                            iv_query_uuid     = is_execution_query-queryuuid
                                                            io_controller     = get_controller( )
                                                            io_last_output    = io_last_output
                                                  IMPORTING eo_final_response = eo_final_response
                                                  CHANGING  cs_axc_reported   = cs_axc_reported
                                                            cs_axc_failed     = cs_axc_failed
                                                            cs_adf_reported   = cs_adf_reported
                                                            cs_adf_failed     = cs_adf_failed   ).
    IF eo_final_response IS BOUND.

      lv_final_response = eo_final_response->get_data( )->*.

      CLEAR lt_query_update_imp.
      APPEND INITIAL LINE TO lt_query_update_imp ASSIGNING <ls_query_2_upd>.
      <ls_query_2_upd>-queryuuid           = is_execution_query-queryuuid.
      <ls_query_2_upd>-runuuid             = is_execution_query-runuuid.
      <ls_query_2_upd>-queryoutputresponse = lv_final_response.
      <ls_query_2_upd>-control-queryoutputresponse = abap_true.

      lo_axc_service->update_query( EXPORTING it_query_update_imp = lt_query_update_imp
                                    CHANGING  cs_reported         = cs_axc_reported
                                              cs_failed           = cs_axc_failed ).
    ENDIF.

    ls_json_type-user      = sy-uname.
    ls_json_type-topic     = `FINAL_RESPONSE`.
    ls_json_type-timestamp = lv_now.
    ls_json_type-content   = <ls_query_2_upd>-queryoutputresponse.

    lo_util->convert_to_string( EXPORTING ir_abap   = REF #( ls_json_type )
                                CHANGING  cr_string = lv_content ).

    DATA(lv_final_response_message) = lv_content.

    DATA(lv_last_number) = lines( io_controller->mt_input_output ).
    ASSIGN io_controller->mt_input_output[ number = lv_last_number ] TO FIELD-SYMBOL(<ls_input_output>).
    IF sy-subrc = 0.
      <ls_input_output>-output_response = lv_final_response_message.
    ENDIF.

    ls_json_type_2-run_id         = is_execution_header-runid.
    ls_json_type_2-query_number   = is_execution_query-querynumber.
    ls_json_type_2-final_response = lv_final_response_message.

    CLEAR lv_content.
    lo_util->convert_to_string( EXPORTING ir_abap   = REF #( ls_json_type_2 )
                                CHANGING  cr_string = lv_content ).

    DATA(lt_message) = VALUE zpru_if_short_memory_provider=>tt_message(
        ( messagecontentid = |{ lv_now }-{ sy-uname }-PROCESS_EXECUTION_STEPS_FINAL|
          stage            = 'PROCESS_EXECUTION_STEPS'
          substage         = |FINAL_RESPONSE|
          namespace        = |{ sy-uname }.{ is_agent-agentname }.{ is_execution_header-runid }.{ is_execution_query-querynumber }|
          username         = sy-uname
          agentuuid        = is_agent-agentuuid
          runuuid          = is_execution_query-runuuid
          queryuuid        = is_execution_query-queryuuid
          messagedatetime  = lv_now
          content          = lv_content
          messagetype      = zpru_if_short_memory_provider=>cs_msg_type-step_output  ) ).

    io_short_memory->save_message( it_message    = lt_message
                                   io_controller = get_controller( ) ).
  ENDMETHOD.

  METHOD resequence_steps.
    CLEAR et_map_tempuuid_2_finaluuid.

    SORT ct_step_all BY stepsequence DESCENDING.
    DATA(lv_count_before) = VALUE #( ct_step_all[ 1 ]-stepsequence OPTIONAL ).
    DATA(lv_first_iteration) = abap_true.

    LOOP AT it_additional_steps ASSIGNING FIELD-SYMBOL(<ls_add_exec_step>).
      lv_count_before += 1.

      GET TIME STAMP FIELD DATA(lv_now).

      APPEND INITIAL LINE TO ct_step_create_imp ASSIGNING FIELD-SYMBOL(<ls_step_2_cre>).
      <ls_step_2_cre>-queryuuid         = is_execution_query-queryuuid.
      <ls_step_2_cre>-runuuid           = is_execution_header-runuuid.
      <ls_step_2_cre>-tooluuid          = <ls_add_exec_step>-tooluuid.
      <ls_step_2_cre>-stepsequence      = lv_count_before.
      <ls_step_2_cre>-stepstatus        = zpru_if_axc_type_and_constant=>sc_step_status-new.
      <ls_step_2_cre>-stepstartdatetime = lv_now.

      IF lv_first_iteration = abap_true.
        <ls_step_2_cre>-stepinputprompt = iv_output_prompt.
      ENDIF.

      <ls_step_2_cre>-control-queryuuid         = abap_true.
      <ls_step_2_cre>-control-runuuid           = abap_true.
      <ls_step_2_cre>-control-tooluuid          = abap_true.
      <ls_step_2_cre>-control-stepsequence      = abap_true.
      <ls_step_2_cre>-control-stepstatus        = abap_true.
      <ls_step_2_cre>-control-stepstartdatetime = abap_true.
      IF lv_first_iteration = abap_true.
        <ls_step_2_cre>-control-stepinputprompt = abap_true.
      ENDIF.

      APPEND INITIAL LINE TO ct_step_all ASSIGNING FIELD-SYMBOL(<ls_step_all>).
      <ls_step_all> = CORRESPONDING #( <ls_step_2_cre> ).

      APPEND INITIAL LINE TO et_map_tempuuid_2_finaluuid ASSIGNING FIELD-SYMBOL(<ls_map_tempuuid_2_finaluuid>).
      <ls_map_tempuuid_2_finaluuid>-temp_uuid    = <ls_add_exec_step>-stepuuid.
      <ls_map_tempuuid_2_finaluuid>-stepsequence = lv_count_before.

      lv_first_iteration = abap_false.
    ENDLOOP.

    LOOP AT ct_step_after ASSIGNING FIELD-SYMBOL(<ls_step_after>).
      lv_count_before += 1.

      APPEND INITIAL LINE TO ct_step_update_imp ASSIGNING FIELD-SYMBOL(<ls_step_2_upd>).
      <ls_step_2_upd>-stepuuid     = <ls_step_after>-stepuuid.
      <ls_step_2_upd>-queryuuid    = is_execution_query-queryuuid.
      <ls_step_2_upd>-runuuid      = is_execution_header-runuuid.
      <ls_step_2_upd>-stepsequence = lv_count_before.
      <ls_step_2_upd>-control-stepsequence = abap_true.

      " refresh old sequence
      <ls_step_after>-stepsequence = lv_count_before.

      APPEND INITIAL LINE TO ct_step_all ASSIGNING <ls_step_all>.
      <ls_step_all> = CORRESPONDING #( <ls_step_after> ).

    ENDLOOP.

    SORT ct_step_all BY stepsequence ASCENDING.
  ENDMETHOD.

  METHOD log_step_execution.
    DATA: BEGIN OF ls_json_type,
            user      TYPE string,
            topic     TYPE string,
            timestamp TYPE timestampl,
            content   TYPE string,
          END OF ls_json_type.

    DATA: BEGIN OF ls_json_type_2,
            run_id        TYPE string,
            query_number  TYPE string,
            step_number   TYPE string,
            timestamp     TYPE timestampl,
            execution_seq TYPE string,
            tool_name     TYPE string,
            step_type     TYPE string,
            input_prompt  TYPE string,
            output_prompt TYPE string,
            error         TYPE string,
          END OF ls_json_type_2.

    DATA lv_content TYPE string.

    GET TIME STAMP FIELD DATA(lv_now).

    DATA(lo_util) = get_utility( ).

    ls_json_type-user      = sy-uname.
    ls_json_type-topic     = `TOOL_INPUT_PROMPT`.
    ls_json_type-timestamp = lv_now.
    ls_json_type-content   = iv_input_prompt.

    lo_util->convert_to_string( EXPORTING ir_abap   = REF #( ls_json_type )
                                CHANGING  cr_string = lv_content ).

    DATA(lv_input_tool_prompt_message) = lv_content.

    CLEAR ls_json_type.
    CLEAR lv_content.
    ls_json_type-user      = sy-uname.
    ls_json_type-topic     = `TOOL_OUTPUT_PROMPT`.
    ls_json_type-timestamp = lv_now.
    ls_json_type-content   = iv_output_prompt.

    lo_util->convert_to_string( EXPORTING ir_abap   = REF #( ls_json_type )
                                CHANGING  cr_string = lv_content ).

    DATA(lv_output_tool_prompt_message) = lv_content.

    ls_json_type_2-run_id        = is_execution_header-runid.
    ls_json_type_2-query_number  = is_execution_query-querynumber.
    ls_json_type_2-step_number   = is_execution_step-stepnumber.
    ls_json_type_2-execution_seq = is_execution_step-stepsequence.
    ls_json_type_2-tool_name     = is_tool_master_data-toolname.
    ls_json_type_2-step_type     = is_tool_master_data-steptype.
    ls_json_type_2-input_prompt  = lv_input_tool_prompt_message.
    ls_json_type_2-output_prompt = lv_output_tool_prompt_message.
    ls_json_type_2-error         = iv_error_flag.
    ls_json_type_2-timestamp     = lv_now.

    CLEAR lv_content.
    lo_util->convert_to_string( EXPORTING ir_abap   = REF #( ls_json_type_2 )
                                CHANGING  cr_string = lv_content ).

    rs_message = VALUE #(
        messagecontentid = |{ lv_now }-{ sy-uname }-PROCESS_EXECUTION_STEPS_{ iv_count }|
        stage            = 'PROCESS_EXECUTION_STEPS'
        substage         = |STEP_{ is_execution_step-stepsequence }|
        namespace        = |{ sy-uname }.{ is_agent-agentname }.{ is_execution_header-runid }.{ is_execution_query-querynumber }|
        username         = sy-uname
        agentuuid        = is_agent-agentuuid
        runuuid          = is_execution_step-runuuid
        queryuuid        = is_execution_step-queryuuid
        stepuuid         = is_execution_step-stepuuid
        messagedatetime  = lv_now
        content          = lv_content
        messagetype      = zpru_if_short_memory_provider=>cs_msg_type-step_output ).
  ENDMETHOD.

  METHOD setup_agent_context.
    DATA lo_adf_service TYPE REF TO zpru_if_adf_service.

    fetch_agent_definition_by_uuid( EXPORTING iv_agent_uuid = iv_agent_uuid
                                    IMPORTING es_agent      = es_agent
                                              eo_service    = lo_adf_service
                                    CHANGING  cs_reported   = cs_adf_reported
                                              cs_failed     = cs_adf_failed ).

    IF es_agent-agentstatus <> zpru_if_adf_type_and_constant=>cs_agent_status-active.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    lo_adf_service->rba_tool( EXPORTING it_rba_tool_k = VALUE #( ( agentuuid                  = es_agent-agentuuid
                                                                   control-tooluuid           = abap_true
                                                                   control-agentuuid          = abap_true
                                                                   control-toolname           = abap_true
                                                                   control-toolprovider       = abap_true
                                                                   control-steptype           = abap_true
                                                                   control-toolschemaprovider = abap_true
                                                                   control-toolinfoprovider   = abap_true
                                                                   control-toolisborrowed     = abap_true
                                                                   control-toolistransient    = abap_true    ) )
                              IMPORTING et_tool       = et_agent_tools
                              CHANGING  cs_reported   = cs_adf_reported
                                        cs_failed     = cs_adf_failed ).

    CREATE OBJECT eo_decision_provider TYPE (es_agent-decisionprovider).

    prepare_memory_provider( EXPORTING iv_agent_uuid   = es_agent-agentuuid
                             IMPORTING eo_short_memory = eo_short_memory
                             CHANGING  cs_reported     = cs_adf_reported
                                       cs_failed       = cs_adf_failed ).

    get_long_memory( EXPORTING iv_agent_uuid  = es_agent-agentuuid
                     IMPORTING eo_long_memory = eo_long_memory
                     CHANGING  cs_reported    = cs_adf_reported
                               cs_failed      = cs_adf_failed ).

    IF es_agent-agentinfoprovider IS NOT INITIAL.
      CREATE OBJECT eo_agent_info_provider TYPE (es_agent-agentinfoprovider).
    ENDIF.

    IF es_agent-systempromptprovider IS NOT INITIAL.
      CREATE OBJECT eo_system_prompt_provider TYPE (es_agent-systempromptprovider).
    ENDIF.
  ENDMETHOD.

  METHOD process_decision_engine.
    DATA: BEGIN OF ls_json_type,
            user      TYPE string,
            topic     TYPE string,
            timestamp TYPE timestampl,
            content   TYPE string,
          END OF ls_json_type.

    DATA: BEGIN OF ls_parsed_query,
            user      TYPE string,
            topic     TYPE string,
            timestamp TYPE timestampl,
            content   TYPE string,
          END OF ls_parsed_query.

    DATA: BEGIN OF ls_json_type_2,
            agent_name        TYPE string,
            decision_provider TYPE string,
            query             TYPE string,
            system_prompt     TYPE string,
            agent_info        TYPE string,
          END OF ls_json_type_2.

    DATA: BEGIN OF ls_json_type_3,
            agent_name        TYPE string,
            decision_provider TYPE string,
            query             TYPE string,
            first_tool_input  TYPE string,
            language          TYPE string,
            decision_log      TYPE string,
          END OF ls_json_type_3.

    DATA lv_content          TYPE string.
    DATA lo_query            TYPE REF TO zpru_if_payload.
    DATA lo_utility          TYPE REF TO zpru_if_agent_util.
    DATA lo_execution_plan   TYPE REF TO zpru_if_payload.
    DATA lo_first_tool_input TYPE REF TO zpru_if_payload.
    DATA lo_langu            TYPE REF TO zpru_if_payload.
    DATA lo_decision_log     TYPE REF TO zpru_if_payload.
    DATA lt_execution_plan   TYPE zpru_if_decision_provider=>tt_execution_plan.
    DATA lv_first_tool_input TYPE zpru_if_agent_frw=>ts_json.
    DATA lv_langu            TYPE sylangu.
    DATA lv_decision_log     TYPE zpru_if_agent_frw=>ts_json.
    DATA lv_unwrapped_query  TYPE string.

    lo_utility = get_utility( ).

    lo_query = get_payload( ).

    lo_first_tool_input = get_payload( ).

    lo_execution_plan = get_payload( ).

    lo_langu = get_payload( ).

    lo_decision_log = get_payload( ).

    lv_unwrapped_query = iv_input_query.

    lo_utility->convert_to_abap( EXPORTING ir_string = REF #( lv_unwrapped_query )
                                 CHANGING  cr_abap   = ls_parsed_query ).

    lo_query->set_data( ir_data = NEW string( ls_parsed_query-content )  ).

    GET TIME STAMP FIELD DATA(lv_now).

    ls_json_type-user      = sy-uname.
    ls_json_type-topic     = `SYSTEM_PROMPT`.
    ls_json_type-timestamp = lv_now.
    ls_json_type-content   = io_system_prompt_provider->get_system_prompt( is_agent-agentuuid ).

    lo_utility->convert_to_string( EXPORTING ir_abap   = REF #( ls_json_type )
                                   CHANGING  cr_string = lv_content ).

    DATA(lv_system_prompt) = lv_content.

    CLEAR ls_json_type.

    ls_json_type-user      = sy-uname.
    ls_json_type-topic     = `AGENT_INFO`.
    ls_json_type-timestamp = lv_now.
    ls_json_type-content   = io_agent_info_provider->get_agent_info( is_agent-agentuuid ).

    CLEAR lv_content.
    lo_utility->convert_to_string( EXPORTING ir_abap   = REF #( ls_json_type )
                                   CHANGING  cr_string = lv_content ).

    DATA(lv_agent_info) = lv_content.

    ls_json_type_2-agent_name        = is_agent-agentname.
    ls_json_type_2-decision_provider = is_agent-decisionprovider.
    ls_json_type_2-query             = lv_unwrapped_query.
    ls_json_type_2-system_prompt     = lv_system_prompt.
    ls_json_type_2-agent_info        = lv_agent_info.

    CLEAR lv_content.
    lo_utility->convert_to_string( EXPORTING ir_abap   = REF #( ls_json_type_2 )
                                   CHANGING  cr_string = lv_content ).

    DATA(lt_message_in) = VALUE zpru_if_short_memory_provider=>tt_message(
                                    ( messagecontentid = |{ lv_now }-{ sy-uname }-{ iv_stage }_{ 1 }|
                                      stage            = iv_stage
                                      substage         = 'BEFORE_DECISION'
                                      namespace        = |{ sy-uname }.{ is_agent-agentname }|
                                      username         = sy-uname
                                      agentuuid        = is_agent-agentuuid
                                      messagedatetime  = lv_now
                                      content          = lv_content
                                      messagetype      = zpru_if_short_memory_provider=>cs_msg_type-info ) ).

    io_short_memory->save_message( it_message    = lt_message_in
                                   io_controller = get_controller( ) ).

    io_decision_provider->call_decision_engine( EXPORTING is_agent               = is_agent
                                                          it_tool                = it_agent_tools
                                                          io_controller          = io_controller
                                                          is_input_prompt        = is_input_prompt
                                                          io_input               = lo_query
                                                          io_system_prompt       = io_system_prompt_provider
                                                          io_short_memory        = io_short_memory
                                                          io_long_memory         = io_long_memory
                                                          io_agent_info_provider = io_agent_info_provider
                                                IMPORTING eo_execution_plan      = lo_execution_plan
                                                          eo_first_tool_input    = lo_first_tool_input
                                                          eo_langu               = lo_langu
                                                          eo_decision_log        = lo_decision_log ).

    IF lo_execution_plan IS BOUND.
      eo_execution_plan = lo_execution_plan.
      lt_execution_plan = lo_execution_plan->get_data( )->*.

    ENDIF.

    IF lt_execution_plan IS INITIAL.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    IF lo_decision_log IS BOUND.
      eo_decision_log = lo_decision_log.
      lv_decision_log = lo_decision_log->get_data( )->*.
    ENDIF.

    IF lo_first_tool_input IS BOUND.
      eo_first_tool_input = lo_first_tool_input.
      lv_first_tool_input = lo_first_tool_input->get_data( )->*.
    ENDIF.

    IF lo_langu IS BOUND.
      eo_langu = lo_langu.
      lv_langu = lo_langu->get_data( )->*.
    ENDIF.

    GET TIME STAMP FIELD lv_now.

    CLEAR ls_json_type.

    ls_json_type-user      = sy-uname.
    ls_json_type-topic     = `DECISION_LOG`.
    ls_json_type-timestamp = lv_now.
    ls_json_type-content   = lv_decision_log.

    CLEAR lv_content.
    lo_utility->convert_to_string( EXPORTING ir_abap   = REF #( ls_json_type )
                                   CHANGING  cr_string = lv_content ).

    DATA(lv_decision_log_message) = lv_content.

    CLEAR ls_json_type.

    ls_json_type-user      = sy-uname.
    ls_json_type-topic     = `FIRST_TOOL_INPUT`.
    ls_json_type-timestamp = lv_now.
    ls_json_type-content   = lv_first_tool_input.

    CLEAR lv_content.
    lo_utility->convert_to_string( EXPORTING ir_abap   = REF #( ls_json_type )
                                   CHANGING  cr_string = lv_content ).

    DATA(lv_first_tool_input_message) = lv_content.

    ls_json_type_3-agent_name        = is_agent-agentname.
    ls_json_type_3-decision_provider = is_agent-decisionprovider.
    ls_json_type_3-query             = lv_unwrapped_query.
    ls_json_type_3-first_tool_input  = lv_first_tool_input_message.
    ls_json_type_3-language          = lv_langu.
    ls_json_type_3-decision_log      = lv_decision_log_message.

    CLEAR lv_content.
    lo_utility->convert_to_string( EXPORTING ir_abap   = REF #( ls_json_type_3 )
                                   CHANGING  cr_string = lv_content ).

    lt_message_in = VALUE #( ( messagecontentid = |{ lv_now }-{ sy-uname }-{ iv_stage }_{ 2 }|
                               stage            = iv_stage
                               substage         = 'AFTER_DECISION'
                               namespace        = |{ sy-uname }.{ is_agent-agentname }|
                               username         = sy-uname
                               agentuuid        = is_agent-agentuuid
                               messagedatetime  = lv_now
                               content          = lv_content
                               messagetype      = zpru_if_short_memory_provider=>cs_msg_type-info ) ).

    io_short_memory->save_message( it_message    = lt_message_in
                                   io_controller = get_controller( )  ).
  ENDMETHOD.

  METHOD construct_execution_steps.
    TYPES: BEGIN OF ts_message_step_mapping,
             messagecontentid TYPE char100,
             stepsequence     TYPE zpru_de_step_sequence,
           END OF ts_message_step_mapping.

    DATA: BEGIN OF ls_json_type,
            user      TYPE string,
            topic     TYPE string,
            timestamp TYPE timestampl,
            content   TYPE string,
          END OF ls_json_type.

    DATA: BEGIN OF ls_json_type_2,
            step_number        TYPE string,
            query_number       TYPE string,
            run_id             TYPE timestampl,
            execution_sequence TYPE string,
            input_prompt       TYPE string,
          END OF ls_json_type_2.

    DATA lv_content              TYPE string.
    DATA lv_tool_prompt_message  TYPE string.
    DATA lo_axc_service          TYPE REF TO zpru_if_axc_service.
    DATA lt_message_in           TYPE zpru_if_short_memory_provider=>tt_message.
    DATA lo_util                 TYPE REF TO zpru_if_agent_util.
    DATA lt_message_step_mapping TYPE STANDARD TABLE OF ts_message_step_mapping WITH EMPTY KEY.

    lo_axc_service ?= zpru_cl_agent_service_mngr=>get_service( iv_service = `ZPRU_IF_AXC_SERVICE`
                                                               iv_context = zpru_if_agent_frw=>cs_context-standard ).

    lo_util = get_utility( ).
    SORT ct_execution_plan BY sequence ASCENDING.
    DATA(lv_min_seq) = VALUE #( ct_execution_plan[ 1 ]-sequence OPTIONAL ).

    GET TIME STAMP FIELD DATA(lv_now).
    DATA(lv_count) = iv_count.

    LOOP AT ct_execution_plan ASSIGNING FIELD-SYMBOL(<ls_tool>).

      CLEAR: ls_json_type,
             ls_json_type_2,
             lv_tool_prompt_message.

      ASSIGN it_agent_tools[ agentuuid = <ls_tool>-agentuuid
                             toolname  = <ls_tool>-toolname ] TO FIELD-SYMBOL(<ls_tool_master_data>).
      IF sy-subrc <> 0.
        RETURN.
      ENDIF.

      APPEND INITIAL LINE TO et_execution_steps ASSIGNING FIELD-SYMBOL(<ls_execution_step>).
      <ls_execution_step>-queryuuid         = is_execution_query-queryuuid.
      <ls_execution_step>-runuuid           = is_execution_header-runuuid.
      <ls_execution_step>-tooluuid          = <ls_tool_master_data>-tooluuid.
      <ls_execution_step>-stepsequence      = <ls_tool>-sequence.
      <ls_execution_step>-stepstatus        = zpru_if_axc_type_and_constant=>sc_step_status-new.
      <ls_execution_step>-stepstartdatetime = lv_now.

      IF <ls_tool>-sequence = lv_min_seq.
        <ls_execution_step>-stepinputprompt = iv_first_tool_input.
      ENDIF.

      IF <ls_execution_step>-stepinputprompt IS NOT INITIAL.
        ls_json_type-user      = sy-uname.
        ls_json_type-topic     = `TOOL_INPUT_PROMPT`.
        ls_json_type-timestamp = lv_now.
        ls_json_type-content   = <ls_execution_step>-stepinputprompt.

        CLEAR lv_content.
        lo_util->convert_to_string( EXPORTING ir_abap   = REF #( ls_json_type )
                                    CHANGING  cr_string = lv_content ).

        lv_tool_prompt_message = lv_content.
      ENDIF.

      ls_json_type_2-query_number       = is_execution_query-querynumber.
      ls_json_type_2-run_id             = is_execution_header-runid.
      ls_json_type_2-execution_sequence = <ls_execution_step>-stepsequence.
      ls_json_type_2-input_prompt       = lv_tool_prompt_message.

      CLEAR lv_content.
      lo_util->convert_to_string( EXPORTING ir_abap   = REF #( ls_json_type_2 )
                                  CHANGING  cr_string = lv_content ).

      APPEND INITIAL LINE TO lt_message_in ASSIGNING FIELD-SYMBOL(<ls_message>).
      <ls_message> = VALUE #(
          messagecontentid = |{ lv_now }-{ sy-uname }-{ iv_stage }_{ lv_count }|
          stage            = iv_stage
          substage         = 'STEP_ANALYSIS'
          namespace        = |{ sy-uname }.{ is_agent-agentname }.{ is_execution_header-runid }.{ is_execution_query-querynumber }|
          username         = sy-uname
          agentuuid        = is_agent-agentuuid
          runuuid          = is_execution_header-runuuid
          queryuuid        = is_execution_query-queryuuid
          messagedatetime  = lv_now
          content          = lv_content
          messagetype      = zpru_if_short_memory_provider=>cs_msg_type-step_input ).

      APPEND INITIAL LINE TO lt_message_step_mapping ASSIGNING FIELD-SYMBOL(<ls_message_step_mapping>).
      <ls_message_step_mapping>-messagecontentid = <ls_message>-messagecontentid.
      <ls_message_step_mapping>-stepsequence     = <ls_execution_step>-stepsequence.

      lv_count += 1.
    ENDLOOP.

    lo_axc_service->cba_step( EXPORTING it_axc_step_imp = VALUE #( FOR <ls_s> IN et_execution_steps
                                                                   ( stepuuid           = <ls_s>-stepuuid
                                                                     queryuuid          = <ls_s>-queryuuid
                                                                     runuuid            = <ls_s>-runuuid
                                                                     tooluuid           = <ls_s>-tooluuid
                                                                     stepsequence       = <ls_s>-stepsequence
                                                                     stepstatus         = <ls_s>-stepstatus
                                                                     stepstartdatetime  = <ls_s>-stepstartdatetime
                                                                     stependdatetime    = <ls_s>-stependdatetime
                                                                     stepinputprompt    = <ls_s>-stepinputprompt
                                                                     stepoutputresponse = <ls_s>-stepoutputresponse
                                                                     control            = VALUE #(
                                                                         stepuuid           = abap_true
                                                                         queryuuid          = abap_true
                                                                         runuuid            = abap_true
                                                                         tooluuid           = abap_true
                                                                         stepsequence       = abap_true
                                                                         stepstatus         = abap_true
                                                                         stepstartdatetime  = abap_true
                                                                         stependdatetime    = abap_true
                                                                         stepinputprompt    = abap_true
                                                                         stepoutputresponse = abap_true ) ) )
                              CHANGING  cs_reported     = cs_axc_reported
                                        cs_failed       = cs_axc_failed
                                        cs_mapped       = cs_axc_mapped ).
    lo_axc_service->read_step(
      EXPORTING it_step_read_k = VALUE #(  FOR <ls_k> IN cs_axc_mapped-step
                                          ( stepuuid = <ls_k>-stepuuid
                                            control  = VALUE #( stepuuid           = abap_true
                                                                stepnumber         = abap_true
                                                                queryuuid          = abap_true
                                                                runuuid            = abap_true
                                                                tooluuid           = abap_true
                                                                stepsequence       = abap_true
                                                                stepstatus         = abap_true
                                                                stepstartdatetime  = abap_true
                                                                stependdatetime    = abap_true
                                                                stepinputprompt    = abap_true
                                                                stepoutputresponse = abap_true ) ) )
      IMPORTING et_axc_step    = DATA(lt_all_steps) ).

    LOOP AT et_execution_steps ASSIGNING <ls_execution_step>.
      ASSIGN lt_all_steps[ stepsequence = <ls_execution_step>-stepsequence ] TO FIELD-SYMBOL(<ls_step_read>).
      IF sy-subrc <> 0.
        RAISE EXCEPTION NEW zpru_cx_agent_core( ).
      ENDIF.
      <ls_execution_step>-stepuuid   = <ls_step_read>-stepuuid.
      <ls_execution_step>-stepnumber = <ls_step_read>-stepnumber.

      ASSIGN lt_message_step_mapping[ stepsequence = <ls_execution_step>-stepsequence  ] TO <ls_message_step_mapping>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      ASSIGN lt_message_in[ messagecontentid = <ls_message_step_mapping>-messagecontentid ] TO <ls_message>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      <ls_message>-stepuuid = <ls_step_read>-stepuuid.

    ENDLOOP.

    io_short_memory->save_message( it_message    = lt_message_in
                                   io_controller = get_controller( ) ).

    SORT et_execution_steps BY stepsequence ASCENDING.
  ENDMETHOD.

  METHOD clear_internal_state.
    CLEAR: mv_output_response,
           mv_output_response_prev,
           mv_input_query,
           mo_controller,
           mo_long_memory,
           mo_short_memory.
  ENDMETHOD.

  METHOD assign_controller_context.
    DATA(lo_controller) = get_controller( ).

    IF io_parent_controller IS BOUND.
      lo_controller->mo_parent_controller = io_parent_controller.
    ENDIF.
  ENDMETHOD.

  METHOD fetch_agent_configuration.
    eo_service ?= zpru_cl_agent_service_mngr=>get_service( iv_service = `ZPRU_IF_ADF_SERVICE`
                                                           iv_context = zpru_if_agent_frw=>cs_context-standard ).

    eo_service->query_agent( EXPORTING it_agent_name = VALUE #( ( sign   = zpru_if_agent_frw=>cs_sign-include
                                                                  option = zpru_if_agent_frw=>cs_option-equal
                                                                  low    = iv_agent_name ) )
                             IMPORTING et_agent_k    = et_agent_k ).

    eo_service->read_agent( EXPORTING it_agent_read_k = VALUE #( FOR <ls_k> IN et_agent_k
                                                                 ( agentuuid                    = <ls_k>-agentuuid
                                                                   control-agentuuid            = abap_true
                                                                   control-agentname            = abap_true
                                                                   control-agenttype            = abap_true
                                                                   control-decisionprovider     = abap_true
                                                                   control-shortmemoryprovider  = abap_true
                                                                   control-longmemoryprovider   = abap_true
                                                                   control-agentinfoprovider    = abap_true
                                                                   control-systempromptprovider = abap_true
                                                                   control-agentmapper          = abap_true
                                                                   control-agentstatus          = abap_true
                                                                   control-createdby            = abap_true
                                                                   control-createdat            = abap_true
                                                                   control-changedby            = abap_true
                                                                   control-lastchanged          = abap_true
                                                                   control-locallastchanged     = abap_true ) )
                            IMPORTING et_agent        = DATA(lt_agent)
                            CHANGING  cs_reported     = cs_reported
                                      cs_failed       = cs_failed ).

    es_agent = VALUE #( lt_agent[ 1 ] OPTIONAL ).
  ENDMETHOD.

  METHOD ensure_agent_is_active.
    IF is_agent IS INITIAL OR is_agent-agentstatus = zpru_if_adf_type_and_constant=>cs_agent_status-inactive.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    IF is_agent-agentstatus <> zpru_if_adf_type_and_constant=>cs_agent_status-new.
      RETURN.
    ENDIF.

    io_service->update_agent(
      EXPORTING it_agent_update_imp = VALUE #( ( agentuuid   = is_agent-agentuuid
                                                 agentstatus = zpru_if_adf_type_and_constant=>cs_agent_status-active
                                                 control     = VALUE #( agentstatus = abap_true ) ) )
      CHANGING  cs_reported         = cs_reported
                cs_failed           = cs_failed ).

    IF line_exists( cs_failed-agent[ agentuuid = is_agent-agentuuid ] ).
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.
  ENDMETHOD.

  METHOD identify_available_tools.
    io_service->rba_tool( EXPORTING it_rba_tool_k = VALUE #( FOR <ls_k2> IN it_agent_k
                                                             ( agentuuid                  = <ls_k2>-agentuuid
                                                               control-tooluuid           = abap_true
                                                               control-agentuuid          = abap_true
                                                               control-toolname           = abap_true
                                                               control-toolprovider       = abap_true
                                                               control-steptype           = abap_true
                                                               control-toolschemaprovider = abap_true
                                                               control-toolinfoprovider   = abap_true
                                                               control-toolisborrowed     = abap_true
                                                               control-toolistransient    = abap_true    ) )
                          IMPORTING et_tool       = et_tools
                          CHANGING  cs_reported   = cs_reported
                                    cs_failed     = cs_failed ).
  ENDMETHOD.

  METHOD prepare_memory_provider.
    get_short_memory( EXPORTING iv_agent_uuid   = iv_agent_uuid
                      IMPORTING eo_short_memory = eo_short_memory
                      CHANGING  cs_reported     = cs_reported
                                cs_failed       = cs_failed ).
  ENDMETHOD.

  METHOD record_initialization_event.
    DATA: BEGIN OF ls_json_type,
            agent_name             TYPE string,
            decision_provider      TYPE string,
            system_prompt_provider TYPE string,
          END OF ls_json_type.

    DATA: BEGIN OF ls_json_type_2,
            tool_name     TYPE string,
            tool_provider TYPE string,
          END OF ls_json_type_2.

    DATA lv_content TYPE string.

    DATA lo_util    TYPE REF TO zpru_if_agent_util.

    GET TIME STAMP FIELD DATA(lv_now).

    DATA(lv_count) = 1.

    lo_util = get_utility( ).

    ls_json_type-agent_name             = is_agent-agentname.
    ls_json_type-decision_provider      = is_agent-decisionprovider.
    ls_json_type-system_prompt_provider = is_agent-systempromptprovider.

    lo_util->convert_to_string( EXPORTING ir_abap   = REF #( ls_json_type )
                                CHANGING  cr_string = lv_content ).

    DATA(lt_message) = VALUE zpru_if_short_memory_provider=>tt_message(
                                 ( messagecontentid = |{ lv_now }-{ sy-uname }-INITIALIZE_{ lv_count }|
                                   stage            = 'INITIALIZE'
                                   substage         = 'INITIALIZE_AGENT'
                                   namespace        = |{ sy-uname }.{ is_agent-agentname }|
                                   username         = sy-uname
                                   agentuuid        = is_agent-agentuuid
                                   messagedatetime  = lv_now
                                   content          = lv_content
                                   messagetype      = zpru_if_short_memory_provider=>cs_msg_type-info ) ).

    lv_count += 1.
    LOOP AT it_tools ASSIGNING FIELD-SYMBOL(<ls_tool>).
      APPEND INITIAL LINE TO lt_message ASSIGNING FIELD-SYMBOL(<ls_message>).

      ls_json_type_2-tool_name     = <ls_tool>-toolname.
      ls_json_type_2-tool_provider = <ls_tool>-toolprovider.

      CLEAR lv_content.
      lo_util->convert_to_string( EXPORTING ir_abap   = REF #( ls_json_type_2 )
                                  CHANGING  cr_string = lv_content ).

      <ls_message> = VALUE #( messagecontentid = |{ lv_now }-{ sy-uname }-INITIALIZE_{ lv_count }|
                              stage            = 'INITIALIZE'
                              substage         = 'INITIALIZE_TOOL'
                              namespace        = |{ sy-uname }.{ is_agent-agentname }|
                              username         = sy-uname
                              agentuuid        = is_agent-agentuuid
                              messagedatetime  = lv_now
                              content          = lv_content
                              messagetype      = zpru_if_short_memory_provider=>cs_msg_type-info ).

      lv_count += 1.

    ENDLOOP.

    io_short_memory->save_message( it_message    = lt_message
                                   io_controller = get_controller( ) ).
  ENDMETHOD.

  METHOD fetch_agent_definition_by_uuid.
    eo_service ?= zpru_cl_agent_service_mngr=>get_service( iv_service = `ZPRU_IF_ADF_SERVICE`
                                                           iv_context = zpru_if_agent_frw=>cs_context-standard ).

    eo_service->read_agent( EXPORTING it_agent_read_k = VALUE #( ( agentuuid                    = iv_agent_uuid
                                                                   control-agentuuid            = abap_true
                                                                   control-agentname            = abap_true
                                                                   control-agenttype            = abap_true
                                                                   control-decisionprovider     = abap_true
                                                                   control-shortmemoryprovider  = abap_true
                                                                   control-longmemoryprovider   = abap_true
                                                                   control-agentinfoprovider    = abap_true
                                                                   control-systempromptprovider = abap_true
                                                                   control-agentmapper          = abap_true
                                                                   control-agentstatus          = abap_true
                                                                   control-createdby            = abap_true
                                                                   control-createdat            = abap_true
                                                                   control-changedby            = abap_true
                                                                   control-lastchanged          = abap_true
                                                                   control-locallastchanged     = abap_true  ) )
                            IMPORTING et_agent        = DATA(lt_agent)
                            CHANGING  cs_reported     = cs_reported
                                      cs_failed       = cs_failed ).

    ASSIGN lt_agent[ 1 ] TO FIELD-SYMBOL(<ls_agent>).
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    es_agent = <ls_agent>.
  ENDMETHOD.

  METHOD update_query_internal_state.
    DATA: BEGIN OF ls_json_type,
            user      TYPE string,
            topic     TYPE string,
            timestamp TYPE timestampl,
            content   TYPE string,
          END OF ls_json_type.

    DATA lo_util    TYPE REF TO zpru_if_agent_util.
    DATA lv_content TYPE string.

    lo_util = get_utility( ).

    lv_content = is_input_query-string_content.

    GET TIME STAMP FIELD DATA(lv_now).

    ls_json_type-user      = sy-uname.
    ls_json_type-topic     = `QUERY`.
    ls_json_type-timestamp = lv_now.
    ls_json_type-content   = lv_content.

    lo_util->convert_to_string( EXPORTING ir_abap   = REF #( ls_json_type )
                                CHANGING  cr_string = mv_input_query ).

    ms_input_prompt = is_input_query.
    ms_input_prompt-string_content = lv_content.

    CLEAR: mv_output_response,
           mv_output_response_prev.
  ENDMETHOD.

  METHOD append_query_to_controller.
    DATA(lo_controller) = get_controller( ).
    DATA(lv_last_number) = lines( lo_controller->mt_input_output ).
    APPEND INITIAL LINE TO lo_controller->mt_input_output ASSIGNING FIELD-SYMBOL(<ls_input_output>).
    <ls_input_output>-number             = lv_last_number + 1.
    <ls_input_output>-input_query        = mv_input_query.
    <ls_input_output>-input_prompt       = ms_input_prompt.
    <ls_input_output>-current_controller = lo_controller.
    <ls_input_output>-parent_controller  = lo_controller->mo_parent_controller.
  ENDMETHOD.

  METHOD record_query_event.
    DATA: BEGIN OF ls_json_type,
            agent_name             TYPE string,
            decision_provider      TYPE string,
            system_prompt_provider TYPE string,
            input_query            TYPE string,
          END OF ls_json_type.

    DATA lv_content TYPE string.
    DATA lt_message TYPE zpru_if_short_memory_provider=>tt_message.
    DATA lo_util    TYPE REF TO zpru_if_agent_util.

    GET TIME STAMP FIELD DATA(lv_now).

    lo_util = get_utility( ).

    ls_json_type-agent_name             = is_agent-agentname.
    ls_json_type-decision_provider      = is_agent-decisionprovider.
    ls_json_type-system_prompt_provider = is_agent-systempromptprovider.
    ls_json_type-input_query            = mv_input_query.

    lo_util->convert_to_string( EXPORTING ir_abap   = REF #( ls_json_type )
                                CHANGING  cr_string = lv_content ).

    lt_message = VALUE #( ( messagecontentid = |{ lv_now }-{ sy-uname }-SET_INPUT_QUERY_{ 1 }|
                            stage            = 'SET_INPUT_QUERY'
                            substage         = 'SET_INPUT_QUERY'
                            namespace        = |{ sy-uname }.{ is_agent-agentname }|
                            username         = sy-uname
                            agentuuid        = is_agent-agentuuid
                            messagedatetime  = lv_now
                            content          = lv_content
                            messagetype      = zpru_if_short_memory_provider=>cs_msg_type-query ) ).

    io_short_memory->save_message( it_message    = lt_message
                                   io_controller = get_controller( ) ).
  ENDMETHOD.

  METHOD initialize_run_controller.
    ro_controller = get_controller( ).
    ro_controller->mv_agent_uuid = iv_agent_uuid.
  ENDMETHOD.

  METHOD create_execution_header.
    GET TIME STAMP FIELD DATA(lv_now).
    TRY.
        es_execution_header = VALUE #( agentuuid        = iv_agent_uuid
                                       userid           = sy-uname
                                       runstartdatetime = lv_now
                                       control          = VALUE #( runuuid          = abap_true
                                                                   agentuuid        = abap_true
                                                                   userid           = abap_true
                                                                   runstartdatetime = abap_true
                                                                   runenddatetime   = abap_true ) ).

        io_axc_service->create_header( EXPORTING it_head_create_imp = VALUE #( ( es_execution_header ) )
                                       CHANGING  cs_reported        = cs_axc_reported
                                                 cs_failed          = cs_axc_failed
                                                 cs_mapped          = cs_axc_mapped ).

        io_axc_service->read_header( EXPORTING it_head_read_k = VALUE #( FOR <ls_k> IN cs_axc_mapped-header
                                                                         ( runuuid       = <ls_k>-runuuid
                                                                           control-runid = abap_true ) )
                                     IMPORTING et_axc_head    = DATA(lt_axc_head) ).

        es_execution_header-runuuid = VALUE #( lt_axc_head[ 1 ]-runuuid  OPTIONAL ).
        es_execution_header-runid   = VALUE #( lt_axc_head[ 1 ]-runid  OPTIONAL ).

      CATCH cx_uuid_error.
        RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDTRY.
  ENDMETHOD.

  METHOD load_execution_header.
    io_axc_service->read_header(
      EXPORTING it_head_read_k = VALUE #( ( runuuid = iv_run_uuid
                                            control = VALUE #( runuuid          = abap_true
                                                               runid            = abap_true
                                                               agentuuid        = abap_true
                                                               userid           = abap_true
                                                               runstartdatetime = abap_true
                                                               createdby        = abap_true
                                                               createdat        = abap_true
                                                               changedby        = abap_true
                                                               lastchanged      = abap_true
                                                               locallastchanged = abap_true ) ) )
      IMPORTING et_axc_head    = DATA(lt_axc_head)
      CHANGING  cs_reported    = cs_axc_reported
                cs_failed      = cs_axc_failed ).

    es_execution_header = VALUE #( lt_axc_head[ 1 ] OPTIONAL ).
    IF es_execution_header IS INITIAL.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.
  ENDMETHOD.

  METHOD create_execution_query.
    DATA: BEGIN OF ls_json_type,
            user      TYPE string,
            topic     TYPE string,
            timestamp TYPE timestampl,
            content   TYPE string,
          END OF ls_json_type.

    DATA lv_content      TYPE string.
    DATA lv_query        TYPE string.
    DATA lv_decision_log TYPE string.

    GET TIME STAMP FIELD DATA(lv_now).

    ls_json_type-user      = sy-uname.
    ls_json_type-topic     = `DECISION_LOG`.
    ls_json_type-timestamp = lv_now.
    ls_json_type-content   = iv_decision_log.

    io_utility->convert_to_string( EXPORTING ir_abap   = REF #( ls_json_type )
                                   CHANGING  cr_string = lv_content ).

    ev_decision_log_msg = lv_content.

    lv_query = iv_input_query.
    lv_decision_log = iv_decision_log.

    TRY.
        es_execution_query = VALUE #(
            runuuid            = iv_run_uuid
            querylanguage      = COND #( WHEN iv_langu IS NOT INITIAL THEN iv_langu ELSE sy-langu )
            querystatus        = zpru_if_axc_type_and_constant=>sc_query_status-new
            querystartdatetime = lv_now
            queryinputprompt   = lv_query
            querydecisionlog   = lv_decision_log
            control            = VALUE #( queryuuid           = abap_true
                                          runuuid             = abap_true
                                          querylanguage       = abap_true
                                          querystatus         = abap_true
                                          querystartdatetime  = abap_true
                                          queryenddatetime    = abap_true
                                          queryinputprompt    = abap_true
                                          querydecisionlog    = abap_true
                                          queryoutputresponse = abap_true ) ).

        io_axc_service->cba_query( EXPORTING it_axc_query_imp = VALUE #( ( es_execution_query ) )
                                   CHANGING  cs_reported      = cs_axc_reported
                                             cs_failed        = cs_axc_failed
                                             cs_mapped        = cs_axc_mapped ).

        io_axc_service->read_query(
          EXPORTING
            it_query_read_k = VALUE #( ( queryuuid           = VALUE #( cs_axc_mapped-query[ 1 ]-queryuuid OPTIONAL )
                                         control-queryuuid   = abap_true
                                         control-querynumber = abap_true ) )
          IMPORTING
            et_axc_query    = DATA(lt_axc_query) ).

        es_execution_query-queryuuid   = VALUE #( lt_axc_query[ 1 ]-queryuuid OPTIONAL ).
        es_execution_query-querynumber = VALUE #( lt_axc_query[ 1 ]-querynumber OPTIONAL ).

      CATCH cx_uuid_error.
        RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDTRY.
  ENDMETHOD.

  METHOD log_query_to_memory.
    DATA: BEGIN OF ls_json_type,
            agent_name   TYPE string,
            run_id       TYPE string,
            query_number TYPE string,
            language     TYPE string,
            query        TYPE string,
            decision_log TYPE string,
          END OF ls_json_type.

    DATA lv_content TYPE string.
    DATA lo_util    TYPE REF TO zpru_if_agent_util.

    lo_util = get_utility( ).

    GET TIME STAMP FIELD DATA(lv_now).

    ls_json_type-agent_name   = is_agent-agentname.
    ls_json_type-run_id       = is_execution_header-runid.
    ls_json_type-query_number = is_execution_query-querynumber.
    ls_json_type-language     = is_execution_query-querylanguage.
    ls_json_type-query        = iv_input_query.
    ls_json_type-decision_log = iv_decision_log_msg.

    lo_util->convert_to_string( EXPORTING ir_abap   = REF #(  ls_json_type )
                                CHANGING  cr_string = lv_content ).

    DATA(lt_message_in) = VALUE zpru_if_short_memory_provider=>tt_message(
        ( messagecontentid = |{ lv_now }-{ sy-uname }-{ iv_stage }_3|
          stage            = iv_stage
          substage         = 'AFTER_QUERY_CREATION'
          namespace        = |{ sy-uname }.{ is_agent-agentname }.{ is_execution_header-runid }|
          username         = sy-uname
          agentuuid        = is_agent-agentuuid
          runuuid          = is_execution_header-runuuid
          queryuuid        = is_execution_query-queryuuid
          messagedatetime  = lv_now
          content          = lv_content
          messagetype      = zpru_if_short_memory_provider=>cs_msg_type-query ) ).
    io_short_memory->save_message( it_message    = lt_message_in
                                   io_controller = get_controller( ) ).
  ENDMETHOD.

  METHOD prepare_controller_4_return.
    get_short_memory( EXPORTING iv_agent_uuid   = mo_controller->mv_agent_uuid
                      IMPORTING eo_short_memory = DATA(lo_short_memory) ).
    lo_short_memory->flush_memory( iv_all_messages = abap_true ).
    eo_executed_controller = get_controller( ).
  ENDMETHOD.

  METHOD attach_run_2_controller.
    io_controller->mv_run_uuid   = is_execution_header-runuuid.
    io_controller->mv_query_uuid = is_execution_query-queryuuid.
  ENDMETHOD.

  METHOD detach_run_from_controller.
    DATA(lv_number_of_runs) = lines( io_controller->mt_run_history ).

    APPEND INITIAL LINE TO io_controller->mt_run_history ASSIGNING FIELD-SYMBOL(<ls_run_history>).
    <ls_run_history>-count      = lv_number_of_runs + 1.
    <ls_run_history>-run_uuid   = io_controller->mv_run_uuid.
    <ls_run_history>-query_uuid = io_controller->mv_query_uuid.

    CLEAR io_controller->mv_run_uuid.
    CLEAR io_controller->mv_query_uuid.
  ENDMETHOD.

  METHOD get_utility.
    ro_util ?= zpru_cl_agent_service_mngr=>get_service( iv_service = `ZPRU_IF_AGENT_UTIL`
                                                        iv_context = zpru_if_agent_frw=>cs_context-standard ).
  ENDMETHOD.

  METHOD get_payload.
    ro_payload ?= zpru_cl_agent_service_mngr=>get_service( iv_service = `ZPRU_IF_PAYLOAD`
                                                           iv_context = zpru_if_agent_frw=>cs_context-standard ).
  ENDMETHOD.

  METHOD write_2_data_board.
    DATA lv_string_type TYPE string.

    IF io_controller IS NOT BOUND.
      RETURN.
    ENDIF.

    SORT io_controller->mt_input_output BY number ASCENDING.
    ASSIGN io_controller->mt_input_output[ number = lines( io_controller->mt_input_output ) ] TO FIELD-SYMBOL(<ls_input_output>).
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    DATA(lv_count) = 1.
    LOOP AT it_key_value_pairs ASSIGNING FIELD-SYMBOL(<ls_key_value_returned>).

      DATA(lt_data_records) = VALUE zpru_tt_key_value( FOR <ls_k>
                                                       IN <ls_input_output>-key_value_pairs
                                                       WHERE ( name = <ls_key_value_returned>-name )
                                                       ( <ls_k> ) ).

      IF lt_data_records IS NOT INITIAL.
        SORT lt_data_records BY counter DESCENDING.
        DATA(ls_record) = VALUE #( lt_data_records[ 1 ] OPTIONAL ).
        lv_count = ls_record-counter + 1.

        IF <ls_key_value_returned>-type <> ls_record-type.
          RAISE EXCEPTION NEW zpru_cx_agent_core( ).
        ENDIF.
      ENDIF.

      APPEND INITIAL LINE TO <ls_input_output>-key_value_pairs ASSIGNING FIELD-SYMBOL(<ls_key_value>).
      <ls_key_value>-name    = <ls_key_value_returned>-name.
      <ls_key_value>-counter = lv_count.

      IF <ls_key_value_returned>-type IS INITIAL.
        <ls_key_value>-type = cl_abap_typedescr=>describe_by_data( p_data = lv_string_type )->absolute_name.
      ELSE.
        <ls_key_value>-type = <ls_key_value_returned>-type.
      ENDIF.

      <ls_key_value>-value = <ls_key_value_returned>-value.

      lv_count = 1.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_execute_miniloop.
    DATA lo_agty_service TYPE REF TO zpru_if_agty_service.

    rv_continue_miniloop = abap_true.

    lo_agty_service ?= zpru_cl_agent_service_mngr=>get_service( iv_service = `ZPRU_IF_AGTY_SERVICE`
                                                                iv_context = zpru_if_agent_frw=>cs_context-standard ).

    IF io_controller->mv_max_number_of_loops IS INITIAL.
      lo_agty_service->read_agent_type(
        EXPORTING it_agty_read_k = VALUE #( ( agenttype                   = is_agent-agenttype
                                              control-maximumnumberofloop = abap_true ) )
        IMPORTING et_agty        = DATA(lt_agty) ).

      DATA(lv_number_of_loops) = VALUE #( lt_agty[ 1 ]-maximumnumberofloop OPTIONAL ).
      IF lv_number_of_loops IS INITIAL.
        lv_number_of_loops = 4.
      ENDIF.

      io_controller->mv_max_number_of_loops = lv_number_of_loops.
    ENDIF.

    IF io_controller->mo_parent_controller IS BOUND.
      DATA(lv_stop_search) = abap_false.

      DATA(lo_current_controller) = io_controller.

      WHILE lv_stop_search = abap_false.
        DATA(lo_parent) = lo_current_controller->mo_parent_controller.
        IF lo_parent->mo_parent_controller IS NOT BOUND.
          DATA(lo_root_controller) = lo_current_controller->mo_parent_controller.
          lv_stop_search = abap_true.
        ENDIF.
        lo_current_controller = lo_parent.
      ENDWHILE.

      lo_root_controller->mv_real_number_of_loops += 1.
      IF lo_root_controller->mv_real_number_of_loops = lo_root_controller->mv_max_number_of_loops.
        CLEAR lo_root_controller->mv_real_number_of_loops.
        rv_continue_miniloop = abap_false.
        RETURN.
      ENDIF.

    ELSE.
      io_controller->mv_real_number_of_loops += 1.
      IF io_controller->mv_real_number_of_loops = io_controller->mv_max_number_of_loops.
        CLEAR io_controller->mv_real_number_of_loops.
        rv_continue_miniloop = abap_false.
        RETURN.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD zpru_if_api_agent~post_environment.
    DATA: BEGIN OF ls_json_type,
            user      TYPE string,
            topic     TYPE string,
            timestamp TYPE timestampl,
            content   TYPE string,
          END OF ls_json_type.

    DATA lo_axc_service  TYPE REF TO zpru_if_axc_service.
    DATA lo_mmsg_service TYPE REF TO zpru_if_mmsg_service.
    DATA ls_failed       TYPE zpru_if_agent_frw=>ts_mmsg_bndl_failed.
    DATA lv_json_string  TYPE string.
    DATA lv_info_message TYPE string.

    CLEAR ev_environment_uuid.

    CALL TRANSFORMATION id
         SOURCE model = me
         RESULT XML lv_json_string
         OPTIONS initial_components = 'suppress'.

    fetch_agent_definition_by_uuid( EXPORTING iv_agent_uuid = iv_agent_uuid
                                    IMPORTING es_agent      = DATA(ls_agent)  ).

    lo_axc_service ?= zpru_cl_agent_service_mngr=>get_service( iv_service = `ZPRU_IF_AXC_SERVICE`
                                                               iv_context = zpru_if_agent_frw=>cs_context-standard ).

    lo_axc_service->read_header( EXPORTING it_head_read_k = VALUE #( ( runuuid = iv_built_run_uuid
                                                                       control = VALUE #(
                                                                           runuuid          = abap_true
                                                                           runid            = abap_true
                                                                           agentuuid        = abap_true
                                                                           userid           = abap_true
                                                                           runstartdatetime = abap_true
                                                                           runenddatetime   = abap_true
                                                                           createdby        = abap_true
                                                                           createdat        = abap_true
                                                                           changedby        = abap_true
                                                                           lastchanged      = abap_true
                                                                           locallastchanged = abap_true ) ) )
                                 IMPORTING et_axc_head    = DATA(lt_axc_head) ).

    GET TIME STAMP FIELD DATA(lv_now).

    DATA(ls_run) = VALUE #( lt_axc_head[ 1 ] OPTIONAL ).

    lo_mmsg_service ?= zpru_cl_agent_service_mngr=>get_service(
                           iv_service = `ZPRU_IF_MMSG_SERVICE`
                           iv_context = zpru_if_agent_frw=>cs_context-st_persistence_message ).
    TRY.

        ev_environment_uuid = cl_system_uuid=>create_uuid_x16_static( ).

        lo_mmsg_service->create_mmsg(
          EXPORTING it_mmsg_create_imp = VALUE #(
              ( messageuuid              = ev_environment_uuid
                content                  = get_utility( )->serialize_json_2_xstring( lv_json_string )
                messagetype              = zpru_if_short_memory_provider=>cs_msg_type-env
                messagecontentid         = |{ lv_now }-{ sy-uname }-POST_ENVIRONMENT|
                stage                    = 'POST_ENVIRONMENT'
                substage                 = 'POST_ENVIRONMENT'
                namespace                = |{ sy-uname }.{ ls_agent-agentname }.{ ls_run-runid }|
                username                 = sy-uname
                agentuuid                = ls_agent-agentuuid
                runuuid                  = ls_run-runuuid
                queryuuid                = iv_built_query_uuid
                messagedatetime          = lv_now
                control-messageuuid      = abap_true
                control-content          = abap_true
                control-messagetype      = abap_true
                control-messagecontentid = abap_true
                control-stage            = abap_true
                control-substage         = abap_true
                control-namespace        = abap_true
                control-username         = abap_true
                control-agentuuid        = abap_true
                control-runuuid          = abap_true
                control-queryuuid        = abap_true
                control-messagedatetime  = abap_true ) )
          CHANGING  cs_failed          = ls_failed ).
      CATCH cx_uuid_error.
        ASSERT 1 = 2.
    ENDTRY.

    get_short_memory( EXPORTING iv_agent_uuid   = iv_agent_uuid
                      IMPORTING eo_short_memory = DATA(lo_short_memory) ).

    ls_json_type-user      = sy-uname.
    ls_json_type-topic     = `POST_ENVIRONMENT`.
    ls_json_type-timestamp = lv_now.
    ls_json_type-content   = `Environment is posted to persistent store`.

    get_utility( )->convert_to_string( EXPORTING ir_abap   = REF #( ls_json_type )
                                       CHANGING  cr_string = lv_info_message ).

    lo_short_memory->save_message(
        it_message    = VALUE #( stage           = 'POST_ENVIRONMENT'
                                 substage        = 'POST_ENVIRONMENT'
                                 namespace       = |{ sy-uname }.{ ls_agent-agentname }.{ ls_run-runid }|
                                 username        = sy-uname
                                 agentuuid       = ls_agent-agentuuid
                                 runuuid         = ls_run-runuuid
                                 queryuuid       = iv_built_query_uuid
                                 messagedatetime = lv_now
                                 ( messagecontentid = |{ lv_now }-{ sy-uname }-POST_ENVIRONMENT|
                                   content          = lv_json_string
                                   messagetype      = zpru_if_short_memory_provider=>cs_msg_type-env )
                                 ( messagecontentid = |{ lv_now }-{ sy-uname }-POST_ENVIRONMENT_INFO|
                                   content          = lv_info_message
                                   messagetype      = zpru_if_short_memory_provider=>cs_msg_type-info ) )
        io_controller = get_controller( )  ).
  ENDMETHOD.

  METHOD zpru_if_api_agent~set_rap_context_flag.
    DATA(lo_controller) = get_controller( ).
    lo_controller->mv_is_rap = iv_is_rap_context.
  ENDMETHOD.

  METHOD zpru_if_api_agent~set_loop_execution.
    DATA(lo_controller) = get_controller( ).
    lo_controller->mv_is_loop_execution = iv_is_loop_execution.
  ENDMETHOD.

  METHOD zpru_if_api_agent~restore_environment.
    DATA lo_mmsg_service TYPE REF TO zpru_if_mmsg_service.
    DATA lo_axc_service  TYPE REF TO zpru_if_axc_service.

    lo_axc_service ?= zpru_cl_agent_service_mngr=>get_service( iv_service = `ZPRU_IF_AXC_SERVICE`
                                                               iv_context = zpru_if_agent_frw=>cs_context-standard ).

    lo_axc_service->read_header( EXPORTING it_head_read_k = VALUE #( ( runuuid = iv_built_run_uuid
                                                                       control = VALUE #(
                                                                           runuuid          = abap_true
                                                                           runid            = abap_true
                                                                           agentuuid        = abap_true
                                                                           userid           = abap_true
                                                                           runstartdatetime = abap_true
                                                                           runenddatetime   = abap_true
                                                                           createdby        = abap_true
                                                                           createdat        = abap_true
                                                                           changedby        = abap_true
                                                                           lastchanged      = abap_true
                                                                           locallastchanged = abap_true ) ) )
                                 IMPORTING et_axc_head    = DATA(lt_axc_head) ).

    DATA(ls_axc_head) = VALUE #( lt_axc_head[ 1 ] OPTIONAL ).

    IF ls_axc_head IS INITIAL.
      RETURN.
    ENDIF.

    lo_mmsg_service ?= zpru_cl_agent_service_mngr=>get_service(
                           iv_service = `ZPRU_IF_MMSG_SERVICE`
                           iv_context = zpru_if_agent_frw=>cs_context-st_persistence_message ).
    IF iv_environment_uuid IS INITIAL.
      lo_mmsg_service->query_mmsg(
        EXPORTING it_agent_uuid   = VALUE #( ( sign   = `I`
                                               option = `EQ`
                                               low    = ls_axc_head-agentuuid ) )
                  it_run_uuid     = VALUE #( ( sign   = `I`
                                               option = `EQ`
                                               low    = iv_built_run_uuid ) )
                  it_query_uuid   = VALUE #( ( sign   = `I`
                                               option = `EQ`
                                               low    = iv_built_query_uuid ) )
                  it_message_type = VALUE #( ( sign   = `I`
                                               option = `EQ`
                                               low    = zpru_if_short_memory_provider=>cs_msg_type-env ) )
        IMPORTING et_mmsg_k       = DATA(lt_mmsg_k) ).

    ELSE.
      lt_mmsg_k = VALUE #( ( messageuuid = iv_environment_uuid ) ).
    ENDIF.

    lo_mmsg_service->read_mmsg( EXPORTING it_mmsg_read_k = VALUE #( FOR <ls_k> IN lt_mmsg_k
                                                                    ( messageuuid              = <ls_k>-messageuuid
                                                                      control-messageuuid      = abap_true
                                                                      control-content          = abap_true
                                                                      control-messagetype      = abap_true
                                                                      control-messagecontentid = abap_true
                                                                      control-stage            = abap_true
                                                                      control-substage         = abap_true
                                                                      control-namespace        = abap_true
                                                                      control-username         = abap_true
                                                                      control-agentuuid        = abap_true
                                                                      control-runuuid          = abap_true
                                                                      control-queryuuid        = abap_true
                                                                      control-stepuuid         = abap_true
                                                                      control-messagedatetime  = abap_true
                                                                      control-createdby        = abap_true
                                                                      control-createdat        = abap_true
                                                                      control-changedby        = abap_true
                                                                      control-changedat        = abap_true  ) )
                                IMPORTING et_mmsg        = DATA(lt_mmsg) ).

    SORT lt_mmsg BY messagedatetime DESCENDING.
    DATA(ls_environment_message) = VALUE #( lt_mmsg[ 1 ] OPTIONAL ).

    DATA(lv_content) = get_utility( )->deserialize_xstring_2_json( ls_environment_message-content ).

    CALL TRANSFORMATION id
         SOURCE XML lv_content
         RESULT model = ro_api.
  ENDMETHOD.

  METHOD zpru_if_api_agent~complete_run.
    DATA lo_axc_service      TYPE REF TO zpru_if_axc_service.
    DATA lt_head_update_imp  TYPE zpru_if_axc_type_and_constant=>tt_head_update_imp.
    DATA lt_query_update_imp TYPE zpru_if_axc_type_and_constant=>tt_query_update_imp.
    DATA lt_step_update_imp  TYPE zpru_if_axc_type_and_constant=>tt_step_update_imp.
    DATA lt_axc_head         TYPE zpru_if_axc_type_and_constant=>tt_axc_head.
    DATA lt_axc_query        TYPE zpru_if_axc_type_and_constant=>tt_axc_query.
    DATA lt_axc_step         TYPE zpru_if_axc_type_and_constant=>tt_axc_step.
    DATA ls_axc_reported     TYPE zpru_if_agent_frw=>ts_axc_reported.
    DATA ls_axc_failed       TYPE zpru_if_agent_frw=>ts_axc_failed.

    IF iv_run_uuid IS INITIAL.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    lo_axc_service ?= zpru_cl_agent_service_mngr=>get_service( iv_service = `ZPRU_IF_AXC_SERVICE`
                                                               iv_context = zpru_if_agent_frw=>cs_context-standard ).

    lo_axc_service->read_header( EXPORTING it_head_read_k = VALUE #( ( runuuid = iv_run_uuid
                                                                       control = VALUE #(
                                                                           runuuid          = abap_true
                                                                           runid            = abap_true
                                                                           agentuuid        = abap_true
                                                                           userid           = abap_true
                                                                           runstartdatetime = abap_true
                                                                           runenddatetime   = abap_true
                                                                           createdby        = abap_true
                                                                           createdat        = abap_true
                                                                           changedby        = abap_true
                                                                           lastchanged      = abap_true
                                                                           locallastchanged = abap_true ) ) )
                                 IMPORTING et_axc_head    = lt_axc_head
                                 CHANGING  cs_reported    = ls_axc_reported
                                           cs_failed      = ls_axc_failed ).

    IF lt_axc_head IS INITIAL.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    lo_axc_service->rba_query( EXPORTING it_rba_query_k = VALUE #( ( runuuid = iv_run_uuid
                                                                     control = VALUE #(
                                                                         runuuid             = abap_true
                                                                         querynumber         = abap_true
                                                                         queryuuid           = abap_true
                                                                         querylanguage       = abap_true
                                                                         querystatus         = abap_true
                                                                         querystartdatetime  = abap_true
                                                                         queryenddatetime    = abap_true
                                                                         queryinputprompt    = abap_true
                                                                         querydecisionlog    = abap_true
                                                                         queryoutputresponse = abap_true ) ) )
                               IMPORTING et_axc_query   = lt_axc_query
                               CHANGING  cs_reported    = ls_axc_reported
                                         cs_failed      = ls_axc_failed ).

    IF lt_axc_query IS INITIAL.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    GET TIME STAMP FIELD DATA(lv_now).

    APPEND INITIAL LINE TO lt_head_update_imp ASSIGNING FIELD-SYMBOL(<ls_head_2_upd>).
    <ls_head_2_upd>-runuuid        = iv_run_uuid.
    <ls_head_2_upd>-runenddatetime = lv_now.
    <ls_head_2_upd>-control-runenddatetime = abap_true.

    lo_axc_service->rba_step( EXPORTING it_rba_step_k = VALUE #( FOR <ls_qk1>
                                                                 IN lt_axc_query
                                                                 ( queryuuid = <ls_qk1>-queryuuid
                                                                   control   = VALUE #(
                                                                       stepuuid           = abap_true
                                                                       stepnumber         = abap_true
                                                                       queryuuid          = abap_true
                                                                       runuuid            = abap_true
                                                                       tooluuid           = abap_true
                                                                       stepsequence       = abap_true
                                                                       stepstatus         = abap_true
                                                                       stepstartdatetime  = abap_true
                                                                       stependdatetime    = abap_true
                                                                       stepinputprompt    = abap_true
                                                                       stepoutputresponse = abap_true ) ) )
                              IMPORTING et_axc_step   = lt_axc_step
                              CHANGING  cs_reported   = ls_axc_reported
                                        cs_failed     = ls_axc_failed ).

    LOOP AT lt_axc_query ASSIGNING FIELD-SYMBOL(<ls_axc_query>).
      IF <ls_axc_query>-querystatus <> zpru_if_axc_type_and_constant=>sc_query_status-error.
        APPEND INITIAL LINE TO lt_query_update_imp ASSIGNING FIELD-SYMBOL(<ls_query_2_upd>).
        <ls_query_2_upd>-queryuuid        = <ls_axc_query>-queryuuid.
        <ls_query_2_upd>-querystatus      = zpru_if_axc_type_and_constant=>sc_query_status-complete.
        <ls_query_2_upd>-queryenddatetime = lv_now.
        <ls_query_2_upd>-control-querystatus      = abap_true.
        <ls_query_2_upd>-control-queryenddatetime = abap_true.
      ENDIF.

      LOOP AT lt_axc_step ASSIGNING FIELD-SYMBOL(<ls_axc_step>)
           WHERE queryuuid = <ls_axc_query>-queryuuid.
        IF <ls_axc_step>-stepstatus <> zpru_if_axc_type_and_constant=>sc_step_status-error.
          APPEND INITIAL LINE TO lt_step_update_imp ASSIGNING FIELD-SYMBOL(<ls_step_2_upd>).
          <ls_step_2_upd>-stepuuid        = <ls_axc_step>-stepuuid.
          <ls_step_2_upd>-stepstatus      = zpru_if_axc_type_and_constant=>sc_step_status-complete.
          <ls_step_2_upd>-stependdatetime = lv_now.
          <ls_step_2_upd>-control-stepstatus      = abap_true.
          <ls_step_2_upd>-control-stependdatetime = abap_true.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    IF lt_head_update_imp IS NOT INITIAL.
      lo_axc_service->update_header( EXPORTING it_head_update_imp = lt_head_update_imp
                                     CHANGING  cs_reported        = ls_axc_reported
                                               cs_failed          = ls_axc_failed ).
      IF ls_axc_failed-header IS NOT INITIAL.
        RAISE EXCEPTION NEW zpru_cx_agent_core( ).
      ENDIF.
    ENDIF.

    IF lt_query_update_imp IS NOT INITIAL.
      lo_axc_service->update_query( EXPORTING it_query_update_imp = lt_query_update_imp
                                    CHANGING  cs_reported         = ls_axc_reported
                                              cs_failed           = ls_axc_failed ).
      IF ls_axc_failed-query IS NOT INITIAL.
        RAISE EXCEPTION NEW zpru_cx_agent_core( ).
      ENDIF.
    ENDIF.

    IF lt_step_update_imp IS NOT INITIAL.
      lo_axc_service->update_step( EXPORTING it_step_update_imp = lt_step_update_imp
                                   CHANGING  cs_reported        = ls_axc_reported
                                             cs_failed          = ls_axc_failed ).
      IF ls_axc_failed-step IS NOT INITIAL.
        RAISE EXCEPTION NEW zpru_cx_agent_core( ).
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD zpru_if_api_agent~get_agent_metadata.
    DATA lo_adf_service         TYPE REF TO zpru_if_adf_service.
    DATA lt_agent_read_k        TYPE zpru_if_adf_type_and_constant=>tt_agent_read_k.
    DATA lo_agty_service        TYPE REF TO zpru_if_agty_service.
    DATA lo_agent_info_provider TYPE REF TO zpru_if_agent_info_provider.
    DATA lo_prompt_provider     TYPE REF TO zpru_if_prompt_provider.

    CLEAR et_agent_info.

    IF it_agent_uuid IS INITIAL.
      RETURN.
    ENDIF.

    lo_adf_service ?= zpru_cl_agent_service_mngr=>get_service( iv_service = `ZPRU_IF_ADF_SERVICE`
                                                               iv_context = zpru_if_agent_frw=>cs_context-standard ).

    LOOP AT it_agent_uuid ASSIGNING FIELD-SYMBOL(<lv_agent_uuid>).
      APPEND INITIAL LINE TO lt_agent_read_k ASSIGNING FIELD-SYMBOL(<ls_agent_read_k>).
      <ls_agent_read_k>-agentuuid                    = <lv_agent_uuid>.
      <ls_agent_read_k>-control-agentuuid            = abap_true.
      <ls_agent_read_k>-control-agentname            = abap_true.
      <ls_agent_read_k>-control-agenttype            = abap_true.
      <ls_agent_read_k>-control-decisionprovider     = abap_true.
      <ls_agent_read_k>-control-shortmemoryprovider  = abap_true.
      <ls_agent_read_k>-control-longmemoryprovider   = abap_true.
      <ls_agent_read_k>-control-agentinfoprovider    = abap_true.
      <ls_agent_read_k>-control-systempromptprovider = abap_true.
      <ls_agent_read_k>-control-agentmapper          = abap_true.
      <ls_agent_read_k>-control-agentstatus          = abap_true.
      <ls_agent_read_k>-control-createdby            = abap_true.
      <ls_agent_read_k>-control-createdat            = abap_true.
      <ls_agent_read_k>-control-changedby            = abap_true.
      <ls_agent_read_k>-control-lastchanged          = abap_true.
      <ls_agent_read_k>-control-locallastchanged     = abap_true.
    ENDLOOP.

    lo_adf_service->read_agent( EXPORTING it_agent_read_k = lt_agent_read_k
                                IMPORTING et_agent        = DATA(lt_agent) ).

    IF lt_agent IS INITIAL.
      RETURN.
    ENDIF.

    lo_agty_service ?= zpru_cl_agent_service_mngr=>get_service( iv_service = `ZPRU_IF_AGTY_SERVICE`
                                                                iv_context = zpru_if_agent_frw=>cs_context-standard ).

    lo_agty_service->query_agent_type( EXPORTING it_agent_type = VALUE #( FOR <ls_ag>
                                                                          IN lt_agent
                                                                          ( sign   = `I`
                                                                            option = `EQ`
                                                                            low    = <ls_ag>-agenttype  ) )
                                       IMPORTING et_agty_k     = DATA(lt_agent_type_key) ).

    IF lt_agent_type_key IS NOT INITIAL.
      lo_agty_service->read_agent_type(
        EXPORTING it_agty_read_k = VALUE #( FOR <ls_agt>
                                            IN lt_agent_type_key
                                            ( agenttype                   = <ls_agt>-agenttype
                                              control-agenttype           = abap_true
                                              control-shortmemoryvolume   = abap_true
                                              control-discardstrategy     = abap_true
                                              control-summarystrategy     = abap_true
                                              control-maximumnumberofloop = abap_true ) )
        IMPORTING et_agty        = DATA(lt_agent_type) ).
    ENDIF.

    LOOP AT lt_agent ASSIGNING FIELD-SYMBOL(<ls_agent>).

      APPEND INITIAL LINE TO et_agent_info ASSIGNING FIELD-SYMBOL(<ls_agent_info>).

      <ls_agent_info>-agentuuid = <ls_agent>-agentuuid.
      <ls_agent_info>-agent     = <ls_agent>.

      ASSIGN lt_agent_type[ agenttype = <ls_agent>-agenttype ] TO FIELD-SYMBOL(<ls_agent_type>).
      IF sy-subrc = 0.
        <ls_agent_info>-agenttype = <ls_agent_type>.
      ENDIF.

      CREATE OBJECT lo_agent_info_provider TYPE (<ls_agent>-agentinfoprovider).
      IF sy-subrc = 0.
        <ls_agent_info>-agentinfo = lo_agent_info_provider->get_abap_agent_info( iv_agent_uuid = <ls_agent>-agentuuid ).
      ENDIF.

      CREATE OBJECT lo_prompt_provider TYPE (<ls_agent>-systempromptprovider).
      IF sy-subrc = 0.
        <ls_agent_info>-systemprompt = lo_prompt_provider->get_abap_system_prompt(
                                           iv_agent_uuid = <ls_agent>-agentuuid ).
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD zpru_if_api_agent~get_agent_tools_metadata.
    DATA lo_tool_info_provider   TYPE REF TO zpru_if_tool_info_provider.
    DATA lo_tool_schema_provider TYPE REF TO zpru_if_tool_schema_provider.
    DATA lo_structure_schema     TYPE REF TO cl_abap_structdescr.
    DATA lt_component_table      TYPE cl_abap_structdescr=>component_table.
    DATA lo_adf_service          TYPE REF TO zpru_if_adf_service.
    DATA lt_agent_read_k         TYPE zpru_if_adf_type_and_constant=>tt_agent_read_k.

    CLEAR et_agent_tool_info.

    IF it_agent_uuid IS INITIAL.
      RETURN.
    ENDIF.

    lo_adf_service ?= zpru_cl_agent_service_mngr=>get_service( iv_service = `ZPRU_IF_ADF_SERVICE`
                                                               iv_context = zpru_if_agent_frw=>cs_context-standard ).

    LOOP AT it_agent_uuid ASSIGNING FIELD-SYMBOL(<lv_agent_uuid>).
      APPEND INITIAL LINE TO lt_agent_read_k ASSIGNING FIELD-SYMBOL(<ls_agent_read_k>).
      <ls_agent_read_k>-agentuuid                    = <lv_agent_uuid>.
      <ls_agent_read_k>-control-agentuuid            = abap_true.
      <ls_agent_read_k>-control-agentname            = abap_true.
      <ls_agent_read_k>-control-agenttype            = abap_true.
      <ls_agent_read_k>-control-decisionprovider     = abap_true.
      <ls_agent_read_k>-control-shortmemoryprovider  = abap_true.
      <ls_agent_read_k>-control-longmemoryprovider   = abap_true.
      <ls_agent_read_k>-control-agentinfoprovider    = abap_true.
      <ls_agent_read_k>-control-systempromptprovider = abap_true.
      <ls_agent_read_k>-control-agentmapper          = abap_true.
      <ls_agent_read_k>-control-agentstatus          = abap_true.
      <ls_agent_read_k>-control-createdby            = abap_true.
      <ls_agent_read_k>-control-createdat            = abap_true.
      <ls_agent_read_k>-control-changedby            = abap_true.
      <ls_agent_read_k>-control-lastchanged          = abap_true.
      <ls_agent_read_k>-control-locallastchanged     = abap_true.
    ENDLOOP.

    lo_adf_service->read_agent( EXPORTING it_agent_read_k = lt_agent_read_k
                                IMPORTING et_agent        = DATA(lt_agent) ).

    IF lt_agent IS INITIAL.
      RETURN.
    ENDIF.

    lo_adf_service->rba_tool( EXPORTING it_rba_tool_k = VALUE #( FOR <ls_k> IN lt_agent
                                                                 ( agentuuid                  = <ls_k>-agentuuid
                                                                   control-tooluuid           = abap_true
                                                                   control-agentuuid          = abap_true
                                                                   control-toolname           = abap_true
                                                                   control-toolprovider       = abap_true
                                                                   control-steptype           = abap_true
                                                                   control-toolschemaprovider = abap_true
                                                                   control-toolinfoprovider   = abap_true
                                                                   control-toolisborrowed     = abap_true
                                                                   control-toolistransient    = abap_true    ) )
                              IMPORTING et_tool       = DATA(lt_agent_tools) ).

    LOOP AT lt_agent_tools ASSIGNING FIELD-SYMBOL(<ls_agent_tool>).

      APPEND INITIAL LINE TO et_agent_tool_info ASSIGNING FIELD-SYMBOL(<ls_agent_tool_info>).
      <ls_agent_tool_info>-agentuuid = <ls_agent_tool>-agentuuid.
      <ls_agent_tool_info>-tooluuid  = <ls_agent_tool>-tooluuid.
      <ls_agent_tool_info>-agenttool = <ls_agent_tool>.

      CREATE OBJECT lo_tool_info_provider TYPE (<ls_agent_tool>-toolinfoprovider).
      IF sy-subrc = 0.
        <ls_agent_tool_info>-toolinfo = lo_tool_info_provider->get_abap_tool_info(
                                            is_tool_master_data = <ls_agent_tool> ).
      ENDIF.

      CREATE OBJECT lo_tool_schema_provider TYPE (<ls_agent_tool>-toolschemaprovider).
      IF sy-subrc = 0.

        CLEAR lo_structure_schema.
        lo_structure_schema = lo_tool_schema_provider->input_rtts_schema( is_tool_master_data = <ls_agent_tool>  ).

        CLEAR lt_component_table.
        lt_component_table = lo_structure_schema->get_components( ).

        LOOP AT lt_component_table ASSIGNING FIELD-SYMBOL(<ls_component_table>).
          APPEND INITIAL LINE TO <ls_agent_tool_info>-toolinputcomponents ASSIGNING FIELD-SYMBOL(<ls_comp_target>).
          <ls_comp_target>-name = <ls_component_table>-name.
          <ls_comp_target>-type = <ls_component_table>-type->absolute_name.
        ENDLOOP.
      ENDIF.

      lo_tool_schema_provider->input_json_schema( EXPORTING is_tool_master_data = <ls_agent_tool>
                                                  IMPORTING es_json_structure   = DATA(ls_json_structure) ).

      <ls_agent_tool_info>-toolinputschema = ls_json_structure.

    ENDLOOP.
  ENDMETHOD.

  METHOD zpru_if_api_agent~read_agent_definition.
    DATA lo_adf_service TYPE REF TO zpru_if_adf_service.

    CLEAR: et_agent,
           et_agent_k,
           et_tool,
           et_tool_agent_link.

    IF     it_agent_name             IS INITIAL
       AND it_agent_type             IS INITIAL
       AND it_decision_provider      IS INITIAL
       AND it_short_memory_provider  IS INITIAL
       AND it_long_memory_provider   IS INITIAL
       AND it_agent_info_provider    IS INITIAL
       AND it_system_prompt_provider IS INITIAL
       AND it_agent_mapper           IS INITIAL
       AND it_status                 IS INITIAL.
      RETURN.
    ENDIF.

    lo_adf_service ?= zpru_cl_agent_service_mngr=>get_service( iv_service = `ZPRU_IF_ADF_SERVICE`
                                                               iv_context = zpru_if_agent_frw=>cs_context-standard ).

    lo_adf_service->query_agent( EXPORTING it_agent_name             = it_agent_name
                                           it_agent_type             = it_agent_type
                                           it_decision_provider      = it_decision_provider
                                           it_short_memory_provider  = it_short_memory_provider
                                           it_long_memory_provider   = it_long_memory_provider
                                           it_agent_info_provider    = it_agent_info_provider
                                           it_system_prompt_provider = it_system_prompt_provider
                                           it_agent_mapper           = it_agent_mapper
                                           it_status                 = it_status
                                 IMPORTING et_agent_k                = et_agent_k
                                           et_tool_agent_link        = et_tool_agent_link ).

    IF et_agent_k IS INITIAL.
      RETURN.
    ENDIF.

    IF et_agent IS SUPPLIED.
      lo_adf_service->read_agent( EXPORTING it_agent_read_k = VALUE #( FOR <ls_k> IN et_agent_k
                                                                       ( agentuuid                    = <ls_k>-agentuuid
                                                                         control-agentuuid            = abap_true
                                                                         control-agentname            = abap_true
                                                                         control-agenttype            = abap_true
                                                                         control-decisionprovider     = abap_true
                                                                         control-shortmemoryprovider  = abap_true
                                                                         control-longmemoryprovider   = abap_true
                                                                         control-agentinfoprovider    = abap_true
                                                                         control-systempromptprovider = abap_true
                                                                         control-agentmapper          = abap_true
                                                                         control-agentstatus          = abap_true
                                                                         control-createdby            = abap_true
                                                                         control-createdat            = abap_true
                                                                         control-changedby            = abap_true
                                                                         control-lastchanged          = abap_true
                                                                         control-locallastchanged     = abap_true ) )
                                  IMPORTING et_agent        = et_agent ).
    ENDIF.

    IF et_tool IS SUPPLIED.
      lo_adf_service->rba_tool( EXPORTING it_rba_tool_k = VALUE #( FOR <ls_k> IN et_agent_k
                                                                   ( agentuuid                  = <ls_k>-agentuuid
                                                                     control-tooluuid           = abap_true
                                                                     control-agentuuid          = abap_true
                                                                     control-toolname           = abap_true
                                                                     control-toolprovider       = abap_true
                                                                     control-steptype           = abap_true
                                                                     control-toolschemaprovider = abap_true
                                                                     control-toolinfoprovider   = abap_true
                                                                     control-toolisborrowed     = abap_true
                                                                     control-toolistransient    = abap_true    ) )
                                IMPORTING et_tool       = et_tool ).
    ENDIF.
  ENDMETHOD.

  METHOD zpru_if_api_agent~get_utility.
    ro_util = get_utility( ).
  ENDMETHOD.

  METHOD zpru_if_api_agent~create_agent_definition.
    DATA lo_adf_service TYPE REF TO zpru_if_adf_service.

    CLEAR: es_reported,
           es_failed,
           es_mapped.

    IF it_agent_create IS INITIAL.
      RETURN.
    ENDIF.

    lo_adf_service ?= zpru_cl_agent_service_mngr=>get_service(
                          iv_service = `ZPRU_IF_ADF_SERVICE`
                          iv_context = zpru_if_agent_frw=>cs_context-standard ).

    lo_adf_service->create_agent(
      EXPORTING
        it_agent_create_imp = it_agent_create
      CHANGING
        cs_reported         = es_reported
        cs_failed           = es_failed
        cs_mapped           = es_mapped ).

    IF it_tool_create IS INITIAL.
      RETURN.
    ENDIF.

    lo_adf_service->cba_tool(
      EXPORTING
        it_tool_create_imp = it_tool_create
      CHANGING
        cs_reported        = es_reported
        cs_failed          = es_failed
        cs_mapped          = es_mapped ).
  ENDMETHOD.

ENDCLASS.
