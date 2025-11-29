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

ENDCLASS.
