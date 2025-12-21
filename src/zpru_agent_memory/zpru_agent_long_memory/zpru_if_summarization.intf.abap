INTERFACE zpru_if_summarization
  PUBLIC .

  METHODS summarize
    IMPORTING
      io_input  TYPE REF TO zpru_if_payload
    EXPORTING
      eo_output TYPE REF TO zpru_if_payload.

ENDINTERFACE.
