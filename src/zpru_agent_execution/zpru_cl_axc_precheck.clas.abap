CLASS zpru_cl_axc_precheck DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zpru_if_axc_precheck .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zpru_cl_axc_precheck IMPLEMENTATION.

  METHOD zpru_if_axc_precheck~precheck_create_header.
    CLEAR et_entities.

    LOOP AT it_head_create_imp ASSIGNING FIELD-SYMBOL(<ls_create>).
      IF <ls_create>-run_uuid IS INITIAL.
        TRY.
            <ls_create>-run_uuid = cl_system_uuid=>create_uuid_x16_static( ).
          CATCH cx_uuid_error.
            RAISE SHORTDUMP NEW zpru_cx_agent_core( ).
        ENDTRY.
      ENDIF.

      NEW zpru_cl_agent_util( )->zpru_if_agent_util~fill_flags(
        EXPORTING
          iv_name    = `ZPRU_IF_AXC_TYPE_AND_CONSTANT=>TS_HEAD_CONTROL`
        CHANGING
          cs_data    = <ls_create>
          cs_control = <ls_create>-control ).

      IF <ls_create>-agent_uuid IS INITIAL.
        APPEND VALUE #( run_uuid = <ls_create>-run_uuid
                        create   = abap_true
                        fail     = zpru_if_agent_frw=>cs_fail_cause-dependency )
               TO cs_failed-header.

        APPEND VALUE #( run_uuid = <ls_create>-run_uuid
                        create   = abap_true
                        msg      = NEW zpru_cl_agent_util( )->zpru_if_agent_util~new_message(
                                           iv_id       = zpru_if_agent_frw=>cs_message_class-zpru_msg_execution
                                           iv_number   = `004`
                                           iv_severity = zpru_if_agent_message=>sc_severity-error ) )
               TO cs_reported-header.

        CONTINUE.
      ENDIF.

      APPEND INITIAL LINE TO et_entities ASSIGNING FIELD-SYMBOL(<ls_entity>).
      <ls_entity> = <ls_create>.
    ENDLOOP.
  ENDMETHOD.

  METHOD zpru_if_axc_precheck~precheck_update_header.
    CLEAR et_entities.

    LOOP AT it_head_update_imp ASSIGNING FIELD-SYMBOL(<ls_update>).
      NEW zpru_cl_agent_util( )->zpru_if_agent_util~fill_flags(
        EXPORTING
          iv_name    = `ZPRU_IF_AXC_TYPE_AND_CONSTANT=>TS_HEAD_CONTROL`
        CHANGING
          cs_data    = <ls_update>
          cs_control = <ls_update>-control ).

      APPEND INITIAL LINE TO et_entities ASSIGNING FIELD-SYMBOL(<ls_entity>).
      <ls_entity> = <ls_update>.
    ENDLOOP.
  ENDMETHOD.

  METHOD zpru_if_axc_precheck~precheck_delete_header.
    CLEAR et_entities.

    LOOP AT it_head_delete_imp ASSIGNING FIELD-SYMBOL(<ls_delete>).
      APPEND INITIAL LINE TO et_entities ASSIGNING FIELD-SYMBOL(<ls_entity>).
      <ls_entity> = <ls_delete>.
    ENDLOOP.
  ENDMETHOD.

  METHOD zpru_if_axc_precheck~precheck_cba_query.
    CLEAR et_entities.

    LOOP AT it_axc_query_imp ASSIGNING FIELD-SYMBOL(<ls_create>).
      IF <ls_create>-query_uuid IS INITIAL.
        TRY.
            <ls_create>-query_uuid = cl_system_uuid=>create_uuid_x16_static( ).
          CATCH cx_uuid_error.
            RAISE SHORTDUMP NEW zpru_cx_agent_core( ).
        ENDTRY.
      ENDIF.

      NEW zpru_cl_agent_util( )->zpru_if_agent_util~fill_flags(
        EXPORTING
          iv_name    = `ZPRU_IF_AXC_TYPE_AND_CONSTANT=>TS_QUERY_CONTROL`
        CHANGING
          cs_data    = <ls_create>
          cs_control = <ls_create>-control ).

      IF <ls_create>-run_uuid IS INITIAL.
        APPEND VALUE #( query_uuid = <ls_create>-query_uuid
                        create     = abap_true
                        fail       = zpru_if_agent_frw=>cs_fail_cause-dependency )
               TO cs_failed-query.

        APPEND VALUE #( query_uuid = <ls_create>-query_uuid
                        create     = abap_true
                        msg        = NEW zpru_cl_agent_util( )->zpru_if_agent_util~new_message(
                                           iv_id       = zpru_if_agent_frw=>cs_message_class-zpru_msg_execution
                                           iv_number   = `006`
                                           iv_severity = zpru_if_agent_message=>sc_severity-error ) )
               TO cs_reported-query.
        CONTINUE.
      ENDIF.

      APPEND INITIAL LINE TO et_entities ASSIGNING FIELD-SYMBOL(<ls_entity>).
      <ls_entity> = <ls_create>.
    ENDLOOP.
  ENDMETHOD.

  METHOD zpru_if_axc_precheck~precheck_read_header.
    CLEAR et_entities.

    LOOP AT it_head_read_k ASSIGNING FIELD-SYMBOL(<ls_read>).
      NEW zpru_cl_agent_util( )->zpru_if_agent_util~fill_flags(
        EXPORTING
          iv_name    = `ZPRU_IF_AXC_TYPE_AND_CONSTANT=>TS_HEAD_CONTROL`
        CHANGING
          cs_data    = <ls_read>
          cs_control = <ls_read>-control ).

      APPEND INITIAL LINE TO et_entities ASSIGNING FIELD-SYMBOL(<ls_entity>).
      <ls_entity> = <ls_read>.
    ENDLOOP.
  ENDMETHOD.

  METHOD zpru_if_axc_precheck~precheck_rba_query.
    CLEAR et_entities.

    LOOP AT it_rba_query_k ASSIGNING FIELD-SYMBOL(<ls_rba>).
      NEW zpru_cl_agent_util( )->zpru_if_agent_util~fill_flags(
        EXPORTING
          iv_name    = `ZPRU_IF_AXC_TYPE_AND_CONSTANT=>TS_QUERY_CONTROL`
        CHANGING
          cs_data    = <ls_rba>
          cs_control = <ls_rba>-control ).

      APPEND INITIAL LINE TO et_entities ASSIGNING FIELD-SYMBOL(<ls_entity>).
      <ls_entity> = <ls_rba>.
    ENDLOOP.
  ENDMETHOD.

  METHOD zpru_if_axc_precheck~precheck_cba_step.
    CLEAR et_entities.

    LOOP AT it_axc_step_imp ASSIGNING FIELD-SYMBOL(<ls_create>).
      IF <ls_create>-step_uuid IS INITIAL.
        TRY.
            <ls_create>-step_uuid = cl_system_uuid=>create_uuid_x16_static( ).
          CATCH cx_uuid_error.
            RAISE SHORTDUMP NEW zpru_cx_agent_core( ).
        ENDTRY.
      ENDIF.

      NEW zpru_cl_agent_util( )->zpru_if_agent_util~fill_flags(
        EXPORTING
          iv_name    = `ZPRU_IF_AXC_TYPE_AND_CONSTANT=>TS_STEP_CONTROL`
        CHANGING
          cs_data    = <ls_create>
          cs_control = <ls_create>-control ).

      IF <ls_create>-query_uuid IS INITIAL.
        APPEND VALUE #( step_uuid  = <ls_create>-step_uuid
                        create     = abap_true
                        fail       = zpru_if_agent_frw=>cs_fail_cause-dependency )
               TO cs_failed-step.

        APPEND VALUE #( step_uuid  = <ls_create>-step_uuid
                        create     = abap_true
                        msg        = NEW zpru_cl_agent_util( )->zpru_if_agent_util~new_message(
                                           iv_id       = zpru_if_agent_frw=>cs_message_class-zpru_msg_execution
                                           iv_number   = `010`
                                           iv_severity = zpru_if_agent_message=>sc_severity-error ) )
               TO cs_reported-step.
        CONTINUE.
      ENDIF.

      APPEND INITIAL LINE TO et_entities ASSIGNING FIELD-SYMBOL(<ls_entity>).
      <ls_entity> = <ls_create>.
    ENDLOOP.
  ENDMETHOD.

  METHOD zpru_if_axc_precheck~precheck_rba_step.
    CLEAR et_entities.

    LOOP AT it_rba_step_k ASSIGNING FIELD-SYMBOL(<ls_rba>).
      NEW zpru_cl_agent_util( )->zpru_if_agent_util~fill_flags(
        EXPORTING
          iv_name    = `ZPRU_IF_AXC_TYPE_AND_CONSTANT=>TS_STEP_CONTROL`
        CHANGING
          cs_data    = <ls_rba>
          cs_control = <ls_rba>-control ).

      APPEND INITIAL LINE TO et_entities ASSIGNING FIELD-SYMBOL(<ls_entity>).
      <ls_entity> = <ls_rba>.
    ENDLOOP.
  ENDMETHOD.

  METHOD zpru_if_axc_precheck~precheck_read_step.
    CLEAR et_entities.

    LOOP AT it_step_read_k ASSIGNING FIELD-SYMBOL(<ls_read>).
      NEW zpru_cl_agent_util( )->zpru_if_agent_util~fill_flags(
        EXPORTING
          iv_name    = `ZPRU_IF_AXC_TYPE_AND_CONSTANT=>TS_STEP_CONTROL`
        CHANGING
          cs_data    = <ls_read>
          cs_control = <ls_read>-control ).

      APPEND INITIAL LINE TO et_entities ASSIGNING FIELD-SYMBOL(<ls_entity>).
      <ls_entity> = <ls_read>.
    ENDLOOP.
  ENDMETHOD.

  METHOD zpru_if_axc_precheck~precheck_update_step.
    CLEAR et_entities.

    LOOP AT it_step_update_imp ASSIGNING FIELD-SYMBOL(<ls_update>).
      NEW zpru_cl_agent_util( )->zpru_if_agent_util~fill_flags(
        EXPORTING
          iv_name    = `ZPRU_IF_AXC_TYPE_AND_CONSTANT=>TS_STEP_CONTROL`
        CHANGING
          cs_data    = <ls_update>
          cs_control = <ls_update>-control ).

      APPEND INITIAL LINE TO et_entities ASSIGNING FIELD-SYMBOL(<ls_entity>).
      <ls_entity> = <ls_update>.
    ENDLOOP.
  ENDMETHOD.

  METHOD zpru_if_axc_precheck~precheck_delete_step.
    CLEAR et_entities.

    LOOP AT it_step_delete_imp ASSIGNING FIELD-SYMBOL(<ls_delete>).
      APPEND INITIAL LINE TO et_entities ASSIGNING FIELD-SYMBOL(<ls_entity>).
      <ls_entity> = <ls_delete>.
    ENDLOOP.
  ENDMETHOD.

  METHOD zpru_if_axc_precheck~precheck_read_query.
    CLEAR et_entities.

    LOOP AT it_query_read_k ASSIGNING FIELD-SYMBOL(<ls_read>).
      NEW zpru_cl_agent_util( )->zpru_if_agent_util~fill_flags(
        EXPORTING
          iv_name    = `ZPRU_IF_AXC_TYPE_AND_CONSTANT=>TS_QUERY_CONTROL`
        CHANGING
          cs_data    = <ls_read>
          cs_control = <ls_read>-control ).

      APPEND INITIAL LINE TO et_entities ASSIGNING FIELD-SYMBOL(<ls_entity>).
      <ls_entity> = <ls_read>.
    ENDLOOP.
  ENDMETHOD.

  METHOD zpru_if_axc_precheck~precheck_update_query.
    CLEAR et_entities.

    LOOP AT it_query_update_imp ASSIGNING FIELD-SYMBOL(<ls_update>).
      NEW zpru_cl_agent_util( )->zpru_if_agent_util~fill_flags(
        EXPORTING
          iv_name    = `ZPRU_IF_AXC_TYPE_AND_CONSTANT=>TS_QUERY_CONTROL`
        CHANGING
          cs_data    = <ls_update>
          cs_control = <ls_update>-control ).

      APPEND INITIAL LINE TO et_entities ASSIGNING FIELD-SYMBOL(<ls_entity>).
      <ls_entity> = <ls_update>.
    ENDLOOP.
  ENDMETHOD.

  METHOD zpru_if_axc_precheck~precheck_delete_query.
    CLEAR et_entities.

    LOOP AT it_query_delete_imp ASSIGNING FIELD-SYMBOL(<ls_delete>).
      APPEND INITIAL LINE TO et_entities ASSIGNING FIELD-SYMBOL(<ls_entity>).
      <ls_entity> = <ls_delete>.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
