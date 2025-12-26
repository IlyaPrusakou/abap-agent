INTERFACE zpru_if_tool_provider
  PUBLIC.

  METHODS get_tool
    IMPORTING is_tool_master_data TYPE zpru_if_adf_type_and_constant=>ts_agent_tool
              is_execution_step   TYPE zpru_if_axc_type_and_constant=>ts_axc_step
    RETURNING VALUE(ro_executor)  TYPE REF TO zpru_if_tool_executor.

ENDINTERFACE.
