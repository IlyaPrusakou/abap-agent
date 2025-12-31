INTERFACE zpru_if_discard_strategy
  PUBLIC .

  METHODS discard
    IMPORTING
      io_long_memory       TYPE REF TO zpru_if_long_memory_provider OPTIONAL
        io_input  TYPE REF TO zpru_if_payload
      EXPORTING
        eo_output TYPE REF TO zpru_if_payload
        raISING zpru_cx_agent_core.

ENDINTERFACE.
