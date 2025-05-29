public class DAOH_DataPortalQueueUserdetails {
    @AuraEnabled
    public static void getDefaultAccountQueueConfig(List<CSM_QI_Data_Portal_Queue_User_details__c> newList){
        Set<String> accIds = new Set<String>();
        Set<String> records = new Set<String>();
        for(CSM_QI_Data_Portal_Queue_User_details__c c : newList){
            if(c.Order__c != 100 && c.Order__c != 1 && c.Type__c == 'Queue Assignment'){
                accIds.add(c.Account__c);
                records.add(c.CaseRecordType__c);
            }    
        }
        List<CSM_QI_Data_Portal_Queue_User_details__c> datalist = Database.query('select Id, Account__c,AccountName__c, All_Current_Users__c, Order__c, Queue_User_Relationship__c, AccountCountry__c, CaseRecordType__c  from CSM_QI_Data_Portal_Queue_User_details__c where Account__c in :accIds and Order__c = 1 and Queue_User_Relationship__c != null and CaseRecordType__c in :records and All_Current_Users__c = true');
        if(datalist != null && datalist.isEmpty()){
            for(CSM_QI_Data_Portal_Queue_User_details__c c : newList){
                if(c.Order__c != 100 && c.Order__c != 1 && c.Type__c == 'Queue Assignment'){
                    c.addError('Please create the default portal queue assignment(i,e; Order 1) of the selected Account for '+ c.CaseRecordType__c+' record type');
                }
            }
        }
    }

}