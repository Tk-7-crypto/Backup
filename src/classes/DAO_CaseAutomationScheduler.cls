public class DAO_CaseAutomationScheduler extends fflib_SObjectDomain {

    public DAO_CaseAutomationScheduler(List<CSM_QI_CaseAutomationScheduler__c> sObjectList) {
        super(sObjectList);
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_CaseAutomationScheduler(sObjectList);
        }
    }
    
    public override void onBeforeInsert() {
        DAOH_CaseAutomationScheduler.setPrimaryAndSecondaryCurrentQueue((List<CSM_QI_CaseAutomationScheduler__c>)Records);
        DAOH_CaseAutomationScheduler.setNextRunDateOnRecord((List<CSM_QI_CaseAutomationScheduler__c>)Records, null);
    }
    
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        DAOH_CaseAutomationScheduler.setPrimaryAndSecondaryCurrentQueue((List<CSM_QI_CaseAutomationScheduler__c>)Records);
        DAOH_CaseAutomationScheduler.setNextRunDateOnRecord((List<CSM_QI_CaseAutomationScheduler__c>)Records, (Map<Id, CSM_QI_CaseAutomationScheduler__c>)existingRecords);
    }
}