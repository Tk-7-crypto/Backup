@isTest
public class TST_CNT_CRM_RelationshipList {
    @testSetup
    public static void setup() {
        List<User> employees = UTL_OWF_TestData.createUser('Sales User', 2);
        for (User employee : employees) {
            employee.User_Country__c = 'USA';
        }
        insert employees;
        
        Account customerAccount = new Account(Name = 'CustomerAccount', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert customerAccount;
        
        Account employeeAccount = new Account(Name = 'EmployeeAccount', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert employeeAccount;
        
        Account globalAccount = new Account(Name = 'GlobalAccount', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert globalAccount;
        
        
        Contact testActiveEmployee = new Contact(
            Firstname = 'testFirstname',
            AccountId = employeeAccount.Id,
            LastName = 'TestActiveEmployee',
            Salesforce_User__c = employees[0].Id
        );
        insert testActiveEmployee;
        
        Contact testInactiveEmployee = new Contact(
            Firstname = 'testFirstname',
            AccountId = employeeAccount.Id,
            LastName = 'TestInactiveEmployee',
            Salesforce_User__c = employees[1].Id
        );
        insert testInactiveEmployee;
        
        // Active Relationship
        AccountContactRelation activeEmployeeRelation = new AccountContactRelation(
            AccountId = customerAccount.Id,
            ContactId = testActiveEmployee.Id,
            Contact_Type__c = 'Customer',
            Roles = 'Inside Sales',
            Focus__c = 'Real World Solutions',
            Geographic_Responsibility__c = 'Global',
            Function__c = 'Inside Sales',
            Responsibility__c = 'Consumer Health',
            StartDate = System.today(),
            IsActive = True
        );
        insert activeEmployeeRelation;
        
        // Inactive Relationship
        AccountContactRelation inactiveEmployeeRelation = new AccountContactRelation(
            AccountId = customerAccount.Id,
            ContactId = testInactiveEmployee.Id,
            Contact_Type__c = 'Customer',
            Roles = 'Account Lead',
            Focus__c = 'Global Market Insights',
            Geographic_Responsibility__c = 'Local',
            Function__c = 'Account Lead',
            Responsibility__c = 'Consumer Health',
            StartDate = System.today() - 7,
            EndDate = System.today(),
            IsActive = False
        );
        insert inactiveEmployeeRelation;
        System.debug(inactiveEmployeeRelation.StartDate);
    }
    
    @isTest
    public static void testGetActiveRelations() {
        List<Account> testAccount = [SELECT Id FROM Account WHERE Name = 'CustomerAccount' LIMIT 1];
        List<Contact> testContact = [SELECT Id FROM Contact WHERE Name = 'testFirstname TestActiveEmployee' LIMIT 1];
        List<AccountContactRelation> testRelation = [SELECT Id, Contact.Name, Function__c, Focus__c, User_Country__c, Geographic_Responsibility__c, Responsibility__c, Contact_Type__c
                                                     FROM AccountContactRelation 
                                                     WHERE AccountId = :testAccount[0].Id 
                                                     AND ContactId = :testContact[0].Id 
                                                     LIMIT 1];
        
        Test.startTest();
        List<AccountContactRelation> relations = CNT_CRM_RelationshipList.getActiveRelations(testAccount[0].Id, testRelation[0].Contact_Type__c);
        Test.stopTest();
        
        System.assertEquals(1, relations.size());
        System.assertEquals(testRelation[0].Contact.Name, relations[0].Contact.Name);
        System.assertEquals(testRelation[0].Function__c, relations[0].Function__c);
        System.assertEquals(testRelation[0].Focus__c, relations[0].Focus__c);
        System.assertEquals(testRelation[0].User_Country__c, relations[0].User_Country__c);
        System.assertEquals(testRelation[0].Geographic_Responsibility__c, relations[0].Geographic_Responsibility__c);
        System.assertEquals(testRelation[0].Responsibility__c, relations[0].Responsibility__c);
    }
    
    @isTest
    public static void testGetInactiveRelations() {
        List<Account> testAccount = [SELECT Id FROM Account WHERE Name = 'CustomerAccount' LIMIT 1];
        List<Contact> testContact = [SELECT Id FROM Contact WHERE Name = 'testFirstname TestInactiveEmployee' LIMIT 1];
        List<AccountContactRelation> testRelation = [SELECT Id, Contact.Name, Function__c, Focus__c, User_Country__c, Geographic_Responsibility__c, Responsibility__c, EndDate, Contact_Type__c
                                                     FROM AccountContactRelation 
                                                     WHERE AccountId = :testAccount[0].Id 
                                                     AND ContactId = :testContact[0].Id 
                                                     LIMIT 1];
        
        Test.startTest();
        List<AccountContactRelation> relations = CNT_CRM_RelationshipList.getInactiveRelations(testAccount[0].Id, testRelation[0].Contact_Type__c);
        Test.stopTest();
        
        System.assertEquals(1, relations.size());
        System.assertEquals(testRelation[0].Contact.Name, relations[0].Contact.Name);
        System.assertEquals(testRelation[0].Function__c, relations[0].Function__c);
        System.assertEquals(testRelation[0].Focus__c, relations[0].Focus__c);
        System.assertEquals(testRelation[0].User_Country__c, relations[0].User_Country__c);
        System.assertEquals(testRelation[0].Geographic_Responsibility__c, relations[0].Geographic_Responsibility__c);
        System.assertEquals(testRelation[0].Responsibility__c, relations[0].Responsibility__c);
        System.assertEquals(testRelation[0].EndDate, relations[0].EndDate);
    }
    
    @isTest
    public static void testGetRecordType(){
        List<Account> testAccount = [SELECT Id FROM Account WHERE Name = 'GlobalAccount' LIMIT 1];
        List<Account> testAccount1 = [SELECT Id FROM Account WHERE Name = 'CustomerAccount' LIMIT 1];
        testAccount[0].RecordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global Customer Account').getRecordTypeId();
        update testAccount;
        System.debug('Record Id : '+testAccount[0].RecordTypeId);
        Test.startTest();
            Boolean flagTrue = CNT_CRM_RelationshipList.getRecordType(testAccount[0].Id);
            Boolean flagFalse = CNT_CRM_RelationshipList.getRecordType(testAccount1[0].Id);
        Test.stopTest();
        System.debug('flagTrue : '+flagTrue);
        System.debug('flagFalse : '+flagFalse);
        
        System.assertEquals(True, flagTrue);
        System.assertEquals(False, flagFalse);        
    }   
    
    @isTest
    public static void testGetGlobal_Account_Team_Roll_Up_Report(){
        Test.startTest();
        	String value = CNT_CRM_RelationshipList.getGlobal_Account_Team_Roll_Up_Report();
        System.debug('value : '+value);
        Test.stopTest();        
    }
    
    @isTest
    public static void testGetAccountNameById(){
        List<Account> testAccount = [SELECT Id FROM Account WHERE Name = 'GlobalAccount' LIMIT 1];
        Test.startTest();
            String accName = CNT_CRM_RelationshipList.getAccountNameById(testAccount[0].Id);
        Test.stopTest();        
        System.assertEquals('GlobalAccount', accName);     
    }
}