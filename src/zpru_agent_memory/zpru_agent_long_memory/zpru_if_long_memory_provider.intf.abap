INTERFACE zpru_if_long_memory_provider
  PUBLIC .

  INTERFACES zpru_if_agent_frw.

  METHODS retrieve_message.

  METHODS save_messages
    IMPORTING
      io_input  TYPE REF TO zpru_if_payload
    EXPORTING
      eo_output TYPE REF TO zpru_if_payload
      ev_error  TYPE abap_boolean.

  METHODS save_summary
    IMPORTING
      io_input  TYPE REF TO zpru_if_payload
    EXPORTING
      eo_output TYPE REF TO zpru_if_payload
      ev_error  TYPE abap_boolean.


  METHODS retrieve_summary.

  METHODS summarize_conversation
    IMPORTING
      io_input  TYPE REF TO zpru_if_payload
    EXPORTING
      eo_output TYPE REF TO zpru_if_payload
      ev_error  TYPE abap_boolean.

  METHODS set_msg_persistence
    IMPORTING
      io_msg_persistence TYPE REF TO zpru_if_long_mem_persistence.

  METHODS get_msg_persistence
    RETURNING VALUE(ro_msg_persistence) TYPE REF TO zpru_if_long_mem_persistence.

  METHODS set_sum_persistence
    IMPORTING
      io_sum_persistence TYPE REF TO zpru_if_long_mem_persistence.

  METHODS get_sum_persistence
    RETURNING VALUE(ro_sum_persistence) TYPE REF TO zpru_if_long_mem_persistence.

  METHODS set_summarization
    IMPORTING
      io_summarization TYPE REF TO zpru_if_summarization.

  METHODS get_summarization
    RETURNING VALUE(ro_summarization) TYPE REF TO zpru_if_summarization.


ENDINTERFACE.
