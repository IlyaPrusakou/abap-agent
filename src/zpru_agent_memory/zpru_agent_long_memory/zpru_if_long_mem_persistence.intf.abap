INTERFACE zpru_if_long_mem_persistence
  PUBLIC .

  TYPES: ts_message TYPE zpru_s_mem_msg_ext.
  TYPES: tt_message TYPE STANDARD TABLE OF ts_message WITH EMPTY KEY.
  TYPES: ts_summarization TYPE zpru_s_mem_sum_ext.
  TYPES: tt_summarization TYPE STANDARD TABLE OF ts_summarization WITH EMPTY KEY.

  TYPES: ts_message_db TYPE zpru_mem_msg.
  TYPES: tt_message_db TYPE STANDARD TABLE OF ts_message_db WITH EMPTY KEY.
  TYPES: ts_summarization_db TYPE zpru_mem_sum.
  TYPES: tt_summarization_db TYPE STANDARD TABLE OF ts_summarization_db WITH EMPTY KEY.


  METHODS persist
    IMPORTING
      io_input  TYPE REF TO zpru_if_payload
    EXPORTING
      eo_output TYPE REF TO zpru_if_payload
      ev_error  TYPE abap_boolean.

ENDINTERFACE.
