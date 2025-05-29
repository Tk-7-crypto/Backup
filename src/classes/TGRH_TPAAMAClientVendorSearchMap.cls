public class TGRH_TPAAMAClientVendorSearchMap {
    

     /**
     * Name: updateAMAAccountFlagOnAccount
     * Description: Method to set 'Is AMA Account' flag to true on mapped accounts.
     * @param:
     * @return: 
    **/
    public static void updateAMAAccountFlagOnAccount( List<TPA_AMA_Client_Vendor_Search_Map__c> newClientVendorMatchingList, Map<Id, TPA_AMA_Client_Vendor_Search_Map__c> oldClientVendorMatchingMap) {
        
        if(trigger.isInsert || trigger.isUpdate) {
            
            //Set to store accounts id
            Set<Id> amaAccountsIdSet = new Set<Id>();
            
            //Map to store account id along with full record
            //Key: Id - Id of account
            //Value: Account - account record
            Map<Id,Address__c> amaAccountsMap = new Map<Id,Address__c>();
            
            //To get all ids of account record where 'is ama account' flag is needed to be checked
            for(TPA_AMA_Client_Vendor_Search_Map__c clientVendorMatchRecord : newClientVendorMatchingList) {
                if(trigger.isUpdate) {
                    if(oldClientVendorMatchingMap.get(clientVendorMatchRecord.id).TPA_Account_Address__c == clientVendorMatchRecord.TPA_Account_Address__c) {
                        continue;
                    }
                }
                amaAccountsIdSet.add(clientVendorMatchRecord.TPA_Account_Address__c);
            }
            
            //To get all account records where 'is ama account' flag is needed to be checked
            for(Address__c acc : [Select id, Is_AMA_Account__c from Address__c where id IN: amaAccountsIdSet]) { //and BillingCountry IN: usaCountryCodeNameSet and Is_TPA_Account__c = true
                acc.Is_AMA_Account__c = true;
                amaAccountsMap.put(acc.id,acc);
            }
            
            //Creating list of account in reder to update accounts in list
            List<Address__c> accountsToBeUpdated = new List<Address__c>();
            for(Id accId : amaAccountsMap.keySet()) {
                accountsToBeUpdated.add(amaAccountsMap.get(accId));
            }
            
            //Update all acount records
            if(accountsToBeUpdated.size() > 0) {
                update accountsToBeUpdated;
            }
        }
    }
    
    // added by supriya johari under Issue-11508 starts
    /**
     * Name: removeNewClientVendorRecords
     * Description: Method to delete records which exists in new client vendor object if vendor search map record name is same.
     * @param:
     * @return: 
    **/
    public static void removeNewClientVendorRecords( List<TPA_AMA_Client_Vendor_Search_Map__c> newClientVendorMatchingList) {
        
        if(trigger.isInsert || trigger.isUpdate) {
            List<TPA_AMA_Client_Vendor_Match__c> clientVendorMatchList =  [SELECT Id, Name, Client_Name__c, Truncated_Name__c, Mapped_Account_Id__c, Mapped_Account_Name__c, IMS_Client_Names__c, IMS_Total_Clients__c, TPA_Account_Address__c FROM TPA_AMA_Client_Vendor_Match__c];
            Map<String, TPA_AMA_Client_Vendor_Match__c> clientVendorMatchMap = UTL_TPA_AMA.getNewClientVendorMatchMap(clientVendorMatchList);
            
            List<TPA_AMA_Client_Vendor_Match__c> matchRecordsToDelete = new List<TPA_AMA_Client_Vendor_Match__c>();
            for(TPA_AMA_Client_Vendor_Search_Map__c searchMapObj : newClientVendorMatchingList) {
                if(clientVendorMatchMap.containsKey(searchMapObj.AMA_Account_Search_Text__c)) {
                    matchRecordsToDelete.add(clientVendorMatchMap.get(searchMapObj.AMA_Account_Search_Text__c));
                }
            }
            
            if(matchRecordsToDelete.size() > 0) {
                delete matchRecordsToDelete;
            }
        }
            
    }
}