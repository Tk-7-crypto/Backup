/*
* Version       : 1.0
* Description   : This test class is used for Webservice CSM One Key Verification
*/
@isTest
private class TST_WSC_CSM_OneKeyCaseVerification {
    /**
    * This method used to set up testdata
    */ 
    @testSetup
    static void setup() {
        OneKey_Config__c oneKey = new OneKey_Config__c(OneKey_Request_1__c = '{"fields": [{"name": "individual.individualEid","values":[',
                                                       OneKey_Request_2__c = '],"codBase": [{0}"]}', Exact_Search_Method__c = '],"method": "EXACT"},',
                                                       Phonetic_Search_Method__c = '],"method": "PHONETIC"},', OneKey_Request_3__c = '{"name": "individual.firstNameLastName","values":[');
        insert oneKey;
        Test.setMock(HttpCalloutMock.class, new TST_Mock_WSC_CSM_OneKeyCaseVerification());
        List<Case> listOfCase = new List<Case>();
        case newCase = UTL_TestData.createCase();
        newCase.OneKey_FirstName__c = 'ALAIN';
        newCase.OneKey_LastName__c = 'BISMUTH';
        newCase.Type = 'Erasure';
        insert newCase;
    }
    
    @IsTest
    static void testInsertRecordForApproval() {
        Id caseId = [Select Id from Case where oneKeyId__c = 'WFRD00890450' limit 1].Id;
        List<Id> listOfId = new List<Id>{caseId};
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TST_Mock_WSC_CSM_OneKeyCaseVerification());
        Test.stopTest();
        ProcessInstanceWorkitem pItem = [Select Id from ProcessInstanceWorkitem 
                                         where ProcessInstance.TargetObjectId =: caseId];
        SYstem.assertEquals(true, pItem != null, 'Case is not in approval process');
    }
    
    @IsTest
    static void testUpdateCaseStatus() {
        List<case> listOfcase = [Select Id from Case where oneKeyId__c = 'WFRD00890450'];
       
        Test.startTest();
            set<Case> result = WSC_CSM_OneKeyCaseVerification.updateCaseWithError(listOfcase);
        Test.stopTest();
        
        listOfcase = new List<Case>();
        listOfcase.addAll(result);
        System.assertEquals('Error',listOfcase[0].status ,'case status is not correct');
    }
}