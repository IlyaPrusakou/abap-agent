CLASS zpru_cl_agent_util DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zpru_if_agent_util .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zpru_cl_agent_util IMPLEMENTATION.

  METHOD zpru_if_agent_util~copy_data_to_ref.
    FIELD-SYMBOLS: <ls_data> TYPE any.

    CREATE DATA cr_data LIKE is_data.
    ASSIGN cr_data->* TO <ls_data>.
    <ls_data> = is_data.
  ENDMETHOD.
ENDCLASS.
