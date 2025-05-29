/*
 * Version       : 1.0
 * Description   : Test Class for SLT_User
 */ 
@isTest
private class TST_SLT_User {
    @testSetup
    static void dataSetup() {
        Account account1 = UTL_TestData.createAccount();
        insert account1;
        List<Contact> listOfCanotact = UTL_TestData.createContacts(account1.Id,1);
        insert listOfCanotact;
        
        
    }
    /**
     * This method used to get Asset by AccountId and Product2 ID
     */    
    @IsTest
    static void testSelectById() {
        List<User> users = new  List<User>();
        Account account_1 = new Account( Name = 'Community',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE'  );
        insert account_1;
        Contact contact_1 = new Contact(AccountId = account_1.Id,FirstName = 'TestFirstName', LastName = 'xgeek');
        insert contact_1;
        Test.startTest();
        users = new SLT_User().selectById(new Set<Id> {UserInfo.getUserId()});
        List<User> userList = new SLT_User().selectByContactId(new Set<Id> {contact_1.Id},new Set<String>{CON_CSM.S_ID,CON_CSM.S_NAME,CON_CSM.S_CONTACTID_C});
        Test.stopTest();
        Integer expected = 1;
        Integer actual = users.size();
        System.assertEquals(expected, actual); 
    }

    @IsTest
    static void testSelectActiveUserByUserId() {
        List<User> userList = UTL_TestData.createUser('Standard User', 1);
        userList[0].IsActive = true;
        insert userList;
        List<User> users = new  List<User>();
        List<User> usrList = new  List<User>();
        Test.startTest();
        users = new SLT_User().selectActiveUserByUserId(new Set<Id> {userList[0].Id}, new Set<String>{'Id'});
        usrList = new SLT_User().selectAccountIdByUser(userList[0].Id);
        Test.stopTest();
        Integer expected = 1;
        Integer actual = users.size();
        System.assertEquals(expected, actual);
    }
    
    @IsTest
    static void testSelectUserByUserId() {
        List<User> userList = UTL_TestData.createUser('Standard User', 1);
        userList[0].IsActive = true;
        insert userList;
        User user;
        List<User> usrList = new List<User>();
        List<User> usrList1 = new List<User>();
        Test.startTest();
        user = new SLT_User().selectUserByUserId(new Set<Id> {userList[0].Id});
        usrList = new SLT_User().getUserDetailByIds(new Set<String>{'Id','Name'}, new Set<Id> {userList[0].Id});
        usrList1 = new SLT_User().getUserDetailByIds(null, new Set<Id> {userList[0].Id});
        Test.stopTest();
        System.assertEquals(true, user != null);
        System.assertNotEquals(null, usrList1, 'user list should not be null');
    }
    
    @IsTest
    static void testSelectUserByName() {
        List<User> userList = UTL_TestData.createUser('Standard User', 1);
        userList[0].IsActive = true;
        insert userList;
        List<User> users = new List<User>();
        Test.startTest();
        users = new SLT_User().selectUserByName('lastName123');
        List<User> newUserList = UTL_TestData.createUser('System Administrator', 1);
        List<User> usrList= new SLT_User().selectAccountCountryByUser(newUserList[0].Id);
        Test.stopTest();
        Integer expected = 1;
        Integer actual = users.size();
        System.assertEquals(expected, actual);
    }

    @IsTest
    static void testSelectUserByAccountId() {
        User partnerUser = TST_PEP_TestDataFactory.createPartnerUser('partneruser@iqvia.partner.com');
        partnerUser.PortalRole = 'Manager';
        insert partnerUser;

        User testPartner = [SELECT id, AccountId FROM User WHERE email='partneruser@iqvia.partner.com'];

        Test.startTest();
            List<User> userListAst = new SLT_User().selectUserByAccountId(new Set<Id>{testPartner.AccountId});
            System.assertEquals(1, userListAst.size());
        Test.stopTest();

    }

    @IsTest
    static void testSelectManagerUserByAccountId() {
        User partnerUser = TST_PEP_TestDataFactory.createPartnerUser('partneruser@iqvia.partner.com');
        partnerUser.PortalRole = 'Manager';
        insert partnerUser;

        User testPartner = [SELECT id, AccountId FROM User WHERE email='partneruser@iqvia.partner.com'];

        Test.startTest();
            List<User> userListAst = new SLT_User().selectManagerUserByAccountId(new Set<Id>{testPartner.AccountId});
            System.assertEquals(1, userListAst.size());
        Test.stopTest();

    }
	
    @IsTest
    static void testSelectMapOfActiveUserByUserId() {
        List<User> userList = UTL_TestData.createUser('Standard User', 1);
        userList[0].IsActive = true;
        insert userList;

        Test.startTest();
        	Map<Id,User> mapOfUser = new SLT_User().selectMapOfActiveUserByUserId(new Set<Id>{userList[0].Id}, new Set<String>{'Id','Name'});
            System.assertEquals(1, mapOfUser.size());
        Test.stopTest();

    }
	
    @IsTest
    static void testSelectContactDetailByUser() {
        List<User> userList = UTL_TestData.createUser('Standard User', 1);
        userList[0].IsActive = true;
        insert userList;

        Test.startTest();
            List<User> ListOfUser = new SLT_User().selectContactDetailByUser(new Set<Id>{userList[0].Id}, new Set<String>{'Id','Name'});
            System.assertEquals(1, ListOfUser.size());
        Test.stopTest();

    }
	
    @IsTest
    static void testSelectContactIdOrEmailByUser() {
        Id contactId = [select Id from contact where lastName = 'TestContact0' limit 1].Id;

        Test.startTest();
        List<user> listOfUser = new SLT_User().selectContactIdOrEmailByUser(new Set<id>{contactId}, new Set<String>{'sda@fgd.sda'},
                                                                            new Set<String>{'id'});
        Test.stopTest();
        
        System.assertEquals(true, listOfUser.isEmpty(),'user is fetched');
    }
    
    @IsTest
    static void testSelectUserWithContact() {        
        Test.startTest();
        List<user> listOfUser = new SLT_User().selectUserWithContact(new Set<String>{'email'});
        Test.stopTest();
    }
    
    @isTest
    static void testSelectUserByEmployeeNumber() {
        Test.startTest();
        List<user> listOfUser = new SLT_User().selectUserByEmployeeNumber(new Set<String>{'1234'}, new Set<String>{'Id', 'EmployeeNumber'});
        Test.stopTest();
    }
    
    @isTest
    static void testGetUserByProfileNames() {
        List<Contact> con = [SELECT Id FROM Contact LIMIT 1];
        Test.startTest();
        List<user> listOfUser = new SLT_User().getUserByProfileNames(new Set<Id>{con[0].Id},new Set<String>{'PRM CommunityUser'});
        Test.stopTest();
    }
    
     @isTest
    static void testGetUserByGroup() {
        List<Contact> con = [SELECT Id FROM Contact LIMIT 1];
        Test.startTest();
        List<user> listOfUser = new SLT_User().getUsersByGroupName(CON_Qualtrics.DECLINE_SURVEY_REASSIGN_GROUP_LABEL);
        Test.stopTest();
    }

    @isTest
    static void testGetPRMManagerUsers() {
        List<Contact> con = [SELECT Id FROM Contact LIMIT 1];
        Test.startTest();
        List<user> listOfUser = new SLT_User().getPRMManagerUsers(new Set<Id>{con[0].Id});
        Test.stopTest();
    }

    @IsTest
    static void testGetUsersByUserIds() {
        List<User> userList = UTL_TestData.createUser('Standard User', 1);
        userList[0].IsActive = true;
        insert userList;

        Test.startTest();
            List<User> ListOfUser = SLT_User.getUsersByUserIds(new List<Id>{userList[0].Id});
            System.assertEquals(1, ListOfUser.size());
        Test.stopTest();
    }
    
    @isTest
    static void testGetPRMUsers() {
        List<Contact> con = [SELECT Id FROM Contact LIMIT 1];
        Test.startTest();
        Map<Id, User> listOfUser = new SLT_User().getPRMUsers(new Set<Id>{con[0].Id});
        Test.stopTest();
    }
	
    @IsTest
    static void testGetUsersByUserEmails() {
        List<User> userList = UTL_TestData.createUser('Standard User', 1);
        userList[0].IsActive = true;
        insert userList;

        Test.startTest();
            List<User> ListOfUser = new SLT_User().selectUserByEmail(new Set<String>{userList[0].Email});
            System.assertEquals(1, ListOfUser.size());
        Test.stopTest();
    }
    
    @IsTest
    static void testSelectUserWithPermissionSetByUserId() {
        List<User> userList = UTL_TestData.createUser('Standard User', 1);
        userList[0].IsActive = true;
        insert userList;

        Test.startTest();
            List<User> ListOfUser = new SLT_User().selectUserWithPermissionSetByUserId(
                new Set<Id>{UserInfo.getUserId()},
                new Set<String> {CON_CPQ.PROFILE_NAME},
                new Set<String> {CON_CPQ.ID},
                new Set<String> {CON_CPQ.CPQ_TS_READ_WRITE_PERMISSION_SET});
            System.assertEquals(1, ListOfUser.size());
        Test.stopTest();
    }
}