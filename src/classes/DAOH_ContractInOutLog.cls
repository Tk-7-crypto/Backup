/**
 * This is ContractInOut trigger handler class.
 * version : 1.0
 */
public class DAOH_ContractInOutLog {
    
    /**
    * This method is used to update Contract In/Out Log fields
    * @params  newList List<Contract_In_Out_Log__c>
    * @params oldMap Map<id, Contract_In_Out_Log__c>
    * @return  void
    */
    public static void setContractInOutLogFields(List<Contract_In_Out_Log__c> newList, Map<Id, Contract_In_Out_Log__c> oldMap) {
        for(Contract_In_Out_Log__c inOutLog : newList) {
            // FEATURE-3828
            if(Trigger.isInsert || inOutLog.LQ_Mulesoft_Sync_Status__c == oldMap.get(inOutLog.Id).LQ_Mulesoft_Sync_Status__c || (inOutLog.LQ_Mulesoft_Sync_Status__c != oldMap.get(inOutLog.Id).LQ_Mulesoft_Sync_Status__c 
                                    && (inOutLog.LQ_Mulesoft_Sync_Status__c != CON_CRM.MULESOFT_SYNC_STATUS_COMPLETED &&  inOutLog.LQ_Mulesoft_Sync_Status__c != CON_CRM.MULESOFT_SYNC_STATUS_FAILED))) {
                inOutLog.LQ_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_PENDING;
            }
        }
    }
    
    /**
     * This method is used to update Outbound Message Deletion Queue
     * @params  List<Contract_In_Out_Log__c> deleteList
     * @return  void
     */
    public static void createOutboundMessageDeletionQueue(List<Contract_In_Out_Log__c> deleteList) {
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Outbound_Message_Deletion_queue__c.SobjectType
            }
        );
        Outbound_Message_Deletion_queue__c outBound;
        Boolean toCommit = false;
        for(Contract_In_Out_Log__c contInOutLog : deleteList) {
            outBound = new Outbound_Message_Deletion_queue__c();
            outBound.Operation__c = CON_CRM.DELETE_LABEL;
            if(contInOutLog.LQ_Contract_In_Out_Log_Id__c != null) {
                outBound.LQ_Id__c = contInOutLog.LQ_Contract_In_Out_Log_Id__c;
            }
            outBound.SObjectType__c = CON_CRM.CONTRACT_IN_OUT_LOG_OBJECT_API;
            outBound.RecordID__c = contInOutLog.Id;
            uow.registerNew(outBound);
            toCommit = true;
        }
        
        if(toCommit) {
            uow.commitWork();
        }
    }
}