@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Agent Execution Query'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZC_PRU_AXC_QUERY
  as projection on ZR_PRU_AXC_QUERY
{
  key QueryUuid,
      RunUuid,
      Language,
      InputPrompt,
      OutputResponse,
      /* Associations */
      _executionheader : redirected to parent ZC_PRU_AXC_HEAD,
      _executionstep   : redirected to composition child ZC_PRU_AXC_STEP
}
