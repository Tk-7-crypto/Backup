@isTest
private class TST_User_FLW_PEP_UserDeactivation {
    @testSetup
    private static void dataSetup() {
        Id prmProfileId = [select id from profile where name =: CON_PEP.S_P_PEP_COMMUNITY ].id;
        Account ac = TST_PEP_TestDataFactory.createAccount('PRMTest');
        ac.AccountCountry__c = 'BM' ;
        insert ac; 
        Contact con = new Contact(FirstName = 'TestFirstNamePRM', LastName ='testCon',AccountId = ac.Id,Email='partneruser@iqvia.partner.com',Inactive__c = false);
        con.Partner_Type__c = 'Integrator Partner; Data Partner';
        insert con;
        User user = new User(alias = 'gdf', email='partneruser@iqvia.partner.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = prmProfileId, country='United States',IsActive =false,
                             ContactId = con.Id,
                             timezonesidkey='America/Los_Angeles', username='test10101prm@xyz.com',
                             Change_Request_Description__c = 'test',
                             Change_Request_Ticket_Number__c ='test description',
                             EmployeeNumber = String.valueOf(System.currentTimeMillis())
                            );
        insert user;
    }
    
    @IsTest
    private static void testPRMUserDeactivation(){
        List<User> autoUser = [select Id,Name,IsActive,Active_Inactive_Reason__c from user where lastname ='Testing' Limit 1 ];
        Test.startTest();
        autoUser[0].IsActive = False;
        update autoUser; 
        Test.stopTest();        
    }
	
}