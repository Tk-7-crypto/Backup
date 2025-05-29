@isTest
private class TST_DAOH_StudySiteContactRelationship {
    /**
* This method is used to setup data for all methods.
*/
    @testSetup
    static void dataSetup() {
        Account acc = CSM_Util.createAccount();
        insert acc;
        Account acc1 = CSM_Util.createAccount();
        insert acc1;
        Contact cnt = CSM_Util.createContact(acc.Id,'CaseTestContact');
        insert cnt;
        
    }
    
    /**
* This test method used for insert and update StudySiteRelationship record
*/ 
    static testMethod void testAuditforStudySiteRelationship() {
        CNT_CSM_FieldHistoryTracking.saveFields('StudySiteContactRelationship__c','Access_Status__c,Comment__c,Contact_Role__c,ContactEmail__c,ContactJobTitle__c,CurrencyIsoCode,Investigator_Name__c,Lab_Site_Number__c,LOS__c,SendEmailUpdates__c,Site_Name__c,SiteNumber__c,Status__c,Study__c,Study_Therapeutic_Area__c,User_Group__c,UserTrainedDate__c');
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'CaseTestAccount' LIMIT 1];
        Account acc1 = [SELECT Id, Name FROM Account WHERE Name = 'CaseTestAccount' LIMIT 1];
        Contact cnt = [SELECT Id, Name FROM Contact WHERE Name = 'CaseTestContact CaseTestContact' LIMIT 1];
        Contact cnt1 = CSM_Util.createContact(acc.Id,'CaseTestContact2');
        insert cnt1;
        Account acc2 = CSM_Util.createRDAccount();
        insert acc2;
        Study__c study = CSM_Util.createStudy(acc2.Id);
        insert study;
        StudySiteContactRelationship__c siteConR=new StudySiteContactRelationship__c(Study__c = study.Id,Investigator_Name__c = cnt.Id,Site_Name__c = acc.Id);
        siteConR.SiteNumber__c = 'SSCN123123';
        
        Test.startTest();
        insert siteConR;
        
        siteConR.Status__c = 'Priority';
        siteConR.Comment__c ='Added Comment';
        siteConR.SendEmailUpdates__c = true;
        siteConR.Contact_Role__c = 'QI Contact';
        siteConR.Access_Status__c='Not requested';
        siteConR.Investigator_Name__c = cnt1.Id;
        siteConR.Site_Name__c = acc1.Id;
        siteConR.SiteNumber__c = 'SITE01';
        siteConR.Lab_Site_Number__c = 'LABSITE01';
        update siteConR;
        siteConR.Access_Status__c='Requested';
        siteConR.Comment__c ='Added Comment 1';
        siteConR.Status__c = 'Standard';
        siteConR.SendEmailUpdates__c = false;
        siteConR.Contact_Role__c = 'Clinical Contact';
        siteConR.Investigator_Name__c = cnt.Id;
        siteConR.Site_Name__c = acc.Id;
        siteConR.SiteNumber__c = 'SITE02';
        siteConR.Lab_Site_Number__c = 'LABSITE02';
        update siteConR;
        Test.stopTest();
    }
}