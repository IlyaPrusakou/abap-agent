CLASS zpru_cl_payload DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
 inTERFACES zpru_if_payload.
  PROTECTED SECTION.
    DATA mr_data TYPE REF TO data.
  PRIVATE SECTION.
ENDCLASS.



CLASS zpru_cl_payload IMPLEMENTATION.


  METHOD zpru_if_payload~get_data.
    rr_data = mr_data.
  ENDMETHOD.


  METHOD zpru_if_payload~set_data.
    mr_data = ir_data.
  ENDMETHOD.

  METHOD zpru_if_payload~clear_data.
    CLEAR: mr_data.
  ENDMETHOD.

ENDCLASS.
