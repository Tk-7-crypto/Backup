public class CNT_CSM_CreateCaseForm {
    @AuraEnabled       
    public static List<EXT_CSM_CheckboxDetails> getRecordTypeValues() {
        List<EXT_CSM_CheckboxDetails> recordTypes = new List<EXT_CSM_CheckboxDetails>();
        EXT_CSM_CheckboxDetails record = null;
        List<Schema.RecordTypeInfo> recordTypeInfoList = Case.SObjectType.getDescribe().getRecordTypeInfos();
        for(RecordTypeInfo info: recordTypeInfoList) {
            if(info.isAvailable()) {
                if(info.getName() != CON_CSM.S_MASTER && info.getName().trim() != '') {
                    record = new EXT_CSM_CheckboxDetails(String.valueOf(info.getRecordTypeId()), info.getName(), false);
                    recordTypes.add(record);  
                }
            }
        } 
        if(!recordTypes.isEmpty() && recordTypes.size() > 0) {
            recordTypes[0].checked = true;
        }
        return recordTypes;
    }
    
    @AuraEnabled       
    public static String getAccountByContact(String contactId) {
        List<Contact> contactList = new SLT_Contact().selectByContactIdList(new Set<Id>{contactId}, new Set<String>{'AccountId'});
        String accountId = contactList != null && contactList.size() > 0 ? contactList[0].AccountId : null;
        return accountId;
    }
}