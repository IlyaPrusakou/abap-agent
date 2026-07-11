CLASS lcl_buffer DEFINITION CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ts_run_count,
             numberrangelevel TYPE zpru_de_run_id,
           END OF ts_run_count.

    TYPES tt_run_count TYPE STANDARD TABLE OF ts_run_count WITH EMPTY KEY.

    CLASS-DATA st_run_count TYPE tt_run_count.

    TYPES: BEGIN OF ts_query_count,
             aipf7runuuid     TYPE sysuuid_x16,
             aipf7queryuuid   TYPE sysuuid_x16,
             aipf7querynumber TYPE zpru_de_query_number,
           END OF ts_query_count.

    TYPES tt_query_count TYPE STANDARD TABLE OF ts_query_count WITH EMPTY KEY.

    CLASS-DATA st_query_count TYPE tt_query_count.

    TYPES: BEGIN OF ts_step_count,
             aipf7runuuid    TYPE sysuuid_x16,
             aipf7queryuuid  TYPE sysuuid_x16,
             aipf7stepuuid   TYPE sysuuid_x16,
             aipf7stepnumber TYPE zpru_de_step_number,
           END OF ts_step_count.

    TYPES tt_step_count TYPE STANDARD TABLE OF ts_step_count WITH EMPTY KEY.

    CLASS-DATA st_step_count TYPE tt_step_count.

ENDCLASS.


CLASS lcl_buffer IMPLEMENTATION.
ENDCLASS.


CLASS lhc_zr_pru_axc_head DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    CONSTANTS:
      BEGIN OF state_area,
        checkagentuuid TYPE string VALUE 'CHECKAGENTUUID',
        checkuserid    TYPE string VALUE 'CHECKUSERID',
      END OF state_area.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING
      REQUEST requested_authorizations FOR executionheader
      RESULT result.
    METHODS generaterunid FOR DETERMINE ON MODIFY
      IMPORTING keys FOR executionheader~generaterunid.
    METHODS checkagentuuid FOR VALIDATE ON SAVE
      IMPORTING keys FOR executionheader~checkAgentUuid.
    METHODS checkuserid FOR VALIDATE ON SAVE
      IMPORTING keys FOR executionheader~checkUserId.
ENDCLASS.


CLASS lhc_zr_pru_axc_head IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD generaterunid.
    DATA lv_number          TYPE cl_numberrange_runtime=>nr_number.
    DATA lv_number_buffered TYPE cl_numberrange_runtime=>nr_number.
    DATA lt_update_root     TYPE TABLE FOR UPDATE zr_pru_axc_head\\executionheader.

    TRY.
        cl_numberrange_runtime=>number_status( EXPORTING nr_range_nr = '01'
                                                         object      = 'ZPRU_AXCHD'
                                               IMPORTING number      = lv_number ).

        IF lv_number IS NOT INITIAL.
          SORT lcl_buffer=>st_run_count BY numberrangelevel DESCENDING.
          lv_number_buffered = VALUE #( lcl_buffer=>st_run_count[ 1 ]-numberrangelevel OPTIONAL ).
          IF lv_number_buffered < lv_number.
            APPEND INITIAL LINE TO lcl_buffer=>st_run_count ASSIGNING FIELD-SYMBOL(<ls_query_count>).
            <ls_query_count>-numberrangelevel = lv_number.
          ENDIF.
        ENDIF.

      CATCH cx_nr_object_not_found
            cx_number_ranges.
        ASSERT 1 = 2.
    ENDTRY.

    IF lcl_buffer=>st_run_count IS NOT INITIAL.
      SORT lcl_buffer=>st_run_count BY numberrangelevel DESCENDING.
      lv_number = VALUE #( lcl_buffer=>st_run_count[ 1 ]-numberrangelevel OPTIONAL ).
    ELSE.
      lv_number = '00000000000000000000'.
    ENDIF.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).

      lv_number += 1.

      APPEND INITIAL LINE TO lt_update_root ASSIGNING FIELD-SYMBOL(<ls_update_root>).
      <ls_update_root>-%tky       = <ls_key>-%tky.
      <ls_update_root>-aipf7runid = lv_number.
      <ls_update_root>-%control-aipf7runid = if_abap_behv=>mk-on.

      APPEND INITIAL LINE TO lcl_buffer=>st_run_count ASSIGNING FIELD-SYMBOL(<ls_run_count>).
      <ls_run_count>-numberrangelevel = lv_number.

    ENDLOOP.

    IF lt_update_root IS NOT INITIAL.
      MODIFY ENTITIES OF zr_pru_axc_head
             IN LOCAL MODE
             ENTITY executionheader
             UPDATE FROM lt_update_root
             REPORTED DATA(ls_upd_reported).

      reported = CORRESPONDING #( DEEP ls_upd_reported ).
    ENDIF.
  ENDMETHOD.
  METHOD checkagentuuid.
    DATA lt_not_found LIKE keys.

    IF keys IS INITIAL.
      RETURN.
    ENDIF.

    READ ENTITIES OF zr_pru_axc_head IN LOCAL MODE
         ENTITY executionheader
         FIELDS ( AIPF7AgentUUID )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_head).

    IF lt_head IS NOT INITIAL.
      SELECT AIPF7AgentUUID
        FROM zr_pru_agent
        FOR ALL ENTRIES IN @lt_head
        WHERE AIPF7AgentUUID = @lt_head-AIPF7AgentUUID
        INTO TABLE @DATA(lt_existing_agents)
        PRIVILEGED ACCESS.
    ENDIF.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).

      APPEND INITIAL LINE TO reported-executionheader ASSIGNING FIELD-SYMBOL(<ls_inval>).
      <ls_inval>-%tky        = <ls_key>-%tky.
      <ls_inval>-%state_area = state_area-checkagentuuid.

      ASSIGN lt_head[ KEY id COMPONENTS %tky = <ls_key>-%tky ] TO FIELD-SYMBOL(<ls_head>).
      IF sy-subrc <> 0.
        APPEND INITIAL LINE TO lt_not_found ASSIGNING FIELD-SYMBOL(<ls_not_found>).
        <ls_not_found> = <ls_key>.
        CONTINUE.
      ENDIF.

      IF <ls_head>-AIPF7AgentUUID IS INITIAL.
        APPEND INITIAL LINE TO failed-executionheader ASSIGNING FIELD-SYMBOL(<ls_fail>).
        <ls_fail>-%tky        = <ls_head>-%tky.
        <ls_fail>-%fail-cause = if_abap_behv=>cause-conflict.

        APPEND INITIAL LINE TO reported-executionheader ASSIGNING FIELD-SYMBOL(<ls_report>).
        <ls_report>-%tky        = <ls_head>-%tky.
        <ls_report>-%state_area = state_area-checkagentuuid.
        <ls_report>-%element-AIPF7AgentUUID = if_abap_behv=>mk-on.
        <ls_report>-%msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = |Agent UUID must not be initial.| ).
        CONTINUE.
      ENDIF.

      IF NOT line_exists( lt_existing_agents[ AIPF7AgentUUID = <ls_head>-AIPF7AgentUUID ] ).
        APPEND INITIAL LINE TO failed-executionheader ASSIGNING <ls_fail>.
        <ls_fail>-%tky        = <ls_head>-%tky.
        <ls_fail>-%fail-cause = if_abap_behv=>cause-conflict.

        APPEND INITIAL LINE TO reported-executionheader ASSIGNING <ls_report>.
        <ls_report>-%tky        = <ls_head>-%tky.
        <ls_report>-%state_area = state_area-checkagentuuid.
        <ls_report>-%element-AIPF7AgentUUID = if_abap_behv=>mk-on.
        <ls_report>-%msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = |Agent with UUID '{ <ls_head>-AIPF7AgentUUID }' does not exist.| ).
      ENDIF.

    ENDLOOP.

    LOOP AT lt_not_found ASSIGNING <ls_not_found>.
      APPEND INITIAL LINE TO failed-executionheader ASSIGNING <ls_fail>.
      <ls_fail>-%tky        = <ls_not_found>-%tky.
      <ls_fail>-%fail-cause = if_abap_behv=>cause-not_found.

      APPEND INITIAL LINE TO reported-executionheader ASSIGNING <ls_report>.
      <ls_report>-%tky        = <ls_not_found>-%tky.
      <ls_report>-%state_area = state_area-checkagentuuid.
      <ls_report>-%msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text     = |Execution header not found.| ).
    ENDLOOP.
  ENDMETHOD.

  METHOD checkuserid.
    DATA lt_not_found LIKE keys.

    IF keys IS INITIAL.
      RETURN.
    ENDIF.

    READ ENTITIES OF zr_pru_axc_head IN LOCAL MODE
         ENTITY executionheader
         FIELDS ( AIPF7UserID )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_head).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).

      APPEND INITIAL LINE TO reported-executionheader ASSIGNING FIELD-SYMBOL(<ls_inval>).
      <ls_inval>-%tky        = <ls_key>-%tky.
      <ls_inval>-%state_area = state_area-checkuserid.

      ASSIGN lt_head[ KEY id COMPONENTS %tky = <ls_key>-%tky ] TO FIELD-SYMBOL(<ls_head>).
      IF sy-subrc <> 0.
        APPEND INITIAL LINE TO lt_not_found ASSIGNING FIELD-SYMBOL(<ls_not_found>).
        <ls_not_found> = <ls_key>.
        CONTINUE.
      ENDIF.

      IF <ls_head>-AIPF7UserID IS INITIAL.
        APPEND INITIAL LINE TO failed-executionheader ASSIGNING FIELD-SYMBOL(<ls_fail>).
        <ls_fail>-%tky        = <ls_head>-%tky.
        <ls_fail>-%fail-cause = if_abap_behv=>cause-conflict.

        APPEND INITIAL LINE TO reported-executionheader ASSIGNING FIELD-SYMBOL(<ls_report>).
        <ls_report>-%tky        = <ls_head>-%tky.
        <ls_report>-%state_area = state_area-checkuserid.
        <ls_report>-%element-AIPF7UserID = if_abap_behv=>mk-on.
        <ls_report>-%msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = |User ID must not be initial.| ).
      ENDIF.

    ENDLOOP.

    LOOP AT lt_not_found ASSIGNING <ls_not_found>.
      APPEND INITIAL LINE TO failed-executionheader ASSIGNING <ls_fail>.
      <ls_fail>-%tky        = <ls_not_found>-%tky.
      <ls_fail>-%fail-cause = if_abap_behv=>cause-not_found.

      APPEND INITIAL LINE TO reported-executionheader ASSIGNING <ls_report>.
      <ls_report>-%tky        = <ls_not_found>-%tky.
      <ls_report>-%state_area = state_area-checkuserid.
      <ls_report>-%msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text     = |Execution header not found.| ).
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.


CLASS lhc_executionquery DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.
    CONSTANTS:
      BEGIN OF state_area,
        checkquerystatus TYPE string VALUE 'CHECKQUERYSTATUS',
      END OF state_area.

    METHODS generatequeryid FOR DETERMINE ON MODIFY
      IMPORTING keys FOR executionquery~generatequeryid.
    METHODS checkquerystatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR executionquery~checkQueryStatus.

ENDCLASS.


CLASS lhc_executionquery IMPLEMENTATION.
  METHOD generatequeryid.
    DATA lv_number          TYPE zpru_de_query_number.
    DATA lv_number_buffered TYPE zpru_de_query_number.
    DATA lt_update_query    TYPE TABLE FOR UPDATE zr_pru_axc_head\\executionquery.

    READ ENTITIES OF zr_pru_axc_head
         IN LOCAL MODE
         ENTITY executionquery
         FIELDS ( aipf7runuuid ) WITH CORRESPONDING #( keys )
         RESULT DATA(lt_query).

    IF lt_query IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT lt_query ASSIGNING FIELD-SYMBOL(<ls_query_group>)
         GROUP BY <ls_query_group>-aipf7runuuid
         ASSIGNING FIELD-SYMBOL(<lv_query_key>).

      CLEAR: lv_number,
             lv_number_buffered.

      SELECT aipf7runuuid,
             aipf7queryuuid,
             aipf7querynumber
        FROM zi_pru_axc_query
        WHERE aipf7runuuid = @<lv_query_key>
        ORDER BY aipf7querynumber DESCENDING
        INTO TABLE @DATA(lt_last_id)
        UP TO 1 ROWS.
      IF sy-subrc = 0.
        ASSIGN lt_last_id[ 1 ] TO FIELD-SYMBOL(<ls_number_db>).
        IF sy-subrc = 0.
          DATA(lt_buffer_copy) = lcl_buffer=>st_query_count.
          DELETE lt_buffer_copy WHERE aipf7runuuid <> <lv_query_key>.
          SORT lt_buffer_copy BY aipf7querynumber DESCENDING.

          lv_number_buffered = VALUE #( lt_buffer_copy[ 1 ]-aipf7querynumber OPTIONAL ).

          IF lv_number_buffered < <ls_number_db>-aipf7querynumber.
            APPEND INITIAL LINE TO lcl_buffer=>st_query_count ASSIGNING FIELD-SYMBOL(<ls_query_count>).
            <ls_query_count>-aipf7runuuid     = <ls_number_db>-aipf7runuuid.
            <ls_query_count>-aipf7queryuuid   = <ls_number_db>-aipf7queryuuid.
            <ls_query_count>-aipf7querynumber = <ls_number_db>-aipf7querynumber.
          ENDIF.
        ENDIF.
      ENDIF.

      lt_buffer_copy = lcl_buffer=>st_query_count.
      DELETE lt_buffer_copy WHERE aipf7runuuid <> <lv_query_key>.

      IF lt_buffer_copy IS NOT INITIAL.
        SORT lt_buffer_copy BY aipf7querynumber DESCENDING.
        lv_number = VALUE #( lt_buffer_copy[ 1 ]-aipf7querynumber OPTIONAL ).
      ELSE.
        lv_number = '0000000000'.
      ENDIF.

      LOOP AT GROUP <lv_query_key> ASSIGNING FIELD-SYMBOL(<ls_member>).

        lv_number += 1.

        APPEND INITIAL LINE TO lt_update_query ASSIGNING FIELD-SYMBOL(<ls_update>).
        <ls_update>-%tky             = <ls_member>-%tky.
        <ls_update>-aipf7querynumber = lv_number.
        <ls_update>-%control-aipf7querynumber = if_abap_behv=>mk-on.

        APPEND INITIAL LINE TO lcl_buffer=>st_query_count ASSIGNING <ls_query_count>.
        <ls_query_count>-aipf7runuuid     = <ls_member>-aipf7runuuid.
        <ls_query_count>-aipf7queryuuid   = <ls_member>-aipf7queryuuid.
        <ls_query_count>-aipf7querynumber = lv_number.
      ENDLOOP.

      CLEAR lt_last_id.

    ENDLOOP.

    IF lt_update_query IS NOT INITIAL.
      MODIFY ENTITIES OF zr_pru_axc_head
             IN LOCAL MODE
             ENTITY executionquery
             UPDATE FROM lt_update_query
             REPORTED DATA(ls_upd_reported).

      reported = CORRESPONDING #( DEEP ls_upd_reported ).
    ENDIF.
  ENDMETHOD.
  METHOD checkquerystatus.
    DATA lt_not_found LIKE keys.

    IF keys IS INITIAL.
      RETURN.
    ENDIF.

    READ ENTITIES OF zr_pru_axc_head IN LOCAL MODE
         ENTITY executionquery
         FIELDS ( AIPF7QueryStatus )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_query).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).

      APPEND INITIAL LINE TO reported-executionquery ASSIGNING FIELD-SYMBOL(<ls_inval>).
      <ls_inval>-%tky        = <ls_key>-%tky.
      <ls_inval>-%state_area = state_area-checkquerystatus.

      ASSIGN lt_query[ KEY id COMPONENTS %tky = <ls_key>-%tky ] TO FIELD-SYMBOL(<ls_query>).
      IF sy-subrc <> 0.
        APPEND INITIAL LINE TO lt_not_found ASSIGNING FIELD-SYMBOL(<ls_not_found>).
        <ls_not_found> = <ls_key>.
        CONTINUE.
      ENDIF.

      IF <ls_query>-AIPF7QueryStatus IS INITIAL.
        APPEND INITIAL LINE TO failed-executionquery ASSIGNING FIELD-SYMBOL(<ls_fail>).
        <ls_fail>-%tky        = <ls_query>-%tky.
        <ls_fail>-%fail-cause = if_abap_behv=>cause-conflict.

        APPEND INITIAL LINE TO reported-executionquery ASSIGNING FIELD-SYMBOL(<ls_report>).
        <ls_report>-%tky        = <ls_query>-%tky.
        <ls_report>-%state_area = state_area-checkquerystatus.
        <ls_report>-%element-AIPF7QueryStatus = if_abap_behv=>mk-on.
        <ls_report>-%msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = |Query status must not be initial.| ).
        CONTINUE.
      ENDIF.

      IF NOT ( <ls_query>-AIPF7QueryStatus = 'N'
            OR <ls_query>-AIPF7QueryStatus = 'E'
            OR <ls_query>-AIPF7QueryStatus = 'C' ).
        APPEND INITIAL LINE TO failed-executionquery ASSIGNING <ls_fail>.
        <ls_fail>-%tky        = <ls_query>-%tky.
        <ls_fail>-%fail-cause = if_abap_behv=>cause-conflict.

        APPEND INITIAL LINE TO reported-executionquery ASSIGNING <ls_report>.
        <ls_report>-%tky        = <ls_query>-%tky.
        <ls_report>-%state_area = state_area-checkquerystatus.
        <ls_report>-%element-AIPF7QueryStatus = if_abap_behv=>mk-on.
        <ls_report>-%msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = |Query status '{ <ls_query>-AIPF7QueryStatus }' is invalid. Valid values are: N (New), E (Error), C (Complete).| ).
      ENDIF.

    ENDLOOP.

    LOOP AT lt_not_found ASSIGNING <ls_not_found>.
      APPEND INITIAL LINE TO failed-executionquery ASSIGNING <ls_fail>.
      <ls_fail>-%tky        = <ls_not_found>-%tky.
      <ls_fail>-%fail-cause = if_abap_behv=>cause-not_found.

      APPEND INITIAL LINE TO reported-executionquery ASSIGNING <ls_report>.
      <ls_report>-%tky        = <ls_not_found>-%tky.
      <ls_report>-%state_area = state_area-checkquerystatus.
      <ls_report>-%msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text     = |Execution query not found.| ).
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.


CLASS lhc_executionstep DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.
    CONSTANTS:
      BEGIN OF state_area,
        checktooluuid         TYPE string VALUE 'CHECKTOOLUUID',
        checkstepstatus       TYPE string VALUE 'CHECKSTEPSTATUS',
        checkstepsequence     TYPE string VALUE 'CHECKSTEPSEQUENCE',
        checkstepsequenceunique TYPE string VALUE 'CHECKSTEPSEQUENCEUNIQUE',
      END OF state_area.

    METHODS generatestepid FOR DETERMINE ON MODIFY
      IMPORTING keys FOR executionstep~generatestepid.
    METHODS checktooluuid FOR VALIDATE ON SAVE
      IMPORTING keys FOR executionstep~checkToolUuid.
    METHODS checkstepstatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR executionstep~checkStepStatus.
    METHODS checkstepsequence FOR VALIDATE ON SAVE
      IMPORTING keys FOR executionstep~checkStepSequence.
    METHODS checkstepsequenceunique FOR VALIDATE ON SAVE
      IMPORTING keys FOR executionstep~checkStepSequenceUnique.

ENDCLASS.


CLASS lhc_executionstep IMPLEMENTATION.
  METHOD generatestepid.
    DATA lv_number          TYPE zpru_de_step_number.
    DATA lv_number_buffered TYPE zpru_de_step_number.
    DATA lt_update_step     TYPE TABLE FOR UPDATE zr_pru_axc_head\\executionstep.

    READ ENTITIES OF zr_pru_axc_head
         IN LOCAL MODE
         ENTITY executionstep
         FIELDS ( aipf7runuuid aipf7queryuuid ) WITH CORRESPONDING #( keys )
         RESULT DATA(lt_steps).

    IF lt_steps IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT lt_steps ASSIGNING FIELD-SYMBOL(<ls_step_group>)
         GROUP BY ( aipf7runuuid   = <ls_step_group>-aipf7runuuid
                    aipf7queryuuid = <ls_step_group>-aipf7queryuuid )
         ASSIGNING FIELD-SYMBOL(<ls_step_key>).

      CLEAR: lv_number,
             lv_number_buffered.

      SELECT aipf7runuuid,
             aipf7queryuuid,
             aipf7stepuuid,
             aipf7stepnumber
        FROM zi_pru_axc_step
        WHERE aipf7runuuid   = @<ls_step_key>-aipf7runuuid
          AND aipf7queryuuid = @<ls_step_key>-aipf7queryuuid
        ORDER BY aipf7stepnumber DESCENDING
        INTO TABLE @DATA(lt_last_id)
        UP TO 1 ROWS.
      IF sy-subrc = 0.
        ASSIGN lt_last_id[ 1 ] TO FIELD-SYMBOL(<ls_number_db>).
        IF sy-subrc = 0.
          DATA(lt_buffer_copy) = lcl_buffer=>st_step_count.
          DELETE lt_buffer_copy WHERE    aipf7runuuid   <> <ls_step_key>-aipf7runuuid
                                      OR aipf7queryuuid <> <ls_step_key>-aipf7queryuuid.
          SORT lt_buffer_copy BY aipf7stepnumber DESCENDING.

          lv_number_buffered = VALUE #( lt_buffer_copy[ 1 ]-aipf7stepnumber OPTIONAL ).

          IF lv_number_buffered < <ls_number_db>-aipf7stepnumber.
            APPEND INITIAL LINE TO lcl_buffer=>st_step_count ASSIGNING FIELD-SYMBOL(<ls_step_count>).
            <ls_step_count>-aipf7runuuid    = <ls_number_db>-aipf7runuuid.
            <ls_step_count>-aipf7queryuuid  = <ls_number_db>-aipf7queryuuid.
            <ls_step_count>-aipf7stepuuid   = <ls_number_db>-aipf7stepuuid.
            <ls_step_count>-aipf7stepnumber = <ls_number_db>-aipf7stepnumber.
          ENDIF.
        ENDIF.
      ENDIF.

      lt_buffer_copy = lcl_buffer=>st_step_count.
      DELETE lt_buffer_copy WHERE    aipf7runuuid   <> <ls_step_key>-aipf7runuuid
                                  OR aipf7queryuuid <> <ls_step_key>-aipf7queryuuid.

      IF lt_buffer_copy IS NOT INITIAL.
        SORT lt_buffer_copy BY aipf7stepnumber DESCENDING.
        lv_number = VALUE #( lt_buffer_copy[ 1 ]-aipf7stepnumber OPTIONAL ).
      ELSE.
        lv_number = '0000000000'.
      ENDIF.

      LOOP AT GROUP <ls_step_key> ASSIGNING FIELD-SYMBOL(<ls_member>).

        lv_number += 1.

        APPEND INITIAL LINE TO lt_update_step ASSIGNING FIELD-SYMBOL(<ls_update>).
        <ls_update>-%tky            = <ls_member>-%tky.
        <ls_update>-aipf7stepnumber = lv_number.
        <ls_update>-%control-aipf7stepnumber = if_abap_behv=>mk-on.

        APPEND INITIAL LINE TO lcl_buffer=>st_step_count ASSIGNING <ls_step_count>.
        <ls_step_count>-aipf7runuuid    = <ls_member>-aipf7runuuid.
        <ls_step_count>-aipf7queryuuid  = <ls_member>-aipf7queryuuid.
        <ls_step_count>-aipf7stepuuid   = <ls_member>-aipf7stepuuid.
        <ls_step_count>-aipf7stepnumber = lv_number.
      ENDLOOP.

      CLEAR lt_last_id.

    ENDLOOP.

    IF lt_update_step IS NOT INITIAL.
      MODIFY ENTITIES OF zr_pru_axc_head
             IN LOCAL MODE
             ENTITY executionstep
             UPDATE FROM lt_update_step
             REPORTED DATA(ls_upd_reported).

      reported = CORRESPONDING #( DEEP ls_upd_reported ).
    ENDIF.
  ENDMETHOD.
  METHOD checktooluuid.
    DATA lt_not_found LIKE keys.

    IF keys IS INITIAL.
      RETURN.
    ENDIF.

    READ ENTITIES OF zr_pru_axc_head IN LOCAL MODE
         ENTITY executionstep
         FIELDS ( AIPF7ToolUuid )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_step).

    IF lt_step IS NOT INITIAL.
      SELECT AIPF7ToolUuid
        FROM zr_pru_agent_tool
        FOR ALL ENTRIES IN @lt_step
        WHERE AIPF7ToolUuid = @lt_step-AIPF7ToolUuid
        INTO TABLE @DATA(lt_existing_tools)
        PRIVILEGED ACCESS.
    ENDIF.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).

      APPEND INITIAL LINE TO reported-executionstep ASSIGNING FIELD-SYMBOL(<ls_inval>).
      <ls_inval>-%tky        = <ls_key>-%tky.
      <ls_inval>-%state_area = state_area-checktooluuid.

      ASSIGN lt_step[ KEY id COMPONENTS %tky = <ls_key>-%tky ] TO FIELD-SYMBOL(<ls_step>).
      IF sy-subrc <> 0.
        APPEND INITIAL LINE TO lt_not_found ASSIGNING FIELD-SYMBOL(<ls_not_found>).
        <ls_not_found> = <ls_key>.
        CONTINUE.
      ENDIF.

      IF <ls_step>-AIPF7ToolUuid IS INITIAL.
        APPEND INITIAL LINE TO failed-executionstep ASSIGNING FIELD-SYMBOL(<ls_fail>).
        <ls_fail>-%tky        = <ls_step>-%tky.
        <ls_fail>-%fail-cause = if_abap_behv=>cause-conflict.

        APPEND INITIAL LINE TO reported-executionstep ASSIGNING FIELD-SYMBOL(<ls_report>).
        <ls_report>-%tky        = <ls_step>-%tky.
        <ls_report>-%state_area = state_area-checktooluuid.
        <ls_report>-%element-AIPF7ToolUuid = if_abap_behv=>mk-on.
        <ls_report>-%msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = |Tool UUID must not be initial.| ).
        CONTINUE.
      ENDIF.

      IF NOT line_exists( lt_existing_tools[ AIPF7ToolUuid = <ls_step>-AIPF7ToolUuid ] ).
        APPEND INITIAL LINE TO failed-executionstep ASSIGNING <ls_fail>.
        <ls_fail>-%tky        = <ls_step>-%tky.
        <ls_fail>-%fail-cause = if_abap_behv=>cause-conflict.

        APPEND INITIAL LINE TO reported-executionstep ASSIGNING <ls_report>.
        <ls_report>-%tky        = <ls_step>-%tky.
        <ls_report>-%state_area = state_area-checktooluuid.
        <ls_report>-%element-AIPF7ToolUuid = if_abap_behv=>mk-on.
        <ls_report>-%msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = |Tool with UUID '{ <ls_step>-AIPF7ToolUuid }' does not exist.| ).
      ENDIF.

    ENDLOOP.

    LOOP AT lt_not_found ASSIGNING <ls_not_found>.
      APPEND INITIAL LINE TO failed-executionstep ASSIGNING <ls_fail>.
      <ls_fail>-%tky        = <ls_not_found>-%tky.
      <ls_fail>-%fail-cause = if_abap_behv=>cause-not_found.

      APPEND INITIAL LINE TO reported-executionstep ASSIGNING <ls_report>.
      <ls_report>-%tky        = <ls_not_found>-%tky.
      <ls_report>-%state_area = state_area-checktooluuid.
      <ls_report>-%msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text     = |Execution step not found.| ).
    ENDLOOP.
  ENDMETHOD.

  METHOD checkstepstatus.
    DATA lt_not_found LIKE keys.

    IF keys IS INITIAL.
      RETURN.
    ENDIF.

    READ ENTITIES OF zr_pru_axc_head IN LOCAL MODE
         ENTITY executionstep
         FIELDS ( AIPF7StepStatus )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_step).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).

      APPEND INITIAL LINE TO reported-executionstep ASSIGNING FIELD-SYMBOL(<ls_inval>).
      <ls_inval>-%tky        = <ls_key>-%tky.
      <ls_inval>-%state_area = state_area-checkstepstatus.

      ASSIGN lt_step[ KEY id COMPONENTS %tky = <ls_key>-%tky ] TO FIELD-SYMBOL(<ls_step>).
      IF sy-subrc <> 0.
        APPEND INITIAL LINE TO lt_not_found ASSIGNING FIELD-SYMBOL(<ls_not_found>).
        <ls_not_found> = <ls_key>.
        CONTINUE.
      ENDIF.

      IF <ls_step>-AIPF7StepStatus IS INITIAL.
        APPEND INITIAL LINE TO failed-executionstep ASSIGNING FIELD-SYMBOL(<ls_fail>).
        <ls_fail>-%tky        = <ls_step>-%tky.
        <ls_fail>-%fail-cause = if_abap_behv=>cause-conflict.

        APPEND INITIAL LINE TO reported-executionstep ASSIGNING FIELD-SYMBOL(<ls_report>).
        <ls_report>-%tky        = <ls_step>-%tky.
        <ls_report>-%state_area = state_area-checkstepstatus.
        <ls_report>-%element-AIPF7StepStatus = if_abap_behv=>mk-on.
        <ls_report>-%msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = |Step status must not be initial.| ).
        CONTINUE.
      ENDIF.

      IF NOT ( <ls_step>-AIPF7StepStatus = 'N'
            OR <ls_step>-AIPF7StepStatus = 'E'
            OR <ls_step>-AIPF7StepStatus = 'C' ).
        APPEND INITIAL LINE TO failed-executionstep ASSIGNING <ls_fail>.
        <ls_fail>-%tky        = <ls_step>-%tky.
        <ls_fail>-%fail-cause = if_abap_behv=>cause-conflict.

        APPEND INITIAL LINE TO reported-executionstep ASSIGNING <ls_report>.
        <ls_report>-%tky        = <ls_step>-%tky.
        <ls_report>-%state_area = state_area-checkstepstatus.
        <ls_report>-%element-AIPF7StepStatus = if_abap_behv=>mk-on.
        <ls_report>-%msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = |Step status '{ <ls_step>-AIPF7StepStatus }' is invalid. Valid values are: N (New), E (Error), C (Complete).| ).
      ENDIF.

    ENDLOOP.

    LOOP AT lt_not_found ASSIGNING <ls_not_found>.
      APPEND INITIAL LINE TO failed-executionstep ASSIGNING <ls_fail>.
      <ls_fail>-%tky        = <ls_not_found>-%tky.
      <ls_fail>-%fail-cause = if_abap_behv=>cause-not_found.

      APPEND INITIAL LINE TO reported-executionstep ASSIGNING <ls_report>.
      <ls_report>-%tky        = <ls_not_found>-%tky.
      <ls_report>-%state_area = state_area-checkstepstatus.
      <ls_report>-%msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text     = |Execution step not found.| ).
    ENDLOOP.
  ENDMETHOD.

  METHOD checkstepsequence.
    DATA lt_not_found LIKE keys.

    IF keys IS INITIAL.
      RETURN.
    ENDIF.

    READ ENTITIES OF zr_pru_axc_head IN LOCAL MODE
         ENTITY executionstep
         FIELDS ( AIPF7StepSequence )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_step).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).

      APPEND INITIAL LINE TO reported-executionstep ASSIGNING FIELD-SYMBOL(<ls_inval>).
      <ls_inval>-%tky        = <ls_key>-%tky.
      <ls_inval>-%state_area = state_area-checkstepsequence.

      ASSIGN lt_step[ KEY id COMPONENTS %tky = <ls_key>-%tky ] TO FIELD-SYMBOL(<ls_step>).
      IF sy-subrc <> 0.
        APPEND INITIAL LINE TO lt_not_found ASSIGNING FIELD-SYMBOL(<ls_not_found>).
        <ls_not_found> = <ls_key>.
        CONTINUE.
      ENDIF.

      IF <ls_step>-AIPF7StepSequence IS INITIAL.
        APPEND INITIAL LINE TO failed-executionstep ASSIGNING FIELD-SYMBOL(<ls_fail>).
        <ls_fail>-%tky        = <ls_step>-%tky.
        <ls_fail>-%fail-cause = if_abap_behv=>cause-conflict.

        APPEND INITIAL LINE TO reported-executionstep ASSIGNING FIELD-SYMBOL(<ls_report>).
        <ls_report>-%tky        = <ls_step>-%tky.
        <ls_report>-%state_area = state_area-checkstepsequence.
        <ls_report>-%element-AIPF7StepSequence = if_abap_behv=>mk-on.
        <ls_report>-%msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = |Step sequence must not be initial.| ).
      ENDIF.

    ENDLOOP.

    LOOP AT lt_not_found ASSIGNING <ls_not_found>.
      APPEND INITIAL LINE TO failed-executionstep ASSIGNING <ls_fail>.
      <ls_fail>-%tky        = <ls_not_found>-%tky.
      <ls_fail>-%fail-cause = if_abap_behv=>cause-not_found.

      APPEND INITIAL LINE TO reported-executionstep ASSIGNING <ls_report>.
      <ls_report>-%tky        = <ls_not_found>-%tky.
      <ls_report>-%state_area = state_area-checkstepsequence.
      <ls_report>-%msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text     = |Execution step not found.| ).
    ENDLOOP.
  ENDMETHOD.

  METHOD checkstepsequenceunique.
    DATA lt_not_found LIKE keys.

    IF keys IS INITIAL.
      RETURN.
    ENDIF.

    READ ENTITIES OF zr_pru_axc_head IN LOCAL MODE
         ENTITY executionstep
         FIELDS ( AIPF7RunUuid AIPF7StepSequence )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_step).

    IF lt_step IS NOT INITIAL.
      SELECT AIPF7StepUuid,
             AIPF7RunUuid,
             AIPF7StepSequence
        FROM zr_pru_axc_step
        FOR ALL ENTRIES IN @lt_step
        WHERE AIPF7RunUuid = @lt_step-AIPF7RunUuid
        INTO TABLE @DATA(lt_existing_steps)
        PRIVILEGED ACCESS.
    ENDIF.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).

      APPEND INITIAL LINE TO reported-executionstep ASSIGNING FIELD-SYMBOL(<ls_inval>).
      <ls_inval>-%tky        = <ls_key>-%tky.
      <ls_inval>-%state_area = state_area-checkstepsequenceunique.

      ASSIGN lt_step[ KEY id COMPONENTS %tky = <ls_key>-%tky ] TO FIELD-SYMBOL(<ls_step>).
      IF sy-subrc <> 0.
        APPEND INITIAL LINE TO lt_not_found ASSIGNING FIELD-SYMBOL(<ls_not_found>).
        <ls_not_found> = <ls_key>.
        CONTINUE.
      ENDIF.

      " Skip initial sequences (handled by checkstepsequence)
      IF <ls_step>-AIPF7StepSequence IS INITIAL.
        CONTINUE.
      ENDIF.

      " Check for duplicate sequence within the same run (exclude self)
      LOOP AT lt_existing_steps ASSIGNING FIELD-SYMBOL(<ls_exist>)
          WHERE AIPF7RunUuid       = <ls_step>-AIPF7RunUuid
            AND AIPF7StepSequence  = <ls_step>-AIPF7StepSequence
            AND AIPF7StepUuid     <> <ls_step>-AIPF7StepUuid.
        APPEND INITIAL LINE TO failed-executionstep ASSIGNING FIELD-SYMBOL(<ls_fail>).
        <ls_fail>-%tky        = <ls_step>-%tky.
        <ls_fail>-%fail-cause = if_abap_behv=>cause-conflict.

        APPEND INITIAL LINE TO reported-executionstep ASSIGNING FIELD-SYMBOL(<ls_report>).
        <ls_report>-%tky        = <ls_step>-%tky.
        <ls_report>-%state_area = state_area-checkstepsequenceunique.
        <ls_report>-%element-AIPF7StepSequence = if_abap_behv=>mk-on.
        <ls_report>-%msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = |Step sequence '{ <ls_step>-AIPF7StepSequence }' is already used within this execution run. Please use a unique sequence number.| ).
        EXIT.
      ENDLOOP.

    ENDLOOP.

    LOOP AT lt_not_found ASSIGNING <ls_not_found>.
      APPEND INITIAL LINE TO failed-executionstep ASSIGNING <ls_fail>.
      <ls_fail>-%tky        = <ls_not_found>-%tky.
      <ls_fail>-%fail-cause = if_abap_behv=>cause-not_found.

      APPEND INITIAL LINE TO reported-executionstep ASSIGNING <ls_report>.
      <ls_report>-%tky        = <ls_not_found>-%tky.
      <ls_report>-%state_area = state_area-checkstepsequenceunique.
      <ls_report>-%msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text     = |Execution step not found.| ).
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.


CLASS lsc_zr_pru_axc_head DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.
    METHODS save_modified REDEFINITION.

    METHODS cleanup       REDEFINITION.

ENDCLASS.


CLASS lsc_zr_pru_axc_head IMPLEMENTATION.
  METHOD save_modified.
    TYPES: BEGIN OF ts_head_key,
             runuuid TYPE sysuuid_x16,
           END OF ts_head_key.

    TYPES: BEGIN OF ts_query_key,
             queryuuid TYPE sysuuid_x16,
           END OF ts_query_key.

    TYPES: BEGIN OF ts_step_key,
             stepuuid TYPE sysuuid_x16,
           END OF ts_step_key.

    DATA lv_number        TYPE cl_numberrange_runtime=>nr_number.
    DATA lt_head_del_tab  TYPE STANDARD TABLE OF ts_head_key WITH EMPTY KEY.
    DATA lt_head_mod_tab  TYPE TABLE OF zpru_axc_head WITH EMPTY KEY.
    DATA lo_head_struct   TYPE REF TO cl_abap_structdescr.
    DATA lt_query_del_tab TYPE STANDARD TABLE OF ts_query_key WITH EMPTY KEY.
    DATA lt_query_mod_tab TYPE TABLE OF zpru_axc_query WITH EMPTY KEY.
    DATA lo_query_struct  TYPE REF TO cl_abap_structdescr.
    DATA lt_step_del_tab  TYPE STANDARD TABLE OF ts_step_key WITH EMPTY KEY.
    DATA lt_step_mod_tab  TYPE TABLE OF zpru_axc_step WITH EMPTY KEY.
    DATA lo_step_struct   TYPE REF TO cl_abap_structdescr.

    DATA lr_query_range   TYPE RANGE OF sysuuid_x16.
    DATA lr_step_range    TYPE RANGE OF sysuuid_x16.

    " create header
    LOOP AT create-executionheader ASSIGNING FIELD-SYMBOL(<ls_head_create>).

      TRY.
          cl_numberrange_runtime=>number_get( EXPORTING nr_range_nr = '01'
                                                        object      = 'ZPRU_AXCHD'
                                              IMPORTING number      = lv_number ).

        CATCH cx_nr_object_not_found
              cx_number_ranges.
          ASSERT 1 = 2.
      ENDTRY.

      APPEND INITIAL LINE TO lt_head_mod_tab ASSIGNING FIELD-SYMBOL(<ls_head_mod>).
      <ls_head_mod> = CORRESPONDING #( <ls_head_create> MAPPING FROM ENTITY ).
      <ls_head_mod>-runid = lv_number.
    ENDLOOP.

    " update header
    IF update-executionheader IS NOT INITIAL.

      SELECT * FROM zpru_axc_head
        FOR ALL ENTRIES IN @update-executionheader
        WHERE runuuid = @update-executionheader-aipf7runuuid
        INTO TABLE @DATA(lt_head_db).

      lo_head_struct ?= cl_abap_structdescr=>describe_by_name( p_name = `ZPRU_AXC_HEAD` ).
      DATA(lt_head_symbols) = lo_head_struct->get_symbols( ).

      LOOP AT update-executionheader ASSIGNING FIELD-SYMBOL(<ls_head_buffer>).

        ASSIGN lt_head_db[ runuuid = <ls_head_buffer>-aipf7runuuid ] TO FIELD-SYMBOL(<ls_head_db>).
        IF sy-subrc <> 0.
          ASSERT 1 = 2.
        ENDIF.

        APPEND INITIAL LINE TO lt_head_mod_tab ASSIGNING <ls_head_mod>.
        <ls_head_mod> = <ls_head_db>.

        LOOP AT lt_head_symbols ASSIGNING FIELD-SYMBOL(<ls_head_symbol>).

          DATA(lv_aipf7_field) = |AIPF7{ <ls_head_symbol>-name }|.

          ASSIGN COMPONENT lv_aipf7_field OF STRUCTURE <ls_head_buffer>-%control TO FIELD-SYMBOL(<lv_control>).
          IF sy-subrc <> 0.
            ASSERT 1 = 2.
          ENDIF.

          IF <lv_control> <> if_abap_behv=>mk-on.
            CONTINUE.
          ENDIF.

          ASSIGN COMPONENT <ls_head_symbol>-name OF STRUCTURE <ls_head_mod> TO FIELD-SYMBOL(<lv_head_target>).
          IF sy-subrc <> 0.
            ASSERT 1 = 2.
          ENDIF.

          ASSIGN COMPONENT <ls_head_symbol>-name OF STRUCTURE <ls_head_buffer> TO FIELD-SYMBOL(<lv_head_source>).
          IF sy-subrc <> 0.
            ASSERT 1 = 2.
          ENDIF.

          IF <lv_head_target> <> <lv_head_source>.
            <lv_head_target> = <lv_head_source>.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
    ENDIF.

    IF lt_head_mod_tab IS NOT INITIAL.
      MODIFY zpru_axc_head FROM TABLE @( CORRESPONDING #( lt_head_mod_tab ) ).
    ENDIF.

    " delete header
    LOOP AT delete-executionheader ASSIGNING FIELD-SYMBOL(<ls_head_delete>).
      APPEND VALUE #( runuuid = <ls_head_delete>-aipf7runuuid ) TO lt_head_del_tab.
    ENDLOOP.

    IF lt_head_del_tab IS NOT INITIAL.

      SELECT aipf7queryuuid AS queryuuid
        FROM zi_pru_axc_query
        FOR ALL ENTRIES IN @lt_head_del_tab
        WHERE aipf7runuuid = @lt_head_del_tab-runuuid
        INTO TABLE @lt_query_del_tab.

      DELETE zpru_axc_head FROM TABLE @( CORRESPONDING #( lt_head_del_tab ) ).
    ENDIF.

    " QUERY CREATE
    LOOP AT create-executionquery ASSIGNING FIELD-SYMBOL(<ls_query_create>).
      APPEND INITIAL LINE TO lt_query_mod_tab ASSIGNING FIELD-SYMBOL(<ls_query_mod>).
      <ls_query_mod> = CORRESPONDING #( <ls_query_create> MAPPING FROM ENTITY ).
    ENDLOOP.

    " update QUERY
    IF update-executionquery IS NOT INITIAL.

      lr_query_range = VALUE #( FOR <ls_q> IN update-executionquery
                                ( sign   = `I`
                                  option = `EQ`
                                  low    = <ls_q>-aipf7queryuuid ) ).

      SELECT * FROM zpru_axc_query
        WHERE queryuuid IN @lr_query_range
        INTO TABLE @DATA(lt_query_db).

      lo_query_struct ?= cl_abap_structdescr=>describe_by_name( p_name = `ZPRU_AXC_QUERY` ).
      DATA(lt_query_symbols) = lo_query_struct->get_symbols( ).

      LOOP AT update-executionquery ASSIGNING FIELD-SYMBOL(<ls_query_buffer>).

        ASSIGN lt_query_db[ queryuuid = <ls_query_buffer>-aipf7queryuuid ] TO FIELD-SYMBOL(<ls_query_db>).
        IF sy-subrc <> 0.
          ASSERT 1 = 2.
        ENDIF.

        APPEND INITIAL LINE TO lt_query_mod_tab ASSIGNING <ls_query_mod>.
        <ls_query_mod> = <ls_query_db>.

        LOOP AT lt_query_symbols ASSIGNING FIELD-SYMBOL(<ls_query_symbol>).

          lv_aipf7_field = |AIPF7{ <ls_query_symbol>-name }|.

          ASSIGN COMPONENT lv_aipf7_field OF STRUCTURE <ls_query_buffer>-%control TO <lv_control>.
          IF sy-subrc <> 0.
            ASSERT 1 = 2.
          ENDIF.

          IF <lv_control> <> if_abap_behv=>mk-on.
            CONTINUE.
          ENDIF.

          ASSIGN COMPONENT <ls_query_symbol>-name OF STRUCTURE <ls_query_mod> TO FIELD-SYMBOL(<lv_query_target>).
          IF sy-subrc <> 0.
            ASSERT 1 = 2.
          ENDIF.

          ASSIGN COMPONENT <ls_query_symbol>-name OF STRUCTURE <ls_query_buffer> TO FIELD-SYMBOL(<lv_query_source>).
          IF sy-subrc <> 0.
            ASSERT 1 = 2.
          ENDIF.

          IF <lv_query_target> <> <lv_query_source>.
            <lv_query_target> = <lv_query_source>.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
    ENDIF.

    IF lt_query_mod_tab IS NOT INITIAL.
      MODIFY zpru_axc_query FROM TABLE @( CORRESPONDING #( lt_query_mod_tab ) ).
    ENDIF.

    " delete QUERY
    LOOP AT delete-executionquery ASSIGNING FIELD-SYMBOL(<ls_query_delete>).
      APPEND VALUE #( queryuuid = <ls_query_delete>-aipf7queryuuid ) TO lt_query_del_tab.
    ENDLOOP.

    SORT lt_query_del_tab BY queryuuid.
    DELETE ADJACENT DUPLICATES FROM lt_query_del_tab COMPARING queryuuid.

    IF lt_query_del_tab IS NOT INITIAL.

      SELECT aipf7stepuuid AS stepuuid
        FROM zi_pru_axc_step
        FOR ALL ENTRIES IN @lt_query_del_tab
        WHERE aipf7queryuuid = @lt_query_del_tab-queryuuid
        INTO TABLE @lt_step_del_tab.

      DELETE zpru_axc_query FROM TABLE @( CORRESPONDING #( lt_query_del_tab ) ).
    ENDIF.

    " QUERY STEP
    LOOP AT create-executionstep ASSIGNING FIELD-SYMBOL(<ls_step_create>).
      APPEND INITIAL LINE TO lt_step_mod_tab ASSIGNING FIELD-SYMBOL(<ls_step_mod>).
      <ls_step_mod> = CORRESPONDING #( <ls_step_create> MAPPING FROM ENTITY ).
    ENDLOOP.

    " update STEP
    IF update-executionstep IS NOT INITIAL.

      lr_step_range = VALUE #( FOR <ls_s> IN update-executionstep
                               ( sign   = `I`
                                 option = `EQ`
                                 low    = <ls_s>-aipf7stepuuid ) ).

      SELECT * FROM zpru_axc_step
        WHERE stepuuid IN @lr_step_range
        INTO TABLE @DATA(lt_step_db).

      lo_step_struct ?= cl_abap_structdescr=>describe_by_name( p_name = `ZPRU_AXC_STEP` ).
      DATA(lt_step_symbols) = lo_step_struct->get_symbols( ).

      LOOP AT update-executionstep ASSIGNING FIELD-SYMBOL(<ls_step_buffer>).

        ASSIGN lt_step_db[ stepuuid = <ls_step_buffer>-aipf7stepuuid ] TO FIELD-SYMBOL(<ls_step_db>).
        IF sy-subrc <> 0.
          ASSERT 1 = 2.
        ENDIF.

        APPEND INITIAL LINE TO lt_step_mod_tab ASSIGNING <ls_step_mod>.
        <ls_step_mod> = <ls_step_db>.

        LOOP AT lt_step_symbols ASSIGNING FIELD-SYMBOL(<ls_step_symbol>).

          lv_aipf7_field = |AIPF7{ <ls_step_symbol>-name }|.

          ASSIGN COMPONENT lv_aipf7_field OF STRUCTURE <ls_step_buffer>-%control TO <lv_control>.
          IF sy-subrc <> 0.
            ASSERT 1 = 2.
          ENDIF.

          IF <lv_control> <> if_abap_behv=>mk-on.
            CONTINUE.
          ENDIF.

          ASSIGN COMPONENT <ls_step_symbol>-name OF STRUCTURE <ls_step_mod> TO FIELD-SYMBOL(<lv_step_target>).
          IF sy-subrc <> 0.
            ASSERT 1 = 2.
          ENDIF.

          ASSIGN COMPONENT <ls_step_symbol>-name OF STRUCTURE <ls_step_buffer> TO FIELD-SYMBOL(<lv_step_source>).
          IF sy-subrc <> 0.
            ASSERT 1 = 2.
          ENDIF.

          IF <lv_step_target> <> <lv_step_source>.
            <lv_step_target> = <lv_step_source>.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
    ENDIF.

    IF lt_step_mod_tab IS NOT INITIAL.
      MODIFY zpru_axc_step FROM TABLE @( CORRESPONDING #( lt_step_mod_tab ) ).
    ENDIF.

    " delete STEP
    LOOP AT delete-executionstep ASSIGNING FIELD-SYMBOL(<ls_step_delete>).
      APPEND VALUE #( stepuuid = <ls_step_delete>-aipf7stepuuid ) TO lt_step_del_tab.
    ENDLOOP.

    SORT lt_step_del_tab BY stepuuid.
    DELETE ADJACENT DUPLICATES FROM lt_step_del_tab COMPARING stepuuid.

    IF lt_step_del_tab IS NOT INITIAL.
      DELETE zpru_axc_step FROM TABLE @( CORRESPONDING #( lt_step_del_tab ) ).
    ENDIF.
  ENDMETHOD.

  METHOD cleanup.
    CLEAR lcl_buffer=>st_run_count.
    CLEAR lcl_buffer=>st_query_count.
    CLEAR lcl_buffer=>st_step_count.
  ENDMETHOD.
ENDCLASS.
