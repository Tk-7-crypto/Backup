public class BCH_PSA_UPDT_ACCNT_ON_LR implements Database.Batchable<sObject>{
    @TestVisible List<String> errorMessageList = new List <String>();
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query =  'select id, name, Project__r.Has_Account_Changed__c, Project__r.pse__Account__c,Account__c from LR_Project_Overview__c where Project__r.Has_Account_Changed__c = true AND Project__c != null AND Project__r.Service_Line__c != null AND  Project__r.Service_Line__r.Name = \'Literature\'';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<LR_Project_Overview__c> records) {
        List<LR_Project_Overview__c> lstToUpdate = new List<LR_Project_Overview__c>();
        for(LR_Project_Overview__c lrRecord : records){
            if(lrRecord.Account__c != lrRecord.Project__r.pse__Account__c){
                lrRecord.Account__c = lrRecord.Project__r.pse__Account__c;
                lstToUpdate.add(lrRecord);
            }
        }
        if(lstToUpdate.size()>0){
            Set<Id> projUpdtSet = new Set<Id>();
            Database.SaveResult[] results = Database.update(lstToUpdate, false);
            if (results.size() > 0){
                for (Integer i=0; i< results.size(); i++){
                    if (!results[i].isSuccess()){
                        errorMessageList.add('Errors : ' + results[i].getErrors()[0].getMessage());
                    }else if (results[i].isSuccess()){
                        projUpdtSet.add(lstToUpdate[i].Project__c);
                    }
                }
            }
            List<pse__Proj__c> projToUpdtList = new List<pse__Proj__c>();
            if(projUpdtSet.size()>0){
                for(Id projId: projUpdtSet){
                    pse__Proj__c proj = new pse__Proj__c(Id = projId, Has_Account_Changed__c = false);
                    projToUpdtList.add(proj);
                } 
            }
            if(projToUpdtList.size()>0){
                Database.SaveResult[] projResults = Database.update(projToUpdtList, false);
            }
        }
    }
    public void finish(Database.BatchableContext BContext){}  
}