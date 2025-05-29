@isTest
public class TST_SLT_UserRole {
    
    @testSetup
    static void dataSetup() {
        Id prmProfileId = [select id from profile where name =: CON_PEP.S_P_PEP_COMMUNITY ].id;
        Account ac = TST_PEP_TestDataFactory.createAccount('AcmeDemo');
        ac.AccountCountry__c = 'BM' ;
        insert ac; 
        
        Contact con = new Contact(FirstName = 'TestFirstName', LastName ='testCon',AccountId = ac.Id,Email='partneruser@iqvia.partner.com',Inactive__c = false);
        con.Partner_Type__c = 'Integrator Partner; Data Partner';
        insert con;
        
        User user = new User(alias = 'test123', email='partneruser@iqvia.partner.com',
                             emailencodingkey='UTF-8', lastname='PRMTesting', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = prmProfileId, country='United States',IsActive =true,
                             ContactId = con.Id,
                             timezonesidkey='America/Los_Angeles', username='test452322@xyz.com',
                             Change_Request_Description__c = 'test',
                             Change_Request_Ticket_Number__c ='test description',
                             EmployeeNumber = String.valueOf(System.currentTimeMillis())
                            );
        insert user;
    }
    
    @isTest 
    static void testGetUserRoleByName() {
        Test.startTest();
        User u = [SELECT Id, Name FROM User WHERE lastname='PRMTesting' LIMIT 1];
        UserRole ur = new UserRole(DeveloperName = 'AcmeDemo', Name = 'AcmeDemoRole');
        insert ur;
        UserRole uRole = new SLT_UserRole().getUserRoleByName('AcmeDemoRole');
        uRole = new SLT_UserRole().getUserRolesByName(new List<String>{'AcmeDemoRole'})[0];
        Test.stopTest();
    }
}