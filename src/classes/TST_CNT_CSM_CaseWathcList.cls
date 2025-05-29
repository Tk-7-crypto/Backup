@isTest
public class TST_CNT_CSM_CaseWathcList {
    @testSetup
    static void setup() {
        String profileName='System Administrator';
        Integer noOfUser = 10;
        List<User> userList = new List<User>();
        for(Integer index = 0; index < noOfUser; index++) {
            userList.add(new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name = :profileName].Id,
                LastName = 'lastName123',
                Email = 'testuser3133@iqvia.com',
                Username = 'testuser3133@imshealth.com' + System.currentTimeMillis(),
                CompanyName = 'TEST',
                Title = 'title',
                Alias = 'alia3133',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                Q1_Target__c = 1.0,
                Change_Request_Description__c = 'test',
                Change_Request_Ticket_Number__c ='test description',
                employeenumber= String.valueOf(System.currentTimeMillis()) + index
            ));
        }
        if(!userList.isEmpty()) insert userList;
        Account acct = new Account(Name = 'testSetupTestSiteAccount1', RDSponsor__c = true, RDClinicalSite__c = true, RDCategorization__c = 'Site', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert acct;
        
        Contact con = new Contact(FirstName = 'TestFirstName', Lastname = 'testSetupContact', Phone = '(619)852-4569', Department = 'Mission Control', 
            Title = 'Mission Specialist - Neptune', Email = 'testSetupcon@iqvia.com', AccountId = acct.Id, PreferredLanguage__c = 'en_US');
        insert con;
        
        Queue_User_Relationship__c queues1 = new Queue_User_Relationship__c();
        queues1.Name = 'Q1';
        queues1.QueueName__c = 'Q1';
        queues1.Type__c = 'Queue';
        queues1.User__c = UserInfo.getUserId(); 
        insert queues1;
        
        Queue_User_Relationship__c queueUser1 = new Queue_User_Relationship__c();
        queueUser1.Name = 'Q1';
        queueUser1.QueueName__c = 'Q1';
        queueUser1.Type__c = 'User';
        queueUser1.User__c = UserInfo.getUserId();
        insert queueUser1;

        Group gr = new Group();
        gr.Name = 'Q1';
        gr.Type = 'Queue';
        insert gr;
        Product2 p2 = new Product2(Name = 'Nexxus MI',Pillar__c = 'Technology Solutions',SpecificToCSM__c = True);
        insert p2;
        Asset a2 = new Asset(Name = 'Nexxus MI', AccountId = acct.Id, Product2Id = p2.id, Status ='Installed');
        insert a2;
        CSM_QI_Case_Categorization__c cc = new CSM_QI_Case_Categorization__c(
            Product__c= p2.Id,SubType1__c = 'Incident-Module', SubType2__c = 'Formularies',
            SubType3__c = '--none--', Active__c = true, Type__c = 'Categorization', Pillar__c = 'Technology Solutions');
            insert cc;
            
        Id recordTypeIdTechno = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
        Case cs = new Case();
        cs.ContactId = con.Id;
        cs.AccountId = acct.Id;
        cs.AssignCaseToCurrentUser__c = false;
        cs.OwnerId = UserInfo.getUserId();
        cs.RecordTypeId = recordTypeIdTechno;
        cs.Priority = 'Priority 4';
        cs.Origin = 'Customer Portal';
        cs.Mail_CC_List__c = 'nodata@info.com';
        cs.Subject = 'Techno Test case';
        cs.Description = 'Test class to check case creation ';
        cs.Status = 'New';
        cs.CurrentQueue__c = queueUser1.Id;
        cs.ProductName__c= 'Nexxus MI';
        cs.SubType1__c = 'Incident-Module';
        cs.SubType2__c = 'Formularies';  
        cs.SubType3__c = '--none--';
        insert cs;
        
        cs.Watch_List_User__c = userList[0].Id;
        update cs;
    }
    
    @IsTest
    private static void testSearchUser() {
        List<User> userlist = [SELECT Id FROM User WHERE User_License_Type__c = 'Salesforce' LIMIT 10];
        
        Test.startTest();
            List<CNT_CSM_CaseWathcList.UserQueueList> res = CNT_CSM_CaseWathcList.searchUserGroup('lastName123', 'user');
            List<CNT_CSM_CaseWathcList.UserQueueList> res2 = CNT_CSM_CaseWathcList.searchUserGroup('Q1', 'queue');
        Test.stopTest();
        //system.assertNotEquals(res[0].Id, userList[0].Id, 'User Found');
    }
    @IsTest
    private static void testGetCase() {
        Case cs = [SELECT Id FROM Case Limit 1];
        
        Test.startTest();
            Case c = CNT_CSM_CaseWathcList.getCase(cs.Id);
        Test.stopTest();
        //system.assertEquals(c.Id, cs.Id, 'Case Found');
    }
    
    @IsTest
    private static void testWatchUserList() {
        List<User> userlist = [SELECT Id FROM User WHERE User_License_Type__c = 'Salesforce' LIMIT 1];
        List<Group> grouplist = [SELECT Id FROM Group WHERE Type='Queue' LIMIT 1];
        
        Test.startTest();
            List<CNT_CSM_CaseWathcList.UserQueueList> res = CNT_CSM_CaseWathcList.watchUserList(userList[0].Id);
            List<CNT_CSM_CaseWathcList.UserQueueList> res2 = CNT_CSM_CaseWathcList.watchUserList(grouplist[0].Id);
        Test.stopTest();
        //system.assertEquals(1, res.size(), 'Same');
    }
    
    @IsTest
    private static void testUpdateWatchListUser() {
        List<User> userlist = [SELECT Id FROM User WHERE User_License_Type__c = 'Salesforce' LIMIT 2];
        Case cs = [SELECT Id FROM Case Limit 1];
        
        Test.startTest();
            Case c = CNT_CSM_CaseWathcList.updateWatchListUser(cs.Id,userList[0].Id,userList[1].Id);
        Test.stopTest();
        //system.assertEquals(c.Watch_List_User__c, userList[0].Id+','+userList[1].Id, 'Same');
    }
}