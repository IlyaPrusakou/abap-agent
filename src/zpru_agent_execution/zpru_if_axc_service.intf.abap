INTERFACE zpru_if_axc_service
  PUBLIC.

  TYPES: BEGIN OF ts_head_control,
           agent_uuid         TYPE abap_boolean,
           user_id            TYPE abap_boolean,
           start_timestamp    TYPE abap_boolean,
           end_timestamp      TYPE abap_boolean,
           created_by         TYPE abap_boolean,
           created_at         TYPE abap_boolean,
           changed_by         TYPE abap_boolean,
           last_changed       TYPE abap_boolean,
           local_last_changed TYPE abap_boolean,
         END OF ts_head_control.

  TYPES: BEGIN OF ts_head_create_imp.
           INCLUDE TYPE zpru_axc_head.
  TYPES:   control TYPE ts_head_control.
  TYPES: END OF ts_head_create_imp.

  TYPES tt_head_create_imp TYPE STANDARD TABLE OF ts_head_create_imp WITH EMPTY KEY.

  TYPES: BEGIN OF ts_head_update_imp.
           INCLUDE TYPE zpru_axc_head.
  TYPES:   control TYPE ts_head_control.
  TYPES: END OF ts_head_update_imp.

  TYPES tt_head_update_imp TYPE STANDARD TABLE OF ts_head_update_imp WITH EMPTY KEY.

  TYPES: BEGIN OF ts_head_read_k,
           run_uuid TYPE sysuuid_x16,
           control  TYPE ts_head_control,
         END OF ts_head_read_k.

  TYPES tt_head_read_k TYPE STANDARD TABLE OF ts_head_read_k WITH EMPTY KEY.

  TYPES: BEGIN OF ts_query_control,
           run_uuid        TYPE abap_boolean,
           query_uuid      TYPE abap_boolean,
           language        TYPE abap_boolean,
           execution_status TYPE abap_boolean,
           start_timestamp TYPE abap_boolean,
           end_timestamp   TYPE abap_boolean,
           input_prompt    TYPE abap_boolean,
           decision_log    TYPE abap_boolean,
           output_response TYPE abap_boolean,
         END OF ts_query_control.

  TYPES: BEGIN OF ts_rba_query_k,
           run_uuid TYPE sysuuid_x16,
           control  TYPE ts_query_control,
         END OF ts_rba_query_k.

  TYPES tt_rba_query_k TYPE STANDARD TABLE OF ts_rba_query_k WITH EMPTY KEY.

  TYPES: BEGIN OF ts_query_create_imp.
          INCLUDE TYPE zpru_axc_query.
  TYPES:    control TYPE ts_query_control.
  TYPES: END OF ts_query_create_imp.

  TYPES tt_query_create_imp TYPE STANDARD TABLE OF ts_query_create_imp WITH EMPTY KEY.

  " Full key for query-level read/update/delete
  TYPES: BEGIN OF ts_query_read_k,
           run_uuid   TYPE sysuuid_x16,
           query_uuid TYPE sysuuid_x16,
           control    TYPE ts_query_control,
         END OF ts_query_read_k.

  TYPES tt_query_read_k TYPE STANDARD TABLE OF ts_query_read_k WITH EMPTY KEY.

  TYPES: BEGIN OF ts_query_update_imp,
           INCLUDE TYPE zpru_axc_query,
         TYPES: control TYPE ts_query_control,
         END OF ts_query_update_imp.

  TYPES tt_query_update_imp TYPE STANDARD TABLE OF ts_query_update_imp WITH EMPTY KEY.

  TYPES: BEGIN OF ts_query_delete_imp,
           run_uuid   TYPE sysuuid_x16,
           query_uuid TYPE sysuuid_x16,
         END OF ts_query_delete_imp.

  TYPES tt_query_delete_imp TYPE STANDARD TABLE OF ts_query_delete_imp WITH EMPTY KEY.

  TYPES: BEGIN OF ts_header_reported,
           run_uuid TYPE sysuuid_x16,
           msg      TYPE REF TO zpru_if_agent_message,
           create   TYPE abap_boolean,
           update   TYPE abap_boolean,
           delete   TYPE abap_boolean,
         END OF ts_header_reported.

  TYPES tt_header_reported TYPE STANDARD TABLE OF ts_header_reported WITH EMPTY KEY.

  TYPES: BEGIN OF ts_query_reported,
           run_uuid   TYPE sysuuid_x16,
           query_uuid TYPE sysuuid_x16,
           msg        TYPE REF TO zpru_if_agent_message,
           create     TYPE abap_boolean,
           update     TYPE abap_boolean,
           delete     TYPE abap_boolean,
         END OF ts_query_reported.

  TYPES tt_query_reported TYPE STANDARD TABLE OF ts_query_reported WITH EMPTY KEY.

  TYPES: BEGIN OF ts_header_failed,
           run_uuid TYPE sysuuid_x16,
           fail     TYPE i,
           create   TYPE abap_boolean,
           update   TYPE abap_boolean,
           delete   TYPE abap_boolean,
         END OF ts_header_failed.

  TYPES tt_header_failed TYPE STANDARD TABLE OF ts_header_failed WITH EMPTY KEY.

  TYPES: BEGIN OF ts_query_failed,
           run_uuid   TYPE sysuuid_x16,
           query_uuid TYPE sysuuid_x16,
           fail       TYPE i,
           create     TYPE abap_boolean,
           update     TYPE abap_boolean,
           delete     TYPE abap_boolean,
         END OF ts_query_failed.

  TYPES tt_query_failed TYPE STANDARD TABLE OF ts_query_failed WITH EMPTY KEY.

  TYPES: BEGIN OF ts_header_mapped,
           run_uuid TYPE sysuuid_x16,
         END OF ts_header_mapped.

  TYPES tt_header_mapped TYPE STANDARD TABLE OF ts_header_mapped WITH EMPTY KEY.

  TYPES: BEGIN OF ts_query_mapped,
          run_uuid   TYPE sysuuid_x16,
          query_uuid TYPE sysuuid_x16,
         END OF ts_query_mapped.

    TYPES tt_query_mapped TYPE STANDARD TABLE OF ts_query_mapped WITH EMPTY KEY.

    TYPES: BEGIN OF ts_step_control,
        step_uuid       TYPE abap_boolean,
        query_uuid      TYPE abap_boolean,
        run_uuid        TYPE abap_boolean,
        tool_uuid       TYPE abap_boolean,
        execution_seq   TYPE abap_boolean,
        start_timestamp TYPE abap_boolean,
        end_timestamp   TYPE abap_boolean,
        input_prompt    TYPE abap_boolean,
        output_prompt   TYPE abap_boolean,
      END OF ts_step_control.

    TYPES: BEGIN OF ts_step_create_imp,
       INCLUDE TYPE zpru_axc_step.
    TYPES:   control TYPE ts_step_control.
    TYPES: END OF ts_step_create_imp.

    TYPES tt_step_create_imp TYPE STANDARD TABLE OF ts_step_create_imp WITH EMPTY KEY.

    TYPES: BEGIN OF ts_step_reported,
        run_uuid   TYPE sysuuid_x16,
        query_uuid TYPE sysuuid_x16,
        step_uuid  TYPE sysuuid_x16,
        msg        TYPE REF TO zpru_if_agent_message,
        create     TYPE abap_boolean,
        update     TYPE abap_boolean,
        delete     TYPE abap_boolean,
      END OF ts_step_reported.

    TYPES tt_step_reported TYPE STANDARD TABLE OF ts_step_reported WITH EMPTY KEY.

    TYPES: BEGIN OF ts_step_failed,
        run_uuid   TYPE sysuuid_x16,
        query_uuid TYPE sysuuid_x16,
        step_uuid  TYPE sysuuid_x16,
        fail       TYPE i,
        create     TYPE abap_boolean,
        update     TYPE abap_boolean,
        delete     TYPE abap_boolean,
      END OF ts_step_failed.

    TYPES tt_step_failed TYPE STANDARD TABLE OF ts_step_failed WITH EMPTY KEY.

    TYPES: BEGIN OF ts_step_mapped,
        run_uuid   TYPE sysuuid_x16,
        query_uuid TYPE sysuuid_x16,
        step_uuid  TYPE sysuuid_x16,
      END OF ts_step_mapped.

    TYPES tt_step_mapped TYPE STANDARD TABLE OF ts_step_mapped WITH EMPTY KEY.

    TYPES: BEGIN OF ts_reported,
        header TYPE tt_header_reported,
        query  TYPE tt_query_reported,
        step   TYPE tt_step_reported,
      END OF ts_reported.
 
  " RBA (query -> step) key and full-key types for step-level operations
  TYPES: BEGIN OF ts_rba_step_k,
    query_uuid TYPE sysuuid_x16,
    control    TYPE ts_step_control,
  END OF ts_rba_step_k.

  TYPES tt_rba_step_k TYPE STANDARD TABLE OF ts_rba_step_k WITH EMPTY KEY.

  " Full key for step-level read/update/delete
  TYPES: BEGIN OF ts_step_read_k,
    query_uuid TYPE sysuuid_x16,
    step_uuid  TYPE sysuuid_x16,
    control    TYPE ts_step_control,
  END OF ts_step_read_k.

  TYPES tt_step_read_k TYPE STANDARD TABLE OF ts_step_read_k WITH EMPTY KEY.

  TYPES: BEGIN OF ts_step_update_imp,
    INCLUDE TYPE zpru_axc_step,
    control TYPE ts_step_control,
  END OF ts_step_update_imp.

  TYPES tt_step_update_imp TYPE STANDARD TABLE OF ts_step_update_imp WITH EMPTY KEY.

  TYPES: BEGIN OF ts_step_delete_imp,
    query_uuid TYPE sysuuid_x16,
    step_uuid  TYPE sysuuid_x16,
  END OF ts_step_delete_imp.

  TYPES tt_step_delete_imp TYPE STANDARD TABLE OF ts_step_delete_imp WITH EMPTY KEY.

    TYPES: BEGIN OF ts_failed,
        header TYPE tt_header_failed,
        query  TYPE tt_query_failed,
        step   TYPE tt_step_failed,
      END OF ts_failed.

    TYPES: BEGIN OF ts_mapped,
        header TYPE tt_header_mapped,
        query  TYPE tt_query_mapped,
        step   TYPE tt_step_mapped,
      END OF ts_mapped.


  METHODS read_agent_execution
    IMPORTING it_axc_head_k TYPE zpru_if_axc_database_access=>tt_axc_head_k
    EXPORTING et_axc_head   TYPE zpru_if_axc_database_access=>tt_axc_head
              et_axc_query  TYPE zpru_if_axc_database_access=>tt_axc_query
              et_axc_step   TYPE zpru_if_axc_database_access=>tt_axc_step.

  METHODS get_actual_query
    IMPORTING it_axc_head_k                 TYPE zpru_if_axc_database_access=>tt_axc_head_k
    RETURNING VALUE(rt_axc_head_query_link) TYPE zpru_if_axc_database_access=>tt_axc_head_query_link.

  METHODS read_header
    IMPORTING it_head_read_k TYPE tt_head_read_k
    EXPORTING  et_axc_head    TYPE zpru_if_axc_database_access=>tt_axc_head.

  METHODS create_header
    IMPORTING it_head_create_imp TYPE tt_head_create_imp
    CHANGING  cs_reported        TYPE ts_reported
              cs_failed          TYPE ts_failed
              cs_mapped          TYPE ts_mapped.

  METHODS update_header
    IMPORTING it_head_update_imp TYPE tt_head_update_imp
    CHANGING  cs_reported        TYPE ts_reported
              cs_failed          TYPE ts_failed.
  METHODS delete_header.
  METHODS lock.
  METHODS rba_query
    IMPORTING it_rba_query_k TYPE tt_rba_query_k
    CHANGING  cs_reported    TYPE ts_reported
              cs_failed      TYPE ts_failed
    EXPORTING et_axc_query   TYPE zpru_if_axc_database_access=>tt_axc_query.
  
  METHODS read_query
    IMPORTING it_query_read_k TYPE tt_query_read_k
    CHANGING  cs_reported     TYPE ts_reported
              cs_failed       TYPE ts_failed
    EXPORTING et_axc_query    TYPE zpru_if_axc_database_access=>tt_axc_query.

  METHODS update_query
    IMPORTING it_query_update_imp TYPE tt_query_update_imp
    CHANGING  cs_reported         TYPE ts_reported
              cs_failed           TYPE ts_failed.

  METHODS delete_query
    IMPORTING it_query_delete_imp TYPE tt_query_delete_imp
    CHANGING  cs_reported         TYPE ts_reported
              cs_failed           TYPE ts_failed.
  METHODS cba_query
    IMPORTING it_axc_query_imp TYPE tt_query_create_imp
    CHANGING  cs_reported       TYPE ts_reported
              cs_failed         TYPE ts_failed
              cs_mapped         TYPE ts_mapped.

  " Step-level symmetry: query -> step operations
  METHODS rba_step
    IMPORTING it_rba_step_k TYPE tt_rba_step_k
    CHANGING  cs_reported   TYPE ts_reported
              cs_failed     TYPE ts_failed
    EXPORTING et_axc_step   TYPE zpru_if_axc_database_access=>tt_axc_step.

  METHODS read_step
    IMPORTING it_step_read_k TYPE tt_step_read_k
    CHANGING  cs_reported    TYPE ts_reported
              cs_failed      TYPE ts_failed
    EXPORTING et_axc_step     TYPE zpru_if_axc_database_access=>tt_axc_step.

  METHODS update_step
    IMPORTING it_step_update_imp TYPE tt_step_update_imp
    CHANGING  cs_reported        TYPE ts_reported
              cs_failed          TYPE ts_failed.

  METHODS delete_step
    IMPORTING it_step_delete_imp TYPE tt_step_delete_imp
    CHANGING  cs_reported        TYPE ts_reported
              cs_failed          TYPE ts_failed.

  METHODS cba_step
    IMPORTING it_axc_step_imp TYPE tt_step_create_imp
    CHANGING  cs_reported      TYPE ts_reported
              cs_failed        TYPE ts_failed
              cs_mapped        TYPE ts_mapped.

ENDINTERFACE.
