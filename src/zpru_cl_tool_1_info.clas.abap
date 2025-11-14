CLASS zpru_cl_tool_1_info DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zpru_if_agent_frw .
    INTERFACES zpru_if_tool_info_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zpru_cl_tool_1_info IMPLEMENTATION.


  METHOD zpru_if_tool_info_provider~get_tool_info.
  rv_tool_info = |\{ "tool_info" : "My First Tool" \}|.
  ENDMETHOD.
ENDCLASS.
