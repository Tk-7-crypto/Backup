public class DAOH_ContractStageDetail {
    
    /**
    * This method is used to update contract Life Cycle Record.
    * @params  newList List<Contract_Stage_Detail__c>
    * @params oldMap Map<id, Contract_Stage_Detail__c>
    * @return  void
    */
    public static void updateContractLifeCycleRecord(List<Contract_Stage_Detail__c> newList, Map<Id, Contract_Stage_Detail__c> oldMap) {
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Contract_Lifecycle__c.SobjectType,
                Contract_Stage_Detail__c.SobjectType
            }
        );
        Contract_Lifecycle__c contractLifeCycle = new Contract_Lifecycle__c();
        for(Contract_Stage_Detail__c contractStageDetail : newList) {
            contractLifeCycle = new Contract_Lifecycle__c(id = contractStageDetail.Contract_Lifecycle__c);
            contractLifeCycle.Most_Recent_Actual_Contract_Value__c = contractStageDetail.Actual_Contract_Value__c;
            contractLifeCycle.Most_Recent_Execution_Plan_Start_Date__c = contractStageDetail.Execution_Plan_Start_Date__c;
            contractLifeCycle.Most_Recent_Planned_Execution_Date__c = contractStageDetail.Planned_Execution_Date__c;
            contractLifeCycle.Most_Recent_Project_Expenses_Value__c = contractStageDetail.Project_Expenses__c;
            contractLifeCycle.Most_Recent_Stage_Entry__c = contractStageDetail.CreatedDate.date();
            uow.registerDirty(contractLifeCycle);
        }
        uow.commitWork();
    }
    
    /**
    * This method is used to update Contract Stage Detail fields
    * @params  newList List<Contract_Stage_Detail__c>
    * @params oldMap Map<id, Contract_Stage_Detail__c>
    * @return  void
    */
    public static void setContractStageDetailFields(List<Contract_Stage_Detail__c> newList, Map<Id, Contract_Stage_Detail__c> oldMap) {
        for(Contract_Stage_Detail__c stageDatail : newList) {
            // FEATURE-3828
            if(Trigger.isInsert || stageDatail.LQ_Mulesoft_Sync_Status__c == oldMap.get(stageDatail.Id).LQ_Mulesoft_Sync_Status__c || (stageDatail.LQ_Mulesoft_Sync_Status__c != oldMap.get(stageDatail.Id).LQ_Mulesoft_Sync_Status__c 
                                    && (stageDatail.LQ_Mulesoft_Sync_Status__c != CON_CRM.MULESOFT_SYNC_STATUS_COMPLETED &&  stageDatail.LQ_Mulesoft_Sync_Status__c != CON_CRM.MULESOFT_SYNC_STATUS_FAILED))) {
                stageDatail.LQ_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_PENDING;
            }
        }
    }
    
    /**
    * This method is used to update Outbound Message Deletion Queue
    * @params  List<Contract_Stage_Detail__c> deleteList
    * @return  void
    */
    public static void createOutboundMessageDeletionQueue(List<Contract_Stage_Detail__c> deleteList) {
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Outbound_Message_Deletion_queue__c.SobjectType
            }
        );
        Outbound_Message_Deletion_queue__c outBound;
        Boolean toCommit = false;
        for(Contract_Stage_Detail__c contStageDetail : deleteList) {
            outBound = new Outbound_Message_Deletion_queue__c();
            outBound.Operation__c = CON_CRM.DELETE_LABEL;
            if(contStageDetail.LQ_Contract_Stage_Detail_ID__c != null) {
                outBound.LQ_Id__c = contStageDetail.LQ_Contract_Stage_Detail_ID__c;
            }
            outBound.SObjectType__c = CON_CRM.CONTRACT_STAGE_DETAIL_OBJECT_API;
            outBound.RecordID__c = contStageDetail.Id;
            uow.registerNew(outBound);
            toCommit = true;
        }
        
        if(toCommit) {
            uow.commitWork();
        }
    }
}