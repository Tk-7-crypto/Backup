/**
 * @Author  : CLD Partners
 * @Purpose : Create and sync deliverables for completed Aggregate Reports
 */
public class QUE_PSA_SyncARDeliverables implements Queueable {
    private List<Aggregate_Report__c> aggregateReports = new List<Aggregate_Report__c>();

    public QUE_PSA_SyncARDeliverables(List<Aggregate_Report__c> agReports) {
        this.aggregateReports = agReports;
    }

    public void execute(QueueableContext context){
        Map<Id,pse__Project_Task__c> reportToExistingDeliverablesMap = new Map<Id,pse__Project_Task__c>();
        Set<String> deliverableFields = new Set<String>{'Id','Aggregate_Report__c','pse__Status__c','Target__c','Resource__c','End_Date_Planned__c', 'End_Date_Actual__c', 'Program__c'};

        //Get existing deliverables to update
        Set<Id> reportIdsToLookUpDeliverables = new Map<Id,Aggregate_Report__c>(aggregateReports).keySet(); 
        List<pse__Project_Task__c> existingDeliverables = new SLT_Project_Task().getProjectTasksByAggregateReport(reportIdsToLookUpDeliverables, deliverableFields);

        if(existingDeliverables.size() > 0){
            for(pse__Project_Task__c deliverable : existingDeliverables){
                reportToExistingDeliverablesMap.put(deliverable.Aggregate_Report__c, deliverable);
            }
        }

        //Sync reports with existing deliverables, or create new ones
        Id deliverableRecordTypeId = Schema.SObjectType.pse__Project_Task__c.getRecordTypeInfosByDeveloperName().get('RDS_Deliverable').getRecordTypeId();
        List<pse__Project_Task__c> syncedDeliverableList = new List<pse__Project_Task__c>();
        Set<Id> userIdSet = new Set<Id>();
        userIdSet.add(UserInfo.getUserId());
        List<Contact> contactList = new List<Contact>();
        Set<String> contactFieldSet = new Set<String>{'Id', 'Name', 'Salesforce_User__c'};
        contactList = new SLT_Contact().selectBySalesforceUserIdsList(userIdSet, contactFieldSet);
        for(Aggregate_Report__c agReport : aggregateReports){
            pse__Project_Task__c deliverable = reportToExistingDeliverablesMap.get(agReport.Id);
            if(deliverable == null) {
                deliverable = new pse__Project_Task__c();
            } 

            deliverable.RecordTypeId = deliverableRecordTypeId;
            deliverable.Aggregate_Report__c = agReport.Id;
            deliverable.pse__Status__c = 'Complete';
            //deliverable.Target__c = '?'; //Need to find formula for getting target
            deliverable.Program__c = agReport.Program__c;
            deliverable.pse__Project__c = agReport.Project__c;
            deliverable.pse__Milestone__c = agReport.Service_Milestone__c;
            deliverable.Resource__c = agReport.Primary_Author__c;
            deliverable.End_Date_Planned__c = agReport.Report_Due_to_IQVIA_or_Client_Reg__c;
            deliverable.End_Date_Actual__c = agReport.Date_Submitted_to_IQVIA_or_Client_Reg__c;
            if(contactList.size() > 0)
                deliverable.Resource__c = contactList[0].Id;

            syncedDeliverableList.add(deliverable);
        }

        if(syncedDeliverableList.size() > 0){
            upsert syncedDeliverableList;
        }
    }
}