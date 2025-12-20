INTERFACE zpru_if_discard_strategy
  PUBLIC .

  METHODS discard
    IMPORTING
      io_long_memory       TYPE REF TO zpru_if_long_memory_provider OPTIONAL
    CHANGING
      ct_message_2_discard TYPE zpru_if_short_memory_provider=>tt_agent_message.

ENDINTERFACE.
