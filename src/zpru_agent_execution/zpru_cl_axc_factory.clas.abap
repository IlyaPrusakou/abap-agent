CLASS zpru_cl_axc_factory DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zpru_if_axc_factory.
ENDCLASS.

CLASS zpru_cl_axc_factory IMPLEMENTATION.
  METHOD zpru_if_axc_factory~get_zpru_if_axc_service.
    ro_obj = NEW zpru_cl_axc_service( ).
  ENDMETHOD.

  METHOD zpru_if_axc_factory~get_zpru_if_axc_precheck.
    ro_obj = NEW zpru_cl_axc_precheck( ).
  ENDMETHOD.

ENDCLASS.
