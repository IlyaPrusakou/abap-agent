@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Agent Tool'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZC_PRU_AGENT_TOOL
  as projection on ZR_PRU_AGENT_TOOL
{
  key ToolUuid,
      AgentUuid,
      ToolName,
      ToolProvider,
      StepType,
      InputSchemaProvider,
      ToolInfoProvider,
      /* Associations */
      _agent : redirected to parent ZC_PRU_AGENT
}
