INTERFACE zpru_if_agent_util
  PUBLIC .

  METHODS copy_data_to_ref
    IMPORTING
      is_data TYPE any
    CHANGING
      cr_data TYPE REF TO data.

ENDINTERFACE.
