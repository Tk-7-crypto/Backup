/*
* Version       : 1.0
* Description   : This test class is used for Select Territory Sharing.
*/
@ISTest
private class TST_SLT_TerritorySharing {
    
    @testSetup
    static void dataSetup() {
        Territory_Sharing__c terrSharing = new Territory_Sharing__c(Account_Country__c = 'All', Record_Type__c = 'All', 
                                                                                    Business_Unit__c = 'All', Parent_Customer_Code__c = 'All', Parent_Sobject_Name__c = 'Apttus__APTS_Agreement__c', isActive__c = true);
        insert terrSharing;        
    }
    
    @isTest
    static void testGetTerritorySharing(){
        
        LIst<Territory_Sharing__c> terSharingList = [SELECT id, Name FROM Territory_Sharing__c WHERE isActive__c = true];
        Test.startTest();        
        Set<String> terSharingFieldSet = new Set<String>{'Id','Account_Country__c','Record_Type__c', 'Business_Unit__c', 'Parent_Customer_Code__c', 'Access_Level__c', 'Parent_Sobject_Name__c', 'Group_Id__c'};
        List<Territory_Sharing__c> territorySharingDataList = new SLT_TerritorySharing().getTerritorySharing(terSharingFieldSet);       
        Test.stopTest();
        System.assertEquals(terSharingList[0].Id, territorySharingDataList[0].Id);
        
    }
    
}