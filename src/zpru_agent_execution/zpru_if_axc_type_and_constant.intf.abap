INTERFACE zpru_if_axc_type_and_constant
  PUBLIC .

  TYPES: BEGIN OF ts_head_control,
           run_uuid           TYPE abap_boolean,
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
           run_uuid         TYPE abap_boolean,
           query_uuid       TYPE abap_boolean,
           language         TYPE abap_boolean,
           execution_status TYPE abap_boolean,
           start_timestamp  TYPE abap_boolean,
           end_timestamp    TYPE abap_boolean,
           input_prompt     TYPE abap_boolean,
           decision_log     TYPE abap_boolean,
           output_response  TYPE abap_boolean,
         END OF ts_query_control.

  TYPES: BEGIN OF ts_rba_query_k,
           run_uuid TYPE sysuuid_x16,
           control  TYPE ts_query_control,
         END OF ts_rba_query_k.

  TYPES tt_rba_query_k TYPE STANDARD TABLE OF ts_rba_query_k WITH EMPTY KEY.

  TYPES: BEGIN OF ts_query_create_imp.
           INCLUDE TYPE zpru_axc_query.
  TYPES:   control TYPE ts_query_control.
  TYPES: END OF ts_query_create_imp.

  TYPES tt_query_create_imp TYPE STANDARD TABLE OF ts_query_create_imp WITH EMPTY KEY.

  TYPES: BEGIN OF ts_query_read_k,
           run_uuid   TYPE sysuuid_x16,
           query_uuid TYPE sysuuid_x16,
           control    TYPE ts_query_control,
         END OF ts_query_read_k.

  TYPES tt_query_read_k TYPE STANDARD TABLE OF ts_query_read_k WITH EMPTY KEY.

  TYPES: BEGIN OF ts_query_update_imp.
           INCLUDE TYPE zpru_axc_query.
  TYPES:   control TYPE ts_query_control,
         END OF ts_query_update_imp.

  TYPES tt_query_update_imp TYPE STANDARD TABLE OF ts_query_update_imp WITH EMPTY KEY.

  TYPES: BEGIN OF ts_header_delete_imp,
           run_uuid TYPE sysuuid_x16,
         END OF ts_header_delete_imp.

  TYPES tt_header_delete_imp TYPE STANDARD TABLE OF ts_header_delete_imp WITH EMPTY KEY.

  TYPES: BEGIN OF ts_query_delete_imp,
           run_uuid   TYPE sysuuid_x16,
           query_uuid TYPE sysuuid_x16,
         END OF ts_query_delete_imp.

  TYPES tt_query_delete_imp TYPE STANDARD TABLE OF ts_query_delete_imp WITH EMPTY KEY.

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

  TYPES: BEGIN OF ts_step_create_imp.
           INCLUDE TYPE zpru_axc_step.
  TYPES:   control TYPE ts_step_control.
  TYPES: END OF ts_step_create_imp.

  TYPES tt_step_create_imp TYPE STANDARD TABLE OF ts_step_create_imp WITH EMPTY KEY.

  TYPES: BEGIN OF ts_rba_step_k,
           query_uuid TYPE sysuuid_x16,
           control    TYPE ts_step_control,
         END OF ts_rba_step_k.

  TYPES tt_rba_step_k TYPE STANDARD TABLE OF ts_rba_step_k WITH EMPTY KEY.

  TYPES: BEGIN OF ts_step_read_k,
           query_uuid TYPE sysuuid_x16,
           step_uuid  TYPE sysuuid_x16,
           control    TYPE ts_step_control,
         END OF ts_step_read_k.

  TYPES tt_step_read_k TYPE STANDARD TABLE OF ts_step_read_k WITH EMPTY KEY.

  TYPES: BEGIN OF ts_step_update_imp.
           INCLUDE TYPE zpru_axc_step.
  TYPES    control TYPE ts_step_control.
  TYPES  END OF ts_step_update_imp.

  TYPES tt_step_update_imp TYPE STANDARD TABLE OF ts_step_update_imp WITH EMPTY KEY.


  TYPES: BEGIN OF ts_step_delete_imp,
           query_uuid TYPE sysuuid_x16,
           step_uuid  TYPE sysuuid_x16,
         END OF ts_step_delete_imp.

  TYPES tt_step_delete_imp TYPE STANDARD TABLE OF ts_step_delete_imp WITH EMPTY KEY.

ENDINTERFACE.
