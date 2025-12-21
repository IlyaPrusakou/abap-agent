INTERFACE zpru_if_agent_util
  PUBLIC.

  METHODS copy_data_to_ref
    IMPORTING is_data TYPE any
    CHANGING  cr_data TYPE REF TO data.

  METHODS new_message
    IMPORTING iv_id         TYPE symsgid
              iv_number     TYPE symsgno
              iv_severity   TYPE zpru_if_agent_message=>t_char01
              iv_v1         TYPE simple OPTIONAL
              iv_v2         TYPE simple OPTIONAL
              iv_v3         TYPE simple OPTIONAL
              iv_v4         TYPE simple OPTIONAL
    RETURNING VALUE(ro_obj) TYPE REF TO zpru_if_agent_message.

  METHODS fill_flags
    IMPORTING iv_name    TYPE any
    CHANGING  cs_data    TYPE any
              cs_control TYPE any.

  METHODS serialize_json_2_xstring
    IMPORTING iv_json           TYPE string
    RETURNING VALUE(rv_xstring) TYPE xstring.

  METHODS deserialize_xstring_2_json
    IMPORTING iv_xstring     TYPE xstring
    RETURNING VALUE(rv_json) TYPE string.

  METHODS convert_to_abap
    IMPORTING
      ir_string TYPE REF TO data
    CHANGING
      cr_abap   TYPE REF TO data.
  METHODS convert_to_string
    IMPORTING
      ir_abap   TYPE REF TO data
    CHANGING
      cr_string TYPE zpru_if_agent_frw=>ts_json.

ENDINTERFACE.
