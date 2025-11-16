@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Agent Execution Step'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZR_PRU_AXC_STEP
  as select from zpru_axc_step
  association         to parent ZR_PRU_AXC_QUERY   as _executionquery  on $projection.QueryUuid = _executionquery.QueryUuid
  association of many to exact one ZR_PRU_AXC_HEAD as _executionheader on $projection.RunUuid = _executionheader.RunUUID
{
  key step_uuid       as StepUuid,
      query_uuid      as QueryUuid,
      run_uuid        as RunUuid,
      tool_uuid       as ToolUuid,
      execution_seq   as ExecutionSeq,
      start_timestamp as StartTimestamp,
      end_timestamp   as EndTimestamp,
      input_prompt    as InputPrompt,
      output_prompt   as OutputPrompt,
      _executionquery,
      _executionheader
}
