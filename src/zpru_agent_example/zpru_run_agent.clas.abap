CLASS zpru_run_agent DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zpru_run_agent IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.

**    DELETE FROM zpru_axc_head.
**    DELETE FROM zpru_axc_query.
**    DELETE FROM zpru_axc_step.
*
*
**    COMMIT WORK.
*
*    DATA(lo_agent_run) = NEW zpru_cl_api_agent( ).
*    TRY.
*        lo_agent_run->zpru_if_api_agent~initialize( iv_agent_name = 'MyFirstAgent' ).
*        lo_agent_run->zpru_if_api_agent~set_input_query( iv_input_query = 'TOOL_1' ).
*        DATA(lv_built_run_uuid) = lo_agent_run->zpru_if_api_agent~build_execution( ).
*        DATA(lv_saved_run_uuid) = lo_agent_run->zpru_if_api_agent~save_execution( iv_do_commit = abap_false
*                                                                                  iv_run_uuid  = lv_built_run_uuid ).
*        COMMIT WORK.
**        lo_agent_run->zpru_if_api_agent~run( iv_run_uuid = lv_saved_run_uuid ).
**
**        lo_agent_run->zpru_if_api_agent~rerun_execution( iv_run_uuid = lv_saved_run_uuid ).
*
*
**lo_agent_run->zpru_if_api_agent~rerun_from_step(
**  iv_run_uuid = lv_saved_run_uuid
**  query_uuid  =
**  step_uuid   =
**).
*
*      CATCH zpru_cx_agent_core.
*    ENDTRY.

  ENDMETHOD.
ENDCLASS.
