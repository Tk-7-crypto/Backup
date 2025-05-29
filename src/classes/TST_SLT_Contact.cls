/**
* This test class is used to test all methods in opportunity trigger helper.
* version : 1.0
*/
@isTest
private class TST_SLT_Contact {
    
    /**
    * This method is used to setup data for all methods.
    */
    @testSetup
    static void dataSetup() {
        Account acc = UTL_OWF_TestData.createAccount();
        insert acc;
        
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        
        Contact cont = UTL_OWF_TestData.createContact(acc.Id);
        cont.pse__Is_Resource__c = true;
        cont.pse__Is_Resource_Active__c = true;
        cont.pse__Group__c = grp.Id;
        cont.email = 'test@test.com';
        insert cont;
        
        Contact contact = new Contact(AccountId = acc.Id, FirstName='test', Email='test@example.com', LastName ='lastname', RecordTypeId = CON_CLM.CONTACT_CONTACT_RECORDTYPEID);
        insert contact;        
    }
    
    /**
    * This test method used to get Contact by Id 
    */ 
    static testMethod void testSelectByContactId() {
        Contact contact = [SELECT id from Contact][0];
        Map<Id, Contact> idToContactMap = new SLT_Contact().selectByContactId(new Set<Id>{contact.Id}, new Set<String>{'Id'});
    }  
    
    static testMethod void testSelectByContactIdList() {
        Contact contact = [SELECT id from Contact][0];
        List<Contact> contactList = new SLT_Contact().selectByContactIdList(new Set<Id>{contact.Id}, new Set<String>{'Id'});
    }
    
    static testMethod void testSelectByEmail() {
        Contact contact = new SLT_Contact(false, false).selectByEmail('test@test.com');
    }
    
    static testMethod void testSelectByMobile() {
        Map<Id, Contact> idToContactMap = new SLT_Contact().selectByMobile('123456789');
    }
    
    static testMethod void testSelectBySalesforceUserIdList() {
        Contact contact = [SELECT id from Contact][0];
        List<Contact> contactList = new SLT_Contact().selectBySalesforceUserIdList(new Set<Id>{contact.Id}, new Set<String>{'Id'});
    }
    
    static testMethod void testSelectByEmailIdList() {
        List<Contact> contactList = new SLT_Contact().selectByEmailIdList(new Set<String> {'test@test.com'});
    }
    
    static testMethod void testSelectByPseSalesforceUserIdList() {
        Contact contact = [SELECT id from Contact][0];
        List<Contact> contactList = new SLT_Contact().selectByPseSalesforceUserIdList(new Set<Id>{contact.Id}, new Set<String>{'Id'});
    }
    
    static testMethod void testSelectContactByLiContactId() {
        Contact contact = [SELECT id from Contact][0];
        List<Contact> contactList = new SLT_Contact().selectContactByLiContactId(new Set<Id>{contact.Id}, new Set<String>{'Id'});
    }
    
    static testMethod void testGetContactByUserEmployeeNumber() {
        List<Contact> contactList = new SLT_Contact().getContactByUserEmployeeNumber('123456789');
    }
    
    static testMethod void testSelectByContactCondition() {
        Contact contact = [SELECT id from Contact][0];
        Map<Id, Contact> idToContactMap = new SLT_Contact().selectByContactCondition(new Set<Id>{contact.Id},' pse__Is_Resource__c = true', new Set<String>{'Id'});
    }

    static testMethod void testSelectByEmailId() {
        Contact contact = [SELECT id,Email from Contact][0];

        Test.startTest();
            Contact fetchedContact = new SLT_Contact().selectByEmailId(contact.Email);
        Test.stopTest();

        System.assertNotEquals(null,fetchedContact , 'No Records Returned when expected');
    }

    static testMethod void testGetContactEmails() {
        Contact contact = [SELECT id,Email from Contact][0];

        Test.startTest();
            List<Contact> fetchedContacts = new SLT_Contact().getContactEmails(new Set<Id>{contact.Id});
        Test.stopTest();

        System.assertNotEquals(0,fetchedContacts.size() , 'No Records Returned when expected');
    }

    static testMethod void testSelectContactByAccId() {
        Contact contact = [SELECT id,AccountId from Contact][0];

        Test.startTest();
            List<Contact> fetchedContacts = new SLT_Contact().selectContactByAccId(contact.AccountId,new Set<String>{'Id'});
        Test.stopTest();

        System.assertNotEquals(0,fetchedContacts.size() , 'No Records Returned when expected');
    }

    static testMethod void testSelectContactByCondition() {
        Contact contact = [SELECT id,AccountId from Contact][0];

        Test.startTest();
            List<Contact> fetchedContacts = new SLT_Contact().selectContactByCondition(new Set<String>{'Id'},new List<Id>{contact.AccountId});
        Test.stopTest();

        System.assertNotEquals(0,fetchedContacts.size() , 'No Records Returned when expected');
    }

    static testMethod void testGetCSMMINContactEmails() {
        Contact contact = [SELECT id,AccountId from Contact][0];
        List<Contact> fetchedContacts = new SLT_Contact().getCSMMINContactEmails(new Set<Id>{contact.AccountId});
    }

    @IsTest
    static void testSelectContactBasedOnId(){
        Contact contact = [SELECT id from Contact][0];
        Test.startTest();
        new SLT_Contact().selectContactBasedOnId(new Set<Id>{contact.Id});
        Test.stopTest();
    }
    static testMethod void getSelectBySearchStringTest(){
        SLT_Contact sltObjectClass = new SLT_Contact();
        Id actId = [SELECT Id FROM Account LIMIT 1].Id;
        Contact cntRec = [SELECT Id,Name FROM Contact LIMIT 1];
        String searchString = cntRec.Name;
        String searchStr = '\'%' + searchString + '%\'';
        Set<String> fieldsToQuery = new Set<String>{'Id', 'Name', 'Phone'};
        List<Contact> cntRecLst = sltObjectClass.selectBySearchString(searchStr, new Set<Id>{actId}, fieldsToQuery);
        System.assertEquals(cntRecLst[0].Name , cntRec.Name);
        System.assertEquals(cntRecLst[0].Id , cntRec.Id);
    }
    
    static testMethod void testSelectByEmailIdSet() { 
        List<Contact> contactList = new SLT_Contact().selectByEmailIdSet(new Set<String> {'test@test.com'});
    }
    
    @IsTest
    static void testGetContactDetailsMap(){
        Contact contact = [SELECT Id from Contact][0];
        Test.startTest();
            Map<Id, Contact> contactMap= new SLT_Contact().getContactDetailsMap(new Set<Id>{contact.Id}, new Set<String> {CON_CPQ.ID, CON_CPQ.NAME});
        Test.stopTest();
        System.assertEquals(1, contactMap.size());
    }
    
    @IsTest
    static void testSelectContactsforEmail(){
        Account acc = [SELECT id FROM Account WHERE Name = 'TestAccount'];
        Contact contact = new Contact(
            Firstname='Brian',
            Lastname='Dent',
            Phone='(619)852-4569',
            Department='Mission Control',
            Title='Mission Specialist - Neptune',
            Email='john@acme.com',
            Portal_Case_Type__c = 'Technology Solutions',
            Contact_User_Type__c='HO User',
            Partner_Type__c='Integrator Partner',
            AccountId = acc.Id);
        insert contact;
        String profilId = [select id from Profile where Name='PRM Community User'].Id;
        User user = New User(Alias = 'com', Email = 'john@acme.com',IsActive =true, ContactId = contact.Id, ProfileId = profilId,Username =' johnprm1@acme.com',FirstName = 'testFirstName', LastName= 'testLastName', CommunityNickname ='testCommunityNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', employeeNumber= '080808082');
        insert user;       
        String partnerType = contact.Partner_Type__c;
        partnerType = '\'' + partnerType.replace(';','\',\'') +'\'';
        String pillar = contact.Portal_Case_Type__c;
        pillar = '\'' + pillar.replace(';','\',\'') +'\'';
        Test.startTest();
        new SLT_Contact().selectContactsforEmail(partnerType,pillar,new Set<Id>{acc.Id});
        Test.stopTest();
    }
    
    @IsTest
    static void testSelectAllContactsforEmail(){
        Account acc = [SELECT id FROM Account WHERE Name = 'TestAccount'];
        Contact contact = new Contact(
            Firstname='Brian',
            Lastname='Dent',
            Phone='(619)852-4569',
            Department='Mission Control',
            Title='Mission Specialist - Neptune',
            Email='john@acme.com',
            Portal_Case_Type__c = 'Technology Solutions',
            Contact_User_Type__c='HO User',
            Partner_Type__c='Integrator Partner',
            AccountId = acc.Id);
        insert contact;
        String profilId = [select id from Profile where Name='PRM Community User'].Id;
        User user = New User(Alias = 'com', Email = 'john@acme.com',IsActive =true, ContactId = contact.Id, ProfileId = profilId,Username =' johnprm1@acme.com',FirstName = 'testFirstName', LastName= 'testLastName', CommunityNickname ='testCommunityNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', employeeNumber= '080808082');
        insert user;       
        String partnerType = contact.Partner_Type__c;
        partnerType = '\'' + partnerType.replace(';','\',\'') +'\'';
        String pillar = contact.Portal_Case_Type__c;
        pillar = '\'' + pillar.replace(';','\',\'') +'\'';
        Test.startTest();
        new SLT_Contact().selectAllContactsforEmail(partnerType,pillar);
        Test.stopTest();
    }
    
    @IsTest
    static void testSelectContactsforEmailCSM(){
        Account acc = [SELECT id FROM Account WHERE Name = 'TestAccount'];
        Contact contact = new Contact(
            Firstname='Brian',
            Lastname='Dent',
            Phone='(619)852-4569',
            Department='Mission Control',
            Title='Mission Specialist - Neptune',
            Email='john@acme.com',
            Portal_Case_Type__c = 'Technology Solutions',
            Contact_User_Type__c='HO User',
            Partner_Type__c='Integrator Partner',
            AccountId = acc.Id);
        insert contact;
        String profilId = [SELECT id from Profile where Name='Customer Community Plus Login User'].Id;
        User user = New User(Alias = 'com', Email = 'john@acme.com',IsActive =true, ContactId = contact.Id, ProfileId = profilId,Username =' johncsm1@acme.com',FirstName = 'testFirstName', LastName= 'testLastName', CommunityNickname ='testCommunityNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', employeeNumber= '080808082');
        insert user;       
        String userType = contact.Contact_User_Type__c;
        userType = '\'' + userType.replace(';','\',\'') +'\'';
        String pillar = contact.Portal_Case_Type__c;
        pillar = '\'' + pillar.replace(';','\',\'') +'\'';
        Test.startTest();
        new SLT_Contact().selectContactsforEmailCSM(userType,pillar,new Set<Id>{acc.Id});
        Test.stopTest();
    }
    
    @IsTest
    static void testSelectAllContactsforEmailCSM(){
        Account acc = [SELECT id FROM Account WHERE Name = 'TestAccount'];
        Contact contact = new Contact(
            Firstname='Brian',
            Lastname='Dent',
            Phone='(619)852-4569',
            Department='Mission Control',
            Title='Mission Specialist - Neptune',
            Email='john@acme.com',
            Portal_Case_Type__c = 'Technology Solutions',
            Contact_User_Type__c='HO User',
            Partner_Type__c='Integrator Partner',
            AccountId = acc.Id);
        insert contact;
        String profilId = [SELECT id from Profile where Name='Customer Community Plus Login User'].Id;
        User user = New User(Alias = 'com', Email = 'john@acme.com',IsActive =true, ContactId = contact.Id, ProfileId = profilId,Username =' johncsm2@acme.com',FirstName = 'testFirstName', LastName= 'testLastName', CommunityNickname ='testCommunityNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', employeeNumber= '080808082');
        insert user;       
        String userType = contact.Contact_User_Type__c;
        userType = '\'' + userType.replace(';','\',\'') +'\'';
        String pillar = contact.Portal_Case_Type__c;
        pillar = '\'' + pillar.replace(';','\',\'') +'\'';
        Test.startTest();
        new SLT_Contact().selectAllContactsforEmailCSM(userType,pillar);
        Test.stopTest();
    }

    @isTest
    private static void testGetContactsByEmails() {
        Set<String> emailSet = new Set<String>{'test@example.com'};
         
        Test.startTest();
            List<Contact> result = new SLT_Contact().getContactsByEmails(emailSet, new Set<Id>{CON_CLM.CONTACT_CONTACT_RECORDTYPEID});
        Test.stopTest();   
        
        System.assertNotEquals(null, result, 'The result should not be null');
    }    

    @isTest
    private static void testGetContactsByCondition() {
        Set<String> emailSet = new Set<String>{'test@example.com'};
        String condition = 'Email =: firstParam AND Inactive__c = false';
        
        Test.startTest();
            List<Contact> result = new SLT_Contact().getContactsByCondition(emailSet, condition, new Set<String>{'Id'});
        Test.stopTest();   
        
        System.assertNotEquals(null, result, 'The result should not be null');
    }
}