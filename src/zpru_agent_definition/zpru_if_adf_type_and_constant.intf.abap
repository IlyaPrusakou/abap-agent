INTERFACE zpru_if_adf_type_and_constant
  PUBLIC .

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

  TYPES: BEGIN OF ts_agent_reported,
           agent_uuid TYPE sysuuid_x16,
           msg        TYPE REF TO zpru_if_agent_message,
           create     TYPE abap_boolean,
           update     TYPE abap_boolean,
           delete     TYPE abap_boolean,
         END OF ts_agent_reported.

  TYPES tt_agent_reported TYPE STANDARD TABLE OF ts_agent_reported WITH EMPTY KEY.

  TYPES: BEGIN OF ts_tool_reported,
           agent_uuid TYPE sysuuid_x16,
           tool_uuid  TYPE sysuuid_x16,
           msg        TYPE REF TO zpru_if_agent_message,
           create     TYPE abap_boolean,
           update     TYPE abap_boolean,
           delete     TYPE abap_boolean,
         END OF ts_tool_reported.

  TYPES tt_tool_reported TYPE STANDARD TABLE OF ts_tool_reported WITH EMPTY KEY.

  TYPES: BEGIN OF ts_agent_failed,
           agent_uuid TYPE sysuuid_x16,
           fail       TYPE i,
           create     TYPE abap_boolean,
           update     TYPE abap_boolean,
           delete     TYPE abap_boolean,
         END OF ts_agent_failed.

  TYPES tt_agent_failed TYPE STANDARD TABLE OF ts_agent_failed WITH EMPTY KEY.

  TYPES: BEGIN OF ts_tool_failed,
           agent_uuid TYPE sysuuid_x16,
           tool_uuid  TYPE sysuuid_x16,
           fail       TYPE i,
           create     TYPE abap_boolean,
           update     TYPE abap_boolean,
           delete     TYPE abap_boolean,
         END OF ts_tool_failed.

  TYPES tt_tool_failed TYPE STANDARD TABLE OF ts_tool_failed WITH EMPTY KEY.

  TYPES: BEGIN OF ts_agent_mapped,
           agent_uuid TYPE sysuuid_x16,
         END OF ts_agent_mapped.

  TYPES tt_agent_mapped TYPE STANDARD TABLE OF ts_agent_mapped WITH EMPTY KEY.

  TYPES: BEGIN OF ts_tool_mapped,
           agent_uuid TYPE sysuuid_x16,
           tool_uuid  TYPE sysuuid_x16,
         END OF ts_tool_mapped.

  TYPES tt_tool_mapped TYPE STANDARD TABLE OF ts_tool_mapped WITH EMPTY KEY.

  TYPES: BEGIN OF ts_reported,
           agent TYPE tt_agent_reported,
           tool  TYPE tt_tool_reported,
         END OF ts_reported.

  TYPES: BEGIN OF ts_failed,
           agent TYPE tt_agent_failed,
           tool  TYPE tt_tool_failed,
         END OF ts_failed.

  TYPES: BEGIN OF ts_mapped,
           agent TYPE tt_agent_mapped,
           tool  TYPE tt_tool_mapped,
         END OF ts_mapped.

ENDINTERFACE.
