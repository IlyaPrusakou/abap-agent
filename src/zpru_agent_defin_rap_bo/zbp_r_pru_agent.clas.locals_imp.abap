CLASS lhc_zr_pru_agent DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    CONSTANTS:
      BEGIN OF state_area,
        checkagentname       TYPE string VALUE 'CHECKAGENTNAME',
        checkagenttype       TYPE string VALUE 'CHECKAGENTTYPE',
        checkdecisionprovider TYPE string VALUE 'CHECKDECISIONPROVIDER',
      END OF state_area.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
              IMPORTING
              REQUEST requested_authorizations FOR Agent
              RESULT result.
    METHODS checkagentname FOR VALIDATE ON SAVE
              IMPORTING keys FOR Agent~checkAgentName.
    METHODS checkagenttype FOR VALIDATE ON SAVE
              IMPORTING keys FOR Agent~checkAgentType.
    METHODS checkdecisionprovider FOR VALIDATE ON SAVE
              IMPORTING keys FOR Agent~checkDecisionProvider.
    METHODS changeDecisionEngine FOR MODIFY
              IMPORTING keys FOR ACTION Agent~changeDecisionEngine.
    METHODS precheck_create FOR PRECHECK
      IMPORTING entities FOR CREATE Agent.
ENDCLASS.


CLASS lhc_zr_pru_agent IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD checkagentname.
    DATA lt_not_found LIKE keys.

    IF keys IS INITIAL.
      RETURN.
    ENDIF.

    READ ENTITIES OF zr_pru_agent IN LOCAL MODE
         ENTITY Agent
         FIELDS ( AIPF7AgentUUID AIPF7AgentName )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_agent).

    IF lt_agent IS NOT INITIAL.
      SELECT AIPF7AgentUUID,
             AIPF7AgentName
        FROM zr_pru_agent
        FOR ALL ENTRIES IN  @lt_agent
        WHERE AIPF7AgentName = @lt_agent-AIPF7AgentName
        INTO TABLE @DATA(lt_existing_uuid)
        PRIVILEGED ACCESS.
    ENDIF.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).

      " Formal invalidation — clear previous validation state
      APPEND INITIAL LINE TO reported-agent ASSIGNING FIELD-SYMBOL(<ls_inval>).
      <ls_inval>-%tky        = <ls_key>-%tky.
      <ls_inval>-%state_area = state_area-checkagentname.

      ASSIGN lt_agent[ KEY id COMPONENTS %tky = <ls_key>-%tky ] TO FIELD-SYMBOL(<ls_agent>).
      IF sy-subrc <> 0.
        APPEND INITIAL LINE TO lt_not_found ASSIGNING FIELD-SYMBOL(<ls_not_found>).
        <ls_not_found> = <ls_key>.
        CONTINUE.
      ENDIF.

      IF NOT line_exists( lt_existing_uuid[ AIPF7AgentName = <ls_agent>-AIPF7AgentName ] ).
        CONTINUE.
      ENDIF.

      APPEND INITIAL LINE TO failed-agent ASSIGNING FIELD-SYMBOL(<ls_fail>).
      <ls_fail>-%tky        = <ls_agent>-%tky.
      <ls_fail>-%fail-cause = if_abap_behv=>cause-conflict.

      APPEND INITIAL LINE TO reported-agent ASSIGNING FIELD-SYMBOL(<ls_report>).
      <ls_report>-%tky        = <ls_agent>-%tky.
      <ls_report>-%state_area = state_area-checkagentname.
      <ls_report>-%msg        = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text     = |Agent name '{ <ls_agent>-AIPF7AgentName }' already exists. Please use a unique name.| ).

    ENDLOOP.

    LOOP AT lt_not_found ASSIGNING <ls_not_found>.
      APPEND INITIAL LINE TO failed-agent ASSIGNING <ls_fail>.
      <ls_fail>-%tky        = <ls_not_found>-%tky.
      <ls_fail>-%fail-cause = if_abap_behv=>cause-not_found.

      APPEND INITIAL LINE TO reported-agent ASSIGNING <ls_report>.
      <ls_report>-%tky        = <ls_not_found>-%tky.
      <ls_report>-%state_area = state_area-checkagentname.
      <ls_report>-%msg        = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                       text     = |Agent not found.| ).
    ENDLOOP.
  ENDMETHOD.

  METHOD checkagenttype.
    DATA lt_not_found LIKE keys.

    IF keys IS INITIAL.
      RETURN.
    ENDIF.

    READ ENTITIES OF zr_pru_agent IN LOCAL MODE
         ENTITY Agent
         FIELDS ( AIPF7AgentType )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_agent).

    IF lt_agent IS NOT INITIAL.
      SELECT AIPF7AgentType
        FROM ZR_PRU_AGENT_TYPE
        FOR ALL ENTRIES IN @lt_agent
        WHERE AIPF7AgentType = @lt_agent-AIPF7AgentType
        INTO TABLE @DATA(lt_valid_types)
        PRIVILEGED ACCESS.
    ENDIF.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).

      " Formal invalidation — clear previous validation state
      APPEND INITIAL LINE TO reported-agent ASSIGNING FIELD-SYMBOL(<ls_inval>).
      <ls_inval>-%tky        = <ls_key>-%tky.
      <ls_inval>-%state_area = state_area-checkagenttype.

      ASSIGN lt_agent[ KEY id COMPONENTS %tky = <ls_key>-%tky ] TO FIELD-SYMBOL(<ls_agent>).
      IF sy-subrc <> 0.
        APPEND INITIAL LINE TO lt_not_found ASSIGNING FIELD-SYMBOL(<ls_not_found>).
        <ls_not_found> = <ls_key>.
        CONTINUE.
      ENDIF.

      IF <ls_agent>-AIPF7AgentType IS INITIAL.
        APPEND INITIAL LINE TO failed-agent ASSIGNING FIELD-SYMBOL(<ls_fail>).
        <ls_fail>-%tky        = <ls_agent>-%tky.
        <ls_fail>-%fail-cause = if_abap_behv=>cause-conflict.

        APPEND INITIAL LINE TO reported-agent ASSIGNING FIELD-SYMBOL(<ls_report>).
        <ls_report>-%tky        = <ls_agent>-%tky.
        <ls_report>-%state_area = state_area-checkagenttype.
        <ls_report>-%msg        = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = |Agent type must not be initial.| ).
        CONTINUE.
      ENDIF.

      IF NOT line_exists( lt_valid_types[ AIPF7AgentType = <ls_agent>-AIPF7AgentType ] ).
        APPEND INITIAL LINE TO failed-agent ASSIGNING <ls_fail>.
        <ls_fail>-%tky        = <ls_agent>-%tky.
        <ls_fail>-%fail-cause = if_abap_behv=>cause-conflict.

        APPEND INITIAL LINE TO reported-agent ASSIGNING <ls_report>.
        <ls_report>-%tky        = <ls_agent>-%tky.
        <ls_report>-%state_area = state_area-checkagenttype.
        <ls_report>-%msg        = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = |Agent type '{ <ls_agent>-AIPF7AgentType }' does not exist in ZPRU_AGENT_TYPE.| ).
      ENDIF.

    ENDLOOP.

    LOOP AT lt_not_found ASSIGNING <ls_not_found>.
      APPEND INITIAL LINE TO failed-agent ASSIGNING <ls_fail>.
      <ls_fail>-%tky        = <ls_not_found>-%tky.
      <ls_fail>-%fail-cause = if_abap_behv=>cause-not_found.

      APPEND INITIAL LINE TO reported-agent ASSIGNING <ls_report>.
      <ls_report>-%tky        = <ls_not_found>-%tky.
      <ls_report>-%state_area = state_area-checkagenttype.
      <ls_report>-%msg        = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                       text     = |Agent not found.| ).
    ENDLOOP.
  ENDMETHOD.

  METHOD checkdecisionprovider.
    DATA lt_not_found LIKE keys.

    IF keys IS INITIAL.
      RETURN.
    ENDIF.

    READ ENTITIES OF zr_pru_agent IN LOCAL MODE
         ENTITY Agent
         FIELDS ( AIPF7DecisionProvider )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_agent).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).

      " Formal invalidation — clear previous validation state
      APPEND INITIAL LINE TO reported-agent ASSIGNING FIELD-SYMBOL(<ls_inval>).
      <ls_inval>-%tky        = <ls_key>-%tky.
      <ls_inval>-%state_area = state_area-checkdecisionprovider.

      ASSIGN lt_agent[ KEY id COMPONENTS %tky = <ls_key>-%tky ] TO FIELD-SYMBOL(<ls_agent>).
      IF sy-subrc <> 0.
        APPEND INITIAL LINE TO lt_not_found ASSIGNING FIELD-SYMBOL(<ls_not_found>).
        <ls_not_found> = <ls_key>.
        CONTINUE.
      ENDIF.

      IF <ls_agent>-AIPF7DecisionProvider IS INITIAL.
        APPEND INITIAL LINE TO failed-agent ASSIGNING FIELD-SYMBOL(<ls_fail>).
        <ls_fail>-%tky        = <ls_agent>-%tky.
        <ls_fail>-%fail-cause = if_abap_behv=>cause-conflict.

        APPEND INITIAL LINE TO reported-agent ASSIGNING FIELD-SYMBOL(<ls_report>).
        <ls_report>-%tky        = <ls_agent>-%tky.
        <ls_report>-%state_area = state_area-checkdecisionprovider.
        <ls_report>-%msg        = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = |Decision provider must not be initial.| ).
        CONTINUE.
      ENDIF.

      TRY.
          DATA(lo_desc) = CAST cl_abap_classdescr( cl_abap_typedescr=>describe_by_name( <ls_agent>-AIPF7DecisionProvider ) ).
          DATA(lv_implements) = abap_false.
          LOOP AT lo_desc->interfaces ASSIGNING FIELD-SYMBOL(<ls_intf>).
            IF <ls_intf>-name = 'ZPRU_IF_DECISION_PROVIDER'.
              lv_implements = abap_true.
              EXIT.
            ENDIF.
          ENDLOOP.
          IF lv_implements = abap_false.
            APPEND INITIAL LINE TO failed-agent ASSIGNING <ls_fail>.
            <ls_fail>-%tky        = <ls_agent>-%tky.
            <ls_fail>-%fail-cause = if_abap_behv=>cause-conflict.

            APPEND INITIAL LINE TO reported-agent ASSIGNING <ls_report>.
            <ls_report>-%tky        = <ls_agent>-%tky.
            <ls_report>-%state_area = state_area-checkdecisionprovider.
            <ls_report>-%msg        = new_message_with_text(
                severity = if_abap_behv_message=>severity-error
                text     = |Class '{ <ls_agent>-AIPF7DecisionProvider }' does not implement ZPRU_IF_DECISION_PROVIDER.| ).
            CONTINUE.
          ENDIF.
        CATCH cx_root.
          APPEND INITIAL LINE TO failed-agent ASSIGNING <ls_fail>.
          <ls_fail>-%tky        = <ls_agent>-%tky.
          <ls_fail>-%fail-cause = if_abap_behv=>cause-conflict.

          APPEND INITIAL LINE TO reported-agent ASSIGNING <ls_report>.
          <ls_report>-%tky        = <ls_agent>-%tky.
          <ls_report>-%state_area = state_area-checkdecisionprovider.
          <ls_report>-%msg        = new_message_with_text(
              severity = if_abap_behv_message=>severity-error
              text     = |Class '{ <ls_agent>-AIPF7DecisionProvider }' does not exist.| ).
          CONTINUE.
      ENDTRY.

    ENDLOOP.

    LOOP AT lt_not_found ASSIGNING <ls_not_found>.
      APPEND INITIAL LINE TO failed-agent ASSIGNING <ls_fail>.
      <ls_fail>-%tky        = <ls_not_found>-%tky.
      <ls_fail>-%fail-cause = if_abap_behv=>cause-not_found.

      APPEND INITIAL LINE TO reported-agent ASSIGNING <ls_report>.
      <ls_report>-%tky        = <ls_not_found>-%tky.
      <ls_report>-%state_area = state_area-checkdecisionprovider.
      <ls_report>-%msg        = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                       text     = |Agent not found.| ).
    ENDLOOP.
  ENDMETHOD.

  METHOD changeDecisionEngine.
    DATA lt_update TYPE TABLE FOR UPDATE zr_pru_agent.

    " 1. Check empty input
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).
      IF <ls_key>-%param-AIPF7DecisionProvider IS INITIAL.
        APPEND INITIAL LINE TO failed-agent ASSIGNING FIELD-SYMBOL(<ls_fail>).
        <ls_fail>-%tky        = <ls_key>-%tky.
        <ls_fail>-%fail-cause = if_abap_behv=>cause-conflict.

        APPEND INITIAL LINE TO reported-agent ASSIGNING FIELD-SYMBOL(<ls_report>).
        <ls_report>-%tky        = <ls_key>-%tky.
        <ls_report>-%msg        = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = |Decision provider must not be empty.| ).
      ENDIF.
    ENDLOOP.

    IF failed-agent IS NOT INITIAL.
      RETURN.
    ENDIF.

    " 2. Read entities
    READ ENTITIES OF zr_pru_agent IN LOCAL MODE
         ENTITY Agent
         FIELDS ( AIPF7DecisionProvider )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_agent)
         FAILED DATA(ls_read_failed).

    " 3. Handle not found
    IF ls_read_failed-agent IS NOT INITIAL.
      LOOP AT ls_read_failed-agent ASSIGNING FIELD-SYMBOL(<ls_read_fail>).
        APPEND INITIAL LINE TO failed-agent ASSIGNING <ls_fail>.
        <ls_fail>-%tky        = <ls_read_fail>-%tky.
        <ls_fail>-%fail-cause = if_abap_behv=>cause-not_found.

        APPEND INITIAL LINE TO reported-agent ASSIGNING <ls_report>.
        <ls_report>-%tky        = <ls_read_fail>-%tky.
        <ls_report>-%msg        = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = |Agent not found.| ).
      ENDLOOP.
      RETURN.
    ENDIF.

    " 4. Loop — fill local update variable + %control explicitly
    LOOP AT lt_agent ASSIGNING FIELD-SYMBOL(<ls_agent>).
      APPEND INITIAL LINE TO lt_update ASSIGNING FIELD-SYMBOL(<ls_update>).
      <ls_update>-%tky                       = <ls_agent>-%tky.
      <ls_update>-AIPF7DecisionProvider       = <ls_key>-%param-AIPF7DecisionProvider.
    ENDLOOP.

    " 5. Single MODIFY ENTITIES if anything to update
    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zr_pru_agent IN LOCAL MODE
             ENTITY Agent
             UPDATE FIELDS ( AIPF7DecisionProvider )
             WITH lt_update.
    ENDIF.
  ENDMETHOD.

  METHOD precheck_create.
    IF entities IS INITIAL.
      RETURN.
    ENDIF.

    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA lt_name_count TYPE SORTED TABLE OF string WITH UNIQUE KEY table_line.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entity>).
      INSERT CONV string( <ls_entity>-AIPF7AgentName ) INTO TABLE lt_name_count.
      IF sy-subrc = 0.
        CONTINUE.
      ENDIF.

      " Duplicate within the same request
      APPEND INITIAL LINE TO failed-agent ASSIGNING FIELD-SYMBOL(<ls_fail>).
      <ls_fail>-%key      = <ls_entity>-%key.
      <ls_fail>-%is_draft = <ls_entity>-%is_draft.
      <ls_fail>-%fail-cause = if_abap_behv=>cause-conflict.

      APPEND INITIAL LINE TO reported-agent ASSIGNING FIELD-SYMBOL(<ls_report>).
      <ls_report>-%key      = <ls_entity>-%key.
      <ls_report>-%is_draft = <ls_entity>-%is_draft.
      <ls_report>-%msg      = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text     = |Duplicate agent name '{ <ls_entity>-AIPF7AgentName }' in the same request. Please use a unique name.| ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
