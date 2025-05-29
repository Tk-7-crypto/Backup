/**
 * This is ContractLifecycle trigger handler class.
 * version : 1.0
 */
public class DAOH_ContractLifecycle {
    
    /**
    * This method is used to update Contract Lifecycle fields
    * @params  newList List<Contract_Lifecycle__c>
    * @params oldMap Map<id, Contract_Lifecycle__c>
    * @return  void
    */
    public static void setContractLifecycleFields(List<Contract_Lifecycle__c> newList, Map<Id, Contract_Lifecycle__c> oldMap) {
        for(Contract_Lifecycle__c lifeCycle : newList) {
            // FEATURE-3828
            if(Trigger.isInsert || lifeCycle.LQ_Mulesoft_Sync_Status__c == oldMap.get(lifeCycle.Id).LQ_Mulesoft_Sync_Status__c || (lifeCycle.LQ_Mulesoft_Sync_Status__c != oldMap.get(lifeCycle.Id).LQ_Mulesoft_Sync_Status__c 
                                    && (lifeCycle.LQ_Mulesoft_Sync_Status__c != CON_CRM.MULESOFT_SYNC_STATUS_COMPLETED &&  lifeCycle.LQ_Mulesoft_Sync_Status__c != CON_CRM.MULESOFT_SYNC_STATUS_FAILED))) {
                lifeCycle.LQ_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_PENDING;
            }
        }
    }
    
    /**
     * This method is used to update Outbound Message Deletion Queue
     * @params  List<Contract_Lifecycle__c> deleteList
     * @return  void
     */
    public static void createOutboundMessageDeletionQueue(List<Contract_Lifecycle__c> deleteList) {
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Outbound_Message_Deletion_queue__c.SobjectType
            }
        );
        Outbound_Message_Deletion_queue__c outBound;
        Boolean toCommit = false;
        for(Contract_Lifecycle__c contLifecycle : deleteList) {
            outBound = new Outbound_Message_Deletion_queue__c();
            outBound.Operation__c = CON_CRM.DELETE_LABEL;
            if(contLifecycle.LQ_Contract_Lifecycle_ID__c != null) {
                outBound.LQ_Id__c = contLifecycle.LQ_Contract_Lifecycle_ID__c;
            }
            outBound.SObjectType__c = CON_CRM.CONTRACT_LIFECYCLE_OBJECT_API;
            outBound.RecordID__c = contLifecycle.Id;
            uow.registerNew(outBound);
            toCommit = true;
        }
        
        if(toCommit) {
            uow.commitWork();
        }
    }
}