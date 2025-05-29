/*
* This test class is used to test REST API Calls and the Responses of methods in InfrequentUser Class.
* version : 1.0
*/
@isTest
public class TST_InfrequentUser {

    @testSetup 
    static void setup() {
        List<User_Activation_API_Response__c> apiResponseList = new List<User_Activation_API_Response__c>();
        apiResponseList.add( new User_Activation_API_Response__c( Name = '10', Response_Code__c = 10, Response_Message__c = 'Message' ));
        apiResponseList.add( new User_Activation_API_Response__c( Name = '20', Response_Code__c = 20, Response_Message__c = 'Message' ));
        apiResponseList.add( new User_Activation_API_Response__c( Name = '21', Response_Code__c = 21, Response_Message__c = 'Message' ));
        apiResponseList.add( new User_Activation_API_Response__c( Name = '22', Response_Code__c = 22, Response_Message__c = 'Message' ));
        apiResponseList.add( new User_Activation_API_Response__c( Name = '23', Response_Code__c = 23, Response_Message__c = 'Message' ));
        apiResponseList.add( new User_Activation_API_Response__c( Name = '24', Response_Code__c = 24, Response_Message__c = 'Message' ));
        apiResponseList.add( new User_Activation_API_Response__c( Name = '25', Response_Code__c = 25, Response_Message__c = 'Message' ));
        apiResponseList.add( new User_Activation_API_Response__c( Name = '30', Response_Code__c = 30, Response_Message__c = 'Message' ));
        apiResponseList.add( new User_Activation_API_Response__c( Name = '40', Response_Code__c = 40, Response_Message__c = 'Message' ));
        apiResponseList.add( new User_Activation_API_Response__c( Name = '41', Response_Code__c = 41, Response_Message__c = 'Message' ));
        insert apiResponseList; 

        User_Activation_Input_Variables__c userConfig = new User_Activation_Input_Variables__c(Name = 'BusinessLogic');
        userConfig.Days_from_last_login__c = 7;
        userConfig.Allowed_Reactivation__c = 2;
        userConfig.Infrequent_User_Active_Days__c = 14;
        userConfig.Number_Of_Days_From_Last_Login__c = 100;
        userConfig.Failure_Notification_Emails__c = 'arun.james@iqvia.com';
        insert userConfig;        
    }

    @isTest
    static void testValidateUserCase1(){
        List<User> testUser = UTL_TestData.createUser('System Administrator', 1);
        insert testUser;

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/UserAccess/'; 
        req.httpMethod = 'GET';
        RestContext.request = req;
        
        Test.startTest();
        String result = InfrequentUser.validateUser();
        Test.stopTest();
        Map<String, Object> resultJSONMap  = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assertEquals(resultJSONMap.get('code'), 21);
    }

    @isTest
    static void testValidateUserCase2(){
        List<User> testUserList = UTL_TestData.createUser('System Administrator', 2);
        insert testUserList;

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/UserAccess/' + testUserList[0].userName.substringBefore('@');
        req.httpMethod = 'GET';
        RestContext.request = req;

        Test.startTest();
        String result = InfrequentUser.validateUser();
        Test.stopTest();
        Map<String, Object> resultJSONMap  = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assertEquals(resultJSONMap.get('code'), 22);
    }

    @isTest
    static void testValidateUserCase3(){
        List<User> testUser = UTL_TestData.createUser('System Administrator', 1);
        testUser[0].isActive = true;
        testUser[0].Change_Request_Description__c = 'test API Reactivation';
        insert testUser;

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/UserAccess/' + testUser[0].userName.substringBefore('@');
        req.httpMethod = 'GET';
        RestContext.request = req;
    
        Test.startTest();
        String result = InfrequentUser.validateUser();
        Test.stopTest();
        Map<String, Object> resultJSONMap  = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assertEquals(resultJSONMap.get('code'), 23);
    }

    @isTest
    static void testValidateUserCase4(){
        List<User> testUser = UTL_TestData.createUser('System Administrator', 1);
        testUser[0].isActive = false;
        testUser[0].Infrequent_User__c = false;
        insert testUser;

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/UserAccess/' + testUser[0].userName.substringBefore('@'); 
        req.httpMethod = 'GET';
        RestContext.request = req;

        Test.startTest();
        String result = InfrequentUser.validateUser();
        Test.stopTest();
        Map<String, Object> resultJSONMap  = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assertEquals(resultJSONMap.get('code'), 24);
    }

    @isTest
    static void testValidateUserCase5(){
        List<User> testUser = UTL_TestData.createUser('System Administrator', 1);
        testUser[0].isActive = false;
        testUser[0].Infrequent_User__c = true;
        testUser[0].Active_Inactive_Reason__c = 'Deactivation (Infrequent User)';
        insert testUser;

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/UserAccess/' + testUser[0].userName.substringBefore('@'); 
        req.httpMethod = 'GET';
        RestContext.request = req;

        Test.startTest();
        String result = InfrequentUser.validateUser();
        Test.stopTest();
        Map<String, Object> resultJSONMap  = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assertEquals(resultJSONMap.get('code'), 10);
    }

    @isTest
    static void testValidateUserCase6(){
        List<User> testUser = UTL_TestData.createUser('System Administrator', 1);
        testUser[0].isActive = false;
        testUser[0].Infrequent_User__c = true;
        insert testUser;
        testUser[0].Active_Inactive_Reason__c = 'New User';
        update testUser;

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/UserAccess/' + testUser[0].userName.substringBefore('@'); 
        req.httpMethod = 'GET';
        RestContext.request = req;

        Test.startTest();
        String result = InfrequentUser.validateUser();
        Test.stopTest();
        Map<String, Object> resultJSONMap  = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assertEquals(resultJSONMap.get('code'), 20);
    }

    @isTest
    static void testActivateUserCase1(){
        List<User> testUser = UTL_TestData.createUser('System Administrator', 1);
        testUser[0].isActive = false;
        testUser[0].Infrequent_User__c = true;
        testUser[0].Active_Inactive_Reason__c = 'Deactivation (Infrequent User)';
        insert testUser;

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/UserAccess/' + testUser[0].userName.substringBefore('@'); 
        req.httpMethod = 'POST';
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        String result = InfrequentUser.activateUser(testUser[0].id);
        Test.stopTest();
        Map<String, Object> resultJSONMap  = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assertEquals(resultJSONMap.get('code'), 30);
    }

    @isTest
    static void testActivateUserCase2(){
        List<User> testUser = UTL_TestData.createUser('System Administrator', 1);
        insert testUser;

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/UserAccess/' + testUser[0].userName.substringBefore('@');
        req.httpMethod = 'POST';
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        String result = InfrequentUser.activateUser(testUser[0].id);
        Test.stopTest();
        Map<String, Object> resultJSONMap  = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assertEquals(resultJSONMap.get('code'), 40);
    }

}