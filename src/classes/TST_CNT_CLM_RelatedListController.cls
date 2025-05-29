@isTest
public class TST_CNT_CLM_RelatedListController {

    @testSetup
    static void dataSetup() {
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        agreement.Name = 'Test PSA';
        agreement.Apttus__Status_Category__c = 'Request';
        agreement.Apttus__Status__c = 'Request';
        insert agreement;
        
        Task task1 = new Task(RecordTypeId = CON_CLM.TASK_STANDARD_RECORDTYPEID, WhatId = agreement.Id, Status = CON_CLM.NOT_STARTED, Subject = CON_CLM.SUBTYPE_PL, Description = 'Contract PL review');
        insert task1;
    }
    
    @isTest
    private static void testGetRecords() {
        Apttus__APTS_Agreement__c agreement = [SELECT Id, Name FROM Apttus__APTS_Agreement__c WHERE Name = 'Test PSA' LIMIT 1];
        List<Task> taskList = new List<Task>();
        Test.startTest();
            taskList = CNT_CLM_RelatedListController.getRecords(agreement.Id);
        Test.stopTest();
        System.assertNotEquals(null,taskList, 'The tasklist should not be empty');
    }
    
    @isTest
    private static void testGetPicklistValues() {
        Test.setMock(HttpCalloutMock.class, new TST_Mock_UTL_PickListOptions());
        Test.startTest();
            Map<String,String> pickListValuesMap = CNT_CLM_RelatedListController.getPicklistValues('Task','Status');
        Test.stopTest();
        System.assertNotEquals(null,pickListValuesMap, 'The pickListValuesMap should not be empty');
    }
   
    @isTest
    private static void testUpdateRecords() {
        Task t=[SELECT Id FROM Task LIMIT 1];
        List<Task> newList=new List<Task>{new Task(Id=t.Id, Status = 'Open')};
        String jsonString = JSON.serialize(newList);
        Test.startTest();
            CNT_CLM_RelatedListController.updateRecords(jsonString);
        Test.stopTest();
        Task t1=[SELECT Id, Subject, Status FROM Task WHERE Status='Open' LIMIT 1];
        System.assertEquals(t1.Subject, CON_CLM.SUBTYPE_PL,'The pickListValuesMap should not be empty');
    }
}