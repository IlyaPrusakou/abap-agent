INTERFACE zpru_if_input_schema_provider
  PUBLIC.
  INTERFACES zpru_if_agent_frw.

  METHODS get_input_schema
    IMPORTING is_tool_master_data    TYPE zpru_if_adf_type_and_constant=>ts_agent_tool
              is_execution_step      TYPE zpru_if_axc_type_and_constant=>ts_axc_step
    RETURNING VALUE(ro_input_schema) TYPE REF TO zpru_if_payload.
ENDINTERFACE.
