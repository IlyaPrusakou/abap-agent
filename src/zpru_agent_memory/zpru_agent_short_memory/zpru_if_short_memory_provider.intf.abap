INTERFACE zpru_if_short_memory_provider
  PUBLIC.

  INTERFACES zpru_if_agent_frw.

  CONSTANTS:
    BEGIN OF cs_msg_type,
      query       TYPE zpru_de_message_type VALUE 'Q',
      step_input  TYPE zpru_de_message_type VALUE 'S',
      step_output TYPE zpru_de_message_type VALUE 'O',
      response    TYPE zpru_de_message_type VALUE 'R',
      info        TYPE zpru_de_message_type VALUE 'I',
    END OF cs_msg_type.

  TYPES ts_message TYPE zpru_s_mem_msg_ext.
  TYPES tt_message TYPE STANDARD TABLE OF ts_message WITH EMPTY KEY.


  TYPES: BEGIN OF ts_agent_message,
           agent_uuid       TYPE sysuuid_x16,
           run_uuid         TYPE sysuuid_x16,
           step_uuid        TYPE sysuuid_x16,
           history_sequence TYPE i,
           timestamp        TYPE timestampl,
           message_type     TYPE zpru_de_message_type,
           message_json     TYPE zpru_if_agent_frw=>ts_json,
         END OF ts_agent_message.

  TYPES tt_agent_message TYPE STANDARD TABLE OF ts_agent_message WITH EMPTY KEY.

  METHODS save_message
    IMPORTING it_message TYPE tt_message
    raISING zpru_cx_agent_core.

  METHODS get_history
    RETURNING VALUE(rt_history) TYPE zpru_if_short_memory_provider=>tt_agent_message.

  METHODS clear_history.

  METHODS set_discard_strategy
    IMPORTING io_discard_strategy TYPE REF TO zpru_if_discard_strategy.

  METHODS get_discard_strategy
    RETURNING VALUE(ro_discard_strategy) TYPE REF TO zpru_if_discard_strategy.

  METHODS set_long_memory
    IMPORTING io_long_memory TYPE REF TO zpru_if_long_memory_provider.

  METHODS get_long_memory
    RETURNING VALUE(ro_long_memory) TYPE REF TO zpru_if_long_memory_provider.

  METHODS set_mem_volume
    IMPORTING iv_mem_volume TYPE zpru_de_mem_volume.

  METHODS get_mem_volume
    RETURNING VALUE(rv_mem_volume) TYPE zpru_de_mem_volume.

ENDINTERFACE.
