INTERFACE zpru_if_decision_provider
  PUBLIC.

  INTERFACES zpru_if_agent_frw.

  TYPES: BEGIN OF ts_execution_plan,
           agent_uuid TYPE sysuuid_x16,
           tool_name  TYPE char100,
           sequence   TYPE i,
         END OF ts_execution_plan.

  TYPES tt_execution_plan TYPE STANDARD TABLE OF ts_execution_plan WITH EMPTY KEY.

  METHODS call_decision_engine
    IMPORTING is_agent               TYPE zpru_if_adf_type_and_constant=>ts_agent
              io_controller          TYPE REF TO zpru_if_agent_controller
              io_input               TYPE REF TO zpru_if_payload
              io_system_prompt       TYPE REF TO zpru_if_prompt_provider       OPTIONAL
              io_short_memory        TYPE REF TO zpru_if_short_memory_provider OPTIONAL
              io_long_memory         TYPE REF TO zpru_if_long_memory_provider  OPTIONAL
              io_agent_info_provider TYPE REF TO zpru_if_agent_info_provider   OPTIONAL
    EXPORTING eo_execution_plan      TYPE REF TO zpru_if_payload
              eo_first_tool_input    TYPE REF TO zpru_if_payload
              eo_langu               TYPE REF TO zpru_if_payload
              eo_decision_log        TYPE REF TO zpru_if_payload.

  METHODS prepare_final_response
    IMPORTING iv_run_uuid       TYPE sysuuid_x16
              iv_query_uuid     TYPE sysuuid_x16
              io_last_output    TYPE REF TO zpru_if_payload OPTIONAL
    EXPORTING eo_final_response TYPE REF TO zpru_if_payload
    CHANGING  cs_axc_reported   TYPE zpru_if_agent_frw=>ts_axc_reported
              cs_axc_failed     TYPE zpru_if_agent_frw=>ts_axc_failed
              cs_adf_reported   TYPE zpru_if_agent_frw=>ts_adf_reported
              cs_adf_failed     TYPE zpru_if_agent_frw=>ts_adf_failed.

ENDINTERFACE.
