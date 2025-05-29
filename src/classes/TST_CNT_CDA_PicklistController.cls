@isTest(seeAllData=false)
public class TST_CNT_CDA_PicklistController { 
    public static testMethod void setUpContactForEmail() {
        String objectType = 'CDA_Request__c';
        String selectedField = 'CDA_Type__c';
        CNT_CDA_PicklistController.getPicklistValues(objectType, selectedField);
        CNT_CDA_PicklistController.getAllPicklistValuesMap(objectType);
    }
}