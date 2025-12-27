CLASS zpru_cl_unit_agent DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zpru_if_unit_agent.
ENDCLASS.


CLASS zpru_cl_unit_agent IMPLEMENTATION.
  METHOD zpru_if_unit_agent~execute_agent.
    DATA lo_api_agent TYPE REF TO zpru_if_api_agent.

    lo_api_agent = NEW zpru_cl_api_agent( ).
    TRY.
        lo_api_agent->initialize( EXPORTING iv_agent_name = iv_agent_name
                                  IMPORTING es_agent      = DATA(ls_agent)
                                  " TODO: variable is assigned but never used (ABAP cleaner)
                                            et_tools      = DATA(lt_tools) ).

        lo_api_agent->set_input_query( iv_input_query = iv_input_query
                                       iv_agent_uuid  = ls_agent-agent_uuid ).

        lo_api_agent->build_execution( EXPORTING iv_agent_uuid       = ls_agent-agent_uuid
                                       IMPORTING ev_built_run_uuid   = DATA(lv_built_run_uuid)
                                                 ev_built_query_uuid = DATA(lv_built_query_uuid)  ).

        lo_api_agent->run( EXPORTING iv_run_uuid       = lv_built_run_uuid
                                     iv_query_uuid     = lv_built_query_uuid
                           IMPORTING
                           " TODO: variable is assigned but never used (ABAP cleaner)
                                     eo_final_response = DATA(lo_final_response) ).

*        lo_api_agent->save_execution( iv_do_commit = abap_true ).
      CATCH zpru_cx_agent_core.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
