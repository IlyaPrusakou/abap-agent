INTERFACE zpru_if_agent_controller
  PUBLIC .

  INTERFACES zpru_if_agent_frw .
  DATA mv_stop_agent TYPE abap_boolean.
  DATA mv_agent_uuid TYPE  sysuuid_x16.
  DATA mo_context TYPE REF TO zpru_if_payload.
  DATA mo_parent_controller TYPE REF TO zpru_if_agent_controller.
ENDINTERFACE.
