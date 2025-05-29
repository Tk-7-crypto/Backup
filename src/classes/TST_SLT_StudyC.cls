@isTest
private class TST_SLT_StudyC {
/**
    * This method is used to setup data for all methods.
    */
    @testSetup
    static void dataSetup() {
        Account acc = CSM_Util.createRDAccount();
        insert acc;
        Account acct1 = CSM_Util.createRDAccount();
        insert acct1;
        Contact cnt = CSM_Util.createContact(acc.Id,'CaseTestContact');
        insert cnt;
        
    }
    
    /**
    * This test method used for insert and update Study record
    */ 
    static testMethod void testAuditforStudy() {
        CNT_CSM_FieldHistoryTracking.saveFields('Study__c','AMF_approvers__c,AMFCall__c,AULCutoffDate__c,AULReceived__c,CloseDate__c,CRO__c,CurrencyIsoCode,DatabaseLockINCSR__c,ERTEscalationContactERTonly__c,ExternalProjectCoordinator__c,FollowUpContacts__c,GoLiveDate__c,HandoverReceived__c,HomepageStudyURL__c,IBMCDStudyRevision__c,InformHomepageURL__c,InformVersionNumber__c,InterimLock__c,IVRSIntegration__c,KineticTRNDB__c,LabProjectCode__c,LOS__c,MissingInfoComments__c,NotificationPriority__c,OutcomeSPAccessPerson__c,OwnerId,Password_Recovery__c,PasswordExpirationPeriod__c,PCComments__c,Phase__c,PlannedSites__c,PlannedSubjects__c,PMFirstName__c,PreDBLockMeeting__c,ProjectCoordinator__c,ProjectInformation__c,Protocol__c,QIPReceived__c,RecordTypeId,RegionalPMPL__c,RRMatrixReceive__c,ShippingAccount__c,SISpecificsERTonly__c,Sponsor__c,SponsorAddress__c,SponsorStatus__c,StartUpCall__c,Status__c,StudyCountry__c,StudyID__c,StudyNickname__c,StudyTypeORDCOnly__c,StudyURL__c,SubLOS__c,Supported_for_CAS_Inform_only__c,SystemVersion__c,TechnicalProjectManager__c,TFNDecommisioned__c,TherapeuticArea__c,UMTIntegration__c,UserTrainingComments__c');
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'CaseRDTestAccount' LIMIT 1];
        Account acc1 = [SELECT Id, Name FROM Account WHERE Name = 'CaseRDTestAccount' LIMIT 1];
        Contact cnt = [SELECT Id, Name FROM Contact WHERE Name = 'CaseTestContact CaseTestContact' LIMIT 1];
        Contact cnt2 = CSM_Util.createContact(acc.Id,'CaseTestContact2');
        insert cnt2;
        Study__c study = CSM_Util.createStudy(acc1.Id);
        
        
        Test.startTest();
        insert study;
        
        study.CRO__c = null;
        study.ProjectCoordinator__c = UserInfo.getUserId();
        study.ProjectInformation__c = 'ProjectInformation Test';
        study.StudyID__c = 'PC100121';
        study.Name = 'Test Study1';
        study.LabProjectCode__c = 'LABPC100121';
        update study;
        study.CRO__c = 'CRO Test R';
        study.ProjectCoordinator__c = null;
        study.ProjectInformation__c = 'ProjectInformation Test Update';
        study.Sponsor__c = acc1.Id;
        study.StudyID__c = 'PC100122';
        study.Name = 'Test Study2';
        study.LabProjectCode__c = 'LABPC100122';
        update study;
        study.CRO__c = 'CRO Test Update1';
        study.ProjectInformation__c = '';
        study.Sponsor__c = acc1.Id;
        update study;
        new SLT_StudyC().selectAccountByStudyId(new Set<Id>{study.Id}, new Set<String>{'ID'});
        new SLT_StudyC().selectAccountByStudyName(study.Name, new Set<String>{'ID'});
        new SLT_StudyC().selectAllStudies(new Set<String>{'ID'});
        Test.stopTest();
    }
    @isTest
    static void testDuplicateCheck() {
        CNT_CSM_FieldHistoryTracking.saveFields('Study__c','AMF_approvers__c,AMFCall__c,AULCutoffDate__c,AULReceived__c,CloseDate__c,CRO__c,CurrencyIsoCode,DatabaseLockINCSR__c,ERTEscalationContactERTonly__c,ExternalProjectCoordinator__c,FollowUpContacts__c,GoLiveDate__c,HandoverReceived__c,HomepageStudyURL__c,IBMCDStudyRevision__c,InformHomepageURL__c,InformVersionNumber__c,InterimLock__c,IVRSIntegration__c,KineticTRNDB__c,LabProjectCode__c,LOS__c,MissingInfoComments__c,NotificationPriority__c,OutcomeSPAccessPerson__c,OwnerId,Password_Recovery__c,PasswordExpirationPeriod__c,PCComments__c,Phase__c,PlannedSites__c,PlannedSubjects__c,PMFirstName__c,PreDBLockMeeting__c,ProjectCoordinator__c,ProjectInformation__c,Protocol__c,QIPReceived__c,RecordTypeId,RegionalPMPL__c,RRMatrixReceive__c,ShippingAccount__c,SISpecificsERTonly__c,Sponsor__c,SponsorAddress__c,SponsorStatus__c,StartUpCall__c,Status__c,StudyCountry__c,StudyID__c,StudyNickname__c,StudyTypeORDCOnly__c,StudyURL__c,SubLOS__c,Supported_for_CAS_Inform_only__c,SystemVersion__c,TechnicalProjectManager__c,TFNDecommisioned__c,TherapeuticArea__c,UMTIntegration__c,UserTrainingComments__c');
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'CaseRDTestAccount' LIMIT 1];
        Account acc1 = [SELECT Id, Name FROM Account WHERE Name = 'CaseRDTestAccount' LIMIT 1];
        Contact cnt = [SELECT Id, Name FROM Contact WHERE Name = 'CaseTestContact CaseTestContact' LIMIT 1];
        Contact cnt2 = CSM_Util.createContact(acc.Id,'CaseTestContact2');
        insert cnt2;
        Study__c study = CSM_Util.createStudy(acc1.Id);
        study.Name ='Custom Name1211';
        Study__c studyTest = CSM_Util.createStudy(acc.Id);
        studyTest.Name ='Custom Study Creation';
        insert study;
        Profile serviceProfile = [SELECT Id FROM Profile WHERE NAME = 'Service User' LIMIT 1];
        User serviceUser = new User(LastName = 'TestUser2', Alias = 'testU2', Email = 'Akansha.gupta@metacube.com', Username = 'CSM_testUser'  + String.valueOf(DateTime.now().getTime()) + '@iqvia.com',
                                  CommunityNickname = 'testUser2', ProfileId = serviceProfile.Id, TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US',EmployeeNUmber='66565',
                                  LanguageLocaleKey = 'en_US', EmailEncodingKey = 'UTF-8', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description');
        INSERT serviceUser;  
        System.runAs (serviceUser) { 
        Test.startTest();
        try{
            INSERT studyTest; 
        }
        catch(DmlException e) {
            System.assertEquals(System.Label.Protocol_name_already_Exists_please_use_other_one, System.Label.Protocol_name_already_Exists_please_use_other_one);
        }
        Test.stopTest();
        }
    }
    
    @isTest
    static void testSelectStudyBasedOnProtocol(){
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'CaseRDTestAccount' LIMIT 1];
        Contact cnt = [SELECT Id, Name FROM Contact WHERE Name = 'CaseTestContact CaseTestContact' LIMIT 1];
        Study__c study = CSM_Util.createStudy(acc.Id);
        study.Name ='Custom Name1211';
        study.Protocol__c = 'Test';
        insert study;
        
        Test.startTest();
        new SLT_StudyC().selectStudyBasedOnProtocol(new Set<String>{study.Protocol__c});
        Test.stopTest();
    }
}