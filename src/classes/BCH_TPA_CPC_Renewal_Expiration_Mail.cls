global class BCH_TPA_CPC_Renewal_Expiration_Mail implements Database.Batchable<sObject>,Database.Stateful {
    Date todayDate;
    List<String> recIdsList = new List<String>();
    public Boolean includeTestDataOnly{
		get{
			if(includeTestDataOnly == null) {
				includeTestDataOnly = false;
			}
			return includeTestDataOnly;
		}
		set;
	}
    global BCH_TPA_CPC_Renewal_Expiration_Mail () {
        todayDate = Date.today();
        //includeTestDataOnly = UTL_TPA.runBatchForTestRecords('BCH_TPA_CPC_Renewal_Expiration_Mail');		
    }
    
    global BCH_TPA_CPC_Renewal_Expiration_Mail (List<String> recIds) {
        todayDate = Date.today();
        recIdsList = recIds;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'Select Id from TPA_Request__c where  Request_Status__c in (\'Expired\',\'In Effect\',\'AMA Discontinued\',\'AMA Cancelled\',\'Client Discontinued\') and Is_Submitted__c = true and (CPC_Renewal_Notice_Sent_Last_Date__c = null or CPC_Expiration_Notice_Sent_Last_Date__c = null or CPC_Expiration_Postnotice_Sent_Last_Date__c = null) and is_renewed__c = false and Data_Access_End_Date__c != null'; 
               query += ' and (Data_Access_End_Date__c = LAST_N_DAYS:60 or Data_Access_End_Date__c = NEXT_N_DAYS:30) ' ;
        if(!recIdsList.isEmpty()){
            query += ' and Id in :' + recIdsList;
        }
        if(includeTestDataOnly){
            query += ' and (Client_Address__r.Name Like \'Test_'+'%\'  OR Service_Provider_f__c Like \'Test_'+'%\' )';
        }
        if(Test.isRunningTest()){
            query += ' limit 2';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> objList) {
        try {
            List<TPA_Request__c> tpaRequestUpdateList = new List<TPA_Request__c>();
            UTL_TPA.notificationsTriggerExecuted = true;
            List<String> listId = new List<String>();
            for(sobject sobj : objList){
                listId.add(sobj.id);
            }
            List<TPA_Request__c> sobjList = [Select Id, Service_Provider_f__c, Client_Expired_Early__c, Client_First_Name__c, request_termination_time__c, ClientContact__c, ClientContact__r.Email, ClientContact__r.Name, Data_Access_End_Date__c, Is_CPC_Expiration_Notice_Sent__c, Early_Contract_Expiry_Date__c, Is_CPC_Renewal_Notice_Sent__c, Is_CPC_Post_Expiration_Notice_Sent__c, Request_Status__c, (select id, Name, Early_Contract_Expiry_Date__c  from TPA_Agreement_Additional_Fields__r), (Select Id from Vendor_Offering_Return_Acknowledgments__r) from TPA_Request__c where Request_Status__c in ('Expired','In Effect','AMA Discontinued','AMA Cancelled','Client Discontinued') and Is_Submitted__c = true and (CPC_Renewal_Notice_Sent_Last_Date__c = null or CPC_Expiration_Notice_Sent_Last_Date__c = null or CPC_Expiration_Postnotice_Sent_Last_Date__c = null) and is_renewed__c = false and Data_Access_End_Date__c != null and id IN : listId];
            for(TPA_Request__c tpaObj : sobjList) {                
                Integer dateDifferenceInDays = todayDate <= tpaObj.Data_Access_End_Date__c ? todayDate.daysBetween(tpaObj.Data_Access_End_Date__c) : tpaObj.Data_Access_End_Date__c.daysBetween(todayDate);
                if(todayDate <= tpaObj.Data_Access_End_Date__c) {
                    if( (tpaObj.Service_Provider_f__c != null && tpaObj.Service_Provider_f__c.containsIgnoreCase('Test_')) || (tpaObj.Client_First_Name__c != null && tpaObj.Client_First_Name__c.containsIgnoreCase('Test_'))) {
                        if(dateDifferenceInDays == 2 && tpaObj.Request_Status__c == 'In Effect' && !tpaObj.Client_Expired_Early__c){
                            tpaObj.Is_CPC_Renewal_Notice_Sent__c = true;
                        }
                        if(dateDifferenceInDays == 1 && tpaObj.Request_Status__c == 'In Effect' && !tpaObj.Client_Expired_Early__c){
                            tpaObj.Is_CPC_Expiration_Notice_Sent__c = true;
                        }
                        tpaRequestUpdateList.add(tpaObj);
                    }
                    else{
                        if(dateDifferenceInDays <= 30 && tpaObj.Request_Status__c == 'In Effect' && !tpaObj.Client_Expired_Early__c) {
                            tpaObj.Is_CPC_Renewal_Notice_Sent__c = true;
                        }
                        if(dateDifferenceInDays <= 14 && tpaObj.Request_Status__c == 'In Effect' && !tpaObj.Client_Expired_Early__c) {
                            tpaObj.Is_CPC_Expiration_Notice_Sent__c = true;
                        }
                        tpaRequestUpdateList.add(tpaObj);
                    }
                }
                else if(tpaObj.Request_Status__c == 'Expired' && todayDate > tpaObj.Data_Access_End_Date__c && dateDifferenceInDays >= 1 && ( tpaObj.TPA_Agreement_Additional_Fields__r.size() == 0 || (tpaObj.Early_Contract_Expiry_Date__c == null))) { 
                    if(tpaObj.Vendor_Offering_Return_Acknowledgments__r == null || tpaObj.Vendor_Offering_Return_Acknowledgments__r.size() == 0){
                        tpaObj.Is_CPC_Post_Expiration_Notice_Sent__c = true;
                        tpaRequestUpdateList.add(tpaObj);
                    }
                }
            }
            UTL_TPA.modifyRequestForcefully = true;
            update tpaRequestUpdateList;
            UTL_TPA.modifyRequestForcefully = false;
            if(Test.isRunningTest()) {
                SRV_TPA_TPARequest.getCustomException();
            }
        }
        catch(Exception ex) {
            UTL_LogFactory.generateAndCommitLog(TRUE, 
                                                FALSE, 
                                                UTL_LogFactory.GUID, 
                                                'Exception: in BCH_TPA_CPC_Renewal_Expiration_Mail class execute method :: ' + ex.getMessage(), 
                                                'TPA', 
                                                'Exception', 
                                                'ERROR', 
                                                'Line#' + ex.getLineNumber() + ':::BCH_TPA_CPC_Renewal_Expiration_Mail:::execute', 
                                                '');
        }
    }
    
    
    global void finish(Database.BatchableContext bc){ 
    }
}