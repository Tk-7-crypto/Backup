@isTest
private class TST_SLT_StudySiteContactRelationship {
    /**
    * This method is used to setup data for all methods.
    */
    @testSetup
    static void dataSetup() {
        Account acc = CSM_Util.createRDAccount();
        insert acc;
        Account acc1 = CSM_Util.createRDAccount();
        insert acc1;
        Contact cnt = CSM_Util.createContact(acc.Id,'CaseTestContact');
        insert cnt;
        
    }
    
    /**
    * This test method used for insert and update Case record
    */ 
    static testMethod void testAuditforStudySiteRelationship() {
        CNT_CSM_FieldHistoryTracking.saveFields('Study_Contact_Relationship__c','AccessStatus__c,Contact__c,ContactEmail__c,ContactJobTitle__c,ContactRole__c,CurrencyIsoCode,RecordTypeId,SendEmailUpdates__c,Status__c,Study__c,StudyID__c,StudyTherapeuticArea__c,SystemModstamp,UserGroup__c,UserTrainedDate__c');
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'CaseRDTestAccount' LIMIT 1];
        Account acc1 = [SELECT Id, Name FROM Account WHERE Name = 'CaseRDTestAccount' LIMIT 1];
        Contact cnt = [SELECT Id, Name FROM Contact WHERE Name = 'CaseTestContact CaseTestContact' LIMIT 1];
        Contact cnt2 = CSM_Util.createContact(acc.Id,'CaseTestContact2');
        insert cnt2;
        Study__c study = CSM_Util.createStudy(acc.Id);
        insert study;
        Study_Contact_Relationship__c contactR = CSM_Util.createStudyContactRelationship(study.Id ,cnt.Id);
        
        Test.startTest();
        insert contactR;
        new SLT_StudySiteContactRelationship().selectByStudySiteContactRelationshipId(new Set<Id>{contactR.Id}, new Set<String>{'Id','Name'});
        
        Test.stopTest();
    }
}