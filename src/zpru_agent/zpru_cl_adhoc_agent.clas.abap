CLASS zpru_cl_adhoc_agent DEFINITION
  PUBLIC
  INHERITING FROM zpru_cl_agent_base
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES zpru_if_adhoc_agent.

  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS get_api_agent
      RETURNING VALUE(ro_api_agent) TYPE REF TO zpru_if_api_agent
      RAISING   zpru_cx_agent_core.
ENDCLASS.



CLASS zpru_cl_adhoc_agent IMPLEMENTATION.

  METHOD get_api_agent.
    ro_api_agent = zpru_cl_agent_service_mngr=>get_agent_api( ).
  ENDMETHOD.

  METHOD zpru_if_adhoc_agent~create_agent.
    DATA lo_api_agent   TYPE REF TO zpru_if_api_agent.
    DATA lt_agent_table TYPE zpru_if_adf_type_and_constant=>tt_agent_create_imp.

    CLEAR: es_reported,
           es_failed,
           es_mapped,
           rv_agent_name.

    lt_agent_table = VALUE #( ( is_agent_create ) ).

    lo_api_agent = get_api_agent( ).

    lo_api_agent->create_agent_definition(
      EXPORTING
        it_agent_create = lt_agent_table
        it_tool_create  = it_tool_create
      IMPORTING
        es_reported     = es_reported
        es_failed       = es_failed
        es_mapped       = es_mapped ).

    IF es_failed-agent IS INITIAL.
      rv_agent_name = is_agent_create-agentname.
    ENDIF.
  ENDMETHOD.

  METHOD zpru_if_adhoc_agent~execute_agent.
    DATA lo_api_agent TYPE REF TO zpru_if_api_agent.
    DATA ls_agent     TYPE zpru_if_adf_type_and_constant=>ts_agent.
    DATA ls_prompt    TYPE zpru_s_prompt.

    CLEAR: ev_response,
           ev_run_uuid,
           ev_query_uuid.

    IF iv_agent_name  IS INITIAL
       OR iv_input_query IS INITIAL.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    lo_api_agent = get_api_agent( ).

    ls_prompt-string_content = iv_input_query.

    lo_api_agent->setup_agent(
      EXPORTING
        iv_agent_name = iv_agent_name
      IMPORTING
        es_agent      = ls_agent ).

    lo_api_agent->set_input_query(
      EXPORTING
        is_input_query = ls_prompt
        iv_agent_uuid  = ls_agent-agentuuid ).

    lo_api_agent->build_execution(
      EXPORTING
        iv_agent_uuid       = ls_agent-agentuuid
      IMPORTING
        ev_built_run_uuid   = ev_run_uuid
        ev_built_query_uuid = ev_query_uuid ).

    lo_api_agent->run(
      EXPORTING
        iv_run_uuid       = ev_run_uuid
        iv_query_uuid     = ev_query_uuid
      IMPORTING
        eo_final_response = DATA(lo_response) ).

    IF lo_response IS BOUND.
      ev_response = lo_response->get_data( )->*.
    ENDIF.

    IF iv_complete_run = abap_true.
      lo_api_agent->complete_run( iv_run_uuid = ev_run_uuid ).
    ENDIF.
  ENDMETHOD.

  METHOD zpru_if_adhoc_agent~create_and_execute.
    DATA lo_api_agent   TYPE REF TO zpru_if_api_agent.
    DATA ls_agent       TYPE zpru_if_adf_type_and_constant=>ts_agent.
    DATA ls_prompt      TYPE zpru_s_prompt.
    DATA lt_agent_table TYPE zpru_if_adf_type_and_constant=>tt_agent_create_imp.

    CLEAR: ev_response,
           ev_run_uuid,
           ev_query_uuid,
           es_reported,
           es_failed,
           es_mapped.

    IF iv_input_query IS INITIAL.
      RAISE EXCEPTION NEW zpru_cx_agent_core( ).
    ENDIF.

    lt_agent_table = VALUE #( ( is_agent_create ) ).

    lo_api_agent = get_api_agent( ).

    lo_api_agent->create_agent_definition(
      EXPORTING
        it_agent_create = lt_agent_table
        it_tool_create  = it_tool_create
      IMPORTING
        es_reported     = es_reported
        es_failed       = es_failed
        es_mapped       = es_mapped ).

    IF es_failed-agent IS NOT INITIAL.
      RETURN.
    ENDIF.

    lo_api_agent->setup_agent(
      EXPORTING
        iv_agent_name = is_agent_create-agentname
      IMPORTING
        es_agent      = ls_agent ).

    ls_prompt-string_content = iv_input_query.

    lo_api_agent->set_input_query(
      EXPORTING
        is_input_query = ls_prompt
        iv_agent_uuid  = ls_agent-agentuuid ).

    lo_api_agent->build_execution(
      EXPORTING
        iv_agent_uuid       = ls_agent-agentuuid
      IMPORTING
        ev_built_run_uuid   = ev_run_uuid
        ev_built_query_uuid = ev_query_uuid ).

    lo_api_agent->run(
      EXPORTING
        iv_run_uuid       = ev_run_uuid
        iv_query_uuid     = ev_query_uuid
      IMPORTING
        eo_final_response = DATA(lo_response) ).

    IF lo_response IS BOUND.
      ev_response = lo_response->get_data( )->*.
    ENDIF.

    IF iv_complete_run = abap_true.
      lo_api_agent->complete_run( iv_run_uuid = ev_run_uuid ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.
