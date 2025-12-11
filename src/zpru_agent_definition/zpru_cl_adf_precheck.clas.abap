CLASS zpru_cl_adf_precheck DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zpru_if_adf_precheck .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zpru_cl_adf_precheck IMPLEMENTATION.

  METHOD zpru_if_adf_precheck~precheck_create_agent.
    CLEAR et_entities.

    LOOP AT it_agent_create_imp ASSIGNING FIELD-SYMBOL(<ls_create>).
      IF <ls_create>-agent_uuid IS INITIAL.
        TRY.
            <ls_create>-agent_uuid = cl_system_uuid=>create_uuid_x16_static( ).
          CATCH cx_uuid_error.
            RAISE SHORTDUMP NEW zpru_cx_agent_core( ).
        ENDTRY.
      ENDIF.

      NEW zpru_cl_agent_util( )->zpru_if_agent_util~fill_flags(
        EXPORTING
          iv_name    = `ZPRU_IF_ADF_TYPE_AND_CONSTANT=>TS_AGENT_CONTROL`
        CHANGING
          cs_data    = <ls_create>
          cs_control = <ls_create>-control ).

      APPEND INITIAL LINE TO et_entities ASSIGNING FIELD-SYMBOL(<ls_entity>).
      <ls_entity> = <ls_create>.
    ENDLOOP.
  ENDMETHOD.

  METHOD zpru_if_adf_precheck~precheck_update_agent.
    CLEAR et_entities.

    LOOP AT it_agent_update_imp ASSIGNING FIELD-SYMBOL(<ls_update>).
      NEW zpru_cl_agent_util( )->zpru_if_agent_util~fill_flags(
        EXPORTING
          iv_name    = `ZPRU_IF_ADF_TYPE_AND_CONSTANT=>TS_AGENT_CONTROL`
        CHANGING
          cs_data    = <ls_update>
          cs_control = <ls_update>-control ).

      APPEND INITIAL LINE TO et_entities ASSIGNING FIELD-SYMBOL(<ls_entity>).
      <ls_entity> = <ls_update>.
    ENDLOOP.
  ENDMETHOD.

  METHOD zpru_if_adf_precheck~precheck_delete_agent.
    CLEAR et_entities.

    LOOP AT it_agent_delete_imp ASSIGNING FIELD-SYMBOL(<ls_delete>).
      APPEND INITIAL LINE TO et_entities ASSIGNING FIELD-SYMBOL(<ls_entity>).
      <ls_entity> = <ls_delete>.
    ENDLOOP.
  ENDMETHOD.

  METHOD zpru_if_adf_precheck~precheck_read_agent.
    CLEAR et_entities.

    LOOP AT it_agent_read_k ASSIGNING FIELD-SYMBOL(<ls_read>).
      NEW zpru_cl_agent_util( )->zpru_if_agent_util~fill_flags(
        EXPORTING
          iv_name    = `ZPRU_IF_ADF_TYPE_AND_CONSTANT=>TS_AGENT_CONTROL`
        CHANGING
          cs_data    = <ls_read>
          cs_control = <ls_read>-control ).

      APPEND INITIAL LINE TO et_entities ASSIGNING FIELD-SYMBOL(<ls_entity>).
      <ls_entity> = <ls_read>.
    ENDLOOP.
  ENDMETHOD.

  METHOD zpru_if_adf_precheck~precheck_cba_tool.
    CLEAR et_entities.

    LOOP AT it_tool_create_imp ASSIGNING FIELD-SYMBOL(<ls_create>).
      IF <ls_create>-tool_uuid IS INITIAL.
        TRY.
            <ls_create>-tool_uuid = cl_system_uuid=>create_uuid_x16_static( ).
          CATCH cx_uuid_error.
            RAISE SHORTDUMP NEW zpru_cx_agent_core( ).
        ENDTRY.
      ENDIF.

      NEW zpru_cl_agent_util( )->zpru_if_agent_util~fill_flags(
        EXPORTING
          iv_name    = `ZPRU_IF_ADF_TYPE_AND_CONSTANT=>TS_TOOL_CONTROL`
        CHANGING
          cs_data    = <ls_create>
          cs_control = <ls_create>-control ).

      IF <ls_create>-agent_uuid IS INITIAL.
        APPEND VALUE #( agent_uuid = <ls_create>-agent_uuid
                        tool_uuid  = <ls_create>-tool_uuid
                        create     = abap_true
                        fail       = zpru_if_agent_frw=>cs_fail_cause-dependency )
               TO cs_failed-tool.

        APPEND VALUE #( agent_uuid = <ls_create>-agent_uuid
                        tool_uuid  = <ls_create>-tool_uuid
                        create     = abap_true
                        msg        = NEW zpru_cl_agent_util( )->zpru_if_agent_util~new_message(
                                           iv_id       = zpru_if_agent_frw=>cs_message_class-zpru_msg_execution
                                           iv_number   = `011` " Assumed message for missing parent key
                                           iv_severity = zpru_if_agent_message=>sc_severity-error ) )
               TO cs_reported-tool.
        CONTINUE.
      ENDIF.

      APPEND INITIAL LINE TO et_entities ASSIGNING FIELD-SYMBOL(<ls_entity>).
      <ls_entity> = <ls_create>.
    ENDLOOP.
  ENDMETHOD.

  METHOD zpru_if_adf_precheck~precheck_update_tool.
    CLEAR et_entities.

    LOOP AT it_tool_update_imp ASSIGNING FIELD-SYMBOL(<ls_update>).
      NEW zpru_cl_agent_util( )->zpru_if_agent_util~fill_flags(
        EXPORTING
          iv_name    = `ZPRU_IF_ADF_TYPE_AND_CONSTANT=>TS_TOOL_CONTROL`
        CHANGING
          cs_data    = <ls_update>
          cs_control = <ls_update>-control ).

      APPEND INITIAL LINE TO et_entities ASSIGNING FIELD-SYMBOL(<ls_entity>).
      <ls_entity> = <ls_update>.
    ENDLOOP.
  ENDMETHOD.

  METHOD zpru_if_adf_precheck~precheck_delete_tool.
    CLEAR et_entities.

    LOOP AT it_tool_delete_imp ASSIGNING FIELD-SYMBOL(<ls_delete>).
      APPEND INITIAL LINE TO et_entities ASSIGNING FIELD-SYMBOL(<ls_entity>).
      <ls_entity> = <ls_delete>.
    ENDLOOP.
  ENDMETHOD.

  METHOD zpru_if_adf_precheck~precheck_read_tool.
    CLEAR et_entities.

    LOOP AT it_tool_read_k ASSIGNING FIELD-SYMBOL(<ls_read>).
      NEW zpru_cl_agent_util( )->zpru_if_agent_util~fill_flags(
        EXPORTING
          iv_name    = `ZPRU_IF_ADF_TYPE_AND_CONSTANT=>TS_TOOL_CONTROL`
        CHANGING
          cs_data    = <ls_read>
          cs_control = <ls_read>-control ).

      APPEND INITIAL LINE TO et_entities ASSIGNING FIELD-SYMBOL(<ls_entity>).
      <ls_entity> = <ls_read>.
    ENDLOOP.
  ENDMETHOD.

  METHOD zpru_if_adf_precheck~precheck_rba_tool.
    CLEAR et_entities.

    LOOP AT it_rba_tool_k ASSIGNING FIELD-SYMBOL(<ls_rba>).
      NEW zpru_cl_agent_util( )->zpru_if_agent_util~fill_flags(
        EXPORTING
          iv_name    = `ZPRU_IF_ADF_TYPE_AND_CONSTANT=>TS_TOOL_CONTROL`
        CHANGING
          cs_data    = <ls_rba>
          cs_control = <ls_rba>-control ).

      APPEND INITIAL LINE TO et_entities ASSIGNING FIELD-SYMBOL(<ls_entity>).
      <ls_entity> = <ls_rba>.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
