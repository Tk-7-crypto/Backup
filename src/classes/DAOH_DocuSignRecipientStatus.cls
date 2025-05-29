public class DAOH_DocuSignRecipientStatus {
    static TGRH_TPADocuSignRecipientStatus triggerHelper = new TGRH_TPADocuSignRecipientStatus();
    static List<dsfs__DocuSign_Recipient_Status__c> tpaNewDsrList = new List<dsfs__DocuSign_Recipient_Status__c>();
    static List<dsfs__DocuSign_Recipient_Status__c> tpaOldDsrList = new List<dsfs__DocuSign_Recipient_Status__c>();
    
    public static void onAfterInsert(List<dsfs__DocuSign_Recipient_Status__c> newRecords, Map<Id, dsfs__DocuSign_Recipient_Status__c> newMap) {
        for(dsfs__DocuSign_Recipient_Status__c objDsr: [Select Id, dsfs__Parent_Status_Record__r.TPA_Request__c FROM dsfs__DocuSign_Recipient_Status__c WHERE Id IN: newMap.keySet()]) {
            if(objDsr.dsfs__Parent_Status_Record__r.TPA_Request__c != null) {
                tpaNewDsrList.add(objDsr);
            }
        }
        if(tpaNewDsrList.size() > 0 && !UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c) {
            triggerHelper.onAfterInsert(tpaNewDsrList);
        }
    }
    
    public static void onAfterUpdate(List<dsfs__DocuSign_Recipient_Status__c> newRecords, List<dsfs__DocuSign_Recipient_Status__c> oldRecords, Map<Id, dsfs__DocuSign_Recipient_Status__c> newMap, Map<Id, dsfs__DocuSign_Recipient_Status__c> oldMap) {
        for(dsfs__DocuSign_Recipient_Status__c objDsr: [Select Id, dsfs__Parent_Status_Record__r.TPA_Request__c FROM dsfs__DocuSign_Recipient_Status__c WHERE Id IN: newMap.keySet()]) {
            if(objDsr.dsfs__Parent_Status_Record__r.TPA_Request__c != null) {
                tpaNewDsrList.add(objDsr);
                tpaOldDsrList.add(oldMap.get(objDsr.Id));
            }
        }        
        if(tpaNewDsrList.size() > 0 && !UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c) {
            triggerHelper.oldRecordsMap = new Map<Id, dsfs__DocuSign_Recipient_Status__c>(tpaOldDsrList);
            triggerHelper.onAfterUpdate(tpaNewDsrList);
        }
    }
}