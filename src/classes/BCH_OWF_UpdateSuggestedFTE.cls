public class BCH_OWF_UpdateSuggestedFTE implements Database.Batchable<Sobject> , Database.Stateful{
    
    @TestVisible Map<Id, String> rrIdToErrorMessageMap;
    public BCH_OWF_UpdateSuggestedFTE() {
        rrIdToErrorMessageMap = new Map<Id, String>();
    }
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        String query = 'Select id, Is_Bid_Defense__c, SubGroup__c, pse__Start_Date__c, pse__End_Date__c, Is_Created_Automatically__c, Suggested_FTE__c from pse__Resource_Request__c Where Is_Bid_Defense__c = true AND SubGroup__c in (\'Biosimilar-COE\', \'Medical-MSL\', \'TSL\', \'ECD-COE\', \'CAGT-COE\', \'PRD-COE\') AND pse__Start_Date__c != LAST_N_DAYS:14 AND pse__Start_Date__c = LAST_N_DAYS:21';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext context, List<pse__Resource_Request__c> rrList) {
        List<pse__Resource_Request__c> rrListToUpdateList = new List<pse__Resource_Request__c>();
        for(pse__Resource_Request__c rr : rrList){
            if(rr.Suggested_FTE__c != 0.7){
                rr.Suggested_FTE__c = 0.7;
                rrListToUpdateList.add(rr);
            }
        }
        
        if (rrListToUpdateList.size() > 0){
            Database.SaveResult[] results = Database.Update(rrListToUpdateList, false);
            if (results.size() > 0){
                for (Integer i=0; i< results.size(); i++){
                    if (!results[i].isSuccess()){
                        rrIdToErrorMessageMap.put(rrListToUpdateList[i].Id, 'Error in updating Suggested FTE : ' + results[i].getErrors()[0].getMessage());
                    }
                }
            }
        }
    }
    
    public void finish(Database.BatchableContext context) {
        if (rrIdToErrorMessageMap.size() > 0 || Test.isRunningTest()){
            UTL_OWF.sendMailOnException(CON_OWF.BCH_OWF_UPDATESUGGESTEDFTE, rrIdToErrorMessageMap, 'BCH_OWF_UpdateSuggestedFTE Batch: Failed');
        }
    }
    

}
