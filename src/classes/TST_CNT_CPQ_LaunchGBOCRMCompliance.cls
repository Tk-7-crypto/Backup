@isTest
private class TST_CNT_CPQ_LaunchGBOCRMCompliance {
	static void createApp(String appName, String uniqueId) {
        Apttus_XApps__Application__c app = new Apttus_XApps__Application__c(Name=appName, Apttus_XApps__UniqueId__c=uniqueId);        
        insert app;
    }
    
    static User userInsertion(String Category) {      
        User testUser = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System administrator' Limit 1].Id,
            LastName = 'test' + System.currentTimeMillis(),
            Email = 'test@quintiles.com',
            Username = 'test' +System.currentTimeMillis() + '@quintiles.com',
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            GBO_CRM_Compliance_Category__c = Category,
            Change_Request_Description__c = 'test',
            Change_Request_Ticket_Number__c ='test description',
            employeeNumber= '080808081');
        insert testUser;
        return testUser;
    }
    
    @isTest
    static void testFetchUserSessionId() {  
        
        Test.startTest();
            String sessionId = CNT_CPQ_LaunchGBOCRMCompliance.fetchUserSessionId();
        Test.stopTest();
        
        System.assertNotEquals(null, sessionId, 'should not return null');
    }
    
    @isTest
    static void testGetBaseURL() { 
        
        Test.startTest();
            String baseUrl = CNT_CPQ_LaunchGBOCRMCompliance.getBaseURL();
        Test.stopTest(); 
        
        System.assertNotEquals(null, baseUrl, 'should not return null');
    }
    
    @isTest
    static void testGetAppIdContracts() {    
        
        createApp('CRM Compliance - Contracts','abcd'); 
        User testUser = userInsertion('Contracts');               
        System.runAs(testUser) {
                
             Test.startTest();
                 String[] appId = CNT_CPQ_LaunchGBOCRMCompliance.getAppName();
             Test.stopTest();
                
             System.assertNotEquals(null, appId[0], 'should return app Id');
        }
    }
    
    @isTest
    static void testGetAppIdMSAUpdates() {        
        User testUser = userInsertion(CON_CPQ.MASTER_SERVICE_AGREEMENTS_UPDATES);        
        System.runAs(testUser) {
                
            Test.startTest();
                String[] appId = CNT_CPQ_LaunchGBOCRMCompliance.getAppName();
            Test.stopTest();
                
            System.assertNotEquals(null, appId[0], 'should return app Id');
        }
    }
    
    @isTest
    static void testGetAppIdProposal() {
        createApp('CRM Compliance - Bid History','abcd1');        
        User testUser=userInsertion('BidHistory');
        System.runAs(testUser){
            
             Test.startTest();
                 String[] appId = CNT_CPQ_LaunchGBOCRMCompliance.getAppName();
             Test.stopTest();
            
             System.assertNotEquals(null, appId[0], 'should return app Id');
        }
    }
    
    @isTest
    static void testGetNewAppID() {
        createApp('CRM Compliance - Bid History','abcd1');
        
        Test.startTest();
            String appId = CNT_CPQ_LaunchGBOCRMCompliance.getNewAppId('CRM Compliance - Bid History');
        Test.stopTest();
        
        System.assertNotEquals(null, appId, 'should return app Id');
    }
}