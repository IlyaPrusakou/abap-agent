INTERFACE zpru_if_short_memory_provider
  PUBLIC .

  INTERFACES zpru_if_agent_frw.

  TYPES: BEGIN OF ENUM es_message_type,
           query       VALUE IS INITIAL,
           step_input  VALUE 1,
           step_output VALUE 2,
           repsonse    VALUE 3,
         END OF ENUM es_message_type.

  TYPES: BEGIN OF ts_history,
           run_uuid         TYPE xstring,
           step_uuid        TYPE xstring,
           history_sequence TYPE i,
           history          TYPE zpru_if_agent_frw=>ts_json,
         END OF ts_history.

  TYPES: tt_history TYPE STANDARD TABLE OF ts_history WITH EMPTY KEY.

  " user query, agent response, or thought step
  METHODS save_message
    IMPORTING iv_message_type TYPE zpru_if_short_memory_provider=>es_message_type DEFAULT zpru_if_short_memory_provider=>step_input
              is_message      TYPE zpru_if_agent_frw=>ts_json.
  METHODS get_history
    RETURNING VALUE(rt_history) TYPE zpru_if_short_memory_provider=>tt_history.
  METHODS clear_history.


ENDINTERFACE.
