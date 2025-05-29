/*
* Version       : 1.0
* Description   : This test class is used for Select SObject Sharing.
*/
@ISTest
private class TST_SLT_sObjectSharing {
    
    @testSetup
    static void dataSetup() {
        
        SObject_Sharing__c sObjSharing = new SObject_Sharing__c(Enable_Sharing_Calculation__c =true, 
                                         Parent_Sobject__c = 'Apttus__APTS_Agreement__c', Sharing_Territory_Label__c ='Opportunity');
        insert sObjSharing;    
    }
    
    @isTest
    static void testGetSObjectSharing(){
        
        LIst<SObject_Sharing__c> sobjectSharingList = [SELECT id, Enable_Sharing_Calculation__c FROM SObject_Sharing__c];
        Test.startTest();        
        Set<String> sObjectSharingFieldSet = new Set<String>{'Id', 'Enable_Sharing_Calculation__c'};
        List<SObject_Sharing__c> checkSObjectSharingList = new SLT_sObjectSharing().getSObjectSharing(sObjectSharingFieldSet);      
        Test.stopTest();
        System.assertEquals(sobjectSharingList[0].Id, checkSObjectSharingList[0].Id);        
    }
}