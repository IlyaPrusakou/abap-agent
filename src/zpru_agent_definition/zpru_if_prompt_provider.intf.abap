INTERFACE zpru_if_prompt_provider
  PUBLIC .
  INTERFACES zpru_if_agent_frw.

  METHODS get_system_prompt
    RETURNING VALUE(rv_system_prompt) TYPE zpru_if_agent_frw=>ts_json.
  METHODS get_prompt_language
    RETURNING VALUE(rv_language) TYPE spras.
ENDINTERFACE.
