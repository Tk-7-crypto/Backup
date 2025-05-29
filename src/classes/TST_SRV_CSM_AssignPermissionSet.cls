@isTest
private class TST_SRV_CSM_AssignPermissionSet {
    
    @testSetup
    static void dataSetup() {
        Group g2 = new Group(Name='Q1', type='Queue',DoesSendEmailToMembers = true, Email ='testQueue2@iqvia.com');
        insert g2;
        QueuesObject q2 = new QueueSObject(QueueID = g2.id, SobjectType = 'Case');
        insert q2;
        GroupMember grpUser2 = new GroupMember (UserOrGroupId = UserInfo.getUserId(), GroupId = g2.Id);
        insert grpUser2;
        
    }
    static testMethod void testCreateAssignPermissionSetToUser() {
        
        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE PortalType = 'None' LIMIT 1];
        Profile profile_1 = [SELECT Id FROM Profile WHERE Name = 'CSM Customer Community Plus Login User' LIMIT 1];
        //User admin = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId = :userRole_1.Id LIMIT 1];
        User user_1;
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        
        String profilId2 = [select id from Profile where Name='System Administrator'].Id;
        User admin = New User(Alias = 'su',UserRoleId= portalRole.Id, ProfileId = profilId2, Email = 'john2@iqvia.com',IsActive =true ,Username ='john2@iqvia.com', LastName= 'testLastName', CommunityNickname ='testSuNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description', EmployeeNumber ='08080808');
        insert admin;
        System.runAs(admin) {
            Account account_1 = new Account( Name = 'Community',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
            insert account_1;
            
            Contact contact_1 =  new Contact( 
            Firstname='Brian', 
            Lastname='Dent', 
            Phone='(619)852-4569', 
            Department='Mission Control', 
            Title='Mission Specialist - Neptune', 
            Email='yourusername@iqvia.com',
            Portal_Case_Type__c = 'Technology Solutions',
            Contact_User_Type__c='HO User',
            AccountId = account_1.Id);
            insert contact_1;
            Queue_User_Relationship__c qurPortal = new Queue_User_Relationship__c(Name = 'Q1',User__c = UserInfo.getUserId(),Type__c = 'Queue');
            insert qurPortal;
            CSM_QI_Data_Portal_Queue_User_details__c dT = new CSM_QI_Data_Portal_Queue_User_details__c();
            dT.Queue_User_Relationship__c = qurPortal.Id;
            dT.Account__c = account_1.Id;
            dT.All_Current_Users__c = true;
            dT.CaseRecordType__c = 'TechnologyCase';
            dT.Type__c ='Queue Assignment';
            dT.Order__c = 1;
            insert dT;
            CSM_QI_Data_Portal_Queue_User_details__c dd = new CSM_QI_Data_Portal_Queue_User_details__c();
            dd.Queue_User_Relationship__c = qurPortal.Id;
            dd.Account__c = account_1.Id;
            dd.All_Current_Users__c = true;
            dd.CaseRecordType__c = 'DATACase';
            dd.Type__c ='Queue Assignment';
            dd.Order__c = 1;
            insert dd;
            user_1 = new User( 
                Email = 'yourusername@iqvia.com',
                ProfileId = profile_1.Id, 
                UserName = 'yourusername@gmail.com', 
                Alias = 'Test',
                TimeZoneSidKey = 'America/New_York',
                EmailEncodingKey = 'ISO-8859-1',
                LocaleSidKey = 'en_US', 
                LanguageLocaleKey = 'en_US',
                ContactId = contact_1.Id,
                PortalRole = 'Manager',
                FirstName = 'Firstname',
                LastName = 'Lastname',
                EmployeeNumber ='080808081'
            );
            insert user_1;
            contact_1.AccessToAllCasesOfTheAccou__c = true;
            update contact_1;
            contact_1.AccessToAllCasesOfTheAccou__c = false;
            update contact_1;
            Group g = [Select id from Group limit 1];
            SRV_CSM_AssignPermissionSet.createQueueUserRelationshipToActiveUser(new List<String>{g.Id});
        }
        
    }
    private class Mir3Mock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'your Json Response';

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    
    @isTest
    static void testTechValidationForAllPillar(){
        Test.setMock(HttpCalloutMock.class, new Mir3Mock());

        CSM_ExternalClient_info__c eci = new CSM_ExternalClient_info__c(Name='Mir3',Client_Url__c = 'http://www.mir3.com/ws', Password__c='pwd', UserName__c='User', client_secret__c ='15-15',Client_Certificate__c='CSM Digital Engagement');
        insert eci;
        Account acct = new Account(Name = 'testSetupTestSiteAccount1',RDSponsor__c=true,RDClinicalSite__c=true, AccountCountry__c = CON_CSM.S_USA_CODE, RDCategorization__c = 'Site',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert acct;
        Contact con = new Contact( FirstName = 'TestFirstName', Lastname='testSetupContact', Phone='(619)852-4569', Department='Mission Control', 
            Title='Mission Specialist - Neptune', Email='testSetupcon@iqvia.com', AccountId = acct.Id,PreferredLanguage__c = 'en_US');
        insert con;
        Id recordTypeIdTech = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
        
        Product2 p2 = new Product2(Name = 'GTN - Data Hub',Pillar__c = 'Technology Solutions',SpecificToCSM__c = True);
        insert p2;
        CSM_QI_Case_Categorization__c cc = new CSM_QI_Case_Categorization__c(Product__c= p2.Id,SubType1__c = 'Incident-Module',SubType2__c = 'Formularies',  
        SubType3__c = '--none--',Active__c = true,Type__c = 'Categorization',Pillar__c = 'Technology Solutions');
        insert cc;
        Asset a3 = new Asset(Name = 'GTN - Data Hub', AccountId = acct.Id, Product2Id = p2.id, Status ='Installed');
        insert a3;
            Queue_User_Relationship__c queueRecord = new Queue_User_Relationship__c();
            queueRecord.Name = 'Q1';
            queueRecord.QueueName__c = 'Q1';
            queueRecord.Type__c = 'Queue';
            queueRecord.AFU_Queue_Email__c = 'metacubeuser@gmail.com';
            insert queueRecord;
            Queue_User_Relationship__c queueUserRecord = new Queue_User_Relationship__c();
            queueUserRecord.Name = 'Q1';
            queueUserRecord.QueueName__c = 'Q1';
            queueUserRecord.Type__c = 'User';
            queueUserRecord.User__c = UserInfo.getUserId();
            queueUserRecord.AFU_Queue_Email__c = 'metacubeuser@gmail.com';
            insert queueUserRecord;
            Queue_User_Relationship__c techQueueUserRecord = new Queue_User_Relationship__c();
            techQueueUserRecord.Name = 'Q1';
            techQueueUserRecord.QueueName__c = 'Q1';
            techQueueUserRecord.Type__c = 'User';
            techQueueUserRecord.User__c = userinfo.getUserId();
            techQueueUserRecord.AFU_Queue_Email__c = 'metacubeuser@gmail.com';
            insert techQueueUserRecord;
            
            Case c = new Case(
                AccountId = acct.Id,
                ContactId = con.Id,
                AssetId = a3.Id,
                ProductName__c = 'GTN - Data Hub',
                SubType1__c = 'Incident-Module',
                SubType2__c = 'Formularies',  
                SubType3__c = '--none--',
                Status = 'New',
                Urgency__c = 'High',
                Techno_Impact__c = 'Significant',
                Origin = CON_CSM.S_CUSTOMER_PORTAL,
                CaseSource__c = CON_CSM.S_CUSTOMER,
                InitialQueue__c = 'Q1',
                CurrentQueue__c = queueUserRecord.Id,
                RecordTypeId = recordTypeIdTech,
                Subject = 'Test Subject 1',
                Description = 'Test Description 1',
                Milestone_Violation__c = true,
                CaseOriginatorName__c = CON_CSM.S_RESOLUTION_FAILD
            );
        insert c;

        Case cs = [select Id,CaseOriginatorName__c From Case limit 1];
        Activity__c act = new Activity__c();
        act.Case__c = cs.Id;
        act.Contact__c = con.Id;
        act.Site__c = acct.Id; 
        act.Type__c = CON_CSM.S_EMAILOUTBOUND;
        act.Description__c = 'Test';
        act.StartDatetime__c = System.now();
        act.ActivityOwner__c = UserInfo.getUserId();
        act.RecordTypeId = CON_CSM.S_ACTIVITY_RT;
        SRV_CSM_AssignPermissionSet.createActivityFromEmailMessage(JSON.serialize(new List<Activity__c>{act}));
        SRV_CSM_AssignPermissionSet.updateMilestoneVilotaion(new List<Id> {cs.Id});
        SRV_CSM_AssignPermissionSet.completeMilestone(new List<Id> {cs.Id},new List<String>{CON_CSM.S_FIRST_RESPONSE_T,CON_CSM.S_PRODOPS_INITIAL_RESPONSE} , System.now());
        Test.startTest();
        cs.CaseOriginatorName__c = CON_CSM.S_INITIAL_RES_FAIL;
        update cs;
        SRV_CSM_AssignPermissionSet.updateMilestoneVilotaion(new List<Id> {cs.Id});
        System.assertEquals(CON_CSM.S_INITIAL_RES_FAIL, cs.CaseOriginatorName__c,'CaseOriginatorName updated');
        Test.stopTest();
        }
    
    @isTest
    static void testTechResolutionFailed(){
        Account acct = new Account(Name = 'testSetupTestSiteAccount1',RDSponsor__c=true,RDClinicalSite__c=true,RDCategorization__c = 'Site',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert acct;
        Contact con = new Contact( FirstName = 'TestFirstName', Lastname='testSetupContact', Phone='(619)852-4569', Department='Mission Control', 
            Title='Mission Specialist - Neptune', Email='testSetupcon@iqvia.com', AccountId = acct.Id,PreferredLanguage__c = 'en_US');
        insert con;
        Id recordTypeIdTech = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
        
        
            Queue_User_Relationship__c queueRecord = new Queue_User_Relationship__c();
            queueRecord.Name = 'Q1';
            queueRecord.QueueName__c = 'Q1';
            queueRecord.Type__c = 'Queue';
            queueRecord.AFU_Queue_Email__c = 'metacubeuser@gmail.com';
            insert queueRecord;
            Queue_User_Relationship__c queueUserRecord = new Queue_User_Relationship__c();
            queueUserRecord.Name = 'Q1';
            queueUserRecord.QueueName__c = 'Q1';
            queueUserRecord.Type__c = 'User';
            queueUserRecord.User__c = UserInfo.getUserId();
            queueUserRecord.AFU_Queue_Email__c = 'metacubeuser@gmail.com';
            insert queueUserRecord;
            Queue_User_Relationship__c techQueueUserRecord = new Queue_User_Relationship__c();
            techQueueUserRecord.Name = 'Q1';
            techQueueUserRecord.QueueName__c = 'Q1';
            techQueueUserRecord.Type__c = 'User';
            techQueueUserRecord.User__c = userinfo.getUserId();
            techQueueUserRecord.AFU_Queue_Email__c = 'metacubeuser@gmail.com';
            insert techQueueUserRecord;
            
            Case c = new Case(
                AccountId = acct.Id,
                ContactId = con.Id,
                Origin = 'Agent Initiated',
                Status = 'New',
                InitialQueue__c = 'Q1',
                CurrentQueue__c = queueUserRecord.Id,
                RecordTypeId = recordTypeIdTech,
                Subject = 'Test Subject 1',
                Description = 'Test Description 1',
                Milestone_Violation__c = true,
                CaseOriginatorName__c = CON_CSM.S_RESOLUTION_FAILD
            );
            insert c;
        Case cs = [select Id,CaseOriginatorName__c From Case limit 1];
        Test.startTest();
        cs.CaseOriginatorName__c = CON_CSM.S_RESOLUTION_FAILD;
        update cs;
        SRV_CSM_AssignPermissionSet.updateMilestoneVilotaion(new List<Id> {cs.Id});
        System.assertEquals(CON_CSM.S_RESOLUTION_FAILD, cs.CaseOriginatorName__c,'CaseOriginatorName updated');
        Test.stopTest();
        }
}