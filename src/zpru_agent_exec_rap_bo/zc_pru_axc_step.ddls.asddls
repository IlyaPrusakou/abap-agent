@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Agent Execution Step'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_PRU_AXC_STEP
  as projection on ZR_PRU_AXC_STEP
{
  key StepUuid,
      QueryUuid,
      RunUuid,
      ToolUuid,
      ExecutionSeq,
      StartTimestamp,
      EndTimestamp,
      InputPrompt,
      OutputPrompt,
      /* Associations */
      _executionheader : redirected to ZC_PRU_AXC_HEAD,
      _executionquery  : redirected to parent ZC_PRU_AXC_QUERY
}
