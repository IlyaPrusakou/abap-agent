CLASS zpru_cl_axc_service DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zpru_if_axc_service.
ENDCLASS.


CLASS zpru_cl_axc_service IMPLEMENTATION.
  METHOD zpru_if_axc_service~read_agent_execution.
    DATA lo_axc_database_access TYPE REF TO zpru_if_axc_database_access.

    CLEAR: et_axc_head,
           et_axc_query,
           et_axc_step.

    IF it_axc_head_k IS INITIAL.
      RETURN.
    ENDIF.

    lo_axc_database_access = NEW zpru_cl_axc_database_access( ).

    et_axc_head = lo_axc_database_access->select_head( it_axc_head_k ).

    IF et_axc_query IS SUPPLIED.
      et_axc_query = lo_axc_database_access->select_query_by_head( it_axc_head_k ).
    ENDIF.

    IF et_axc_step IS SUPPLIED.
      et_axc_step = lo_axc_database_access->select_step_by_query( VALUE #( FOR <ls_q_k> IN et_axc_query
                                                                           ( query_uuid = <ls_q_k>-query_uuid  ) ) ).
    ENDIF.
  ENDMETHOD.

  METHOD zpru_if_axc_service~get_actual_query.
    DATA lo_axc_database_access TYPE REF TO zpru_if_axc_database_access.

    IF it_axc_head_k IS INITIAL.
      RETURN.
    ENDIF.

    lo_axc_database_access = NEW zpru_cl_axc_database_access( ).
    DATA(lt_query_candidates) = lo_axc_database_access->select_query_by_head( it_axc_head_k ).

    LOOP AT it_axc_head_k ASSIGNING FIELD-SYMBOL(<ls_axc_head_k>).

      DATA(lt_query_copy) = lt_query_candidates.
      DELETE lt_query_copy WHERE run_uuid <> <ls_axc_head_k>-run_uuid.
      DELETE lt_query_copy WHERE execution_status <> zpru_if_agent_frw=>cs_execution_status-new.

      SORT lt_query_copy BY start_timestamp ASCENDING.

      APPEND INITIAL LINE TO rt_axc_head_query_link ASSIGNING FIELD-SYMBOL(<ls_axc_head_query_link>).
      <ls_axc_head_query_link>-run_uuid = <ls_axc_head_k>-run_uuid.
      <ls_axc_head_query_link>-query_uuid = VALUE #( lt_query_copy[ 1 ]-query_uuid OPTIONAL ).

    ENDLOOP.

  ENDMETHOD.

  METHOD zpru_if_axc_service~cba_query.

  ENDMETHOD.

  METHOD zpru_if_axc_service~delete.

  ENDMETHOD.

  METHOD zpru_if_axc_service~lock.

  ENDMETHOD.

  METHOD zpru_if_axc_service~rba_query.

  ENDMETHOD.

  METHOD zpru_if_axc_service~read.

  ENDMETHOD.

  METHOD zpru_if_axc_service~update.

  ENDMETHOD.

  METHOD zpru_if_axc_service~create.
*   " fetch data from buffer
*    lcl_buffer=>prep_root_buffer( CORRESPONDING #( entities MAPPING is_draft = %is_draft
*                                                                    purchaseorderid = purchaseorderid ) ).
*
*    LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_create>).
*
*      " check if entry does not exist or marked as deleted
*      IF    NOT line_exists( lcl_buffer=>root_buffer[ instance-purchaseorderid = <ls_create>-purchaseorderid
*                                                      is_draft                 = <ls_create>-%is_draft ] )
*         OR     line_exists( lcl_buffer=>root_buffer[ instance-purchaseorderid = <ls_create>-purchaseorderid
*                                                      is_draft                 = <ls_create>-%is_draft
*                                                      deleted                  = abap_true ] ).
*
*        " delete the one marked as deleted
*        DELETE lcl_buffer=>root_buffer WHERE     instance-purchaseorderid = VALUE #( lcl_buffer=>root_buffer[
*                                                                                         instance-purchaseorderid = <ls_create>-purchaseorderid
*                                                                                         is_draft                 = <ls_create>-%is_draft ]-instance-purchaseorderid OPTIONAL )
*                                             AND is_draft                 = <ls_create>-%is_draft
*                                             AND deleted                  = abap_true.
*
*        " add value to buffer considering %control structure
*        APPEND VALUE #(
*            cid                       = <ls_create>-%cid
*            is_draft                  = <ls_create>-%is_draft
*            instance-purchaseorderid  = <ls_create>-purchaseorderid
*            instance-orderdate        = COND #( WHEN <ls_create>-%control-orderdate <> if_abap_behv=>mk-off
*                                                THEN <ls_create>-orderdate )
*            instance-supplierid       = COND #( WHEN <ls_create>-%control-supplierid <> if_abap_behv=>mk-off
*                                                THEN <ls_create>-supplierid )
*            instance-suppliername     = COND #( WHEN <ls_create>-%control-suppliername <> if_abap_behv=>mk-off
*                                                THEN <ls_create>-suppliername )
*            instance-buyerid          = COND #( WHEN <ls_create>-%control-buyerid <> if_abap_behv=>mk-off
*                                                THEN <ls_create>-buyerid )
*            instance-buyername        = COND #( WHEN <ls_create>-%control-buyername <> if_abap_behv=>mk-off
*                                                THEN <ls_create>-buyername )
*            instance-totalamount      = COND #( WHEN <ls_create>-%control-totalamount <> if_abap_behv=>mk-off
*                                                THEN <ls_create>-totalamount )
*            instance-headercurrency   = COND #( WHEN <ls_create>-%control-headercurrency <> if_abap_behv=>mk-off
*                                                THEN <ls_create>-headercurrency )
*            instance-deliverydate     = COND #( WHEN <ls_create>-%control-deliverydate <> if_abap_behv=>mk-off
*                                                THEN <ls_create>-deliverydate )
*            instance-status           = COND #( WHEN <ls_create>-%control-status <> if_abap_behv=>mk-off
*                                                THEN <ls_create>-status )
*            instance-paymentterms     = COND #( WHEN <ls_create>-%control-paymentterms <> if_abap_behv=>mk-off
*                                                THEN <ls_create>-paymentterms )
*            instance-shippingmethod   = COND #( WHEN <ls_create>-%control-shippingmethod <> if_abap_behv=>mk-off
*                                                THEN <ls_create>-shippingmethod )
*            instance-controltimestamp = COND #( WHEN <ls_create>-%control-controltimestamp <> if_abap_behv=>mk-off
*                                                THEN <ls_create>-controltimestamp )
*            instance-origin           = COND #( WHEN <ls_create>-%control-origin <> if_abap_behv=>mk-off
*                                                THEN <ls_create>-origin )
*            instance-createdby        = COND #( WHEN <ls_create>-%control-createdby <> if_abap_behv=>mk-off
*                                                THEN <ls_create>-createdby )
*            instance-createon         = COND #( WHEN <ls_create>-%control-createon <> if_abap_behv=>mk-off
*                                                THEN <ls_create>-createon )
*            instance-changedby        = COND #( WHEN <ls_create>-%control-changedby <> if_abap_behv=>mk-off
*                                                THEN <ls_create>-changedby )
*            instance-changedon        = COND #( WHEN <ls_create>-%control-changedon <> if_abap_behv=>mk-off
*                                                THEN <ls_create>-changedon )
*            " qqq make sure that your made you admin fields managed by RAP framework
*            " it is expected that createOn already have been filled by time value
*            " otherwise check semantic annotation on your transactional CDS
*            instance-lastchanged      = <ls_create>-createon
*
*            newly_created             = abap_true " qqq to raise event on order creation I must distinct created and updated instances
*            " alternatively we can check db via select, but flag is likely be easier.
*
*            changed                   = abap_true
*            deleted                   = abap_false ) TO lcl_buffer=>root_buffer.
*
*        INSERT VALUE #( %cid      = <ls_create>-%cid
*                        %key      = <ls_create>-%key
*                        %is_draft = <ls_create>-%is_draft ) INTO TABLE mapped-ordertp.
*
*        APPEND VALUE #( %msg            = new_message_with_text( severity = if_abap_behv_message=>severity-success
*                                                                 text     = 'create: Ok!' )
*                        purchaseorderid = <ls_create>-purchaseorderid
*                        %cid            = <ls_create>-%cid
*                        %is_draft       = <ls_create>-%is_draft ) TO reported-ordertp.
*
*      ELSE.
*
*        APPEND VALUE #( %cid        = <ls_create>-%cid
*                        %key        = <ls_create>-%key
*                        %is_draft   = <ls_create>-%is_draft
*                        %create     = if_abap_behv=>mk-on
*                        %fail-cause = if_abap_behv=>cause-unspecific )
*               TO failed-ordertp.
*
*        APPEND VALUE #( %cid      = <ls_create>-%cid
*                        %key      = <ls_create>-%key
*                        %is_draft = <ls_create>-%is_draft
*                        %create   = if_abap_behv=>mk-on
*                        %msg      = new_message_with_text( severity = if_abap_behv_message=>severity-error
*                                                           text     = 'Create operation failed.' ) )
*               TO reported-ordertp.
*
*      ENDIF.
*    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
