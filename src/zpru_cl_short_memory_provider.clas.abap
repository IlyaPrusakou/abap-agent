CLASS zpru_cl_short_memory_provider DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zpru_if_agent_frw .
    INTERFACES zpru_if_short_memory_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zpru_cl_short_memory_provider IMPLEMENTATION.


  METHOD zpru_if_short_memory_provider~clear_history.
  ENDMETHOD.


  METHOD zpru_if_short_memory_provider~get_history.
  ENDMETHOD.


  METHOD zpru_if_short_memory_provider~save_message.
  ENDMETHOD.
ENDCLASS.
