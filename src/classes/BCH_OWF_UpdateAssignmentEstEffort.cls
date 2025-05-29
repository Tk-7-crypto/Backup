public class BCH_OWF_UpdateAssignmentEstEffort implements Database.Batchable<Sobject> , Database.Stateful {
   
    @TestVisible Map<Id, String> assignmentIdToErrorMessageMap;
    @TestVisible public Map<String,Integer> subgroupToDaysMap = new Map<String,Integer>();
    @TestVisible public Date currentDate;
    @TestVisible Decimal noOfDays; 
    public BCH_OWF_UpdateAssignmentEstEffort() {
        assignmentIdToErrorMessageMap = new Map<Id, String>();
    }
    
    /**
     * start method 
     * @params  Database.BatchableContext context
     * @return  Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext context) {
        //list of all assignments for updating status
        Integer maxdays = 0;
        if(Test.isRunningTest())
        {
            subgroupToDaysMap.put('TAL',8);    
            maxdays = 8;
        }
        /*else{
            List<OWF_Resource_Setting__mdt> resourceSettingMetadata = [Select Sub_Group__c,Estimation_Effort_Updated_After_Days__c from OWF_Resource_Setting__mdt where Estimation_Effort_Updated_After_Days__c!= null];
            for(OWF_Resource_Setting__mdt resourceSetting: resourceSettingMetadata){
                if(maxdays < Integer.valueOf(resourceSetting.Estimation_Effort_Updated_After_Days__c)){
                    maxdays = Integer.valueOf(resourceSetting.Estimation_Effort_Updated_After_Days__c);
                }
                subgroupToDaysMap.put(resourceSetting.Sub_Group__c,Integer.valueOf(resourceSetting.Estimation_Effort_Updated_After_Days__c));
                
            }
            maxdays = maxdays +  ((maxdays/5) + 1) * 2;            
        }*/        
        currentDate = Date.today().addDays(-(maxdays));
        String subgroupName = '\''+ String.join(subgroupToDaysMap.keySet(), '\',\' ') +'\'';
        String query = 'Select id from Contact where (Sub_Group__c in('+ subgroupName +') or Secondary_Sub_Group__c includes ('+subgroupName+'))  and pse__Is_Resource__c = true and pse__Is_Resource_Active__c = true and pse__Salesforce_User__r.IsActive = true';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext context, List<Contact> contactList) {
        /*Set<Id> contactIdSet = new Set<Id>();
        for(Contact con : contactList){
            contactIdSet.add(con.id);
        }
        
        String assignmentCondition = 'pse__Resource__c in: sObjectIdset AND (pse__Status__c =\'Accepted\' OR pse__Status__c =\'Pending\') AND RecordType.DeveloperName =\'OWF_Assignment\' AND pse__End_Date__c >= TODAY AND Match_Date__c >= :currentDate AND Bid_History__r.Bid_Number__c = 1  And Bid_History__r.RecordTypeID = \'' + CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID + '\'';
        Set<String> assignmentFieldSet = new Set<String>{'Id','pse__Resource__c','pse__Status__c','createdDate','Subgroup_Name__c','Estimation_Effort__c','Regional_Analytics_country__c','Match_Date__c'};
        List<pse__Assignment__c> assignmentList = new SLT_Assignment(false,false).getAssignmentByResourceAndCondition(contactIdSet,currentDate,assignmentCondition,assignmentFieldSet);
        List<pse__Assignment__c> assignmentUpdateList = new List<pse__Assignment__c>();
        for(pse__Assignment__c assignment: assignmentList){
            if(subgroupToDaysMap.keySet().contains((assignment.Subgroup_Name__c)) && (assignment.Subgroup_Name__c != CON_OWF.RES_REQ_TYPE_GLOBAL_ANALYTICS || 
               (assignment.Subgroup_Name__c == CON_OWF.RES_REQ_TYPE_GLOBAL_ANALYTICS && 
                assignment.Regional_Analytics_country__c == CON_OWF.RA_COUNTRY_TYPE_STRATEGIC_ANALYTICS))){
                    if(findNoOfDays_exclude_weekend(assignment.Match_Date__c,Date.Today()) == subgroupToDaysMap.get(assignment.Subgroup_Name__c)){
                        assignment.Estimation_Effort__c = assignment.Estimation_Effort__c * 0.3;
                    }
                }
            assignmentUpdateList.add(assignment);
        }
        if (assignmentUpdateList.size() > 0){
            Database.SaveResult[] results = Database.Update(assignmentUpdateList, false);
            if (results.size() > 0){
                for (Integer i=0; i< results.size(); i++){
                    if (!results[i].isSuccess()){
                        assignmentIdToErrorMessageMap.put(assignmentUpdateList[i].Id, 'Error in accepting unassigned assignments : ' + results[i].getErrors()[0].getMessage());
                    }
                }
            }
        }*/
    }
    
    /*public static Integer findNoOfDays_exclude_weekend(Date startDate,Date endDate) {
        Decimal noOfDays    = (5*(Math.FLOOR(DATE.newInstance(1900,1,8).daysBetween(endDate)/7)) + Math.MIN( 5, Math.MOD(DATE.newInstance(1900,1,8).daysBetween(endDate),7) ))  - (5 * ( Math.FLOOR( DATE.newInstance( 1900, 1, 8).daysBetween(startDate)/ 7 )) + Math.MIN( 5, Math.MOD(DATE.newInstance(1900,1,8).daysBetween(startDate), 7  ) ) ) ;
        Boolean isWeekend   = (Math.MOD(DATE.newInstance(1900,1,6).daysBetween(endDate),7) == 0 || Math.MOD(DATE.newInstance(1900,1,6).daysBetween(endDate),7) == 1) ? true : false;
        
        //add an extra day if it doesn't end on a weekend
        noOfDays = !isweekend ? noOfDays += 1 : noOfDays;
        return (Integer)noOfDays;
    }*/
    
    public void finish(Database.BatchableContext context) {
        /*if (assignmentIdToErrorMessageMap.size() > 0 || Test.isRunningTest()){
            UTL_OWF.sendMailOnException(CON_OWF.BCH_OWF_UPDATEASSIGNMENTESTEFFORT, assignmentIdToErrorMessageMap, 'BCH_OWF_UpdateAssEstimationEffort Batch: Failed');
        }*/
    } 
}