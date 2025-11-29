CLASS zpru_cl_adf_service DEFINITION
  PUBLIC FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.
    INTERFACES zpru_if_adf_service.

    CLASS-METHODS get_instance
      RETURNING VALUE(ro_instance) TYPE REF TO zpru_if_adf_service.

  PRIVATE SECTION.
    CLASS-DATA so_instance TYPE REF TO zpru_if_adf_service.

ENDCLASS.


CLASS zpru_cl_adf_service IMPLEMENTATION.
  METHOD get_instance.
    IF so_instance IS BOUND.
      ro_instance = so_instance.
      RETURN.
    ENDIF.

    so_instance = NEW zpru_cl_adf_service( ).
    ro_instance = so_instance.
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

  METHOD zpru_if_adf_service~read_agent.
    DATA lo_data_base_access TYPE REF TO zpru_if_adf_database_access.

    CLEAR: et_agent,
           et_agent_tool.

    lo_data_base_access = NEW zpru_cl_adf_database_access( ).

    et_agent = lo_data_base_access->select_agent( it_agent_k ).

    IF et_agent IS INITIAL.
      RETURN.
    ENDIF.

    IF et_agent_tool IS SUPPLIED.

      zpru_if_adf_service~query_agent( EXPORTING it_agent_name      = VALUE #( FOR <ls_a> IN et_agent
                                                                               ( sign   = `I`
                                                                                 option = `EQ`
                                                                                 low    = <ls_a>-agent_name ) )
                                       IMPORTING et_tool_agent_link = DATA(lt_tool_agent_link) ).

      et_agent_tool = lo_data_base_access->select_agent_tool(
                          it_agent_tool_k = VALUE #( FOR <ls_tl> IN lt_tool_agent_link
                                                     ( tool_uuid = <ls_tl>-tool_uuid ) ) ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
