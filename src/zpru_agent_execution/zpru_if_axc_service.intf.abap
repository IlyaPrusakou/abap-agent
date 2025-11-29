INTERFACE zpru_if_axc_service
  PUBLIC .

  methods read_agent_execution
    importing it_axc_head_k    type zpru_if_axc_database_access=>tt_axc_head_k
    exporting et_axc_head      type zpru_if_axc_database_access=>tt_axc_head
              et_axc_query type zpru_if_axc_database_access=>tt_axc_query
              et_axc_step type zpru_if_axc_database_access=>tt_axc_step.

  METHODS get_actual_query
    IMPORTING it_axc_head_k                 TYPE zpru_if_axc_database_access=>tt_axc_head_k
    RETURNING VALUE(rt_axc_head_query_link) TYPE zpru_if_axc_database_access=>tt_axc_head_query_link.

ENDINTERFACE.
