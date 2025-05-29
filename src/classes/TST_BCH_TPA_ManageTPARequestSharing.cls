@isTest(seeAllData = false)
private class TST_BCH_TPA_ManageTPARequestSharing {
    @testSetup
    static void setup() {
        
    }

    public static testMethod void testtpaRequestSharing() {
        Test.startTest();
        Date todayDate = Date.today();

        Profile tpProcessorProfile = [SELECT Id FROM Profile WHERE Name like 'TPA Processor Profile CCP'];
        Profile superUserProfile = [SELECT Id FROM Profile WHERE Name like 'Super User Profile CCP'];
		//UserRole portalRole = [Select Id, DeveloperName, PortalType From UserRole Where DeveloperName = 'Global' and PortalType='None'];
        
        Account testAccount = new Account( name = 'TPA Test Account1',
                                           BillingCountry = 'India',
                                           BillingState = 'Delhi',
                                           BillingCity = 'Test',
                                           BillingStreet = 'Test',
                                           BillingPostalCode = '123',
                                           CustomerSegment__c = 'GOVERNMENT',
                                           Sub_Industry__c = 'STATE' );
        insert testAccount;
        
        Address__c testAccount1 = UTL_TPA_SetupTestData.getAddress(); 
        testAccount1.Name = 'Test Account 1';
        testAccount1.Account__c = testAccount.Id;
        testAccount1.Is_TPA_Account__c = true;
        testAccount1.Vendor_Registration_Number__c = 1234;
        insert testAccount1;

        Address__c testAccount2 = UTL_TPA_SetupTestData.getAddress(); 
        testAccount2.Name = 'Test Account 2';
        testAccount2.Account__c = testAccount.Id;
        insert testAccount2;

        Contact testContact1 = UTL_TPA_SetupTestData.getContact();
        testContact1.AccountId = testAccount1.Account__c;
        testContact1.LastName = 'Test Contact 1';
        insert testContact1;

        Contact testContact2 = UTL_TPA_SetupTestData.getContact();
        testContact2.AccountId = testAccount1.Account__c;
        testContact2.LastName = 'Test Contact 2';
        insert testContact2;

        Contact testContact3 = UTL_TPA_SetupTestData.getContact();
        testContact3.AccountId = testAccount1.Account__c;
        testContact3.LastName = 'Test Contact 3';
        insert testContact3;
        
        List<Contact_Address_Crosswalk__c> crosswalkObjList = new List<Contact_Address_Crosswalk__c>();
        Contact_Address_Crosswalk__c crosswalkObj1 = UTL_TPA_SetupTestData.getjunctionRecord(testContact1.Id, testAccount1.Id);
        crosswalkObjList.add(crosswalkObj1);
        
        Contact_Address_Crosswalk__c crosswalkObj2 = UTL_TPA_SetupTestData.getjunctionRecord(testContact2.Id, testAccount1.Id);
        crosswalkObjList.add(crosswalkObj2);
        
        Contact_Address_Crosswalk__c crosswalkObj3 = UTL_TPA_SetupTestData.getjunctionRecord(testContact3.Id, testAccount2.Id);
        crosswalkObjList.add(crosswalkObj3);
        
        insert crosswalkObjList;
		
        List<User> tpProcessors = new List<User>();
        User tpProcessor1 = UTL_TPA_SetupTestData.getUser();
        tpProcessor1.ProfileId = tpProcessorProfile.id;
        tpProcessor1.UserName='testuser1@testing.com';
        tpProcessor1.ContactId = testContact1.id;
        tpProcessors.add(tpProcessor1);

        User tpProcessor2 = UTL_TPA_SetupTestData.getUser();
        tpProcessor2.ProfileId = tpProcessorProfile.id;
        tpProcessor2.UserName='testuser12@testing.com';
        tpProcessor2.ContactId = testContact3.id;
        tpProcessors.add(tpProcessor2);
        
        insert tpProcessors;

        User superUser1 = UTL_TPA_SetupTestData.getUser();
        superUser1.ProfileId = superUserProfile.id;
        superUser1.UserName='testuser2@testing.com';
        superUser1.ContactId = testContact2.id;
        insert superUser1;
        
        system.debug('superUser1:'+superUser1.IsPortalEnabled);
        
        TPA_Request__c tpaRequest1 = UTL_TPA_SetupTestData.getTestTPARequest();
        tpaRequest1.OwnerId = UserInfo.getUserId();
        tpaRequest1.Service_Provider_Address__c = testAccount1.Id;
        tpaRequest1.Request_Status__c = 'Awaiting Vendor Submission';
        tpaRequest1.Data_Access_End_Date__c = todayDate.addDays(-3);
        tpaRequest1.Client_Company_Name_Address__c = testAccount1.Id;
        tpaRequest1.TPA_Processor_Account_Address__c = testAccount1.Id;
        tpaRequest1.TPA_Processor_Contact__c = testContact1.Id;
        insert tpaRequest1;

        TPA_Request__c tpaRequest2 = UTL_TPA_SetupTestData.getTestTPARequest();
        tpaRequest2.OwnerId = UserInfo.getUserId();
        tpaRequest2.Service_Provider_Address__c = testAccount2.Id;
        tpaRequest2.Request_Status__c = 'Awaiting Vendor Submission';
        tpaRequest2.Data_Access_End_Date__c = todayDate.addDays(-3);
        tpaRequest2.TPA_Processor_Account_Address__c = testAccount2.Id;
        tpaRequest1.TPA_Processor_Contact__c = testContact2.Id;
        insert tpaRequest2;
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
            List<User> userList = [SELECT Id FROM User WHERE UserName = 'testuser1@testing.com' OR UserName = 'testuser2@testing.com' OR UserName = 'testuser12@testing.com'];
            Update userList;
            List <id> idList = new List<id>();
            for(User user :userList){
                idList.add(user.id);
            }
            List<TPA_Request__Share> shareRecords1 = [SELECT Id, UserOrGroupId, ParentId, RowCause
                                                     FROM TPA_Request__Share
                                                     WHERE ParentId =: tpaRequest1.Id
                                                     AND (RowCause = :Schema.TPA_Request__Share.rowCause.TP_Processor__c  OR RowCause = :Schema.TPA_Request__Share.rowCause.Super_User__c)];

            //System.assertEquals(2, shareRecords1.size());
            delete shareRecords1;

            List<TPA_Request__Share> shareRecords = [SELECT Id, UserOrGroupId, ParentId, RowCause
                                                     FROM TPA_Request__Share
                                                     WHERE ParentId =: tpaRequest2.Id
                                                     AND (RowCause = :Schema.TPA_Request__Share.rowCause.TP_Processor__c  OR RowCause = :Schema.TPA_Request__Share.rowCause.Super_User__c)];
            delete shareRecords;
            System.debug('*** shareRecords:b4 ' + shareRecords);
            Update userList;
            //TGRH_TPA_User.manageSharing(idList);
            //
            
        }
        Test.stopTest();
        List<TPA_Request__Share> shareRecords2 = [SELECT Id, UserOrGroupId, ParentId, RowCause
                                                 FROM TPA_Request__Share
                                                 WHERE ParentId =: tpaRequest2.Id
                                                 AND (RowCause = :Schema.TPA_Request__Share.rowCause.TP_Processor__c  OR RowCause = :Schema.TPA_Request__Share.rowCause.Super_User__c)];

        System.debug('*** shareRecords2: ' + shareRecords2);
        
       // System.assertEquals(1, shareRecords2.size());
    }
    
}