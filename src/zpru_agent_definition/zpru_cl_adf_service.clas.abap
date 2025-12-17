CLASS zpru_cl_adf_service DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zpru_if_adf_service.

  PROTECTED SECTION.
    METHODS db_modify
      IMPORTING iv_do_commit TYPE abap_boolean
      CHANGING  cs_reported  TYPE zpru_if_agent_frw=>ts_adf_reported
                cs_failed    TYPE zpru_if_agent_frw=>ts_adf_failed
                cs_mapped    TYPE zpru_if_agent_frw=>ts_adf_mapped
      RETURNING VALUE(rv_error) TYPE abap_bool.

    METHODS precheck_create_agent
      IMPORTING it_agent_create_imp TYPE zpru_if_adf_type_and_constant=>tt_agent_create_imp
      EXPORTING et_entities         TYPE zpru_if_adf_type_and_constant=>tt_agent_create_imp
      CHANGING  cs_reported         TYPE zpru_if_agent_frw=>ts_adf_reported
                cs_failed           TYPE zpru_if_agent_frw=>ts_adf_failed.

    METHODS precheck_update_agent
      IMPORTING it_agent_update_imp TYPE zpru_if_adf_type_and_constant=>tt_agent_update_imp
      EXPORTING et_entities         TYPE zpru_if_adf_type_and_constant=>tt_agent_update_imp
      CHANGING  cs_reported         TYPE zpru_if_agent_frw=>ts_adf_reported
                cs_failed           TYPE zpru_if_agent_frw=>ts_adf_failed.

    METHODS precheck_delete_agent
      IMPORTING it_agent_delete_imp TYPE zpru_if_adf_type_and_constant=>tt_agent_delete_imp
      EXPORTING et_entities         TYPE zpru_if_adf_type_and_constant=>tt_agent_delete_imp
      CHANGING  cs_reported         TYPE zpru_if_agent_frw=>ts_adf_reported
                cs_failed           TYPE zpru_if_agent_frw=>ts_adf_failed.

    METHODS precheck_read_agent
      IMPORTING it_agent_read_k TYPE zpru_if_adf_type_and_constant=>tt_agent_read_k
      EXPORTING et_entities     TYPE zpru_if_adf_type_and_constant=>tt_agent_read_k
      CHANGING  cs_reported     TYPE zpru_if_agent_frw=>ts_adf_reported
                cs_failed       TYPE zpru_if_agent_frw=>ts_adf_failed.

    METHODS precheck_cba_tool
      IMPORTING it_tool_create_imp TYPE zpru_if_adf_type_and_constant=>tt_tool_create_imp
      EXPORTING et_entities        TYPE zpru_if_adf_type_and_constant=>tt_tool_create_imp
      CHANGING  cs_reported        TYPE zpru_if_agent_frw=>ts_adf_reported
                cs_failed          TYPE zpru_if_agent_frw=>ts_adf_failed.

    METHODS precheck_update_tool
      IMPORTING it_tool_update_imp TYPE zpru_if_adf_type_and_constant=>tt_tool_update_imp
      EXPORTING et_entities        TYPE zpru_if_adf_type_and_constant=>tt_tool_update_imp
      CHANGING  cs_reported        TYPE zpru_if_agent_frw=>ts_adf_reported
                cs_failed          TYPE zpru_if_agent_frw=>ts_adf_failed.

    METHODS precheck_delete_tool
      IMPORTING it_tool_delete_imp TYPE zpru_if_adf_type_and_constant=>tt_tool_delete_imp
      EXPORTING et_entities        TYPE zpru_if_adf_type_and_constant=>tt_tool_delete_imp
      CHANGING  cs_reported        TYPE zpru_if_agent_frw=>ts_adf_reported
                cs_failed          TYPE zpru_if_agent_frw=>ts_adf_failed.

    METHODS precheck_read_tool
      IMPORTING it_tool_read_k TYPE zpru_if_adf_type_and_constant=>tt_tool_read_k
      EXPORTING et_entities    TYPE zpru_if_adf_type_and_constant=>tt_tool_read_k
      CHANGING  cs_reported    TYPE zpru_if_agent_frw=>ts_adf_reported
                cs_failed      TYPE zpru_if_agent_frw=>ts_adf_failed.

    METHODS precheck_rba_tool
      IMPORTING it_rba_tool_k TYPE zpru_if_adf_type_and_constant=>tt_rba_tool_k
      EXPORTING et_entities   TYPE zpru_if_adf_type_and_constant=>tt_rba_tool_k
      CHANGING  cs_reported   TYPE zpru_if_agent_frw=>ts_adf_reported
                cs_failed     TYPE zpru_if_agent_frw=>ts_adf_failed.

  PRIVATE SECTION.
    TYPES tt_agent      TYPE STANDARD TABLE OF zpru_agent WITH EMPTY KEY.
    TYPES tt_agent_tool TYPE STANDARD TABLE OF zpru_agent_tool WITH EMPTY KEY.

    METHODS collect_changes
      EXPORTING et_modify_agent TYPE tt_agent
                et_modify_tool  TYPE tt_agent_tool
                et_delete_agent TYPE tt_agent
                et_delete_tool  TYPE tt_agent_tool.

    METHODS cascade_deletes
      CHANGING ct_delete_agent TYPE tt_agent
               ct_delete_tool  TYPE tt_agent_tool.

    METHODS apply_db_changes
      IMPORTING it_modify_agent TYPE tt_agent
                it_modify_tool  TYPE tt_agent_tool
                it_delete_agent TYPE tt_agent
                it_delete_tool  TYPE tt_agent_tool
      RETURNING VALUE(rv_error) TYPE abap_bool.

    METHODS fill_agent_admin_fields
      IMPORTING iv_during_create TYPE abap_boolean DEFAULT abap_false
      CHANGING  cs_agent         TYPE zpru_cl_adf_buffer=>ts_agent.

ENDCLASS.



CLASS ZPRU_CL_ADF_SERVICE IMPLEMENTATION.

  METHOD precheck_create_agent.
    DATA lo_pre TYPE REF TO zpru_if_adf_precheck.
    lo_pre = zpru_cl_adf_factory=>zpru_if_adf_factory~get_zpru_if_adf_precheck( ).

    lo_pre->precheck_create_agent(
      EXPORTING it_agent_create_imp = it_agent_create_imp
      IMPORTING et_entities         = et_entities
      CHANGING  cs_reported         = cs_reported
                cs_failed           = cs_failed ).
  ENDMETHOD.


  METHOD precheck_update_agent.
    DATA lo_pre TYPE REF TO zpru_if_adf_precheck.
    lo_pre = zpru_cl_adf_factory=>zpru_if_adf_factory~get_zpru_if_adf_precheck( ).

    lo_pre->precheck_update_agent(
      EXPORTING it_agent_update_imp = it_agent_update_imp
      IMPORTING et_entities         = et_entities
      CHANGING  cs_reported         = cs_reported
                cs_failed           = cs_failed ).
  ENDMETHOD.


  METHOD precheck_delete_agent.
    DATA lo_pre TYPE REF TO zpru_if_adf_precheck.
    lo_pre = zpru_cl_adf_factory=>zpru_if_adf_factory~get_zpru_if_adf_precheck( ).

    lo_pre->precheck_delete_agent(
      EXPORTING it_agent_delete_imp = it_agent_delete_imp
      IMPORTING et_entities         = et_entities
      CHANGING  cs_reported         = cs_reported
                cs_failed           = cs_failed ).
  ENDMETHOD.


  METHOD precheck_read_agent.
    DATA lo_pre TYPE REF TO zpru_if_adf_precheck.
    lo_pre = zpru_cl_adf_factory=>zpru_if_adf_factory~get_zpru_if_adf_precheck( ).

    lo_pre->precheck_read_agent(
      EXPORTING it_agent_read_k = it_agent_read_k
      IMPORTING et_entities     = et_entities
      CHANGING  cs_reported     = cs_reported
                cs_failed       = cs_failed ).
  ENDMETHOD.


  METHOD precheck_cba_tool.
    DATA lo_pre TYPE REF TO zpru_if_adf_precheck.
    lo_pre = zpru_cl_adf_factory=>zpru_if_adf_factory~get_zpru_if_adf_precheck( ).

    lo_pre->precheck_cba_tool(
      EXPORTING it_tool_create_imp = it_tool_create_imp
      IMPORTING et_entities        = et_entities
      CHANGING  cs_reported        = cs_reported
                cs_failed          = cs_failed ).
  ENDMETHOD.


  METHOD precheck_update_tool.
    DATA lo_pre TYPE REF TO zpru_if_adf_precheck.
    lo_pre = zpru_cl_adf_factory=>zpru_if_adf_factory~get_zpru_if_adf_precheck( ).

    lo_pre->precheck_update_tool(
      EXPORTING it_tool_update_imp = it_tool_update_imp
      IMPORTING et_entities        = et_entities
      CHANGING  cs_reported        = cs_reported
                cs_failed          = cs_failed ).
  ENDMETHOD.


  METHOD precheck_delete_tool.
    DATA lo_pre TYPE REF TO zpru_if_adf_precheck.
    lo_pre = zpru_cl_adf_factory=>zpru_if_adf_factory~get_zpru_if_adf_precheck( ).

    lo_pre->precheck_delete_tool(
      EXPORTING it_tool_delete_imp = it_tool_delete_imp
      IMPORTING et_entities        = et_entities
      CHANGING  cs_reported        = cs_reported
                cs_failed          = cs_failed ).
  ENDMETHOD.


  METHOD precheck_read_tool.
    DATA lo_pre TYPE REF TO zpru_if_adf_precheck.
    lo_pre = zpru_cl_adf_factory=>zpru_if_adf_factory~get_zpru_if_adf_precheck( ).

    lo_pre->precheck_read_tool(
      EXPORTING it_tool_read_k = it_tool_read_k
      IMPORTING et_entities    = et_entities
      CHANGING  cs_reported    = cs_reported
                cs_failed      = cs_failed ).
  ENDMETHOD.


  METHOD precheck_rba_tool.
    DATA lo_pre TYPE REF TO zpru_if_adf_precheck.
    lo_pre = zpru_cl_adf_factory=>zpru_if_adf_factory~get_zpru_if_adf_precheck( ).

    lo_pre->precheck_rba_tool(
      EXPORTING it_rba_tool_k = it_rba_tool_k
      IMPORTING et_entities   = et_entities
      CHANGING  cs_reported   = cs_reported
                cs_failed     = cs_failed ).
  ENDMETHOD.


  METHOD zpru_if_adf_service~query_agent.
    CLEAR: et_agent_k,
           et_tool_agent_link.

    SELECT agent_uuid FROM zpru_agent
      WHERE agent_name             IN @it_agent_name
        AND decision_provider      IN @it_decision_provider
        AND short_memory_provider  IN @it_short_memory_provider
        AND long_memory_provider   IN @it_long_memory_provider
        AND agent_info_provider    IN @it_agent_info_provider
        AND system_prompt_provider IN @it_system_prompt_provider
        AND status                 IN @it_status
        AND created_by             IN @it_created_by
        AND created_at             IN @it_created_at
        AND changed_by             IN @it_changed_by
        AND last_changed           IN @it_last_changed
      INTO TABLE @et_agent_k.

    IF et_agent_k IS INITIAL.
      RETURN.
    ENDIF.

    IF et_tool_agent_link IS SUPPLIED.
      SELECT agent_uuid, tool_uuid FROM zpru_agent_tool
        FOR ALL ENTRIES IN @et_agent_k
        WHERE agent_uuid = @et_agent_k-agent_uuid
        INTO TABLE @et_tool_agent_link.
    ENDIF.
  ENDMETHOD.


  METHOD zpru_if_adf_service~create_agent.
    precheck_create_agent( EXPORTING it_agent_create_imp = it_agent_create_imp
                           IMPORTING et_entities         = DATA(lt_entities)
                           CHANGING  cs_reported         = cs_reported
                                     cs_failed           = cs_failed ).

    IF lt_entities IS INITIAL.
      RETURN.
    ENDIF.

    zpru_cl_adf_buffer=>prep_agent_buffer( VALUE #( FOR <ls_k>
                                                    IN     lt_entities
                                                    ( agent_uuid = <ls_k>-agent_uuid ) ) ).

    LOOP AT lt_entities ASSIGNING FIELD-SYMBOL(<ls_create>).

      IF    NOT line_exists( zpru_cl_adf_buffer=>agent_buffer[ instance-agent_uuid = <ls_create>-agent_uuid ] )
         OR     line_exists( zpru_cl_adf_buffer=>agent_buffer[ instance-agent_uuid = <ls_create>-agent_uuid
                                                               deleted             = abap_true ] ).

        ASSIGN zpru_cl_adf_buffer=>agent_buffer[ instance-agent_uuid = <ls_create>-agent_uuid
                                                 deleted             = abap_false ] TO FIELD-SYMBOL(<ls_buffer>).
        IF sy-subrc = 0.
           DELETE zpru_cl_adf_buffer=>agent_buffer
                  WHERE     instance-agent_uuid = <ls_buffer>-instance-agent_uuid
                        AND deleted             = abap_true.
        ENDIF.

        APPEND VALUE #(
            instance-agent_uuid             = <ls_create>-agent_uuid
            instance-agent_name             = COND #( WHEN <ls_create>-control-agent_name = abap_true
                                                      THEN <ls_create>-agent_name )
            instance-decision_provider      = COND #( WHEN <ls_create>-control-decision_provider = abap_true
                                                      THEN <ls_create>-decision_provider )
            instance-short_memory_provider  = COND #( WHEN <ls_create>-control-short_memory_provider = abap_true
                                                      THEN <ls_create>-short_memory_provider )
            instance-long_memory_provider   = COND #( WHEN <ls_create>-control-long_memory_provider = abap_true
                                                      THEN <ls_create>-long_memory_provider )
            instance-agent_info_provider    = COND #( WHEN <ls_create>-control-agent_info_provider = abap_true
                                                      THEN <ls_create>-agent_info_provider )
            instance-system_prompt_provider = COND #( WHEN <ls_create>-control-system_prompt_provider = abap_true
                                                      THEN <ls_create>-system_prompt_provider )
            instance-status                 = COND #( WHEN <ls_create>-control-status = abap_true
                                                      THEN <ls_create>-status )
            instance-created_by             = COND #( WHEN <ls_create>-control-created_by = abap_true
                                                      THEN <ls_create>-created_by )
            instance-created_at             = COND #( WHEN <ls_create>-control-created_at = abap_true
                                                      THEN <ls_create>-created_at )
            instance-changed_by             = COND #( WHEN <ls_create>-control-changed_by <> if_abap_behv=>mk-off
                                                      THEN <ls_create>-changed_by )
            instance-last_changed           = COND #( WHEN <ls_create>-control-last_changed = abap_true
                                                      THEN <ls_create>-last_changed )
            instance-local_last_changed     = COND #( WHEN <ls_create>-control-local_last_changed = abap_true
                                                      THEN <ls_create>-local_last_changed )
            changed                         = abap_true
            deleted                         = abap_false ) TO zpru_cl_adf_buffer=>agent_buffer ASSIGNING FIELD-SYMBOL(<ls_just_added>).

         fill_agent_admin_fields( EXPORTING iv_during_create = abap_true
                                  CHANGING  cs_agent         = <ls_just_added> ).

         INSERT VALUE #( agent_uuid = <ls_create>-agent_uuid ) INTO TABLE cs_mapped-agent.

         APPEND VALUE #( msg      = NEW zpru_cl_agent_util( )->zpru_if_agent_util~new_message(
                                            iv_id       = zpru_if_agent_frw=>cs_message_class-zpru_msg_execution
                                            iv_number   = `001`
                                            iv_severity = zpru_if_agent_message=>sc_severity-success
                                            iv_v1       = <ls_create>-agent_uuid )
                         agent_uuid = <ls_create>-agent_uuid ) TO cs_reported-agent.

      ELSE.
        APPEND VALUE #( agent_uuid = <ls_create>-agent_uuid
                        create     = abap_true
                        fail       = zpru_if_agent_frw=>cs_fail_cause-conflict )
               TO cs_failed-agent.

        APPEND VALUE #( agent_uuid = <ls_create>-agent_uuid
                        create     = abap_true
                        msg        = NEW zpru_cl_agent_util( )->zpru_if_agent_util~new_message(
                                           iv_id       = zpru_if_agent_frw=>cs_message_class-zpru_msg_execution
                                           iv_number   = `002`
                                           iv_severity = zpru_if_agent_message=>sc_severity-error
                                           iv_v1       = <ls_create>-agent_uuid ) )
               TO cs_reported-agent.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD zpru_if_adf_service~read_agent.
    DATA ls_out TYPE zpru_agent.
    CLEAR et_agent.

    IF it_agent_read_k IS INITIAL.
      RETURN.
    ENDIF.

    precheck_read_agent( EXPORTING it_agent_read_k = it_agent_read_k
                         IMPORTING et_entities     = DATA(lt_entities)
                         CHANGING  cs_reported     = cs_reported
                                   cs_failed       = cs_failed ).

    zpru_cl_adf_buffer=>prep_agent_buffer( VALUE #( FOR <ls_k>
                                                    IN     lt_entities
                                                    ( agent_uuid = <ls_k>-agent_uuid ) ) ).

    LOOP AT lt_entities ASSIGNING FIELD-SYMBOL(<ls_read>).

      ASSIGN zpru_cl_adf_buffer=>agent_buffer[ instance-agent_uuid = <ls_read>-agent_uuid
                                               deleted             = abap_false ] TO FIELD-SYMBOL(<ls_buffer>).
      IF sy-subrc = 0.
        CLEAR ls_out.
        ls_out-agent_uuid             = <ls_buffer>-instance-agent_uuid.

        ls_out-agent_name             = COND #( WHEN <ls_read>-control-agent_name = abap_true
                                                THEN <ls_buffer>-instance-agent_name ).
        ls_out-decision_provider      = COND #( WHEN <ls_read>-control-decision_provider = abap_true
                                                THEN <ls_buffer>-instance-decision_provider ).
        ls_out-short_memory_provider  = COND #( WHEN <ls_read>-control-short_memory_provider = abap_true
                                                THEN <ls_buffer>-instance-short_memory_provider ).
        ls_out-long_memory_provider   = COND #( WHEN <ls_read>-control-long_memory_provider = abap_true
                                                THEN <ls_buffer>-instance-long_memory_provider ).
        ls_out-agent_info_provider    = COND #( WHEN <ls_read>-control-agent_info_provider = abap_true
                                                THEN <ls_buffer>-instance-agent_info_provider ).
        ls_out-system_prompt_provider = COND #( WHEN <ls_read>-control-system_prompt_provider = abap_true
                                                THEN <ls_buffer>-instance-system_prompt_provider ).
        ls_out-status                 = COND #( WHEN <ls_read>-control-status = abap_true
                                                THEN <ls_buffer>-instance-status ).
        ls_out-created_by             = COND #( WHEN <ls_read>-control-created_by = abap_true
                                                THEN <ls_buffer>-instance-created_by ).
        ls_out-created_at             = COND #( WHEN <ls_read>-control-created_at = abap_true
                                                THEN <ls_buffer>-instance-created_at ).
        ls_out-changed_by             = COND #( WHEN <ls_read>-control-changed_by = abap_true
                                                THEN <ls_buffer>-instance-changed_by ).
        ls_out-last_changed           = COND #( WHEN <ls_read>-control-last_changed = abap_true
                                                THEN <ls_buffer>-instance-last_changed ).
        ls_out-local_last_changed     = COND #( WHEN <ls_read>-control-local_last_changed = abap_true
                                                THEN <ls_buffer>-instance-local_last_changed ).

        APPEND ls_out TO et_agent.

      ELSE.
        APPEND VALUE #( agent_uuid = <ls_read>-agent_uuid
                        fail       = zpru_if_agent_frw=>cs_fail_cause-not_found )
               TO cs_failed-agent.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD zpru_if_adf_service~update_agent.
    precheck_update_agent( EXPORTING it_agent_update_imp = it_agent_update_imp
                           IMPORTING et_entities         = DATA(lt_entities)
                           CHANGING  cs_reported         = cs_reported
                                     cs_failed           = cs_failed ).

    IF lt_entities IS INITIAL.
      RETURN.
    ENDIF.

    zpru_cl_adf_buffer=>prep_agent_buffer( VALUE #( FOR <ls_k>
                                                    IN     lt_entities
                                                    ( agent_uuid = <ls_k>-agent_uuid ) ) ).

    LOOP AT lt_entities ASSIGNING FIELD-SYMBOL(<ls_update>).

      ASSIGN zpru_cl_adf_buffer=>agent_buffer[ instance-agent_uuid = <ls_update>-agent_uuid
                                               deleted             = abap_false ] TO FIELD-SYMBOL(<ls_buffer>).
      IF sy-subrc = 0.
        <ls_buffer>-instance-agent_name             = COND #( WHEN <ls_update>-control-agent_name = abap_true
                                                              THEN <ls_update>-agent_name
                                                              ELSE <ls_buffer>-instance-agent_name ).
        <ls_buffer>-instance-decision_provider      = COND #( WHEN <ls_update>-control-decision_provider = abap_true
                                                              THEN <ls_update>-decision_provider
                                                              ELSE <ls_buffer>-instance-decision_provider ).
        <ls_buffer>-instance-short_memory_provider  = COND #( WHEN <ls_update>-control-short_memory_provider = abap_true
                                                              THEN <ls_update>-short_memory_provider
                                                              ELSE <ls_buffer>-instance-short_memory_provider ).
        <ls_buffer>-instance-long_memory_provider   = COND #( WHEN <ls_update>-control-long_memory_provider = abap_true
                                                              THEN <ls_update>-long_memory_provider
                                                              ELSE <ls_buffer>-instance-long_memory_provider ).
        <ls_buffer>-instance-agent_info_provider    = COND #( WHEN <ls_update>-control-agent_info_provider = abap_true
                                                              THEN <ls_update>-agent_info_provider
                                                              ELSE <ls_buffer>-instance-agent_info_provider ).
        <ls_buffer>-instance-system_prompt_provider = COND #( WHEN <ls_update>-control-system_prompt_provider = abap_true
                                                              THEN <ls_update>-system_prompt_provider
                                                              ELSE <ls_buffer>-instance-system_prompt_provider ).
        <ls_buffer>-instance-status                 = COND #( WHEN <ls_update>-control-status = abap_true
                                                              THEN <ls_update>-status
                                                              ELSE <ls_buffer>-instance-status ).
        <ls_buffer>-instance-created_by             = COND #( WHEN <ls_update>-control-created_by = abap_true
                                                              THEN <ls_update>-created_by
                                                              ELSE <ls_buffer>-instance-created_by ).
        <ls_buffer>-instance-created_at             = COND #( WHEN <ls_update>-control-created_at = abap_true
                                                              THEN <ls_update>-created_at
                                                              ELSE <ls_buffer>-instance-created_at ).
        <ls_buffer>-instance-changed_by             = COND #( WHEN <ls_update>-control-changed_by = abap_true
                                                              THEN <ls_update>-changed_by
                                                              ELSE <ls_buffer>-instance-changed_by ).
        <ls_buffer>-instance-last_changed           = COND #( WHEN <ls_update>-control-last_changed = abap_true
                                                              THEN <ls_update>-last_changed
                                                              ELSE <ls_buffer>-instance-last_changed ).
        <ls_buffer>-instance-local_last_changed     = COND #( WHEN <ls_update>-control-local_last_changed = abap_true
                                                              THEN <ls_update>-local_last_changed
                                                              ELSE <ls_buffer>-instance-local_last_changed ).

        <ls_buffer>-changed = abap_true.
        <ls_buffer>-deleted = abap_false.

        fill_agent_admin_fields( EXPORTING iv_during_create = abap_false
                                 CHANGING  cs_agent         = <ls_buffer> ).

      ELSE.
        APPEND VALUE #( agent_uuid = <ls_update>-agent_uuid
                        update     = abap_true
                        fail       = zpru_if_agent_frw=>cs_fail_cause-not_found )
               TO cs_failed-agent.

        APPEND VALUE #( agent_uuid = <ls_update>-agent_uuid
                        update     = abap_true
                        msg        = NEW zpru_cl_agent_util( )->zpru_if_agent_util~new_message(
                                           iv_id       = zpru_if_agent_frw=>cs_message_class-zpru_msg_execution
                                           iv_number   = `012`
                                           iv_severity = zpru_if_agent_message=>sc_severity-error
                                           iv_v1       = <ls_update>-agent_uuid ) )
               TO cs_reported-agent.

      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD zpru_if_adf_service~delete_agent.
    precheck_delete_agent( EXPORTING it_agent_delete_imp = it_agent_delete_imp
                           IMPORTING et_entities         = DATA(lt_entities)
                           CHANGING  cs_reported         = cs_reported
                                     cs_failed           = cs_failed ).

    IF lt_entities IS INITIAL.
      RETURN.
    ENDIF.

    zpru_cl_adf_buffer=>prep_agent_buffer( VALUE #( FOR <ls_k>
                                                    IN     lt_entities
                                                    ( agent_uuid = <ls_k>-agent_uuid ) ) ).

    zpru_cl_adf_buffer=>prep_tool_buffer( VALUE #( FOR <ls_q>
                                                   IN     lt_entities
                                                   ( agent_uuid = <ls_q>-agent_uuid ) ) ).


    LOOP AT lt_entities ASSIGNING FIELD-SYMBOL(<ls_delete>).

      ASSIGN zpru_cl_adf_buffer=>agent_buffer[ instance-agent_uuid = <ls_delete>-agent_uuid
                                               deleted             = abap_false ] TO FIELD-SYMBOL(<ls_buffer>).
      IF sy-subrc = 0.
        <ls_buffer>-deleted = abap_true.
        <ls_buffer>-changed = abap_true.

        LOOP AT zpru_cl_adf_buffer=>tool_buffer ASSIGNING FIELD-SYMBOL(<ls_tool_del>)
             WHERE instance-agent_uuid = <ls_buffer>-instance-agent_uuid.
          <ls_tool_del>-changed = abap_true.
          <ls_tool_del>-deleted = abap_true.
        ENDLOOP.

        APPEND VALUE #( msg      = NEW zpru_cl_agent_util( )->zpru_if_agent_util~new_message(
                                           iv_id       = zpru_if_agent_frw=>cs_message_class-zpru_msg_execution
                                           iv_number   = `001`
                                           iv_severity = zpru_if_agent_message=>sc_severity-success
                                           iv_v1       = <ls_delete>-agent_uuid )
                        agent_uuid = <ls_delete>-agent_uuid ) TO cs_reported-agent.

      ELSE.
        APPEND VALUE #( agent_uuid = <ls_delete>-agent_uuid
                        delete     = abap_true
                        fail       = zpru_if_agent_frw=>cs_fail_cause-not_found )
               TO cs_failed-agent.

        APPEND VALUE #( agent_uuid = <ls_delete>-agent_uuid
                        delete     = abap_true
                        msg        = NEW zpru_cl_agent_util( )->zpru_if_agent_util~new_message(
                                           iv_id       = zpru_if_agent_frw=>cs_message_class-zpru_msg_execution
                                           iv_number   = `003`
                                           iv_severity = zpru_if_agent_message=>sc_severity-error ) )
               TO cs_reported-agent.

      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD zpru_if_adf_service~cba_tool.
    precheck_cba_tool( EXPORTING it_tool_create_imp = it_tool_create_imp
                       IMPORTING et_entities        = DATA(lt_entities)
                       CHANGING  cs_reported        = cs_reported
                                 cs_failed          = cs_failed ).

    IF lt_entities IS INITIAL.
      RETURN.
    ENDIF.

    zpru_cl_adf_buffer=>prep_agent_buffer( VALUE #( FOR <ls_k>
                                                    IN  lt_entities
                                                    ( agent_uuid = <ls_k>-agent_uuid ) ) ).

    zpru_cl_adf_buffer=>prep_tool_buffer( VALUE #( FOR <ls_q>
                                                   IN     lt_entities
                                                   ( agent_uuid = <ls_q>-agent_uuid
                                                     tool_uuid  = <ls_q>-tool_uuid
                                                     full_key   = abap_true ) ) ).

    LOOP AT lt_entities ASSIGNING FIELD-SYMBOL(<ls_create>).

      ASSIGN zpru_cl_adf_buffer=>agent_buffer[ instance-agent_uuid = <ls_create>-agent_uuid
                                               deleted             = abap_false ] TO FIELD-SYMBOL(<ls_parent>).
      IF sy-subrc = 0.
        IF    NOT line_exists( zpru_cl_adf_buffer=>tool_buffer[ instance-agent_uuid = <ls_create>-agent_uuid
                                                                instance-tool_uuid  = <ls_create>-tool_uuid ] )
           OR     line_exists( zpru_cl_adf_buffer=>tool_buffer[ instance-agent_uuid = <ls_create>-agent_uuid
                                                                instance-tool_uuid  = <ls_create>-tool_uuid
                                                                deleted             = abap_true ] ).

          ASSIGN zpru_cl_adf_buffer=>tool_buffer[ instance-agent_uuid = <ls_create>-agent_uuid
                                                  instance-tool_uuid  = <ls_create>-tool_uuid
                                                  deleted             = abap_false ] TO FIELD-SYMBOL(<ls_buffer>).
          IF sy-subrc = 0.
            DELETE zpru_cl_adf_buffer=>tool_buffer
                   WHERE     instance-agent_uuid = <ls_buffer>-instance-agent_uuid
                         AND instance-tool_uuid  = <ls_buffer>-instance-tool_uuid
                         AND deleted             = abap_true.
          ENDIF.

          APPEND VALUE #(
              instance-tool_uuid            = <ls_create>-tool_uuid
              instance-agent_uuid           = <ls_create>-agent_uuid
              instance-tool_name            = COND #( WHEN <ls_create>-control-tool_name = abap_true
                                                      THEN <ls_create>-tool_name )
              instance-tool_provider        = COND #( WHEN <ls_create>-control-tool_provider = abap_true
                                                      THEN <ls_create>-tool_provider )
              instance-step_type            = COND #( WHEN <ls_create>-control-step_type = abap_true
                                                      THEN <ls_create>-step_type )
              instance-input_schema_provider = COND #( WHEN <ls_create>-control-input_schema_provider = abap_true
                                                      THEN <ls_create>-input_schema_provider )
              instance-tool_info_provider   = COND #( WHEN <ls_create>-control-tool_info_provider = abap_true
                                                      THEN <ls_create>-tool_info_provider )
              changed                       = abap_true
              deleted                       = abap_false ) TO zpru_cl_adf_buffer=>tool_buffer.

          APPEND VALUE #( agent_uuid = <ls_create>-agent_uuid
                          tool_uuid  = <ls_create>-tool_uuid ) TO cs_mapped-tool.

          APPEND VALUE #( msg        = NEW zpru_cl_agent_util( )->zpru_if_agent_util~new_message(
                                             iv_id       = zpru_if_agent_frw=>cs_message_class-zpru_msg_execution
                                             iv_number   = `001`
                                             iv_severity = zpru_if_agent_message=>sc_severity-success
                                             iv_v1       = <ls_create>-tool_uuid )
                          agent_uuid = <ls_create>-agent_uuid
                          tool_uuid  = <ls_create>-tool_uuid ) TO cs_reported-tool.

        ELSE.
          APPEND VALUE #( agent_uuid = <ls_create>-agent_uuid
                          tool_uuid  = <ls_create>-tool_uuid
                          create     = abap_true
                          fail       = zpru_if_agent_frw=>cs_fail_cause-conflict )
                 TO cs_failed-tool.

          APPEND VALUE #( agent_uuid = <ls_create>-agent_uuid
                          tool_uuid  = <ls_create>-tool_uuid
                          create     = abap_true
                          msg        = NEW zpru_cl_agent_util( )->zpru_if_agent_util~new_message(
                                             iv_id       = zpru_if_agent_frw=>cs_message_class-zpru_msg_execution
                                             iv_number   = `001`
                                             iv_severity = zpru_if_agent_message=>sc_severity-error
                                             iv_v1       = <ls_create>-tool_uuid ) )
                 TO cs_reported-tool.
        ENDIF.

      ELSE.
        APPEND VALUE #( agent_uuid = <ls_create>-agent_uuid
                        tool_uuid  = <ls_create>-tool_uuid
                        create     = abap_true
                        fail       = zpru_if_agent_frw=>cs_fail_cause-not_found )
               TO cs_failed-tool.

        APPEND VALUE #( agent_uuid = <ls_create>-agent_uuid
                        tool_uuid  = <ls_create>-tool_uuid
                        create     = abap_true
                        msg        = NEW zpru_cl_agent_util( )->zpru_if_agent_util~new_message(
                                           iv_id       = zpru_if_agent_frw=>cs_message_class-zpru_msg_execution
                                           iv_number   = `002`
                                           iv_severity = zpru_if_agent_message=>sc_severity-error ) )
               TO cs_reported-tool.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD zpru_if_adf_service~rba_tool.
    DATA ls_out TYPE zpru_agent_tool.
    CLEAR et_tool.

    IF it_rba_tool_k IS INITIAL.
      RETURN.
    ENDIF.

    precheck_rba_tool( EXPORTING it_rba_tool_k = it_rba_tool_k
                       IMPORTING et_entities   = DATA(lt_entities)
                       CHANGING  cs_reported   = cs_reported
                                 cs_failed     = cs_failed ).


    zpru_cl_adf_buffer=>prep_agent_buffer( VALUE #( FOR <ls_k>
                                                    IN     lt_entities
                                                    ( agent_uuid = <ls_k>-agent_uuid ) ) ).

    zpru_cl_adf_buffer=>prep_tool_buffer( VALUE #( FOR <ls_q>
                                                   IN     lt_entities
                                                   ( agent_uuid = <ls_q>-agent_uuid ) ) ).

    LOOP AT lt_entities ASSIGNING FIELD-SYMBOL(<ls_h>).
      LOOP AT zpru_cl_adf_buffer=>tool_buffer ASSIGNING FIELD-SYMBOL(<ls_t_buf>)
           WHERE     instance-agent_uuid = <ls_h>-agent_uuid
                 AND deleted             = abap_false.

        CLEAR ls_out.
        ls_out-tool_uuid             = <ls_t_buf>-instance-tool_uuid.
        ls_out-agent_uuid            = COND #( WHEN <ls_h>-control-agent_uuid = abap_true
                                               THEN <ls_t_buf>-instance-agent_uuid ).
        ls_out-tool_name             = COND #( WHEN <ls_h>-control-tool_name = abap_true
                                               THEN <ls_t_buf>-instance-tool_name ).
        ls_out-tool_provider         = COND #( WHEN <ls_h>-control-tool_provider = abap_true
                                               THEN <ls_t_buf>-instance-tool_provider ).
        ls_out-step_type             = COND #( WHEN <ls_h>-control-step_type = abap_true
                                               THEN <ls_t_buf>-instance-step_type ).
        ls_out-input_schema_provider = COND #( WHEN <ls_h>-control-input_schema_provider = abap_true
                                               THEN <ls_t_buf>-instance-input_schema_provider ).
        ls_out-tool_info_provider    = COND #( WHEN <ls_h>-control-tool_info_provider = abap_true
                                               THEN <ls_t_buf>-instance-tool_info_provider ).

        APPEND ls_out TO et_tool.
      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.


  METHOD zpru_if_adf_service~read_tool.
    DATA ls_out TYPE zpru_agent_tool.
    CLEAR et_tool.

    IF it_tool_read_k IS INITIAL.
      RETURN.
    ENDIF.

    precheck_read_tool( EXPORTING it_tool_read_k = it_tool_read_k
                        IMPORTING et_entities    = DATA(lt_entities)
                        CHANGING  cs_reported    = cs_reported
                                  cs_failed      = cs_failed ).


    zpru_cl_adf_buffer=>prep_agent_buffer( VALUE #( FOR <ls_k>
                                                    IN     lt_entities
                                                    ( agent_uuid = <ls_k>-agent_uuid ) ) ).

    zpru_cl_adf_buffer=>prep_tool_buffer( VALUE #( FOR <ls_q>
                                                   IN     lt_entities
                                                   ( agent_uuid = <ls_q>-agent_uuid
                                                     tool_uuid  = <ls_q>-tool_uuid
                                                     full_key   = abap_true ) ) ).


    LOOP AT lt_entities ASSIGNING FIELD-SYMBOL(<ls_read>).
      ASSIGN zpru_cl_adf_buffer=>agent_buffer[ instance-agent_uuid = <ls_read>-agent_uuid ] TO FIELD-SYMBOL(<ls_parent>).
      IF sy-subrc = 0 AND <ls_parent>-deleted = abap_true.
         APPEND VALUE #( agent_uuid = <ls_read>-agent_uuid
                         tool_uuid  = <ls_read>-tool_uuid
                         fail       = zpru_if_agent_frw=>cs_fail_cause-not_found )
                TO cs_failed-tool.
         CONTINUE.
      ENDIF.

      ASSIGN zpru_cl_adf_buffer=>tool_buffer[ instance-agent_uuid = <ls_read>-agent_uuid
                                              instance-tool_uuid  = <ls_read>-tool_uuid ] TO FIELD-SYMBOL(<ls_buffer>).
      IF sy-subrc = 0.
        IF <ls_buffer>-deleted = abap_true.
          APPEND VALUE #( agent_uuid = <ls_read>-agent_uuid
                          tool_uuid  = <ls_read>-tool_uuid
                          fail       = zpru_if_agent_frw=>cs_fail_cause-not_found )
                 TO cs_failed-tool.
          CONTINUE.
        ENDIF.

        CLEAR ls_out.
        ls_out-tool_uuid            = <ls_buffer>-instance-tool_uuid.
        ls_out-agent_uuid           = COND #( WHEN <ls_read>-control-agent_uuid = abap_true
                                              THEN <ls_buffer>-instance-agent_uuid ).
        ls_out-tool_name            = COND #( WHEN <ls_read>-control-tool_name = abap_true
                                              THEN <ls_buffer>-instance-tool_name ).
        ls_out-tool_provider        = COND #( WHEN <ls_read>-control-tool_provider = abap_true
                                              THEN <ls_buffer>-instance-tool_provider ).
        ls_out-step_type            = COND #( WHEN <ls_read>-control-step_type = abap_true
                                              THEN <ls_buffer>-instance-step_type ).
        ls_out-input_schema_provider = COND #( WHEN <ls_read>-control-input_schema_provider = abap_true
                                              THEN <ls_buffer>-instance-input_schema_provider ).
        ls_out-tool_info_provider   = COND #( WHEN <ls_read>-control-tool_info_provider = abap_true
                                              THEN <ls_buffer>-instance-tool_info_provider ).

        APPEND ls_out TO et_tool.

      ELSE.
        APPEND VALUE #( agent_uuid = <ls_read>-agent_uuid
                        tool_uuid  = <ls_read>-tool_uuid
                        fail       = zpru_if_agent_frw=>cs_fail_cause-not_found )
               TO cs_failed-tool.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD zpru_if_adf_service~update_tool.
    precheck_update_tool( EXPORTING it_tool_update_imp = it_tool_update_imp
                          IMPORTING et_entities        = DATA(lt_entities)
                          CHANGING  cs_reported        = cs_reported
                                    cs_failed          = cs_failed ).

    IF lt_entities IS INITIAL.
      RETURN.
    ENDIF.

    zpru_cl_adf_buffer=>prep_agent_buffer( VALUE #( FOR <ls_k>
                                                    IN     lt_entities
                                                    ( agent_uuid = <ls_k>-agent_uuid ) ) ).

    zpru_cl_adf_buffer=>prep_tool_buffer( VALUE #( FOR <ls_q>
                                                   IN     lt_entities
                                                   ( agent_uuid = <ls_q>-agent_uuid
                                                     tool_uuid  = <ls_q>-tool_uuid
                                                     full_key   = abap_true ) ) ).


    LOOP AT lt_entities ASSIGNING FIELD-SYMBOL(<ls_update>).

      ASSIGN zpru_cl_adf_buffer=>agent_buffer[ instance-agent_uuid = <ls_update>-agent_uuid ] TO FIELD-SYMBOL(<ls_parent>).
      IF sy-subrc = 0 AND <ls_parent>-deleted = abap_true.
         APPEND VALUE #( agent_uuid = <ls_update>-agent_uuid
                         tool_uuid  = <ls_update>-tool_uuid
                         update     = abap_true
                         fail       = zpru_if_agent_frw=>cs_fail_cause-not_found )
                TO cs_failed-tool.
         CONTINUE.
      ENDIF.


      ASSIGN zpru_cl_adf_buffer=>tool_buffer[ instance-agent_uuid = <ls_update>-agent_uuid
                                              instance-tool_uuid  = <ls_update>-tool_uuid ] TO FIELD-SYMBOL(<ls_buffer>).
      IF sy-subrc = 0 AND <ls_buffer>-deleted = abap_false.
        <ls_buffer>-instance-tool_name            = COND #( WHEN <ls_update>-control-tool_name = abap_true
                                                            THEN <ls_update>-tool_name
                                                            ELSE <ls_buffer>-instance-tool_name ).
        <ls_buffer>-instance-tool_provider        = COND #( WHEN <ls_update>-control-tool_provider = abap_true
                                                            THEN <ls_update>-tool_provider
                                                            ELSE <ls_buffer>-instance-tool_provider ).
        <ls_buffer>-instance-step_type            = COND #( WHEN <ls_update>-control-step_type = abap_true
                                                            THEN <ls_update>-step_type
                                                            ELSE <ls_buffer>-instance-step_type ).
        <ls_buffer>-instance-input_schema_provider = COND #( WHEN <ls_update>-control-input_schema_provider = abap_true
                                                            THEN <ls_update>-input_schema_provider
                                                            ELSE <ls_buffer>-instance-input_schema_provider ).
        <ls_buffer>-instance-tool_info_provider   = COND #( WHEN <ls_update>-control-tool_info_provider = abap_true
                                                            THEN <ls_update>-tool_info_provider
                                                            ELSE <ls_buffer>-instance-tool_info_provider ).
        <ls_buffer>-changed = abap_true.

      ELSE.
        APPEND VALUE #( agent_uuid = <ls_update>-agent_uuid
                        tool_uuid  = <ls_update>-tool_uuid
                        update     = abap_true
                        fail       = zpru_if_agent_frw=>cs_fail_cause-not_found )
               TO cs_failed-tool.

        APPEND VALUE #( agent_uuid = <ls_update>-agent_uuid
                        tool_uuid  = <ls_update>-tool_uuid
                        update     = abap_true
                        msg        = NEW zpru_cl_agent_util( )->zpru_if_agent_util~new_message(
                                           iv_id       = zpru_if_agent_frw=>cs_message_class-zpru_msg_execution
                                           iv_number   = `002`
                                           iv_severity = zpru_if_agent_message=>sc_severity-error ) )
               TO cs_reported-tool.

      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD zpru_if_adf_service~delete_tool.
    precheck_delete_tool( EXPORTING it_tool_delete_imp = it_tool_delete_imp
                          IMPORTING et_entities        = DATA(lt_entities)
                          CHANGING  cs_reported        = cs_reported
                                    cs_failed          = cs_failed ).

    IF lt_entities IS INITIAL.
      RETURN.
    ENDIF.

    zpru_cl_adf_buffer=>prep_agent_buffer( VALUE #( FOR <ls_k>
                                                    IN     lt_entities
                                                    ( agent_uuid = <ls_k>-agent_uuid ) ) ).

    zpru_cl_adf_buffer=>prep_tool_buffer( VALUE #( FOR <ls_q>
                                                   IN     lt_entities
                                                   ( agent_uuid = <ls_q>-agent_uuid
                                                     tool_uuid  = <ls_q>-tool_uuid
                                                     full_key   = abap_true ) ) ).


    LOOP AT lt_entities ASSIGNING FIELD-SYMBOL(<ls_delete>).

      ASSIGN zpru_cl_adf_buffer=>agent_buffer[ instance-agent_uuid = <ls_delete>-agent_uuid ] TO FIELD-SYMBOL(<ls_parent>).
      IF sy-subrc = 0 AND <ls_parent>-deleted = abap_true.
         " Parent deleted implies child deleted.
      ELSE.

        ASSIGN zpru_cl_adf_buffer=>tool_buffer[ instance-agent_uuid = <ls_delete>-agent_uuid
                                                instance-tool_uuid  = <ls_delete>-tool_uuid
                                                deleted             = abap_false ] TO FIELD-SYMBOL(<ls_buffer>).
        IF sy-subrc = 0.
          <ls_buffer>-deleted = abap_true.
          <ls_buffer>-changed = abap_true.
        ELSE.
          APPEND VALUE #( agent_uuid = <ls_delete>-agent_uuid
                          tool_uuid  = <ls_delete>-tool_uuid
                          delete     = abap_true
                          fail       = zpru_if_agent_frw=>cs_fail_cause-not_found )
                 TO cs_failed-tool.

          APPEND VALUE #( agent_uuid = <ls_delete>-agent_uuid
                          tool_uuid  = <ls_delete>-tool_uuid
                          delete     = abap_true
                          msg        = NEW zpru_cl_agent_util( )->zpru_if_agent_util~new_message(
                                             iv_id       = zpru_if_agent_frw=>cs_message_class-zpru_msg_execution
                                             iv_number   = `003`
                                             iv_severity = zpru_if_agent_message=>sc_severity-error ) )
                 TO cs_reported-tool.

        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD zpru_if_adf_service~clean_up.
    CLEAR zpru_cl_adf_buffer=>agent_buffer.
    CLEAR zpru_cl_adf_buffer=>tool_buffer.
  ENDMETHOD.


  METHOD zpru_if_adf_service~do_save.

    zpru_if_adf_service~determine( CHANGING cs_reported = cs_reported
                                            cs_failed   = cs_failed
                                            cs_mapped   = cs_mapped ).

    zpru_if_adf_service~validate( CHANGING cs_reported = cs_reported
                                           cs_failed   = cs_failed ).

    IF cs_failed IS NOT INITIAL.
        RETURN.
    ENDIF.


    DATA(lv_error) = db_modify( EXPORTING iv_do_commit = iv_do_commit
                                CHANGING  cs_reported = cs_reported
                                          cs_failed   = cs_failed
                                          cs_mapped   = cs_mapped ).

    IF lv_error = abap_true.
      IF iv_do_commit = abap_true.
        ROLLBACK WORK.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD zpru_if_adf_service~determine.
    " Placeholder for determination logic
  ENDMETHOD.


  METHOD zpru_if_adf_service~validate.
    " Placeholder for validation logic
  ENDMETHOD.


  METHOD db_modify.
    rv_error = abap_false.

    collect_changes( IMPORTING et_modify_agent = DATA(lt_mod_agent)
                               et_modify_tool  = DATA(lt_mod_tool)
                               et_delete_agent = DATA(lt_del_agent)
                               et_delete_tool  = DATA(lt_del_tool) ).

    cascade_deletes( CHANGING ct_delete_agent = lt_del_agent
                              ct_delete_tool  = lt_del_tool ).


   rv_error = apply_db_changes( EXPORTING it_modify_agent = lt_mod_agent
                                it_modify_tool  = lt_mod_tool
                                it_delete_agent = lt_del_agent
                                it_delete_tool  = lt_del_tool ).

  ENDMETHOD.


  METHOD cascade_deletes.
    LOOP AT ct_delete_agent ASSIGNING FIELD-SYMBOL(<ls_agent>).
      zpru_cl_adf_buffer=>prep_tool_buffer( VALUE #( ( agent_uuid = <ls_agent>-agent_uuid ) ) ).

      LOOP AT zpru_cl_adf_buffer=>tool_buffer ASSIGNING FIELD-SYMBOL(<ls_buf_tool>) WHERE instance-agent_uuid = <ls_agent>-agent_uuid.
        IF NOT line_exists( ct_delete_tool[ tool_uuid = <ls_buf_tool>-instance-tool_uuid ] ).
           APPEND <ls_buf_tool>-instance TO ct_delete_tool.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.


  METHOD collect_changes.
    LOOP AT zpru_cl_adf_buffer=>agent_buffer ASSIGNING FIELD-SYMBOL(<ls_agent>) WHERE changed = abap_true.
      IF <ls_agent>-deleted = abap_true.
        APPEND <ls_agent>-instance TO et_delete_agent.
      ELSE.
        APPEND <ls_agent>-instance TO et_modify_agent.
      ENDIF.
    ENDLOOP.

    LOOP AT zpru_cl_adf_buffer=>tool_buffer ASSIGNING FIELD-SYMBOL(<ls_tool>) WHERE changed = abap_true.
      IF <ls_tool>-deleted = abap_true.
        APPEND <ls_tool>-instance TO et_delete_tool.
      ELSE.
        APPEND <ls_tool>-instance TO et_modify_tool.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD apply_db_changes.
*    DATA(lo_db_access) = zpru_cl_adf_factory=>zpru_if_adf_factory~get_zpru_if_adf_db_access( ).
*
*    " Handle Updates/Creates
*    IF it_modify_agent IS NOT INITIAL.
*      lo_db_access->modify_agent( EXPORTING it_agent = it_modify_agent
*                                  IMPORTING ev_error = DATA(lv_err_agent) ).
*      IF lv_err_agent = abap_true. rv_error = abap_true. ENDIF.
*    ENDIF.
*
*    IF it_modify_tool IS NOT INITIAL.
*      lo_db_access->modify_agent_tool( EXPORTING it_agent_tool = it_modify_tool
*                                       IMPORTING ev_error      = DATA(lv_err_tool) ).
*      IF lv_err_tool = abap_true. rv_error = abap_true. ENDIF.
*    ENDIF.
*
*
*    " Handle Deletes
*    IF it_delete_tool IS NOT INITIAL.
*       lo_db_access->delete_agent_tool( EXPORTING it_agent_tool = it_delete_tool
*                                        IMPORTING ev_error      = DATA(lv_del_err_tool) ).
*       IF lv_del_err_tool = abap_true. rv_error = abap_true. ENDIF.
*    ENDIF.
*
*    IF it_delete_agent IS NOT INITIAL.
*       lo_db_access->delete_agent( EXPORTING it_agent  = it_delete_agent
*                                   IMPORTING ev_error  = DATA(lv_del_err_agent) ).
*       IF lv_del_err_agent = abap_true. rv_error = abap_true. ENDIF.
*    ENDIF.

  ENDMETHOD.


  METHOD fill_agent_admin_fields.
    GET TIME STAMP FIELD DATA(lv_now).

    IF iv_during_create = abap_true.
      cs_agent-instance-created_by = COND #( WHEN cs_agent-instance-created_by IS INITIAL
                                             THEN sy-uname
                                             ELSE cs_agent-instance-created_by ).
      cs_agent-instance-created_at = COND #( WHEN cs_agent-instance-created_at IS INITIAL
                                             THEN lv_now
                                             ELSE cs_agent-instance-created_at ).
    ENDIF.

    cs_agent-instance-last_changed       = lv_now.
    cs_agent-instance-changed_by         = sy-uname.
    cs_agent-instance-local_last_changed = lv_now.
  ENDMETHOD.
ENDCLASS.
