CLASS lcl_decision_provider DEFINITION CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zpru_if_decision_provider.
ENDCLASS.


CLASS lcl_decision_provider IMPLEMENTATION.
  METHOD zpru_if_decision_provider~call_decision_engine.
    DATA lt_execution_plan TYPE zpru_if_decision_provider=>tt_execution_plan.

    zpru_cl_dummy_agent_logic=>ms_method_registr-call_decision_engine = abap_true.

    GET TIME STAMP FIELD DATA(lv_now).

    APPEND INITIAL LINE TO lt_execution_plan ASSIGNING FIELD-SYMBOL(<ls_execution_plan>).
    <ls_execution_plan>-agent_uuid = is_agent-agent_uuid.
    <ls_execution_plan>-tool_name  = 'SIMPLE_TOOL'.
    <ls_execution_plan>-sequence   = 1.

    APPEND INITIAL LINE TO lt_execution_plan ASSIGNING <ls_execution_plan>.
    <ls_execution_plan>-agent_uuid = is_agent-agent_uuid.
    <ls_execution_plan>-tool_name  = 'KNOWLEDGE'.
    <ls_execution_plan>-sequence   = 2.

    APPEND INITIAL LINE TO lt_execution_plan ASSIGNING <ls_execution_plan>.
    <ls_execution_plan>-agent_uuid = is_agent-agent_uuid.
    <ls_execution_plan>-tool_name  = 'NESTED_AGENT'.
    <ls_execution_plan>-sequence   = 3.

    eo_execution_plan->set_data( ir_data = NEW zpru_if_decision_provider=>tt_execution_plan( lt_execution_plan ) ).
    eo_first_tool_input->set_data(
        ir_data = NEW string( |\{ "FIRST_TOOL_INPUT" : "FIRST TOOL INPUT - { lv_now }" \}| ) ).
    eo_langu->set_data( ir_data = NEW spras( sy-langu ) ).
    eo_decision_log->set_data( ir_data = NEW string( |\{ "DICISION LOG" : "DECISION LOG - { lv_now }" \}| ) ).
  ENDMETHOD.

  METHOD zpru_if_decision_provider~prepare_final_response.
    DATA lv_final_response TYPE string.

    zpru_cl_dummy_agent_logic=>ms_method_registr-prepare_final_response = abap_true.

    DATA(lv_last_output) = io_last_output->get_data( ).
    GET TIME STAMP FIELD DATA(lv_now).
    lv_final_response = |{ lv_last_output->* } - FINAL_RESPONSE - { lv_now } |.
    eo_final_response->set_data( ir_data = NEW string( lv_final_response ) ).
  ENDMETHOD.
ENDCLASS.


CLASS lcl_short_memory_provider DEFINITION
  INHERITING FROM zpru_cl_short_memory_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CLASS-METHODS get_instance
      RETURNING VALUE(ro_instance) TYPE REF TO lcl_short_memory_provider.
  PROTECTED SECTION.
    CLASS-DATA so_instance TYPE REF TO lcl_short_memory_provider.
  PRIVATE SECTION.
ENDCLASS.


CLASS lcl_short_memory_provider IMPLEMENTATION.

  METHOD get_instance.

    IF so_instance IS BOUND.
      ro_instance = so_instance.
      RETURN.
    ENDIF.

    so_instance = NEW lcl_short_memory_provider( ).
    ro_instance = so_instance.

  ENDMETHOD.

ENDCLASS.


CLASS lcl_long_memory_provider DEFINITION
  INHERITING FROM zpru_cl_long_memory_base
  CREATE PUBLIC.

  PUBLIC SECTION.

  PROTECTED SECTION.

  PRIVATE SECTION.
ENDCLASS.


CLASS lcl_long_memory_provider IMPLEMENTATION.

ENDCLASS.


CLASS lcl_agent_info_provider DEFINITION
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zpru_if_agent_info_provider.
ENDCLASS.


CLASS lcl_agent_info_provider IMPLEMENTATION.
  METHOD zpru_if_agent_info_provider~get_agent_info.
    zpru_cl_dummy_agent_logic=>ms_method_registr-get_agent_info = abap_true.

    GET TIME STAMP FIELD DATA(lv_now).
    rv_agent_info = |JUST DUMMY AGENT - { lv_now }|.
  ENDMETHOD.
ENDCLASS.


CLASS lcl_prompt_provider DEFINITION
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zpru_if_prompt_provider.
ENDCLASS.


CLASS lcl_prompt_provider IMPLEMENTATION.
  METHOD zpru_if_prompt_provider~get_prompt_language.
    zpru_cl_dummy_agent_logic=>ms_method_registr-get_prompt_language = abap_true.
    rv_language = sy-langu.
  ENDMETHOD.

  METHOD zpru_if_prompt_provider~get_system_prompt.
    zpru_cl_dummy_agent_logic=>ms_method_registr-get_system_prompt = abap_true.
    GET TIME STAMP FIELD DATA(lv_now).
    rv_system_prompt = |\{ "SYSTEM_PROMPT" : "DUMMY SYSTEM PROMPT - { lv_now }" \}|.
  ENDMETHOD.
ENDCLASS.


CLASS lcl_simple_tool DEFINITION
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zpru_if_tool_executor.
ENDCLASS.


CLASS lcl_simple_tool IMPLEMENTATION.
  METHOD zpru_if_tool_executor~execute_tool.
    DATA lv_payload TYPE string.

    zpru_cl_dummy_agent_logic=>ms_method_registr-simple_tool = abap_true.
    GET TIME STAMP FIELD DATA(lv_now).
    lv_payload = io_request->get_data( )->*.
    lv_payload = |{ lv_payload } - SIMPLE TOOL VISITED - { lv_now }|.
    eo_response->set_data( ir_data = NEW string( lv_payload ) ).
  ENDMETHOD.

  METHOD zpru_if_tool_executor~lookup_knowledge.
    RETURN.
  ENDMETHOD.

  METHOD zpru_if_tool_executor~run_nested_agent.
    RETURN.
  ENDMETHOD.
ENDCLASS.


CLASS lcl_knowledge DEFINITION
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zpru_if_tool_executor.
ENDCLASS.


CLASS lcl_knowledge IMPLEMENTATION.
  METHOD zpru_if_tool_executor~execute_tool.
    RETURN.
  ENDMETHOD.

  METHOD zpru_if_tool_executor~lookup_knowledge.
    DATA lv_payload TYPE string.

    zpru_cl_dummy_agent_logic=>ms_method_registr-knowledge = abap_true.
    GET TIME STAMP FIELD DATA(lv_now).
    lv_payload = io_request->get_data( )->*.
    lv_payload = |{ lv_payload } - KNOWLEDGE TOOL VISITED - { lv_now }|.
    eo_response->set_data( ir_data = NEW string( lv_payload ) ).
  ENDMETHOD.

  METHOD zpru_if_tool_executor~run_nested_agent.
    RETURN.
  ENDMETHOD.
ENDCLASS.


CLASS lcl_nested_agent DEFINITION
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zpru_if_tool_executor.
ENDCLASS.


CLASS lcl_nested_agent IMPLEMENTATION.
  METHOD zpru_if_tool_executor~execute_tool.
    RETURN.
  ENDMETHOD.

  METHOD zpru_if_tool_executor~lookup_knowledge.
    RETURN.
  ENDMETHOD.

  METHOD zpru_if_tool_executor~run_nested_agent.
    DATA lv_payload TYPE string.

    zpru_cl_dummy_agent_logic=>ms_method_registr-nested_agent = abap_true.
    GET TIME STAMP FIELD DATA(lv_now).
    lv_payload = io_request->get_data( )->*.
    lv_payload = |{ lv_payload } - NESTED AGENT TOOL VISITED - { lv_now }|.
    eo_response->set_data( ir_data = NEW string( lv_payload ) ).
  ENDMETHOD.
ENDCLASS.


CLASS lcl_tool_provider DEFINITION
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zpru_if_tool_provider.
ENDCLASS.


CLASS lcl_tool_provider IMPLEMENTATION.
  METHOD zpru_if_tool_provider~get_tool.
    zpru_cl_dummy_agent_logic=>ms_method_registr-get_tool = abap_true.
    CASE is_tool_master_data-tool_name.
      WHEN 'SIMPLE_TOOL'.
        ro_executor = NEW lcl_simple_tool( ).
      WHEN 'KNOWLEDGE'.
        ro_executor = NEW lcl_knowledge( ).
      WHEN 'NESTED_AGENT'.
        ro_executor = NEW lcl_nested_agent( ).
      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.


CLASS lcl_input_schema_provider DEFINITION
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zpru_if_input_schema_provider.
ENDCLASS.


CLASS lcl_input_schema_provider IMPLEMENTATION.
  METHOD zpru_if_input_schema_provider~get_input_schema.
    DATA lv_input_schema TYPE string.

    zpru_cl_dummy_agent_logic=>ms_method_registr-get_input_schema = abap_true.
    CASE is_tool_master_data-tool_name.
      WHEN 'SIMPLE_TOOL'.
        lv_input_schema = |\{ "INPUT_SCHEMA" : "SIMPLE_TOOL" \}|.
      WHEN 'KNOWLEDGE'.
        lv_input_schema = |\{ "INPUT_SCHEMA" : "KNOWLEDGE" \}|.
      WHEN 'NESTED_AGENT'.
        lv_input_schema = |\{ "INPUT_SCHEMA" : "NESTED_AGENT" \}|.
      WHEN OTHERS.
    ENDCASE.
    ro_input_schema->set_data( ir_data = NEW string( lv_input_schema ) ).
  ENDMETHOD.
ENDCLASS.
