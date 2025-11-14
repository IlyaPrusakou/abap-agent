CLASS zpru_cl_request DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zpru_if_request .
  PROTECTED SECTION.
    DATA mr_data TYPE REF TO data.
  PRIVATE SECTION.
ENDCLASS.



CLASS zpru_cl_request IMPLEMENTATION.

  METHOD zpru_if_request~get_data.
    rr_data = mr_data.
  ENDMETHOD.

  METHOD zpru_if_request~set_data.
    mr_data = ir_data.
  ENDMETHOD.
ENDCLASS.
