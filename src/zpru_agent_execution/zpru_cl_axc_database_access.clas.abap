CLASS zpru_cl_axc_database_access DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zpru_if_axc_database_access.
ENDCLASS.


CLASS zpru_cl_axc_database_access IMPLEMENTATION.
  METHOD zpru_if_axc_database_access~delete_head.
    ev_error = abap_false.

    DELETE zpru_axc_head FROM TABLE @it_axc_head.
    IF sy-subrc <> 0.
      ev_error = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD zpru_if_axc_database_access~delete_query.
    ev_error = abap_false.

    DELETE zpru_axc_query FROM TABLE @it_axc_query.
    IF sy-subrc <> 0.
      ev_error = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD zpru_if_axc_database_access~delete_step.
    ev_error = abap_false.

    DELETE zpru_axc_step FROM TABLE @it_axc_step.
    IF sy-subrc <> 0.
      ev_error = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD zpru_if_axc_database_access~modify_head.
    ev_error = abap_false.

    IF it_axc_head IS INITIAL.
      RETURN.
    ENDIF.

    MODIFY zpru_axc_head FROM TABLE @it_axc_head.
    IF sy-subrc <> 0.
      ev_error = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD zpru_if_axc_database_access~modify_query.
    ev_error = abap_false.

    IF it_axc_query IS INITIAL.
      RETURN.
    ENDIF.

    MODIFY zpru_axc_query FROM TABLE @it_axc_query.
    IF sy-subrc <> 0.
      ev_error = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD zpru_if_axc_database_access~modify_step.
    ev_error = abap_false.

    IF it_axc_step IS INITIAL.
      RETURN.
    ENDIF.

    MODIFY zpru_axc_step FROM TABLE @it_axc_step.
    IF sy-subrc <> 0.
      ev_error = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD zpru_if_axc_database_access~select_head.

    IF it_axc_head_k IS INITIAL.
      RETURN.
    ENDIF.

    SELECT * FROM zpru_axc_head
      FOR ALL ENTRIES IN @it_axc_head_k
      WHERE run_uuid = @it_axc_head_k-run_uuid
      INTO TABLE @rt_axc_head.
  ENDMETHOD.

  METHOD zpru_if_axc_database_access~select_query.
    DATA lr_query TYPE RANGE OF sysuuid_x16.

    IF it_axc_query_k IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_axc_query_k ASSIGNING FIELD-SYMBOL(<ls_axc_query>).
      APPEND INITIAL LINE TO lr_query ASSIGNING FIELD-SYMBOL(<ls_query>).
      <ls_query>-sign   = `I`.
      <ls_query>-option = `EQ`.
      <ls_query>-low    = <ls_axc_query>-query_uuid.
    ENDLOOP.

    SELECT * FROM zpru_axc_query
      WHERE query_uuid IN @lr_query
      INTO TABLE @rt_axc_query.
  ENDMETHOD.

  METHOD zpru_if_axc_database_access~select_step.
    DATA lr_step TYPE RANGE OF sysuuid_x16.

    IF it_axc_step_k IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_axc_step_k ASSIGNING FIELD-SYMBOL(<ls_axc_step>).
      APPEND INITIAL LINE TO lr_step ASSIGNING FIELD-SYMBOL(<ls_step>).
      <ls_step>-sign   = `I`.
      <ls_step>-option = `EQ`.
      <ls_step>-low    = <ls_axc_step>-step_uuid.
    ENDLOOP.

    SELECT * FROM zpru_axc_step
      WHERE step_uuid IN @lr_step
      INTO TABLE @rt_axc_step.
  ENDMETHOD.
ENDCLASS.
