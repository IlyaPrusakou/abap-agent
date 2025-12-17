INTERFACE zpru_if_adf_factory
  PUBLIC .

  CLASS-METHODS get_zpru_if_adf_service
    RETURNING VALUE(ro_obj) TYPE REF TO zpru_if_adf_service.

  CLASS-METHODS get_zpru_if_adf_precheck
    RETURNING VALUE(ro_obj) TYPE REF TO zpru_if_adf_precheck.

ENDINTERFACE.
