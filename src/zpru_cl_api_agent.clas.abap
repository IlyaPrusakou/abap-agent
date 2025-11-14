CLASS zpru_cl_api_agent DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zpru_if_agent_frw .
    INTERFACES zpru_if_api_agent .
  PROTECTED SECTION.
    DATA ms_agent TYPE zpru_agent.
    DATA ms_agent_prompt TYPE zpru_agent_prmpt.
    DATA mt_agent_tools TYPE STANDARD TABLE OF zpru_agent_tool WITH EMPTY KEY.
    DATA mv_input_query TYPE zpru_if_agent_frw=>ts_json.

  PRIVATE SECTION.
ENDCLASS.



CLASS zpru_cl_api_agent IMPLEMENTATION.


  METHOD zpru_if_api_agent~build_execution_plan.
  ENDMETHOD.


  METHOD zpru_if_api_agent~initialize.

    SELECT * FROM zpru_agent
    WHERE agent_name = @iv_agent_name
    INTO TABLE @DATA(lt_agent).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    ms_agent = VALUE #( lt_agent[ 1 ] OPTIONAL ).

    IF ms_agent IS INITIAL.
      RETURN.
    ENDIF.

    SELECT * FROM zpru_agent_prmpt
    WHERE agent_uuid = @ms_agent-agent_uuid AND
          spras      = @sy-langu
    INTO @ms_agent_prompt UP TO 1 ROWS.
    ENDSELECT.

*  SELECT * FROM ZPRU_AGENT_TOOL INTO mt_agent_tools

  ENDMETHOD.


  METHOD zpru_if_api_agent~rerun_execution.
  ENDMETHOD.


  METHOD zpru_if_api_agent~rerun_from_step.
  ENDMETHOD.


  METHOD zpru_if_api_agent~run.

    DATA: lo_decision_provider TYPE REF TO zpru_if_decision_provider.
    CREATE OBJECT lo_decision_provider TYPE (ms_agent-decision_provider).

*      lo_decision_provider->make_decision(
*        EXPORTING
*          iv_input  = mv_input_query
*        IMPORTING
*          ev_output = DATA(lv_output) ).




  ENDMETHOD.


  METHOD zpru_if_api_agent~set_input_query.
    mv_input_query = iv_input_query.
  ENDMETHOD.
ENDCLASS.
