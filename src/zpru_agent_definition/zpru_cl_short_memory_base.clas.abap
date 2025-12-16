CLASS zpru_cl_short_memory_base DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zpru_if_agent_frw.
    INTERFACES zpru_if_short_memory_provider.

  PROTECTED SECTION.
    DATA mt_agent_message TYPE zpru_if_short_memory_provider=>tt_agent_message.

  PRIVATE SECTION.
ENDCLASS.


CLASS zpru_cl_short_memory_base IMPLEMENTATION.
  METHOD zpru_if_short_memory_provider~clear_history.
    CLEAR mt_agent_message.
  ENDMETHOD.

  METHOD zpru_if_short_memory_provider~get_history.
    rt_history = mt_agent_message.
  ENDMETHOD.

  METHOD zpru_if_short_memory_provider~save_message.
    DATA ls_message TYPE zpru_if_short_memory_provider=>ts_agent_message.

    IF ir_message IS not BOUND.
      RETURN.
    ENDIF.

    me->zpru_if_short_memory_provider~convert_to_string(
      EXPORTING
        ir_abap   = ir_message
      CHANGING
        cr_string = ls_message-message_json ).

    ls_message-history_sequence = lines( mt_agent_message ) + 1.

    GET TIME STAMP FIELD DATA(lv_now).
    ls_message-timestamp = lv_now.

    IF ls_message-message_type IS INITIAL.
      ls_message-message_type = zpru_if_short_memory_provider=>info.
    ENDIF.

    APPEND INITIAL LINE TO mt_agent_message ASSIGNING FIELD-SYMBOL(<ls_target>).
    <ls_target> = ls_message.
  ENDMETHOD.

  METHOD zpru_if_short_memory_provider~convert_to_abap.
    /ui2/cl_json=>deserialize(
      EXPORTING
        json = ir_string->*
      CHANGING
        data = cr_abap->* ).
  ENDMETHOD.

  METHOD zpru_if_short_memory_provider~convert_to_string.
    cr_string = /ui2/cl_json=>serialize( ir_abap->* ).
  ENDMETHOD.

ENDCLASS.
