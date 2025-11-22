CLASS zpru_cl_adf_database_access DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zpru_if_adf_database_access.
ENDCLASS.


CLASS zpru_cl_adf_database_access IMPLEMENTATION.
  METHOD zpru_if_adf_database_access~delete_agent.
    ev_error = abap_false.

    DELETE zpru_agent FROM TABLE @it_agent.
    IF sy-subrc <> 0.
      ev_error = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD zpru_if_adf_database_access~delete_agent_tool.
    ev_error = abap_false.

    DELETE zpru_agent_tool FROM TABLE @it_agent_tool.
    IF sy-subrc <> 0.
      ev_error = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD zpru_if_adf_database_access~modify_agent.
    ev_error = abap_false.

    IF it_agent IS INITIAL.
      RETURN.
    ENDIF.

    MODIFY zpru_agent FROM TABLE @it_agent.
    IF sy-subrc <> 0.
      ev_error = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD zpru_if_adf_database_access~modify_agent_tool.
    ev_error = abap_false.

    IF it_agent_tool IS INITIAL.
      RETURN.
    ENDIF.

    MODIFY zpru_agent_tool FROM TABLE @it_agent_tool.
    IF sy-subrc <> 0.
      ev_error = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD zpru_if_adf_database_access~select_agent.
    IF it_agent_k IS INITIAL.
      RETURN.
    ENDIF.

    SELECT * FROM zpru_agent
      FOR ALL ENTRIES IN @it_agent_k
      WHERE agent_uuid = @it_agent_k-agent_uuid
      INTO TABLE @rt_agent.
  ENDMETHOD.

  METHOD zpru_if_adf_database_access~select_agent_tool.
    IF it_agent_tool_k IS INITIAL.
      RETURN.
    ENDIF.

    SELECT * FROM zpru_agent_tool
      FOR ALL ENTRIES IN @it_agent_tool_k
      WHERE tool_uuid = @it_agent_tool_k-tool_uuid
      INTO TABLE @rt_agent_tool.
  ENDMETHOD.

  METHOD zpru_if_adf_database_access~query_agent.
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
      SELECT agent_uuid, tool_uuid  FROM zpru_agent_tool
        FOR ALL ENTRIES IN @et_agent_k
        WHERE agent_uuid = @et_agent_k-agent_uuid
        INTO TABLE @et_tool_agent_link.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
