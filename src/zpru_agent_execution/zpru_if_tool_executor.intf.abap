INTERFACE zpru_if_tool_executor
  PUBLIC .

  METHODS execute_tool
    IMPORTING
      io_controller TYPE REF TO zpru_if_agent_controller
      io_request    TYPE REF TO zpru_if_payload
    EXPORTING
      eo_response   TYPE REF TO zpru_if_payload
      ev_error_flag TYPE abap_boolean.

  METHODS run_nested_agent
    IMPORTING
      io_controller TYPE REF TO zpru_if_agent_controller
      io_request    TYPE REF TO zpru_if_payload
    EXPORTING
      eo_response   TYPE REF TO zpru_if_payload
      ev_error_flag TYPE abap_boolean.

  METHODS lookup_knowledge
    IMPORTING
      io_controller TYPE REF TO zpru_if_agent_controller
      io_request    TYPE REF TO zpru_if_payload
    EXPORTING
      eo_response   TYPE REF TO zpru_if_payload
      ev_error_flag TYPE abap_boolean.

ENDINTERFACE.
