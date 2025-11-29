INTERFACE zpru_if_adf_service
  PUBLIC.

  TYPES tt_agent_name             TYPE RANGE OF char100.
  TYPES tt_decision_provider      TYPE RANGE OF char30.
  TYPES tt_short_memory_provider  TYPE RANGE OF char30.
  TYPES tt_long_memory_provider   TYPE RANGE OF char30.
  TYPES tt_agent_info_provider    TYPE RANGE OF char30.
  TYPES tt_system_prompt_provider TYPE RANGE OF char30.
  TYPES tt_status                 TYPE RANGE OF char1.
  TYPES tt_created_by             TYPE RANGE OF syuname.
  TYPES tt_created_at             TYPE RANGE OF timestampl.
  TYPES tt_changed_by             TYPE RANGE OF syuname.
  TYPES tt_last_changed           TYPE RANGE OF abp_lastchange_tstmpl.

  TYPES: BEGIN OF ts_tool_agent_link.
           INCLUDE TYPE zpru_if_adf_database_access=>ts_agent_k.
           INCLUDE TYPE zpru_if_adf_database_access=>ts_agent_tool_k.
  TYPES: END OF ts_tool_agent_link.

  TYPES tt_tool_agent_link TYPE STANDARD TABLE OF ts_tool_agent_link WITH EMPTY KEY.

  METHODS query_agent
    IMPORTING it_agent_name             TYPE tt_agent_name             OPTIONAL
              it_decision_provider      TYPE tt_decision_provider      OPTIONAL
              it_short_memory_provider  TYPE tt_short_memory_provider  OPTIONAL
              it_long_memory_provider   TYPE tt_long_memory_provider   OPTIONAL
              it_agent_info_provider    TYPE tt_agent_info_provider    OPTIONAL
              it_system_prompt_provider TYPE tt_system_prompt_provider OPTIONAL
              it_status                 TYPE tt_status                 OPTIONAL
              it_created_by             TYPE tt_created_by             OPTIONAL
              it_created_at             TYPE tt_created_at             OPTIONAL
              it_changed_by             TYPE tt_changed_by             OPTIONAL
              it_last_changed           TYPE tt_last_changed           OPTIONAL
    EXPORTING et_agent_k                TYPE zpru_if_adf_database_access=>tt_agent_k
              et_tool_agent_link        TYPE tt_tool_agent_link.

  METHODS read_agent
    IMPORTING it_agent_k    TYPE zpru_if_adf_database_access=>tt_agent_k
    EXPORTING et_agent      TYPE zpru_if_adf_database_access=>tt_agent
              et_agent_tool TYPE zpru_if_adf_database_access=>tt_agent_tool.

ENDINTERFACE.
