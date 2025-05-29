trigger TGR_CRM_Reassigned on Reassign__e (after insert) {
    for(Reassign__e reassign: Trigger.new){
        List<ProcessInstanceWorkitem> piwi = [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId,ActorId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId =: reassign.recordId__c];
        if(reassign.Reassign_Approver__c!=null){
            piwi[0].ActorId = reassign.Reassign_Approver__c;
            update piwi;
        }
    }
}