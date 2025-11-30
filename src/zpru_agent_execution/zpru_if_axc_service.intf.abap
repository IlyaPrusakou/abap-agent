INTERFACE zpru_if_axc_service
  PUBLIC .

  TYPES: BEGIN OF ts_head_control,
           agent_uuid         TYPE  abap_boolean,
           user_id            TYPE  abap_boolean,
           start_timestamp    TYPE  abap_boolean,
           end_timestamp      TYPE  abap_boolean,
           created_by         TYPE  abap_boolean,
           created_at         TYPE  abap_boolean,
           changed_by         TYPE  abap_boolean,
           last_changed       TYPE  abap_boolean,
           local_last_changed TYPE  abap_boolean,
         END OF ts_head_control.

  TYPES: BEGIN OF ts_head_create_imp.
           INCLUDE TYPE zpru_axc_head.
  TYPES:   control TYPE  ts_head_control.
  TYPES: END OF ts_head_create_imp.

  TYPES: tt_head_create_imp TYPE STANDARD TABLE OF ts_head_create_imp WITH EMPTY KEY.

  TYPES: BEGIN OF ts_header_reported,
           run_uuid TYPE sysuuid_x16,
           msg      TYPE REF TO zpru_if_agent_message,
         END OF ts_header_reported.

  TYPES tt_header_reported TYPE STANDARD TABLE OF ts_header_reported WITH EMPTY KEY.

  TYPES: BEGIN OF ts_header_failed,
           run_uuid TYPE sysuuid_x16,
         END OF ts_header_failed.

  TYPES tt_header_failed TYPE STANDARD TABLE OF ts_header_failed WITH EMPTY KEY.

  TYPES: BEGIN OF ts_header_mapped,
           run_uuid TYPE sysuuid_x16,
         END OF ts_header_mapped.

  TYPES tt_header_mapped TYPE STANDARD TABLE OF ts_header_mapped WITH EMPTY KEY.

  METHODS read_agent_execution
    IMPORTING it_axc_head_k TYPE zpru_if_axc_database_access=>tt_axc_head_k
    EXPORTING et_axc_head   TYPE zpru_if_axc_database_access=>tt_axc_head
              et_axc_query  TYPE zpru_if_axc_database_access=>tt_axc_query
              et_axc_step   TYPE zpru_if_axc_database_access=>tt_axc_step.

  METHODS get_actual_query
    IMPORTING it_axc_head_k                 TYPE zpru_if_axc_database_access=>tt_axc_head_k
    RETURNING VALUE(rt_axc_head_query_link) TYPE zpru_if_axc_database_access=>tt_axc_head_query_link.

  METHODS read.
  METHODS create
    IMPORTING it_head_create_imp TYPE tt_head_create_imp
    CHANGING  ct_header_reported TYPE tt_header_reported
              ct_header_failed type tt_header_failed.
  METHODS update.
  METHODS delete.
  METHODS lock.
  METHODS rba_query.
  METHODS cba_query.

ENDINTERFACE.
