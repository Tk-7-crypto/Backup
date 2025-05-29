/*
 * This is the test class for Just-In_Time User Provisioning custom handler : 'JITHandler'.
*/
@isTest
private class TST_JITHandler {
    
    @testSetup
    static void setup() {
        User_Activation_Input_Variables__c userConfig = new User_Activation_Input_Variables__c(Name = 'BusinessLogic');
        userConfig.Number_Of_Days_From_Last_Login__c = 100;
        userConfig.Failure_Notification_Emails__c = 'ritvik.bhomia@metacube.com';
        userConfig.PSA_Admin_Email_Address__c = 'arun.james@iqvia.com';
        userConfig.Sales_Admin_Email_Address__c = 'arun.james@iqvia.com';
        userConfig.Service_Admin_Email_Address__c = 'arun.james@iqvia.com';
        insert userConfig;
    }
    
    @isTest
    static void testCreateUser() {
        JITHandler handler = new JITHandler();
        String pid =[Select Id from Profile Where name ='Standard User'].Id ;
        Map<string,String> tempUser=  new Map<String, String>
        {'language' => 'en_US' ,
            'Username'=>'testaskdhjkasdj@sdjkfhsjd.com' ,
            'LastName'=>'asdjhgasjhd',
            'Email'=>'askdasgdhgas@sdjkfd.com',
            'Alias'=>'asdhagsd',
            'CommunityNickname'=>'asdjasgdjhahsdhasd',
            'TimeZoneSidKey'=>'America/Los_Angeles',
            'LocaleSidKey'=>'en_US',
            'EmailEncodingKey'=>'UTF-8',
            'ProfileId'=>pid,
            'LanguageLocaleKey'=>'en_US' }; 
                
        test.startTest();
        User u = handler.createUser(null,null,null,'', tempUser ,null);
        test.stopTest();  
        System.assertEquals(null, u);
    }

    @isTest
    static void testUpdateUserCase1() {
        JITHandler handler = new JITHandler();
                
        List<User> testUser = UTL_TestData.createUser('Standard User', 1);
        testUser[0].isActive = false;
        testUser[0].Infrequent_User__c = false;
        insert testUser[0];
        String userId = testUser[0].id;
        
        String pid =[Select Id from Profile Where name ='Standard User'].Id ;
        Map<string,String> tempUser=  new Map<String, String>
        {'language' => 'en_US' ,
            'Username'=> testUser[0].Username ,
            'LastName'=> testUser[0].LastName,
            'Email'=> testUser[0].Email,
            'Alias'=> testUser[0].Alias,
            'TimeZoneSidKey'=> testUser[0].TimeZoneSidKey,
            'LocaleSidKey'=>'en_US',
            'EmailEncodingKey'=>'UTF-8',
            'ProfileId'=> pid,
            'LanguageLocaleKey'=>'en_US' }; 
		try {
            test.startTest();        
            handler.updateUser(userId,null,null,null, '', tempUser,null);
            test.stopTest();
        } catch(Exception e) {
            System.assert(e.getMessage().contains('#Profile.Name'));
        }          
    }

    @isTest
    static void testUpdateUserCase2() {
        JITHandler handler = new JITHandler();
                
        List<User> testUser = UTL_TestData.createUser('Standard User', 1);
        testUser[0].isActive = false;
        testUser[0].Infrequent_User__c = false;
        insert testUser[0];
        String userId = testUser[0].id;
        String pid =[Select Id from Profile Where name ='Standard User'].Id ;
        Map<string,String> tempUser=  new Map<String, String>
        {'language' => 'en_US' ,
            'Username'=> testUser[0].Username ,
            'LastName'=> testUser[0].LastName,
            'Email'=> testUser[0].Email,
            'Alias'=> testUser[0].Alias,
            'TimeZoneSidKey'=> testUser[0].TimeZoneSidKey,
            'LocaleSidKey'=>'en_US',
            'EmailEncodingKey'=>'UTF-8',
            'ProfileId'=> pid,
            'LanguageLocaleKey'=>'en_US' }; 
		try {
            test.startTest();        
            handler.updateUser(null,null,null,null, '', tempUser,null);
            test.stopTest();
        } catch(Exception e) {
			
        }          
    }
}