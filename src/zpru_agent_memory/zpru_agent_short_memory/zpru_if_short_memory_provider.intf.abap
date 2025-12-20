INTERFACE zpru_if_short_memory_provider
  PUBLIC.

  INTERFACES zpru_if_agent_frw.

  TYPES: BEGIN OF ENUM es_message_type,
           query       VALUE IS INITIAL,
           step_input  VALUE 1,
           step_output VALUE 2,
           repsonse    VALUE 3,
           info        VALUE 4,
         END OF ENUM es_message_type.

  TYPES: BEGIN OF ts_agent_message,
           agent_uuid       TYPE sysuuid_x16,
           run_uuid         TYPE sysuuid_x16,
           step_uuid        TYPE sysuuid_x16,
           history_sequence TYPE i,
           timestamp        TYPE timestampl,
           message_type     TYPE zpru_if_short_memory_provider=>es_message_type,
           message_json     TYPE zpru_if_agent_frw=>ts_json,
         END OF ts_agent_message.

  TYPES tt_agent_message TYPE STANDARD TABLE OF ts_agent_message WITH EMPTY KEY.

  METHODS save_message
    IMPORTING iv_agent_uuid   TYPE sysuuid_x16                                    OPTIONAL
              iv_run_uuid     TYPE sysuuid_x16                                    OPTIONAL
              iv_step_uuid    TYPE sysuuid_x16                                    OPTIONAL
              iv_message_type TYPE zpru_if_short_memory_provider=>es_message_type DEFAULT zpru_if_short_memory_provider=>info
              ir_message      TYPE REF TO data.

  METHODS get_history
    RETURNING VALUE(rt_history) TYPE zpru_if_short_memory_provider=>tt_agent_message.

  METHODS clear_history.

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

  METHODS set_discard_strategy
    IMPORTING
      io_discard_strategy TYPE REF TO zpru_if_discard_strategy.

  METHODS get_discard_strategy
    RETURNING VALUE(ro_discard_strategy) TYPE REF TO zpru_if_discard_strategy.

  METHODS set_long_memory
    IMPORTING
      io_long_memory TYPE REF TO zpru_if_long_memory_provider.

  METHODS get_long_memory
    RETURNING VALUE(ro_long_memory) TYPE REF TO zpru_if_long_memory_provider.

ENDINTERFACE.
