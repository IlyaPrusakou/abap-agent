CLASS zpru_cl_dummy_agent_logic DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zpru_if_decision_provider.
    INTERFACES zpru_if_short_memory_provider.
    INTERFACES zpru_if_long_memory_provider.
    INTERFACES zpru_if_agent_info_provider.
    INTERFACES zpru_if_prompt_provider.
    INTERFACES zpru_if_tool_provider.
    INTERFACES zpru_if_input_schema_provider.
    TYPES: BEGIN OF ts_method_registr,
             call_decision_engine   TYPE abap_boolean,
             prepare_final_response TYPE abap_boolean,
             get_agent_info         TYPE abap_boolean,
             get_prompt_language    TYPE abap_boolean,
             get_system_prompt      TYPE abap_boolean,
             get_tool               TYPE abap_boolean,
             get_input_schema       TYPE abap_boolean,
             simple_tool            TYPE abap_boolean,
             knowledge              TYPE abap_boolean,
             nested_agent           TYPE abap_boolean,
           END OF ts_method_registr.

    CLASS-DATA ms_method_registr TYPE ts_method_registr.

ENDCLASS.


CLASS zpru_cl_dummy_agent_logic IMPLEMENTATION.

  METHOD zpru_if_decision_provider~call_decision_engine.
    DATA lo_decision_provider TYPE REF TO zpru_if_decision_provider.

    lo_decision_provider = NEW lcl_decision_provider( ).

    lo_decision_provider->call_decision_engine( EXPORTING is_agent               = is_agent
                                                          io_controller          = io_controller
                                                          io_input               = io_input
                                                          io_system_prompt       = io_system_prompt
                                                          io_short_memory        = io_short_memory
                                                          io_long_memory         = io_long_memory
                                                          io_agent_info_provider = io_agent_info_provider
                                                IMPORTING eo_execution_plan      = eo_execution_plan
                                                          eo_first_tool_input    = eo_first_tool_input
                                                          eo_langu               = eo_langu
                                                          eo_decision_log        = eo_decision_log ).
  ENDMETHOD.

  METHOD zpru_if_short_memory_provider~clear_history.
    DATA lo_short_memory TYPE REF TO zpru_if_short_memory_provider.

    lo_short_memory = lcl_short_memory_provider=>get_instance( ).
    lo_short_memory->clear_history( ).
  ENDMETHOD.

  METHOD zpru_if_agent_info_provider~get_agent_info.
    DATA lo_agent_info_provider TYPE REF TO zpru_if_agent_info_provider.

    lo_agent_info_provider = NEW lcl_agent_info_provider( ).
    rv_agent_info = lo_agent_info_provider->get_agent_info( ).
  ENDMETHOD.

  METHOD zpru_if_short_memory_provider~get_discard_strategy.
    DATA lo_short_memory TYPE REF TO zpru_if_short_memory_provider.

    lo_short_memory = lcl_short_memory_provider=>get_instance( ).
    ro_discard_strategy = lo_short_memory->get_discard_strategy( ).
  ENDMETHOD.

  METHOD zpru_if_short_memory_provider~get_history.
    DATA lo_short_memory TYPE REF TO zpru_if_short_memory_provider.

    lo_short_memory = lcl_short_memory_provider=>get_instance( ).
    rt_history = lo_short_memory->get_history( ).
  ENDMETHOD.

  METHOD zpru_if_short_memory_provider~get_long_memory.
    DATA lo_short_memory TYPE REF TO zpru_if_short_memory_provider.

    lo_short_memory = lcl_short_memory_provider=>get_instance( ).
    ro_long_memory = lo_short_memory->get_long_memory( ).
  ENDMETHOD.

  METHOD zpru_if_long_memory_provider~get_msg_persistence.
    DATA lo_long_memory TYPE REF TO zpru_if_long_memory_provider.

    lo_long_memory = NEW lcl_long_memory_provider( ).
    ro_msg_persistence = lo_long_memory->get_msg_persistence( ).
  ENDMETHOD.

  METHOD zpru_if_prompt_provider~get_prompt_language.
    DATA lo_prompt_provider TYPE REF TO zpru_if_prompt_provider.

    lo_prompt_provider = NEW lcl_prompt_provider( ).
    rv_language = lo_prompt_provider->get_prompt_language( ).
  ENDMETHOD.

  METHOD zpru_if_long_memory_provider~get_summarization.
    DATA lo_long_memory TYPE REF TO zpru_if_long_memory_provider.

    lo_long_memory = NEW lcl_long_memory_provider( ).
    ro_summarization = lo_long_memory->get_summarization( ).
  ENDMETHOD.

  METHOD zpru_if_long_memory_provider~get_sum_persistence.
    DATA lo_long_memory TYPE REF TO zpru_if_long_memory_provider.

    lo_long_memory = NEW lcl_long_memory_provider( ).
    ro_sum_persistence = lo_long_memory->get_sum_persistence( ).
  ENDMETHOD.

  METHOD zpru_if_prompt_provider~get_system_prompt.
    DATA lo_prompt_provider TYPE REF TO zpru_if_prompt_provider.

    lo_prompt_provider = NEW lcl_prompt_provider( ).
    rv_system_prompt = lo_prompt_provider->get_system_prompt( ).
  ENDMETHOD.

  METHOD zpru_if_decision_provider~prepare_final_response.
    DATA lo_decision_provider TYPE REF TO zpru_if_decision_provider.

    lo_decision_provider = NEW lcl_decision_provider( ).
    lo_decision_provider->prepare_final_response( EXPORTING iv_run_uuid       = iv_run_uuid
                                                            iv_query_uuid     = iv_query_uuid
                                                  IMPORTING eo_final_response = eo_final_response
                                                  CHANGING  cs_axc_reported   = cs_axc_reported
                                                            cs_axc_failed     = cs_axc_failed
                                                            cs_adf_reported   = cs_adf_reported
                                                            cs_adf_failed     = cs_adf_failed ).
  ENDMETHOD.

  METHOD zpru_if_long_memory_provider~retrieve_message.
    DATA lo_long_memory TYPE REF TO zpru_if_long_memory_provider.

    lo_long_memory = NEW lcl_long_memory_provider( ).
    lo_long_memory->retrieve_message( ).
  ENDMETHOD.

  METHOD zpru_if_long_memory_provider~retrieve_summary.
    DATA lo_long_memory TYPE REF TO zpru_if_long_memory_provider.

    lo_long_memory = NEW lcl_long_memory_provider( ).
    lo_long_memory->retrieve_summary( ).
  ENDMETHOD.

  METHOD zpru_if_short_memory_provider~save_message.
    DATA lo_short_memory TYPE REF TO zpru_if_short_memory_provider.

    lo_short_memory = lcl_short_memory_provider=>get_instance( ).
    lo_short_memory->save_message( it_message = it_message ).
  ENDMETHOD.

  METHOD zpru_if_long_memory_provider~save_messages.
    DATA lo_long_memory TYPE REF TO zpru_if_long_memory_provider.

    lo_long_memory = NEW lcl_long_memory_provider( ).
    lo_long_memory->save_messages( EXPORTING io_input  = io_input
                                   IMPORTING eo_output = eo_output
                                             ev_error  = ev_error ).
  ENDMETHOD.

  METHOD zpru_if_long_memory_provider~save_summary.
    DATA lo_long_memory TYPE REF TO zpru_if_long_memory_provider.

    lo_long_memory = NEW lcl_long_memory_provider( ).
    lo_long_memory->save_summary( EXPORTING io_input  = io_input
                                  IMPORTING eo_output = eo_output
                                            ev_error  = ev_error ).
  ENDMETHOD.

  METHOD zpru_if_short_memory_provider~set_discard_strategy.
    DATA lo_short_memory TYPE REF TO zpru_if_short_memory_provider.

    lo_short_memory = lcl_short_memory_provider=>get_instance( ).
    lo_short_memory->set_discard_strategy( io_discard_strategy = io_discard_strategy ).
  ENDMETHOD.

  METHOD zpru_if_short_memory_provider~set_long_memory.
    DATA lo_short_memory TYPE REF TO zpru_if_short_memory_provider.

    lo_short_memory = lcl_short_memory_provider=>get_instance( ).
    lo_short_memory->set_long_memory( io_long_memory = io_long_memory ).
  ENDMETHOD.

  METHOD zpru_if_long_memory_provider~set_msg_persistence.
    DATA lo_long_memory TYPE REF TO zpru_if_long_memory_provider.

    lo_long_memory = NEW lcl_long_memory_provider( ).
    lo_long_memory->set_msg_persistence( io_msg_persistence = io_msg_persistence ).
  ENDMETHOD.

  METHOD zpru_if_long_memory_provider~set_summarization.
    DATA lo_long_memory TYPE REF TO zpru_if_long_memory_provider.

    lo_long_memory = NEW lcl_long_memory_provider( ).
    lo_long_memory->set_summarization( io_summarization = io_summarization ).
  ENDMETHOD.

  METHOD zpru_if_long_memory_provider~set_sum_persistence.
    DATA lo_long_memory TYPE REF TO zpru_if_long_memory_provider.

    lo_long_memory = NEW lcl_long_memory_provider( ).
    lo_long_memory->set_sum_persistence( io_sum_persistence = io_sum_persistence ).
  ENDMETHOD.

  METHOD zpru_if_long_memory_provider~summarize_conversation.
    DATA lo_long_memory TYPE REF TO zpru_if_long_memory_provider.

    lo_long_memory = NEW lcl_long_memory_provider( ).
    lo_long_memory->summarize_conversation( EXPORTING io_input  = io_input
                                            IMPORTING eo_output = eo_output
                                                      ev_error  = ev_error ).
  ENDMETHOD.

  METHOD zpru_if_tool_provider~get_tool.
    DATA lo_tool_provider TYPE REF TO zpru_if_tool_provider.

    lo_tool_provider = NEW lcl_tool_provider( ).
    ro_executor = lo_tool_provider->get_tool( is_tool_master_data = is_tool_master_data
                                              is_execution_step   = is_execution_step ).
  ENDMETHOD.

  METHOD zpru_if_input_schema_provider~get_input_schema.
    DATA lo_input_schema_provider TYPE REF TO zpru_if_input_schema_provider.

    lo_input_schema_provider = NEW lcl_input_schema_provider( ).
    ro_input_schema = lo_input_schema_provider->get_input_schema(
       EXPORTING
         is_tool_master_data = is_tool_master_data
         is_execution_step   = is_execution_step ).
  ENDMETHOD.
ENDCLASS.
