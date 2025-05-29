@isTest
private class TST_TGR_Study {
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
        update study;
        study.CRO__c = 'CRO Test R';
        study.ProjectCoordinator__c = null;
        study.ProjectInformation__c = 'ProjectInformation Test Update';
        study.Sponsor__c = acc1.Id;
        update study;
        study.CRO__c = 'CRO Test Update1';
        study.ProjectInformation__c = '';
        study.Sponsor__c = acc1.Id;
        update study;
        Test.stopTest();
    }
}