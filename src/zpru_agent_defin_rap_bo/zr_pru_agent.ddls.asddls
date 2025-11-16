@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZPRU_AGENT'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_PRU_AGENT
  as select from zpru_agent 
  composition of exact one to many  ZR_PRU_AGENT_TOOL as _tool  
{
  key agent_uuid             as AgentUUID,
      agent_name             as AgentName,
      decision_provider      as DecisionProvider,
      short_memory_provider  as ShortMemoryProvider,
      long_memory_provider   as LongMemoryProvider,
      agent_info_provider    as AgentInfoProvider,
      system_prompt_provider as SystemPromptProvider,
      status                 as Status,
      created_by             as CreatedBy,
      created_at             as CreatedAt,
      changed_by             as ChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed           as LastChanged,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed     as LocalLastChanged,
      _tool
}
