INTERFACE zpru_if_axc_database_access
  PUBLIC .

  TYPES: BEGIN OF ts_axc_head_k,
           run_uuid TYPE  sysuuid_x16,
         END OF ts_axc_head_k.

  TYPES: BEGIN OF ts_axc_query_k,
           query_uuid TYPE  sysuuid_x16,
         END OF ts_axc_query_k.

  TYPES: BEGIN OF ts_axc_step_k,
           STEP_uuid TYPE  sysuuid_x16,
         END OF ts_axc_step_k.

  TYPES: tt_axc_head_k TYPE STANDARD TABLE OF ts_axc_head_k WITH EMPTY KEY.
  TYPES: tt_axc_query_k TYPE STANDARD TABLE OF ts_axc_query_k WITH EMPTY KEY.
  TYPES: tt_axc_step_k TYPE STANDARD TABLE OF ts_axc_step_k WITH EMPTY KEY.

  TYPES tt_axc_head TYPE STANDARD TABLE OF zpru_axc_head WITH EMPTY KEY.
  TYPES tt_axc_query TYPE STANDARD TABLE OF zpru_axc_query WITH EMPTY KEY.
  TYPES tt_axc_step TYPE STANDARD TABLE OF zpru_axc_step WITH EMPTY KEY.

  METHODS modify_head
    IMPORTING
      it_axc_head TYPE tt_axc_head
    EXPORTING
      ev_error    TYPE abap_boolean.

  METHODS delete_head
    IMPORTING
      it_axc_head TYPE tt_axc_head
    EXPORTING
      ev_error      TYPE abap_boolean.

  METHODS select_head
    IMPORTING
      it_axc_head_k      TYPE tt_axc_head_k
    RETURNING
      VALUE(rt_axc_head) TYPE tt_axc_head.

  METHODS modify_query
    IMPORTING
      it_axc_query TYPE tt_axc_query
    EXPORTING
      ev_error     TYPE abap_boolean.

  METHODS delete_query
    IMPORTING
      it_axc_query TYPE tt_axc_query
    EXPORTING
      ev_error       TYPE abap_boolean.

  METHODS select_query
    IMPORTING
      it_axc_query_k      TYPE tt_axc_query_k
    RETURNING
      VALUE(rt_axc_query) TYPE tt_axc_query.

  METHODS modify_step
    IMPORTING
      it_axc_step TYPE tt_axc_step
    EXPORTING
      ev_error    TYPE abap_boolean.

  METHODS delete_step
    IMPORTING
      it_axc_step TYPE tt_axc_step
    EXPORTING
      ev_error      TYPE abap_boolean.

  METHODS select_step
    IMPORTING
      it_axc_step_k      TYPE tt_axc_step_k
    RETURNING
      VALUE(rt_axc_step) TYPE tt_axc_step.

ENDINTERFACE.
