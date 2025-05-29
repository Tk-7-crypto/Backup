/**
 * @Author  : Metacube
 * @Purpose : Create deliverables for completed SD Runs Records
 */
public class QUE_PSA_SyncSDRunsDeliverables implements Queueable{
    private List<SD_Runs__c> sdRuns = new List<SD_Runs__c>();
    
	public QUE_PSA_SyncSDRunsDeliverables(List<SD_Runs__c> agReports) {
        this.sdRuns = agReports;
    }

    public void execute(QueueableContext context){
        Map<Id,pse__Project_Task__c> reportToExistingDeliverablesMap = new Map<Id,pse__Project_Task__c>();
        Set<String> deliverableFields = new Set<String>{'Id','SD_Run_Status__c','Project_Code__c','SD_Run_ID__c','SD_Run_Due_Date__c','Identifier__c','Account_Name__c','Product_Name__c','System_Generated_Deliverable__c'};
            
        //Get existing deliverables to update
        Set<Id> reportIdsToLookUpDeliverables = new Map<Id,SD_Runs__c>(sdRuns).keySet(); 
        Set<Id> projectIdSet = new Set<Id>();
        Set<Id> sdRunIdSet = new Set<Id>();
        for(SD_Runs__c sd : sdRuns){
            projectIdSet.add(sd.Project__c);
            sdRunIdSet.add(sd.id);
        }
        Map<Id,SD_Runs__c> sdRunMap = new Map<Id,SD_Runs__c>([SELECT Id, Account__r.Name, Product__r.Name
                                                         FROM SD_Runs__c 
                                                         WHERE Id in: sdRunIdSet]);
        List<pse__Project_Task__c> existingDeliverables = new SLT_Project_Task().getProjectTasksBySDRuns(reportIdsToLookUpDeliverables, deliverableFields);
        
		//Map<Id, Milestone__c> milestoneMap = new SLT_
		Map<Id, List<pse__Milestone__c>> projectMilestoneListMap = new SLT_Milestone().selectMilestoneListByProjectId(projectIdSet,new Set<String> {'Id','Name','pse__Project__c','Service__r.Name'});
        if(existingDeliverables.size() > 0){
            for(pse__Project_Task__c deliverable : existingDeliverables){
                reportToExistingDeliverablesMap.put(deliverable.SD_Run_ID__c, deliverable);
            }
        }

        //Sync reports with existing deliverables, or create new ones
        Id deliverableRecordTypeId = Schema.SObjectType.pse__Project_Task__c.getRecordTypeInfosByDeveloperName().get('RDS_Deliverable').getRecordTypeId();
        List<pse__Project_Task__c> syncedDeliverableList = new List<pse__Project_Task__c>();
        String uniqueString;
        String secondString;
        String firstString;
        String sdRunName;
        for(SD_Runs__c sdRunsRec : sdRuns){
            pse__Project_Task__c deliverable = reportToExistingDeliverablesMap.get(sdRunsRec.Id);
            uniqueString = sdRunsRec.SD_Run_Unique_ID__c;
            secondString = uniqueString.remove(uniqueString.substringBefore('-'));
            firstString = uniqueString.substringBefore('-').left(3);
            sdRunName = firstString+secondString;
            
            if(deliverable == null || deliverable.System_Generated_Deliverable__c == false) {
                deliverable = new pse__Project_Task__c();
                deliverable.RecordTypeId = deliverableRecordTypeId;
                deliverable.SD_Run_ID__c = sdRunsRec.Id;
                List<pse__Milestone__c> milestoneList = new List<pse__Milestone__c>();
                
                //Service milestone and service name map
                Map<String, Id> srvcNameMlstnMap = new Map<String,Id>();
                List<String> srvcNameList = new List<String>();
                milestoneList = projectMilestoneListMap.get(sdRunsRec.Project__c);
                
                for(pse__Milestone__c mlstn : milestoneList){
                    srvcNameMlstnMap.put( mlstn.Service__r.Name, mlstn.Id);
                    srvcNameList.add(mlstn.Service__r.Name);
                }
                
                if(milestoneList != null && srvcNameList.size() > 0 && srvcNameList.contains('Signal Detection Run')){
                    Id mlstnId = srvcNameMlstnMap.get('Signal Detection Run');
                    deliverable.pse__Milestone__c = mlstnId;
                    deliverable.Name = 'Signal Detection Run' + '-' + sdRunName;
                    deliverable.Resource__c = sdRunsRec.SM_Specialist__c;
                }else if(milestoneList != null && srvcNameList.size() > 0 && srvcNameList.contains('SM Miscellaneous')){
                    Id mlstnId = srvcNameMlstnMap.get('SM Miscellaneous');
                    deliverable.pse__Milestone__c = mlstnId;                    
                    deliverable.Name = 'SM Miscellaneous' + '-' + sdRunName;
                    deliverable.Resource__c = sdRunsRec.SM_Specialist__c;
                }
                
                deliverable.pse__Project__c = sdRunsRec.Project__c;
                deliverable.Account_Name__c = sdRunMap.get(sdRunsRec.id).Account__r.Name;   
                deliverable.Product_Name__c = sdRunMap.get(sdRunsRec.id).Product__r.Name;
                deliverable.System_Generated_Deliverable__c = true;
                deliverable.Identifier__c =  deliverable.Name;
                deliverable.SD_Run_Due_Date__c = sdRunsRec.SD_Run_Due_Date__c;
                deliverable.pse__Status__c = 'Complete';
                syncedDeliverableList.add(deliverable);
            }
        }
        if(syncedDeliverableList.size() > 0){
            upsert syncedDeliverableList;
        }
    }
}
