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

    DATA ls_line TYPE zpru_if_axc_type_and_constant=>ts_head_create_imp.

    CLEAR et_entities.

    LOOP AT it_head_create_imp ASSIGNING FIELD-SYMBOL(<ls_create>).

      ls_line = <ls_create>.

      IF ls_line-run_uuid IS INITIAL.
        TRY.
            ls_line-run_uuid = cl_system_uuid=>create_uuid_x16_static( ).
          CATCH cx_uuid_error.
            RAISE SHORTDUMP NEW zpru_cx_agent_core( ).
        ENDTRY.
      ENDIF.

      NEW zpru_cl_agent_util( )->zpru_if_agent_util~fill_flags(
        EXPORTING
          iv_name    = `ZPRU_IF_AXC_TYPE_AND_CONSTANT=>TS_HEAD_CONTROL`
        CHANGING
          cs_data    = ls_line
          cs_control = ls_line-control ).

      IF ls_line-agent_uuid IS INITIAL.
        APPEND VALUE #( run_uuid = ls_line-run_uuid
                        create   = abap_true
                        fail     = zpru_if_agent_frw=>cs_fail_cause-dependency )
               TO cs_failed-header.

        APPEND VALUE #( run_uuid = ls_line-run_uuid
                        create   = abap_true
                        msg      = NEW zpru_cl_agent_util( )->zpru_if_agent_util~new_message(
                                           iv_id       = zpru_if_agent_frw=>cs_message_class-zpru_msg_execution
                                           iv_number   = `004`
                                           iv_severity = zpru_if_agent_message=>sc_severity-error ) )
               TO cs_reported-header.

        CONTINUE.
      ENDIF.

      APPEND INITIAL LINE TO et_entities ASSIGNING FIELD-SYMBOL(<ls_entity>).
      <ls_entity> = ls_line.
    ENDLOOP.
  ENDMETHOD.

  METHOD zpru_if_axc_precheck~precheck_update_header.

    DATA ls_line TYPE zpru_if_axc_type_and_constant=>ts_head_update_imp.

    CLEAR et_entities.

    LOOP AT it_head_update_imp ASSIGNING FIELD-SYMBOL(<ls_update>).

      ls_line = <ls_update>.

      NEW zpru_cl_agent_util( )->zpru_if_agent_util~fill_flags(
        EXPORTING
          iv_name    = `ZPRU_IF_AXC_TYPE_AND_CONSTANT=>TS_HEAD_CONTROL`
        CHANGING
          cs_data    = ls_line
          cs_control = ls_line-control ).

      APPEND INITIAL LINE TO et_entities ASSIGNING FIELD-SYMBOL(<ls_entity>).
      <ls_entity> = ls_line.
    ENDLOOP.
  ENDMETHOD.

  METHOD zpru_if_axc_precheck~precheck_delete_header.

    DATA ls_line TYPE zpru_if_axc_type_and_constant=>ts_header_delete_imp.


    CLEAR et_entities.

    LOOP AT it_head_delete_imp ASSIGNING FIELD-SYMBOL(<ls_delete>).
      ls_line = <ls_delete>.
      APPEND INITIAL LINE TO et_entities ASSIGNING FIELD-SYMBOL(<ls_entity>).
      <ls_entity> = ls_line.
    ENDLOOP.
  ENDMETHOD.

  METHOD zpru_if_axc_precheck~precheck_cba_query.
    DATA ls_line TYPE zpru_if_axc_type_and_constant=>ts_query_create_imp.
    CLEAR et_entities.

    LOOP AT it_axc_query_imp ASSIGNING FIELD-SYMBOL(<ls_create>).
      ls_line = <ls_create>.
      IF ls_line-query_uuid IS INITIAL.
        TRY.
            ls_line-query_uuid = cl_system_uuid=>create_uuid_x16_static( ).
          CATCH cx_uuid_error.
            RAISE SHORTDUMP NEW zpru_cx_agent_core( ).
        ENDTRY.
      ENDIF.

      NEW zpru_cl_agent_util( )->zpru_if_agent_util~fill_flags(
        EXPORTING
          iv_name    = `ZPRU_IF_AXC_TYPE_AND_CONSTANT=>TS_QUERY_CONTROL`
        CHANGING
          cs_data    = ls_line
          cs_control = ls_line-control ).

      IF ls_line-run_uuid IS INITIAL.
        APPEND VALUE #( query_uuid = ls_line-query_uuid
                        create     = abap_true
                        fail       = zpru_if_agent_frw=>cs_fail_cause-dependency )
               TO cs_failed-query.

        APPEND VALUE #( query_uuid = ls_line-query_uuid
                        create     = abap_true
                        msg        = NEW zpru_cl_agent_util( )->zpru_if_agent_util~new_message(
                                           iv_id       = zpru_if_agent_frw=>cs_message_class-zpru_msg_execution
                                           iv_number   = `006`
                                           iv_severity = zpru_if_agent_message=>sc_severity-error ) )
               TO cs_reported-query.
        CONTINUE.
      ENDIF.

      APPEND INITIAL LINE TO et_entities ASSIGNING FIELD-SYMBOL(<ls_entity>).
      <ls_entity> = ls_line.
    ENDLOOP.
  ENDMETHOD.

  METHOD zpru_if_axc_precheck~precheck_read_header.
    DATA ls_line TYPE zpru_if_axc_type_and_constant=>ts_head_read_k.
    CLEAR et_entities.

    LOOP AT it_head_read_k ASSIGNING FIELD-SYMBOL(<ls_read>).
      ls_line = <ls_read>.
      NEW zpru_cl_agent_util( )->zpru_if_agent_util~fill_flags(
        EXPORTING
          iv_name    = `ZPRU_IF_AXC_TYPE_AND_CONSTANT=>TS_HEAD_CONTROL`
        CHANGING
          cs_data    = ls_line
          cs_control = ls_line-control ).

      APPEND INITIAL LINE TO et_entities ASSIGNING FIELD-SYMBOL(<ls_entity>).
      <ls_entity> = ls_line.

    ENDLOOP.
  ENDMETHOD.

  METHOD zpru_if_axc_precheck~precheck_rba_query.
    DATA ls_line TYPE zpru_if_axc_type_and_constant=>ts_rba_query_k.
    CLEAR et_entities.

    LOOP AT it_rba_query_k ASSIGNING FIELD-SYMBOL(<ls_rba>).
      ls_line = <ls_rba>.
      NEW zpru_cl_agent_util( )->zpru_if_agent_util~fill_flags(
        EXPORTING
          iv_name    = `ZPRU_IF_AXC_TYPE_AND_CONSTANT=>TS_QUERY_CONTROL`
        CHANGING
          cs_data    = ls_line
          cs_control = ls_line-control ).

      APPEND INITIAL LINE TO et_entities ASSIGNING FIELD-SYMBOL(<ls_entity>).
      <ls_entity> = ls_line.
    ENDLOOP.
  ENDMETHOD.

  METHOD zpru_if_axc_precheck~precheck_cba_step.
    DATA ls_line TYPE zpru_if_axc_type_and_constant=>ts_step_create_imp.
    CLEAR et_entities.

    LOOP AT it_axc_step_imp ASSIGNING FIELD-SYMBOL(<ls_create>).
      ls_line = <ls_create>.
      IF ls_line-step_uuid IS INITIAL.
        TRY.
            ls_line-step_uuid = cl_system_uuid=>create_uuid_x16_static( ).
          CATCH cx_uuid_error.
            RAISE SHORTDUMP NEW zpru_cx_agent_core( ).
        ENDTRY.
      ENDIF.

      NEW zpru_cl_agent_util( )->zpru_if_agent_util~fill_flags(
        EXPORTING
          iv_name    = `ZPRU_IF_AXC_TYPE_AND_CONSTANT=>TS_STEP_CONTROL`
        CHANGING
          cs_data    = ls_line
          cs_control = ls_line-control ).

      IF ls_line-query_uuid IS INITIAL.
        APPEND VALUE #( step_uuid  = ls_line-step_uuid
                        create     = abap_true
                        fail       = zpru_if_agent_frw=>cs_fail_cause-dependency )
               TO cs_failed-step.

        APPEND VALUE #( step_uuid  = ls_line-step_uuid
                        create     = abap_true
                        msg        = NEW zpru_cl_agent_util( )->zpru_if_agent_util~new_message(
                                           iv_id       = zpru_if_agent_frw=>cs_message_class-zpru_msg_execution
                                           iv_number   = `010`
                                           iv_severity = zpru_if_agent_message=>sc_severity-error ) )
               TO cs_reported-step.
        CONTINUE.
      ENDIF.

      APPEND INITIAL LINE TO et_entities ASSIGNING FIELD-SYMBOL(<ls_entity>).
      <ls_entity> = ls_line.
    ENDLOOP.
  ENDMETHOD.

  METHOD zpru_if_axc_precheck~precheck_rba_step.
    DATA ls_line TYPE zpru_if_axc_type_and_constant=>ts_rba_step_k.
    CLEAR et_entities.

    LOOP AT it_rba_step_k ASSIGNING FIELD-SYMBOL(<ls_rba>).
      ls_line = <ls_rba>.
      NEW zpru_cl_agent_util( )->zpru_if_agent_util~fill_flags(
        EXPORTING
          iv_name    = `ZPRU_IF_AXC_TYPE_AND_CONSTANT=>TS_STEP_CONTROL`
        CHANGING
          cs_data    = ls_line
          cs_control = ls_line-control ).

      APPEND INITIAL LINE TO et_entities ASSIGNING FIELD-SYMBOL(<ls_entity>).
      <ls_entity> = ls_line.
    ENDLOOP.
  ENDMETHOD.

  METHOD zpru_if_axc_precheck~precheck_read_step.
    DATA ls_line TYPE zpru_if_axc_type_and_constant=>ts_step_read_k.
    CLEAR et_entities.

    LOOP AT it_step_read_k ASSIGNING FIELD-SYMBOL(<ls_read>).
      ls_line = <ls_read>.
      NEW zpru_cl_agent_util( )->zpru_if_agent_util~fill_flags(
        EXPORTING
          iv_name    = `ZPRU_IF_AXC_TYPE_AND_CONSTANT=>TS_STEP_CONTROL`
        CHANGING
          cs_data    = ls_line
          cs_control = ls_line-control ).

      APPEND INITIAL LINE TO et_entities ASSIGNING FIELD-SYMBOL(<ls_entity>).
      <ls_entity> = ls_line.
    ENDLOOP.
  ENDMETHOD.

  METHOD zpru_if_axc_precheck~precheck_update_step.
    DATA ls_line TYPE zpru_if_axc_type_and_constant=>ts_step_update_imp.
    CLEAR et_entities.

    LOOP AT it_step_update_imp ASSIGNING FIELD-SYMBOL(<ls_update>).
      ls_line = <ls_update>.
      NEW zpru_cl_agent_util( )->zpru_if_agent_util~fill_flags(
        EXPORTING
          iv_name    = `ZPRU_IF_AXC_TYPE_AND_CONSTANT=>TS_STEP_CONTROL`
        CHANGING
          cs_data    = ls_line
          cs_control = ls_line-control ).

      APPEND INITIAL LINE TO et_entities ASSIGNING FIELD-SYMBOL(<ls_entity>).
      <ls_entity> = ls_line.
    ENDLOOP.
  ENDMETHOD.

  METHOD zpru_if_axc_precheck~precheck_delete_step.
    DATA ls_line TYPE zpru_if_axc_type_and_constant=>ts_step_delete_imp.
    CLEAR et_entities.

    LOOP AT it_step_delete_imp ASSIGNING FIELD-SYMBOL(<ls_delete>).
      ls_line = <ls_delete>.
      APPEND INITIAL LINE TO et_entities ASSIGNING FIELD-SYMBOL(<ls_entity>).
      <ls_entity> = ls_line.
    ENDLOOP.
  ENDMETHOD.

  METHOD zpru_if_axc_precheck~precheck_read_query.
    DATA ls_line TYPE zpru_if_axc_type_and_constant=>ts_query_read_k.
    CLEAR et_entities.

    LOOP AT it_query_read_k ASSIGNING FIELD-SYMBOL(<ls_read>).
      ls_line = <ls_read>.
      NEW zpru_cl_agent_util( )->zpru_if_agent_util~fill_flags(
        EXPORTING
          iv_name    = `ZPRU_IF_AXC_TYPE_AND_CONSTANT=>TS_QUERY_CONTROL`
        CHANGING
          cs_data    = ls_line
          cs_control = ls_line-control ).

      APPEND INITIAL LINE TO et_entities ASSIGNING FIELD-SYMBOL(<ls_entity>).
      <ls_entity> = ls_line.
    ENDLOOP.
  ENDMETHOD.

  METHOD zpru_if_axc_precheck~precheck_update_query.
    DATA ls_line TYPE zpru_if_axc_type_and_constant=>ts_query_update_imp.
    CLEAR et_entities.

    LOOP AT it_query_update_imp ASSIGNING FIELD-SYMBOL(<ls_update>).
      ls_line = <ls_update>.
      NEW zpru_cl_agent_util( )->zpru_if_agent_util~fill_flags(
        EXPORTING
          iv_name    = `ZPRU_IF_AXC_TYPE_AND_CONSTANT=>TS_QUERY_CONTROL`
        CHANGING
          cs_data    = ls_line
          cs_control = ls_line-control ).

      APPEND INITIAL LINE TO et_entities ASSIGNING FIELD-SYMBOL(<ls_entity>).
      <ls_entity> = ls_line.
    ENDLOOP.
  ENDMETHOD.

  METHOD zpru_if_axc_precheck~precheck_delete_query.
    DATA ls_line TYPE zpru_if_axc_type_and_constant=>ts_query_delete_imp.
    CLEAR et_entities.

    LOOP AT it_query_delete_imp ASSIGNING FIELD-SYMBOL(<ls_delete>).
      ls_line = <ls_delete>.
      APPEND INITIAL LINE TO et_entities ASSIGNING FIELD-SYMBOL(<ls_entity>).
      <ls_entity> = ls_line.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
