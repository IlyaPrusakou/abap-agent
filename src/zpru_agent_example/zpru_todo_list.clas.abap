CLASS zpru_todo_list DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  METHODS TODO.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zpru_todo_list IMPLEMENTATION.
  METHOD todo.
*21.12.2025
*1 ADD MESSAGED TO API -DONE
*2 IMPLEMENT METHOD ADD_QUERY_2_RUN IN API CLASS - done
*3 ADD ADDITIONAL FIELDS TO AGENT AND RUN TABLES - done
*4 EXPAND MESSAGES IN API WITH NEW FIELDS - DONE
*5 ADD VALIDATION INTO SERVICE CLASSES FOR AGENT AND RUN
*6 CHECK SAVE LOGIN IN SERVICE CLASSES FOR AGENT AND RUN

*23.12.2025
*1 add fields and logic to generate run_id, query_number, step_number to api - done
*2 save final response as query output - done
*3 adjust messages with new fields - DONE
*4 add field agent_type to agent node and customizing table with values and configs for agent type
*5 add strategy for summarize and long memory process
*6 save data as xstring in db ?????

*27.12.2025
*1 WHAT DO WITH ATTRIBUTES IN API CLASS???
*2 what do with error flags in long memory save methods and in io_long_memory->save_summary - fixed
*3 add possibility to provide configuration outside of agent definition
*4 add paralel save flag and logic in long memory save methods - refused

  ENDMETHOD.

ENDCLASS.
