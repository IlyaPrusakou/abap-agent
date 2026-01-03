CLASS zpru_todo_list DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS todo.
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

*1 do we need user defined tool when we have simple abap code
*2 add configuration for strategy( additional table and field in step definition )
*possible values
*RETRY_LIMIT INT1        INT1    3   Max Retries for Handler
*REQ_USER_APP    ABAP_BOOL       CHAR    1   Pause for User Approval
*COMMIT_REQ  ABAP_BOOL       CHAR    1   Trigger COMMIT WORK
*IS_IDEMPOTENT   ABAP_BOOL       CHAR    1   Safe for Auto-Retry
*TERM_ON_FAIL    ABAP_BOOL       CHAR    1   Terminate Process on Error

*3 make framework system prompt
*4 again recheck what formats to use json or string
*5 finish with dynamic invokation

  ENDMETHOD.

ENDCLASS.
