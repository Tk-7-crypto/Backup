/**
 * This test class is used to test all methods in UTL_GLOBAL class.
 * version : 1.0
 */
@isTest
private class TST_UTL_GLOBAL {
    /**
     * This test method used for testing getCurrentReleaseVersion method with null value
     */ 
    static testMethod void testgetCurrentReleaseVersionWithNullValue() {
        Test.startTest();
            UTL_GLOBAL.getCurrentReleaseVersion();
        Test.stopTest();
    }
    
    /**
     * This test method used for testing getCurrentReleaseVersion method
     */ 
    static testMethod void testgetCurrentReleaseVersion() {
        Current_Release_Version__c testReleaseVersionSetting = new Current_Release_Version__c();
        testReleaseVersionSetting.Current_Release__c = '3000.12';
        insert testReleaseVersionSetting;
        Test.startTest();
            Double value = UTL_GLOBAL.getCurrentReleaseVersion();
        Test.stopTest();
        
        System.assertEquals(3000.12, value, 'Current Release should be same');
    }
    
    static testMethod void testGetUserWithProfile() {
        List<User> userList = UTL_TestData.createUser('Standard User', 1);
        userList[0].IsActive = true;
        insert userList;
        Integer value;
        Map<Id, User> actualUserMap;
        Id userId = userList[0].Id;
        Test.startTest();
        	UTL_GLOBAL.getUserWithProfile(new Set<Id>{userId});
        	actualUserMap = UTL_GLOBAL.getUserWithProfile(new Set<Id>{userId});
        	value = Limits.getQueries();
        Test.stopTest();
        
        System.assertEquals(1, value, 'Same User should query only one time');
        System.assertEquals('Standard User', actualUserMap.get(userId).Profile.Name, 'User Should be having Standard User Profile');
        System.assertNotEquals(null, actualUserMap.get(userId).Profile.Name);
    }
    
    static testMethod void testGetProfile() {
        Profile profile = [Select id From Profile Where Name like 'System Administrator'];
        Test.startTest();
        	UTL_GLOBAL.getProfile(new Set<Id>{profile.Id});
        	UTL_GLOBAL.getProfile(new Set<Id>{profile.Id});
        	Integer value = Limits.getQueries();
        Test.stopTest();
        
        System.assertEquals(1, value, 'Same Profile should query only one time');
    }
    
    static testMethod void testGetCurrencyType() {
        Test.startTest();
        	UTL_GLOBAL.getCurrencyType();
        	UTL_GLOBAL.getCurrencyType();
        	Integer value = Limits.getQueries();
        Test.stopTest();
        
        System.assertEquals(1, value, 'Same CurrencyType should query only one time');
    }
	
	@isTest
    private static void testSendEmail(){
        List<string> toAddresses = new List<String>{'abc@metacube.com'};
        String subject = 'Test Subject';
        String body = 'Test Body';
        Test.startTest();
            UTL_Global.sendEmail(toAddresses, subject,body);
            Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();
        System.assertEquals(1, invocations);
    }
    
    @isTest
    private static void testConcatenateException(){
        DmlException exc = new DmlException();
        exc.setMessage('Test Exception Failure');
        Test.startTest();
        	String result = UTL_Global.concatenateException(exc);
        Test.stopTest();
        System.assertNotEquals(null, result);
    }
}
