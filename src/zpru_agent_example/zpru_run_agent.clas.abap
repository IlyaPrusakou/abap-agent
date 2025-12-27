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
    GET TIME STAMP FIELD DATA(lv_now).
    lo_cl_unit_agent->execute_agent( iv_agent_name  = 'DUMMY_AGENT'
                                     iv_input_query = |\{ "INPUT_QUERY" : "MY QUERY - { lv_now }" \}| ).
  ENDMETHOD.
ENDCLASS.
