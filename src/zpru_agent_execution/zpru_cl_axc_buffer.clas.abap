CLASS zpru_cl_axc_buffer DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ts_header,
             instance TYPE zpru_axc_head,
             changed  TYPE abap_bool,
             deleted  TYPE abap_bool,
           END OF ts_header.

    TYPES: BEGIN OF ts_query,
             instance TYPE zpru_axc_query,
             changed  TYPE abap_bool,
             deleted  TYPE abap_bool,
           END OF ts_query.

    TYPES: BEGIN OF ts_step,
             instance TYPE zpru_axc_step,
             changed  TYPE abap_bool,
             deleted  TYPE abap_bool,
           END OF ts_step.

    TYPES tt_header TYPE TABLE OF ts_header WITH EMPTY KEY.
    TYPES tt_query  TYPE TABLE OF ts_query WITH EMPTY KEY.
    TYPES tt_step   TYPE TABLE OF ts_step WITH EMPTY KEY.

    CLASS-DATA header_buffer TYPE tt_header.
    CLASS-DATA query_buffer  TYPE tt_query.
    CLASS-DATA step_buffer   TYPE tt_step.

    TYPES: BEGIN OF ts_header_keys,
             run_uuid TYPE zpru_axc_head-run_uuid,
           END OF ts_header_keys.

    TYPES: BEGIN OF ts_query_keys,
             run_uuid   TYPE zpru_axc_query-run_uuid,
             query_uuid TYPE zpru_axc_query-query_uuid,
             full_key   TYPE abap_bool,
           END OF ts_query_keys.

    TYPES: BEGIN OF ts_step_keys,
             query_uuid TYPE zpru_axc_step-query_uuid,
             step_uuid  TYPE zpru_axc_step-step_uuid,
             full_key   TYPE abap_bool,
           END OF ts_step_keys.

    TYPES tt_header_keys TYPE TABLE OF ts_header_keys WITH EMPTY KEY.
    TYPES tt_query_keys  TYPE TABLE OF ts_query_keys WITH EMPTY KEY.
    TYPES tt_step_keys   TYPE TABLE OF ts_step_keys WITH EMPTY KEY.

    CLASS-METHODS prep_header_buffer
      IMPORTING !keys TYPE tt_header_keys.

    CLASS-METHODS prep_query_buffer
      IMPORTING !keys TYPE tt_query_keys.

    CLASS-METHODS prep_step_buffer
      IMPORTING !keys TYPE tt_step_keys.

ENDCLASS.


CLASS zpru_cl_axc_buffer IMPLEMENTATION.
  METHOD prep_header_buffer.
    DATA ls_line TYPE zpru_axc_head.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).

      IF line_exists( zpru_cl_axc_buffer=>header_buffer[ instance-run_uuid = <ls_key>-run_uuid ] ).
        " do nothing
      ELSE.
        SELECT SINGLE @abap_true FROM zpru_axc_head
          WHERE run_uuid = @<ls_key>-run_uuid
          INTO @DATA(lv_exists).
        IF lv_exists = abap_true.
          SELECT SINGLE * FROM zpru_axc_head
            WHERE run_uuid = @<ls_key>-run_uuid
            INTO CORRESPONDING FIELDS OF @ls_line.
          IF sy-subrc = 0.
            APPEND VALUE #( instance = ls_line ) TO zpru_cl_axc_buffer=>header_buffer.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD prep_query_buffer.
    DATA lt_child_tab  TYPE TABLE OF zpru_axc_query WITH EMPTY KEY.
    DATA ls_child_line TYPE zpru_axc_query.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key_child>).
      IF <ls_key_child>-full_key = abap_true.
        IF line_exists( zpru_cl_axc_buffer=>query_buffer[ instance-run_uuid   = <ls_key_child>-run_uuid
                                                          instance-query_uuid = <ls_key_child>-query_uuid ] ).
          " do nothing
        ELSE.
          SELECT SINGLE @abap_true FROM zpru_axc_query
            WHERE run_uuid   = @<ls_key_child>-run_uuid
              AND query_uuid = @<ls_key_child>-query_uuid
            INTO @DATA(lv_exists).
          IF lv_exists = abap_true.
            SELECT SINGLE * FROM zpru_axc_query
              WHERE run_uuid   = @<ls_key_child>-run_uuid
                AND query_uuid = @<ls_key_child>-query_uuid
              INTO CORRESPONDING FIELDS OF @ls_child_line.
            IF sy-subrc = 0.
              APPEND VALUE #( instance = ls_child_line ) TO zpru_cl_axc_buffer=>query_buffer.
            ENDIF.
          ENDIF.
        ENDIF.

      ELSE.
        IF     line_exists( zpru_cl_axc_buffer=>header_buffer[ instance-run_uuid = <ls_key_child>-run_uuid ] )
           AND VALUE #( zpru_cl_axc_buffer=>header_buffer[ instance-run_uuid = <ls_key_child>-run_uuid ]-deleted OPTIONAL ) IS NOT INITIAL.
          " do nothing
        ELSE.
          SELECT SINGLE @abap_true FROM zpru_axc_query
            WHERE run_uuid = @<ls_key_child>-run_uuid
            INTO @DATA(lv_exists_ch).
          IF lv_exists_ch = abap_true.
            SELECT * FROM zpru_axc_query
              WHERE run_uuid = @<ls_key_child>-run_uuid
              INTO CORRESPONDING FIELDS OF TABLE @lt_child_tab.
            IF sy-subrc = 0.
              LOOP AT lt_child_tab ASSIGNING FIELD-SYMBOL(<ls_child>).
                IF NOT line_exists( zpru_cl_axc_buffer=>query_buffer[ instance-run_uuid   = <ls_child>-run_uuid
                                                                      instance-query_uuid = <ls_child>-query_uuid ] ).
                  APPEND VALUE #( instance = <ls_child> ) TO zpru_cl_axc_buffer=>query_buffer.
                ENDIF.
              ENDLOOP.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD prep_step_buffer.
    DATA lt_child_tab  TYPE TABLE OF zpru_axc_step WITH EMPTY KEY.
    DATA ls_child_line TYPE zpru_axc_step.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key_child>).
      IF <ls_key_child>-full_key = abap_true.
        IF line_exists( zpru_cl_axc_buffer=>step_buffer[ instance-query_uuid = <ls_key_child>-query_uuid
                                                         instance-step_uuid  = <ls_key_child>-step_uuid ] ).
          " do nothing
        ELSE.
          SELECT SINGLE @abap_true FROM zpru_axc_step
            WHERE query_uuid = @<ls_key_child>-query_uuid
              AND step_uuid  = @<ls_key_child>-step_uuid
            INTO @DATA(lv_exists).
          IF lv_exists = abap_true.
            SELECT SINGLE * FROM zpru_axc_step
              WHERE query_uuid = @<ls_key_child>-query_uuid
                AND step_uuid  = @<ls_key_child>-step_uuid
              INTO CORRESPONDING FIELDS OF @ls_child_line.
            IF sy-subrc = 0.
              APPEND VALUE #( instance = ls_child_line ) TO zpru_cl_axc_buffer=>step_buffer.
            ENDIF.
          ENDIF.
        ENDIF.

      ELSE.
        IF     line_exists( zpru_cl_axc_buffer=>query_buffer[ instance-query_uuid = <ls_key_child>-query_uuid ] )
           AND VALUE #( zpru_cl_axc_buffer=>query_buffer[ instance-query_uuid = <ls_key_child>-query_uuid ]-deleted OPTIONAL ) IS NOT INITIAL.
          " do nothing
        ELSE.
          SELECT SINGLE @abap_true FROM zpru_axc_step
            WHERE query_uuid = @<ls_key_child>-query_uuid
            INTO @DATA(lv_exists_ch).
          IF lv_exists_ch = abap_true.
            SELECT * FROM zpru_axc_step
              WHERE query_uuid = @<ls_key_child>-query_uuid
              INTO CORRESPONDING FIELDS OF TABLE @lt_child_tab.
            IF sy-subrc = 0.
              LOOP AT lt_child_tab ASSIGNING FIELD-SYMBOL(<ls_child>).
                IF NOT line_exists( zpru_cl_axc_buffer=>step_buffer[ instance-query_uuid = <ls_child>-query_uuid
                                                                     instance-step_uuid  = <ls_child>-step_uuid ] ).
                  APPEND VALUE #( instance = <ls_child> ) TO zpru_cl_axc_buffer=>step_buffer.
                ENDIF.
              ENDLOOP.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
