@isTest
public with sharing class TST_SLT_FRUP {
    
    @testSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount(); 
        insert acc; 
        
        Contract contract = new Contract();
        contract.Name = 'Test Contract';
        contract.AccountId = acc.Id;
        insert contract;
        
        box__FRUP__c testFRUP = new box__FRUP__c();
        testFRUP.box__Record_ID__c = contract.Id;
        testFRUP.box__Folder_ID__c = '123456';
        testFRUP.box__Object_Name__c = 'Contract';
        insert testFRUP;
    }
    
    @isTest
    static void testByfolderId(){
        Account accountObj = UTL_TestData.createAccount();
        insert accountObj;
        Opportunity opportunityObj = UTL_TestData.createOpportunity(accountObj.Id);
        INSERT opportunityObj;

        box__FRUP__c testFrup = new  box__FRUP__c(box__Folder_ID__c='1234567', box__Object_Name__c='Agreement', box__Record_ID__c = opportunityObj.Id);
        INSERT testFrup;
        Test.startTest();
        Set<Id> boxRecordIds = new Set<Id>{opportunityObj.id};
        List<box__FRUP__c> boxlist =  new SLT_FRUP().getFRUPRecordsByRecordId(boxRecordIds);
        box__FRUP__c frupRecord1 = new SLT_FRUP().getFolderId(opportunityObj.id, new Set<String>{'box__Folder_ID__c'});
        Test.stopTest();
        System.assertEquals(testFrup.box__Folder_ID__c, frupRecord1.box__Folder_ID__c);
        Schema.SObjectType type = new SLT_FRUP().getSObjectType();  
        List<Schema.SObjectField> fieldset = new SLT_FRUP().getSObjectFieldList();
    }
    
    @isTest
    private static void testGetFRUPRecordsByBoxRecordId() {
        Id contractId = [SELECT Id FROM Contract WHERE Name = 'Test Contract'].Id;
        String condition = 'box__Record_ID__c IN: boxRecordIds';
        Set<String> fieldSet = new Set<String>{'box__Folder_ID__c'};
        
        Test.startTest();
            List<box__FRUP__c> resultFRUP = new SLT_FRUP().getFRUPRecordsByBoxRecordId(new Set<Id>{contractId}, fieldSet, condition);   
        Test.stopTest();
        
        System.assertEquals('123456', resultFRUP[0].box__Folder_ID__c, 'The box folder id returned is not as expected');
    }
}