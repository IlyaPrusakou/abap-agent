CLASS zpru_cl_axc_service DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zpru_if_axc_service.
ENDCLASS.


CLASS zpru_cl_axc_service IMPLEMENTATION.
  METHOD zpru_if_axc_service~read_agent_execution.
    DATA lo_axc_database_access TYPE REF TO zpru_if_axc_database_access.

    CLEAR: et_axc_head,
           et_axc_query,
           et_axc_step.

    IF it_axc_head_k IS INITIAL.
      RETURN.
    ENDIF.

    lo_axc_database_access = NEW zpru_cl_axc_database_access( ).

    et_axc_head = lo_axc_database_access->select_head( it_axc_head_k ).

    IF et_axc_query IS SUPPLIED.
      et_axc_query = lo_axc_database_access->select_query_by_head( it_axc_head_k ).
    ENDIF.

    IF et_axc_step IS SUPPLIED.
      et_axc_step = lo_axc_database_access->select_step_by_query( VALUE #( FOR <ls_q_k> IN et_axc_query
                                                                           ( query_uuid = <ls_q_k>-query_uuid  ) ) ).
    ENDIF.
  ENDMETHOD.

  METHOD zpru_if_axc_service~get_actual_query.
    DATA lo_axc_database_access TYPE REF TO zpru_if_axc_database_access.

    IF it_axc_head_k IS INITIAL.
      RETURN.
    ENDIF.

    lo_axc_database_access = NEW zpru_cl_axc_database_access( ).
    DATA(lt_query_candidates) = lo_axc_database_access->select_query_by_head( it_axc_head_k ).

    LOOP AT it_axc_head_k ASSIGNING FIELD-SYMBOL(<ls_axc_head_k>).

      DATA(lt_query_copy) = lt_query_candidates.
      DELETE lt_query_copy WHERE run_uuid <> <ls_axc_head_k>-run_uuid.
      DELETE lt_query_copy WHERE execution_status <> zpru_if_agent_frw=>cs_execution_status-new.

      SORT lt_query_copy BY start_timestamp ASCENDING.

      APPEND INITIAL LINE TO rt_axc_head_query_link ASSIGNING FIELD-SYMBOL(<ls_axc_head_query_link>).
      <ls_axc_head_query_link>-run_uuid = <ls_axc_head_k>-run_uuid.
      <ls_axc_head_query_link>-query_uuid = VALUE #( lt_query_copy[ 1 ]-query_uuid OPTIONAL ).

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
