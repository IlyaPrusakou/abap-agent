CLASS zpru_cl_axc_service DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zpru_if_axc_service.

  PROTECTED SECTION.
    METHODS precheck_create
      IMPORTING it_head_create_imp TYPE zpru_if_axc_service=>tt_head_create_imp
      EXPORTING et_entities        TYPE zpru_if_axc_service=>tt_head_create_imp
      CHANGING  cs_reported        TYPE zpru_if_axc_service=>ts_reported
                cs_failed          TYPE zpru_if_axc_service=>ts_failed.

    METHODS precheck_cba_query
      IMPORTING it_axc_query_imp TYPE zpru_if_axc_service=>tt_query_create_imp
      EXPORTING et_entities      TYPE zpru_if_axc_service=>tt_query_create_imp
      CHANGING  cs_reported      TYPE zpru_if_axc_service=>ts_reported
                cs_failed        TYPE zpru_if_axc_service=>ts_failed.

    METHODS precheck_read
      IMPORTING it_head_read_k TYPE zpru_if_axc_service=>tt_head_read_k
      EXPORTING et_entities    TYPE zpru_if_axc_service=>tt_head_read_k
      CHANGING  cs_reported    TYPE zpru_if_axc_service=>ts_reported
                cs_failed      TYPE zpru_if_axc_service=>ts_failed.

    METHODS precheck_rba_query
      IMPORTING it_rba_query_k TYPE zpru_if_axc_service=>tt_rba_query_k
      EXPORTING et_entities    TYPE zpru_if_axc_service=>tt_rba_query_k
      CHANGING  cs_reported    TYPE zpru_if_axc_service=>ts_reported
                cs_failed      TYPE zpru_if_axc_service=>ts_failed.

    METHODS precheck_cba_step
      IMPORTING it_axc_step_imp TYPE zpru_if_axc_service=>tt_step_create_imp
      EXPORTING et_entities      TYPE zpru_if_axc_service=>tt_step_create_imp
      CHANGING  cs_reported      TYPE zpru_if_axc_service=>ts_reported
                cs_failed        TYPE zpru_if_axc_service=>ts_failed.

    METHODS precheck_rba_step
      IMPORTING it_rba_step_k TYPE zpru_if_axc_service=>tt_rba_step_k
      EXPORTING et_entities    TYPE zpru_if_axc_service=>tt_rba_step_k
      CHANGING  cs_reported    TYPE zpru_if_axc_service=>ts_reported
                cs_failed      TYPE zpru_if_axc_service=>ts_failed.

    METHODS precheck_read_step
      IMPORTING it_step_read_k TYPE zpru_if_axc_service=>tt_step_read_k
      EXPORTING et_entities    TYPE zpru_if_axc_service=>tt_step_read_k
      CHANGING  cs_reported    TYPE zpru_if_axc_service=>ts_reported
                cs_failed      TYPE zpru_if_axc_service=>ts_failed.

    METHODS precheck_update_step
      IMPORTING it_step_update_imp TYPE zpru_if_axc_service=>tt_step_update_imp
      EXPORTING et_entities       TYPE zpru_if_axc_service=>tt_step_update_imp
      CHANGING  cs_reported       TYPE zpru_if_axc_service=>ts_reported
                cs_failed         TYPE zpru_if_axc_service=>ts_failed.

    METHODS precheck_delete_step
      IMPORTING it_step_delete_imp TYPE zpru_if_axc_service=>tt_step_delete_imp
      EXPORTING et_entities       TYPE zpru_if_axc_service=>tt_step_delete_imp
      CHANGING  cs_reported       TYPE zpru_if_axc_service=>ts_reported
                cs_failed         TYPE zpru_if_axc_service=>ts_failed.

    METHODS fill_head_admin_fields
      IMPORTING iv_during_create TYPE abap_boolean DEFAULT abap_false
      CHANGING  cs_header        TYPE zpru_cl_axc_buffer=>ts_header.

    METHODS db_modify
      IMPORTING iv_do_commit TYPE abap_boolean
      CHANGING  cs_reported   TYPE zpru_if_axc_service=>ts_reported
                cs_failed     TYPE zpru_if_axc_service=>ts_failed
                cs_mapped     TYPE zpru_if_axc_service=>ts_mapped
      RETURNING VALUE(rv_error) TYPE abap_boolean.
ENDCLASS.


CLASS zpru_cl_axc_service IMPLEMENTATION.
  METHOD fill_head_admin_fields.
    GET TIME STAMP FIELD DATA(lv_now).

    IF iv_during_create = abap_true.
      cs_header-instance-created_by = COND #( WHEN cs_header-instance-created_by IS INITIAL
                                              THEN sy-uname
                                              ELSE cs_header-instance-created_by ).

      cs_header-instance-created_at = COND #( WHEN cs_header-instance-created_at IS INITIAL
                                              THEN lv_now
                                              ELSE cs_header-instance-created_at ).
    ENDIF.

    cs_header-instance-changed_by   = COND #( WHEN cs_header-instance-changed_by IS INITIAL
                                              THEN sy-uname
                                              ELSE cs_header-instance-changed_by ).

    cs_header-instance-last_changed = COND #( WHEN cs_header-instance-last_changed IS INITIAL
                                              THEN lv_now
                                              ELSE cs_header-instance-last_changed ).
  ENDMETHOD.

  METHOD db_modify.
    rv_error = abap_false.

    " Prepare tables for modify/delete operations
    DATA: lt_modify_head  TYPE TABLE OF zpru_axc_head WITH EMPTY KEY,
          lt_modify_query TYPE TABLE OF zpru_axc_query WITH EMPTY KEY,
          lt_modify_step  TYPE TABLE OF zpru_axc_step WITH EMPTY KEY,

          lt_delete_head  TYPE TABLE OF zpru_axc_head WITH EMPTY KEY,
          lt_delete_query TYPE TABLE OF zpru_axc_query WITH EMPTY KEY,
          lt_delete_step  TYPE TABLE OF zpru_axc_step WITH EMPTY KEY.

    " Collect deletes / modifies from buffers
    LOOP AT zpru_cl_axc_buffer=>step_buffer ASSIGNING FIELD-SYMBOL(<ls_s>) WHERE changed = abap_true.
      IF <ls_s>-deleted = abap_true.
        APPEND <ls_s>-instance TO lt_delete_step.
      ELSE.
        APPEND <ls_s>-instance TO lt_modify_step.
      ENDIF.
    ENDLOOP.

    LOOP AT zpru_cl_axc_buffer=>query_buffer ASSIGNING FIELD-SYMBOL(<ls_q>) WHERE changed = abap_true.
      IF <ls_q>-deleted = abap_true.
        APPEND <ls_q>-instance TO lt_delete_query.
      ELSE.
        APPEND <ls_q>-instance TO lt_modify_query.
      ENDIF.
    ENDLOOP.

    LOOP AT zpru_cl_axc_buffer=>header_buffer ASSIGNING FIELD-SYMBOL(<ls_h>) WHERE changed = abap_true.
      IF <ls_h>-deleted = abap_true.
        APPEND <ls_h>-instance TO lt_delete_head.
      ELSE.
        APPEND <ls_h>-instance TO lt_modify_head.
      ENDIF.
    ENDLOOP.

    " Cascade: if headers deleted, fetch their queries and steps
    IF lt_delete_head IS NOT INITIAL.
      DATA(lt_head_keys) = VALUE #( FOR <ls> IN lt_delete_head ( run_uuid = <ls>-run_uuid ) ).

      SELECT * FROM zpru_axc_query
        FOR ALL ENTRIES IN @lt_head_keys
        WHERE run_uuid = @lt_head_keys-run_uuid
        INTO TABLE @DATA(lt_q_from_db).

      IF sy-subrc = 0.
        LOOP AT lt_q_from_db ASSIGNING FIELD-SYMBOL(<ls_qdb>).
          IF NOT line_exists( lt_delete_query[ query_uuid = <ls_qdb>-query_uuid ] ).
            APPEND <ls_qdb> TO lt_delete_query.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.

    " Cascade: if queries deleted, fetch their steps
    IF lt_delete_query IS NOT INITIAL.
      DATA(lt_query_keys) = VALUE #( FOR <ls> IN lt_delete_query ( query_uuid = <ls>-query_uuid ) ).

      SELECT * FROM zpru_axc_step
        FOR ALL ENTRIES IN @lt_query_keys
        WHERE query_uuid = @lt_query_keys-query_uuid
        INTO TABLE @DATA(lt_s_from_db).

      IF sy-subrc = 0.
        LOOP AT lt_s_from_db ASSIGNING FIELD-SYMBOL(<ls_sdb>).
          IF NOT line_exists( lt_delete_step[ step_uuid = <ls_sdb>-step_uuid ] ).
            APPEND <ls_sdb> TO lt_delete_step.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.

    " Perform deletes first: steps -> queries -> headers
    IF lt_delete_step IS NOT INITIAL.
      DELETE zpru_axc_step FROM TABLE lt_delete_step.
      IF sy-subrc <> 0.
        rv_error = abap_true.
      ENDIF.
    ENDIF.

    IF rv_error = abap_false AND lt_delete_query IS NOT INITIAL.
      DELETE zpru_axc_query FROM TABLE lt_delete_query.
      IF sy-subrc <> 0.
        rv_error = abap_true.
      ENDIF.
    ENDIF.

    IF rv_error = abap_false AND lt_delete_head IS NOT INITIAL.
      DELETE zpru_axc_head FROM TABLE lt_delete_head.
      IF sy-subrc <> 0.
        rv_error = abap_true.
      ENDIF.
    ENDIF.

    " If any delete failed, return error
    IF rv_error = abap_true.
      RETURN.
    ENDIF.

    " Perform modifies/inserts: head -> query -> step
    IF lt_modify_head IS NOT INITIAL.
      MODIFY zpru_axc_head FROM TABLE lt_modify_head.
      IF sy-subrc <> 0.
        rv_error = abap_true.
        RETURN.
      ENDIF.
    ENDIF.

    IF lt_modify_query IS NOT INITIAL.
      MODIFY zpru_axc_query FROM TABLE lt_modify_query.
      IF sy-subrc <> 0.
        rv_error = abap_true.
        RETURN.
      ENDIF.
    ENDIF.

    IF lt_modify_step IS NOT INITIAL.
      MODIFY zpru_axc_step FROM TABLE lt_modify_step.
      IF sy-subrc <> 0.
        rv_error = abap_true.
        RETURN.
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD zpru_if_axc_service~cba_step.
    IF it_axc_step_imp IS INITIAL.
      RETURN.
    ENDIF.

    precheck_cba_step( EXPORTING it_axc_step_imp = it_axc_step_imp
                        IMPORTING et_entities      = DATA(lt_entities)
                        CHANGING  cs_reported      = cs_reported
                                  cs_failed        = cs_failed ).

    IF lt_entities IS INITIAL.
      RETURN.
    ENDIF.

    zpru_cl_axc_buffer=>prep_step_buffer( VALUE #( FOR <ls_k>
                                                  IN     lt_entities
                                                  ( query_uuid = <ls_k>-query_uuid
                                                    step_uuid  = <ls_k>-step_uuid
                                                    full_key   = COND #( WHEN <ls_k>-step_uuid IS INITIAL
                                                                         THEN abap_false
                                                                         ELSE abap_true ) ) ) ).

    LOOP AT lt_entities ASSIGNING FIELD-SYMBOL(<ls_create>).

      ASSIGN zpru_cl_axc_buffer=>step_buffer[ instance-query_uuid = <ls_create>-query_uuid
                                              instance-step_uuid  = <ls_create>-step_uuid
                                              deleted             = abap_false ] TO FIELD-SYMBOL(<ls_buffer>).

      IF    NOT line_exists( zpru_cl_axc_buffer=>step_buffer[ instance-query_uuid = <ls_create>-query_uuid
                                                               instance-step_uuid  = <ls_create>-step_uuid ] )
         OR     line_exists( zpru_cl_axc_buffer=>step_buffer[ instance-query_uuid = <ls_create>-query_uuid
                                                               instance-step_uuid  = <ls_create>-step_uuid
                                                               deleted             = abap_true ] ).

        DELETE zpru_cl_axc_buffer=>step_buffer
               WHERE     instance-query_uuid = VALUE #( zpru_cl_axc_buffer=>step_buffer[
                                                          instance-query_uuid = <ls_create>-query_uuid ]-instance-query_uuid OPTIONAL )
                     AND instance-step_uuid  = VALUE #( zpru_cl_axc_buffer=>step_buffer[
                                                          instance-query_uuid = <ls_create>-query_uuid ]-instance-step_uuid OPTIONAL )
                     AND deleted             = abap_true.

        APPEND VALUE #(
            instance-query_uuid    = <ls_create>-query_uuid
            instance-step_uuid     = <ls_create>-step_uuid
            instance-run_uuid      = COND #( WHEN <ls_create>-control-run_uuid = abap_true
                                              THEN <ls_create>-run_uuid )
            instance-tool_uuid     = COND #( WHEN <ls_create>-control-tool_uuid = abap_true
                                              THEN <ls_create>-tool_uuid )
            instance-execution_seq = COND #( WHEN <ls_create>-control-execution_seq = abap_true
                                              THEN <ls_create>-execution_seq )
            instance-start_timestamp = COND #( WHEN <ls_create>-control-start_timestamp = abap_true
                                                THEN <ls_create>-start_timestamp )
            instance-end_timestamp = COND #( WHEN <ls_create>-control-end_timestamp = abap_true
                                              THEN <ls_create>-end_timestamp )
            instance-input_prompt  = COND #( WHEN <ls_create>-control-input_prompt = abap_true
                                              THEN <ls_create>-input_prompt )
            instance-output_prompt = COND #( WHEN <ls_create>-control-output_prompt = abap_true
                                              THEN <ls_create>-output_prompt )
            changed                = abap_true
            deleted                = abap_false ) TO zpru_cl_axc_buffer=>step_buffer ASSIGNING FIELD-SYMBOL(<ls_just_added>).

        INSERT VALUE #( query_uuid = <ls_create>-query_uuid
                        step_uuid  = <ls_create>-step_uuid ) INTO TABLE cs_mapped-step.

        APPEND VALUE #( msg       = NEW zpru_cl_agent_util( )->zpru_if_agent_util~new_message(
                    iv_id       = zpru_if_agent_frw=>cs_message_class-zpru_msg_execution
                    iv_number   = `001`
                    iv_severity = zpru_if_agent_message=>sc_severity-success )
            run_uuid  = <ls_create>-run_uuid
            query_uuid = <ls_create>-query_uuid
            step_uuid = <ls_create>-step_uuid ) TO cs_reported-step.

      ELSE.

         APPEND VALUE #( run_uuid   = <ls_create>-run_uuid
               query_uuid  = <ls_create>-query_uuid
               step_uuid   = <ls_create>-step_uuid
               create      = abap_true
               fail        = zpru_if_agent_frw=>cs_fail_cause-unspecific )
           TO cs_failed-step.

         APPEND VALUE #( run_uuid   = <ls_create>-run_uuid
               query_uuid  = <ls_create>-query_uuid
               step_uuid   = <ls_create>-step_uuid
               create      = abap_true
               msg         = NEW zpru_cl_agent_util( )->zpru_if_agent_util~new_message(
                   iv_id       = zpru_if_agent_frw=>cs_message_class-zpru_msg_execution
                   iv_number   = `002`
                   iv_severity = zpru_if_agent_message=>sc_severity-error ) )
           TO cs_reported-step.

      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD zpru_if_axc_service~rba_step.
    CLEAR et_axc_step.

    IF it_rba_step_k IS INITIAL.
      RETURN.
    ENDIF.

    precheck_rba_step( EXPORTING it_rba_step_k = it_rba_step_k
                       IMPORTING et_entities    = DATA(lt_entities)
                       CHANGING  cs_reported    = cs_reported
                                 cs_failed      = cs_failed ).

    IF lt_entities IS INITIAL.
      RETURN.
    ENDIF.

    zpru_cl_axc_buffer=>prep_step_buffer( VALUE #( FOR <ls_k> IN lt_entities
                                                  ( query_uuid = <ls_k>-query_uuid
                                                    step_uuid  = ''
                                                    full_key   = abap_false ) ) ).

    LOOP AT lt_entities ASSIGNING FIELD-SYMBOL(<ls_h>).
      LOOP AT zpru_cl_axc_buffer=>step_buffer ASSIGNING FIELD-SYMBOL(<ls_s_buf>)
           WHERE instance-query_uuid = <ls_h>-query_uuid
             AND deleted = abap_false.

        DATA(ls_out) = VALUE zpru_axc_step( ).
        ls_out-step_uuid = <ls_s_buf>-instance-step_uuid.
        ls_out-query_uuid = <ls_s_buf>-instance-query_uuid.
        ls_out-run_uuid = COND #( WHEN <ls_h>-control-run_uuid = abap_true
                   THEN <ls_s_buf>-instance-run_uuid ).
        ls_out-tool_uuid = COND #( WHEN <ls_h>-control-tool_uuid = abap_true
                   THEN <ls_s_buf>-instance-tool_uuid ).
        ls_out-execution_seq = COND #( WHEN <ls_h>-control-execution_seq = abap_true
                   THEN <ls_s_buf>-instance-execution_seq ).
        ls_out-start_timestamp = COND #( WHEN <ls_h>-control-start_timestamp = abap_true
                  THEN <ls_s_buf>-instance-start_timestamp ).
        ls_out-end_timestamp = COND #( WHEN <ls_h>-control-end_timestamp = abap_true
                THEN <ls_s_buf>-instance-end_timestamp ).
        ls_out-input_prompt = COND #( WHEN <ls_h>-control-input_prompt = abap_true
                     THEN <ls_s_buf>-instance-input_prompt ).
        ls_out-output_prompt = COND #( WHEN <ls_h>-control-output_prompt = abap_true
                  THEN <ls_s_buf>-instance-output_prompt ).

        APPEND ls_out TO et_axc_step.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD zpru_if_axc_service~read_step.
    CLEAR et_axc_step.

    IF it_step_read_k IS INITIAL.
      RETURN.
    ENDIF.

    " Use precheck helper to validate inputs and populate control flags
    precheck_read_step( EXPORTING it_step_read_k = it_step_read_k
                        IMPORTING et_entities    = DATA(lt_entities)
                        CHANGING  cs_reported    = cs_reported
                                  cs_failed      = cs_failed ).

    IF lt_entities IS INITIAL.
      RETURN.
    ENDIF.

    " Load exact steps into buffer
    zpru_cl_axc_buffer=>prep_step_buffer( VALUE #( FOR <ls_k> IN lt_entities
                                                  ( query_uuid = <ls_k>-query_uuid
                                                    step_uuid  = <ls_k>-step_uuid
                                                    full_key   = abap_true ) ) ).

    LOOP AT lt_entities ASSIGNING FIELD-SYMBOL(<ls_ent>).
      ASSIGN zpru_cl_axc_buffer=>step_buffer[ instance-query_uuid = <ls_ent>-query_uuid
                                              instance-step_uuid  = <ls_ent>-step_uuid
                                              deleted             = abap_false ] TO FIELD-SYMBOL(<ls_buf>).
      IF sy-subrc = 0.
        DATA(ls_out) = VALUE zpru_axc_step( ).
        ls_out-step_uuid = <ls_buf>-instance-step_uuid.
        ls_out-query_uuid = <ls_buf>-instance-query_uuid.
        ls_out-run_uuid = COND #( WHEN <ls_ent>-control-run_uuid = abap_true
                                     THEN <ls_buf>-instance-run_uuid ).
        ls_out-tool_uuid = COND #( WHEN <ls_ent>-control-tool_uuid = abap_true
                                     THEN <ls_buf>-instance-tool_uuid ).
        ls_out-execution_seq = COND #( WHEN <ls_ent>-control-execution_seq = abap_true
                                           THEN <ls_buf>-instance-execution_seq ).
        ls_out-start_timestamp = COND #( WHEN <ls_ent>-control-start_timestamp = abap_true
                                          THEN <ls_buf>-instance-start_timestamp ).
        ls_out-end_timestamp = COND #( WHEN <ls_ent>-control-end_timestamp = abap_true
                                        THEN <ls_buf>-instance-end_timestamp ).
        ls_out-input_prompt = COND #( WHEN <ls_ent>-control-input_prompt = abap_true
                                       THEN <ls_buf>-instance-input_prompt ).
        ls_out-output_prompt = COND #( WHEN <ls_ent>-control-output_prompt = abap_true
                                          THEN <ls_buf>-instance-output_prompt ).

        APPEND ls_out TO et_axc_step.
      ELSE.
        APPEND VALUE #( run_uuid   = <ls_ent>-run_uuid
                        query_uuid = <ls_ent>-query_uuid
                        step_uuid  = <ls_ent>-step_uuid
                        fail       = zpru_if_agent_frw=>cs_fail_cause-not_found )
               TO cs_failed-step.

        APPEND VALUE #( run_uuid   = <ls_ent>-run_uuid
                        query_uuid = <ls_ent>-query_uuid
                        step_uuid  = <ls_ent>-step_uuid
                        msg        = NEW zpru_cl_agent_util( )->zpru_if_agent_util~new_message(
                                    iv_id       = zpru_if_agent_frw=>cs_message_class-zpru_msg_execution
                                    iv_number   = `003`
                                    iv_severity = zpru_if_agent_message=>sc_severity-error ) )
               TO cs_reported-step.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD zpru_if_axc_service~update_step.
    IF it_step_update_imp IS INITIAL.
      RETURN.
    ENDIF.

    " Precheck and populate control flags
    precheck_update_step( EXPORTING it_step_update_imp = it_step_update_imp
                          IMPORTING et_entities         = DATA(lt_entities)
                          CHANGING  cs_reported         = cs_reported
                                    cs_failed           = cs_failed ).

    IF lt_entities IS INITIAL.
      RETURN.
    ENDIF.

    zpru_cl_axc_buffer=>prep_step_buffer( VALUE #( FOR <ls_k> IN lt_entities
                                                  ( query_uuid = <ls_k>-query_uuid
                                                    step_uuid  = <ls_k>-step_uuid
                                                    full_key   = abap_true ) ) ).

    LOOP AT lt_entities ASSIGNING FIELD-SYMBOL(<ls_update>).

      ASSIGN zpru_cl_axc_buffer=>step_buffer[ instance-query_uuid = <ls_update>-query_uuid
                                              instance-step_uuid  = <ls_update>-step_uuid
                                              deleted             = abap_false ] TO FIELD-SYMBOL(<ls_buf>).

      IF sy-subrc = 0.
        <ls_buf>-instance-run_uuid = COND #( WHEN <ls_update>-control-run_uuid = abap_true
                                            THEN <ls_update>-run_uuid
                                            ELSE <ls_buf>-instance-run_uuid ).
        <ls_buf>-instance-tool_uuid = COND #( WHEN <ls_update>-control-tool_uuid = abap_true
                                              THEN <ls_update>-tool_uuid
                                              ELSE <ls_buf>-instance-tool_uuid ).
        <ls_buf>-instance-execution_seq = COND #( WHEN <ls_update>-control-execution_seq = abap_true
                                                  THEN <ls_update>-execution_seq
                                                  ELSE <ls_buf>-instance-execution_seq ).
        <ls_buf>-instance-start_timestamp = COND #( WHEN <ls_update>-control-start_timestamp = abap_true
                                                     THEN <ls_update>-start_timestamp
                                                     ELSE <ls_buf>-instance-start_timestamp ).
        <ls_buf>-instance-end_timestamp = COND #( WHEN <ls_update>-control-end_timestamp = abap_true
                                                   THEN <ls_update>-end_timestamp
                                                   ELSE <ls_buf>-instance-end_timestamp ).
        <ls_buf>-instance-input_prompt = COND #( WHEN <ls_update>-control-input_prompt = abap_true
                                                 THEN <ls_update>-input_prompt
                                                 ELSE <ls_buf>-instance-input_prompt ).
        <ls_buf>-instance-output_prompt = COND #( WHEN <ls_update>-control-output_prompt = abap_true
                                                  THEN <ls_update>-output_prompt
                                                  ELSE <ls_buf>-instance-output_prompt ).

        <ls_buf>-changed = abap_true.
        <ls_buf>-deleted = abap_false.

      ELSE.
        APPEND VALUE #( run_uuid   = <ls_update>-run_uuid
                        query_uuid = <ls_update>-query_uuid
                        step_uuid  = <ls_update>-step_uuid
                        update     = abap_true
                        fail       = zpru_if_agent_frw=>cs_fail_cause-not_found )
               TO cs_failed-step.

        APPEND VALUE #( run_uuid   = <ls_update>-run_uuid
                        query_uuid = <ls_update>-query_uuid
                        step_uuid  = <ls_update>-step_uuid
                        update     = abap_true
                        msg        = NEW zpru_cl_agent_util( )->zpru_if_agent_util~new_message(
                                    iv_id       = zpru_if_agent_frw=>cs_message_class-zpru_msg_execution
                                    iv_number   = `003`
                                    iv_severity = zpru_if_agent_message=>sc_severity-error ) )
               TO cs_reported-step.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD zpru_if_axc_service~delete_step.
    IF it_step_delete_imp IS INITIAL.
      RETURN.
    ENDIF.

    " Precheck and populate entities
    precheck_delete_step( EXPORTING it_step_delete_imp = it_step_delete_imp
                          IMPORTING et_entities         = DATA(lt_entities)
                          CHANGING  cs_reported         = cs_reported
                                    cs_failed           = cs_failed ).

    IF lt_entities IS INITIAL.
      RETURN.
    ENDIF.

    zpru_cl_axc_buffer=>prep_step_buffer( VALUE #( FOR <ls_k> IN lt_entities
                                                  ( query_uuid = <ls_k>-query_uuid
                                                    step_uuid  = <ls_k>-step_uuid
                                                    full_key   = abap_true ) ) ).

    LOOP AT lt_entities ASSIGNING FIELD-SYMBOL(<ls_delete>).

      ASSIGN zpru_cl_axc_buffer=>step_buffer[ instance-query_uuid = <ls_delete>-query_uuid
                                              instance-step_uuid  = <ls_delete>-step_uuid
                                              deleted             = abap_false ] TO FIELD-SYMBOL(<ls_buf>).
      IF sy-subrc = 0.
        <ls_buf>-deleted = abap_true.
        <ls_buf>-changed = abap_true.

        INSERT VALUE #( query_uuid = <ls_delete>-query_uuid
                        step_uuid  = <ls_delete>-step_uuid ) INTO TABLE cs_mapped-step.

        APPEND VALUE #( msg      = NEW zpru_cl_agent_util( )->zpru_if_agent_util~new_message(
                                           iv_id       = zpru_if_agent_frw=>cs_message_class-zpru_msg_execution
                                           iv_number   = `005`
                                           iv_severity = zpru_if_agent_message=>sc_severity-success )
                        run_uuid  = <ls_delete>-run_uuid
                        query_uuid = <ls_delete>-query_uuid
                        step_uuid = <ls_delete>-step_uuid ) TO cs_reported-step.

      ELSE.
        APPEND VALUE #( run_uuid   = <ls_delete>-run_uuid
                        query_uuid = <ls_delete>-query_uuid
                        step_uuid  = <ls_delete>-step_uuid
                        delete     = abap_true
                        fail       = zpru_if_agent_frw=>cs_fail_cause-not_found )
               TO cs_failed-step.

        APPEND VALUE #( run_uuid   = <ls_delete>-run_uuid
                        query_uuid = <ls_delete>-query_uuid
                        step_uuid  = <ls_delete>-step_uuid
                        delete     = abap_true
                        msg        = NEW zpru_cl_agent_util( )->zpru_if_agent_util~new_message(
                                    iv_id       = zpru_if_agent_frw=>cs_message_class-zpru_msg_execution
                                    iv_number   = `003`
                                    iv_severity = zpru_if_agent_message=>sc_severity-error ) )
               TO cs_reported-step.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD zpru_if_axc_service~read_agent_execution.
    DATA lo_axc_database_access TYPE REF TO zpru_if_axc_database_access.

    CLEAR: et_axc_head,
           et_axc_query,
           et_axc_step.

    IF it_axc_head_k IS INITIAL.
      RETURN.
    ENDIF.

    lo_axc_database_access = NEW zpru_cl_axc_database_access( ).

    et_axc_head = lo_axc_database_access->select_head( it_axc_head_k ).

    IF et_axc_query IS SUPPLIED.
      et_axc_query = lo_axc_database_access->select_query_by_head( it_axc_head_k ).
    ENDIF.

    IF et_axc_step IS SUPPLIED.
      et_axc_step = lo_axc_database_access->select_step_by_query( VALUE #( FOR <ls_q_k> IN et_axc_query
                                                                           ( query_uuid = <ls_q_k>-query_uuid  ) ) ).
    ENDIF.
  ENDMETHOD.

  METHOD zpru_if_axc_service~determine.
    " Placeholder for business logic that determines what to persist.
    " Currently a no-op; callers populate buffers via CBA/UPDATE/DELETE flows.
    IF cs_mapped IS INITIAL.
      " leave as-is
    ENDIF.
  ENDMETHOD.

  METHOD zpru_if_axc_service~validate.
    " Placeholder for validation logic. Add domain-specific checks here.
    " For now, we keep this minimal: if there are existing failures, leave them.
    IF cs_failed-header IS NOT INITIAL OR cs_failed-query IS NOT INITIAL OR cs_failed-step IS NOT INITIAL.
      " existing failures already present
    ENDIF.
  ENDMETHOD.

  METHOD zpru_if_axc_service~clean_up.
    " Clear in-memory buffers and mapped entries after save/rollback.
    CLEAR cs_mapped.
    CLEAR: zpru_cl_axc_buffer=>header_buffer,
           zpru_cl_axc_buffer=>query_buffer,
           zpru_cl_axc_buffer=>step_buffer.
  ENDMETHOD.

  METHOD zpru_if_axc_service~do_save.
    DATA(lv_err) = abap_false.

    " Run determination step
    me->determine( CHANGING cs_reported = cs_reported
                             cs_failed   = cs_failed
                             cs_mapped   = cs_mapped ).

    " Run validation
    me->validate( CHANGING cs_reported = cs_reported
                            cs_failed   = cs_failed ).

    " If validation produced failures, skip DB modification
    IF cs_failed-header IS NOT INITIAL OR cs_failed-query IS NOT INITIAL OR cs_failed-step IS NOT INITIAL.
      RETURN.
    ENDIF.

    " Persist buffers to DB (returns abap_true on error)
    lv_err = me->db_modify( EXPORTING iv_do_commit = iv_do_commit
                CHANGING  cs_reported   = cs_reported
                      cs_failed     = cs_failed
                      cs_mapped     = cs_mapped ).

    IF lv_err = abap_true.
      IF iv_do_commit = abap_true.
        ROLLBACK WORK.
      ENDIF.
      " leave failure info in cs_failed
      me->clean_up( CHANGING cs_mapped = cs_mapped ).
      RETURN.
    ENDIF.

    IF iv_do_commit = abap_true.
      COMMIT WORK AND WAIT.
    ENDIF.

    me->clean_up( CHANGING cs_mapped = cs_mapped ).
  ENDMETHOD.

  METHOD zpru_if_axc_service~get_actual_query.
    DATA lo_axc_database_access TYPE REF TO zpru_if_axc_database_access.

    IF it_axc_head_k IS INITIAL.
      RETURN.
    ENDIF.

    lo_axc_database_access = NEW zpru_cl_axc_database_access( ).
    DATA(lt_query_candidates) = lo_axc_database_access->select_query_by_head( it_axc_head_k ).

    LOOP AT it_axc_head_k ASSIGNING FIELD-SYMBOL(<ls_axc_head_k>).

      DATA(lt_query_copy) = lt_query_candidates.
      DELETE lt_query_copy WHERE run_uuid <> <ls_axc_head_k>-run_uuid.
      DELETE lt_query_copy WHERE execution_status <> zpru_if_agent_frw=>cs_execution_status-new.

      SORT lt_query_copy BY start_timestamp ASCENDING.

      APPEND INITIAL LINE TO rt_axc_head_query_link ASSIGNING FIELD-SYMBOL(<ls_axc_head_query_link>).
      <ls_axc_head_query_link>-run_uuid   = <ls_axc_head_k>-run_uuid.
      <ls_axc_head_query_link>-query_uuid = VALUE #( lt_query_copy[ 1 ]-query_uuid OPTIONAL ).

    ENDLOOP.
  ENDMETHOD.

  METHOD zpru_if_axc_service~cba_query.
    IF it_axc_query_imp IS INITIAL.
      RETURN.
    ENDIF.

    precheck_cba_query( EXPORTING it_axc_query_imp = it_axc_query_imp
                        IMPORTING et_entities      = DATA(lt_entities)
                        CHANGING  cs_reported      = cs_reported
                                  cs_failed        = cs_failed ).

    IF lt_entities IS INITIAL.
      RETURN.
    ENDIF.

    zpru_cl_axc_buffer=>prep_query_buffer( VALUE #( FOR <ls_k>
                                                   IN     lt_entities
                                                   ( run_uuid   = <ls_k>-run_uuid
                                                     query_uuid = <ls_k>-query_uuid
                                                     full_key   = COND #( WHEN <ls_k>-query_uuid IS INITIAL
                                                                          THEN abap_false
                                                                          ELSE abap_true ) ) ) ).

    LOOP AT lt_entities ASSIGNING FIELD-SYMBOL(<ls_create>).

      ASSIGN zpru_cl_axc_buffer=>query_buffer[ instance-run_uuid   = <ls_create>-run_uuid
                                               instance-query_uuid = <ls_create>-query_uuid
                                               deleted             = abap_false ] TO FIELD-SYMBOL(<ls_buffer>).

      IF    NOT line_exists( zpru_cl_axc_buffer=>query_buffer[ instance-run_uuid   = <ls_create>-run_uuid
                                                               instance-query_uuid = <ls_create>-query_uuid ] )
         OR     line_exists( zpru_cl_axc_buffer=>query_buffer[ instance-run_uuid   = <ls_create>-run_uuid
                                                               instance-query_uuid = <ls_create>-query_uuid
                                                               deleted             = abap_true ] ).

        DELETE zpru_cl_axc_buffer=>query_buffer
               WHERE     instance-run_uuid   = VALUE #( zpru_cl_axc_buffer=>query_buffer[
                                                          instance-run_uuid   = <ls_create>-run_uuid
                                                          instance-query_uuid = <ls_create>-query_uuid ]-instance-run_uuid OPTIONAL )
                     AND instance-query_uuid = VALUE #( zpru_cl_axc_buffer=>query_buffer[
                                                          instance-run_uuid   = <ls_create>-run_uuid
                                                          instance-query_uuid = <ls_create>-query-query_uuid ]-instance-query_uuid OPTIONAL )
                     AND deleted             = abap_true.

        APPEND VALUE #(
            instance-run_uuid        = <ls_create>-run_uuid
            instance-query_uuid      = <ls_create>-query_uuid
            instance-language        = COND #( WHEN <ls_create>-control-language = abap_true
                                               THEN <ls_create>-language )
            instance-execution_status = COND #( WHEN <ls_create>-control-execution_status = abap_true
                                               THEN <ls_create>-execution_status )
            instance-start_timestamp = COND #( WHEN <ls_create>-control-start_timestamp = abap_true
                                               THEN <ls_create>-start_timestamp )
            instance-end_timestamp   = COND #( WHEN <ls_create>-control-end_timestamp = abap_true
                                               THEN <ls_create>-end_timestamp )
            instance-input_prompt    = COND #( WHEN <ls_create>-control-input_prompt = abap_true
                                               THEN <ls_create>-input_prompt )
            instance-decision_log    = COND #( WHEN <ls_create>-control-decision_log = abap_true
                                               THEN <ls_create>-decision_log )
            instance-output_response = COND #( WHEN <ls_create>-control-output_response = abap_true
                                               THEN <ls_create>-output_response )
            changed                  = abap_true
            deleted                  = abap_false ) TO zpru_cl_axc_buffer=>query_buffer ASSIGNING FIELD-SYMBOL(<ls_just_added>).

        GET TIME STAMP FIELD DATA(lv_now).
        <ls_just_added>-instance-start_timestamp = COND #( WHEN <ls_just_added>-instance-start_timestamp IS INITIAL
                                                          THEN lv_now
                                                          ELSE <ls_just_added>-instance-start_timestamp ).

        INSERT VALUE #( run_uuid = <ls_create>-run_uuid
            query_uuid = <ls_create>-query_uuid ) INTO TABLE cs_mapped-query.

        APPEND VALUE #( msg       = NEW zpru_cl_agent_util( )->zpru_if_agent_util~new_message(
                    iv_id       = zpru_if_agent_frw=>cs_message_class-zpru_msg_execution
                    iv_number   = `001`
                    iv_severity = zpru_if_agent_message=>sc_severity-success )
            run_uuid  = <ls_create>-run_uuid
            query_uuid = <ls_create>-query_uuid ) TO cs_reported-query.

      ELSE.

         APPEND VALUE #( run_uuid  = <ls_create>-run_uuid
               query_uuid = <ls_create>-query_uuid
               create    = abap_true
               fail      = zpru_if_agent_frw=>cs_fail_cause-unspecific )
           TO cs_failed-query.

         APPEND VALUE #( run_uuid   = <ls_create>-run_uuid
               query_uuid  = <ls_create>-query_uuid
               create      = abap_true
               msg         = NEW zpru_cl_agent_util( )->zpru_if_agent_util~new_message(
                   iv_id       = zpru_if_agent_frw=>cs_message_class-zpru_msg_execution
                   iv_number   = `002`
                   iv_severity = zpru_if_agent_message=>sc_severity-error ) )
           TO cs_reported-query.

      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD zpru_if_axc_service~delete_header.
    IF it_head_delete_imp IS INITIAL.
      RETURN.
    ENDIF.

    zpru_cl_axc_buffer=>prep_header_buffer( VALUE #( FOR <ls_k>
                                                     IN     it_head_delete_imp
                                                     ( run_uuid = <ls_k>-run_uuid ) ) ).

    LOOP AT it_head_delete_imp ASSIGNING FIELD-SYMBOL(<ls_delete>).

      ASSIGN zpru_cl_axc_buffer=>header_buffer[ instance-run_uuid = <ls_delete>-run_uuid
                                                deleted           = abap_false ] TO FIELD-SYMBOL(<ls_buffer>).
      IF sy-subrc = 0.
        <ls_buffer>-deleted = abap_true.
        <ls_buffer>-changed = abap_true.

        fill_head_admin_fields( EXPORTING iv_during_create = abap_false
                                CHANGING  cs_header        = <ls_buffer> ).

        INSERT VALUE #( run_uuid = <ls_delete>-run_uuid ) INTO TABLE cs_mapped-header.

        APPEND VALUE #( msg      = NEW zpru_cl_agent_util( )->zpru_if_agent_util~new_message(
                                           iv_id       = zpru_if_agent_frw=>cs_message_class-zpru_msg_execution
                                           iv_number   = `005`
                                           iv_severity = zpru_if_agent_message=>sc_severity-success )
                        run_uuid = <ls_delete>-run_uuid ) TO cs_reported-header.

      ELSE.

        APPEND VALUE #( run_uuid = <ls_delete>-run_uuid
                        delete   = abap_true
                        fail     = zpru_if_agent_frw=>cs_fail_cause-not_found )
               TO cs_failed-header.

        APPEND VALUE #( run_uuid = <ls_delete>-run_uuid
                        delete   = abap_true
                        msg      = NEW zpru_cl_agent_util( )->zpru_if_agent_util~new_message(
                                           iv_id       = zpru_if_agent_frw=>cs_message_class-zpru_msg_execution
                                           iv_number   = `003`
                                           iv_severity = zpru_if_agent_message=>sc_severity-error ) )
               TO cs_reported-header.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD zpru_if_axc_service~lock.
  ENDMETHOD.

  METHOD zpru_if_axc_service~rba_query.
    " Read queries by association (header keys and query control expected)
    CLEAR et_axc_query.

    IF it_rba_query_k IS INITIAL.
      RETURN.
    ENDIF.

    " Precheck inputs (fills control flags and appends any precheck failures)
    precheck_rba_query( EXPORTING it_rba_query_k = it_rba_query_k
                        IMPORTING et_entities    = DATA(lt_entities)
                        CHANGING  cs_reported    = cs_reported
                                  cs_failed      = cs_failed ).

    IF lt_entities IS INITIAL.
      RETURN.
    ENDIF.

    " Prepare query buffer for all queries belonging to requested headers
    zpru_cl_axc_buffer=>prep_query_buffer( VALUE #( FOR <ls_k> IN lt_entities
                                                   ( run_uuid   = <ls_k>-run_uuid
                                                     query_uuid = ''
                                                     full_key   = abap_false ) ) ).

    " Collect queries from buffer matching requested headers and honor query control
    LOOP AT lt_entities ASSIGNING FIELD-SYMBOL(<ls_h>).
      LOOP AT zpru_cl_axc_buffer=>query_buffer ASSIGNING FIELD-SYMBOL(<ls_q_buf>)
           WHERE instance-run_uuid = <ls_h>-run_uuid
             AND deleted = abap_false.

        DATA(ls_out) = VALUE zpru_axc_query( ).
        ls_out-query_uuid = <ls_q_buf>-instance-query_uuid.
        ls_out-run_uuid   = <ls_q_buf>-instance-run_uuid.
        ls_out-language   = COND #( WHEN <ls_h>-control-language = abap_true
                   THEN <ls_q_buf>-instance-language ).
        ls_out-execution_status = COND #( WHEN <ls_h>-control-execution_status = abap_true
                   THEN <ls_q_buf>-instance-execution_status ).
        ls_out-start_timestamp = COND #( WHEN <ls_h>-control-start_timestamp = abap_true
                  THEN <ls_q_buf>-instance-start_timestamp ).
        ls_out-end_timestamp = COND #( WHEN <ls_h>-control-end_timestamp = abap_true
                THEN <ls_q_buf>-instance-end_timestamp ).
        ls_out-input_prompt = COND #( WHEN <ls_h>-control-input_prompt = abap_true
                     THEN <ls_q_buf>-instance-input_prompt ).
        ls_out-decision_log = COND #( WHEN <ls_h>-control-decision_log = abap_true
                     THEN <ls_q_buf>-instance-decision_log ).
        ls_out-output_response = COND #( WHEN <ls_h>-control-output_response = abap_true
                  THEN <ls_q_buf>-instance-output_response ).

        APPEND ls_out TO et_axc_query.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD zpru_if_axc_service~read_query.
    CLEAR et_axc_query.

    IF it_query_read_k IS INITIAL.
      RETURN.
    ENDIF.

    DATA(lt_entities) = VALUE zpru_if_axc_service=>tt_query_read_k( ).

    LOOP AT it_query_read_k ASSIGNING FIELD-SYMBOL(<ls_k>).
      NEW zpru_cl_agent_util( )->zpru_if_agent_util~fill_flags(
        EXPORTING iv_name = `ZPRU_IF_AXC_SERVICE=>TS_QUERY_CONTROL`
        CHANGING  cs_data = <ls_k>
                  cs_control = <ls_k>-control ).

      IF <ls_k>-run_uuid IS INITIAL OR <ls_k>-query_uuid IS INITIAL.
        APPEND VALUE #( run_uuid = <ls_k>-run_uuid
                        query_uuid = <ls_k>-query_uuid
                        fail     = zpru_if_agent_frw=>cs_fail_cause-dependency )
               TO cs_failed-query.

        APPEND VALUE #( run_uuid = <ls_k>-run_uuid
                        query_uuid = <ls_k>-query_uuid
                        msg      = NEW zpru_cl_agent_util( )->zpru_if_agent_util~new_message(
                                    iv_id       = zpru_if_agent_frw=>cs_message_class-zpru_msg_execution
                                    iv_number   = `007`
                                    iv_severity = zpru_if_agent_message=>sc_severity-error ) )
               TO cs_reported-query.

        CONTINUE.
      ENDIF.

      APPEND <ls_k> TO lt_entities.
    ENDLOOP.

    IF lt_entities IS INITIAL.
      RETURN.
    ENDIF.

    " Load exact queries into buffer
    zpru_cl_axc_buffer=>prep_query_buffer( VALUE #( FOR <ls_k> IN lt_entities
                                                   ( run_uuid   = <ls_k>-run_uuid
                                                     query_uuid = <ls_k>-query_uuid
                                                     full_key   = abap_true ) ) ).

    LOOP AT lt_entities ASSIGNING FIELD-SYMBOL(<ls_ent>).
      ASSIGN zpru_cl_axc_buffer=>query_buffer[ instance-run_uuid   = <ls_ent>-run_uuid
                                               instance-query_uuid = <ls_ent>-query_uuid
                                               deleted             = abap_false ] TO FIELD-SYMBOL(<ls_buf>).
      IF sy-subrc = 0.
        DATA(ls_out) = VALUE zpru_axc_query( ).
        ls_out-query_uuid = <ls_buf>-instance-query_uuid.
        ls_out-run_uuid   = <ls_buf>-instance-run_uuid.
        ls_out-language   = COND #( WHEN <ls_ent>-control-language = abap_true
                                     THEN <ls_buf>-instance-language ).
        ls_out-execution_status = COND #( WHEN <ls_ent>-control-execution_status = abap_true
                                           THEN <ls_buf>-instance-execution_status ).
        ls_out-start_timestamp = COND #( WHEN <ls_ent>-control-start_timestamp = abap_true
                                          THEN <ls_buf>-instance-start_timestamp ).
        ls_out-end_timestamp = COND #( WHEN <ls_ent>-control-end_timestamp = abap_true
                                        THEN <ls_buf>-instance-end_timestamp ).
        ls_out-input_prompt = COND #( WHEN <ls_ent>-control-input_prompt = abap_true
                                       THEN <ls_buf>-instance-input_prompt ).
        ls_out-decision_log = COND #( WHEN <ls_ent>-control-decision_log = abap_true
                                       THEN <ls_buf>-instance-decision_log ).
        ls_out-output_response = COND #( WHEN <ls_ent>-control-output_response = abap_true
                                          THEN <ls_buf>-instance-output_response ).

        APPEND ls_out TO et_axc_query.
      ELSE.
        APPEND VALUE #( run_uuid = <ls_ent>-run_uuid
                        query_uuid = <ls_ent>-query_uuid
                        fail     = zpru_if_agent_frw=>cs_fail_cause-not_found )
               TO cs_failed-query.

        APPEND VALUE #( run_uuid = <ls_ent>-run_uuid
                        query_uuid = <ls_ent>-query_uuid
                        msg      = NEW zpru_cl_agent_util( )->zpru_if_agent_util~new_message(
                                    iv_id       = zpru_if_agent_frw=>cs_message_class-zpru_msg_execution
                                    iv_number   = `003`
                                    iv_severity = zpru_if_agent_message=>sc_severity-error ) )
               TO cs_reported-query.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD zpru_if_axc_service~update_query.
    IF it_query_update_imp IS INITIAL.
      RETURN.
    ENDIF.

    zpru_cl_axc_buffer=>prep_query_buffer( VALUE #( FOR <ls_k> IN it_query_update_imp
                                                   ( run_uuid   = <ls_k>-run_uuid
                                                     query_uuid = <ls_k>-query_uuid
                                                     full_key   = abap_true ) ) ).

    LOOP AT it_query_update_imp ASSIGNING FIELD-SYMBOL(<ls_update>).

      NEW zpru_cl_agent_util( )->zpru_if_agent_util~fill_flags(
        EXPORTING iv_name = `ZPRU_IF_AXC_SERVICE=>TS_QUERY_CONTROL`
        CHANGING  cs_data = <ls_update>
                  cs_control = <ls_update>-control ).

      ASSIGN zpru_cl_axc_buffer=>query_buffer[ instance-run_uuid   = <ls_update>-run_uuid
                                               instance-query_uuid = <ls_update>-query_uuid
                                               deleted             = abap_false ] TO FIELD-SYMBOL(<ls_buf>).

      IF sy-subrc = 0.
        <ls_buf>-instance-language = COND #( WHEN <ls_update>-control-language = abap_true
                                            THEN <ls_update>-language
                                            ELSE <ls_buf>-instance-language ).
        <ls_buf>-instance-execution_status = COND #( WHEN <ls_update>-control-execution_status = abap_true
                                                     THEN <ls_update>-execution_status
                                                     ELSE <ls_buf>-instance-execution_status ).
        <ls_buf>-instance-start_timestamp = COND #( WHEN <ls_update>-control-start_timestamp = abap_true
                                                     THEN <ls_update>-start_timestamp
                                                     ELSE <ls_buf>-instance-start_timestamp ).
        <ls_buf>-instance-end_timestamp = COND #( WHEN <ls_update>-control-end_timestamp = abap_true
                                                   THEN <ls_update>-end_timestamp
                                                   ELSE <ls_buf>-instance-end_timestamp ).
        <ls_buf>-instance-input_prompt = COND #( WHEN <ls_update>-control-input_prompt = abap_true
                                                 THEN <ls_update>-input_prompt
                                                 ELSE <ls_buf>-instance-input_prompt ).
        <ls_buf>-instance-decision_log = COND #( WHEN <ls_update>-control-decision_log = abap_true
                                                 THEN <ls_update>-decision_log
                                                 ELSE <ls_buf>-instance-decision_log ).
        <ls_buf>-instance-output_response = COND #( WHEN <ls_update>-control-output_response = abap_true
                                                    THEN <ls_update>-output_response
                                                    ELSE <ls_buf>-instance-output_response ).

        <ls_buf>-changed = abap_true.
        <ls_buf>-deleted = abap_false.

      ELSE.
        APPEND VALUE #( run_uuid = <ls_update>-run_uuid
                        query_uuid = <ls_update>-query_uuid
                        update   = abap_true
                        fail     = zpru_if_agent_frw=>cs_fail_cause-not_found )
               TO cs_failed-query.

        APPEND VALUE #( run_uuid = <ls_update>-run_uuid
                        query_uuid = <ls_update>-query_uuid
                        update   = abap_true
                        msg      = NEW zpru_cl_agent_util( )->zpru_if_agent_util~new_message(
                                    iv_id       = zpru_if_agent_frw=>cs_message_class-zpru_msg_execution
                                    iv_number   = `003`
                                    iv_severity = zpru_if_agent_message=>sc_severity-error ) )
               TO cs_reported-query.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD zpru_if_axc_service~delete_query.
    IF it_query_delete_imp IS INITIAL.
      RETURN.
    ENDIF.

    zpru_cl_axc_buffer=>prep_query_buffer( VALUE #( FOR <ls_k> IN it_query_delete_imp
                                                   ( run_uuid   = <ls_k>-run_uuid
                                                     query_uuid = <ls_k>-query_uuid
                                                     full_key   = abap_true ) ) ).

    LOOP AT it_query_delete_imp ASSIGNING FIELD-SYMBOL(<ls_delete>).

      ASSIGN zpru_cl_axc_buffer=>query_buffer[ instance-run_uuid   = <ls_delete>-run_uuid
                                               instance-query_uuid = <ls_delete>-query_uuid
                                               deleted             = abap_false ] TO FIELD-SYMBOL(<ls_buf>).
      IF sy-subrc = 0.
        <ls_buf>-deleted = abap_true.
        <ls_buf>-changed = abap_true.

        INSERT VALUE #( run_uuid = <ls_delete>-run_uuid
                        query_uuid = <ls_delete>-query_uuid ) INTO TABLE cs_mapped-query.

        APPEND VALUE #( msg      = NEW zpru_cl_agent_util( )->zpru_if_agent_util~new_message(
                                           iv_id       = zpru_if_agent_frw=>cs_message_class-zpru_msg_execution
                                           iv_number   = `005`
                                           iv_severity = zpru_if_agent_message=>sc_severity-success )
                        run_uuid = <ls_delete>-run_uuid
                        query_uuid = <ls_delete>-query_uuid ) TO cs_reported-query.

      ELSE.
        APPEND VALUE #( run_uuid = <ls_delete>-run_uuid
                        query_uuid = <ls_delete>-query_uuid
                        delete   = abap_true
                        fail     = zpru_if_agent_frw=>cs_fail_cause-not_found )
               TO cs_failed-query.

        APPEND VALUE #( run_uuid = <ls_delete>-run_uuid
                        query_uuid = <ls_delete>-query_uuid
                        delete   = abap_true
                        msg      = NEW zpru_cl_agent_util( )->zpru_if_agent_util~new_message(
                                           iv_id       = zpru_if_agent_frw=>cs_message_class-zpru_msg_execution
                                           iv_number   = `003`
                                           iv_severity = zpru_if_agent_message=>sc_severity-error ) )
               TO cs_reported-query.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD zpru_if_axc_service~read_header.

    clear et_axc_head.

    " Read header nodes from in-memory buffer honoring control flags
    IF it_head_read_k IS INITIAL.
      RETURN.
    ENDIF.

    " Precheck and ensure control flags are populated
    precheck_read( EXPORTING it_head_read_k = it_head_read_k
                   IMPORTING et_entities    = DATA(lt_entities)
                   CHANGING  cs_reported    = DATA(ls_reported)
                             cs_failed      = DATA(ls_failed) ).

    IF lt_entities IS INITIAL.
      RETURN.
    ENDIF.

    " Prepare buffer for requested headers
    zpru_cl_axc_buffer=>prep_header_buffer( VALUE #( FOR <ls_k> IN lt_entities ( run_uuid = <ls_k>-run_uuid ) ) ).

    LOOP AT lt_entities ASSIGNING FIELD-SYMBOL(<ls_req>).

      ASSIGN zpru_cl_axc_buffer=>header_buffer[ instance-run_uuid = <ls_req>-run_uuid
                                                deleted           = abap_false ] TO FIELD-SYMBOL(<ls_buf>).
      IF sy-subrc = 0.
        DATA(ls_out) = VALUE zpru_axc_head( ).

        ls_out-run_uuid = <ls_buf>-instance-run_uuid.
        ls_out-agent_uuid = COND #( WHEN <ls_req>-control-agent_uuid = abap_true
                                     THEN <ls_buf>-instance-agent_uuid ).
        ls_out-user_id = COND #( WHEN <ls_req>-control-user_id = abap_true
                                  THEN <ls_buf>-instance-user_id ).
        ls_out-start_timestamp = COND #( WHEN <ls_req>-control-start_timestamp = abap_true
                                          THEN <ls_buf>-instance-start_timestamp ).
        ls_out-end_timestamp = COND #( WHEN <ls_req>-control-end_timestamp = abap_true
                                        THEN <ls_buf>-instance-end_timestamp ).
        ls_out-created_by = COND #( WHEN <ls_req>-control-created_by = abap_true
                                     THEN <ls_buf>-instance-created_by ).
        ls_out-created_at = COND #( WHEN <ls_req>-control-created_at = abap_true
                                     THEN <ls_buf>-instance-created_at ).
        ls_out-changed_by = COND #( WHEN <ls_req>-control-changed_by = abap_true
                                     THEN <ls_buf>-instance-changed_by ).
        ls_out-last_changed = COND #( WHEN <ls_req>-control-last_changed = abap_true
                                       THEN <ls_buf>-instance-last_changed ).
        ls_out-local_last_changed = COND #( WHEN <ls_req>-control-local_last_changed = abap_true
                                            THEN <ls_buf>-instance-local_last_changed ).

        APPEND ls_out TO et_axc_head.
      ELSE.
        " Record failure and reported message for not-found so callers inspecting
        " the precheck/read diagnostics can see why the row is minimal
        APPEND VALUE #( run_uuid = <ls_req>-run_uuid
                        fail     = zpru_if_agent_frw=>cs_fail_cause-not_found )
               TO ls_failed-header.

        APPEND VALUE #( run_uuid = <ls_req>-run_uuid
                        msg      = NEW zpru_cl_agent_util( )->zpru_if_agent_util~new_message(
                                    iv_id       = zpru_if_agent_frw=>cs_message_class-zpru_msg_execution
                                    iv_number   = `003`
                                    iv_severity = zpru_if_agent_message=>sc_severity-error ) )
               TO ls_reported-header.
      ENDIF.
      ENDLOOP.
    ENDMETHOD.

  METHOD zpru_if_axc_service~update_header.

    IF it_head_update_imp IS INITIAL.
      RETURN.
    ENDIF.

    zpru_cl_axc_buffer=>prep_header_buffer( VALUE #( FOR <ls_k>
                                                     IN     it_head_update_imp
                                                     ( run_uuid = <ls_k>-run_uuid ) ) ).

    LOOP AT it_head_update_imp ASSIGNING FIELD-SYMBOL(<ls_update>).

      ASSIGN zpru_cl_axc_buffer=>header_buffer[ instance-run_uuid = <ls_update>-run_uuid
                                                deleted           = abap_false ] TO FIELD-SYMBOL(<ls_buffer>).
      IF sy-subrc = 0.
        <ls_buffer>-instance-agent_uuid      = COND #( WHEN <ls_update>-control-agent_uuid = abap_true
                                                       THEN <ls_update>-agent_uuid
                                                       ELSE <ls_buffer>-instance-agent_uuid ).
        <ls_buffer>-instance-user_id         = COND #( WHEN <ls_update>-control-user_id = abap_true
                                                       THEN <ls_update>-user_id
                                                       ELSE <ls_buffer>-instance-user_id ).
        <ls_buffer>-instance-start_timestamp = COND #( WHEN <ls_update>-control-start_timestamp = abap_true
                                                       THEN <ls_update>-start_timestamp
                                                       ELSE <ls_buffer>-instance-start_timestamp ).
        <ls_buffer>-instance-end_timestamp   = COND #( WHEN <ls_update>-control-end_timestamp = abap_true
                                                       THEN <ls_update>-end_timestamp
                                                       ELSE <ls_buffer>-instance-end_timestamp ).
        <ls_buffer>-instance-created_by      = COND #( WHEN <ls_update>-control-created_by = abap_true
                                                       THEN <ls_update>-created_by
                                                       ELSE <ls_buffer>-instance-created_by ).
        <ls_buffer>-instance-created_at      = COND #( WHEN <ls_update>-control-created_at = abap_true
                                                       THEN <ls_update>-created_at
                                                       ELSE <ls_buffer>-instance-created_at ).
        <ls_buffer>-instance-changed_by      = COND #( WHEN <ls_update>-control-changed_by = abap_true
                                                       THEN <ls_update>-changed_by
                                                       ELSE <ls_buffer>-instance-changed_by ).
        <ls_buffer>-instance-last_changed    = COND #( WHEN <ls_update>-control-last_changed = abap_true
                                                       THEN <ls_update>-last_changed
                                                       ELSE <ls_buffer>-instance-last_changed ).
        <ls_buffer>-changed = abap_true.
        <ls_buffer>-deleted = abap_false.

        fill_head_admin_fields( EXPORTING iv_during_create = abap_false
                                CHANGING  cs_header        = <ls_buffer> ).

      ELSE.

        APPEND VALUE #( run_uuid = <ls_update>-run_uuid
                        update   = abap_true
                        fail     = zpru_if_agent_frw=>cs_fail_cause-not_found )
               TO cs_failed-header.

        APPEND VALUE #( run_uuid = <ls_update>-run_uuid
                        update   = abap_true
                        msg      = NEW zpru_cl_agent_util( )->zpru_if_agent_util~new_message(
                                           iv_id       = zpru_if_agent_frw=>cs_message_class-zpru_msg_execution
                                           iv_number   = `003`
                                           iv_severity = zpru_if_agent_message=>sc_severity-error ) )
               TO cs_reported-header.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD zpru_if_axc_service~create_header.
    IF it_head_create_imp IS INITIAL.
      RETURN.
    ENDIF.

    precheck_create( EXPORTING it_head_create_imp = it_head_create_imp
                     IMPORTING et_entities        = DATA(lt_entities)
                     CHANGING  cs_reported        = cs_reported
                               cs_failed          = cs_failed ).

    zpru_cl_axc_buffer=>prep_header_buffer( VALUE #( FOR <ls_k>
                                                     IN lt_entities
                                                     ( run_uuid = <ls_k>-run_uuid ) ) ).

    LOOP AT lt_entities ASSIGNING FIELD-SYMBOL(<ls_create>).

      IF    NOT line_exists( zpru_cl_axc_buffer=>header_buffer[ instance-run_uuid = <ls_create>-run_uuid ] )
         OR     line_exists( zpru_cl_axc_buffer=>header_buffer[ instance-run_uuid = <ls_create>-run_uuid
                                                                deleted           = abap_true ] ).

        DELETE zpru_cl_axc_buffer=>header_buffer
               WHERE     instance-run_uuid = VALUE #( zpru_cl_axc_buffer=>header_buffer[
                                                          instance-run_uuid = <ls_create>-run_uuid ]-instance-run_uuid OPTIONAL )
                     AND deleted           = abap_true.

        APPEND VALUE #(
            instance-run_uuid           = <ls_create>-run_uuid
            instance-agent_uuid         = COND #( WHEN <ls_create>-control-agent_uuid = abap_true
                                                  THEN <ls_create>-agent_uuid )
            instance-user_id            = COND #( WHEN <ls_create>-control-user_id = abap_true
                                                  THEN <ls_create>-user_id )
            instance-start_timestamp    = COND #( WHEN <ls_create>-control-start_timestamp = abap_true
                                                  THEN <ls_create>-start_timestamp )
            instance-end_timestamp      = COND #( WHEN <ls_create>-control-end_timestamp = abap_true
                                                  THEN <ls_create>-end_timestamp )
            instance-created_by         = COND #( WHEN <ls_create>-control-created_by = abap_true
                                                  THEN <ls_create>-created_by )
            instance-created_at         = COND #( WHEN <ls_create>-control-created_at = abap_true
                                                  THEN <ls_create>-created_at )
            instance-changed_by         = COND #( WHEN <ls_create>-control-changed_by <> if_abap_behv=>mk-off
                                                  THEN <ls_create>-changed_by )
            instance-last_changed       = COND #( WHEN <ls_create>-control-last_changed = abap_true
                                                  THEN <ls_create>-last_changed )
            instance-local_last_changed = COND #( WHEN <ls_create>-control-local_last_changed = abap_true
                                                  THEN <ls_create>-local_last_changed )
            changed                     = abap_true
            deleted                     = abap_false ) TO zpru_cl_axc_buffer=>header_buffer ASSIGNING FIELD-SYMBOL(<ls_just_added>).

        fill_head_admin_fields( EXPORTING iv_during_create = abap_true
                                CHANGING  cs_header        = <ls_just_added> ).

        INSERT VALUE #( run_uuid = <ls_create>-run_uuid ) INTO TABLE cs_mapped-header.

        APPEND VALUE #( msg      = NEW zpru_cl_agent_util( )->zpru_if_agent_util~new_message(
                                           iv_id       = zpru_if_agent_frw=>cs_message_class-zpru_msg_execution
                                           iv_number   = `001`
                                           iv_severity = zpru_if_agent_message=>sc_severity-success )
                        run_uuid = <ls_create>-run_uuid  ) TO cs_reported-header.

      ELSE.

        APPEND VALUE #( run_uuid = <ls_create>-run_uuid
                        create   = abap_true
                        fail     = zpru_if_agent_frw=>cs_fail_cause-unspecific )
               TO cs_failed-header.

        APPEND VALUE #( run_uuid = <ls_create>-run_uuid
                        create   = abap_true
                        msg      = NEW zpru_cl_agent_util( )->zpru_if_agent_util~new_message(
                                           iv_id       = zpru_if_agent_frw=>cs_message_class-zpru_msg_execution
                                           iv_number   = `002`
                                           iv_severity = zpru_if_agent_message=>sc_severity-error ) )
               TO cs_reported-header.

      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_create.

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
          iv_name    = `ZPRU_IF_AXC_SERVICE=>TS_HEAD_CONTROL`
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

  METHOD precheck_cba_query.

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
          iv_name    = `ZPRU_IF_AXC_SERVICE=>TS_QUERY_CONTROL`
        CHANGING
          cs_data    = <ls_create>
          cs_control = <ls_create>-control ).

      IF <ls_create>-run_uuid IS INITIAL.

         APPEND VALUE #( run_uuid  = <ls_create>-run_uuid
               query_uuid = <ls_create>-query_uuid
               create    = abap_true
               fail      = zpru_if_agent_frw=>cs_fail_cause-dependency )
           TO cs_failed-query.

         APPEND VALUE #( run_uuid   = <ls_create>-run_uuid
               query_uuid  = <ls_create>-query_uuid
               create      = abap_true
               msg         = NEW zpru_cl_agent_util( )->zpru_if_agent_util~new_message(
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

  METHOD precheck_read.

    CLEAR et_entities.

    LOOP AT it_head_read_k ASSIGNING FIELD-SYMBOL(<ls_k>).

      NEW zpru_cl_agent_util( )->zpru_if_agent_util~fill_flags(
        EXPORTING
          iv_name    = `ZPRU_IF_AXC_SERVICE=>TS_HEAD_CONTROL`
        CHANGING
          cs_data    = <ls_k>
          cs_control = <ls_k>-control ).

      IF <ls_k>-run_uuid IS INITIAL.
        APPEND VALUE #( run_uuid = <ls_k>-run_uuid
                        create   = abap_true
                        fail     = zpru_if_agent_frw=>cs_fail_cause-dependency )
               TO cs_failed-header.

        APPEND VALUE #( run_uuid = <ls_k>-run_uuid
                        create   = abap_true
                        msg      = NEW zpru_cl_agent_util( )->zpru_if_agent_util~new_message(
                                           iv_id       = zpru_if_agent_frw=>cs_message_class-zpru_msg_execution
                                           iv_number   = `007`
                                           iv_severity = zpru_if_agent_message=>sc_severity-error ) )
               TO cs_reported-header.

        CONTINUE.
      ENDIF.

      APPEND INITIAL LINE TO et_entities ASSIGNING FIELD-SYMBOL(<ls_ent>).
      <ls_ent> = <ls_k>.
    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_rba_query.

    CLEAR et_entities.

    LOOP AT it_rba_query_k ASSIGNING FIELD-SYMBOL(<ls_in>).

      NEW zpru_cl_agent_util( )->zpru_if_agent_util~fill_flags(
        EXPORTING
          iv_name    = `ZPRU_IF_AXC_SERVICE=>TS_QUERY_CONTROL`
        CHANGING
          cs_data    = <ls_in>
          cs_control = <ls_in>-control ).

      IF <ls_in>-run_uuid IS INITIAL.
        APPEND VALUE #( run_uuid = <ls_in>-run_uuid
                        fail     = zpru_if_agent_frw=>cs_fail_cause-dependency )
               TO cs_failed-header.

        APPEND VALUE #( run_uuid = <ls_in>-run_uuid
                        msg      = NEW zpru_cl_agent_util( )->zpru_if_agent_util~new_message(
                                    iv_id       = zpru_if_agent_frw=>cs_message_class-zpru_msg_execution
                                    iv_number   = `007`
                                    iv_severity = zpru_if_agent_message=>sc_severity-error ) )
               TO cs_reported-header.

        CONTINUE.
      ENDIF.

      APPEND INITIAL LINE TO et_entities ASSIGNING FIELD-SYMBOL(<ls_ent>).
      <ls_ent> = <ls_in>.

    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_read_query.

    CLEAR et_entities.

    LOOP AT it_query_read_k ASSIGNING FIELD-SYMBOL(<ls_k>).

      NEW zpru_cl_agent_util( )->zpru_if_agent_util~fill_flags(
        EXPORTING
          iv_name    = `ZPRU_IF_AXC_SERVICE=>TS_QUERY_CONTROL`
        CHANGING
          cs_data    = <ls_k>
          cs_control = <ls_k>-control ).

      IF <ls_k>-run_uuid IS INITIAL OR <ls_k>-query_uuid IS INITIAL.
        APPEND VALUE #( run_uuid   = <ls_k>-run_uuid
                        query_uuid = <ls_k>-query_uuid
                        fail       = zpru_if_agent_frw=>cs_fail_cause-dependency )
               TO cs_failed-query.

        APPEND VALUE #( run_uuid   = <ls_k>-run_uuid
                        query_uuid = <ls_k>-query_uuid
                        msg        = NEW zpru_cl_agent_util( )->zpru_if_agent_util~new_message(
                                      iv_id       = zpru_if_agent_frw=>cs_message_class-zpru_msg_execution
                                      iv_number   = `007`
                                      iv_severity = zpru_if_agent_message=>sc_severity-error ) )
               TO cs_reported-query.

        CONTINUE.
      ENDIF.

      APPEND INITIAL LINE TO et_entities ASSIGNING FIELD-SYMBOL(<ls_ent>).
      <ls_ent> = <ls_k>.

    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_update_query.

    CLEAR et_entities.

    LOOP AT it_query_update_imp ASSIGNING FIELD-SYMBOL(<ls_k>).

      NEW zpru_cl_agent_util( )->zpru_if_agent_util~fill_flags(
        EXPORTING
          iv_name    = `ZPRU_IF_AXC_SERVICE=>TS_QUERY_CONTROL`
        CHANGING
          cs_data    = <ls_k>
          cs_control = <ls_k>-control ).

      IF <ls_k>-run_uuid IS INITIAL OR <ls_k>-query_uuid IS INITIAL.
        APPEND VALUE #( run_uuid   = <ls_k>-run_uuid
                        query_uuid = <ls_k>-query_uuid
                        fail       = zpru_if_agent_frw=>cs_fail_cause-dependency )
               TO cs_failed-query.

        APPEND VALUE #( run_uuid   = <ls_k>-run_uuid
                        query_uuid = <ls_k>-query_uuid
                        msg        = NEW zpru_cl_agent_util( )->zpru_if_agent_util~new_message(
                                      iv_id       = zpru_if_agent_frw=>cs_message_class-zpru_msg_execution
                                      iv_number   = `007`
                                      iv_severity = zpru_if_agent_message=>sc_severity-error ) )
               TO cs_reported-query.

        CONTINUE.
      ENDIF.

      APPEND INITIAL LINE TO et_entities ASSIGNING FIELD-SYMBOL(<ls_ent>).
      <ls_ent> = <ls_k>.

    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_delete_query.

    CLEAR et_entities.

    LOOP AT it_query_delete_imp ASSIGNING FIELD-SYMBOL(<ls_k>).

      IF <ls_k>-run_uuid IS INITIAL OR <ls_k>-query_uuid IS INITIAL.
        APPEND VALUE #( run_uuid   = <ls_k>-run_uuid
                        query_uuid = <ls_k>-query_uuid
                        fail       = zpru_if_agent_frw=>cs_fail_cause-dependency )
               TO cs_failed-query.

        APPEND VALUE #( run_uuid   = <ls_k>-run_uuid
                        query_uuid = <ls_k>-query_uuid
                        msg        = NEW zpru_cl_agent_util( )->zpru_if_agent_util~new_message(
                                      iv_id       = zpru_if_agent_frw=>cs_message_class-zpru_msg_execution
                                      iv_number   = `007`
                                      iv_severity = zpru_if_agent_message=>sc_severity-error ) )
               TO cs_reported-query.

        CONTINUE.
      ENDIF.

      APPEND INITIAL LINE TO et_entities ASSIGNING FIELD-SYMBOL(<ls_ent>).
      <ls_ent>-run_uuid = <ls_k>-run_uuid.
      <ls_ent>-query_uuid = <ls_k>-query_uuid.

    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_cba_step.

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
          iv_name    = `ZPRU_IF_AXC_SERVICE=>TS_STEP_CONTROL`
        CHANGING
          cs_data    = <ls_create>
          cs_control = <ls_create>-control ).

      IF <ls_create>-query_uuid IS INITIAL.

         APPEND VALUE #( run_uuid   = <ls_create>-run_uuid
               query_uuid  = <ls_create>-query_uuid
               step_uuid   = <ls_create>-step_uuid
               create      = abap_true
               fail        = zpru_if_agent_frw=>cs_fail_cause-dependency )
           TO cs_failed-step.

         APPEND VALUE #( run_uuid   = <ls_create>-run_uuid
               query_uuid  = <ls_create>-query_uuid
               step_uuid   = <ls_create>-step_uuid
               create      = abap_true
               msg         = NEW zpru_cl_agent_util( )->zpru_if_agent_util~new_message(
                   iv_id       = zpru_if_agent_frw=>cs_message_class-zpru_msg_execution
                   iv_number   = `006`
                   iv_severity = zpru_if_agent_message=>sc_severity-error ) )
           TO cs_reported-step.

        CONTINUE.
      ENDIF.

      APPEND INITIAL LINE TO et_entities ASSIGNING FIELD-SYMBOL(<ls_entity>).
      <ls_entity> = <ls_create>.

    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_rba_step.

    CLEAR et_entities.

    LOOP AT it_rba_step_k ASSIGNING FIELD-SYMBOL(<ls_in>).

      NEW zpru_cl_agent_util( )->zpru_if_agent_util~fill_flags(
        EXPORTING
          iv_name    = `ZPRU_IF_AXC_SERVICE=>TS_STEP_CONTROL`
        CHANGING
          cs_data    = <ls_in>
          cs_control = <ls_in>-control ).

      IF <ls_in>-query_uuid IS INITIAL.
        APPEND VALUE #( query_uuid = <ls_in>-query_uuid
                        fail      = zpru_if_agent_frw=>cs_fail_cause-dependency )
               TO cs_failed-query.

        APPEND VALUE #( query_uuid = <ls_in>-query_uuid
                        msg       = NEW zpru_cl_agent_util( )->zpru_if_agent_util~new_message(
                                    iv_id       = zpru_if_agent_frw=>cs_message_class-zpru_msg_execution
                                    iv_number   = `007`
                                    iv_severity = zpru_if_agent_message=>sc_severity-error ) )
               TO cs_reported-query.

        CONTINUE.
      ENDIF.

      APPEND INITIAL LINE TO et_entities ASSIGNING FIELD-SYMBOL(<ls_ent>).
      <ls_ent> = <ls_in>.

    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_read_step.

    CLEAR et_entities.

    LOOP AT it_step_read_k ASSIGNING FIELD-SYMBOL(<ls_k>).

      NEW zpru_cl_agent_util( )->zpru_if_agent_util~fill_flags(
        EXPORTING
          iv_name    = `ZPRU_IF_AXC_SERVICE=>TS_STEP_CONTROL`
        CHANGING
          cs_data    = <ls_k>
          cs_control = <ls_k>-control ).

      IF <ls_k>-query_uuid IS INITIAL OR <ls_k>-step_uuid IS INITIAL.
        APPEND VALUE #( run_uuid   = <ls_k>-run_uuid
                        query_uuid = <ls_k>-query_uuid
                        step_uuid  = <ls_k>-step_uuid
                        fail       = zpru_if_agent_frw=>cs_fail_cause-dependency )
               TO cs_failed-step.

        APPEND VALUE #( run_uuid   = <ls_k>-run_uuid
                        query_uuid = <ls_k>-query_uuid
                        step_uuid  = <ls_k>-step_uuid
                        msg        = NEW zpru_cl_agent_util( )->zpru_if_agent_util~new_message(
                                      iv_id       = zpru_if_agent_frw=>cs_message_class-zpru_msg_execution
                                      iv_number   = `007`
                                      iv_severity = zpru_if_agent_message=>sc_severity-error ) )
               TO cs_reported-step.

        CONTINUE.
      ENDIF.

      APPEND INITIAL LINE TO et_entities ASSIGNING FIELD-SYMBOL(<ls_ent>).
      <ls_ent> = <ls_k>.
    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_update_step.

    CLEAR et_entities.

    LOOP AT it_step_update_imp ASSIGNING FIELD-SYMBOL(<ls_k>).

      NEW zpru_cl_agent_util( )->zpru_if_agent_util~fill_flags(
        EXPORTING
          iv_name    = `ZPRU_IF_AXC_SERVICE=>TS_STEP_CONTROL`
        CHANGING
          cs_data    = <ls_k>
          cs_control = <ls_k>-control ).

      IF <ls_k>-query_uuid IS INITIAL OR <ls_k>-step_uuid IS INITIAL.
        APPEND VALUE #( run_uuid   = <ls_k>-run_uuid
                        query_uuid = <ls_k>-query_uuid
                        step_uuid  = <ls_k>-step_uuid
                        fail       = zpru_if_agent_frw=>cs_fail_cause-dependency )
               TO cs_failed-step.

        APPEND VALUE #( run_uuid   = <ls_k>-run_uuid
                        query_uuid = <ls_k>-query_uuid
                        step_uuid  = <ls_k>-step_uuid
                        msg        = NEW zpru_cl_agent_util( )->zpru_if_agent_util~new_message(
                                      iv_id       = zpru_if_agent_frw=>cs_message_class-zpru_msg_execution
                                      iv_number   = `007`
                                      iv_severity = zpru_if_agent_message=>sc_severity-error ) )
               TO cs_reported-step.

        CONTINUE.
      ENDIF.

      APPEND INITIAL LINE TO et_entities ASSIGNING FIELD-SYMBOL(<ls_ent>).
      <ls_ent> = <ls_k>.

    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_delete_step.

    CLEAR et_entities.

    LOOP AT it_step_delete_imp ASSIGNING FIELD-SYMBOL(<ls_k>).

      IF <ls_k>-query_uuid IS INITIAL OR <ls_k>-step_uuid IS INITIAL.
        APPEND VALUE #( run_uuid   = <ls_k>-run_uuid
                        query_uuid = <ls_k>-query_uuid
                        step_uuid  = <ls_k>-step_uuid
                        fail       = zpru_if_agent_frw=>cs_fail_cause-dependency )
               TO cs_failed-step.

        APPEND VALUE #( run_uuid   = <ls_k>-run_uuid
                        query_uuid = <ls_k>-query_uuid
                        step_uuid  = <ls_k>-step_uuid
                        msg        = NEW zpru_cl_agent_util( )->zpru_if_agent_util~new_message(
                                      iv_id       = zpru_if_agent_frw=>cs_message_class-zpru_msg_execution
                                      iv_number   = `007`
                                      iv_severity = zpru_if_agent_message=>sc_severity-error ) )
               TO cs_reported-step.

        CONTINUE.
      ENDIF.

      APPEND INITIAL LINE TO et_entities ASSIGNING FIELD-SYMBOL(<ls_ent>).
      <ls_ent>-query_uuid = <ls_k>-query_uuid.
      <ls_ent>-step_uuid = <ls_k>-step_uuid.

    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
