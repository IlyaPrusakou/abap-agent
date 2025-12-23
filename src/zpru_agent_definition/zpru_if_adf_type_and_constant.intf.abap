INTERFACE zpru_if_adf_type_and_constant
  PUBLIC.

  CONSTANTS: BEGIN OF cs_agent_status,
               new      TYPE zpru_de_adf_agent_status VALUE 'N',
               active   TYPE zpru_de_adf_agent_status VALUE 'A',
               inactive TYPE zpru_de_adf_agent_status VALUE 'I',
             END OF cs_agent_status.

  CONSTANTS: BEGIN OF cs_step_type,
               simple_code      TYPE zpru_de_adf_step_type VALUE 'S', " Simple Code
               knowledge_source TYPE zpru_de_adf_step_type VALUE 'K', " Knowledge Source
               nested_agent     TYPE zpru_de_adf_step_type VALUE 'A', " Nested Agent
             END OF cs_step_type.

  TYPES: BEGIN OF ts_agent_control,
           agent_uuid             TYPE abap_boolean,
           agent_name             TYPE abap_boolean,
           decision_provider      TYPE abap_boolean,
           short_memory_provider  TYPE abap_boolean,
           long_memory_provider   TYPE abap_boolean,
           agent_info_provider    TYPE abap_boolean,
           system_prompt_provider TYPE abap_boolean,
           status                 TYPE abap_boolean,
           created_by             TYPE abap_boolean,
           created_at             TYPE abap_boolean,
           changed_by             TYPE abap_boolean,
           last_changed           TYPE abap_boolean,
           local_last_changed     TYPE abap_boolean,
         END OF ts_agent_control.

  TYPES: BEGIN OF ts_agent_k,
           agent_uuid TYPE sysuuid_x16,
         END OF ts_agent_k.

  TYPES tt_agent_k TYPE STANDARD TABLE OF ts_agent_k WITH EMPTY KEY.

  TYPES: BEGIN OF ts_agent_tool_k,
           tool_uuid TYPE sysuuid_x16,
         END OF ts_agent_tool_k.

  TYPES tt_agent_tool_k TYPE STANDARD TABLE OF ts_agent_tool_k WITH EMPTY KEY.

  TYPES ts_agent        TYPE zpru_agent.
  TYPES tt_agent        TYPE STANDARD TABLE OF ts_agent WITH EMPTY KEY.

  TYPES ts_agent_tool   TYPE zpru_agent_tool.
  TYPES tt_agent_tool   TYPE STANDARD TABLE OF ts_agent_tool WITH EMPTY KEY.

  TYPES: BEGIN OF ts_agent_create_imp.
           INCLUDE TYPE zpru_agent.
  TYPES:   control TYPE ts_agent_control.
  TYPES: END OF ts_agent_create_imp.

  TYPES tt_agent_create_imp TYPE STANDARD TABLE OF ts_agent_create_imp WITH EMPTY KEY.

  TYPES: BEGIN OF ts_agent_update_imp.
           INCLUDE TYPE zpru_agent.
  TYPES:   control TYPE ts_agent_control.
  TYPES: END OF ts_agent_update_imp.

  TYPES tt_agent_update_imp TYPE STANDARD TABLE OF ts_agent_update_imp WITH EMPTY KEY.

  TYPES: BEGIN OF ts_agent_read_k,
           agent_uuid TYPE sysuuid_x16,
           control    TYPE ts_agent_control,
         END OF ts_agent_read_k.

  TYPES tt_agent_read_k TYPE STANDARD TABLE OF ts_agent_read_k WITH EMPTY KEY.

  TYPES: BEGIN OF ts_agent_delete_imp,
           agent_uuid TYPE sysuuid_x16,
         END OF ts_agent_delete_imp.

  TYPES tt_agent_delete_imp TYPE STANDARD TABLE OF ts_agent_delete_imp WITH EMPTY KEY.

  TYPES: BEGIN OF ts_tool_control,
           tool_uuid             TYPE abap_boolean,
           agent_uuid            TYPE abap_boolean,
           tool_name             TYPE abap_boolean,
           tool_provider         TYPE abap_boolean,
           step_type             TYPE abap_boolean,
           input_schema_provider TYPE abap_boolean,
           tool_info_provider    TYPE abap_boolean,
         END OF ts_tool_control.

  TYPES: BEGIN OF ts_rba_tool_k,
           agent_uuid TYPE sysuuid_x16,
           control    TYPE ts_tool_control,
         END OF ts_rba_tool_k.

  TYPES tt_rba_tool_k TYPE STANDARD TABLE OF ts_rba_tool_k WITH EMPTY KEY.

  TYPES: BEGIN OF ts_tool_create_imp.
           INCLUDE TYPE zpru_agent_tool.
  TYPES:   control TYPE ts_tool_control.
  TYPES: END OF ts_tool_create_imp.

  TYPES tt_tool_create_imp TYPE STANDARD TABLE OF ts_tool_create_imp WITH EMPTY KEY.

  TYPES: BEGIN OF ts_tool_read_k,
           agent_uuid TYPE sysuuid_x16,
           tool_uuid  TYPE sysuuid_x16,
           control    TYPE ts_tool_control,
         END OF ts_tool_read_k.

  TYPES tt_tool_read_k TYPE STANDARD TABLE OF ts_tool_read_k WITH EMPTY KEY.

  TYPES: BEGIN OF ts_tool_update_imp.
           INCLUDE TYPE zpru_agent_tool.
  TYPES:   control TYPE ts_tool_control.
  TYPES: END OF ts_tool_update_imp.

  TYPES tt_tool_update_imp TYPE STANDARD TABLE OF ts_tool_update_imp WITH EMPTY KEY.

  TYPES: BEGIN OF ts_tool_delete_imp,
           agent_uuid TYPE sysuuid_x16,
           tool_uuid  TYPE sysuuid_x16,
         END OF ts_tool_delete_imp.

  TYPES tt_tool_delete_imp TYPE STANDARD TABLE OF ts_tool_delete_imp WITH EMPTY KEY.

ENDINTERFACE.
