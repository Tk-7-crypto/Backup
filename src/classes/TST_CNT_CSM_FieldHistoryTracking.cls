@isTest
private class TST_CNT_CSM_FieldHistoryTracking {
    
    testmethod static void testgetObjNameList(){
        CNT_CSM_FieldHistoryTracking.getObjNameList();
    }
    
    testmethod static void testshowFieldGroupCheckboxData(){
        CNT_CSM_FieldHistoryTracking.showFieldGroupCheckboxData('Case');
        CNT_CSM_FieldHistoryTracking.showFieldGroupCheckboxCustomData('Case');
        CNT_CSM_FieldHistoryTracking.saveFields('Case',null);
        CNT_CSM_FieldHistoryTracking.saveFields('Case','AccessionNumber__c,Account_Name_Article__c,AccountCountry__c,ACN__c,ActionDescription__c');
        CNT_CSM_FieldHistoryTracking.saveFields('Case','AccessionNumber__c,Account_Name_Article__c,AccountCountry__c,ACN__c,ActionDescription__c');
    }
}