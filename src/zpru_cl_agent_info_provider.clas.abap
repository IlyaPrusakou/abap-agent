CLASS zpru_cl_agent_info_provider DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zpru_if_agent_frw .
    INTERFACES zpru_if_agent_info_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zpru_cl_agent_info_provider IMPLEMENTATION.

  METHOD zpru_if_agent_info_provider~get_agent_info.
    rv_agent_info = |\{ "agent_info" : "My First Agent" \}|.
  ENDMETHOD.
ENDCLASS.
