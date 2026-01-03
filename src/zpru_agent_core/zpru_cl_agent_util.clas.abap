CLASS zpru_cl_agent_util DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zpru_if_agent_util.
ENDCLASS.


CLASS zpru_cl_agent_util IMPLEMENTATION.
  METHOD zpru_if_agent_util~copy_data_to_ref.
    FIELD-SYMBOLS <ls_data> TYPE any.

    CREATE DATA cr_data LIKE is_data.
    ASSIGN cr_data->* TO <ls_data>.
    <ls_data> = is_data.
  ENDMETHOD.

  METHOD zpru_if_agent_util~new_message.
    ro_obj = NEW zpru_cl_agent_message(
                     textid = VALUE #( msgid = iv_id
                                       msgno = iv_number
                                       attr1 = COND #( WHEN iv_v1 IS NOT INITIAL THEN 'IF_T100_DYN_MSG~MSGV1' )
                                       attr2 = COND #( WHEN iv_v2 IS NOT INITIAL THEN 'IF_T100_DYN_MSG~MSGV2' )
                                       attr3 = COND #( WHEN iv_v3 IS NOT INITIAL THEN 'IF_T100_DYN_MSG~MSGV3' )
                                       attr4 = COND #( WHEN iv_v4 IS NOT INITIAL THEN 'IF_T100_DYN_MSG~MSGV4' ) )
                     msgty  = SWITCH #( iv_severity
                                        WHEN zpru_cl_agent_message=>zpru_if_agent_message~sc_severity-error THEN
                                          'E'
                                        WHEN zpru_cl_agent_message=>zpru_if_agent_message~sc_severity-warning THEN
                                          'W'
                                        WHEN zpru_cl_agent_message=>zpru_if_agent_message~sc_severity-information THEN
                                          'I'
                                        WHEN zpru_cl_agent_message=>zpru_if_agent_message~sc_severity-success THEN
                                          'S' )
                     msgv1  = |{ iv_v1 }|
                     msgv2  = |{ iv_v2 }|
                     msgv3  = |{ iv_v3 }|
                     msgv4  = |{ iv_v4 }| ).

    ro_obj->m_severity = iv_severity.
  ENDMETHOD.

  METHOD zpru_if_agent_util~fill_flags.
    DATA lo_abap_struct  TYPE REF TO cl_abap_structdescr.
    DATA lv_flags_filled TYPE abap_boolean.
    DATA lv_processed    TYPE abap_boolean.

    lo_abap_struct ?= cl_abap_typedescr=>describe_by_name( p_name = iv_name ).

    DATA(lt_symbols) = lo_abap_struct->get_symbols( ).

    IF lt_symbols IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT lt_symbols ASSIGNING FIELD-SYMBOL(<ls_symbol>).

      ASSIGN COMPONENT <ls_symbol>-name OF STRUCTURE cs_control TO FIELD-SYMBOL(<lv_control_field>).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      IF <lv_control_field> = abap_true.
        lv_flags_filled = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF lv_flags_filled = abap_true.
      RETURN.
    ENDIF.

    LOOP AT lt_symbols ASSIGNING <ls_symbol>.

      ASSIGN COMPONENT <ls_symbol>-name OF STRUCTURE cs_data TO FIELD-SYMBOL(<lv_data_field>).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      IF <lv_data_field> IS NOT INITIAL.
        ASSIGN COMPONENT <ls_symbol>-name OF STRUCTURE cs_control TO <lv_control_field>.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.
        <lv_control_field> = abap_true.
        IF lv_processed = abap_false.
          lv_processed = abap_true.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF lv_processed = abap_false.
      RAISE SHORTDUMP NEW zpru_cx_agent_core( ).
    ENDIF.
  ENDMETHOD.

  METHOD zpru_if_agent_util~deserialize_xstring_2_json.
    TRY.
        rv_json = cl_abap_conv_codepage=>create_in( )->convert( iv_xstring ).
      CATCH cx_parameter_invalid_range
            cx_sy_conversion_codepage.
        RETURN.
    ENDTRY.
  ENDMETHOD.

  METHOD zpru_if_agent_util~serialize_json_2_xstring.
    TRY.
        rv_xstring = cl_abap_conv_codepage=>create_out( )->convert( iv_json ).
      CATCH cx_parameter_invalid_range
            cx_sy_conversion_codepage.
        RETURN.
    ENDTRY.
  ENDMETHOD.

  METHOD zpru_if_agent_util~convert_to_abap.
    /ui2/cl_json=>deserialize( EXPORTING json          = ir_string->*
                                         hex_as_base64 = abap_false
                               CHANGING  data          = cr_abap ).
  ENDMETHOD.

  METHOD zpru_if_agent_util~convert_to_string.
    cr_string = /ui2/cl_json=>serialize( data          = ir_abap->*
                                         hex_as_base64 = abap_false ).
  ENDMETHOD.

  METHOD zpru_if_agent_util~search_node_in_json.
    DATA lv_node_found TYPE abap_boolean.

    IF    iv_json           IS INITIAL
       OR iv_field_2_search IS INITIAL.
      RETURN.
    ENDIF.

    TRY.
        DATA(lv_xml_to_parse) = cl_abap_conv_codepage=>create_out( )->convert( iv_json ).
      CATCH cx_sy_conversion_codepage.
        RETURN.
    ENDTRY.

    DATA(lo_reader) = cl_sxml_string_reader=>create( lv_xml_to_parse ).

    TRY.
        DO.

          lo_reader->next_node( ).
          IF lo_reader->node_type = if_sxml_node=>co_nt_final.
            EXIT.
          ENDIF.

          CASE lo_reader->node_type.
            WHEN if_sxml_node=>co_nt_element_open.

              DATA(lo_current_node) = lo_reader->read_current_node( ).

              DATA(lo_open_element) = CAST if_sxml_open_element( lo_current_node ).

              DATA(lt_attributes) = lo_open_element->get_attributes( ).

              LOOP AT lt_attributes ASSIGNING FIELD-SYMBOL(<ls_attribute>).
                IF     <ls_attribute>->qname-name   = 'name'
                   AND <ls_attribute>->value_type   = if_sxml_value=>co_vt_text
                   AND <ls_attribute>->get_value( ) = iv_field_2_search.
                  lv_node_found = abap_true.
                  EXIT.
                ENDIF.
              ENDLOOP.

              IF lv_node_found = abap_true.

                DATA(lo_writer) = cl_sxml_string_writer=>create( type = if_sxml=>co_xt_json ).

                TRY.
                    IF lo_reader->name = 'array' OR lo_reader->name = 'object'.
                      lo_reader->push_back( ).
                      lo_reader->skip_node( lo_writer ).
                      rv_value = cl_abap_conv_codepage=>create_in( )->convert( lo_writer->get_output( ) ).
                    ELSE.
                      lo_reader->next_node( ).
                      IF lo_reader->node_type = if_sxml_node=>co_nt_value.
                        DATA(lo_value_node) = CAST if_sxml_value_node( lo_reader->read_current_node( ) ).
                        IF lo_value_node->value_type = if_sxml_value=>co_vt_text.
                          rv_value = lo_value_node->get_value( ).
                        ENDIF.
                      ENDIF.
                    ENDIF.
                  CATCH cx_sxml_parse_error.
                    RETURN.
                ENDTRY.
                RETURN.
              ENDIF.
            WHEN if_sxml_node=>co_nt_element_close.
              CONTINUE.
            WHEN if_sxml_node=>co_nt_value.
              CONTINUE.
            WHEN OTHERS.
              CONTINUE.
          ENDCASE.
        ENDDO.
      CATCH cx_sxml_state_error
            cx_sxml_parse_error.
        RETURN.
    ENDTRY.
  ENDMETHOD.

  METHOD zpru_if_agent_util~snip_json.
    DATA lv_current_pos TYPE i VALUE 0.
    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA lv_input_len   TYPE i.

    lv_input_len = strlen( iv_json ).

    FIND ALL OCCURRENCES OF REGEX '[\{\[]' IN iv_json RESULTS DATA(lt_matches).

    LOOP AT lt_matches ASSIGNING FIELD-SYMBOL(<match>).
      IF <match>-offset < lv_current_pos.
        CONTINUE.
      ENDIF.

      DATA(lv_fragment) = substring( val = iv_json
                                     off = <match>-offset ).
      DATA(lo_reader)   = cl_sxml_string_reader=>create( cl_abap_conv_codepage=>create_out( )->convert( lv_fragment ) ).
      DATA(lo_writer)   = cl_sxml_string_writer=>create( type = if_sxml=>co_xt_json ).

      TRY.
          lo_reader->next_node( ).
          lo_reader->skip_node( lo_writer ).

          DATA(lv_json_string) = cl_abap_conv_codepage=>create_in( )->convert( lo_writer->get_output( ) ).
          APPEND VALUE #( content  = lv_json_string
                          is_valid = abap_false ) TO rt_fragments.
          lv_current_pos = <match>-offset + ( lo_reader->get_byte_offset( ) ).

        CATCH cx_sxml_parse_error.
          APPEND VALUE #( content  = lv_fragment
                          is_valid = abap_false ) TO rt_fragments.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
