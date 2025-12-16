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



CLASS zpru_cl_decision_provider IMPLEMENTATION.


  METHOD zpru_if_decision_provider~call_decision_engine.

*    DATA lv_input TYPE string.
*
*    lv_input = io_input->get_data( )->*.
*
*    CASE lv_input.
*      WHEN 'TOOL_1'.
*        APPEND INITIAL LINE TO et_execution_plan ASSIGNING FIELD-SYMBOL(<ls_execution_plan>).
*        <ls_execution_plan>-agent_uuid =  io_controller->mv_agent_uuid.
*        <ls_execution_plan>-sequence = 1.
*        <ls_execution_plan>-tool_name = 'AddTwoNumbers'.
*      WHEN OTHERS.
*        io_controller->mv_stop_agent = abap_true.
*        RETURN.
*    ENDCASE.

  ENDMETHOD.
ENDCLASS.
