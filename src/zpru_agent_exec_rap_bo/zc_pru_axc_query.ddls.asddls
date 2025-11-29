@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Agent Execution Query'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_PRU_AXC_QUERY
  as projection on ZR_PRU_AXC_QUERY
{
  key QueryUuid,
      RunUuid,
      Language,
      ExecutionStatus,
      InputPrompt,
      OutputResponse,
      /* Associations */
      _executionheader : redirected to parent ZC_PRU_AXC_HEAD,
      _executionstep   : redirected to composition child ZC_PRU_AXC_STEP
}
