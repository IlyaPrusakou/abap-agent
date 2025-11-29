@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Agent Execution Query'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZR_PRU_AXC_QUERY
  as select from zpru_axc_query
  association              to parent ZR_PRU_AXC_HEAD as _executionheader on $projection.RunUuid = _executionheader.RunUUID
  composition of exact one to many ZR_PRU_AXC_STEP   as _executionstep
{
  key query_uuid       as QueryUuid,
      run_uuid         as RunUuid,
      language         as Language,
      execution_status as ExecutionStatus,
      start_timestamp  as StartTimestamp,
      end_timestamp    as EndTimestamp,
      input_prompt     as InputPrompt,
      output_response  as OutputResponse,
      _executionheader,
      _executionstep
}
