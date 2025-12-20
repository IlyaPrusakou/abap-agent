CLASS zpru_cl_short_memory_base DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zpru_if_agent_frw.
    INTERFACES zpru_if_short_memory_provider.

  PROTECTED SECTION.
    DATA mt_agent_message TYPE zpru_if_short_memory_provider=>tt_agent_message.
    DATA mo_discard_strategy TYPE REF TO zpru_if_discard_strategy.
    DATA mo_long_memory_provider TYPE REF TO zpru_if_long_memory_provider.

    METHODS discard_messages
      IMPORTING
        io_input  TYPE REF TO zpru_if_request
      EXPORTING
        eo_output TYPE REF TO zpru_if_response.

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
    DATA lt_message_2_discard LIKE mt_agent_message.
    DATA lo_discard_input TYPE REF TO zpru_if_request.
    DATA lo_discard_output TYPE REF TO zpru_if_response.
    DATA lv_short_memory_size TYPE i VALUE 20.

    IF ir_message IS NOT BOUND.
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

    SORT mt_agent_message BY history_sequence DESCENDING.

    IF lines( mt_agent_message ) > lv_short_memory_size.
      LOOP AT mt_agent_message FROM lv_short_memory_size + 1 ASSIGNING FIELD-SYMBOL(<ls_message_to_discard>).
        APPEND INITIAL LINE TO lt_message_2_discard ASSIGNING FIELD-SYMBOL(<ls_discard>).
        <ls_discard> = <ls_message_to_discard>.
      ENDLOOP.

      IF lt_message_2_discard IS NOT INITIAL.
        lo_discard_input = NEW zpru_cl_request( ).
        lo_discard_input->set_data( ir_data = REF #( lt_message_2_discard ) ).
        lo_discard_output = NEW zpru_cl_response( ).

        discard_messages(
          EXPORTING
            io_input  = lo_discard_input
          IMPORTING
            eo_output = lo_discard_output ).
      ENDIF.
    ENDIF.
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

  METHOD discard_messages.
    IF io_input IS NOT BOUND.
      RETURN.
    ENDIF.

    zpru_if_short_memory_provider~get_discard_strategy( )->discard(
    EXPORTING io_long_memory = zpru_if_short_memory_provider~get_long_memory( )
              io_input       = io_input
    IMPORTING eo_output = eo_output ).

  ENDMETHOD.

  METHOD zpru_if_short_memory_provider~get_discard_strategy.

    IF mo_discard_strategy IS NOT BOUND.
      mo_discard_strategy = NEW zpru_cl_discard_delete( ).
    ENDIF.

    ro_discard_strategy = mo_discard_strategy.
  ENDMETHOD.

  METHOD zpru_if_short_memory_provider~set_discard_strategy.
    mo_discard_strategy = io_discard_strategy.
  ENDMETHOD.

  METHOD zpru_if_short_memory_provider~get_long_memory.
    IF mo_long_memory_provider IS NOT BOUND.
      mo_long_memory_provider = NEW zpru_cl_long_memory_base( ).
    ENDIF.
    ro_long_memory = mo_long_memory_provider.
  ENDMETHOD.

  METHOD zpru_if_short_memory_provider~set_long_memory.
    mo_long_memory_provider = io_long_memory.
  ENDMETHOD.

ENDCLASS.
