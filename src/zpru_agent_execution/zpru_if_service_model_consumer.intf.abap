INTERFACE zpru_if_service_model_consumer
  PUBLIC .

  METHODS consume_service_model
    IMPORTING
      io_controller            TYPE REF TO zpru_if_agent_controller
      io_request               TYPE REF TO zpru_if_payload
    EXPORTING
      eo_response              TYPE REF TO zpru_if_payload
      ev_error_flag            TYPE abap_boolean.

ENDINTERFACE.
