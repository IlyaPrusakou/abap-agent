CLASS zpru_cl_dynamic_abap_base DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zpru_if_dynamic_abap_processor .
    INTERFACES zpru_if_tool_executor .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zpru_cl_dynamic_abap_base IMPLEMENTATION.


  METHOD zpru_if_dynamic_abap_processor~process_dynamic_abap.

*      DATA lo_object     TYPE REF TO object.

*  DATA(lv_class_name) = 'ZPRU_CL_DYNAMIC_CALL'.
*    DATA(lv_class_meth) = 'SERIALIZE'.
*
*    DATA: lt_params TYPE abap_parmbind_tab,
*          ls_param  TYPE abap_parmbind,
*          lv_json   TYPE /ui2/cl_json=>json.


*data lo_class type ref to zpru_if_agent_controller.
*
*  lo_class = new zpru_cl_agent_controller( ).
*
*    ls_param-name = 'IO_CLASS'.
*    ls_param-kind = cl_abap_objectdescr=>exporting.
*    ls_param-value = REF #( lo_class ).
*    INSERT ls_param INTO TABLE lt_params.
*

*    " 1. The DATA parameter (The ABAP structure/table to serialize)
*    ls_param-name = 'DATA'.
*    ls_param-kind = cl_abap_objectdescr=>exporting.
*    ls_param-value = REF #( 1 ).
*    INSERT ls_param INTO TABLE lt_params.
*
*    " 2. COMPRESS (Boolean)
*    ls_param-name = 'COMPRESS'.
*    ls_param-kind = cl_abap_objectdescr=>exporting.
*    ls_param-value = REF #( abap_true ).
*    INSERT ls_param INTO TABLE lt_params.
*
*    " 3. PRETTY_NAME (Enum/Mode)
*    DATA(lv_pretty) = /ui2/cl_json=>pretty_mode-camel_case.
*    ls_param-name = 'PRETTY_NAME'.
*    ls_param-kind = cl_abap_objectdescr=>exporting.
*    ls_param-value = REF #( lv_pretty ).
*    INSERT ls_param INTO TABLE lt_params.
*
*    " 4. RETURNING parameter (r_json)
*    ls_param-name = 'R_JSON'.
*    ls_param-kind = cl_abap_objectdescr=>returning.
*    ls_param-value = REF #( lv_json ).
*    INSERT ls_param INTO TABLE lt_params.
*
*    CREATE OBJECT lo_object TYPE (lv_class_name).
*
*    CALL METHOD lo_object->(lv_class_meth)
*      PARAMETER-TABLE lt_params.
  ENDMETHOD.
ENDCLASS.
