INTERFACE zpru_if_request
  PUBLIC .

  METHODS set_data
    IMPORTING
      ir_data TYPE REF TO data.

  METHODS get_data
    RETURNING
      VALUE(rr_data) TYPE REF TO data.

ENDINTERFACE.
