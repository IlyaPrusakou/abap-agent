INTERFACE zpru_if_agent_frw
  PUBLIC.

  TYPES: BEGIN OF ENUM es_execution_status BASE TYPE char1,
           new       VALUE IS INITIAL,
           running   VALUE `R`,
           completed VALUE `C`,
         END OF ENUM es_execution_status.

  TYPES ts_json       TYPE string.
  TYPES tt_agent_tool TYPE STANDARD TABLE OF zpru_agent_tool WITH EMPTY KEY.

ENDINTERFACE.
