@istest
public class TST_CNT_CSM_RelationshipList {
    
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
        
        Contact testActiveEmployee = new Contact(
            AccountId = employeeAccount.Id,
            FirstName = 'TestActive1',
            LastName = 'TestActiveEmployee',
            Salesforce_User__c = employees[0].Id
        );
        insert testActiveEmployee;
        
        Contact testInactiveEmployee = new Contact(
            AccountId = employeeAccount.Id,
            FirstName = 'TestInactive2',
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

            Focus__c = 'Research & Development Solutions',
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

            Focus__c = 'Q-Squared Solutions',
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
    public static void testgetContactDetails() {
         List<Account> testAccount = [SELECT Id FROM Account WHERE Name = 'CustomerAccount' LIMIT 1];
        List<Contact> testContact = [SELECT Id FROM Contact WHERE Name = 'TestActive1 TestActiveEmployee' LIMIT 1];
        List<AccountContactRelation> testRelation = [SELECT Id, Contact.Name, Function__c, Focus__c, User_Country__c, Geographic_Responsibility__c, Responsibility__c, Contact_Type__c
                                                     FROM AccountContactRelation 
                                                     WHERE AccountId = :testAccount[0].Id 
                                                     AND ContactId = :testContact[0].Id 
                                                     LIMIT 1];
        
        Test.startTest();
        List<Contact> relations = CNT_CSM_RelationshipList.getContactDetails(UserInfo.getUserId());
        List<User> userRelations = CNT_CSM_RelationshipList.getUserDetail(UserInfo.getUserId());
        Test.stopTest();
    }
    
    @isTest
    public static void testGetActiveRelations() {
        List<Account> testAccount = [SELECT Id FROM Account WHERE Name = 'CustomerAccount' LIMIT 1];
        List<Contact> testContact = [SELECT Id FROM Contact WHERE Name = 'TestActive1 TestActiveEmployee' LIMIT 1];
        List<AccountContactRelation> testRelation = [SELECT Id, Contact.Name, Function__c, Focus__c, User_Country__c, Geographic_Responsibility__c, Responsibility__c, Contact_Type__c
                                                     FROM AccountContactRelation 
                                                     WHERE AccountId = :testAccount[0].Id 
                                                     AND ContactId = :testContact[0].Id 
                                                     LIMIT 1];
        
        Test.startTest();
        List<AccountContactRelation> relations = CNT_CSM_RelationshipList.getActiveRelationsForCSH(UserInfo.getUserId(), testRelation[0].Contact_Type__c);
        Test.stopTest();
        
        
    }
    
    
    
    @isTest
    public static void testdelete() {
        CNT_CSM_RelationshipList.deletePhoto(UserInfo.getUserId(), 'sign.jpg');
    }
    
    @isTest
    public static void testsave() {
        Document documentObj;
        documentObj = new Document();
        documentObj.Body = Blob.valueOf('Some Document Text');
        documentObj.ContentType = 'image/jpg';
        documentObj.DeveloperName = 'my_document';
        documentObj.IsPublic = true;
        documentObj.Name = 'My Document';
        documentObj.FolderId = UserInfo.getUserId();
        insert documentObj;
        CNT_CSM_RelationshipList.deletePhoto(UserInfo.getUserId(), 'My Document');
        //string c = Blob.valueOf('Some Document Text');
        CNT_CSM_RelationshipList.saveAttachment('My Document', 'Some Document Text', 'image/jpg');
    }
    
    
}