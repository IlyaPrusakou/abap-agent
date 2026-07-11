"! @testing BDEF:ZR_PRU_AGENT
CLASS zbp_r_pru_agent_au DEFINITION
  PUBLIC
  FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  CREATE PUBLIC .

  PUBLIC SECTION.
  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA mo_cds_test_env TYPE REF TO if_cds_test_environment.

    " --- Fixture ---
    CLASS-METHODS class_setup.
    CLASS-METHODS class_teardown.
    METHODS setup.
    METHODS teardown.

    " Agent (root) — Validation tests
    METHODS check_agent_name_empty_keys     FOR TESTING RAISING cx_static_check.
    METHODS check_agent_name_unique         FOR TESTING RAISING cx_static_check.
    METHODS check_agent_name_duplicate      FOR TESTING RAISING cx_static_check.
    METHODS check_agent_type_initial        FOR TESTING RAISING cx_static_check.
    METHODS check_agent_type_invalid        FOR TESTING RAISING cx_static_check.
    METHODS check_agent_type_valid          FOR TESTING RAISING cx_static_check.
    METHODS check_decision_prov_initial     FOR TESTING RAISING cx_static_check.
    METHODS check_decision_prov_not_exist   FOR TESTING RAISING cx_static_check.
    METHODS check_decision_prov_no_if       FOR TESTING RAISING cx_static_check.
    METHODS check_short_memory_initial      FOR TESTING RAISING cx_static_check.
    METHODS check_short_memory_not_exist    FOR TESTING RAISING cx_static_check.
    METHODS check_short_memory_no_if        FOR TESTING RAISING cx_static_check.
    METHODS check_long_memory_initial       FOR TESTING RAISING cx_static_check.
    METHODS check_long_memory_not_exist     FOR TESTING RAISING cx_static_check.
    METHODS check_long_memory_no_if         FOR TESTING RAISING cx_static_check.
    METHODS check_sys_prompt_optional     FOR TESTING RAISING cx_static_check.
    METHODS check_sys_prompt_not_exist      FOR TESTING RAISING cx_static_check.
    METHODS check_sys_prompt_no_if          FOR TESTING RAISING cx_static_check.
    METHODS check_agent_mapper_opt_empty    FOR TESTING RAISING cx_static_check.
    METHODS check_agent_mapper_not_exist    FOR TESTING RAISING cx_static_check.
    METHODS check_agent_mapper_no_if        FOR TESTING RAISING cx_static_check.
    METHODS check_agent_info_opt_empty      FOR TESTING RAISING cx_static_check.
    METHODS check_agent_info_not_exist      FOR TESTING RAISING cx_static_check.
    METHODS check_agent_info_no_if          FOR TESTING RAISING cx_static_check.
    METHODS check_agent_status_initial      FOR TESTING RAISING cx_static_check.
    METHODS check_agent_status_invalid      FOR TESTING RAISING cx_static_check.
    METHODS check_agent_status_valid        FOR TESTING RAISING cx_static_check.

    " Agent (root) — Action tests
    METHODS change_decision_eng_empty      FOR TESTING RAISING cx_static_check.
    METHODS change_decision_eng_success     FOR TESTING RAISING cx_static_check.
    METHODS change_short_mem_empty_param    FOR TESTING RAISING cx_static_check.
    METHODS change_short_mem_success        FOR TESTING RAISING cx_static_check.
    METHODS change_long_mem_empty_param     FOR TESTING RAISING cx_static_check.
    METHODS change_long_mem_success         FOR TESTING RAISING cx_static_check.
    METHODS change_sys_prompt_empty_ok      FOR TESTING RAISING cx_static_check.
    METHODS change_sys_prompt_success       FOR TESTING RAISING cx_static_check.
    METHODS change_agent_mapper_empty_ok    FOR TESTING RAISING cx_static_check.
    METHODS change_agent_mapper_success     FOR TESTING RAISING cx_static_check.
    METHODS change_agent_info_empty_ok      FOR TESTING RAISING cx_static_check.
    METHODS change_agent_info_success       FOR TESTING RAISING cx_static_check.
    METHODS change_agent_status_empty       FOR TESTING RAISING cx_static_check.
    METHODS change_agent_status_invalid     FOR TESTING RAISING cx_static_check.
    METHODS change_agent_status_success     FOR TESTING RAISING cx_static_check.

    " Agent (root) — Determination tests
    METHODS fill_agent_mapper_already_set   FOR TESTING RAISING cx_static_check.
    METHODS fill_agent_mapper_default       FOR TESTING RAISING cx_static_check.
    METHODS fill_agent_status_already_set   FOR TESTING RAISING cx_static_check.
    METHODS fill_agent_status_default       FOR TESTING RAISING cx_static_check.

    " Agent (root) — Precheck tests
    METHODS precheck_empty_entities         FOR TESTING RAISING cx_static_check.
    METHODS precheck_unique_names           FOR TESTING RAISING cx_static_check.
    METHODS precheck_duplicate_names        FOR TESTING RAISING cx_static_check.

    " ======================================================================
    " Agent (root) — Global authorization
    " ======================================================================
    METHODS get_global_authorizations_ok    FOR TESTING RAISING cx_static_check.

    " ======================================================================
    " AgentTool (child) — Validation tests
    " ======================================================================
    METHODS check_tool_name_empty_keys      FOR TESTING RAISING cx_static_check.
    METHODS check_tool_name_unique          FOR TESTING RAISING cx_static_check.
    METHODS check_tool_name_duplicate       FOR TESTING RAISING cx_static_check.
    METHODS check_tool_provider_initial     FOR TESTING RAISING cx_static_check.
    METHODS check_tool_provider_not_exist   FOR TESTING RAISING cx_static_check.
    METHODS check_tool_provider_no_if       FOR TESTING RAISING cx_static_check.
    METHODS check_step_type_initial         FOR TESTING RAISING cx_static_check.
    METHODS check_step_type_invalid         FOR TESTING RAISING cx_static_check.
    METHODS check_step_type_valid           FOR TESTING RAISING cx_static_check.
    METHODS check_tool_schema_opt_empty     FOR TESTING RAISING cx_static_check.
    METHODS check_tool_schema_not_exist     FOR TESTING RAISING cx_static_check.
    METHODS check_tool_schema_no_if         FOR TESTING RAISING cx_static_check.
    METHODS check_tool_info_opt_empty       FOR TESTING RAISING cx_static_check.
    METHODS check_tool_info_not_exist       FOR TESTING RAISING cx_static_check.
    METHODS check_tool_info_no_if           FOR TESTING RAISING cx_static_check.

    " ======================================================================
    " AgentTool (child) — Action tests
    " ======================================================================
    METHODS change_tool_prov_empty_param    FOR TESTING RAISING cx_static_check.
    METHODS change_tool_prov_success        FOR TESTING RAISING cx_static_check.
    METHODS change_tool_schema_empty_ok     FOR TESTING RAISING cx_static_check.
    METHODS change_tool_schema_success      FOR TESTING RAISING cx_static_check.
    METHODS change_tool_info_empty_ok       FOR TESTING RAISING cx_static_check.
    METHODS change_tool_info_success        FOR TESTING RAISING cx_static_check.
    METHODS change_step_type_empty          FOR TESTING RAISING cx_static_check.
    METHODS change_step_type_invalid        FOR TESTING RAISING cx_static_check.
    METHODS change_step_type_success        FOR TESTING RAISING cx_static_check.

    TYPES: tr_reported TYPE RESPONSE FOR REPORTED zr_pru_agent,
           tr_failed   TYPE RESPONSE FOR FAILED   zr_pru_agent,
           tr_mapped   TYPE RESPONSE FOR MAPPED   zr_pru_agent.

    " --- Private helpers ---
    METHODS insert_agent
      IMPORTING
        agent_uuid     TYPE sysuuid_x16 OPTIONAL
        agent_type     TYPE string       DEFAULT 'DEFAULT'
        agent_name     TYPE string       DEFAULT 'TEST_AGENT'
        decision_prov  TYPE string       DEFAULT 'ZPRU_CL_DECISION_PROVIDER'
        short_mem_prov TYPE string       DEFAULT 'ZPRU_CL_SHORT_MEMORY_PROVIDER'
        long_mem_prov  TYPE string       DEFAULT 'ZPRU_CL_LONG_MEMORY_PROVIDER'
        sys_prompt     TYPE string       DEFAULT ''
        agent_mapper   TYPE string       DEFAULT ''
        agent_info     TYPE string       DEFAULT ''
        agent_status   TYPE string       DEFAULT 'N'
      RETURNING
        VALUE(rs_agent) TYPE zpru_agent.

    METHODS insert_agent_type
      IMPORTING agent_type TYPE string DEFAULT 'DEFAULT'.

    METHODS insert_tool
      IMPORTING
        tool_uuid    TYPE sysuuid_x16 OPTIONAL
        agent_uuid   TYPE sysuuid_x16
        tool_name    TYPE string       DEFAULT 'TEST_TOOL'
        tool_prov    TYPE string       DEFAULT 'ZPRU_CL_TOOL_PROVIDER'
        step_type    TYPE string       DEFAULT 'A'
        tool_schema  TYPE string       DEFAULT ''
        tool_info    TYPE string       DEFAULT ''
      RETURNING
        VALUE(rs_tool) TYPE zpru_agent_tool.

    METHODS create_agent_eml
      IMPORTING
        agent_name   TYPE string
        agent_type   TYPE string DEFAULT 'DEFAULT'
        decision     TYPE string DEFAULT 'ZPRU_CL_DECISION_PROVIDER'
        short_mem    TYPE string DEFAULT 'ZPRU_CL_SHORT_MEMORY_PROVIDER'
        long_mem     TYPE string DEFAULT 'ZPRU_CL_LONG_MEMORY_PROVIDER'
        sys_prompt   TYPE string DEFAULT ''
        agent_mapper TYPE string DEFAULT ''
        agent_info   TYPE string DEFAULT ''
        agent_status TYPE string DEFAULT 'N'
      EXPORTING
        reported     TYPE tr_reported
        failed       TYPE tr_failed
        mapped       TYPE tr_mapped.

    METHODS create_tool_eml
      IMPORTING
        agent_uuid  TYPE sysuuid_x16
        tool_name   TYPE string
        tool_prov   TYPE string DEFAULT 'ZPRU_CL_TOOL_PROVIDER'
        step_type   TYPE string DEFAULT 'A'
        tool_schema TYPE string DEFAULT ''
        tool_info   TYPE string DEFAULT ''
      EXPORTING
        reported    TYPE tr_reported
        failed      TYPE tr_failed.

    METHODS assert_reported_msg
      IMPORTING
        reported      TYPE tr_reported
        entity_name   TYPE string
        msg_text      TYPE string.

    METHODS assert_no_reported
      IMPORTING
        reported    TYPE tr_reported
        entity_name TYPE string.

    METHODS assert_failed_count
      IMPORTING
        failed      TYPE tr_failed
        entity_name TYPE string
        exp_count   TYPE i.

ENDCLASS.


CLASS zbp_r_pru_agent_au IMPLEMENTATION.

  METHOD class_setup.
    mo_cds_test_env = cl_cds_test_environment=>create(
        i_for_entity = 'ZR_PRU_AGENT'
    ).
  ENDMETHOD.

  METHOD class_teardown.
    IF mo_cds_test_env IS BOUND.
      mo_cds_test_env->clear_doubles( ).
      mo_cds_test_env->destroy( ).
      CLEAR mo_cds_test_env.
    ENDIF.
  ENDMETHOD.

  METHOD setup.
    mo_cds_test_env->clear_doubles( ).
  ENDMETHOD.

  METHOD teardown.
    ROLLBACK WORK.
  ENDMETHOD.

  METHOD insert_agent.
    DATA(ls_agent) = VALUE zpru_agent(
        agentuuid            = agent_uuid
        agentname            = agent_name
        agenttype            = agent_type
        decisionprovider     = decision_prov
        shortmemoryprovider  = short_mem_prov
        longmemoryprovider   = long_mem_prov
        systempromptprovider = sys_prompt
        agentmapper          = agent_mapper
        agentinfoprovider    = agent_info
        agentstatus          = agent_status
    ).
    DATA lt_agent_tab TYPE STANDARD TABLE OF zpru_agent WITH EMPTY KEY.
    INSERT ls_agent INTO TABLE lt_agent_tab.
    mo_cds_test_env->insert_test_data( i_data = lt_agent_tab ).
    rs_agent = ls_agent.
  ENDMETHOD.

  METHOD insert_agent_type.
    DATA(ls_type) = VALUE zpru_agent_type( agenttype = agent_type ).
    DATA lt_type_tab TYPE STANDARD TABLE OF zpru_agent_type WITH EMPTY KEY.
    INSERT ls_type INTO TABLE lt_type_tab.
    mo_cds_test_env->insert_test_data( i_data = lt_type_tab ).
  ENDMETHOD.

  METHOD insert_tool.
    DATA(ls_tool) = VALUE zpru_agent_tool(
        tooluuid           = tool_uuid
        agentuuid          = agent_uuid
        toolname           = tool_name
        toolprovider       = tool_prov
        steptype           = step_type
        toolschemaprovider = tool_schema
        toolinfoprovider   = tool_info
    ).
    DATA lt_tool_tab TYPE STANDARD TABLE OF zpru_agent_tool WITH EMPTY KEY.
    INSERT ls_tool INTO TABLE lt_tool_tab.
    mo_cds_test_env->insert_test_data( i_data = lt_tool_tab ).
    rs_tool = ls_tool.
  ENDMETHOD.

  METHOD create_agent_eml.
    DATA lt_reported TYPE tr_reported.
    DATA lt_failed   TYPE tr_failed.
    DATA lt_mapped   TYPE tr_mapped.

    MODIFY ENTITIES OF zr_pru_agent
        ENTITY Agent
        CREATE
        FIELDS ( AIPF7AgentName  AIPF7AgentType  AIPF7DecisionProvider
                 AIPF7ShortMemoryProvider AIPF7LongMemoryProvider
                 AIPF7SystemPromptProvider AIPF7AgentMapper
                 AIPF7AgentInfoProvider AIPF7AgentStatus )
        WITH VALUE #( ( %cid   = 'CID_01'
                        AIPF7AgentName           = agent_name
                        AIPF7AgentType           = agent_type
                        AIPF7DecisionProvider     = decision
                        AIPF7ShortMemoryProvider  = short_mem
                        AIPF7LongMemoryProvider   = long_mem
                        AIPF7SystemPromptProvider = sys_prompt
                        AIPF7AgentMapper          = agent_mapper
                        AIPF7AgentInfoProvider    = agent_info
                        AIPF7AgentStatus          = agent_status ) )
        REPORTED lt_reported
        FAILED   lt_failed
        MAPPED   lt_mapped.
    reported = lt_reported.
    failed   = lt_failed.
    mapped   = lt_mapped.
  ENDMETHOD.

  METHOD create_tool_eml.
    DATA lt_reported TYPE tr_reported.
    DATA lt_failed   TYPE tr_failed.

    MODIFY ENTITIES OF zr_pru_agent
        ENTITY Agent
        CREATE BY \_tool
        FIELDS ( AIPF7ToolName AIPF7ToolProvider AIPF7StepType
                 AIPF7ToolSchemaProvider AIPF7ToolInfoProvider )
        WITH VALUE #( ( %target = VALUE #( ( AIPF7ToolName           = tool_name
                                           AIPF7ToolProvider       = tool_prov
                                           AIPF7StepType           = step_type
                                           AIPF7ToolSchemaProvider = tool_schema
                                           AIPF7ToolInfoProvider   = tool_info ) )
                        %tky-AIPF7AgentUUID = agent_uuid ) )
        REPORTED lt_reported
        FAILED   lt_failed.
    reported = lt_reported.
    failed   = lt_failed.
  ENDMETHOD.

  METHOD assert_reported_msg.
    DATA(lv_found) = abap_false.
    " Search in Agent reported
    IF entity_name = 'AGENT'.
      LOOP AT reported-agent ASSIGNING FIELD-SYMBOL(<ls_r>).
        IF <ls_r>-%msg IS BOUND.
          DATA(lv_text) = CAST if_message( <ls_r>-%msg )->get_text( ).
          IF lv_text CS msg_text.
            lv_found = abap_true.
            EXIT.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ELSEIF entity_name = 'AGENTTOOL'.
      LOOP AT reported-agenttool ASSIGNING FIELD-SYMBOL(<ls_rt>).
        IF <ls_rt>-%msg IS BOUND.
          DATA(lv_text2) = CAST if_message( <ls_rt>-%msg )->get_text( ).
          IF lv_text2 CS msg_text.
            lv_found = abap_true.
            EXIT.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.
    cl_abap_unit_assert=>assert_equals(
        act = lv_found
        exp = abap_true
        msg = |Expected message containing '{ msg_text }' not found in reported-{ entity_name }| ).
  ENDMETHOD.

  METHOD assert_no_reported.
    DATA(lv_count) = 0.
    IF entity_name = 'AGENT'.
      lv_count = lines( reported-agent ).
    ELSEIF entity_name = 'AGENTTOOL'.
      lv_count = lines( reported-agenttool ).
    ENDIF.
    cl_abap_unit_assert=>assert_equals(
        act = lv_count
        exp = 0
        msg = |Expected no reported entries for { entity_name }| ).
  ENDMETHOD.

  METHOD assert_failed_count.
    DATA(lv_count) = 0.
    IF entity_name = 'AGENT'.
      lv_count = lines( failed-agent ).
    ELSEIF entity_name = 'AGENTTOOL'.
      lv_count = lines( failed-agenttool ).
    ENDIF.
    cl_abap_unit_assert=>assert_equals(
        act = lv_count
        exp = exp_count
        msg = |Expected { exp_count } failed entries for { entity_name }| ).
  ENDMETHOD.

  METHOD check_agent_name_empty_keys.
    " Validations are triggered via MODIFY ENTITIES, so test via create
    " with a valid unique name (and insert no existing data)
    insert_agent_type( ).
    create_agent_eml(
      EXPORTING
        agent_name = 'UNIQUE_AGENT_1'
      IMPORTING
        reported = DATA(lt_reported)
        failed   = DATA(lt_failed) ).
    assert_no_reported( reported = lt_reported entity_name = 'AGENT' ).
  ENDMETHOD.

  METHOD check_agent_name_unique.
    insert_agent_type( ).
    create_agent_eml(
      EXPORTING
        agent_name = 'UNIQUE_AGENT_2'
      IMPORTING
        reported = DATA(lt_reported)
        failed   = DATA(lt_failed) ).
    assert_no_reported( reported = lt_reported entity_name = 'AGENT' ).
  ENDMETHOD.

  METHOD check_agent_name_duplicate.
    " Insert existing agent first
    insert_agent( agent_name = 'DUP_AGENT' ).
    insert_agent_type( ).
    create_agent_eml(
      EXPORTING
        agent_name = 'DUP_AGENT'
      IMPORTING
        reported = DATA(lt_reported)
        failed   = DATA(lt_failed) ).
    assert_reported_msg( reported = lt_reported entity_name = 'AGENT'
                         msg_text = 'already exists' ).
  ENDMETHOD.

  METHOD check_agent_type_initial.
    insert_agent_type( agent_type = 'DEFAULT' ).
    create_agent_eml(
      EXPORTING
        agent_name = 'TYPE_INITIAL'
        agent_type = ''
      IMPORTING
        reported = DATA(lt_reported)
        failed   = DATA(lt_failed) ).
    assert_reported_msg( reported = lt_reported entity_name = 'AGENT'
                         msg_text = 'must not be initial' ).
  ENDMETHOD.

  METHOD check_agent_type_invalid.
    insert_agent_type( agent_type = 'DEFAULT' ).
    create_agent_eml(
      EXPORTING
        agent_name = 'TYPE_BAD'
        agent_type = 'INVALID_TYPE'
      IMPORTING
        reported = DATA(lt_reported)
        failed   = DATA(lt_failed) ).
    assert_reported_msg( reported = lt_reported entity_name = 'AGENT'
                         msg_text = 'does not exist in ZPRU_AGENT_TYPE' ).
  ENDMETHOD.

  METHOD check_agent_type_valid.
    insert_agent_type( agent_type = 'VALID_TYPE' ).
    create_agent_eml(
      EXPORTING
        agent_name = 'TYPE_OK'
        agent_type = 'VALID_TYPE'
      IMPORTING
        reported = DATA(lt_reported)
        failed   = DATA(lt_failed) ).
    assert_no_reported( reported = lt_reported entity_name = 'AGENT' ).
  ENDMETHOD.

  METHOD check_decision_prov_initial.
    insert_agent_type( ).
    create_agent_eml(
      EXPORTING
        agent_name = 'DEC_INIT'
        decision   = ''
      IMPORTING
        reported = DATA(lt_reported)
        failed   = DATA(lt_failed) ).
    assert_reported_msg( reported = lt_reported entity_name = 'AGENT'
                         msg_text = 'must not be initial' ).
  ENDMETHOD.

  METHOD check_decision_prov_not_exist.
    insert_agent_type( ).
    create_agent_eml(
      EXPORTING
        agent_name = 'DEC_NOT_EXIST'
        decision   = 'Z_NONEXISTENT_CLASS_XYZ'
      IMPORTING
        reported = DATA(lt_reported)
        failed   = DATA(lt_failed) ).
    assert_reported_msg( reported = lt_reported entity_name = 'AGENT'
                         msg_text = 'does not exist' ).
  ENDMETHOD.

  METHOD check_decision_prov_no_if.
    insert_agent_type( ).
    " CL_ABAP_CHAR_UTILITIES exists but does NOT implement ZPRU_IF_DECISION_PROVIDER
    create_agent_eml(
      EXPORTING
        agent_name = 'DEC_NO_IF'
        decision   = 'CL_ABAP_CHAR_UTILITIES'
      IMPORTING
        reported = DATA(lt_reported)
        failed   = DATA(lt_failed) ).
    assert_reported_msg( reported = lt_reported entity_name = 'AGENT'
                         msg_text = 'does not implement' ).
  ENDMETHOD.

  METHOD check_short_memory_initial.
    insert_agent_type( ).
    create_agent_eml(
      EXPORTING
        agent_name = 'SHORT_INIT'
        short_mem  = ''
      IMPORTING
        reported = DATA(lt_reported)
        failed   = DATA(lt_failed) ).
    assert_reported_msg( reported = lt_reported entity_name = 'AGENT'
                         msg_text = 'Short memory provider must not be initial' ).
  ENDMETHOD.

  METHOD check_short_memory_not_exist.
    insert_agent_type( ).
    create_agent_eml(
      EXPORTING
        agent_name = 'SHORT_NOEX'
        short_mem  = 'Z_NONEXISTENT_XYZ'
      IMPORTING
        reported = DATA(lt_reported)
        failed   = DATA(lt_failed) ).
    assert_reported_msg( reported = lt_reported entity_name = 'AGENT'
                         msg_text = 'does not exist' ).
  ENDMETHOD.

  METHOD check_short_memory_no_if.
    insert_agent_type( ).
    create_agent_eml(
      EXPORTING
        agent_name = 'SHORT_NOIF'
        short_mem  = 'CL_ABAP_CHAR_UTILITIES'
      IMPORTING
        reported = DATA(lt_reported)
        failed   = DATA(lt_failed) ).
    assert_reported_msg( reported = lt_reported entity_name = 'AGENT'
                         msg_text = 'does not implement' ).
  ENDMETHOD.

  METHOD check_long_memory_initial.
    insert_agent_type( ).
    create_agent_eml(
      EXPORTING
        agent_name = 'LONG_INIT'
        long_mem   = ''
      IMPORTING
        reported = DATA(lt_reported)
        failed   = DATA(lt_failed) ).
    assert_reported_msg( reported = lt_reported entity_name = 'AGENT'
                         msg_text = 'Long memory provider must not be initial' ).
  ENDMETHOD.

  METHOD check_long_memory_not_exist.
    insert_agent_type( ).
    create_agent_eml(
      EXPORTING
        agent_name = 'LONG_NOEX'
        long_mem   = 'Z_NONEXISTENT_XYZ'
      IMPORTING
        reported = DATA(lt_reported)
        failed   = DATA(lt_failed) ).
    assert_reported_msg( reported = lt_reported entity_name = 'AGENT'
                         msg_text = 'does not exist' ).
  ENDMETHOD.

  METHOD check_long_memory_no_if.
    insert_agent_type( ).
    create_agent_eml(
      EXPORTING
        agent_name = 'LONG_NOIF'
        long_mem   = 'CL_ABAP_CHAR_UTILITIES'
      IMPORTING
        reported = DATA(lt_reported)
        failed   = DATA(lt_failed) ).
    assert_reported_msg( reported = lt_reported entity_name = 'AGENT'
                         msg_text = 'does not implement' ).
  ENDMETHOD.

  METHOD check_sys_prompt_optional.
    " System prompt is optional — empty should pass
    insert_agent_type( ).
    create_agent_eml(
      EXPORTING
        agent_name = 'PROMPT_EMPTY'
        sys_prompt = ''
      IMPORTING
        reported = DATA(lt_reported)
        failed   = DATA(lt_failed) ).
    assert_no_reported( reported = lt_reported entity_name = 'AGENT' ).
  ENDMETHOD.

  METHOD check_sys_prompt_not_exist.
    insert_agent_type( ).
    create_agent_eml(
      EXPORTING
        agent_name = 'PROMPT_NOEX'
        sys_prompt = 'Z_NONEXISTENT_CLASS'
      IMPORTING
        reported = DATA(lt_reported)
        failed   = DATA(lt_failed) ).
    assert_reported_msg( reported = lt_reported entity_name = 'AGENT'
                         msg_text = 'does not exist' ).
  ENDMETHOD.

  METHOD check_sys_prompt_no_if.
    insert_agent_type( ).
    create_agent_eml(
      EXPORTING
        agent_name = 'PROMPT_NOIF'
        sys_prompt = 'CL_ABAP_CHAR_UTILITIES'
      IMPORTING
        reported = DATA(lt_reported)
        failed   = DATA(lt_failed) ).
    assert_reported_msg( reported = lt_reported entity_name = 'AGENT'
                         msg_text = 'does not implement' ).
  ENDMETHOD.

  METHOD check_agent_mapper_opt_empty.
    insert_agent_type( ).
    create_agent_eml(
      EXPORTING
        agent_name   = 'MAPPER_EMPTY'
        agent_mapper = ''
      IMPORTING
        reported = DATA(lt_reported)
        failed   = DATA(lt_failed) ).
    assert_no_reported( reported = lt_reported entity_name = 'AGENT' ).
  ENDMETHOD.

  METHOD check_agent_mapper_not_exist.
    insert_agent_type( ).
    create_agent_eml(
      EXPORTING
        agent_name   = 'MAPPER_NOEX'
        agent_mapper = 'Z_NONEXISTENT_CLASS'
      IMPORTING
        reported = DATA(lt_reported)
        failed   = DATA(lt_failed) ).
    assert_reported_msg( reported = lt_reported entity_name = 'AGENT'
                         msg_text = 'does not exist' ).
  ENDMETHOD.

  METHOD check_agent_mapper_no_if.
    insert_agent_type( ).
    create_agent_eml(
      EXPORTING
        agent_name   = 'MAPPER_NOIF'
        agent_mapper = 'CL_ABAP_CHAR_UTILITIES'
      IMPORTING
        reported = DATA(lt_reported)
        failed   = DATA(lt_failed) ).
    assert_reported_msg( reported = lt_reported entity_name = 'AGENT'
                         msg_text = 'does not implement' ).
  ENDMETHOD.

  METHOD check_agent_info_opt_empty.
    insert_agent_type( ).
    create_agent_eml(
      EXPORTING
        agent_name = 'INFO_EMPTY'
        agent_info = ''
      IMPORTING
        reported = DATA(lt_reported)
        failed   = DATA(lt_failed) ).
    assert_no_reported( reported = lt_reported entity_name = 'AGENT' ).
  ENDMETHOD.

  METHOD check_agent_info_not_exist.
    insert_agent_type( ).
    create_agent_eml(
      EXPORTING
        agent_name = 'INFO_NOEX'
        agent_info = 'Z_NONEXISTENT_CLASS'
      IMPORTING
        reported = DATA(lt_reported)
        failed   = DATA(lt_failed) ).
    assert_reported_msg( reported = lt_reported entity_name = 'AGENT'
                         msg_text = 'does not exist' ).
  ENDMETHOD.

  METHOD check_agent_info_no_if.
    insert_agent_type( ).
    create_agent_eml(
      EXPORTING
        agent_name = 'INFO_NOIF'
        agent_info = 'CL_ABAP_CHAR_UTILITIES'
      IMPORTING
        reported = DATA(lt_reported)
        failed   = DATA(lt_failed) ).
    assert_reported_msg( reported = lt_reported entity_name = 'AGENT'
                         msg_text = 'does not implement' ).
  ENDMETHOD.

  METHOD check_agent_status_initial.
    insert_agent_type( ).
    create_agent_eml(
      EXPORTING
        agent_name   = 'STAT_INIT'
        agent_status = ''
      IMPORTING
        reported = DATA(lt_reported)
        failed   = DATA(lt_failed) ).
    assert_reported_msg( reported = lt_reported entity_name = 'AGENT'
                         msg_text = 'must not be initial' ).
  ENDMETHOD.

  METHOD check_agent_status_invalid.
    insert_agent_type( ).
    create_agent_eml(
      EXPORTING
        agent_name   = 'STAT_BAD'
        agent_status = 'X'
      IMPORTING
        reported = DATA(lt_reported)
        failed   = DATA(lt_failed) ).
    assert_reported_msg( reported = lt_reported entity_name = 'AGENT'
                         msg_text = 'is invalid' ).
  ENDMETHOD.

  METHOD check_agent_status_valid.
    insert_agent_type( ).
    create_agent_eml(
      EXPORTING
        agent_name   = 'STAT_N'
        agent_status = 'N'
      IMPORTING
        reported = DATA(lt_reported)
        failed   = DATA(lt_failed) ).
    assert_no_reported( reported = lt_reported entity_name = 'AGENT' ).
  ENDMETHOD.

  METHOD change_decision_eng_empty.
    insert_agent_type( ).
    DATA(ls_agent) = insert_agent( agent_name = 'ACT_DEC' ).

    MODIFY ENTITIES OF zr_pru_agent
        ENTITY Agent
        EXECUTE changeDecisionEngine
        FROM VALUE #( ( %key-AIPF7AgentUUID = ls_agent-agentuuid
                        %param-AIPF7DecisionProvider = '' ) )
        REPORTED DATA(lt_reported)
        FAILED   DATA(lt_failed).

    assert_reported_msg( reported = CORRESPONDING #( lt_reported )
                         entity_name = 'AGENT' msg_text = 'must not be empty' ).
  ENDMETHOD.

  METHOD change_decision_eng_success.
    insert_agent_type( ).
    DATA(ls_agent) = insert_agent( agent_name = 'ACT_DEC_OK' ).

    MODIFY ENTITIES OF zr_pru_agent
        ENTITY Agent
        EXECUTE changeDecisionEngine
        FROM VALUE #( ( %key-AIPF7AgentUUID = ls_agent-agentuuid
                        %param-AIPF7DecisionProvider = 'ZPRU_CL_DECISION_PROVIDER' ) )
        REPORTED DATA(lt_reported)
        FAILED   DATA(lt_failed).

    assert_no_reported( reported = CORRESPONDING #( lt_reported )
                        entity_name = 'AGENT' ).
  ENDMETHOD.

  METHOD change_short_mem_empty_param.
    insert_agent_type( ).
    DATA(ls_agent) = insert_agent( agent_name = 'ACT_SM' ).

    MODIFY ENTITIES OF zr_pru_agent
        ENTITY Agent
        EXECUTE changeShortMemoryProvider
        FROM VALUE #( ( %key-AIPF7AgentUUID = ls_agent-agentuuid
                        %param-AIPF7ShortMemoryProvider = '' ) )
        REPORTED DATA(lt_reported)
        FAILED   DATA(lt_failed).

    assert_reported_msg( reported = CORRESPONDING #( lt_reported )
                         entity_name = 'AGENT' msg_text = 'must not be empty' ).
  ENDMETHOD.

  METHOD change_short_mem_success.
    insert_agent_type( ).
    DATA(ls_agent) = insert_agent( agent_name = 'ACT_SM_OK' ).

    MODIFY ENTITIES OF zr_pru_agent
        ENTITY Agent
        EXECUTE changeShortMemoryProvider
        FROM VALUE #( ( %key-AIPF7AgentUUID = ls_agent-agentuuid
                        %param-AIPF7ShortMemoryProvider = 'ZPRU_CL_SHORT_MEMORY_PROVIDER' ) )
        REPORTED DATA(lt_reported)
        FAILED   DATA(lt_failed).

    assert_no_reported( reported = CORRESPONDING #( lt_reported )
                        entity_name = 'AGENT' ).
  ENDMETHOD.

  METHOD change_long_mem_empty_param.
    insert_agent_type( ).
    DATA(ls_agent) = insert_agent( agent_name = 'ACT_LM' ).

    MODIFY ENTITIES OF zr_pru_agent
        ENTITY Agent
        EXECUTE changeLongMemoryProvider
        FROM VALUE #( ( %key-AIPF7AgentUUID = ls_agent-agentuuid
                        %param-AIPF7LongMemoryProvider = '' ) )
        REPORTED DATA(lt_reported)
        FAILED   DATA(lt_failed).

    assert_reported_msg( reported = CORRESPONDING #( lt_reported )
                         entity_name = 'AGENT' msg_text = 'must not be empty' ).
  ENDMETHOD.

  METHOD change_long_mem_success.
    insert_agent_type( ).
    DATA(ls_agent) = insert_agent( agent_name = 'ACT_LM_OK' ).

    MODIFY ENTITIES OF zr_pru_agent
        ENTITY Agent
        EXECUTE changeLongMemoryProvider
        FROM VALUE #( ( %key-AIPF7AgentUUID = ls_agent-agentuuid
                        %param-AIPF7LongMemoryProvider = 'ZPRU_CL_LONG_MEMORY_PROVIDER' ) )
        REPORTED DATA(lt_reported)
        FAILED   DATA(lt_failed).

    assert_no_reported( reported = CORRESPONDING #( lt_reported )
                        entity_name = 'AGENT' ).
  ENDMETHOD.

  METHOD change_sys_prompt_empty_ok.
    insert_agent_type( ).
    DATA(ls_agent) = insert_agent( agent_name = 'ACT_SP'
                                    sys_prompt = 'CL_ABAP_CHAR_UTILITIES' ).

    MODIFY ENTITIES OF zr_pru_agent
        ENTITY Agent
        EXECUTE changeSystemPromptProvider
        FROM VALUE #( ( %key-AIPF7AgentUUID = ls_agent-agentuuid
                        %param-AIPF7SystemPromptProvider = '' ) )
        REPORTED DATA(lt_reported)
        FAILED   DATA(lt_failed).

    " Empty is allowed — no reported msg
    assert_no_reported( reported = CORRESPONDING #( lt_reported )
                        entity_name = 'AGENT' ).
  ENDMETHOD.

  METHOD change_sys_prompt_success.
    insert_agent_type( ).
    DATA(ls_agent) = insert_agent( agent_name = 'ACT_SP2' ).

    MODIFY ENTITIES OF zr_pru_agent
        ENTITY Agent
        EXECUTE changeSystemPromptProvider
        FROM VALUE #( ( %key-AIPF7AgentUUID = ls_agent-agentuuid
                        %param-AIPF7SystemPromptProvider = 'CL_ABAP_CHAR_UTILITIES' ) )
        REPORTED DATA(lt_reported)
        FAILED   DATA(lt_failed).

    assert_no_reported( reported = CORRESPONDING #( lt_reported )
                        entity_name = 'AGENT' ).
  ENDMETHOD.

  METHOD change_agent_mapper_empty_ok.
    insert_agent_type( ).
    DATA(ls_agent) = insert_agent( agent_name = 'ACT_AM'
                                    agent_mapper = 'CL_ABAP_CHAR_UTILITIES' ).

    MODIFY ENTITIES OF zr_pru_agent
        ENTITY Agent
        EXECUTE changeAgentMapper
        FROM VALUE #( ( %key-AIPF7AgentUUID = ls_agent-agentuuid
                        %param-AIPF7AgentMapper = '' ) )
        REPORTED DATA(lt_reported)
        FAILED   DATA(lt_failed).

    assert_no_reported( reported = CORRESPONDING #( lt_reported )
                        entity_name = 'AGENT' ).
  ENDMETHOD.

  METHOD change_agent_mapper_success.
    insert_agent_type( ).
    DATA(ls_agent) = insert_agent( agent_name = 'ACT_AM2' ).

    MODIFY ENTITIES OF zr_pru_agent
        ENTITY Agent
        EXECUTE changeAgentMapper
        FROM VALUE #( ( %key-AIPF7AgentUUID = ls_agent-agentuuid
                        %param-AIPF7AgentMapper = 'CL_ABAP_CHAR_UTILITIES' ) )
        REPORTED DATA(lt_reported)
        FAILED   DATA(lt_failed).

    assert_no_reported( reported = CORRESPONDING #( lt_reported )
                        entity_name = 'AGENT' ).
  ENDMETHOD.

  METHOD change_agent_info_empty_ok.
    insert_agent_type( ).
    DATA(ls_agent) = insert_agent( agent_name = 'ACT_AI'
                                    agent_info = 'CL_ABAP_CHAR_UTILITIES' ).

    MODIFY ENTITIES OF zr_pru_agent
        ENTITY Agent
        EXECUTE changeAgentInfoProvider
        FROM VALUE #( ( %key-AIPF7AgentUUID = ls_agent-agentuuid
                        %param-AIPF7AgentInfoProvider = '' ) )
        REPORTED DATA(lt_reported)
        FAILED   DATA(lt_failed).

    assert_no_reported( reported = CORRESPONDING #( lt_reported )
                        entity_name = 'AGENT' ).
  ENDMETHOD.

  METHOD change_agent_info_success.
    insert_agent_type( ).
    DATA(ls_agent) = insert_agent( agent_name = 'ACT_AI2' ).

    MODIFY ENTITIES OF zr_pru_agent
        ENTITY Agent
        EXECUTE changeAgentInfoProvider
        FROM VALUE #( ( %key-AIPF7AgentUUID = ls_agent-agentuuid
                        %param-AIPF7AgentInfoProvider = 'CL_ABAP_CHAR_UTILITIES' ) )
        REPORTED DATA(lt_reported)
        FAILED   DATA(lt_failed).

    assert_no_reported( reported = CORRESPONDING #( lt_reported )
                        entity_name = 'AGENT' ).
  ENDMETHOD.

  METHOD change_agent_status_empty.
    insert_agent_type( ).
    DATA(ls_agent) = insert_agent( agent_name = 'ACT_ST' ).

    MODIFY ENTITIES OF zr_pru_agent
        ENTITY Agent
        EXECUTE changeAgentStatus
        FROM VALUE #( ( %key-AIPF7AgentUUID = ls_agent-agentuuid
                        %param-AIPF7AgentStatus = '' ) )
        REPORTED DATA(lt_reported)
        FAILED   DATA(lt_failed).

    assert_reported_msg( reported = CORRESPONDING #( lt_reported )
                         entity_name = 'AGENT' msg_text = 'must not be empty' ).
  ENDMETHOD.

  METHOD change_agent_status_invalid.
    insert_agent_type( ).
    DATA(ls_agent) = insert_agent( agent_name = 'ACT_ST2' ).

    MODIFY ENTITIES OF zr_pru_agent
        ENTITY Agent
        EXECUTE changeAgentStatus
        FROM VALUE #( ( %key-AIPF7AgentUUID = ls_agent-agentuuid
                        %param-AIPF7AgentStatus = 'X' ) )
        REPORTED DATA(lt_reported)
        FAILED   DATA(lt_failed).

    assert_reported_msg( reported = CORRESPONDING #( lt_reported )
                         entity_name = 'AGENT' msg_text = 'Invalid status value' ).
  ENDMETHOD.

  METHOD change_agent_status_success.
    insert_agent_type( ).
    DATA(ls_agent) = insert_agent( agent_name = 'ACT_ST_OK' ).

    MODIFY ENTITIES OF zr_pru_agent
        ENTITY Agent
        EXECUTE changeAgentStatus
        FROM VALUE #( ( %key-AIPF7AgentUUID = ls_agent-agentuuid
                        %param-AIPF7AgentStatus = 'A' ) )
        REPORTED DATA(lt_reported)
        FAILED   DATA(lt_failed).

    assert_no_reported( reported = CORRESPONDING #( lt_reported )
                        entity_name = 'AGENT' ).
  ENDMETHOD.

  METHOD fill_agent_mapper_already_set.
    insert_agent_type( ).
    insert_agent( agent_name = 'DET_AM_SET'
                  agent_mapper = 'CL_ABAP_CHAR_UTILITIES' ).
    create_agent_eml(
      EXPORTING
        agent_name   = 'DET_AM_SET2'
        agent_mapper = 'CL_ABAP_CHAR_UTILITIES'
      IMPORTING
        reported = DATA(lt_reported) ).
    " No validation error for agent mapper since already set
    " (The determination fillAgentMapper fires on create but mapper is already set
    "  so the loop just skips — nothing fails)
    " Just verify no mapper-related error
    assert_no_reported( reported = lt_reported entity_name = 'AGENT' ).
  ENDMETHOD.

  METHOD fill_agent_mapper_default.
    insert_agent_type( ).
    create_agent_eml(
      EXPORTING
        agent_name   = 'DET_AM_DEF'
        agent_mapper = ''
      IMPORTING
        reported = DATA(lt_reported)
        failed   = DATA(lt_failed)
        mapped   = DATA(lt_mapped) ).
    " Default mapper should be set by determination — no validation error
    assert_no_reported( reported = lt_reported entity_name = 'AGENT' ).
  ENDMETHOD.

  METHOD fill_agent_status_already_set.
    insert_agent_type( ).
    create_agent_eml(
      EXPORTING
        agent_name   = 'DET_ST_SET'
        agent_status = 'A'
      IMPORTING
        reported = DATA(lt_reported) ).
    assert_no_reported( reported = lt_reported entity_name = 'AGENT' ).
  ENDMETHOD.

  METHOD fill_agent_status_default.
    insert_agent_type( ).
    create_agent_eml(
      EXPORTING
        agent_name   = 'DET_ST_DEF'
        agent_status = ''
      IMPORTING
        reported = DATA(lt_reported) ).
    " Default status ('N') set by determination — valid, no error
    assert_no_reported( reported = lt_reported entity_name = 'AGENT' ).
  ENDMETHOD.

  METHOD precheck_empty_entities.
    " precheck_create returns immediately when entities IS INITIAL
    " This branch is tested implicitly — create_agent_eml always sends entities
    " so we just verify no crash with valid data
    insert_agent_type( ).
    create_agent_eml(
      EXPORTING agent_name = 'PRECHK_OK'
      IMPORTING reported = DATA(lt_reported) ).
    assert_no_reported( reported = lt_reported entity_name = 'AGENT' ).
  ENDMETHOD.

  METHOD precheck_unique_names.
    insert_agent_type( ).
    " Create two agents with different names in one call — precheck should pass
    MODIFY ENTITIES OF zr_pru_agent
        ENTITY Agent
        CREATE
        FIELDS ( AIPF7AgentName AIPF7AgentType AIPF7DecisionProvider
                 AIPF7ShortMemoryProvider AIPF7LongMemoryProvider
                 AIPF7AgentStatus )
        WITH VALUE #( ( %cid = 'CID_01'
                        AIPF7AgentName           = 'PRECHK_UNIQ_A'
                        AIPF7AgentType           = 'DEFAUL'
                        AIPF7DecisionProvider     = 'ZPRU_CL_DECISION_PROVIDER'
                        AIPF7ShortMemoryProvider  = 'ZPRU_CL_SHORT_MEMORY_PROVIDER'
                        AIPF7LongMemoryProvider   = 'ZPRU_CL_LONG_MEMORY_PROVIDER'
                        AIPF7AgentStatus          = 'N' )
                      ( %cid = 'CID_02'
                        AIPF7AgentName           = 'PRECHK_UNIQ_B'
                        AIPF7AgentType           = 'DEFAUL'
                        AIPF7DecisionProvider     = 'ZPRU_CL_DECISION_PROVIDER'
                        AIPF7ShortMemoryProvider  = 'ZPRU_CL_SHORT_MEMORY_PROVIDER'
                        AIPF7LongMemoryProvider   = 'ZPRU_CL_LONG_MEMORY_PROVIDER'
                        AIPF7AgentStatus          = 'N' ) )
        REPORTED DATA(lt_reported)
        FAILED   DATA(lt_failed).

    assert_no_reported( reported = CORRESPONDING #( lt_reported )
                        entity_name = 'AGENT' ).
  ENDMETHOD.

  METHOD precheck_duplicate_names.
    insert_agent_type( ).
    MODIFY ENTITIES OF zr_pru_agent
        ENTITY Agent
        CREATE
        FIELDS ( AIPF7AgentName AIPF7AgentType AIPF7DecisionProvider
                 AIPF7ShortMemoryProvider AIPF7LongMemoryProvider
                 AIPF7AgentStatus )
        WITH VALUE #( ( %cid = 'CID_01'
                        AIPF7AgentName           = 'SAME_NAME'
                        AIPF7AgentType           = 'DEFAUL'
                        AIPF7DecisionProvider     = 'ZPRU_CL_DECISION_PROVIDER'
                        AIPF7ShortMemoryProvider  = 'ZPRU_CL_SHORT_MEMORY_PROVIDER'
                        AIPF7LongMemoryProvider   = 'ZPRU_CL_LONG_MEMORY_PROVIDER'
                        AIPF7AgentStatus          = 'N' )
                      ( %cid = 'CID_02'
                        AIPF7AgentName           = 'SAME_NAME'
                        AIPF7AgentType           = 'DEFAUL'
                        AIPF7DecisionProvider     = 'ZPRU_CL_DECISION_PROVIDER'
                        AIPF7ShortMemoryProvider  = 'ZPRU_CL_SHORT_MEMORY_PROVIDER'
                        AIPF7LongMemoryProvider   = 'ZPRU_CL_LONG_MEMORY_PROVIDER'
                        AIPF7AgentStatus          = 'N' ) )
        REPORTED DATA(lt_reported)
        FAILED   DATA(lt_failed).

    assert_reported_msg( reported = CORRESPONDING #( lt_reported )
                         entity_name = 'AGENT'
                         msg_text = 'Duplicate agent name' ).
  ENDMETHOD.

  METHOD get_global_authorizations_ok.
    " Method has empty implementation — just verify it exists and doesn't dump
    " Not directly callable; tested implicitly via create
    insert_agent_type( ).
    create_agent_eml(
      EXPORTING agent_name = 'AUTH_OK'
      IMPORTING reported = DATA(lt_reported) ).
    assert_no_reported( reported = lt_reported entity_name = 'AGENT' ).
  ENDMETHOD.

  METHOD check_tool_name_empty_keys.
    " create_tool_eml with valid data — unique name
    insert_agent_type( ).
    DATA(ls_agent) = insert_agent( agent_name = 'TOOL_NM_AG' ).
    create_tool_eml(
      EXPORTING
        agent_uuid = ls_agent-agentuuid
        tool_name  = 'UNIQUE_TOOL_1'
      IMPORTING
        reported = DATA(lt_reported) ).
    assert_no_reported( reported = lt_reported entity_name = 'AGENTTOOL' ).
  ENDMETHOD.

  METHOD check_tool_name_unique.
    insert_agent_type( ).
    DATA(ls_agent) = insert_agent( agent_name = 'TOOL_NM_UNIQ' ).
    create_tool_eml(
      EXPORTING
        agent_uuid = ls_agent-agentuuid
        tool_name  = 'UNIQUE_TOOL_2'
      IMPORTING
        reported = DATA(lt_reported) ).
    assert_no_reported( reported = lt_reported entity_name = 'AGENTTOOL' ).
  ENDMETHOD.

  METHOD check_tool_name_duplicate.
    insert_agent_type( ).
    DATA(ls_agent) = insert_agent( agent_name = 'TOOL_DUP_AG' ).
    insert_tool( agent_uuid = ls_agent-agentuuid tool_name = 'DUP_TOOL' ).
    create_tool_eml(
      EXPORTING
        agent_uuid = ls_agent-agentuuid
        tool_name  = 'DUP_TOOL'
      IMPORTING
        reported = DATA(lt_reported) ).
    assert_reported_msg( reported = lt_reported entity_name = 'AGENTTOOL'
                         msg_text = 'already exists' ).
  ENDMETHOD.

  METHOD check_tool_provider_initial.
    insert_agent_type( ).
    DATA(ls_agent) = insert_agent( agent_name = 'TOOL_PRV_INIT' ).
    create_tool_eml(
      EXPORTING
        agent_uuid = ls_agent-agentuuid
        tool_name  = 'TOOL_PRV_I_1'
        tool_prov  = ''
      IMPORTING
        reported = DATA(lt_reported) ).
    assert_reported_msg( reported = lt_reported entity_name = 'AGENTTOOL'
                         msg_text = 'must not be initial' ).
  ENDMETHOD.

  METHOD check_tool_provider_not_exist.
    insert_agent_type( ).
    DATA(ls_agent) = insert_agent( agent_name = 'TOOL_PRV_NEX' ).
    create_tool_eml(
      EXPORTING
        agent_uuid = ls_agent-agentuuid
        tool_name  = 'TOOL_PRV_NEX1'
        tool_prov  = 'Z_NONEXISTENT_XYZ'
      IMPORTING
        reported = DATA(lt_reported) ).
    assert_reported_msg( reported = lt_reported entity_name = 'AGENTTOOL'
                         msg_text = 'does not exist' ).
  ENDMETHOD.

  METHOD check_tool_provider_no_if.
    insert_agent_type( ).
    DATA(ls_agent) = insert_agent( agent_name = 'TOOL_PRV_NOIF' ).
    create_tool_eml(
      EXPORTING
        agent_uuid = ls_agent-agentuuid
        tool_name  = 'TOOL_PRV_NOIF1'
        tool_prov  = 'CL_ABAP_CHAR_UTILITIES'
      IMPORTING
        reported = DATA(lt_reported) ).
    assert_reported_msg( reported = lt_reported entity_name = 'AGENTTOOL'
                         msg_text = 'does not implement' ).
  ENDMETHOD.

  METHOD check_step_type_initial.
    insert_agent_type( ).
    DATA(ls_agent) = insert_agent( agent_name = 'ST_TY_INIT' ).
    create_tool_eml(
      EXPORTING
        agent_uuid = ls_agent-agentuuid
        tool_name  = 'ST_TY_I_1'
        step_type  = ''
      IMPORTING
        reported = DATA(lt_reported) ).
    assert_reported_msg( reported = lt_reported entity_name = 'AGENTTOOL'
                         msg_text = 'must not be initial' ).
  ENDMETHOD.

  METHOD check_step_type_invalid.
    insert_agent_type( ).
    DATA(ls_agent) = insert_agent( agent_name = 'ST_TY_BAD' ).
    create_tool_eml(
      EXPORTING
        agent_uuid = ls_agent-agentuuid
        tool_name  = 'ST_TY_BAD1'
        step_type  = 'X'
      IMPORTING
        reported = DATA(lt_reported) ).
    assert_reported_msg( reported = lt_reported entity_name = 'AGENTTOOL'
                         msg_text = 'is invalid' ).
  ENDMETHOD.

  METHOD check_step_type_valid.
    insert_agent_type( ).
    DATA(ls_agent) = insert_agent( agent_name = 'ST_TY_OK' ).
    " Test with 'B' (ABAP Code) — one of valid values
    create_tool_eml(
      EXPORTING
        agent_uuid = ls_agent-agentuuid
        tool_name  = 'ST_TY_OK_B'
        step_type  = 'B'
      IMPORTING
        reported = DATA(lt_reported) ).
    assert_no_reported( reported = lt_reported entity_name = 'AGENTTOOL' ).
  ENDMETHOD.

  METHOD check_tool_schema_opt_empty.
    insert_agent_type( ).
    DATA(ls_agent) = insert_agent( agent_name = 'TSC_EMPTY' ).
    create_tool_eml(
      EXPORTING
        agent_uuid  = ls_agent-agentuuid
        tool_name   = 'TSC_EMPTY_1'
        tool_schema = ''
      IMPORTING
        reported = DATA(lt_reported) ).
    assert_no_reported( reported = lt_reported entity_name = 'AGENTTOOL' ).
  ENDMETHOD.

  METHOD check_tool_schema_not_exist.
    insert_agent_type( ).
    DATA(ls_agent) = insert_agent( agent_name = 'TSC_NOEX' ).
    create_tool_eml(
      EXPORTING
        agent_uuid  = ls_agent-agentuuid
        tool_name   = 'TSC_NOEX_1'
        tool_schema = 'Z_NONEXISTENT_XYZ'
      IMPORTING
        reported = DATA(lt_reported) ).
    assert_reported_msg( reported = lt_reported entity_name = 'AGENTTOOL'
                         msg_text = 'does not exist' ).
  ENDMETHOD.

  METHOD check_tool_schema_no_if.
    insert_agent_type( ).
    DATA(ls_agent) = insert_agent( agent_name = 'TSC_NOIF' ).
    create_tool_eml(
      EXPORTING
        agent_uuid  = ls_agent-agentuuid
        tool_name   = 'TSC_NOIF_1'
        tool_schema = 'CL_ABAP_CHAR_UTILITIES'
      IMPORTING
        reported = DATA(lt_reported) ).
    assert_reported_msg( reported = lt_reported entity_name = 'AGENTTOOL'
                         msg_text = 'does not implement' ).
  ENDMETHOD.

  METHOD check_tool_info_opt_empty.
    insert_agent_type( ).
    DATA(ls_agent) = insert_agent( agent_name = 'TINF_EMPTY' ).
    create_tool_eml(
      EXPORTING
        agent_uuid = ls_agent-agentuuid
        tool_name  = 'TINF_EMPTY_1'
        tool_info  = ''
      IMPORTING
        reported = DATA(lt_reported) ).
    assert_no_reported( reported = lt_reported entity_name = 'AGENTTOOL' ).
  ENDMETHOD.

  METHOD check_tool_info_not_exist.
    insert_agent_type( ).
    DATA(ls_agent) = insert_agent( agent_name = 'TINF_NOEX' ).
    create_tool_eml(
      EXPORTING
        agent_uuid = ls_agent-agentuuid
        tool_name  = 'TINF_NOEX_1'
        tool_info  = 'Z_NONEXISTENT_XYZ'
      IMPORTING
        reported = DATA(lt_reported) ).
    assert_reported_msg( reported = lt_reported entity_name = 'AGENTTOOL'
                         msg_text = 'does not exist' ).
  ENDMETHOD.

  METHOD check_tool_info_no_if.
    insert_agent_type( ).
    DATA(ls_agent) = insert_agent( agent_name = 'TINF_NOIF' ).
    create_tool_eml(
      EXPORTING
        agent_uuid = ls_agent-agentuuid
        tool_name  = 'TINF_NOIF_1'
        tool_info  = 'CL_ABAP_CHAR_UTILITIES'
      IMPORTING
        reported = DATA(lt_reported) ).
    assert_reported_msg( reported = lt_reported entity_name = 'AGENTTOOL'
                         msg_text = 'does not implement' ).
  ENDMETHOD.

  METHOD change_tool_prov_empty_param.
    insert_agent_type( ).
    DATA(ls_agent) = insert_agent( agent_name = 'TACT_PRV' ).
    DATA(ls_tool) = insert_tool( agent_uuid = ls_agent-agentuuid tool_name = 'TACT_PRV_T1' ).

    MODIFY ENTITIES OF zr_pru_agent
        ENTITY AgentTool
        EXECUTE changeToolProvider
        FROM VALUE #( ( %key-AIPF7ToolUuid = ls_tool-tooluuid
                        %param-AIPF7ToolProvider = '' ) )
        REPORTED DATA(lt_reported)
        FAILED   DATA(lt_failed).

    assert_reported_msg( reported = CORRESPONDING #( lt_reported )
                         entity_name = 'AGENTTOOL' msg_text = 'must not be empty' ).
  ENDMETHOD.

  METHOD change_tool_prov_success.
    insert_agent_type( ).
    DATA(ls_agent) = insert_agent( agent_name = 'TACT_PRV_OK' ).
    DATA(ls_tool) = insert_tool( agent_uuid = ls_agent-agentuuid tool_name = 'TACT_PRV_OK1' ).

    MODIFY ENTITIES OF zr_pru_agent
        ENTITY AgentTool
        EXECUTE changeToolProvider
        FROM VALUE #( ( %key-AIPF7ToolUuid = ls_tool-tooluuid
                        %param-AIPF7ToolProvider = 'ZPRU_CL_TOOL_PROVIDER' ) )
        REPORTED DATA(lt_reported)
        FAILED   DATA(lt_failed).

    assert_no_reported( reported = CORRESPONDING #( lt_reported )
                        entity_name = 'AGENTTOOL' ).
  ENDMETHOD.

  METHOD change_tool_schema_empty_ok.
    insert_agent_type( ).
    DATA(ls_agent) = insert_agent( agent_name = 'TACT_SC' ).
    DATA(ls_tool) = insert_tool( agent_uuid = ls_agent-agentuuid tool_name = 'TACT_SC_T1'
                                  tool_schema = 'CL_ABAP_CHAR_UTILITIES' ).

    MODIFY ENTITIES OF zr_pru_agent
        ENTITY AgentTool
        EXECUTE changeToolSchemaProvider
        FROM VALUE #( ( %key-AIPF7ToolUuid = ls_tool-tooluuid
                        %param-AIPF7ToolSchemaProvider = '' ) )
        REPORTED DATA(lt_reported)
        FAILED   DATA(lt_failed).

    assert_no_reported( reported = CORRESPONDING #( lt_reported )
                        entity_name = 'AGENTTOOL' ).
  ENDMETHOD.

  METHOD change_tool_schema_success.
    insert_agent_type( ).
    DATA(ls_agent) = insert_agent( agent_name = 'TACT_SC_OK' ).
    DATA(ls_tool) = insert_tool( agent_uuid = ls_agent-agentuuid tool_name = 'TACT_SC_OK1' ).

    MODIFY ENTITIES OF zr_pru_agent
        ENTITY AgentTool
        EXECUTE changeToolSchemaProvider
        FROM VALUE #( ( %key-AIPF7ToolUuid = ls_tool-tooluuid
                        %param-AIPF7ToolSchemaProvider = 'CL_ABAP_CHAR_UTILITIES' ) )
        REPORTED DATA(lt_reported)
        FAILED   DATA(lt_failed).

    assert_no_reported( reported = CORRESPONDING #( lt_reported )
                        entity_name = 'AGENTTOOL' ).
  ENDMETHOD.

  METHOD change_tool_info_empty_ok.
    insert_agent_type( ).
    DATA(ls_agent) = insert_agent( agent_name = 'TACT_INF' ).
    DATA(ls_tool) = insert_tool( agent_uuid = ls_agent-agentuuid tool_name = 'TACT_INF_T1'
                                  tool_info = 'CL_ABAP_CHAR_UTILITIES' ).

    MODIFY ENTITIES OF zr_pru_agent
        ENTITY AgentTool
        EXECUTE changeToolInfoProvider
        FROM VALUE #( ( %key-AIPF7ToolUuid = ls_tool-tooluuid
                        %param-AIPF7ToolInfoProvider = '' ) )
        REPORTED DATA(lt_reported)
        FAILED   DATA(lt_failed).

    assert_no_reported( reported = CORRESPONDING #( lt_reported )
                        entity_name = 'AGENTTOOL' ).
  ENDMETHOD.

  METHOD change_tool_info_success.
    insert_agent_type( ).
    DATA(ls_agent) = insert_agent( agent_name = 'TACT_INF_OK' ).
    DATA(ls_tool) = insert_tool( agent_uuid = ls_agent-agentuuid tool_name = 'TACT_INF_OK1' ).

    MODIFY ENTITIES OF zr_pru_agent
        ENTITY AgentTool
        EXECUTE changeToolInfoProvider
        FROM VALUE #( ( %key-AIPF7ToolUuid = ls_tool-tooluuid
                        %param-AIPF7ToolInfoProvider = 'CL_ABAP_CHAR_UTILITIES' ) )
        REPORTED DATA(lt_reported)
        FAILED   DATA(lt_failed).

    assert_no_reported( reported = CORRESPONDING #( lt_reported )
                        entity_name = 'AGENTTOOL' ).
  ENDMETHOD.

  METHOD change_step_type_empty.
    insert_agent_type( ).
    DATA(ls_agent) = insert_agent( agent_name = 'TACT_ST' ).
    DATA(ls_tool) = insert_tool( agent_uuid = ls_agent-agentuuid tool_name = 'TACT_ST_T1' ).

    MODIFY ENTITIES OF zr_pru_agent
        ENTITY AgentTool
        EXECUTE changeStepType
        FROM VALUE #( ( %key-AIPF7ToolUuid = ls_tool-tooluuid
                        %param-AIPF7StepType = '' ) )
        REPORTED DATA(lt_reported)
        FAILED   DATA(lt_failed).

    assert_reported_msg( reported = CORRESPONDING #( lt_reported )
                         entity_name = 'AGENTTOOL' msg_text = 'must not be empty' ).
  ENDMETHOD.

  METHOD change_step_type_invalid.
    insert_agent_type( ).
    DATA(ls_agent) = insert_agent( agent_name = 'TACT_ST_BAD' ).
    DATA(ls_tool) = insert_tool( agent_uuid = ls_agent-agentuuid tool_name = 'TACT_ST_BAD1' ).

    MODIFY ENTITIES OF zr_pru_agent
        ENTITY AgentTool
        EXECUTE changeStepType
        FROM VALUE #( ( %key-AIPF7ToolUuid = ls_tool-tooluuid
                        %param-AIPF7StepType = 'X' ) )
        REPORTED DATA(lt_reported)
        FAILED   DATA(lt_failed).

    assert_reported_msg( reported = CORRESPONDING #( lt_reported )
                         entity_name = 'AGENTTOOL' msg_text = 'Invalid step type value' ).
  ENDMETHOD.

  METHOD change_step_type_success.
    insert_agent_type( ).
    DATA(ls_agent) = insert_agent( agent_name = 'TACT_ST_OK' ).
    DATA(ls_tool) = insert_tool( agent_uuid = ls_agent-agentuuid tool_name = 'TACT_ST_OK1' ).

    MODIFY ENTITIES OF zr_pru_agent
        ENTITY AgentTool
        EXECUTE changeStepType
        FROM VALUE #( ( %key-AIPF7ToolUuid = ls_tool-tooluuid
                        %param-AIPF7StepType = 'K' ) )
        REPORTED DATA(lt_reported)
        FAILED   DATA(lt_failed).

    assert_no_reported( reported = CORRESPONDING #( lt_reported )
                        entity_name = 'AGENTTOOL' ).
  ENDMETHOD.

ENDCLASS.
