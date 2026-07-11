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

CLASS lhc_zr_pru_agent_tool DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    CONSTANTS:
      BEGIN OF state_area,
        checktoolname           TYPE string VALUE 'CHECKTOOLNAME',
        checktoolprovider       TYPE string VALUE 'CHECKTOOLPROVIDER',
        checksteptype           TYPE string VALUE 'CHECKSTEPTYPE',
        checktoolschemaprovider TYPE string VALUE 'CHECKTOOLSCHEMAPROVIDER',
        checktoolinfoprovider   TYPE string VALUE 'CHECKTOOLINFOPROVIDER',
      END OF state_area.

    METHODS checktoolname FOR VALIDATE ON SAVE
      IMPORTING keys FOR AgentTool~checkToolName.
    METHODS checktoolprovider FOR VALIDATE ON SAVE
      IMPORTING keys FOR AgentTool~checkToolProvider.
    METHODS checksteptype FOR VALIDATE ON SAVE
      IMPORTING keys FOR AgentTool~checkStepType.
    METHODS checktoolschemaprovider FOR VALIDATE ON SAVE
      IMPORTING keys FOR AgentTool~checkToolSchemaProvider.
    METHODS checktoolinfoprovider FOR VALIDATE ON SAVE
      IMPORTING keys FOR AgentTool~checkToolInfoProvider.

    METHODS changetoolprovider FOR MODIFY
      IMPORTING keys FOR ACTION AgentTool~changeToolProvider.
    METHODS changetoolschemaprovider FOR MODIFY
      IMPORTING keys FOR ACTION AgentTool~changeToolSchemaProvider.
    METHODS changetoolinfoprovider FOR MODIFY
      IMPORTING keys FOR ACTION AgentTool~changeToolInfoProvider.
    METHODS changesteptype FOR MODIFY
      IMPORTING keys FOR ACTION AgentTool~changeStepType.
ENDCLASS.


CLASS lhc_zr_pru_agent_tool IMPLEMENTATION.
  METHOD checktoolname.
    DATA lt_not_found LIKE keys.

    IF keys IS INITIAL.
      RETURN.
    ENDIF.

    READ ENTITIES OF zr_pru_agent IN LOCAL MODE
         ENTITY AgentTool
         FIELDS ( AIPF7ToolUuid AIPF7AgentUuid AIPF7ToolName )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_tool).

    IF lt_tool IS NOT INITIAL.
      SELECT AIPF7ToolUuid, AIPF7AgentUuid, AIPF7ToolName
        FROM zr_pru_agent_tool
        FOR ALL ENTRIES IN @lt_tool
        WHERE AIPF7AgentUuid = @lt_tool-AIPF7AgentUuid
          AND AIPF7ToolName  = @lt_tool-AIPF7ToolName
        INTO TABLE @DATA(lt_existing)
        PRIVILEGED ACCESS.
    ENDIF.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).

      " Formal invalidation — clear previous validation state
      APPEND INITIAL LINE TO reported-agenttool ASSIGNING FIELD-SYMBOL(<ls_inval>).
      <ls_inval>-%tky        = <ls_key>-%tky.
      <ls_inval>-%state_area = state_area-checktoolname.

      ASSIGN lt_tool[ KEY id COMPONENTS %tky = <ls_key>-%tky ] TO FIELD-SYMBOL(<ls_tool>).
      IF sy-subrc <> 0.
        APPEND INITIAL LINE TO lt_not_found ASSIGNING FIELD-SYMBOL(<ls_not_found>).
        <ls_not_found> = <ls_key>.
        CONTINUE.
      ENDIF.

      " Exclude self from uniqueness check
      DATA(lv_exists) = abap_false.
      LOOP AT lt_existing TRANSPORTING NO FIELDS
           WHERE AIPF7AgentUuid = <ls_tool>-AIPF7AgentUuid
             AND AIPF7ToolName  = <ls_tool>-AIPF7ToolName
             AND AIPF7ToolUuid <> <ls_tool>-AIPF7ToolUuid.
        lv_exists = abap_true.
        EXIT.
      ENDLOOP.
      IF lv_exists = abap_false.
        CONTINUE.
      ENDIF.

      APPEND INITIAL LINE TO failed-agenttool ASSIGNING FIELD-SYMBOL(<ls_fail>).
      <ls_fail>-%tky        = <ls_tool>-%tky.
      <ls_fail>-%fail-cause = if_abap_behv=>cause-conflict.

      APPEND INITIAL LINE TO reported-agenttool ASSIGNING FIELD-SYMBOL(<ls_report>).
      <ls_report>-%tky        = <ls_tool>-%tky.
      <ls_report>-%state_area = state_area-checktoolname.
      <ls_report>-%element-AIPF7ToolName = if_abap_behv=>mk-on.
      <ls_report>-%msg        = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text     = |Tool name '{ <ls_tool>-AIPF7ToolName }' already exists for this agent. Please use a unique name.| ).

    ENDLOOP.

    LOOP AT lt_not_found ASSIGNING <ls_not_found>.
      APPEND INITIAL LINE TO failed-agenttool ASSIGNING <ls_fail>.
      <ls_fail>-%tky        = <ls_not_found>-%tky.
      <ls_fail>-%fail-cause = if_abap_behv=>cause-not_found.

      APPEND INITIAL LINE TO reported-agenttool ASSIGNING <ls_report>.
      <ls_report>-%tky        = <ls_not_found>-%tky.
      <ls_report>-%state_area = state_area-checktoolname.
      <ls_report>-%msg        = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                       text     = |Tool not found.| ).
    ENDLOOP.
  ENDMETHOD.

  METHOD checktoolprovider.
    DATA lt_not_found LIKE keys.

    IF keys IS INITIAL.
      RETURN.
    ENDIF.

    READ ENTITIES OF zr_pru_agent IN LOCAL MODE
         ENTITY AgentTool
         FIELDS ( AIPF7ToolProvider )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_tool).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).

      " Formal invalidation — clear previous validation state
      APPEND INITIAL LINE TO reported-agenttool ASSIGNING FIELD-SYMBOL(<ls_inval>).
      <ls_inval>-%tky        = <ls_key>-%tky.
      <ls_inval>-%state_area = state_area-checktoolprovider.

      ASSIGN lt_tool[ KEY id COMPONENTS %tky = <ls_key>-%tky ] TO FIELD-SYMBOL(<ls_tool>).
      IF sy-subrc <> 0.
        APPEND INITIAL LINE TO lt_not_found ASSIGNING FIELD-SYMBOL(<ls_not_found>).
        <ls_not_found> = <ls_key>.
        CONTINUE.
      ENDIF.

      IF <ls_tool>-AIPF7ToolProvider IS INITIAL.
        APPEND INITIAL LINE TO failed-agenttool ASSIGNING FIELD-SYMBOL(<ls_fail>).
        <ls_fail>-%tky        = <ls_tool>-%tky.
        <ls_fail>-%fail-cause = if_abap_behv=>cause-conflict.

        APPEND INITIAL LINE TO reported-agenttool ASSIGNING FIELD-SYMBOL(<ls_report>).
        <ls_report>-%tky        = <ls_tool>-%tky.
        <ls_report>-%state_area = state_area-checktoolprovider.
        <ls_report>-%element-AIPF7ToolProvider = if_abap_behv=>mk-on.
        <ls_report>-%msg        = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = |Tool provider must not be initial.| ).
        CONTINUE.
      ENDIF.

      TRY.
          DATA(lo_desc) = CAST cl_abap_classdescr( cl_abap_typedescr=>describe_by_name( <ls_tool>-AIPF7ToolProvider ) ).
          DATA(lv_implements) = abap_false.
          LOOP AT lo_desc->interfaces ASSIGNING FIELD-SYMBOL(<ls_intf>).
            IF <ls_intf>-name = 'ZPRU_IF_TOOL_PROVIDER'.
              lv_implements = abap_true.
              EXIT.
            ENDIF.
          ENDLOOP.
          IF lv_implements = abap_false.
            APPEND INITIAL LINE TO failed-agenttool ASSIGNING <ls_fail>.
            <ls_fail>-%tky        = <ls_tool>-%tky.
            <ls_fail>-%fail-cause = if_abap_behv=>cause-conflict.

            APPEND INITIAL LINE TO reported-agenttool ASSIGNING <ls_report>.
            <ls_report>-%tky        = <ls_tool>-%tky.
            <ls_report>-%state_area = state_area-checktoolprovider.
            <ls_report>-%element-AIPF7ToolProvider = if_abap_behv=>mk-on.
            <ls_report>-%msg        = new_message_with_text(
                severity = if_abap_behv_message=>severity-error
                text     = |Class '{ <ls_tool>-AIPF7ToolProvider }' does not implement ZPRU_IF_TOOL_PROVIDER.| ).
            CONTINUE.
          ENDIF.
        CATCH cx_root.
          APPEND INITIAL LINE TO failed-agenttool ASSIGNING <ls_fail>.
          <ls_fail>-%tky        = <ls_tool>-%tky.
          <ls_fail>-%fail-cause = if_abap_behv=>cause-conflict.

          APPEND INITIAL LINE TO reported-agenttool ASSIGNING <ls_report>.
          <ls_report>-%tky        = <ls_tool>-%tky.
          <ls_report>-%state_area = state_area-checktoolprovider.
          <ls_report>-%element-AIPF7ToolProvider = if_abap_behv=>mk-on.
          <ls_report>-%msg        = new_message_with_text(
              severity = if_abap_behv_message=>severity-error
              text     = |Class '{ <ls_tool>-AIPF7ToolProvider }' does not exist.| ).
          CONTINUE.
      ENDTRY.

    ENDLOOP.

    LOOP AT lt_not_found ASSIGNING <ls_not_found>.
      APPEND INITIAL LINE TO failed-agenttool ASSIGNING <ls_fail>.
      <ls_fail>-%tky        = <ls_not_found>-%tky.
      <ls_fail>-%fail-cause = if_abap_behv=>cause-not_found.

      APPEND INITIAL LINE TO reported-agenttool ASSIGNING <ls_report>.
      <ls_report>-%tky        = <ls_not_found>-%tky.
      <ls_report>-%state_area = state_area-checktoolprovider.
      <ls_report>-%msg        = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                       text     = |Tool not found.| ).
    ENDLOOP.
  ENDMETHOD.

  METHOD checksteptype.
    DATA lt_not_found LIKE keys.

    IF keys IS INITIAL.
      RETURN.
    ENDIF.

    READ ENTITIES OF zr_pru_agent IN LOCAL MODE
         ENTITY AgentTool
         FIELDS ( AIPF7StepType )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_tool).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).

      " Formal invalidation — clear previous validation state
      APPEND INITIAL LINE TO reported-agenttool ASSIGNING FIELD-SYMBOL(<ls_inval>).
      <ls_inval>-%tky        = <ls_key>-%tky.
      <ls_inval>-%state_area = state_area-checksteptype.

      ASSIGN lt_tool[ KEY id COMPONENTS %tky = <ls_key>-%tky ] TO FIELD-SYMBOL(<ls_tool>).
      IF sy-subrc <> 0.
        APPEND INITIAL LINE TO lt_not_found ASSIGNING FIELD-SYMBOL(<ls_not_found>).
        <ls_not_found> = <ls_key>.
        CONTINUE.
      ENDIF.

      IF <ls_tool>-AIPF7StepType IS INITIAL.
        APPEND INITIAL LINE TO failed-agenttool ASSIGNING FIELD-SYMBOL(<ls_fail>).
        <ls_fail>-%tky        = <ls_tool>-%tky.
        <ls_fail>-%fail-cause = if_abap_behv=>cause-conflict.

        APPEND INITIAL LINE TO reported-agenttool ASSIGNING FIELD-SYMBOL(<ls_report>).
        <ls_report>-%tky        = <ls_tool>-%tky.
        <ls_report>-%state_area = state_area-checksteptype.
        <ls_report>-%element-AIPF7StepType = if_abap_behv=>mk-on.
        <ls_report>-%msg        = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = |Step type must not be initial.| ).
        CONTINUE.
      ENDIF.

      IF NOT ( <ls_tool>-AIPF7StepType = 'A'
            OR <ls_tool>-AIPF7StepType = 'K'
            OR <ls_tool>-AIPF7StepType = 'B'
            OR <ls_tool>-AIPF7StepType = 'H'
            OR <ls_tool>-AIPF7StepType = 'S'
            OR <ls_tool>-AIPF7StepType = 'L'
            OR <ls_tool>-AIPF7StepType = 'D'
            OR <ls_tool>-AIPF7StepType = 'M'
            OR <ls_tool>-AIPF7StepType = 'Z' ).
        APPEND INITIAL LINE TO failed-agenttool ASSIGNING <ls_fail>.
        <ls_fail>-%tky        = <ls_tool>-%tky.
        <ls_fail>-%fail-cause = if_abap_behv=>cause-conflict.

        APPEND INITIAL LINE TO reported-agenttool ASSIGNING <ls_report>.
        <ls_report>-%tky        = <ls_tool>-%tky.
        <ls_report>-%state_area = state_area-checksteptype.
        <ls_report>-%element-AIPF7StepType = if_abap_behv=>mk-on.
        <ls_report>-%msg        = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = |Step type '{ <ls_tool>-AIPF7StepType }' is invalid. Valid values are: A (Nested Agent), K (Knowledge Source),| &&
                        | B (ABAP Code), H (HTTP Request), S (Service Consumption Model), L (Call LLM), D (Dynamic ABAP Code), M (Infer ML Model), Z (User Tool).| ).
      ENDIF.

    ENDLOOP.

    LOOP AT lt_not_found ASSIGNING <ls_not_found>.
      APPEND INITIAL LINE TO failed-agenttool ASSIGNING <ls_fail>.
      <ls_fail>-%tky        = <ls_not_found>-%tky.
      <ls_fail>-%fail-cause = if_abap_behv=>cause-not_found.

      APPEND INITIAL LINE TO reported-agenttool ASSIGNING <ls_report>.
      <ls_report>-%tky        = <ls_not_found>-%tky.
      <ls_report>-%state_area = state_area-checksteptype.
      <ls_report>-%msg        = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                       text     = |Tool not found.| ).
    ENDLOOP.
  ENDMETHOD.

  METHOD checktoolschemaprovider.
    DATA lt_not_found LIKE keys.

    IF keys IS INITIAL.
      RETURN.
    ENDIF.

    READ ENTITIES OF zr_pru_agent IN LOCAL MODE
         ENTITY AgentTool
         FIELDS ( AIPF7ToolSchemaProvider )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_tool).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).

      " Formal invalidation — clear previous validation state
      APPEND INITIAL LINE TO reported-agenttool ASSIGNING FIELD-SYMBOL(<ls_inval>).
      <ls_inval>-%tky        = <ls_key>-%tky.
      <ls_inval>-%state_area = state_area-checktoolschemaprovider.

      ASSIGN lt_tool[ KEY id COMPONENTS %tky = <ls_key>-%tky ] TO FIELD-SYMBOL(<ls_tool>).
      IF sy-subrc <> 0.
        APPEND INITIAL LINE TO lt_not_found ASSIGNING FIELD-SYMBOL(<ls_not_found>).
        <ls_not_found> = <ls_key>.
        CONTINUE.
      ENDIF.

      " Field is optional — skip validation if empty
      IF <ls_tool>-AIPF7ToolSchemaProvider IS INITIAL.
        CONTINUE.
      ENDIF.

      TRY.
          DATA(lo_desc) = CAST cl_abap_classdescr( cl_abap_typedescr=>describe_by_name( <ls_tool>-AIPF7ToolSchemaProvider ) ).
          DATA(lv_implements) = abap_false.
          LOOP AT lo_desc->interfaces ASSIGNING FIELD-SYMBOL(<ls_intf>).
            IF <ls_intf>-name = 'ZPRU_IF_TOOL_SCHEMA_PROVIDER'.
              lv_implements = abap_true.
              EXIT.
            ENDIF.
          ENDLOOP.
          IF lv_implements = abap_false.
            APPEND INITIAL LINE TO failed-agenttool ASSIGNING FIELD-SYMBOL(<ls_fail>).
            <ls_fail>-%tky        = <ls_tool>-%tky.
            <ls_fail>-%fail-cause = if_abap_behv=>cause-conflict.

            APPEND INITIAL LINE TO reported-agenttool ASSIGNING FIELD-SYMBOL(<ls_report>).
            <ls_report>-%tky        = <ls_tool>-%tky.
            <ls_report>-%state_area = state_area-checktoolschemaprovider.
            <ls_report>-%element-AIPF7ToolSchemaProvider = if_abap_behv=>mk-on.
            <ls_report>-%msg        = new_message_with_text(
                severity = if_abap_behv_message=>severity-error
                text     = |Class '{ <ls_tool>-AIPF7ToolSchemaProvider }' does not implement ZPRU_IF_TOOL_SCHEMA_PROVIDER.| ).
            CONTINUE.
          ENDIF.
        CATCH cx_root.
          APPEND INITIAL LINE TO failed-agenttool ASSIGNING <ls_fail>.
          <ls_fail>-%tky        = <ls_tool>-%tky.
          <ls_fail>-%fail-cause = if_abap_behv=>cause-conflict.

          APPEND INITIAL LINE TO reported-agenttool ASSIGNING <ls_report>.
          <ls_report>-%tky        = <ls_tool>-%tky.
          <ls_report>-%state_area = state_area-checktoolschemaprovider.
          <ls_report>-%element-AIPF7ToolSchemaProvider = if_abap_behv=>mk-on.
          <ls_report>-%msg        = new_message_with_text(
              severity = if_abap_behv_message=>severity-error
              text     = |Class '{ <ls_tool>-AIPF7ToolSchemaProvider }' does not exist.| ).
          CONTINUE.
      ENDTRY.

    ENDLOOP.

    LOOP AT lt_not_found ASSIGNING <ls_not_found>.
      APPEND INITIAL LINE TO failed-agenttool ASSIGNING <ls_fail>.
      <ls_fail>-%tky        = <ls_not_found>-%tky.
      <ls_fail>-%fail-cause = if_abap_behv=>cause-not_found.

      APPEND INITIAL LINE TO reported-agenttool ASSIGNING <ls_report>.
      <ls_report>-%tky        = <ls_not_found>-%tky.
      <ls_report>-%state_area = state_area-checktoolschemaprovider.
      <ls_report>-%msg        = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                       text     = |Tool not found.| ).
    ENDLOOP.
  ENDMETHOD.

  METHOD checktoolinfoprovider.
    DATA lt_not_found LIKE keys.

    IF keys IS INITIAL.
      RETURN.
    ENDIF.

    READ ENTITIES OF zr_pru_agent IN LOCAL MODE
         ENTITY AgentTool
         FIELDS ( AIPF7ToolInfoProvider )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_tool).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).

      " Formal invalidation — clear previous validation state
      APPEND INITIAL LINE TO reported-agenttool ASSIGNING FIELD-SYMBOL(<ls_inval>).
      <ls_inval>-%tky        = <ls_key>-%tky.
      <ls_inval>-%state_area = state_area-checktoolinfoprovider.

      ASSIGN lt_tool[ KEY id COMPONENTS %tky = <ls_key>-%tky ] TO FIELD-SYMBOL(<ls_tool>).
      IF sy-subrc <> 0.
        APPEND INITIAL LINE TO lt_not_found ASSIGNING FIELD-SYMBOL(<ls_not_found>).
        <ls_not_found> = <ls_key>.
        CONTINUE.
      ENDIF.

      " Field is optional — skip validation if empty
      IF <ls_tool>-AIPF7ToolInfoProvider IS INITIAL.
        CONTINUE.
      ENDIF.

      TRY.
          DATA(lo_desc) = CAST cl_abap_classdescr( cl_abap_typedescr=>describe_by_name( <ls_tool>-AIPF7ToolInfoProvider ) ).
          DATA(lv_implements) = abap_false.
          LOOP AT lo_desc->interfaces ASSIGNING FIELD-SYMBOL(<ls_intf>).
            IF <ls_intf>-name = 'ZPRU_IF_TOOL_INFO_PROVIDER'.
              lv_implements = abap_true.
              EXIT.
            ENDIF.
          ENDLOOP.
          IF lv_implements = abap_false.
            APPEND INITIAL LINE TO failed-agenttool ASSIGNING FIELD-SYMBOL(<ls_fail>).
            <ls_fail>-%tky        = <ls_tool>-%tky.
            <ls_fail>-%fail-cause = if_abap_behv=>cause-conflict.

            APPEND INITIAL LINE TO reported-agenttool ASSIGNING FIELD-SYMBOL(<ls_report>).
            <ls_report>-%tky        = <ls_tool>-%tky.
            <ls_report>-%state_area = state_area-checktoolinfoprovider.
            <ls_report>-%element-AIPF7ToolInfoProvider = if_abap_behv=>mk-on.
            <ls_report>-%msg        = new_message_with_text(
                severity = if_abap_behv_message=>severity-error
                text     = |Class '{ <ls_tool>-AIPF7ToolInfoProvider }' does not implement ZPRU_IF_TOOL_INFO_PROVIDER.| ).
            CONTINUE.
          ENDIF.
        CATCH cx_root.
          APPEND INITIAL LINE TO failed-agenttool ASSIGNING <ls_fail>.
          <ls_fail>-%tky        = <ls_tool>-%tky.
          <ls_fail>-%fail-cause = if_abap_behv=>cause-conflict.

          APPEND INITIAL LINE TO reported-agenttool ASSIGNING <ls_report>.
          <ls_report>-%tky        = <ls_tool>-%tky.
          <ls_report>-%state_area = state_area-checktoolinfoprovider.
          <ls_report>-%element-AIPF7ToolInfoProvider = if_abap_behv=>mk-on.
          <ls_report>-%msg        = new_message_with_text(
              severity = if_abap_behv_message=>severity-error
              text     = |Class '{ <ls_tool>-AIPF7ToolInfoProvider }' does not exist.| ).
          CONTINUE.
      ENDTRY.

    ENDLOOP.

    LOOP AT lt_not_found ASSIGNING <ls_not_found>.
      APPEND INITIAL LINE TO failed-agenttool ASSIGNING <ls_fail>.
      <ls_fail>-%tky        = <ls_not_found>-%tky.
      <ls_fail>-%fail-cause = if_abap_behv=>cause-not_found.

      APPEND INITIAL LINE TO reported-agenttool ASSIGNING <ls_report>.
      <ls_report>-%tky        = <ls_not_found>-%tky.
      <ls_report>-%state_area = state_area-checktoolinfoprovider.
      <ls_report>-%msg        = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                       text     = |Tool not found.| ).
    ENDLOOP.
  ENDMETHOD.

  METHOD changetoolprovider.
    DATA lt_update TYPE TABLE FOR UPDATE zr_pru_agent\\AgentTool.

    " 1. Check empty input
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).
      IF <ls_key>-%param-AIPF7ToolProvider IS INITIAL.
        APPEND INITIAL LINE TO failed-agenttool ASSIGNING FIELD-SYMBOL(<ls_fail>).
        <ls_fail>-%tky        = <ls_key>-%tky.
        <ls_fail>-%fail-cause = if_abap_behv=>cause-conflict.

        APPEND INITIAL LINE TO reported-agenttool ASSIGNING FIELD-SYMBOL(<ls_report>).
        <ls_report>-%tky        = <ls_key>-%tky.
        <ls_report>-%msg        = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = |Tool provider must not be empty.| ).
      ENDIF.
    ENDLOOP.

    IF failed-agenttool IS NOT INITIAL.
      RETURN.
    ENDIF.

    " 2. Read entities
    READ ENTITIES OF zr_pru_agent IN LOCAL MODE
         ENTITY AgentTool
         FIELDS ( AIPF7ToolProvider )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_tool)
         FAILED DATA(ls_read_failed).

    " 3. Handle not found
    IF ls_read_failed-agenttool IS NOT INITIAL.
      LOOP AT ls_read_failed-agenttool ASSIGNING FIELD-SYMBOL(<ls_read_fail>).
        APPEND INITIAL LINE TO failed-agenttool ASSIGNING <ls_fail>.
        <ls_fail>-%tky        = <ls_read_fail>-%tky.
        <ls_fail>-%fail-cause = if_abap_behv=>cause-not_found.

        APPEND INITIAL LINE TO reported-agenttool ASSIGNING <ls_report>.
        <ls_report>-%tky        = <ls_read_fail>-%tky.
        <ls_report>-%msg        = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = |Tool not found.| ).
      ENDLOOP.
      RETURN.
    ENDIF.

    " 4. Loop — fill local update variable + %control explicitly
    LOOP AT keys ASSIGNING <ls_key>.
      ASSIGN lt_tool[ KEY id COMPONENTS %tky = <ls_key>-%tky ] TO FIELD-SYMBOL(<ls_tool>).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      APPEND INITIAL LINE TO lt_update ASSIGNING FIELD-SYMBOL(<ls_update>).
      <ls_update>-%tky                         = <ls_tool>-%tky.
      <ls_update>-AIPF7ToolProvider             = <ls_key>-%param-AIPF7ToolProvider.
      <ls_update>-%control-AIPF7ToolProvider    = if_abap_behv=>mk-on.
    ENDLOOP.

    " 5. Single MODIFY ENTITIES if anything to update
    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zr_pru_agent IN LOCAL MODE
             ENTITY AgentTool
             UPDATE FIELDS ( AIPF7ToolProvider )
             WITH lt_update.
    ENDIF.
  ENDMETHOD.

  METHOD changetoolschemaprovider.
    DATA lt_update TYPE TABLE FOR UPDATE zr_pru_agent\\AgentTool.

    " 1. Read entities (empty is allowed, no precondition check)
    READ ENTITIES OF zr_pru_agent IN LOCAL MODE
         ENTITY AgentTool
         FIELDS ( AIPF7ToolSchemaProvider )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_tool)
         FAILED DATA(ls_read_failed).

    " 2. Handle not found
    IF ls_read_failed-agenttool IS NOT INITIAL.
      LOOP AT ls_read_failed-agenttool ASSIGNING FIELD-SYMBOL(<ls_read_fail>).
        APPEND INITIAL LINE TO failed-agenttool ASSIGNING FIELD-SYMBOL(<ls_fail>).
        <ls_fail>-%tky        = <ls_read_fail>-%tky.
        <ls_fail>-%fail-cause = if_abap_behv=>cause-not_found.

        APPEND INITIAL LINE TO reported-agenttool ASSIGNING FIELD-SYMBOL(<ls_report>).
        <ls_report>-%tky        = <ls_read_fail>-%tky.
        <ls_report>-%msg        = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = |Tool not found.| ).
      ENDLOOP.
      RETURN.
    ENDIF.

    " 3. Loop — fill local update variable + %control explicitly (empty allowed)
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).
      ASSIGN lt_tool[ KEY id COMPONENTS %tky = <ls_key>-%tky ] TO FIELD-SYMBOL(<ls_tool>).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      APPEND INITIAL LINE TO lt_update ASSIGNING FIELD-SYMBOL(<ls_update>).
      <ls_update>-%tky                               = <ls_tool>-%tky.
      <ls_update>-AIPF7ToolSchemaProvider             = <ls_key>-%param-AIPF7ToolSchemaProvider.
      <ls_update>-%control-AIPF7ToolSchemaProvider    = if_abap_behv=>mk-on.
    ENDLOOP.

    " 4. Single MODIFY ENTITIES if anything to update
    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zr_pru_agent IN LOCAL MODE
             ENTITY AgentTool
             UPDATE FIELDS ( AIPF7ToolSchemaProvider )
             WITH lt_update.
    ENDIF.
  ENDMETHOD.

  METHOD changetoolinfoprovider.
    DATA lt_update TYPE TABLE FOR UPDATE zr_pru_agent\\AgentTool.

    " 1. Read entities (empty is allowed, no precondition check)
    READ ENTITIES OF zr_pru_agent IN LOCAL MODE
         ENTITY AgentTool
         FIELDS ( AIPF7ToolInfoProvider )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_tool)
         FAILED DATA(ls_read_failed).

    " 2. Handle not found
    IF ls_read_failed-agenttool IS NOT INITIAL.
      LOOP AT ls_read_failed-agenttool ASSIGNING FIELD-SYMBOL(<ls_read_fail>).
        APPEND INITIAL LINE TO failed-agenttool ASSIGNING FIELD-SYMBOL(<ls_fail>).
        <ls_fail>-%tky        = <ls_read_fail>-%tky.
        <ls_fail>-%fail-cause = if_abap_behv=>cause-not_found.

        APPEND INITIAL LINE TO reported-agenttool ASSIGNING FIELD-SYMBOL(<ls_report>).
        <ls_report>-%tky        = <ls_read_fail>-%tky.
        <ls_report>-%msg        = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = |Tool not found.| ).
      ENDLOOP.
      RETURN.
    ENDIF.

    " 3. Loop — fill local update variable + %control explicitly (empty allowed)
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).
      ASSIGN lt_tool[ KEY id COMPONENTS %tky = <ls_key>-%tky ] TO FIELD-SYMBOL(<ls_tool>).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      APPEND INITIAL LINE TO lt_update ASSIGNING FIELD-SYMBOL(<ls_update>).
      <ls_update>-%tky                              = <ls_tool>-%tky.
      <ls_update>-AIPF7ToolInfoProvider              = <ls_key>-%param-AIPF7ToolInfoProvider.
      <ls_update>-%control-AIPF7ToolInfoProvider     = if_abap_behv=>mk-on.
    ENDLOOP.

    " 4. Single MODIFY ENTITIES if anything to update
    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zr_pru_agent IN LOCAL MODE
             ENTITY AgentTool
             UPDATE FIELDS ( AIPF7ToolInfoProvider )
             WITH lt_update.
    ENDIF.
  ENDMETHOD.

  METHOD changesteptype.
    DATA lt_update TYPE TABLE FOR UPDATE zr_pru_agent\\AgentTool.

    " 1. Check empty input and valid values
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).
      IF <ls_key>-%param-AIPF7StepType IS INITIAL.
        APPEND INITIAL LINE TO failed-agenttool ASSIGNING FIELD-SYMBOL(<ls_fail>).
        <ls_fail>-%tky        = <ls_key>-%tky.
        <ls_fail>-%fail-cause = if_abap_behv=>cause-conflict.

        APPEND INITIAL LINE TO reported-agenttool ASSIGNING FIELD-SYMBOL(<ls_report>).
        <ls_report>-%tky        = <ls_key>-%tky.
        <ls_report>-%msg        = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = |Step type must not be empty.| ).
      ELSEIF NOT ( <ls_key>-%param-AIPF7StepType = 'A'
                OR <ls_key>-%param-AIPF7StepType = 'K'
                OR <ls_key>-%param-AIPF7StepType = 'B'
                OR <ls_key>-%param-AIPF7StepType = 'H'
                OR <ls_key>-%param-AIPF7StepType = 'S'
                OR <ls_key>-%param-AIPF7StepType = 'L'
                OR <ls_key>-%param-AIPF7StepType = 'D'
                OR <ls_key>-%param-AIPF7StepType = 'M'
                OR <ls_key>-%param-AIPF7StepType = 'Z' ).
        APPEND INITIAL LINE TO failed-agenttool ASSIGNING <ls_fail>.
        <ls_fail>-%tky        = <ls_key>-%tky.
        <ls_fail>-%fail-cause = if_abap_behv=>cause-conflict.

        APPEND INITIAL LINE TO reported-agenttool ASSIGNING <ls_report>.
        <ls_report>-%tky        = <ls_key>-%tky.
        <ls_report>-%msg        = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = |Invalid step type value.| ).
      ENDIF.
    ENDLOOP.

    IF failed-agenttool IS NOT INITIAL.
      RETURN.
    ENDIF.

    " 2. Read entities
    READ ENTITIES OF zr_pru_agent IN LOCAL MODE
         ENTITY AgentTool
         FIELDS ( AIPF7StepType )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_tool)
         FAILED DATA(ls_read_failed).

    " 3. Handle not found
    IF ls_read_failed-agenttool IS NOT INITIAL.
      LOOP AT ls_read_failed-agenttool ASSIGNING FIELD-SYMBOL(<ls_read_fail>).
        APPEND INITIAL LINE TO failed-agenttool ASSIGNING <ls_fail>.
        <ls_fail>-%tky        = <ls_read_fail>-%tky.
        <ls_fail>-%fail-cause = if_abap_behv=>cause-not_found.

        APPEND INITIAL LINE TO reported-agenttool ASSIGNING <ls_report>.
        <ls_report>-%tky        = <ls_read_fail>-%tky.
        <ls_report>-%msg        = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = |Tool not found.| ).
      ENDLOOP.
      RETURN.
    ENDIF.

    " 4. Loop — fill local update variable + %control explicitly
    LOOP AT keys ASSIGNING <ls_key>.
      ASSIGN lt_tool[ KEY id COMPONENTS %tky = <ls_key>-%tky ] TO FIELD-SYMBOL(<ls_tool>).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      APPEND INITIAL LINE TO lt_update ASSIGNING FIELD-SYMBOL(<ls_update>).
      <ls_update>-%tky                    = <ls_tool>-%tky.
      <ls_update>-AIPF7StepType            = <ls_key>-%param-AIPF7StepType.
      <ls_update>-%control-AIPF7StepType   = if_abap_behv=>mk-on.
    ENDLOOP.

    " 5. Single MODIFY ENTITIES if anything to update
    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zr_pru_agent IN LOCAL MODE
             ENTITY AgentTool
             UPDATE FIELDS ( AIPF7StepType )
             WITH lt_update.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
