INTERFACE zpru_if_adf_database_access
  PUBLIC.

  TYPES: BEGIN OF ts_agent_k,
           agent_uuid TYPE sysuuid_x16,
         END OF ts_agent_k.

  TYPES: BEGIN OF ts_agent_tool_k,
           tool_uuid TYPE sysuuid_x16,
         END OF ts_agent_tool_k.

  TYPES tt_agent_k                TYPE STANDARD TABLE OF ts_agent_k WITH EMPTY KEY.
  TYPES tt_agent_tool_k           TYPE STANDARD TABLE OF ts_agent_tool_k WITH EMPTY KEY.
  TYPES tt_agent                  TYPE STANDARD TABLE OF zpru_agent WITH EMPTY KEY.
  TYPES tt_agent_tool             TYPE STANDARD TABLE OF zpru_agent_tool WITH EMPTY KEY.

  METHODS modify_agent
    IMPORTING it_agent TYPE tt_agent
    EXPORTING ev_error TYPE abap_boolean.

  METHODS delete_agent
    IMPORTING it_agent TYPE tt_agent
    EXPORTING ev_error TYPE abap_boolean.

  METHODS select_agent
    IMPORTING it_agent_k      TYPE tt_agent_k
    RETURNING VALUE(rt_agent) TYPE tt_agent.

  METHODS modify_agent_tool
    IMPORTING it_agent_tool TYPE tt_agent_tool
    EXPORTING ev_error      TYPE abap_boolean.

  METHODS delete_agent_tool
    IMPORTING it_agent_tool TYPE tt_agent_tool
    EXPORTING ev_error      TYPE abap_boolean.

  METHODS select_agent_tool
    IMPORTING it_agent_tool_k      TYPE tt_agent_tool_k
    RETURNING VALUE(rt_agent_tool) TYPE tt_agent_tool.

ENDINTERFACE.
