INTERFACE zpru_if_agent_frw
  PUBLIC.

  CONSTANTS: BEGIN OF  cs_execution_status,
               new       VALUE SPACE,
               running   VALUE `R`,
               completed VALUE `C`,
             END OF cs_execution_status.

  TYPES ts_json       TYPE string.
  TYPES tt_agent_tool TYPE STANDARD TABLE OF zpru_agent_tool WITH EMPTY KEY.

ENDINTERFACE.
