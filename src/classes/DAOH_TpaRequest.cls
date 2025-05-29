public class DAOH_TpaRequest {
    static TGRH_TPARequest triggerHelper = new TGRH_TPARequest();
    public static Boolean isManageSharingTriggerd = false;
    
    public static Boolean checkIfOwnerModified(TPA_Request__c newTpaRequestSO, TPA_Request__c oldTpaRequestSO) {
        // get the old and new owner and compare
        return (newTpaRequestSO.OwnerId != null && newTpaRequestSO.OwnerId != oldTpaRequestSO.OwnerId);   
    }
    
    public static void onBeforeInsert(List<TPA_Request__c> newRecords) {
        for (TPA_Request__c tpa : newRecords) {
            DateTime now = System.now();         
            String formattedNow =
                now.formatGmt('yyyy-MM-dd') + 'T' +
                now.formatGmt('HH:mm:ss') + '.' +
                now.formatGMT('SSS') + 'Z';         
            
            //create a unique hash consisting of the TPA Request Id, Name, and the current timestamp
            String canonical = tpa.Id + tpa.Name + formattedNow;                        
            Blob bsig = Crypto.generateDigest('MD5', Blob.valueOf(canonical));         
            
            String token =  EncodingUtil.base64Encode(bsig);                 
            if (token.length() > 255) {
                token =  token.substring(0,254);
            }    
                
            // save unauthenticated tpa site url and security code required to access the request
            tpa.TPASiteURL__c = URL.getSalesforceBaseUrl().toExternalForm() + '/tpa';
            tpa.TPASiteSecurityCode__c = EncodingUtil.urlEncode(token, 'UTF-8').replaceAll('%','_');
        }
        
        triggerHelper.onBeforeInsert(newRecords);
    }
    
    public static void onAfterInsert(List<TPA_Request__c> newRecords) {
        triggerHelper.onAfterInsert(newRecords);
        if(!DAOH_TpaRequest.isManageSharingTriggerd){
            triggerHelper.manageSharing(newRecords);
        }
    }
    
    public static void onBeforeUpdate(List<TPA_Request__c> newRecords, List<TPA_Request__c> oldRecords, Map<Id, TPA_Request__c> newMap, Map<Id, TPA_Request__c> oldMap) {
        triggerHelper.onBeforeUpdate(newRecords, oldRecords, newMap, oldMap);

        // if owner was modified, record this date in the tpa request
        if (newRecords.size() == 1 && checkIfOwnerModified(newRecords[0], oldRecords[0])) {
            
            // record date the owner was initially changed
            if (newRecords[0].Date_IMS_Receipt_Initial__c == null) {
                newRecords[0].Date_IMS_Receipt_Initial__c = system.now();
            }
            
            // record most recent date owner was changed
            newRecords[0].Date_IMS_Receipt_Recent__c = system.now();
        }
    }
    
    public static void onAfterUpdate(List<TPA_Request__c> newRecords, List<TPA_Request__c> oldRecords, Map<Id, TPA_Request__c> newMap, Map<Id, TPA_Request__c> oldMap) {
        triggerHelper.onAfterUpdate(newRecords, oldRecords, newMap, oldMap);        
        if(!DAOH_TpaRequest.isManageSharingTriggerd){
            triggerHelper.manageSharing(newRecords);
        }
    }
    
    public static void onBeforeDelete(List<TPA_Request__c> oldRecords) {
        triggerHelper.onBeforeDelete(oldRecords);
    }
}