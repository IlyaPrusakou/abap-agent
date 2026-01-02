INTERFACE zpru_if_ml_model_inference
  PUBLIC .

  METHODS get_machine_learning_inference
    IMPORTING
      io_controller            TYPE REF TO zpru_if_agent_controller
      io_request               TYPE REF TO zpru_if_payload
    EXPORTING
      eo_response              TYPE REF TO zpru_if_payload
      ev_error_flag            TYPE abap_boolean.

ENDINTERFACE.
