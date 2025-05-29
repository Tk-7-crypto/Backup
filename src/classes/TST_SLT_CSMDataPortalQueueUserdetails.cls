@isTest
private class TST_SLT_CSMDataPortalQueueUserdetails {
    @IsTest
    static void testCSMDataPortal() {
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        String profilId2 = [select id from Profile where Name='System Administrator'].Id;
        User accOwner = New User(Alias = 'su',UserRoleId= portalRole.Id, ProfileId = profilId2, Email = 'john2@iqvia.com',IsActive =true ,Username ='john2@iqvia.com', LastName= 'testLastName', CommunityNickname ='testSuNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description');
        accOwner.EmployeeNumber = String.valueOf(System.currentTimeMillis());
        insert accOwner;
        
        System.runAs (accOwner) {
            Account acct = new Account(Name = 'testSetupTestSiteAccount1',RDSponsor__c=true,RDClinicalSite__c=true,RDCategorization__c = 'Site',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
            insert acct;
            Contact con = new Contact( FirstName = 'TestFirstName', Lastname='testSetupContact', Phone='(619)852-4569', Department='Mission Control', 
                                      Title='Mission Specialist - Neptune', Email='testSetupcon@iqvia.com', AccountId = acct.Id,PreferredLanguage__c = 'en_US');
            insert con;
            Product2 p1 = UTL_TestData.createProduct();
            p1.Name = 'Nexxus MI';
            p1.SpecificToCSM__c = True;
            insert p1;
            Group g1 = new Group(Name='group name', type='Queue',DoesSendEmailToMembers = true, Email ='testQueue@iqvia.com');
            insert g1;
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case');
            insert q1;
            
            GroupMember grpUser = new GroupMember (
                UserOrGroupId = accOwner.Id,
                GroupId = g1.Id);
            
            insert grpUser;
            
            Queue_User_Relationship__c qur = new Queue_User_Relationship__c(
                Name = grpUser.group.Name,
                User__c = grpUser.UserOrGroupId,
                Type__c = 'Queue',
                Group_Id__c = grpUser.groupId);
            
            insert qur;
            
            CSM_QI_Data_Portal_Queue_User_details__c dT = new CSM_QI_Data_Portal_Queue_User_details__c();
            dT.Queue_User_Relationship__c = qur.Id;
            dT.Account__c = acct.Id;
            dT.All_Current_Users__c = true;
            dT.CaseRecordType__c = 'TechnologyCase';
            dT.Type__c ='Queue Assignment';
            dT.Order__c = 1;
            insert dT;
            
            SLT_CSMDataPortalQueueUserdetails ud = new SLT_CSMDataPortalQueueUserdetails();
            ud.selectById(new Set<Id>{dT.Id});
            ud.getDataWithFilter(new Set<String>{'Id'}, 'Account__c =\''+acct.Id+'\'');
        }
    }
    
}