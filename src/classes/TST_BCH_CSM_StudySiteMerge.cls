@IsTest
private class TST_BCH_CSM_StudySiteMerge {
    @testSetup
    static void setup() {
        List<Account> accList = new List<Account>();
        Account acct = new Account(Name = 'testSetupTestSiteAccount1', RDSponsor__c = true, RDClinicalSite__c = true, RDCategorization__c = 'Site',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        accList.add(acct);
        Account acct1 = new Account(Name = 'testSetupTestSiteAccount2', RDCategorization__c = 'Site',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        accList.add(acct1);
        Account acct2 = new Account(Name = 'testSetupTestSponsorAccount1', RDCategorization__c = 'Sponsor',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        accList.add(acct2);
        insert accList;
        
        Study__c study = new Study__c(Name = 'testSetupCaseTestStudy', Sponsor__c = acct2.Id);
        insert study;
        
        Queue_User_Relationship__c queues1 = new Queue_User_Relationship__c();
        queues1.Name = 'Q1';
        queues1.QueueName__c = 'Q1';
        queues1.Type__c = 'Queue';
        queues1.User__c = UserInfo.getUserId(); 
        insert queues1;
        
        Contact con = new Contact( FirstName = 'TestFirstName', Lastname = 'testSetupContact', Phone = '(619)852-4569', Department = 'Mission Control', 
                                  Title = 'Mission Specialist - Neptune', Email = 'testSetupcon@iqvia.com', AccountId = acct.Id, PreferredLanguage__c = 'en_US');
        insert con;
        
        Study__c study1 = CSM_Util.createStudy(acct2.Id);
        study1.Name = 'STUDY12';
        study1.StudyID__c = 'PROJ0012';
        study1.LabProjectCode__c = 'LABPROJ0012';
        insert study1;
        
        Id RecordTypeId1 = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Activity Plan Case').getRecordTypeId();
        
        StudySiteContactRelationship__c siteConR1 = new StudySiteContactRelationship__c(Study__c = study1.Id, Investigator_Name__c = con.Id, Site_Name__c = acct.Id);
        siteConR1.SiteNumber__c = 'SITE01';
        siteConR1.Lab_Site_Number__c = 'LABSITE01';
        insert siteConR1;
        
        StudySiteContactRelationship__c siteConR2 = new StudySiteContactRelationship__c(Study__c = study1.Id, Investigator_Name__c = con.Id, Site_Name__c = acct.Id);
        siteConR2.SiteNumber__c = 'SITE01';
        siteConR2.Lab_Site_Number__c = 'LABSITE02';
        siteConR2.Is_Survivor__c = true;
        insert siteConR2;      
        
        Case rndCase = new Case(
            AccountId = acct.Id,
            ContactId = con.Id,
            Study__c = study1.Id,
            Site_Related_to_the_Study__c = siteConR1.Id,
            Sponsor__c = acct2.Id,
            CurrentQueue__c = queues1.Id,
            Origin = 'Email',
            AssignCaseToCurrentUser__c = false,
            Status = 'New',
            Subject = 'Activity Plan Case',
            RandD_Location__c = 'Dalian',
            InitialQueue__c = 'Q1',
            RnD_Email_Flag__c = true,
            OwnerId = UserInfo.getUserId(),
            AFU_Email_Addresses__c = 'testmail@mailer.com; noreply@mailer.com',
            RecordTypeId = RecordTypeId1
        );  
        insert rndCase;
    }
    
    @IsTest
    private static void testStudySiteMergeBatch() {
        Case caseRecord = [SELECT Id, Site_Related_to_the_Study__c FROM Case WHERE Subject = 'Activity Plan Case' LIMIT 1];
        
        Test.startTest();
        
            BCH_CSM_StudySiteMerge bch = new BCH_CSM_StudySiteMerge();
            Database.executeBatch(bch, 1);
        
        Test.stopTest();
        
        Case updatedCase = [SELECT Id, Site_Related_to_the_Study__c FROM Case WHERE Id =: caseRecord.Id];
        List<StudySiteContactRelationship__c> siteConR = [SELECT Id FROM StudySiteContactRelationship__c WHERE Id =: caseRecord.Site_Related_to_the_Study__c];
        
        System.assertEquals(true, updatedCase.Site_Related_to_the_Study__c != caseRecord.Site_Related_to_the_Study__c, 'Case should be updated with survivor study site relationship');
        System.assertEquals(true, siteConR.size() == 0 , 'Non survivor records should be deleted');
    }
}