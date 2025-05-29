@isTest
private class TST_TGR_StudySiteRelationship {
    /**
    * This method is used to setup data for all methods.
    */
    @testSetup
    static void dataSetup() {
        Account acc  =  CSM_Util.createAccount();
        insert acc;
        Account acc1  =  CSM_Util.createRDAccount();
        insert acc1;
        Contact cnt  =  CSM_Util.createContact(acc.Id,'CaseTestContact');
        insert cnt;
        
    }

    /**
    * This test method used for insert and update Case record
    */ 
    static testMethod void testAuditforStudySiteRelationship() {
        CNT_CSM_FieldHistoryTracking.saveFields('Study_Site_Relationship__c','Comment__c,CurrencyIsoCode,KeyContacts__c,LOS__c,RecordTypeId,Site__c,SiteNumber__c,SpecificLocationDetails__c,Status__c,Study__c,StudyTherapeuticArea__c,SystemModstamp');
        Account acc  =  [SELECT Id, Name FROM Account WHERE Name  =  'CaseTestAccount' LIMIT 1];
         Account acc1  =  [SELECT Id, Name FROM Account WHERE Name  =  'CaseRDTestAccount' LIMIT 1];
        Contact cnt  =  [SELECT Id, Name FROM Contact WHERE Name  =  'CaseTestContact CaseTestContact' LIMIT 1];
        Contact cnt2  =  CSM_Util.createContact(acc.Id,'CaseTestContact2');
        insert cnt2;
        Study__c study = CSM_Util.createStudy(acc1.Id);
        insert study;
         Study_Site_Relationship__c siteR = CSM_Util.createStudySiteRelationship(acc.Id,study.Id ,cnt.Id);
        
        Test.startTest();
        insert siteR;

        siteR.Comment__c = 'Test Comment';
        siteR.KeyContacts__c = cnt2.Id;
        siteR.Status__c = 'In-Active';
        siteR.LOS__c = 'LOS Test';
        siteR.SpecificLocationDetails__c = 'Specific Location Details';
        update siteR;
        siteR.Comment__c = null;
        siteR.KeyContacts__c = null;
        siteR.Status__c = 'Active';
        siteR.LOS__c = 'LOS Test 1';
        siteR.SpecificLocationDetails__c = 'Specific Location Details 1';
           update siteR;
        siteR.LOS__c = null;
         siteR.KeyContacts__c = cnt.Id;
        siteR.SpecificLocationDetails__c = 'Specific Location Details 1';
           update siteR;        
       
        Test.stopTest();
    }
}