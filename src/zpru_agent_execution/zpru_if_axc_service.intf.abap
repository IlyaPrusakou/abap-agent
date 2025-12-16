INTERFACE zpru_if_axc_service
  PUBLIC.

  METHODS read_agent_execution
    IMPORTING it_axc_head_k TYPE zpru_if_axc_database_access=>tt_axc_head_k
    EXPORTING et_axc_head   TYPE zpru_if_axc_database_access=>tt_axc_head
              et_axc_query  TYPE zpru_if_axc_database_access=>tt_axc_query
              et_axc_step   TYPE zpru_if_axc_database_access=>tt_axc_step.

  METHODS get_actual_query
    IMPORTING it_axc_head_k                 TYPE zpru_if_axc_database_access=>tt_axc_head_k
    RETURNING VALUE(rt_axc_head_query_link) TYPE zpru_if_axc_database_access=>tt_axc_head_query_link.

  METHODS read_header
    IMPORTING it_head_read_k TYPE zpru_if_axc_type_and_constant=>tt_head_read_k
    EXPORTING et_axc_head    TYPE zpru_if_axc_database_access=>tt_axc_head
    CHANGING  cs_reported    TYPE zpru_if_agent_frw=>ts_axc_reported
              cs_failed      TYPE zpru_if_agent_frw=>ts_axc_failed.

  METHODS create_header
    IMPORTING it_head_create_imp TYPE zpru_if_axc_type_and_constant=>tt_head_create_imp
    CHANGING  cs_reported        TYPE zpru_if_agent_frw=>ts_axc_reported
              cs_failed          TYPE zpru_if_agent_frw=>ts_axc_failed
              cs_mapped          TYPE zpru_if_agent_frw=>ts_axc_mapped.

  METHODS update_header
    IMPORTING it_head_update_imp TYPE zpru_if_axc_type_and_constant=>tt_head_update_imp
    CHANGING  cs_reported        TYPE zpru_if_agent_frw=>ts_axc_reported
              cs_failed          TYPE zpru_if_agent_frw=>ts_axc_failed.

  METHODS delete_header
    IMPORTING it_head_delete_imp TYPE zpru_if_axc_type_and_constant=>tt_header_delete_imp
    CHANGING  cs_reported        TYPE zpru_if_agent_frw=>ts_axc_reported
              cs_failed          TYPE zpru_if_agent_frw=>ts_axc_failed.

  METHODS lock.

  METHODS rba_query
    IMPORTING it_rba_query_k TYPE zpru_if_axc_type_and_constant=>tt_rba_query_k
    EXPORTING et_axc_query   TYPE zpru_if_axc_database_access=>tt_axc_query
    CHANGING  cs_reported    TYPE zpru_if_agent_frw=>ts_axc_reported
              cs_failed      TYPE zpru_if_agent_frw=>ts_axc_failed.

  METHODS read_query
    IMPORTING it_query_read_k TYPE zpru_if_axc_type_and_constant=>tt_query_read_k
    EXPORTING et_axc_query    TYPE zpru_if_axc_database_access=>tt_axc_query
    CHANGING  cs_reported     TYPE zpru_if_agent_frw=>ts_axc_reported
              cs_failed       TYPE zpru_if_agent_frw=>ts_axc_failed.

  METHODS update_query
    IMPORTING it_query_update_imp TYPE zpru_if_axc_type_and_constant=>tt_query_update_imp
    CHANGING  cs_reported         TYPE zpru_if_agent_frw=>ts_axc_reported
              cs_failed           TYPE zpru_if_agent_frw=>ts_axc_failed.

  METHODS delete_query
    IMPORTING it_query_delete_imp TYPE zpru_if_axc_type_and_constant=>tt_query_delete_imp
    CHANGING  cs_reported         TYPE zpru_if_agent_frw=>ts_axc_reported
              cs_failed           TYPE zpru_if_agent_frw=>ts_axc_failed.

  METHODS cba_query
    IMPORTING it_axc_query_imp TYPE zpru_if_axc_type_and_constant=>tt_query_create_imp
    CHANGING  cs_reported      TYPE zpru_if_agent_frw=>ts_axc_reported
              cs_failed        TYPE zpru_if_agent_frw=>ts_axc_failed
              cs_mapped        TYPE zpru_if_agent_frw=>ts_axc_mapped.

  METHODS rba_step
    IMPORTING it_rba_step_k TYPE zpru_if_axc_type_and_constant=>tt_rba_step_k
    EXPORTING et_axc_step   TYPE zpru_if_axc_database_access=>tt_axc_step
    CHANGING  cs_reported   TYPE zpru_if_agent_frw=>ts_axc_reported
              cs_failed     TYPE zpru_if_agent_frw=>ts_axc_failed.

  METHODS read_step
    IMPORTING it_step_read_k TYPE zpru_if_axc_type_and_constant=>tt_step_read_k
    EXPORTING et_axc_step    TYPE zpru_if_axc_database_access=>tt_axc_step
    CHANGING  cs_reported    TYPE zpru_if_agent_frw=>ts_axc_reported
              cs_failed      TYPE zpru_if_agent_frw=>ts_axc_failed.

  METHODS update_step
    IMPORTING it_step_update_imp TYPE zpru_if_axc_type_and_constant=>tt_step_update_imp
    CHANGING  cs_reported        TYPE zpru_if_agent_frw=>ts_axc_reported
              cs_failed          TYPE zpru_if_agent_frw=>ts_axc_failed.

  METHODS delete_step
    IMPORTING it_step_delete_imp TYPE zpru_if_axc_type_and_constant=>tt_step_delete_imp
    CHANGING  cs_reported        TYPE zpru_if_agent_frw=>ts_axc_reported
              cs_failed          TYPE zpru_if_agent_frw=>ts_axc_failed.

  METHODS cba_step
    IMPORTING it_axc_step_imp TYPE zpru_if_axc_type_and_constant=>tt_step_create_imp
    CHANGING  cs_reported     TYPE zpru_if_agent_frw=>ts_axc_reported
              cs_failed       TYPE zpru_if_agent_frw=>ts_axc_failed
              cs_mapped       TYPE zpru_if_agent_frw=>ts_axc_mapped.

  METHODS determine
    CHANGING cs_reported TYPE zpru_if_agent_frw=>ts_axc_reported
             cs_failed   TYPE zpru_if_agent_frw=>ts_axc_failed
             cs_mapped   TYPE zpru_if_agent_frw=>ts_axc_mapped.

  METHODS validate
    CHANGING cs_reported TYPE zpru_if_agent_frw=>ts_axc_reported
             cs_failed   TYPE zpru_if_agent_frw=>ts_axc_failed.

  METHODS clean_up
    CHANGING cs_mapped TYPE zpru_if_agent_frw=>ts_axc_mapped.

  METHODS do_save
    IMPORTING iv_do_commit TYPE abap_boolean DEFAULT abap_true
    CHANGING  cs_reported  TYPE zpru_if_agent_frw=>ts_axc_reported
              cs_failed    TYPE zpru_if_agent_frw=>ts_axc_failed
              cs_mapped    TYPE zpru_if_agent_frw=>ts_axc_mapped.

ENDINTERFACE.
