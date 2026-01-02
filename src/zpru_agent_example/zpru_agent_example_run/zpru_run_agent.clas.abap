CLASS zpru_run_agent DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.


CLASS zpru_run_agent IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DATA lo_cl_unit_agent TYPE REF TO zpru_if_unit_agent.

    lo_cl_unit_agent = NEW zpru_cl_unit_agent( ).
    lo_cl_unit_agent->execute_agent( iv_agent_name  = 'DUMMY_AGENT'
                                     iv_input_query = zpru_cl_dummy_agent_logic=>get_input_prompt( ) ).
  ENDMETHOD.
ENDCLASS.
