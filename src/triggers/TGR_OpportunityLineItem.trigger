/**
 * This trigger is used for opportunityLineItem object.
 * version : 1.0
 */
trigger TGR_OpportunityLineItem on OpportunityLineItem (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    if(!UTL_ExecutionControl.stopTriggerExecution)
        fflib_SObjectDomain.triggerHandler(DAO_OpportunityLineItem.class);
    if(Trigger.IsAfter && Trigger.IsInsert )
    DAOH_OpportunityLineItem.upsertIqviaLiZquiMappingObject(Trigger.new,Trigger.newMap,null); 
    if(Trigger.IsAfter && Trigger.IsUpdate )
    DAOH_OpportunityLineItem.upsertIqviaLiZquiMappingObject(Trigger.new,Trigger.newMap,Trigger.oldMap); 
}