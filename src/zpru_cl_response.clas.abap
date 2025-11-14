CLASS zpru_cl_response DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zpru_if_response .
  PROTECTED SECTION.
    DATA mr_data TYPE REF TO data.
  PRIVATE SECTION.
ENDCLASS.



CLASS zpru_cl_response IMPLEMENTATION.

  METHOD zpru_if_response~get_data.
    rr_data = mr_data.
  ENDMETHOD.

  METHOD zpru_if_response~set_data.
    mr_data = ir_data.
  ENDMETHOD.
ENDCLASS.
