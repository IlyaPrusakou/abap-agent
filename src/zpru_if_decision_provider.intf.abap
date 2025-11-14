INTERFACE zpru_if_decision_provider
  PUBLIC .

  INTERFACES zpru_if_agent_frw.

  METHODS call_decision_engine
    IMPORTING io_input  TYPE REF TO zpru_if_request
    EXPORTING eo_output TYPE REF TO zpru_if_response.

ENDINTERFACE.
