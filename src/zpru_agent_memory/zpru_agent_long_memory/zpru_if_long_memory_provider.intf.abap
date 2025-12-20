INTERFACE zpru_if_long_memory_provider
  PUBLIC .

  INTERFACES zpru_if_agent_frw.

  METHODS retrieve_message.
  METHODS save_messages
    EXPORTING
      ev_error    TYPE abap_boolean
    CHANGING
      ct_messages TYPE zpru_if_short_memory_provider=>tt_agent_message.
  METHODS save_insights.
  METHODS retrieve_insights.
  METHODS summarize_conversation.

ENDINTERFACE.
