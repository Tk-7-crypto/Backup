@isTest
public class TST_Flow_Document_Version {
    
    @testSetup
    static void dataSetup() { 
        
        Account account = new Account(Name = 'IMS Health Global',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert account;
        
        Contact contact = new Contact(FirstName='test', Email='test@gmail.com', LastName ='lastname');
        contact.Account = account;
        contact.EmployeeNumber__c = '123456789';
        contact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('IQVIA_User_Contact').getRecordTypeId();
        insert contact;
    
        Apttus__APTS_Agreement__c testAgreementRWLP = TST_CLM_TestDataFactory.createAgreement(CON_CLM.RWLP_RECORDTYPEID, false);
        testAgreementRWLP.Name = 'Test Agreement RWLP';
        testAgreementRWLP.IQVIA_Project_Manager_Con__c = contact.Id;
        insert testAgreementRWLP;
        
        Apttus__DocumentVersion__c dvRWLP = new Apttus__DocumentVersion__c();
        dvRWLP.Name = 'Test 123';
        dvRWLP.Apttus__AgreementId__c = testAgreementRWLP.Id;
        dvRWLP.Apttus__LatestVersion__c = '1.0.0';
        dvRWLP.Apttus__Title__c = 'Test';
        dvRWLP.Apttus__LatestReviewCycleStatus__c = 'Not Started';
        insert dvRWLP;
        
        Apttus__DocumentVersionDetail__c dvdRWLP = new Apttus__DocumentVersionDetail__c();
        dvdRWLP.Name = 'TestName';
        dvdRWLP.Apttus__DocumentVersionId__c = dvRWLP.Id;
        dvdRWLP.Apttus__Title__c ='TestTitle';
        dvdRWLP.Apttus__VersionMajor__c = 1;
        dvdRWLP.Apttus__VersionMinor__c = 0;
        dvdRWLP.Apttus__VersionRevision__c = 0;
        insert dvdRWLP;
        
        dvRWLP.Apttus__LatestVersionId__c = dvdRWLP.Id;
        update dvRWLP;
        
        Apttus__APTS_Agreement__c testAgreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        testAgreement.Name = 'Test Agreement';
        testAgreement.IQVIA_Project_Manager_Con__c = contact.Id;
        insert testAgreement;
        
        Apttus__DocumentVersion__c dv = new Apttus__DocumentVersion__c();
        dv.Name = 'Test ABC';
        dv.Apttus__AgreementId__c = testAgreement.Id;
        dv.Apttus__LatestVersion__c = '1.0.0';
        dv.Apttus__Title__c = 'Test';
        dv.Apttus__LatestReviewCycleStatus__c = 'In Progress';
        insert dv;
        
        Apttus__DocumentVersionDetail__c dvd = new Apttus__DocumentVersionDetail__c();
        dvd.Name = 'TestName1';
        dvd.Apttus__DocumentVersionId__c = dv.Id;
        dvd.Apttus__Title__c ='TestTitle';
        dvd.Apttus__VersionMajor__c = 1;
        dvd.Apttus__VersionMinor__c = 0;
        dvd.Apttus__VersionRevision__c = 0;
        insert dvd;
        
        dv.Apttus__LatestVersionId__c = dvd.Id;
        update dv;
    }
    
    @isTest
    private static void testDocVersionUpdateReviewerCycleSubflow() {
        Apttus__DocumentVersionDetail__c dvdRWLP = [Select Id,Apttus__DocumentVersionId__c,Apttus__DocumentVersionId__r.Apttus__AgreementId__c From Apttus__DocumentVersionDetail__c where Name ='TestName' Limit 1];
                
        Apttus__ReviewCycle__c reviewCycle = new Apttus__ReviewCycle__c();
        reviewCycle.Apttus__ReviewStatus__c = 'In Progress';
        reviewCycle.Name = 'Test Review cycle';
        reviewCycle.Apttus__OriginalDocumentVersionDetail__c = dvdRWLP.Id;
		insert reviewCycle;
        
        Apttus__Reviewer__c reviewer = new Apttus__Reviewer__c();
        reviewer.Name = 'Test reviewer';
        reviewer.Apttus__ReviewStatus__c = 'In Progress';
        reviewer.Apttus__ReviewCycle__c = reviewCycle.id;
        reviewer.Apttus__ReviewerEmail__c = 'abcd@gmail.com';
        insert reviewer;
        
        Apttus__DocumentVersion__c dv = new Apttus__DocumentVersion__c(Id = dvdRWLP.Apttus__DocumentVersionId__c);
        dv.Apttus__LatestReviewCycleStatus__c = null;
        
        Test.startTest();
            update dv;
            dv.Apttus__LatestReviewCycleStatus__c = 'Not Started';
            update dv;
        Test.stopTest(); 
        
        Apttus__APTS_Agreement__c agreement = [SELECT Apttus__Status__c FROM Apttus__APTS_Agreement__c WHERE Id = : dvdRWLP.Apttus__DocumentVersionId__r.Apttus__AgreementId__c];
        System.assertEquals(dv.Apttus__LatestReviewCycleStatus__c, 'Not Started', 'Status not updated correctly');
        System.assertEquals('Internal Review', agreement.Apttus__Status__c, 'Status update done successfully');
    }
    
    @isTest
    private static void testDocVersionUpdateCompleteReviewCycleSubflow() {
        Apttus__DocumentVersionDetail__c dvdRWLP = [Select Id,Apttus__DocumentVersionId__c From Apttus__DocumentVersionDetail__c where Name ='TestName' Limit 1];
        
        Apttus__ReviewCycle__c reviewCycle = new Apttus__ReviewCycle__c();
        reviewCycle.Apttus__ReviewStatus__c = 'Completed';
        reviewCycle.Name = 'Test Review cycle';
        reviewCycle.Apttus__OriginalDocumentVersionDetail__c = dvdRWLP.Id;
		insert reviewCycle;
        
        Apttus__Reviewer__c reviewer = new Apttus__Reviewer__c();
        reviewer.Name = 'Test reviewer';
        reviewer.Apttus__ReviewStatus__c = 'Completed';
        reviewer.Apttus__ReviewCycle__c = reviewCycle.id;
        reviewer.Apttus__ReviewerEmail__c = 'abcd@gmail.com';
        insert reviewer;
        
        Apttus__DocumentVersion__c dv = new Apttus__DocumentVersion__c(Id = dvdRWLP.Apttus__DocumentVersionId__c);
        dv.Apttus__LatestReviewCycleStatus__c = 'Completed';
        
        Test.startTest();
            update dv;
        Test.stopTest(); 
        
        System.assertEquals(dv.Apttus__LatestReviewCycleStatus__c, 'Completed', 'Status not updated correctly');
    }
    
    @isTest
    private static void testDocVersionCompleteReviewCycleForAllRctypes() {
        Apttus__DocumentVersionDetail__c dvd = [Select Id,Apttus__DocumentVersionId__c From Apttus__DocumentVersionDetail__c where Name ='TestName1' Limit 1];
        
        Apttus__DocumentVersion__c dv = new Apttus__DocumentVersion__c(Id = dvd.Apttus__DocumentVersionId__c);
        dv.Apttus__LatestReviewCycleStatus__c = 'Completed';
        
        Test.startTest();
            update dv;
        Test.stopTest(); 
        
        System.assertEquals(dv.Apttus__LatestReviewCycleStatus__c, 'Completed', 'Status should be completed');
    }
}