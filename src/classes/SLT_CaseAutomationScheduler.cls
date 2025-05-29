public class SLT_CaseAutomationScheduler extends fflib_SObjectSelector {

    public SLT_CaseAutomationScheduler() {
        super(false, true, false);
    }
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            CSM_QI_CaseAutomationScheduler__c.Id,
            CSM_QI_CaseAutomationScheduler__c.Name,
            CSM_QI_CaseAutomationScheduler__c.Account_Name__c,
            CSM_QI_CaseAutomationScheduler__c.Active__c,
            CSM_QI_CaseAutomationScheduler__c.Asset_Name__c,
            CSM_QI_CaseAutomationScheduler__c.Case_Categorization__c,
            CSM_QI_CaseAutomationScheduler__c.Creation_Date_In_Subject__c,
            CSM_QI_CaseAutomationScheduler__c.Description__c,
            CSM_QI_CaseAutomationScheduler__c.Device__c,
            CSM_QI_CaseAutomationScheduler__c.Frequency__c,
            CSM_QI_CaseAutomationScheduler__c.FrequencyId__c,
            CSM_QI_CaseAutomationScheduler__c.Impact__c,
            CSM_QI_CaseAutomationScheduler__c.Last_Run_Date__c,
            CSM_QI_CaseAutomationScheduler__c.Next_Run_Date__c,
            CSM_QI_CaseAutomationScheduler__c.No_Contact_Known__c,
            CSM_QI_CaseAutomationScheduler__c.Origin__c,
            CSM_QI_CaseAutomationScheduler__c.OwnerId,
            CSM_QI_CaseAutomationScheduler__c.Pillar__c,
            CSM_QI_CaseAutomationScheduler__c.Primary_Owner__c,
            CSM_QI_CaseAutomationScheduler__c.Primary_Owner_Current_Queue__c,
            CSM_QI_CaseAutomationScheduler__c.ProductName__c,
            CSM_QI_CaseAutomationScheduler__c.Secondary_Owner__c,
            CSM_QI_CaseAutomationScheduler__c.Secondary_Owner_Current_Queue__c,
            CSM_QI_CaseAutomationScheduler__c.Start_Date__c,
            CSM_QI_CaseAutomationScheduler__c.Subject__c,
            CSM_QI_CaseAutomationScheduler__c.SubType1__c,
            CSM_QI_CaseAutomationScheduler__c.SubType2__c,
            CSM_QI_CaseAutomationScheduler__c.SubType3__c,
            CSM_QI_CaseAutomationScheduler__c.Urgency__c
        };
    }
    
    public Schema.SObjectType getSObjectType() {
        return CSM_QI_CaseAutomationScheduler__c.sObjectType;
    }
    
    public List<CSM_QI_CaseAutomationScheduler__c> selectById(Set<ID> idSet) {
        return (List<CSM_QI_CaseAutomationScheduler__c>) selectSObjectsById(idSet);
    }
}