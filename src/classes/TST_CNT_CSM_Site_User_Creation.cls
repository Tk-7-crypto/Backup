@isTest
Private class TST_CNT_CSM_Site_User_Creation {
    
    /**
    * This method used to set up testdata
    */ 
    @testSetup
    static void dataSetup() {
        Account account1 = UTL_TestData.createAccount();
        insert account1;
        List<Contact> listOfCanotact = UTL_TestData.createContacts(account1.Id,1);
        insert listOfCanotact;
        Case newCase1 =  UTL_TestData.createCase();
        newCase1.RecordTypeId = new SLT_RecordType().getRecordType('DATACase')[0].Id;
        newCase1.contactId = listOfCanotact[0].Id;
        newCase1.AccountId = account1.Id;
        Insert newCase1;
        CSM_User_Self_Registration__c csmSetting = new CSM_User_Self_Registration__c(Community_Link__c = 'test.com');
        insert csmSetting;
    }
    
    /**
    * This method used to get Current user
    */    
    @IsTest
    static void testCreateCommunityUser() {
        Id accountId = [Select Id,Name from Account where name = 'TestAccount' limit 1].Id;
        Id ContactId = [select Id, name from contact where accountId =: accountId limit 1].Id;
        Id CaseId = [select Id from case where ContactId =: ContactId limit 1].Id;
        CNT_CSM_Site_User_Creation.ContactInfo newContactInfo= new CNT_CSM_Site_User_Creation.ContactInfo(ContactId,'Tst','userCreation','','',
            'test54234@gmail.com','TestAccount', CON_CSM.S_TECHNOLOGY_R_T,null, accountId);
        Test.startTest();
            String result = CNT_CSM_Site_User_Creation.createCommunityUser(newContactInfo, CaseId);
        Test.stopTest();
        System.assertEquals(true, String.isEmpty(result),'user is not created');
    }
    
    @IsTest
    static void testUpdateContactInfo() {
        Id accountId = [Select Id,Name from Account where name = 'TestAccount' limit 1].Id;
        Id ContactId = [select Id, name from contact where accountId =: accountId limit 1].Id;
        CNT_CSM_Site_User_Creation.ContactInfo newContactInfo= new CNT_CSM_Site_User_Creation.ContactInfo(ContactId,'Tst1','userCreation','','',
            'test54234@gmail.com','TestAccount', CON_CSM.S_INFORMATION_OFFERING,null, accountId);
        Test.startTest();
            newContactInfo = CNT_CSM_Site_User_Creation.updateContactInfo(newContactInfo);
        Test.stopTest();
        System.assertEquals('Tst1', newContactInfo.firstName,'user is not created');
    }
    
    @IsTest
    static void testSelectContactInfo() {
        Id accountId = [Select Id,Name from Account where name = 'TestAccount' limit 1].Id;
        Id ContactId = [select Id, name from contact where accountId =: accountId limit 1].Id;
        CNT_CSM_Site_User_Creation.ContactInfo newContactInfo= new CNT_CSM_Site_User_Creation.ContactInfo();
        Test.startTest();
            newContactInfo = CNT_CSM_Site_User_Creation.selectContactInfo(ContactId, CON_CSM.S_INFORMATION_OFFERING);
        Test.stopTest();
        System.assertEquals('TestContact0', newContactInfo.lastName,'user is not created');
    }
    
    @IsTest
    static void testGetCSMSetting() {
        Test.startTest();
            String csmSetting = CNT_CSM_Site_User_Creation.getCSMSetting();
        Test.stopTest();
        System.assertEquals(true, csmSetting != null,'custom setting is fetched');
    }
    
    @IsTest
    static void testResetPassword() {
        Test.setMock(HttpCalloutMock.class, new CSM_JiraCalloutsHttpResponseMock());
        Test.startTest();
            CNT_CSM_Site_User_Creation.sendResetPassword('00523000001CK2LAAW');
        Test.stopTest();
    }
}