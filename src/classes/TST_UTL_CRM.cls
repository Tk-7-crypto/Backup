/**
* This test class is used to test all methods in UTL_CRM class.
* version : 1.0
*/
@isTest
private class TST_UTL_CRM {
    
    /**
	 * This test method used for testing UTL_CRM GetCurrentUserProfileName method
	 */ 
    static testMethod void testGetCurrentUserProfileName() {
        List<Profile> profileList = [SELECT Id, Name FROM Profile WHERE Id= :userInfo.getProfileId()];
        String expectedProfileName = profileList[0].Name;
        String actualProfileName;
        Test.startTest();
        actualProfileName = UTL_CRM.getCurrentUserProfileName();
        Test.stopTest();
        System.assertEquals(expectedProfileName, actualProfileName);
    }
    
    /**
	 * This test method used for testing UTL_CRM Encrypt Password method
	 */
    static testMethod void testEncryptPassword() {
        String actualEncryptedPassword;
        String password = 'abc123';
        Test.startTest();
        actualEncryptedPassword = UTL_CRM.encryptPassword(password);
        System.assertNotEquals(password, actualEncryptedPassword);
        actualEncryptedPassword = UTL_CRM.encryptPassword(null);
        System.assertEquals('', actualEncryptedPassword);
        actualEncryptedPassword = UTL_CRM.encryptPassword('');
        System.assertEquals('', actualEncryptedPassword);
        Test.stopTest();   
    }
    
    /**
	 * This test method used for testing UTL_CRM Decrypt Password method
	 */
    static testMethod void testDecryptPassword() {
        String encryptedPassword;
        String actualDecryptedPassword;
        Test.startTest();
        encryptedPassword = UTL_CRM.encryptPassword('qwerty123');
        actualDecryptedPassword = UTL_CRM.decryptPassword(encryptedPassword);
        System.assertEquals('qwerty123', actualDecryptedPassword);
        encryptedPassword = UTL_CRM.encryptPassword('12ASDWER');
        actualDecryptedPassword = UTL_CRM.decryptPassword(encryptedPassword);
        System.assertEquals('12ASDWER', actualDecryptedPassword);
        encryptedPassword = UTL_CRM.encryptPassword(null);
        actualDecryptedPassword = UTL_CRM.decryptPassword(encryptedPassword);
        System.assertEquals('', actualDecryptedPassword);
        encryptedPassword = UTL_CRM.encryptPassword('');
        actualDecryptedPassword = UTL_CRM.decryptPassword(encryptedPassword);
        System.assertEquals('', actualDecryptedPassword);
        Test.stopTest();
    }
    
    static testMethod void testgetDateFormatFromLocale(){
        String localeCode = 'zh_TW';
        Test.startTest();
        String dateFormat = UTL_CRM.getDateFormatFromLocale(localeCode);
        System.assertEquals('yyyy/M/d', dateFormat);
        Test.stopTest();
    }
}