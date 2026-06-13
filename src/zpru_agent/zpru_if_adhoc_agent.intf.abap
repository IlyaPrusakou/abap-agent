INTERFACE zpru_if_adhoc_agent
  PUBLIC .

  METHODS create_agent
    IMPORTING is_agent_create     TYPE zpru_if_adf_type_and_constant=>ts_agent_create_imp
              it_tool_create      TYPE zpru_if_adf_type_and_constant=>tt_tool_create_imp
    EXPORTING es_reported         TYPE zpru_if_agent_frw=>ts_adf_reported
              es_failed           TYPE zpru_if_agent_frw=>ts_adf_failed
              es_mapped           TYPE zpru_if_agent_frw=>ts_adf_mapped
    RETURNING VALUE(rv_agent_name) TYPE zpru_if_api_agent=>tv_agent_name
    RAISING   zpru_cx_agent_core.

  METHODS execute_agent
    IMPORTING iv_agent_name       TYPE zpru_if_api_agent=>tv_agent_name
              iv_input_query      TYPE string
              iv_complete_run     TYPE abap_boolean DEFAULT abap_false
    EXPORTING ev_response         TYPE zpru_if_agent_frw=>ts_json
              ev_run_uuid         TYPE sysuuid_x16
              ev_query_uuid       TYPE sysuuid_x16
    RAISING   zpru_cx_agent_core.

  METHODS create_and_execute
    IMPORTING is_agent_create     TYPE zpru_if_adf_type_and_constant=>ts_agent_create_imp
              it_tool_create      TYPE zpru_if_adf_type_and_constant=>tt_tool_create_imp
              iv_input_query      TYPE string
              iv_complete_run     TYPE abap_boolean DEFAULT abap_false
    EXPORTING ev_response         TYPE zpru_if_agent_frw=>ts_json
              ev_run_uuid         TYPE sysuuid_x16
              ev_query_uuid       TYPE sysuuid_x16
              es_reported         TYPE zpru_if_agent_frw=>ts_adf_reported
              es_failed           TYPE zpru_if_agent_frw=>ts_adf_failed
              es_mapped           TYPE zpru_if_agent_frw=>ts_adf_mapped
    RAISING   zpru_cx_agent_core.

ENDINTERFACE.
