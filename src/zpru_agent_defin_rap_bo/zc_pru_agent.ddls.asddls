@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: '###GENERATED Core Data Service Entity'
}
@ObjectModel: {
  sapObjectNodeType.name: 'ZPRU_AGENT'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZC_PRU_AGENT
  provider contract transactional_query
  as projection on ZR_PRU_AGENT
  association [1..1] to ZR_PRU_AGENT as _BaseEntity on $projection.AgentUUID = _BaseEntity.AgentUUID
{
  key AgentUUID,
  AgentName,
  DecisionProvider,
  ShortMemoryProvider,
  LongMemoryProvider,
  AgentInfoProvider,
  SystemPromptProvider,
  Status,
  CreatedBy,
  CreatedAt,
  ChangedBy,
  @Semantics: {
    systemDateTime.lastChangedAt: true
  }
  LastChanged,
  @Semantics: {
    systemDateTime.localInstanceLastChangedAt: true
  }
  LocalLastChanged,
  _tool : redirected to composition child ZC_PRU_AGENT_TOOL,
  _BaseEntity
}
