INTERFACE zpru_if_api_agent
  PUBLIC.

  INTERFACES zpru_if_agent_frw.

  TYPES tv_agent_name TYPE char100.

  METHODS initialize
    IMPORTING iv_agent_name TYPE zpru_if_api_agent=>tv_agent_name
    RAISING   zpru_cx_agent_core.

  METHODS set_input_query
    IMPORTING iv_input_query TYPE zpru_if_agent_frw=>ts_json
    RAISING   zpru_cx_agent_core.

  METHODS build_execution
    RETURNING VALUE(rv_built_run_uuid) TYPE sysuuid_x16
    RAISING   zpru_cx_agent_core.

  METHODS save_execution
    IMPORTING iv_do_commit             TYPE abap_boolean
              iv_run_uuid              TYPE sysuuid_x16 OPTIONAL
    RETURNING VALUE(rv_saved_run_uuid) TYPE sysuuid_x16
    RAISING   zpru_cx_agent_core.

  METHODS run
    IMPORTING iv_run_uuid   TYPE sysuuid_x16
              iv_query_uuid TYPE sysuuid_x16 optiONAL
    RAISING   zpru_cx_agent_core.

  METHODS rerun
    IMPORTING iv_run_uuid   TYPE sysuuid_x16
              iv_query_uuid TYPE sysuuid_x16 opTIONAL
    RAISING   zpru_cx_agent_core.

  METHODS rerun_from_step
    IMPORTING iv_run_uuid   TYPE sysuuid_x16
              iv_query_uuid TYPE sysuuid_x16
              iv_starting_step_uuid  TYPE sysuuid_x16
    RAISING   zpru_cx_agent_core.

ENDINTERFACE.
