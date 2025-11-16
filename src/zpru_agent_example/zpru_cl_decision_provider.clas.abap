CLASS zpru_cl_decision_provider DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zpru_if_agent_frw .
    INTERFACES zpru_if_decision_provider .
  PROTECTED SECTION.

  PRIVATE SECTION.
ENDCLASS.



CLASS ZPRU_CL_DECISION_PROVIDER IMPLEMENTATION.


  METHOD zpru_if_decision_provider~call_decision_engine.

    DATA lv_input TYPE string.

    lv_input = io_input->get_data( )->*.

    CASE lv_input.
      WHEN 'TOOL_1'.
        eo_output->set_data( ir_data = NEW string( 'TOOL_1' ) ).
      WHEN OTHERS.
        eo_output->set_data( ir_data = NEW string( 'STOP_WORK' ) ).
        RETURN.
    ENDCASE.

  ENDMETHOD.
ENDCLASS.
