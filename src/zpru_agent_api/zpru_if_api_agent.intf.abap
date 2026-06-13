INTERFACE zpru_if_api_agent
  PUBLIC.

  TYPES tv_agent_name TYPE char100.
  TYPES tt_agent_name TYPE STANDARD TABLE OF tv_agent_name WITH EMPTY KEY.
  TYPES tt_agent_uuid TYPE STANDARD TABLE OF sysuuid_x16 WITH EMPTY KEY.

  TYPES tt_agent_name_r             TYPE RANGE OF char100.
  TYPES tt_agent_type_r             TYPE RANGE OF zpru_de_agent_type.
  TYPES tt_decision_provider_r      TYPE RANGE OF char30.
  TYPES tt_short_memory_provider_r  TYPE RANGE OF char30.
  TYPES tt_long_memory_provider_r   TYPE RANGE OF char30.
  TYPES tt_agent_info_provider_r    TYPE RANGE OF char30.
  TYPES tt_system_prompt_provider_r TYPE RANGE OF char30.
  TYPES tt_agent_mapper_r            TYPE RANGE OF char30.
  TYPES tt_status_r                 TYPE RANGE OF zpru_de_adf_agent_status.

  TYPES: BEGIN OF ts_agent_k,
           agentuuid TYPE sysuuid_x16,
         END OF ts_agent_k.

  TYPES tt_agent_k TYPE STANDARD TABLE OF ts_agent_k WITH EMPTY KEY.

  TYPES: BEGIN OF ts_agent_tool_k,
           tooluuid TYPE sysuuid_x16,
         END OF ts_agent_tool_k.

  TYPES tt_agent_tool_k TYPE STANDARD TABLE OF ts_agent_tool_k WITH EMPTY KEY.

  TYPES: BEGIN OF ts_tool_agent_link.
           INCLUDE TYPE zpru_if_adf_type_and_constant=>ts_agent_k.
           INCLUDE TYPE zpru_if_adf_type_and_constant=>ts_agent_tool_k.
  TYPES: END OF ts_tool_agent_link.

  TYPES tt_tool_agent_link TYPE STANDARD TABLE OF ts_tool_agent_link WITH EMPTY KEY.

  TYPES ts_agent        TYPE zpru_s_agent.
  TYPES tt_agent        TYPE STANDARD TABLE OF ts_agent WITH EMPTY KEY.

  TYPES ts_agent_tool   TYPE zpru_s_agent_tool.
  TYPES tt_agent_tool   TYPE STANDARD TABLE OF ts_agent_tool WITH EMPTY KEY.

  METHODS add_query_2_run
    IMPORTING iv_run_uuid          TYPE sysuuid_x16
              is_input_query       TYPE zpru_s_prompt
              io_parent_controller TYPE REF TO zpru_if_agent_controller OPTIONAL
    EXPORTING ev_run_uuid          TYPE sysuuid_x16
              ev_query_uuid        TYPE sysuuid_x16
    CHANGING  cs_axc_reported      TYPE zpru_if_agent_frw=>ts_axc_reported OPTIONAL
              cs_axc_failed        TYPE zpru_if_agent_frw=>ts_axc_failed OPTIONAL
              cs_axc_mapped        TYPE zpru_if_agent_frw=>ts_axc_mapped OPTIONAL
              cs_adf_reported      TYPE zpru_if_agent_frw=>ts_adf_reported   OPTIONAL
              cs_adf_failed        TYPE zpru_if_agent_frw=>ts_adf_failed OPTIONAL
    RAISING   zpru_cx_agent_core.

  METHODS setup_agent
    IMPORTING iv_agent_name        TYPE zpru_if_api_agent=>tv_agent_name
              io_parent_controller TYPE REF TO zpru_if_agent_controller OPTIONAL
    EXPORTING es_agent             TYPE zpru_if_adf_type_and_constant=>ts_agent
              et_tools             TYPE zpru_if_adf_type_and_constant=>tt_agent_tool
    CHANGING  cs_adf_reported      TYPE zpru_if_agent_frw=>ts_adf_reported OPTIONAL
              cs_adf_failed        TYPE zpru_if_agent_frw=>ts_adf_failed OPTIONAL
    RAISING   zpru_cx_agent_core.

  METHODS set_input_query
    IMPORTING is_input_query  TYPE zpru_s_prompt
              iv_agent_uuid   TYPE sysuuid_x16
    CHANGING  cs_adf_reported TYPE zpru_if_agent_frw=>ts_adf_reported OPTIONAL
              cs_adf_failed   TYPE zpru_if_agent_frw=>ts_adf_failed OPTIONAL
    RAISING   zpru_cx_agent_core.

  METHODS build_execution
    IMPORTING iv_agent_uuid       TYPE sysuuid_x16
    EXPORTING ev_built_run_uuid   TYPE sysuuid_x16
              ev_built_query_uuid TYPE sysuuid_x16
    CHANGING  cs_axc_reported     TYPE zpru_if_agent_frw=>ts_axc_reported OPTIONAL
              cs_axc_failed       TYPE zpru_if_agent_frw=>ts_axc_failed OPTIONAL
              cs_axc_mapped       TYPE zpru_if_agent_frw=>ts_axc_mapped OPTIONAL
              cs_adf_reported     TYPE zpru_if_agent_frw=>ts_adf_reported OPTIONAL
              cs_adf_failed       TYPE zpru_if_agent_frw=>ts_adf_failed OPTIONAL
    RAISING   zpru_cx_agent_core.

  METHODS save_execution
    IMPORTING iv_do_commit    TYPE abap_boolean
    CHANGING  cs_axc_reported TYPE zpru_if_agent_frw=>ts_axc_reported OPTIONAL
              cs_axc_failed   TYPE zpru_if_agent_frw=>ts_axc_failed OPTIONAL
              cs_axc_mapped   TYPE zpru_if_agent_frw=>ts_axc_mapped OPTIONAL
    RAISING   zpru_cx_agent_core.

  METHODS run
    IMPORTING iv_run_uuid            TYPE sysuuid_x16
              iv_query_uuid          TYPE sysuuid_x16 OPTIONAL
    EXPORTING eo_final_response      TYPE REF TO zpru_if_payload
              eo_executed_controller TYPE REF TO zpru_if_agent_controller
    CHANGING  cs_axc_reported        TYPE zpru_if_agent_frw=>ts_axc_reported OPTIONAL
              cs_axc_failed          TYPE zpru_if_agent_frw=>ts_axc_failed OPTIONAL
              cs_adf_reported        TYPE zpru_if_agent_frw=>ts_adf_reported OPTIONAL
              cs_adf_failed          TYPE zpru_if_agent_frw=>ts_adf_failed OPTIONAL
    RAISING   zpru_cx_agent_core.

  METHODS rerun
    IMPORTING iv_run_uuid            TYPE sysuuid_x16
              iv_query_uuid          TYPE sysuuid_x16
    EXPORTING eo_final_response      TYPE REF TO zpru_if_payload
              eo_executed_controller TYPE REF TO zpru_if_agent_controller
    CHANGING  cs_axc_reported        TYPE zpru_if_agent_frw=>ts_axc_reported OPTIONAL
              cs_axc_failed          TYPE zpru_if_agent_frw=>ts_axc_failed OPTIONAL
              cs_adf_reported        TYPE zpru_if_agent_frw=>ts_adf_reported OPTIONAL
              cs_adf_failed          TYPE zpru_if_agent_frw=>ts_adf_failed OPTIONAL
    RAISING   zpru_cx_agent_core.

  METHODS rerun_from_step
    IMPORTING iv_run_uuid            TYPE sysuuid_x16
              iv_query_uuid          TYPE sysuuid_x16
              iv_starting_step_uuid  TYPE sysuuid_x16
              iv_new_step_prompt     TYPE string OPTIONAL
    EXPORTING eo_final_response      TYPE REF TO zpru_if_payload
              eo_executed_controller TYPE REF TO zpru_if_agent_controller
    CHANGING  cs_axc_reported        TYPE zpru_if_agent_frw=>ts_axc_reported OPTIONAL
              cs_axc_failed          TYPE zpru_if_agent_frw=>ts_axc_failed OPTIONAL
              cs_adf_reported        TYPE zpru_if_agent_frw=>ts_adf_reported OPTIONAL
              cs_adf_failed          TYPE zpru_if_agent_frw=>ts_adf_failed OPTIONAL
    RAISING   zpru_cx_agent_core.

  METHODS restore_environment
    IMPORTING iv_built_run_uuid   TYPE sysuuid_x16
              iv_built_query_uuid TYPE sysuuid_x16
              iv_environment_uuid TYPE sysuuid_x16 OPTIONAL
    RETURNING VALUE(ro_api)       TYPE REF TO zpru_if_api_agent
    RAISING   zpru_cx_agent_core.

  METHODS post_environment
    IMPORTING iv_agent_uuid       TYPE sysuuid_x16
              iv_built_run_uuid   TYPE sysuuid_x16
              iv_built_query_uuid TYPE sysuuid_x16
    EXPORTING ev_environment_uuid TYPE sysuuid_x16
    RAISING   zpru_cx_agent_core.

  METHODS set_rap_context_flag
    IMPORTING iv_is_rap_context TYPE abap_boolean
    RAISING   zpru_cx_agent_core.

  METHODS set_loop_execution
    IMPORTING iv_is_loop_execution TYPE abap_boolean
    RAISING   zpru_cx_agent_core.

  METHODS complete_run
    IMPORTING iv_run_uuid TYPE sysuuid_x16
    RAISING   zpru_cx_agent_core.

  METHODS get_agent_metadata
    IMPORTING it_agent_uuid TYPE tt_agent_uuid
    EXPORTING et_agent_info TYPE zpru_tt_api_agent_info
    RAISING   zpru_cx_agent_core.

  METHODS get_agent_tools_metadata
    IMPORTING it_agent_uuid      TYPE tt_agent_uuid
    EXPORTING et_agent_tool_info TYPE zpru_tt_api_tool_info
    RAISING   zpru_cx_agent_core.

  METHODS read_agent_definition
    IMPORTING it_agent_name             TYPE tt_agent_name_r             OPTIONAL
              it_agent_type             TYPE tt_agent_type_r             OPTIONAL
              it_decision_provider      TYPE tt_decision_provider_r      OPTIONAL
              it_short_memory_provider  TYPE tt_short_memory_provider_r  OPTIONAL
              it_long_memory_provider   TYPE tt_long_memory_provider_r   OPTIONAL
              it_agent_info_provider    TYPE tt_agent_info_provider_r    OPTIONAL
              it_system_prompt_provider TYPE tt_system_prompt_provider_r OPTIONAL
              it_agent_mapper           TYPE tt_agent_mapper_r           OPTIONAL
              it_status                 TYPE tt_status_r                 OPTIONAL
    EXPORTING et_agent_k                TYPE tt_agent_k
              et_tool_agent_link        TYPE tt_tool_agent_link
              et_agent                  TYPE tt_agent
              et_tool                   TYPE tt_agent_tool
    RAISING   zpru_cx_agent_core.

  METHODS get_utility
    RETURNING VALUE(ro_util) TYPE REF TO zpru_if_agent_util
    RAISING   zpru_cx_agent_core.

  METHODS create_agent_definition
    IMPORTING it_agent_create     TYPE zpru_if_adf_type_and_constant=>tt_agent_create_imp
              it_tool_create      TYPE zpru_if_adf_type_and_constant=>tt_tool_create_imp
    EXPORTING es_reported         TYPE zpru_if_agent_frw=>ts_adf_reported
              es_failed           TYPE zpru_if_agent_frw=>ts_adf_failed
              es_mapped           TYPE zpru_if_agent_frw=>ts_adf_mapped
    RAISING   zpru_cx_agent_core.

ENDINTERFACE.
