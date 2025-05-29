/**
 * This is ContractMilestone trigger handler class.
 * version : 1.0
 */
public class DAOH_ContractMilestone {
    
    /**
     * in this method we updating contracts
     * @params  List<Contract_Milestone__c> newList
     * @return  void
     */
    public static void updateContracts(List<Contract_Milestone__c> newList) {
        List<Contract> contractsToUpdate = new List<Contract>();
        for(Contract_Milestone__c currentContractMilestone : newList ){
            if(currentContractMilestone.Contract_Number__c != null){
                contractsToUpdate.add(new Contract(Id=currentContractMilestone.Contract_Number__c, 
                                                   Current_Milestone__c=currentContractMilestone.Milestone_number__c));
            }
        }
        try{
            update contractsToUpdate;
        }catch(Exception e){
            System.debug('Failed due to : '+e);
        }
    }
    
    /**
     * in this method we updating Contract_Milestone__c
     * @params  List<Contract_Milestone__c> newList
     * @return  void
     */
    public static void updateContractMilestone(List<Contract_Milestone__c> newList) {
        Set<Id> contractMilestoneIds = new Set<Id>();
        Set<String> fieldSet = new Set<String>{'Id','Milestone_Total_Business_Days__c'};
        for(Integer i = 1; i <= 10; i++){
            fieldSet.add('V' + i + '_Total_Business_Days__c');
        }    
        for(Contract_Milestone__c currentContractMilestone : newList ){
            contractMilestoneIds.add(currentContractMilestone.Id);
        }
        List<Contract_Milestone__c> contractMilestoneNewList = new SLT_ContractMilestone().selectByIdFilter(contractMilestoneIds, fieldSet);
        List<Contract_Milestone__c> contractMilestonesToUpdate = new List<Contract_Milestone__c>();
        for(Contract_Milestone__c currentContractMilestone : contractMilestoneNewList ){
            Integer milestoneTotalBusinessDays = 0;
            for(Integer i = 1; i <= 10; i++){
                if(currentContractMilestone.get('V' + i + '_Total_Business_Days__c') != null){
                    milestoneTotalBusinessDays += Integer.valueOf(currentContractMilestone.get('V' + i + '_Total_Business_Days__c'));
                }
            }
            currentContractMilestone.Milestone_Total_Business_Days__c = milestoneTotalBusinessDays;
            contractMilestonesToUpdate.add(currentContractMilestone );
        }
        try{
            UTL_ExecutionControl.stopMilestoneTriggerExecution = true;
            update contractMilestonesToUpdate;
            UTL_ExecutionControl.stopMilestoneTriggerExecution = false;
        }catch(Exception e){
            Apex_Error_Log__c apexErrorLog = new Apex_Error_Log__c();
            apexErrorLog.Running_User__c = UserInfo.getUserId();
            apexErrorLog.Object__c = 'Contract_Milestone__c';
            apexErrorLog.Error_Message__c = e.getStackTraceString();
            insert apexErrorLog;
        }
    }
    
    /**
    * This method is used to update Contract Milestone fields
    * @params  newList List<Contract_Milestone__c>
    * @params oldMap Map<id, Contract_Milestone__c>
    * @return  void
    */
    public static void setContractMileStoneFields(List<Contract_Milestone__c> newList, Map<Id, Contract_Milestone__c> oldMap) {
        for(Contract_Milestone__c milestone : newList) {
            // FEATURE-3828
            if(Trigger.isInsert || milestone.LQ_Mulesoft_Sync_Status__c == oldMap.get(milestone.Id).LQ_Mulesoft_Sync_Status__c || (milestone.LQ_Mulesoft_Sync_Status__c != oldMap.get(milestone.Id).LQ_Mulesoft_Sync_Status__c 
                                    && (milestone.LQ_Mulesoft_Sync_Status__c != CON_CRM.MULESOFT_SYNC_STATUS_COMPLETED &&  milestone.LQ_Mulesoft_Sync_Status__c != CON_CRM.MULESOFT_SYNC_STATUS_FAILED))) {
                milestone.LQ_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_PENDING;
            }
        }
    }
    
    /**
     * This method is used to update Outbound Message Deletion Queue
     * @params  List<Contract_Milestone__c> deleteList
     * @return  void
     */
    public static void createOutboundMessageDeletionQueue(List<Contract_Milestone__c> deleteList) {
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Outbound_Message_Deletion_queue__c.SobjectType
            }
        );
        Outbound_Message_Deletion_queue__c outBound;
        Boolean toCommit = false;
        for(Contract_Milestone__c contMilestone : deleteList) {
            outBound = new Outbound_Message_Deletion_queue__c();
            outBound.Operation__c = CON_CRM.DELETE_LABEL;
            if(contMilestone.LQ_Contract_Milestone_id__c != null) {
                outBound.LQ_Id__c = contMilestone.LQ_Contract_Milestone_id__c;
            }
            outBound.SObjectType__c = CON_CRM.CONTRACT_MILESTONE_OBJECT_API;
            outBound.RecordID__c = contMilestone.Id;
            uow.registerNew(outBound);
            toCommit = true;
        }
        
        if(toCommit) {
            uow.commitWork();
        }
    }
}