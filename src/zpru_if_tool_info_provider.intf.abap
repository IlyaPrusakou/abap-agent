INTERFACE zpru_if_tool_info_provider
  PUBLIC .
  INTERFACES zpru_if_agent_frw.

  METHODS get_tool_info
    RETURNING VALUE(rv_tool_info) TYPE zpru_if_agent_frw=>ts_json.
ENDINTERFACE.
