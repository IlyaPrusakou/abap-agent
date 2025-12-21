CLASS zpru_cl_summarize_simple DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zpru_if_summarization .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zpru_cl_summarize_simple IMPLEMENTATION.
  METHOD zpru_if_summarization~summarize.

    DATA lt_message TYPE zpru_if_long_mem_persistence=>tt_message.
    DATA lt_summarization TYPE zpru_if_long_mem_persistence=>tt_summarization.
    DATA lv_string TYPE zpru_if_agent_frw=>ts_json.

    IF io_input IS NOT BOUND.
      RETURN.
    ENDIF.

    lt_message = io_input->get_data( )->*.

    DATA(lo_utility) = NEW zpru_cl_agent_util( ).

    lo_utility->zpru_if_agent_util~convert_to_string(
      EXPORTING
        ir_abap   = REF #(  lt_message )
      CHANGING
        cr_string = lv_string ).

    SORT lt_message BY message_time DESCENDING.
    DATA(ls_last_message) = VALUE #( lt_message[ 1 ] OPTIONAL ).

    APPEND INITIAL LINE TO lt_summarization ASSIGNING FIELD-SYMBOL(<ls_sum>).
    <ls_sum> = CORRESPONDING #( ls_last_message EXCEPT content ).
    <ls_sum>-summary_cid = ls_last_message-message_cid.
    <ls_sum>-content = lv_string.

    IF lt_summarization IS NOT INITIAL.
      IF eo_output IS BOUND.
        eo_output->set_data( NEW zpru_if_long_mem_persistence=>tt_summarization( lt_summarization ) ).
      ELSE.
        eo_output = NEW zpru_cl_payload( ).
        eo_output->set_data( NEW zpru_if_long_mem_persistence=>tt_summarization( lt_summarization ) ).
      ENDIF.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
