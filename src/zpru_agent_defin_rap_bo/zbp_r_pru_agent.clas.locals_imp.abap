CLASS lhc_zr_pru_agent DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    CONSTANTS:
      BEGIN OF state_area,
        checkagentname            TYPE string VALUE 'CHECKAGENTNAME',
        checkagenttype            TYPE string VALUE 'CHECKAGENTTYPE',
        checkdecisionprovider     TYPE string VALUE 'CHECKDECISIONPROVIDER',
        checkshortmemoryprovider  TYPE string VALUE 'CHECKSHORTMEMORYPROVIDER',
        checklongmemoryprovider   TYPE string VALUE 'CHECKLONGMEMORYPROVIDER',
        checksystempromptprovider TYPE string VALUE 'CHECKSYSTEMPROMPTPROVIDER',
        checkagentmapper          TYPE string VALUE 'CHECKAGENTMAPPER',
        checkagentinfoprovider    TYPE string VALUE 'CHECKAGENTINFOPROVIDER',
        checkagentstatus          TYPE string VALUE 'CHECKAGENTSTATUS',
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
    METHODS checkshortmemoryprovider FOR VALIDATE ON SAVE
      IMPORTING keys FOR Agent~checkShortMemoryProvider.
    METHODS checklongmemoryprovider FOR VALIDATE ON SAVE
      IMPORTING keys FOR Agent~checkLongMemoryProvider.
    METHODS checksystempromptprovider FOR VALIDATE ON SAVE
      IMPORTING keys FOR Agent~checkSystemPromptProvider.
    METHODS checkagentmapper FOR VALIDATE ON SAVE
      IMPORTING keys FOR Agent~checkAgentMapper.
    METHODS changeDecisionEngine FOR MODIFY
      IMPORTING keys FOR ACTION Agent~changeDecisionEngine.
    METHODS changeshortmemoryprovider FOR MODIFY
      IMPORTING keys FOR ACTION Agent~changeShortMemoryProvider.
    METHODS changelongmemoryprovider FOR MODIFY
      IMPORTING keys FOR ACTION Agent~changeLongMemoryProvider.
    METHODS changesystempromptprovider FOR MODIFY
      IMPORTING keys FOR ACTION Agent~changeSystemPromptProvider.
    METHODS changeagentmapper FOR MODIFY
      IMPORTING keys FOR ACTION Agent~changeAgentMapper.
    METHODS changeagentstatus FOR MODIFY
      IMPORTING keys FOR ACTION Agent~changeAgentStatus.
    METHODS changeagentinfoprovider FOR MODIFY
      IMPORTING keys FOR ACTION Agent~changeAgentInfoProvider.
    METHODS fillagentmapper FOR DETERMINE ON SAVE
      IMPORTING keys FOR Agent~fillAgentMapper.
    METHODS fillagentstatus FOR DETERMINE ON SAVE
      IMPORTING keys FOR Agent~fillAgentStatus.
    METHODS checkagentinfoprovider FOR VALIDATE ON SAVE
      IMPORTING keys FOR Agent~checkAgentInfoProvider.
    METHODS checkagentstatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR Agent~checkAgentStatus.
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
      <ls_report>-%element-AIPF7AgentName = if_abap_behv=>mk-on.
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
        FROM zr_pru_agent_type
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
        <ls_report>-%element-AIPF7AgentType = if_abap_behv=>mk-on.
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
        <ls_report>-%element-AIPF7AgentType = if_abap_behv=>mk-on.
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
        <ls_report>-%element-AIPF7DecisionProvider = if_abap_behv=>mk-on.
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
            <ls_report>-%element-AIPF7DecisionProvider = if_abap_behv=>mk-on.
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
          <ls_report>-%element-AIPF7DecisionProvider = if_abap_behv=>mk-on.
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
    DATA lt_update TYPE TABLE FOR UPDATE zr_pru_agent\\Agent.

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
    LOOP AT keys ASSIGNING <ls_key>.
      ASSIGN lt_agent[ KEY id COMPONENTS %tky = <ls_key>-%tky ] TO FIELD-SYMBOL(<ls_agent>).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      APPEND INITIAL LINE TO lt_update ASSIGNING FIELD-SYMBOL(<ls_update>).
      <ls_update>-%tky                       = <ls_agent>-%tky.
      <ls_update>-AIPF7DecisionProvider       = <ls_key>-%param-AIPF7DecisionProvider.
      <ls_update>-%control-AIPF7DecisionProvider = if_abap_behv=>mk-on.
    ENDLOOP.

    " 5. Single MODIFY ENTITIES if anything to update
    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zr_pru_agent IN LOCAL MODE
             ENTITY Agent
             UPDATE FIELDS ( AIPF7DecisionProvider )
             WITH lt_update.
    ENDIF.
  ENDMETHOD.

  METHOD checkshortmemoryprovider.
    DATA lt_not_found LIKE keys.

    IF keys IS INITIAL.
      RETURN.
    ENDIF.

    READ ENTITIES OF zr_pru_agent IN LOCAL MODE
         ENTITY Agent
         FIELDS ( AIPF7ShortMemoryProvider )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_agent).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).

      " Formal invalidation — clear previous validation state
      APPEND INITIAL LINE TO reported-agent ASSIGNING FIELD-SYMBOL(<ls_inval>).
      <ls_inval>-%tky        = <ls_key>-%tky.
      <ls_inval>-%state_area = state_area-checkshortmemoryprovider.

      ASSIGN lt_agent[ KEY id COMPONENTS %tky = <ls_key>-%tky ] TO FIELD-SYMBOL(<ls_agent>).
      IF sy-subrc <> 0.
        APPEND INITIAL LINE TO lt_not_found ASSIGNING FIELD-SYMBOL(<ls_not_found>).
        <ls_not_found> = <ls_key>.
        CONTINUE.
      ENDIF.

      IF <ls_agent>-AIPF7ShortMemoryProvider IS INITIAL.
        APPEND INITIAL LINE TO failed-agent ASSIGNING FIELD-SYMBOL(<ls_fail>).
        <ls_fail>-%tky        = <ls_agent>-%tky.
        <ls_fail>-%fail-cause = if_abap_behv=>cause-conflict.

        APPEND INITIAL LINE TO reported-agent ASSIGNING FIELD-SYMBOL(<ls_report>).
        <ls_report>-%tky        = <ls_agent>-%tky.
        <ls_report>-%state_area = state_area-checkshortmemoryprovider.
        <ls_report>-%element-AIPF7ShortMemoryProvider = if_abap_behv=>mk-on.
        <ls_report>-%msg        = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = |Short memory provider must not be initial.| ).
        CONTINUE.
      ENDIF.

      TRY.
          DATA(lo_desc) = CAST cl_abap_classdescr( cl_abap_typedescr=>describe_by_name( <ls_agent>-AIPF7ShortMemoryProvider ) ).
          DATA(lv_implements) = abap_false.
          LOOP AT lo_desc->interfaces ASSIGNING FIELD-SYMBOL(<ls_intf>).
            IF <ls_intf>-name = 'ZPRU_IF_SHORT_MEMORY_PROVIDER'.
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
            <ls_report>-%state_area = state_area-checkshortmemoryprovider.
            <ls_report>-%element-AIPF7ShortMemoryProvider = if_abap_behv=>mk-on.
            <ls_report>-%msg        = new_message_with_text(
                severity = if_abap_behv_message=>severity-error
                text     = |Class '{ <ls_agent>-AIPF7ShortMemoryProvider }' does not implement ZPRU_IF_SHORT_MEMORY_PROVIDER.| ).
            CONTINUE.
          ENDIF.
        CATCH cx_root.
          APPEND INITIAL LINE TO failed-agent ASSIGNING <ls_fail>.
          <ls_fail>-%tky        = <ls_agent>-%tky.
          <ls_fail>-%fail-cause = if_abap_behv=>cause-conflict.

          APPEND INITIAL LINE TO reported-agent ASSIGNING <ls_report>.
          <ls_report>-%tky        = <ls_agent>-%tky.
          <ls_report>-%state_area = state_area-checkshortmemoryprovider.
          <ls_report>-%element-AIPF7ShortMemoryProvider = if_abap_behv=>mk-on.
          <ls_report>-%msg        = new_message_with_text(
              severity = if_abap_behv_message=>severity-error
              text     = |Class '{ <ls_agent>-AIPF7ShortMemoryProvider }' does not exist.| ).
          CONTINUE.
      ENDTRY.

    ENDLOOP.

    LOOP AT lt_not_found ASSIGNING <ls_not_found>.
      APPEND INITIAL LINE TO failed-agent ASSIGNING <ls_fail>.
      <ls_fail>-%tky        = <ls_not_found>-%tky.
      <ls_fail>-%fail-cause = if_abap_behv=>cause-not_found.

      APPEND INITIAL LINE TO reported-agent ASSIGNING <ls_report>.
      <ls_report>-%tky        = <ls_not_found>-%tky.
      <ls_report>-%state_area = state_area-checkshortmemoryprovider.
      <ls_report>-%msg        = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                       text     = |Agent not found.| ).
    ENDLOOP.
  ENDMETHOD.

  METHOD changeshortmemoryprovider.
    DATA lt_update TYPE TABLE FOR UPDATE zr_pru_agent\\Agent.

    " 1. Check empty input
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).
      IF <ls_key>-%param-AIPF7ShortMemoryProvider IS INITIAL.
        APPEND INITIAL LINE TO failed-agent ASSIGNING FIELD-SYMBOL(<ls_fail>).
        <ls_fail>-%tky        = <ls_key>-%tky.
        <ls_fail>-%fail-cause = if_abap_behv=>cause-conflict.

        APPEND INITIAL LINE TO reported-agent ASSIGNING FIELD-SYMBOL(<ls_report>).
        <ls_report>-%tky        = <ls_key>-%tky.
        <ls_report>-%msg        = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = |Short memory provider must not be empty.| ).
      ENDIF.
    ENDLOOP.

    IF failed-agent IS NOT INITIAL.
      RETURN.
    ENDIF.

    " 2. Read entities
    READ ENTITIES OF zr_pru_agent IN LOCAL MODE
         ENTITY Agent
         FIELDS ( AIPF7ShortMemoryProvider )
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
    LOOP AT keys ASSIGNING <ls_key>.
      ASSIGN lt_agent[ KEY id COMPONENTS %tky = <ls_key>-%tky ] TO FIELD-SYMBOL(<ls_agent>).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      APPEND INITIAL LINE TO lt_update ASSIGNING FIELD-SYMBOL(<ls_update>).
      <ls_update>-%tky                           = <ls_agent>-%tky.
      <ls_update>-AIPF7ShortMemoryProvider        = <ls_key>-%param-AIPF7ShortMemoryProvider.
      <ls_update>-%control-AIPF7ShortMemoryProvider = if_abap_behv=>mk-on.
    ENDLOOP.

    " 5. Single MODIFY ENTITIES if anything to update
    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zr_pru_agent IN LOCAL MODE
             ENTITY Agent
             UPDATE FIELDS ( AIPF7ShortMemoryProvider )
             WITH lt_update.
    ENDIF.
  ENDMETHOD.

  METHOD checklongmemoryprovider.
    DATA lt_not_found LIKE keys.

    IF keys IS INITIAL.
      RETURN.
    ENDIF.

    READ ENTITIES OF zr_pru_agent IN LOCAL MODE
         ENTITY Agent
         FIELDS ( AIPF7LongMemoryProvider )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_agent).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).

      " Formal invalidation — clear previous validation state
      APPEND INITIAL LINE TO reported-agent ASSIGNING FIELD-SYMBOL(<ls_inval>).
      <ls_inval>-%tky        = <ls_key>-%tky.
      <ls_inval>-%state_area = state_area-checklongmemoryprovider.

      ASSIGN lt_agent[ KEY id COMPONENTS %tky = <ls_key>-%tky ] TO FIELD-SYMBOL(<ls_agent>).
      IF sy-subrc <> 0.
        APPEND INITIAL LINE TO lt_not_found ASSIGNING FIELD-SYMBOL(<ls_not_found>).
        <ls_not_found> = <ls_key>.
        CONTINUE.
      ENDIF.

      IF <ls_agent>-AIPF7LongMemoryProvider IS INITIAL.
        APPEND INITIAL LINE TO failed-agent ASSIGNING FIELD-SYMBOL(<ls_fail>).
        <ls_fail>-%tky        = <ls_agent>-%tky.
        <ls_fail>-%fail-cause = if_abap_behv=>cause-conflict.

        APPEND INITIAL LINE TO reported-agent ASSIGNING FIELD-SYMBOL(<ls_report>).
        <ls_report>-%tky        = <ls_agent>-%tky.
        <ls_report>-%state_area = state_area-checklongmemoryprovider.
        <ls_report>-%element-AIPF7LongMemoryProvider = if_abap_behv=>mk-on.
        <ls_report>-%msg        = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = |Long memory provider must not be initial.| ).
        CONTINUE.
      ENDIF.

      TRY.
          DATA(lo_desc) = CAST cl_abap_classdescr( cl_abap_typedescr=>describe_by_name( <ls_agent>-AIPF7LongMemoryProvider ) ).
          DATA(lv_implements) = abap_false.
          LOOP AT lo_desc->interfaces ASSIGNING FIELD-SYMBOL(<ls_intf>).
            IF <ls_intf>-name = 'ZPRU_IF_LONG_MEMORY_PROVIDER'.
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
            <ls_report>-%state_area = state_area-checklongmemoryprovider.
            <ls_report>-%element-AIPF7LongMemoryProvider = if_abap_behv=>mk-on.
            <ls_report>-%msg        = new_message_with_text(
                severity = if_abap_behv_message=>severity-error
                text     = |Class '{ <ls_agent>-AIPF7LongMemoryProvider }' does not implement ZPRU_IF_LONG_MEMORY_PROVIDER.| ).
            CONTINUE.
          ENDIF.
        CATCH cx_root.
          APPEND INITIAL LINE TO failed-agent ASSIGNING <ls_fail>.
          <ls_fail>-%tky        = <ls_agent>-%tky.
          <ls_fail>-%fail-cause = if_abap_behv=>cause-conflict.

          APPEND INITIAL LINE TO reported-agent ASSIGNING <ls_report>.
          <ls_report>-%tky        = <ls_agent>-%tky.
          <ls_report>-%state_area = state_area-checklongmemoryprovider.
          <ls_report>-%element-AIPF7LongMemoryProvider = if_abap_behv=>mk-on.
          <ls_report>-%msg        = new_message_with_text(
              severity = if_abap_behv_message=>severity-error
              text     = |Class '{ <ls_agent>-AIPF7LongMemoryProvider }' does not exist.| ).
          CONTINUE.
      ENDTRY.

    ENDLOOP.

    LOOP AT lt_not_found ASSIGNING <ls_not_found>.
      APPEND INITIAL LINE TO failed-agent ASSIGNING <ls_fail>.
      <ls_fail>-%tky        = <ls_not_found>-%tky.
      <ls_fail>-%fail-cause = if_abap_behv=>cause-not_found.

      APPEND INITIAL LINE TO reported-agent ASSIGNING <ls_report>.
      <ls_report>-%tky        = <ls_not_found>-%tky.
      <ls_report>-%state_area = state_area-checklongmemoryprovider.
      <ls_report>-%msg        = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                       text     = |Agent not found.| ).
    ENDLOOP.
  ENDMETHOD.

  METHOD changelongmemoryprovider.
    DATA lt_update TYPE TABLE FOR UPDATE zr_pru_agent\\Agent.

    " 1. Check empty input
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).
      IF <ls_key>-%param-AIPF7LongMemoryProvider IS INITIAL.
        APPEND INITIAL LINE TO failed-agent ASSIGNING FIELD-SYMBOL(<ls_fail>).
        <ls_fail>-%tky        = <ls_key>-%tky.
        <ls_fail>-%fail-cause = if_abap_behv=>cause-conflict.

        APPEND INITIAL LINE TO reported-agent ASSIGNING FIELD-SYMBOL(<ls_report>).
        <ls_report>-%tky        = <ls_key>-%tky.
        <ls_report>-%msg        = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = |Long memory provider must not be empty.| ).
      ENDIF.
    ENDLOOP.

    IF failed-agent IS NOT INITIAL.
      RETURN.
    ENDIF.

    " 2. Read entities
    READ ENTITIES OF zr_pru_agent IN LOCAL MODE
         ENTITY Agent
         FIELDS ( AIPF7LongMemoryProvider )
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
    LOOP AT keys ASSIGNING <ls_key>.
      ASSIGN lt_agent[ KEY id COMPONENTS %tky = <ls_key>-%tky ] TO FIELD-SYMBOL(<ls_agent>).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      APPEND INITIAL LINE TO lt_update ASSIGNING FIELD-SYMBOL(<ls_update>).
      <ls_update>-%tky                           = <ls_agent>-%tky.
      <ls_update>-AIPF7LongMemoryProvider         = <ls_key>-%param-AIPF7LongMemoryProvider.
      <ls_update>-%control-AIPF7LongMemoryProvider = if_abap_behv=>mk-on.
    ENDLOOP.

    " 5. Single MODIFY ENTITIES if anything to update
    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zr_pru_agent IN LOCAL MODE
             ENTITY Agent
             UPDATE FIELDS ( AIPF7LongMemoryProvider )
             WITH lt_update.
    ENDIF.
  ENDMETHOD.

  METHOD checksystempromptprovider.
    DATA lt_not_found LIKE keys.

    IF keys IS INITIAL.
      RETURN.
    ENDIF.

    READ ENTITIES OF zr_pru_agent IN LOCAL MODE
         ENTITY Agent
         FIELDS ( AIPF7SystemPromptProvider )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_agent).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).

      " Formal invalidation — clear previous validation state
      APPEND INITIAL LINE TO reported-agent ASSIGNING FIELD-SYMBOL(<ls_inval>).
      <ls_inval>-%tky        = <ls_key>-%tky.
      <ls_inval>-%state_area = state_area-checksystempromptprovider.

      ASSIGN lt_agent[ KEY id COMPONENTS %tky = <ls_key>-%tky ] TO FIELD-SYMBOL(<ls_agent>).
      IF sy-subrc <> 0.
        APPEND INITIAL LINE TO lt_not_found ASSIGNING FIELD-SYMBOL(<ls_not_found>).
        <ls_not_found> = <ls_key>.
        CONTINUE.
      ENDIF.

      " Field is optional — skip validation if empty
      IF <ls_agent>-AIPF7SystemPromptProvider IS INITIAL.
        CONTINUE.
      ENDIF.

      TRY.
          DATA(lo_desc) = CAST cl_abap_classdescr( cl_abap_typedescr=>describe_by_name( <ls_agent>-AIPF7SystemPromptProvider ) ).
          DATA(lv_implements) = abap_false.
          LOOP AT lo_desc->interfaces ASSIGNING FIELD-SYMBOL(<ls_intf>).
            IF <ls_intf>-name = 'ZPRU_IF_PROMPT_PROVIDER'.
              lv_implements = abap_true.
              EXIT.
            ENDIF.
          ENDLOOP.
          IF lv_implements = abap_false.
            APPEND INITIAL LINE TO failed-agent ASSIGNING FIELD-SYMBOL(<ls_fail>).
            <ls_fail>-%tky        = <ls_agent>-%tky.
            <ls_fail>-%fail-cause = if_abap_behv=>cause-conflict.

            APPEND INITIAL LINE TO reported-agent ASSIGNING FIELD-SYMBOL(<ls_report>).
            <ls_report>-%tky        = <ls_agent>-%tky.
            <ls_report>-%state_area = state_area-checksystempromptprovider.
            <ls_report>-%element-AIPF7SystemPromptProvider = if_abap_behv=>mk-on.
            <ls_report>-%msg        = new_message_with_text(
                severity = if_abap_behv_message=>severity-error
                text     = |Class '{ <ls_agent>-AIPF7SystemPromptProvider }' does not implement ZPRU_IF_PROMPT_PROVIDER.| ).
            CONTINUE.
          ENDIF.
        CATCH cx_root.
          APPEND INITIAL LINE TO failed-agent ASSIGNING <ls_fail>.
          <ls_fail>-%tky        = <ls_agent>-%tky.
          <ls_fail>-%fail-cause = if_abap_behv=>cause-conflict.

          APPEND INITIAL LINE TO reported-agent ASSIGNING <ls_report>.
          <ls_report>-%tky        = <ls_agent>-%tky.
          <ls_report>-%state_area = state_area-checksystempromptprovider.
          <ls_report>-%element-AIPF7SystemPromptProvider = if_abap_behv=>mk-on.
          <ls_report>-%msg        = new_message_with_text(
              severity = if_abap_behv_message=>severity-error
              text     = |Class '{ <ls_agent>-AIPF7SystemPromptProvider }' does not exist.| ).
          CONTINUE.
      ENDTRY.

    ENDLOOP.

    LOOP AT lt_not_found ASSIGNING <ls_not_found>.
      APPEND INITIAL LINE TO failed-agent ASSIGNING <ls_fail>.
      <ls_fail>-%tky        = <ls_not_found>-%tky.
      <ls_fail>-%fail-cause = if_abap_behv=>cause-not_found.

      APPEND INITIAL LINE TO reported-agent ASSIGNING <ls_report>.
      <ls_report>-%tky        = <ls_not_found>-%tky.
      <ls_report>-%state_area = state_area-checksystempromptprovider.
      <ls_report>-%msg        = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                       text     = |Agent not found.| ).
    ENDLOOP.
  ENDMETHOD.

  METHOD changesystempromptprovider.
    DATA lt_update TYPE TABLE FOR UPDATE zr_pru_agent\\Agent.

    " 1. Read entities (empty is allowed, no precondition check)
    READ ENTITIES OF zr_pru_agent IN LOCAL MODE
         ENTITY Agent
         FIELDS ( AIPF7SystemPromptProvider )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_agent)
         FAILED DATA(ls_read_failed).

    " 2. Handle not found
    IF ls_read_failed-agent IS NOT INITIAL.
      LOOP AT ls_read_failed-agent ASSIGNING FIELD-SYMBOL(<ls_read_fail>).
        APPEND INITIAL LINE TO failed-agent ASSIGNING FIELD-SYMBOL(<ls_fail>).
        <ls_fail>-%tky        = <ls_read_fail>-%tky.
        <ls_fail>-%fail-cause = if_abap_behv=>cause-not_found.

        APPEND INITIAL LINE TO reported-agent ASSIGNING FIELD-SYMBOL(<ls_report>).
        <ls_report>-%tky        = <ls_read_fail>-%tky.
        <ls_report>-%msg        = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = |Agent not found.| ).
      ENDLOOP.
      RETURN.
    ENDIF.

    " 3. Loop — fill local update variable + %control explicitly (empty allowed)
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).
      ASSIGN lt_agent[ KEY id COMPONENTS %tky = <ls_key>-%tky ] TO FIELD-SYMBOL(<ls_agent>).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      APPEND INITIAL LINE TO lt_update ASSIGNING FIELD-SYMBOL(<ls_update>).
      <ls_update>-%tky                              = <ls_agent>-%tky.
      <ls_update>-AIPF7SystemPromptProvider          = <ls_key>-%param-AIPF7SystemPromptProvider.
      <ls_update>-%control-AIPF7SystemPromptProvider  = if_abap_behv=>mk-on.
    ENDLOOP.

    " 4. Single MODIFY ENTITIES if anything to update
    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zr_pru_agent IN LOCAL MODE
             ENTITY Agent
             UPDATE FIELDS ( AIPF7SystemPromptProvider )
             WITH lt_update.
    ENDIF.
  ENDMETHOD.

  METHOD checkagentmapper.
    DATA lt_not_found LIKE keys.

    IF keys IS INITIAL.
      RETURN.
    ENDIF.

    READ ENTITIES OF zr_pru_agent IN LOCAL MODE
         ENTITY Agent
         FIELDS ( AIPF7AgentMapper )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_agent).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).

      " Formal invalidation — clear previous validation state
      APPEND INITIAL LINE TO reported-agent ASSIGNING FIELD-SYMBOL(<ls_inval>).
      <ls_inval>-%tky        = <ls_key>-%tky.
      <ls_inval>-%state_area = state_area-checkagentmapper.

      ASSIGN lt_agent[ KEY id COMPONENTS %tky = <ls_key>-%tky ] TO FIELD-SYMBOL(<ls_agent>).
      IF sy-subrc <> 0.
        APPEND INITIAL LINE TO lt_not_found ASSIGNING FIELD-SYMBOL(<ls_not_found>).
        <ls_not_found> = <ls_key>.
        CONTINUE.
      ENDIF.

      " Field is optional — skip validation if empty
      IF <ls_agent>-AIPF7AgentMapper IS INITIAL.
        CONTINUE.
      ENDIF.

      TRY.
          DATA(lo_desc) = CAST cl_abap_classdescr( cl_abap_typedescr=>describe_by_name( <ls_agent>-AIPF7AgentMapper ) ).
          DATA(lv_implements) = abap_false.
          LOOP AT lo_desc->interfaces ASSIGNING FIELD-SYMBOL(<ls_intf>).
            IF <ls_intf>-name = 'ZPRU_IF_AGENT_MAPPER'.
              lv_implements = abap_true.
              EXIT.
            ENDIF.
          ENDLOOP.
          IF lv_implements = abap_false.
            APPEND INITIAL LINE TO failed-agent ASSIGNING FIELD-SYMBOL(<ls_fail>).
            <ls_fail>-%tky        = <ls_agent>-%tky.
            <ls_fail>-%fail-cause = if_abap_behv=>cause-conflict.

            APPEND INITIAL LINE TO reported-agent ASSIGNING FIELD-SYMBOL(<ls_report>).
            <ls_report>-%tky        = <ls_agent>-%tky.
            <ls_report>-%state_area = state_area-checkagentmapper.
            <ls_report>-%element-AIPF7AgentMapper = if_abap_behv=>mk-on.
            <ls_report>-%msg        = new_message_with_text(
                severity = if_abap_behv_message=>severity-error
                text     = |Class '{ <ls_agent>-AIPF7AgentMapper }' does not implement ZPRU_IF_AGENT_MAPPER.| ).
            CONTINUE.
          ENDIF.
        CATCH cx_root.
          APPEND INITIAL LINE TO failed-agent ASSIGNING <ls_fail>.
          <ls_fail>-%tky        = <ls_agent>-%tky.
          <ls_fail>-%fail-cause = if_abap_behv=>cause-conflict.

          APPEND INITIAL LINE TO reported-agent ASSIGNING <ls_report>.
          <ls_report>-%tky        = <ls_agent>-%tky.
          <ls_report>-%state_area = state_area-checkagentmapper.
          <ls_report>-%element-AIPF7AgentMapper = if_abap_behv=>mk-on.
          <ls_report>-%msg        = new_message_with_text(
              severity = if_abap_behv_message=>severity-error
              text     = |Class '{ <ls_agent>-AIPF7AgentMapper }' does not exist.| ).
          CONTINUE.
      ENDTRY.

    ENDLOOP.

    LOOP AT lt_not_found ASSIGNING <ls_not_found>.
      APPEND INITIAL LINE TO failed-agent ASSIGNING <ls_fail>.
      <ls_fail>-%tky        = <ls_not_found>-%tky.
      <ls_fail>-%fail-cause = if_abap_behv=>cause-not_found.

      APPEND INITIAL LINE TO reported-agent ASSIGNING <ls_report>.
      <ls_report>-%tky        = <ls_not_found>-%tky.
      <ls_report>-%state_area = state_area-checkagentmapper.
      <ls_report>-%msg        = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                       text     = |Agent not found.| ).
    ENDLOOP.
  ENDMETHOD.

  METHOD changeagentmapper.
    DATA lt_update TYPE TABLE FOR UPDATE zr_pru_agent\\Agent.

    " 1. Read entities (empty is allowed, no precondition check)
    READ ENTITIES OF zr_pru_agent IN LOCAL MODE
         ENTITY Agent
         FIELDS ( AIPF7AgentMapper )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_agent)
         FAILED DATA(ls_read_failed).

    " 2. Handle not found
    IF ls_read_failed-agent IS NOT INITIAL.
      LOOP AT ls_read_failed-agent ASSIGNING FIELD-SYMBOL(<ls_read_fail>).
        APPEND INITIAL LINE TO failed-agent ASSIGNING FIELD-SYMBOL(<ls_fail>).
        <ls_fail>-%tky        = <ls_read_fail>-%tky.
        <ls_fail>-%fail-cause = if_abap_behv=>cause-not_found.

        APPEND INITIAL LINE TO reported-agent ASSIGNING FIELD-SYMBOL(<ls_report>).
        <ls_report>-%tky        = <ls_read_fail>-%tky.
        <ls_report>-%msg        = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = |Agent not found.| ).
      ENDLOOP.
      RETURN.
    ENDIF.

    " 3. Loop — fill local update variable + %control explicitly (empty allowed)
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).
      ASSIGN lt_agent[ KEY id COMPONENTS %tky = <ls_key>-%tky ] TO FIELD-SYMBOL(<ls_agent>).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      APPEND INITIAL LINE TO lt_update ASSIGNING FIELD-SYMBOL(<ls_update>).
      <ls_update>-%tky                       = <ls_agent>-%tky.
      <ls_update>-AIPF7AgentMapper            = <ls_key>-%param-AIPF7AgentMapper.
      <ls_update>-%control-AIPF7AgentMapper   = if_abap_behv=>mk-on.
    ENDLOOP.

    " 4. Single MODIFY ENTITIES if anything to update
    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zr_pru_agent IN LOCAL MODE
             ENTITY Agent
             UPDATE FIELDS ( AIPF7AgentMapper )
             WITH lt_update.
    ENDIF.
  ENDMETHOD.

  METHOD fillagentmapper.
    DATA lt_update TYPE TABLE FOR UPDATE zr_pru_agent\\Agent.

    READ ENTITIES OF zr_pru_agent IN LOCAL MODE
         ENTITY Agent
         FIELDS ( AIPF7AgentMapper )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_agent).

    LOOP AT lt_agent ASSIGNING FIELD-SYMBOL(<ls_agent>).
      IF <ls_agent>-AIPF7AgentMapper IS NOT INITIAL.
        CONTINUE.
      ENDIF.

      APPEND INITIAL LINE TO lt_update ASSIGNING FIELD-SYMBOL(<ls_update>).
      <ls_update>-%tky                     = <ls_agent>-%tky.
      <ls_update>-AIPF7AgentMapper          = 'ZPRU_CL_AGENT_MAPPER'.
      <ls_update>-%control-AIPF7AgentMapper = if_abap_behv=>mk-on.
    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zr_pru_agent IN LOCAL MODE
             ENTITY Agent
             UPDATE FIELDS ( AIPF7AgentMapper )
             WITH lt_update.
    ENDIF.
  ENDMETHOD.

  METHOD fillagentstatus.
    DATA lt_update TYPE TABLE FOR UPDATE zr_pru_agent\\Agent.

    READ ENTITIES OF zr_pru_agent IN LOCAL MODE
         ENTITY Agent
         FIELDS ( AIPF7AgentStatus )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_agent).

    LOOP AT lt_agent ASSIGNING FIELD-SYMBOL(<ls_agent>).
      IF <ls_agent>-AIPF7AgentStatus IS NOT INITIAL.
        CONTINUE.
      ENDIF.

      APPEND INITIAL LINE TO lt_update ASSIGNING FIELD-SYMBOL(<ls_update>).
      <ls_update>-%tky                     = <ls_agent>-%tky.
      <ls_update>-AIPF7AgentStatus          = zpru_if_adf_type_and_constant=>cs_agent_status-new.
      <ls_update>-%control-AIPF7AgentStatus = if_abap_behv=>mk-on.
    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zr_pru_agent IN LOCAL MODE
             ENTITY Agent
             UPDATE FIELDS ( AIPF7AgentStatus )
             WITH lt_update.
    ENDIF.
  ENDMETHOD.

  METHOD checkagentinfoprovider.
    DATA lt_not_found LIKE keys.

    IF keys IS INITIAL.
      RETURN.
    ENDIF.

    READ ENTITIES OF zr_pru_agent IN LOCAL MODE
         ENTITY Agent
         FIELDS ( AIPF7AgentInfoProvider )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_agent).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).

      " Formal invalidation — clear previous validation state
      APPEND INITIAL LINE TO reported-agent ASSIGNING FIELD-SYMBOL(<ls_inval>).
      <ls_inval>-%tky        = <ls_key>-%tky.
      <ls_inval>-%state_area = state_area-checkagentinfoprovider.

      ASSIGN lt_agent[ KEY id COMPONENTS %tky = <ls_key>-%tky ] TO FIELD-SYMBOL(<ls_agent>).
      IF sy-subrc <> 0.
        APPEND INITIAL LINE TO lt_not_found ASSIGNING FIELD-SYMBOL(<ls_not_found>).
        <ls_not_found> = <ls_key>.
        CONTINUE.
      ENDIF.

      " Field is optional — skip validation if empty
      IF <ls_agent>-AIPF7AgentInfoProvider IS INITIAL.
        CONTINUE.
      ENDIF.

      TRY.
          DATA(lo_desc) = CAST cl_abap_classdescr( cl_abap_typedescr=>describe_by_name( <ls_agent>-AIPF7AgentInfoProvider ) ).
          DATA(lv_implements) = abap_false.
          LOOP AT lo_desc->interfaces ASSIGNING FIELD-SYMBOL(<ls_intf>).
            IF <ls_intf>-name = 'ZPRU_IF_AGENT_INFO_PROVIDER'.
              lv_implements = abap_true.
              EXIT.
            ENDIF.
          ENDLOOP.
          IF lv_implements = abap_false.
            APPEND INITIAL LINE TO failed-agent ASSIGNING FIELD-SYMBOL(<ls_fail>).
            <ls_fail>-%tky        = <ls_agent>-%tky.
            <ls_fail>-%fail-cause = if_abap_behv=>cause-conflict.

            APPEND INITIAL LINE TO reported-agent ASSIGNING FIELD-SYMBOL(<ls_report>).
            <ls_report>-%tky        = <ls_agent>-%tky.
            <ls_report>-%state_area = state_area-checkagentinfoprovider.
            <ls_report>-%element-AIPF7AgentInfoProvider = if_abap_behv=>mk-on.
            <ls_report>-%msg        = new_message_with_text(
                severity = if_abap_behv_message=>severity-error
                text     = |Class '{ <ls_agent>-AIPF7AgentInfoProvider }' does not implement ZPRU_IF_AGENT_INFO_PROVIDER.| ).
            CONTINUE.
          ENDIF.
        CATCH cx_root.
          APPEND INITIAL LINE TO failed-agent ASSIGNING <ls_fail>.
          <ls_fail>-%tky        = <ls_agent>-%tky.
          <ls_fail>-%fail-cause = if_abap_behv=>cause-conflict.

          APPEND INITIAL LINE TO reported-agent ASSIGNING <ls_report>.
          <ls_report>-%tky        = <ls_agent>-%tky.
          <ls_report>-%state_area = state_area-checkagentinfoprovider.
          <ls_report>-%element-AIPF7AgentInfoProvider = if_abap_behv=>mk-on.
          <ls_report>-%msg        = new_message_with_text(
              severity = if_abap_behv_message=>severity-error
              text     = |Class '{ <ls_agent>-AIPF7AgentInfoProvider }' does not exist.| ).
          CONTINUE.
      ENDTRY.

    ENDLOOP.

    LOOP AT lt_not_found ASSIGNING <ls_not_found>.
      APPEND INITIAL LINE TO failed-agent ASSIGNING <ls_fail>.
      <ls_fail>-%tky        = <ls_not_found>-%tky.
      <ls_fail>-%fail-cause = if_abap_behv=>cause-not_found.

      APPEND INITIAL LINE TO reported-agent ASSIGNING <ls_report>.
      <ls_report>-%tky        = <ls_not_found>-%tky.
      <ls_report>-%state_area = state_area-checkagentinfoprovider.
      <ls_report>-%msg        = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                       text     = |Agent not found.| ).
    ENDLOOP.
  ENDMETHOD.

  METHOD checkagentstatus.
    DATA lt_not_found LIKE keys.

    IF keys IS INITIAL.
      RETURN.
    ENDIF.

    READ ENTITIES OF zr_pru_agent IN LOCAL MODE
         ENTITY Agent
         FIELDS ( AIPF7AgentStatus )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_agent).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).

      " Formal invalidation — clear previous validation state
      APPEND INITIAL LINE TO reported-agent ASSIGNING FIELD-SYMBOL(<ls_inval>).
      <ls_inval>-%tky        = <ls_key>-%tky.
      <ls_inval>-%state_area = state_area-checkagentstatus.

      ASSIGN lt_agent[ KEY id COMPONENTS %tky = <ls_key>-%tky ] TO FIELD-SYMBOL(<ls_agent>).
      IF sy-subrc <> 0.
        APPEND INITIAL LINE TO lt_not_found ASSIGNING FIELD-SYMBOL(<ls_not_found>).
        <ls_not_found> = <ls_key>.
        CONTINUE.
      ENDIF.

      IF <ls_agent>-AIPF7AgentStatus IS INITIAL.
        APPEND INITIAL LINE TO failed-agent ASSIGNING FIELD-SYMBOL(<ls_fail>).
        <ls_fail>-%tky        = <ls_agent>-%tky.
        <ls_fail>-%fail-cause = if_abap_behv=>cause-conflict.

        APPEND INITIAL LINE TO reported-agent ASSIGNING FIELD-SYMBOL(<ls_report>).
        <ls_report>-%tky        = <ls_agent>-%tky.
        <ls_report>-%state_area = state_area-checkagentstatus.
        <ls_report>-%element-AIPF7AgentStatus = if_abap_behv=>mk-on.
        <ls_report>-%msg        = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = |Agent status must not be initial.| ).
        CONTINUE.
      ENDIF.

      IF NOT ( <ls_agent>-AIPF7AgentStatus = 'N'
            OR <ls_agent>-AIPF7AgentStatus = 'A'
            OR <ls_agent>-AIPF7AgentStatus = 'I' ).
        APPEND INITIAL LINE TO failed-agent ASSIGNING <ls_fail>.
        <ls_fail>-%tky        = <ls_agent>-%tky.
        <ls_fail>-%fail-cause = if_abap_behv=>cause-conflict.

        APPEND INITIAL LINE TO reported-agent ASSIGNING <ls_report>.
        <ls_report>-%tky        = <ls_agent>-%tky.
        <ls_report>-%state_area = state_area-checkagentstatus.
        <ls_report>-%element-AIPF7AgentStatus = if_abap_behv=>mk-on.
        <ls_report>-%msg        = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = |Agent status '{ <ls_agent>-AIPF7AgentStatus }' is invalid. Valid values are: N (New), A (Active), I (Inactive).| ).
      ENDIF.

    ENDLOOP.

    LOOP AT lt_not_found ASSIGNING <ls_not_found>.
      APPEND INITIAL LINE TO failed-agent ASSIGNING <ls_fail>.
      <ls_fail>-%tky        = <ls_not_found>-%tky.
      <ls_fail>-%fail-cause = if_abap_behv=>cause-not_found.

      APPEND INITIAL LINE TO reported-agent ASSIGNING <ls_report>.
      <ls_report>-%tky        = <ls_not_found>-%tky.
      <ls_report>-%state_area = state_area-checkagentstatus.
      <ls_report>-%msg        = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                       text     = |Agent not found.| ).
    ENDLOOP.
  ENDMETHOD.

  METHOD changeagentstatus.
    DATA lt_update TYPE TABLE FOR UPDATE zr_pru_agent\\Agent.

    " 1. Check empty input
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).
      IF <ls_key>-%param-AIPF7AgentStatus IS INITIAL.
        APPEND INITIAL LINE TO failed-agent ASSIGNING FIELD-SYMBOL(<ls_fail>).
        <ls_fail>-%tky        = <ls_key>-%tky.
        <ls_fail>-%fail-cause = if_abap_behv=>cause-conflict.

        APPEND INITIAL LINE TO reported-agent ASSIGNING FIELD-SYMBOL(<ls_report>).
        <ls_report>-%tky        = <ls_key>-%tky.
        <ls_report>-%msg        = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = |Status must not be empty.| ).
      ELSEIF NOT ( <ls_key>-%param-AIPF7AgentStatus = 'A'
                OR <ls_key>-%param-AIPF7AgentStatus = 'I' ).
        APPEND INITIAL LINE TO failed-agent ASSIGNING <ls_fail>.
        <ls_fail>-%tky        = <ls_key>-%tky.
        <ls_fail>-%fail-cause = if_abap_behv=>cause-conflict.

        APPEND INITIAL LINE TO reported-agent ASSIGNING <ls_report>.
        <ls_report>-%tky        = <ls_key>-%tky.
        <ls_report>-%msg        = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = |Invalid status value.| ).
      ENDIF.
    ENDLOOP.

    IF failed-agent IS NOT INITIAL.
      RETURN.
    ENDIF.

    " 2. Read entities
    READ ENTITIES OF zr_pru_agent IN LOCAL MODE
         ENTITY Agent
         FIELDS ( AIPF7AgentStatus )
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
    LOOP AT keys ASSIGNING <ls_key>.
      ASSIGN lt_agent[ KEY id COMPONENTS %tky = <ls_key>-%tky ] TO FIELD-SYMBOL(<ls_agent>).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      APPEND INITIAL LINE TO lt_update ASSIGNING FIELD-SYMBOL(<ls_update>).
      <ls_update>-%tky                       = <ls_agent>-%tky.
      <ls_update>-AIPF7AgentStatus            = <ls_key>-%param-AIPF7AgentStatus.
      <ls_update>-%control-AIPF7AgentStatus   = if_abap_behv=>mk-on.
    ENDLOOP.

    " 5. Single MODIFY ENTITIES if anything to update
    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zr_pru_agent IN LOCAL MODE
             ENTITY Agent
             UPDATE FIELDS ( AIPF7AgentStatus )
             WITH lt_update.
    ENDIF.
  ENDMETHOD.

  METHOD changeagentinfoprovider.
    DATA lt_update TYPE TABLE FOR UPDATE zr_pru_agent\\Agent.

    " 1. Read entities (empty is allowed, no precondition check)
    READ ENTITIES OF zr_pru_agent IN LOCAL MODE
         ENTITY Agent
         FIELDS ( AIPF7AgentInfoProvider )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_agent)
         FAILED DATA(ls_read_failed).

    " 2. Handle not found
    IF ls_read_failed-agent IS NOT INITIAL.
      LOOP AT ls_read_failed-agent ASSIGNING FIELD-SYMBOL(<ls_read_fail>).
        APPEND INITIAL LINE TO failed-agent ASSIGNING FIELD-SYMBOL(<ls_fail>).
        <ls_fail>-%tky        = <ls_read_fail>-%tky.
        <ls_fail>-%fail-cause = if_abap_behv=>cause-not_found.

        APPEND INITIAL LINE TO reported-agent ASSIGNING FIELD-SYMBOL(<ls_report>).
        <ls_report>-%tky        = <ls_read_fail>-%tky.
        <ls_report>-%msg        = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = |Agent not found.| ).
      ENDLOOP.
      RETURN.
    ENDIF.

    " 3. Loop — fill local update variable + %control explicitly (empty allowed)
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).
      ASSIGN lt_agent[ KEY id COMPONENTS %tky = <ls_key>-%tky ] TO FIELD-SYMBOL(<ls_agent>).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      APPEND INITIAL LINE TO lt_update ASSIGNING FIELD-SYMBOL(<ls_update>).
      <ls_update>-%tky                            = <ls_agent>-%tky.
      <ls_update>-AIPF7AgentInfoProvider            = <ls_key>-%param-AIPF7AgentInfoProvider.
      <ls_update>-%control-AIPF7AgentInfoProvider   = if_abap_behv=>mk-on.
    ENDLOOP.

    " 4. Single MODIFY ENTITIES if anything to update
    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zr_pru_agent IN LOCAL MODE
             ENTITY Agent
             UPDATE FIELDS ( AIPF7AgentInfoProvider )
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
