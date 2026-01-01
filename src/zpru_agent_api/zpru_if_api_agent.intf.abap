INTERFACE zpru_if_api_agent
  PUBLIC.

  INTERFACES zpru_if_agent_frw.

  TYPES tv_agent_name TYPE char100.

  METHODS add_query_2_run
    IMPORTING iv_run_uuid     TYPE sysuuid_x16
              iv_input_query  TYPE zpru_if_agent_frw=>ts_json
    EXPORTING ev_run_uuid     TYPE sysuuid_x16
              ev_query_uuid   TYPE sysuuid_x16
    CHANGING  cs_axc_reported TYPE zpru_if_agent_frw=>ts_axc_reported OPTIONAL
              cs_axc_failed   TYPE zpru_if_agent_frw=>ts_axc_failed OPTIONAL
              cs_axc_mapped   TYPE zpru_if_agent_frw=>ts_axc_mapped OPTIONAL
              cs_adf_reported TYPE zpru_if_agent_frw=>ts_adf_reported   OPTIONAL
              cs_adf_failed   TYPE zpru_if_agent_frw=>ts_adf_failed OPTIONAL
    RAISING   zpru_cx_agent_core.

  METHODS initialize
    IMPORTING iv_agent_name     TYPE zpru_if_api_agent=>tv_agent_name
              io_parent_controller TYPE REF TO zpru_if_agent_controller OPTIONAL
    EXPORTING es_agent          TYPE zpru_if_adf_type_and_constant=>ts_agent
              et_tools          TYPE zpru_if_adf_type_and_constant=>tt_agent_tool
    CHANGING  cs_adf_reported   TYPE zpru_if_agent_frw=>ts_adf_reported OPTIONAL
              cs_adf_failed     TYPE zpru_if_agent_frw=>ts_adf_failed OPTIONAL
    RAISING   zpru_cx_agent_core.

  METHODS set_input_query
    IMPORTING iv_input_query  TYPE zpru_if_agent_frw=>ts_json
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
    IMPORTING iv_run_uuid       TYPE sysuuid_x16
              iv_query_uuid     TYPE sysuuid_x16 OPTIONAL
    EXPORTING eo_final_response TYPE REF TO zpru_if_payload
    CHANGING  cs_axc_reported   TYPE zpru_if_agent_frw=>ts_axc_reported OPTIONAL
              cs_axc_failed     TYPE zpru_if_agent_frw=>ts_axc_failed OPTIONAL
              cs_adf_reported   TYPE zpru_if_agent_frw=>ts_adf_reported OPTIONAL
              cs_adf_failed     TYPE zpru_if_agent_frw=>ts_adf_failed OPTIONAL
    RAISING   zpru_cx_agent_core.

  METHODS rerun
    IMPORTING iv_run_uuid       TYPE sysuuid_x16
              iv_query_uuid     TYPE sysuuid_x16
    EXPORTING eo_final_response TYPE REF TO zpru_if_payload
    CHANGING  cs_axc_reported   TYPE zpru_if_agent_frw=>ts_axc_reported OPTIONAL
              cs_axc_failed     TYPE zpru_if_agent_frw=>ts_axc_failed OPTIONAL
              cs_adf_reported   TYPE zpru_if_agent_frw=>ts_adf_reported OPTIONAL
              cs_adf_failed     TYPE zpru_if_agent_frw=>ts_adf_failed OPTIONAL
    RAISING   zpru_cx_agent_core.

  METHODS rerun_from_step
    IMPORTING iv_run_uuid           TYPE sysuuid_x16
              iv_query_uuid         TYPE sysuuid_x16
              iv_starting_step_uuid TYPE sysuuid_x16
              iv_new_step_prompt    TYPE string OPTIONAL
    EXPORTING eo_final_response     TYPE REF TO zpru_if_payload
    CHANGING  cs_axc_reported       TYPE zpru_if_agent_frw=>ts_axc_reported OPTIONAL
              cs_axc_failed         TYPE zpru_if_agent_frw=>ts_axc_failed OPTIONAL
              cs_adf_reported       TYPE zpru_if_agent_frw=>ts_adf_reported OPTIONAL
              cs_adf_failed         TYPE zpru_if_agent_frw=>ts_adf_failed OPTIONAL
    RAISING   zpru_cx_agent_core.

ENDINTERFACE.
