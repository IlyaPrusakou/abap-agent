INTERFACE zpru_if_api_agent
  PUBLIC .

  INTERFACES zpru_if_agent_frw.

  TYPES: tv_agent_name TYPE char100.

  METHODS initialize
    IMPORTING iv_agent_name TYPE zpru_if_api_agent=>tv_agent_name.
  METHODS set_input_query
    IMPORTING iv_input_query TYPE zpru_if_agent_frw=>ts_json.
  METHODS build_execution.
  methods save_execution.
  METHODS run.
  METHODS rerun_execution.
  METHODS rerun_from_step.

ENDINTERFACE.
