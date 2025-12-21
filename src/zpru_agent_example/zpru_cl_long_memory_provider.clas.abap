CLASS zpru_cl_long_memory_provider DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zpru_if_agent_frw .
    INTERFACES zpru_if_long_memory_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zpru_cl_long_memory_provider IMPLEMENTATION.




  METHOD zpru_if_long_memory_provider~summarize_conversation.
  ENDMETHOD.
  METHOD zpru_if_long_memory_provider~get_msg_persistence.

  ENDMETHOD.

  METHOD zpru_if_long_memory_provider~get_sum_persistence.

  ENDMETHOD.

  METHOD zpru_if_long_memory_provider~retrieve_message.

  ENDMETHOD.

  METHOD zpru_if_long_memory_provider~retrieve_summary.

  ENDMETHOD.

  METHOD zpru_if_long_memory_provider~save_messages.

  ENDMETHOD.

  METHOD zpru_if_long_memory_provider~save_summary.

  ENDMETHOD.

  METHOD zpru_if_long_memory_provider~set_msg_persistence.

  ENDMETHOD.

  METHOD zpru_if_long_memory_provider~set_sum_persistence.

  ENDMETHOD.

ENDCLASS.
