CLASS zpru_cl_dummy_agent_logic DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

*    INTERFACES zpru_if_decision_provider.
*    INTERFACES zpru_if_short_memory_provider.
*    INTERFACES zpru_if_long_memory_provider.
*    INTERFACES zpru_if_agent_info_provider.
*    INTERFACES zpru_if_prompt_provider.

    METHODS get_local
      RETURNING VALUE(ro_loc) TYPE REF TO zpru_if_tool_executor.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zpru_cl_dummy_agent_logic IMPLEMENTATION.
  METHOD get_local.
    ro_loc = NEW lcl_local( ).
  ENDMETHOD.

ENDCLASS.
