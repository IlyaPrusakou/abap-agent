INTERFACE zpru_if_agent_frw
  PUBLIC.

  CONSTANTS: BEGIN OF  cs_execution_status,
               new       TYPE ZPRU_DE_AXC_QUERY_STATUS VALUE `N`,
               ERROR   TYPE ZPRU_DE_AXC_QUERY_STATUS VALUE `E`,
               completed TYPE ZPRU_DE_AXC_QUERY_STATUS VALUE `C`,
             END OF cs_execution_status.

  CONSTANTS:
    BEGIN OF  cs_fail_cause,
      unspecific   TYPE i VALUE 0,
      unauthorized TYPE i VALUE 401,
      not_found    TYPE i VALUE 404,
      conflict     TYPE i VALUE 409,
      locked       TYPE i VALUE 423,
      dependency   TYPE i VALUE 424,
      disabled     TYPE i VALUE 4221,
      readonly     TYPE i VALUE 4222,
    END OF  cs_fail_cause.

  CONSTANTS: BEGIN OF cs_message_class,
               zpru_msg_execution TYPE symsgid VALUE `ZPRU_MSG_EXECUTION`,
               zpru_msg_definition TYPE symsgid VALUE `ZPRU_MSG_DEFINITION`,
             END OF cs_message_class.

  CONSTANTS: BEGIN OF cs_sign,
               include TYPE char1 VALUE 'I',
               exclude TYPE char1 VALUE 'E',
             END OF cs_sign.

  CONSTANTS: BEGIN OF cs_option,
               equal TYPE char2 VALUE 'EQ',
             END OF cs_option.

  " ADF (Agent Definition) types
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

  TYPES: BEGIN OF ts_adf_reported,
           agent TYPE tt_agent_reported,
           tool  TYPE tt_tool_reported,
         END OF ts_adf_reported.

  TYPES: BEGIN OF ts_adf_failed,
           agent TYPE tt_agent_failed,
           tool  TYPE tt_tool_failed,
         END OF ts_adf_failed.

  TYPES: BEGIN OF ts_adf_mapped,
           agent TYPE tt_agent_mapped,
           tool  TYPE tt_tool_mapped,
         END OF ts_adf_mapped.

  " AXC (Agent eXecution Context) types
  TYPES: BEGIN OF ts_header_reported,
           run_uuid TYPE sysuuid_x16,
           msg      TYPE REF TO zpru_if_agent_message,
           create   TYPE abap_boolean,
           update   TYPE abap_boolean,
           delete   TYPE abap_boolean,
         END OF ts_header_reported.

  TYPES tt_header_reported TYPE STANDARD TABLE OF ts_header_reported WITH EMPTY KEY.

  TYPES: BEGIN OF ts_query_reported,
           query_uuid TYPE sysuuid_x16,
           msg        TYPE REF TO zpru_if_agent_message,
           create     TYPE abap_boolean,
           update     TYPE abap_boolean,
           delete     TYPE abap_boolean,
         END OF ts_query_reported.

  TYPES tt_query_reported TYPE STANDARD TABLE OF ts_query_reported WITH EMPTY KEY.

  TYPES: BEGIN OF ts_step_reported,
           step_uuid  TYPE sysuuid_x16,
           msg        TYPE REF TO zpru_if_agent_message,
           create     TYPE abap_boolean,
           update     TYPE abap_boolean,
           delete     TYPE abap_boolean,
         END OF ts_step_reported.

  TYPES tt_step_reported TYPE STANDARD TABLE OF ts_step_reported WITH EMPTY KEY.

  TYPES: BEGIN OF ts_header_failed,
           run_uuid TYPE sysuuid_x16,
           fail     TYPE i,
           create   TYPE abap_boolean,
           update   TYPE abap_boolean,
           delete   TYPE abap_boolean,
         END OF ts_header_failed.

  TYPES tt_header_failed TYPE STANDARD TABLE OF ts_header_failed WITH EMPTY KEY.

  TYPES: BEGIN OF ts_query_failed,
           query_uuid TYPE sysuuid_x16,
           fail       TYPE i,
           create     TYPE abap_boolean,
           update     TYPE abap_boolean,
           delete     TYPE abap_boolean,
         END OF ts_query_failed.

  TYPES tt_query_failed TYPE STANDARD TABLE OF ts_query_failed WITH EMPTY KEY.

  TYPES: BEGIN OF ts_step_failed,
           step_uuid  TYPE sysuuid_x16,
           fail       TYPE i,
           create     TYPE abap_boolean,
           update     TYPE abap_boolean,
           delete     TYPE abap_boolean,
         END OF ts_step_failed.

  TYPES tt_step_failed TYPE STANDARD TABLE OF ts_step_failed WITH EMPTY KEY.

  TYPES: BEGIN OF ts_header_mapped,
           run_uuid TYPE sysuuid_x16,
         END OF ts_header_mapped.

  TYPES tt_header_mapped TYPE STANDARD TABLE OF ts_header_mapped WITH EMPTY KEY.

  TYPES: BEGIN OF ts_query_mapped,
           query_uuid TYPE sysuuid_x16,
         END OF ts_query_mapped.

  TYPES tt_query_mapped TYPE STANDARD TABLE OF ts_query_mapped WITH EMPTY KEY.

  TYPES: BEGIN OF ts_step_mapped,
           step_uuid  TYPE sysuuid_x16,
         END OF ts_step_mapped.

  TYPES tt_step_mapped TYPE STANDARD TABLE OF ts_step_mapped WITH EMPTY KEY.

  TYPES: BEGIN OF ts_axc_reported,
           header TYPE tt_header_reported,
           query  TYPE tt_query_reported,
           step   TYPE tt_step_reported,
         END OF ts_axc_reported.

  TYPES: BEGIN OF ts_axc_failed,
           header TYPE tt_header_failed,
           query  TYPE tt_query_failed,
           step   TYPE tt_step_failed,
         END OF ts_axc_failed.

  TYPES: BEGIN OF ts_axc_mapped,
           header TYPE tt_header_mapped,
           query  TYPE tt_query_mapped,
           step   TYPE tt_step_mapped,
         END OF ts_axc_mapped.

  TYPES ts_json       TYPE string.
  TYPES tt_agent_tool TYPE STANDARD TABLE OF zpru_agent_tool WITH EMPTY KEY.

ENDINTERFACE.
