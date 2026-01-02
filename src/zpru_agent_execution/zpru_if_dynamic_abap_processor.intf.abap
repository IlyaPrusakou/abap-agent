INTERFACE zpru_if_dynamic_abap_processor
  PUBLIC .

  METHODS process_dynamic_abap
    IMPORTING
      io_controller            TYPE REF TO zpru_if_agent_controller
      io_request               TYPE REF TO zpru_if_payload
    EXPORTING
      eo_response              TYPE REF TO zpru_if_payload
      ev_error_flag            TYPE abap_boolean.

ENDINTERFACE.
