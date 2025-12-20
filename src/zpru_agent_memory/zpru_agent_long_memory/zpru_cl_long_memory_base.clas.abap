CLASS zpru_cl_long_memory_base DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zpru_if_agent_frw .
    INTERFACES zpru_if_long_memory_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zpru_cl_long_memory_base IMPLEMENTATION.


  METHOD zpru_if_long_memory_provider~retrieve_insights.
  ENDMETHOD.


  METHOD zpru_if_long_memory_provider~retrieve_message.
  ENDMETHOD.


  METHOD zpru_if_long_memory_provider~save_insights.
  ENDMETHOD.


  METHOD zpru_if_long_memory_provider~save_messages.
  ENDMETHOD.


  METHOD zpru_if_long_memory_provider~summarize_conversation.
  ENDMETHOD.
ENDCLASS.
