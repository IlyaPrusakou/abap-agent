INTERFACE zpru_if_long_mem_persistence
  PUBLIC .

  TYPES: ts_message TYPE zpru_s_mem_msg.
  TYPES: tt_message TYPE STANDARD TABLE OF ts_message WITH EMPTY KEY.
  TYPES: ts_summarization TYPE zpru_s_mem_sum.
  TYPES: tt_summarization TYPE STANDARD TABLE OF ts_summarization WITH EMPTY KEY.

  METHODS persist
    IMPORTING
      io_input  TYPE REF TO zpru_if_request
    EXPORTING
      eo_output TYPE REF TO zpru_if_response
      ev_error  TYPE abap_boolean.

ENDINTERFACE.
