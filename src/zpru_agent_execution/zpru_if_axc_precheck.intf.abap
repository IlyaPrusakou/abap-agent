INTERFACE zpru_if_axc_precheck
  PUBLIC .

  METHODS precheck_create_header
    IMPORTING it_head_create_imp TYPE zpru_if_axc_type_and_constant=>tt_head_create_imp
    EXPORTING et_entities        TYPE zpru_if_axc_type_and_constant=>tt_head_create_imp
    CHANGING  cs_reported        TYPE zpru_if_agent_frw=>ts_axc_reported
              cs_failed          TYPE zpru_if_agent_frw=>ts_axc_failed.

  METHODS precheck_update_header
    IMPORTING it_head_update_imp TYPE zpru_if_axc_type_and_constant=>tt_head_update_imp
    EXPORTING et_entities        TYPE zpru_if_axc_type_and_constant=>tt_head_update_imp
    CHANGING  cs_reported        TYPE zpru_if_agent_frw=>ts_axc_reported
              cs_failed          TYPE zpru_if_agent_frw=>ts_axc_failed.

  METHODS precheck_delete_header
    IMPORTING it_head_delete_imp TYPE zpru_if_axc_type_and_constant=>tt_header_delete_imp
    EXPORTING et_entities        TYPE zpru_if_axc_type_and_constant=>tt_header_delete_imp
    CHANGING  cs_reported        TYPE zpru_if_agent_frw=>ts_axc_reported
              cs_failed          TYPE zpru_if_agent_frw=>ts_axc_failed.

  METHODS precheck_cba_query
    IMPORTING it_axc_query_imp TYPE zpru_if_axc_type_and_constant=>tt_query_create_imp
    EXPORTING et_entities      TYPE zpru_if_axc_type_and_constant=>tt_query_create_imp
    CHANGING  cs_reported      TYPE zpru_if_agent_frw=>ts_axc_reported
              cs_failed        TYPE zpru_if_agent_frw=>ts_axc_failed.

  METHODS precheck_read_header
    IMPORTING it_head_read_k TYPE zpru_if_axc_type_and_constant=>tt_head_read_k
    EXPORTING et_entities    TYPE zpru_if_axc_type_and_constant=>tt_head_read_k
    CHANGING  cs_reported    TYPE zpru_if_agent_frw=>ts_axc_reported
              cs_failed      TYPE zpru_if_agent_frw=>ts_axc_failed.

  METHODS precheck_rba_query
    IMPORTING it_rba_query_k TYPE zpru_if_axc_type_and_constant=>tt_rba_query_k
    EXPORTING et_entities    TYPE zpru_if_axc_type_and_constant=>tt_rba_query_k
    CHANGING  cs_reported    TYPE zpru_if_agent_frw=>ts_axc_reported
              cs_failed      TYPE zpru_if_agent_frw=>ts_axc_failed.

  METHODS precheck_cba_step
    IMPORTING it_axc_step_imp TYPE zpru_if_axc_type_and_constant=>tt_step_create_imp
    EXPORTING et_entities     TYPE zpru_if_axc_type_and_constant=>tt_step_create_imp
    CHANGING  cs_reported     TYPE zpru_if_agent_frw=>ts_axc_reported
              cs_failed       TYPE zpru_if_agent_frw=>ts_axc_failed.

  METHODS precheck_rba_step
    IMPORTING it_rba_step_k TYPE zpru_if_axc_type_and_constant=>tt_rba_step_k
    EXPORTING et_entities   TYPE zpru_if_axc_type_and_constant=>tt_rba_step_k
    CHANGING  cs_reported   TYPE zpru_if_agent_frw=>ts_axc_reported
              cs_failed     TYPE zpru_if_agent_frw=>ts_axc_failed.

  METHODS precheck_read_step
    IMPORTING it_step_read_k TYPE zpru_if_axc_type_and_constant=>tt_step_read_k
    EXPORTING et_entities    TYPE zpru_if_axc_type_and_constant=>tt_step_read_k
    CHANGING  cs_reported    TYPE zpru_if_agent_frw=>ts_axc_reported
              cs_failed      TYPE zpru_if_agent_frw=>ts_axc_failed.

  METHODS precheck_update_step
    IMPORTING it_step_update_imp TYPE zpru_if_axc_type_and_constant=>tt_step_update_imp
    EXPORTING et_entities        TYPE zpru_if_axc_type_and_constant=>tt_step_update_imp
    CHANGING  cs_reported        TYPE zpru_if_agent_frw=>ts_axc_reported
              cs_failed          TYPE zpru_if_agent_frw=>ts_axc_failed.

  METHODS precheck_delete_step
    IMPORTING it_step_delete_imp TYPE zpru_if_axc_type_and_constant=>tt_step_delete_imp
    EXPORTING et_entities        TYPE zpru_if_axc_type_and_constant=>tt_step_delete_imp
    CHANGING  cs_reported        TYPE zpru_if_agent_frw=>ts_axc_reported
              cs_failed          TYPE zpru_if_agent_frw=>ts_axc_failed.

  METHODS precheck_read_query
    IMPORTING it_query_read_k TYPE zpru_if_axc_type_and_constant=>tt_query_read_k
    EXPORTING et_entities     TYPE zpru_if_axc_type_and_constant=>tt_query_read_k
    CHANGING  cs_reported     TYPE zpru_if_agent_frw=>ts_axc_reported
              cs_failed       TYPE zpru_if_agent_frw=>ts_axc_failed.

  METHODS precheck_update_query
    IMPORTING it_query_update_imp TYPE zpru_if_axc_type_and_constant=>tt_query_update_imp
    EXPORTING et_entities         TYPE zpru_if_axc_type_and_constant=>tt_query_update_imp
    CHANGING  cs_reported         TYPE zpru_if_agent_frw=>ts_axc_reported
              cs_failed           TYPE zpru_if_agent_frw=>ts_axc_failed.

  METHODS precheck_delete_query
    IMPORTING it_query_delete_imp TYPE zpru_if_axc_type_and_constant=>tt_query_delete_imp
    EXPORTING et_entities         TYPE zpru_if_axc_type_and_constant=>tt_query_delete_imp
    CHANGING  cs_reported         TYPE zpru_if_agent_frw=>ts_axc_reported
              cs_failed           TYPE zpru_if_agent_frw=>ts_axc_failed.

ENDINTERFACE.
