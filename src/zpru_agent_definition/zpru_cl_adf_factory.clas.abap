CLASS zpru_cl_adf_factory DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zpru_if_adf_factory .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zpru_cl_adf_factory IMPLEMENTATION.

  METHOD zpru_if_adf_factory~get_zpru_if_adf_service.
    ro_obj = NEW zpru_cl_adf_service( ).
  ENDMETHOD.

  METHOD zpru_if_adf_factory~get_zpru_if_adf_precheck.
    ro_obj = NEW zpru_cl_adf_precheck( ).
  ENDMETHOD.

  METHOD zpru_if_adf_factory~get_zpru_if_adf_db_access.
    ro_obj = NEW zpru_cl_adf_database_access( ).
  ENDMETHOD.

ENDCLASS.
