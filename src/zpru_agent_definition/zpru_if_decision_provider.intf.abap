INTERFACE zpru_if_decision_provider
  PUBLIC .

  INTERFACES zpru_if_agent_frw.

  TYPES: BEGIN OF ts_execution_plan,
           agent_uuid TYPE   sysuuid_x16,
           tool_name  TYPE char100,
           sequence   TYPE i,
         END OF ts_execution_plan.

  TYPES tt_execution_plan TYPE STANDARD TABLE OF ts_execution_plan WITH EMPTY KEY.

  METHODS call_decision_engine
    IMPORTING io_controller          TYPE REF TO zpru_if_agent_controller
              io_input               TYPE REF TO zpru_if_request
              io_system_prompt       TYPE REF TO zpru_if_prompt_provider OPTIONAL
              io_short_memory        TYPE REF TO zpru_if_short_memory_provider OPTIONAL
              io_long_memory         TYPE REF TO zpru_if_long_memory_provider OPTIONAL
              io_agent_info_provider TYPE REF TO zpru_if_agent_info_provider OPTIONAL
    EXPORTING eo_execution_plan      TYPE ref to zpru_if_response
              eo_first_tool_input    TYPE REF TO zpru_if_response
              eo_langu               type REF TO zpru_if_response
              eo_decision_log        type ref to zpru_if_response.

ENDINTERFACE.
