@isTest
private class TST_CNT_CSM_CloneChildCasesFromParent {
    
    @testSetup
    static void dataSetup() {
    List<Account> accList = new List<Account>();
        Account acct = new Account(Name = 'testSetupTestSiteAccount1',RDSponsor__c=true,RDClinicalSite__c=true,RDCategorization__c = 'Site', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        accList.add(acct);
        
        Account acct1 = new Account(Name = 'testSetupTestSiteAccount2',RDCategorization__c = 'Site', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        accList.add(acct1);
        Account acct2 = new Account(Name = 'testSetupTestSponsorAccount1',RDCategorization__c = 'Sponsor', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        accList.add(acct2);
        insert accList;
        Study__c study= new Study__c(Name = 'testSetupCaseTestStudy', Sponsor__c = acct2.Id);
        insert study;
        /* Added End */
        Contact con = new Contact(FirstName = 'testFirstName', Lastname='testSetupContact', Phone='(619)852-4569', Department='Mission Control', 
            Title='Mission Specialist - Neptune', Email='testSetupcon@iqvia.com', AccountId = acct.Id);
        insert con;
        
        List<Queue_User_Relationship__c> queueList = new List<Queue_User_Relationship__c>();
        Queue_User_Relationship__c queues = new Queue_User_Relationship__c();
        queues.Name = 'Q1';
        queues.QueueName__c = 'Q1';
        queues.Type__c = 'Queue';
        queues.User__c = UserInfo.getUserId();
        queueList.add(queues);
        
        Queue_User_Relationship__c queueUser = new Queue_User_Relationship__c();
        queueUser.Name = 'Q1';
        queueUser.QueueName__c = 'Q1';
        queueUser.Type__c = 'User';
        queueUser.User__c = UserInfo.getUserId();
        queueList.add(queueUser); 
        insert queueList;
        
        Id RecordTypeId1 = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Assistance Request Case').getRecordTypeId();
        Id RecordTypeIdCaseRD = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Activity Plan Case').getRecordTypeId();
        BusinessHours bHours1 = [select Id,Name,IsActive,IsDefault from BusinessHours where IsActive=true and name='Default' LIMIT 1];
        Entitlement ent1 = new Entitlement(Name='Testing', AccountId=acct.Id,Type = 'R&D',
                                          BusinessHoursId = bHours1.Id,
                                          StartDate=Date.valueof(System.now().addDays(-2)), 
                                          EndDate=Date.valueof(System.now().addYears(2)));
        
        List<Case> cList = new List<Case>();
        
        Study__c study1 = CSM_Util.createStudy(acct2.Id);
        study1.Name ='STUDY12';
        study1.StudyID__c ='PROJ0012';
        study1.LabProjectCode__c ='LABPROJ0012';
        insert study1;
        StudySiteContactRelationship__c siteConR1=new StudySiteContactRelationship__c(Study__c = study1.Id,Investigator_Name__c = con.Id,Site_Name__c = acct.Id);
        siteConR1.SiteNumber__c = 'SITE01';
        siteConR1.Lab_Site_Number__c = 'LABSITE01';
        insert siteConR1;
        List<Case> caseList = new List<Case>();
        Case cs1 = new Case(
            AccountId = acct.Id,
            ContactId = con.Id,
            Study__c =study1.Id,
            Site_Related_to_the_Study__c = siteConR1.Id,
            Sponsor__c = acct2.Id,
            CurrentQueue__c=queues.Id,
            Origin = 'Email',
            AssignCaseToCurrentUser__c = false,
            Status = 'New',
            Subject = 'Activity Plan Case',
            RandD_Location__c = 'Dalian',
            InitialQueue__c = 'Q1',
            RnD_Email_Flag__c = true,
            OwnerId = UserInfo.getUserId(),
            EntitlementId = ent1.Id,
            AFU_Email_Addresses__c = 'testmail@mailer.com; noreply@mailer.com',
            RecordTypeId = RecordTypeId1
        );
        caseList.add(cs1);
        
        Case csActivityPlan = new Case(
            AccountId = acct.Id,
            ContactId = con.Id,
            Study__c =study1.Id,
            Site_Related_to_the_Study__c = siteConR1.Id,
            Sponsor__c = acct2.Id,
            CurrentQueue__c=queues.Id,
            Origin = 'Email',
            AssignCaseToCurrentUser__c = false,
            Status = 'New',
            Subject = 'Parent Case',
            RandD_Location__c = 'Dalian',
            InitialQueue__c = 'Q1',
            OwnerId = UserInfo.getUserId(),
            EntitlementId = ent1.Id,
            RnD_Email_Flag__c = true,
            AFU_Email_Addresses__c = 'testmail@mailer.com; noreply@mailer.com',
            RecordTypeId = RecordTypeId1
        );
        
        caseList.add(csActivityPlan);
        
        Id RecordTypeIdCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Assistance Request Case').getRecordTypeId();
        Case csAssistanceRequest = new Case(
            AccountId = acct.Id,
            ContactId = con.Id,
            Study__c =study1.Id,
            Site_Related_to_the_Study__c = siteConR1.Id,
            Sponsor__c = acct2.Id,
            CurrentQueue__c=queues.Id,
            Origin = 'Email',
            AssignCaseToCurrentUser__c = false,
            Status = 'New',
            Subject = 'Assistance Request Case',
            RandD_Location__c = 'Dalian',
            InitialQueue__c = 'Q1',
            OwnerId = UserInfo.getUserId(),
            EntitlementId = ent1.Id,
            AFU_Email_Addresses__c = 'testmail@mailer.com; noreply@mailer.com',
            RnD_Email_Flag__c = true,
            RecordTypeId = RecordTypeIdCase
        );
        caseList.add(csAssistanceRequest);
        
        
        insert caseList;
    }
    
    static testmethod void testsearchParentCase(){
        Case cs = [Select id from Case LIMIT 1];
        CNT_CSM_CloneChildCasesFromParent.searchParentCase(cs.Id);
        List<Case> caseList = new SLT_Case().getCaseDetails(new List<String>{cs.Id});
        integer i = 1;
        CNT_CSM_CloneChildCasesFromParent.EXT_CSM_ChildCaseData data = null;
        List<CNT_CSM_CloneChildCasesFromParent.EXT_CSM_ChildCaseData> lstdata = new List<CNT_CSM_CloneChildCasesFromParent.EXT_CSM_ChildCaseData>();
        for(Case c : caseList){
            data = new CNT_CSM_CloneChildCasesFromParent.EXT_CSM_ChildCaseData();
            data.Id = i;
            data.caseNumber = '';
            data.contactId = c.ContactId;
            data.contactName = c.Contact.FirstName + ' '+c.Contact.LastName;
            data.siteName = c.Site_Related_to_the_Study__r.Name;
            data.sscId = c.Site_Related_to_the_Study__c;
            lstdata.add(data);
            i++;
        }
        CNT_CSM_CloneChildCasesFromParent.insertChildCases(cs.Id, JSON.serialize(lstdata));
    }

}