public class DAOH_OWF_Investigator_Grant {
    
    public static void populateAssignedInvestigator(List<Investigator_Grant__c> newList){
        Set<Id> bidHistoryIdSet = new Set<Id>();
        Map<Id,Id> investigatorGrantIdToBidHistoryIdMap = new Map<Id,Id>();
        Map<Id,pse__Assignment__c> bidHistoryToAssignmentMap = new Map<Id,pse__Assignment__c>();
        for(Investigator_Grant__c ig : newList){
            bidHistoryIdSet.add(ig.Bid_History__c);
            investigatorGrantIdToBidHistoryIdMap.put(ig.Id,ig.Bid_History__c);
        }

        Set<String> assignmentFieldSet = new Set<String>{'pse__Resource_Request__r.pse__End_Date__c','pse__Resource__r.pse__Salesforce_User__c','createdDate','Bid_History__c'};
        String condition = 'AND pse__Resource_Request__r.SubGroup__c = \''+CON_OWF.RES_REQ_TYPE_IG_LEAD+'\' AND pse__Status__c = \''+CON_OWF.OWF_STATUS_ACCEPTED + '\' AND pse__Resource_Request__r.Is_Created_Automatically__c = True';
        List<pse__Assignment__c> assignmentList = new SLT_Assignment(false,false).getAssignmentByBhrAndCondition(bidHistoryIdSet,condition,assignmentFieldSet);
        for(pse__Assignment__c assignment : assignmentList){
            bidHistoryToAssignmentMap.put(assignment.Bid_History__c,assignment);
        }
        for(Investigator_Grant__c ig : newList){
            pse__Assignment__c assignment = bidHistoryToAssignmentMap.get(investigatorGrantIdToBidHistoryIdMap.get(ig.Id));
            if(assignment !=null){
                ig.Assigned_Investigator_Grants_Developer__c = assignment.pse__Resource__r.pse__Salesforce_User__c;
                ig.Investigator_Grants_Assigned_Date__c = Date.newInstance(assignment.createdDate.year(), assignment.createdDate.month(), assignment.createdDate.day());
                ig.Investigator_Grants_Due_Date_to_PD__c = assignment.pse__Resource_Request__r.pse__End_Date__c;
            }
        } 
    }
}