@IsTest
private class TST_CNT_CSM_StudySpecificInfoModal {
    @testSetup
    static void setup() {
        List<Account> accList = new List<Account>();
        Account acct = new Account(Name = 'testSetupTestSiteAccount1',RDSponsor__c=true,RDClinicalSite__c=true,RDCategorization__c = 'Site', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        accList.add(acct);
        
        Account acct1 = new Account(Name = 'testSetupTestSiteAccount2',RDCategorization__c = 'Site', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        accList.add(acct1);
        Account acct2 = new Account(Name = 'testSetupTestSponsorAccount1',RDCategorization__c = 'Sponsor', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        accList.add(acct2);
        insert accList;
        Study__c studyWithoutInfo = new Study__c(Name = 'studyWithoutInfo', Sponsor__c = acct2.Id);
        Study__c studyWithInfo = new Study__c(Name = 'studyWithInfo', Sponsor__c = acct2.Id, Study_Specific_Information__c = 'Test Info');
        List<Study__c> studyList = new List<Study__c>{studyWithoutInfo, studyWithInfo};
        insert studyList;
        
        Contact con = new Contact(Firstname = 'testFirstName', Lastname='testSetupContact', Phone='(619)852-4569', Department='Mission Control', 
            Title='Mission Specialist - Neptune', Email='testSetupcon@iqvia.com', AccountId = acct.Id);
        insert con;

        Queue_User_Relationship__c queues1 = new Queue_User_Relationship__c();
        queues1.Name ='Q1';
        queues1.QueueName__c ='Q1';
        queues1.Type__c ='Queue';
        queues1.User__c = UserInfo.getUserId(); 
        insert queues1;        
        
        Id RecordTypeId1 = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Activity Plan Case').getRecordTypeId();
        List<StudySiteContactRelationship__c> studySiteConList = new List<StudySiteContactRelationship__c>();
        StudySiteContactRelationship__c siteConR1 = new StudySiteContactRelationship__c(Study__c = studyWithInfo.Id, Investigator_Name__c = con.Id, Site_Name__c = acct.Id);
        siteConR1.SiteNumber__c = 'SITE01';
        siteConR1.Lab_Site_Number__c = 'LABSITE01';
        StudySiteContactRelationship__c siteConR2 = new StudySiteContactRelationship__c(Study__c = studyWithoutInfo.Id, Investigator_Name__c = con.Id, Site_Name__c = acct.Id);
        siteConR2.SiteNumber__c = 'SITE02';
        siteConR2.Lab_Site_Number__c = 'LABSITE02';
        studySiteConList.add(siteConR1);
        studySiteConList.add(siteConR2);
        insert studySiteConList;
        
        List<Case> caseList = new List<Case>();
        Case cs1 = new Case(
            AccountId = acct.Id,
            ContactId = con.Id,
            Study__c = studyWithInfo.Id,
            Site_Related_to_the_Study__c = siteConR1.Id,
            Sponsor__c = acct2.Id,
            CurrentQueue__c = queues1.Id,
            Origin = 'Email',
            AssignCaseToCurrentUser__c = false,
            Status = 'New',
            Subject = 'StudyWithInfo',
            RandD_Location__c = 'Dalian',
            InitialQueue__c = 'Q1',
            RnD_Email_Flag__c = true,
            OwnerId = UserInfo.getUserId(),
            AFU_Email_Addresses__c = 'testmail@mailer.com; noreply@mailer.com',
            RecordTypeId = RecordTypeId1
        );
        caseList.add(cs1);
        Case cs2 = new Case(
            AccountId = acct.Id,
            ContactId = con.Id,
            Study__c = studyWithoutInfo.Id,
            Site_Related_to_the_Study__c = siteConR2.Id,
            Sponsor__c = acct2.Id,
            CurrentQueue__c = queues1.Id,
            Origin = 'Email',
            AssignCaseToCurrentUser__c = false,
            Status = 'New',
            Subject = 'StudyWithoutInfo',
            RandD_Location__c = 'Dalian',
            InitialQueue__c = 'Q1',
            RnD_Email_Flag__c = true,
            OwnerId = UserInfo.getUserId(),
            AFU_Email_Addresses__c = 'testmail@mailer.com; noreply@mailer.com',
            RecordTypeId = RecordTypeId1
        );
        caseList.add(cs2);
        insert caseList;
    }
    
    @IsTest
    private static void testShowAlertForRNDShouldShow() {
        Case caseRecord = [SELECT Id FROM Case WHERE Subject = 'StudyWithInfo' LIMIT 1];
        Test.startTest();
            String caseAlertWrapperJSON = CNT_CSM_StudySpecificInfoModal.showAlertForRND(caseRecord.Id);
        Test.stopTest();
        CNT_CSM_StudySpecificInfoModal.CaseAlertWrapper caseAlertWrapper = (CNT_CSM_StudySpecificInfoModal.CaseAlertWrapper)JSON.deserialize(caseAlertWrapperJSON, CNT_CSM_StudySpecificInfoModal.CaseAlertWrapper.class);
        System.assertEquals(true, caseAlertWrapper.isShowAlert, 'Alert will be shown');
    }
    
    @IsTest
    private static void testShowAlertForRNDShouldNotShow() {
        Case caseRecord = [SELECT Id FROM Case WHERE Subject = 'StudyWithoutInfo' LIMIT 1];
        Test.startTest();
            String caseAlertWrapperJSON = CNT_CSM_StudySpecificInfoModal.showAlertForRND(caseRecord.Id);
        Test.stopTest();
        CNT_CSM_StudySpecificInfoModal.CaseAlertWrapper caseAlertWrapper = (CNT_CSM_StudySpecificInfoModal.CaseAlertWrapper)JSON.deserialize(caseAlertWrapperJSON, CNT_CSM_StudySpecificInfoModal.CaseAlertWrapper.class);
        System.assertEquals(false, caseAlertWrapper.isShowAlert, 'Alert will not be shown');
    }
}