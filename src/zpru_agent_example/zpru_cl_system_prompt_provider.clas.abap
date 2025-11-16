CLASS zpru_cl_system_prompt_provider DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zpru_if_agent_frw .
    INTERFACES zpru_if_prompt_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zpru_cl_system_prompt_provider IMPLEMENTATION.


  METHOD zpru_if_prompt_provider~get_prompt_language.
  ENDMETHOD.


  METHOD zpru_if_prompt_provider~get_system_prompt.
  ENDMETHOD.
ENDCLASS.
