INTERFACE zpru_if_agent_message
  PUBLIC.

  INTERFACES if_message.
  INTERFACES if_t100_dyn_msg.
  INTERFACES if_t100_message.

  TYPES t_char01 TYPE c LENGTH 1.
  CONSTANTS:
    BEGIN OF sc_severity,
      none        TYPE c LENGTH 1 VALUE IS INITIAL,
      error       TYPE t_char01   VALUE 'E',
      warning     TYPE t_char01   VALUE 'W',
      information TYPE t_char01   VALUE 'I',
      success     TYPE t_char01   VALUE 'S',
    END OF sc_severity.

  DATA m_severity TYPE t_char01.

ENDINTERFACE.
