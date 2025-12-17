INTERFACE zpru_if_api_agent
  PUBLIC.

  INTERFACES zpru_if_agent_frw.

  TYPES tv_agent_name TYPE char100.

  METHODS initialize
    IMPORTING iv_agent_name   TYPE zpru_if_api_agent=>tv_agent_name
    EXPORTING es_agent        TYPE zpru_if_adf_type_and_constant=>ts_agent
              et_tools        TYPE zpru_if_adf_type_and_constant=>tt_agent_tool
    CHANGING  cs_adf_reported TYPE zpru_if_agent_frw=>ts_adf_reported
              cs_adf_failed   TYPE zpru_if_agent_frw=>ts_adf_failed
    RAISING   zpru_cx_agent_core.

  METHODS set_input_query
    IMPORTING iv_input_query  TYPE zpru_if_agent_frw=>ts_json
              iv_agent_uuid   TYPE sysuuid_x16
    CHANGING  cs_adf_reported TYPE zpru_if_agent_frw=>ts_adf_reported
              cs_adf_failed   TYPE zpru_if_agent_frw=>ts_adf_failed
    RAISING   zpru_cx_agent_core.

  METHODS build_execution
    IMPORTING iv_agent_uuid     TYPE sysuuid_x16
    EXPORTING ev_built_run_uuid TYPE sysuuid_x16
    CHANGING  cs_axc_reported   TYPE zpru_if_agent_frw=>ts_axc_reported
              cs_axc_failed     TYPE zpru_if_agent_frw=>ts_axc_failed
              cs_axc_mapped     TYPE zpru_if_agent_frw=>ts_axc_mapped
              cs_adf_reported   TYPE zpru_if_agent_frw=>ts_adf_reported
              cs_adf_failed     TYPE zpru_if_agent_frw=>ts_adf_failed
    RAISING   zpru_cx_agent_core.

  METHODS save_execution
    IMPORTING iv_do_commit    TYPE abap_boolean
    CHANGING  cs_axc_reported TYPE zpru_if_agent_frw=>ts_axc_reported
              cs_axc_failed   TYPE zpru_if_agent_frw=>ts_axc_failed
              cs_axc_mapped   TYPE zpru_if_agent_frw=>ts_axc_mapped
    RAISING   zpru_cx_agent_core.

  METHODS run
    IMPORTING iv_run_uuid     TYPE sysuuid_x16
              iv_query_uuid   TYPE sysuuid_x16 OPTIONAL
    CHANGING  cs_axc_reported TYPE zpru_if_agent_frw=>ts_axc_reported
              cs_axc_failed   TYPE zpru_if_agent_frw=>ts_axc_failed
              cs_adf_reported TYPE zpru_if_agent_frw=>ts_adf_reported
              cs_adf_failed   TYPE zpru_if_agent_frw=>ts_adf_failed
    RAISING   zpru_cx_agent_core.

  METHODS rerun
    IMPORTING iv_run_uuid     TYPE sysuuid_x16
              iv_query_uuid   TYPE sysuuid_x16
    CHANGING  cs_axc_reported TYPE zpru_if_agent_frw=>ts_axc_reported
              cs_axc_failed   TYPE zpru_if_agent_frw=>ts_axc_failed
              cs_adf_reported TYPE zpru_if_agent_frw=>ts_adf_reported
              cs_adf_failed   TYPE zpru_if_agent_frw=>ts_adf_failed
    RAISING   zpru_cx_agent_core.

  METHODS rerun_from_step
    IMPORTING iv_run_uuid           TYPE sysuuid_x16
              iv_query_uuid         TYPE sysuuid_x16
              iv_starting_step_uuid TYPE sysuuid_x16
              iv_new_step_prompt    TYPE string OPTIONAL
    CHANGING  cs_axc_reported       TYPE zpru_if_agent_frw=>ts_axc_reported
              cs_axc_failed         TYPE zpru_if_agent_frw=>ts_axc_failed
              cs_adf_reported       TYPE zpru_if_agent_frw=>ts_adf_reported
              cs_adf_failed         TYPE zpru_if_agent_frw=>ts_adf_failed
    RAISING   zpru_cx_agent_core.

ENDINTERFACE.
