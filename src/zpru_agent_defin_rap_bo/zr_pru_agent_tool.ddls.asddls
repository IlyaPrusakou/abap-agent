@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Agent Tool'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZR_PRU_AGENT_TOOL
  as select from zpru_agent_tool
  association to parent ZR_PRU_AGENT as _agent on $projection.AgentUuid = _agent.AgentUUID
{
  key tool_uuid             as ToolUuid,
      agent_uuid            as AgentUuid,
      tool_name             as ToolName,
      tool_provider         as ToolProvider,
      step_type             as StepType,
      input_schema_provider as InputSchemaProvider,
      tool_info_provider    as ToolInfoProvider,
      _agent 
}
