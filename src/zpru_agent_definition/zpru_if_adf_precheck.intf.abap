INTERFACE zpru_if_adf_precheck
  PUBLIC .

  METHODS precheck_create_agent
    IMPORTING it_agent_create_imp TYPE zpru_if_adf_type_and_constant=>tt_agent_create_imp
    EXPORTING et_entities         TYPE zpru_if_adf_type_and_constant=>tt_agent_create_imp
    CHANGING  cs_reported         TYPE zpru_if_adf_type_and_constant=>ts_reported
              cs_failed           TYPE zpru_if_adf_type_and_constant=>ts_failed.

  METHODS precheck_update_agent
    IMPORTING it_agent_update_imp TYPE zpru_if_adf_type_and_constant=>tt_agent_update_imp
    EXPORTING et_entities         TYPE zpru_if_adf_type_and_constant=>tt_agent_update_imp
    CHANGING  cs_reported         TYPE zpru_if_adf_type_and_constant=>ts_reported
              cs_failed           TYPE zpru_if_adf_type_and_constant=>ts_failed.

  METHODS precheck_delete_agent
    IMPORTING it_agent_delete_imp TYPE zpru_if_adf_type_and_constant=>tt_agent_delete_imp
    EXPORTING et_entities         TYPE zpru_if_adf_type_and_constant=>tt_agent_delete_imp
    CHANGING  cs_reported         TYPE zpru_if_adf_type_and_constant=>ts_reported
              cs_failed           TYPE zpru_if_adf_type_and_constant=>ts_failed.

  METHODS precheck_read_agent
    IMPORTING it_agent_read_k TYPE zpru_if_adf_type_and_constant=>tt_agent_read_k
    EXPORTING et_entities     TYPE zpru_if_adf_type_and_constant=>tt_agent_read_k
    CHANGING  cs_reported     TYPE zpru_if_adf_type_and_constant=>ts_reported
              cs_failed       TYPE zpru_if_adf_type_and_constant=>ts_failed.

  METHODS precheck_cba_tool
    IMPORTING it_tool_create_imp TYPE zpru_if_adf_type_and_constant=>tt_tool_create_imp
    EXPORTING et_entities        TYPE zpru_if_adf_type_and_constant=>tt_tool_create_imp
    CHANGING  cs_reported        TYPE zpru_if_adf_type_and_constant=>ts_reported
              cs_failed          TYPE zpru_if_adf_type_and_constant=>ts_failed.

  METHODS precheck_update_tool
    IMPORTING it_tool_update_imp TYPE zpru_if_adf_type_and_constant=>tt_tool_update_imp
    EXPORTING et_entities        TYPE zpru_if_adf_type_and_constant=>tt_tool_update_imp
    CHANGING  cs_reported        TYPE zpru_if_adf_type_and_constant=>ts_reported
              cs_failed          TYPE zpru_if_adf_type_and_constant=>ts_failed.

  METHODS precheck_delete_tool
    IMPORTING it_tool_delete_imp TYPE zpru_if_adf_type_and_constant=>tt_tool_delete_imp
    EXPORTING et_entities        TYPE zpru_if_adf_type_and_constant=>tt_tool_delete_imp
    CHANGING  cs_reported        TYPE zpru_if_adf_type_and_constant=>ts_reported
              cs_failed          TYPE zpru_if_adf_type_and_constant=>ts_failed.

  METHODS precheck_read_tool
    IMPORTING it_tool_read_k TYPE zpru_if_adf_type_and_constant=>tt_tool_read_k
    EXPORTING et_entities    TYPE zpru_if_adf_type_and_constant=>tt_tool_read_k
    CHANGING  cs_reported    TYPE zpru_if_adf_type_and_constant=>ts_reported
              cs_failed      TYPE zpru_if_adf_type_and_constant=>ts_failed.

  METHODS precheck_rba_tool
    IMPORTING it_rba_tool_k TYPE zpru_if_adf_type_and_constant=>tt_rba_tool_k
    EXPORTING et_entities   TYPE zpru_if_adf_type_and_constant=>tt_rba_tool_k
    CHANGING  cs_reported   TYPE zpru_if_adf_type_and_constant=>ts_reported
              cs_failed     TYPE zpru_if_adf_type_and_constant=>ts_failed.

ENDINTERFACE.
