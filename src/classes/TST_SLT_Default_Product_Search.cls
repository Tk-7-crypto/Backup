/*
 * Version       : 1.0
 * Description   : Test class for SLT_Default_Product_Search
 */
@isTest
private class TST_SLT_Default_Product_Search {
    
    /**
     * test Data Setup
     */
    @testSetup
    static void testDataSetup() {
        String profileName = CON_CRM.SYSTEM_ADMIN_PROFILE;
        List<User> userList = UTL_TestData.createUser(profileName, 1);
        insert userList;
        Default_Product_Search__c defaultSearch = UTL_TestData.createDefaultProductSearch(userList[0].Id);
        insert defaultSearch;
    }
    
    /**
     * test method for getDefaultProductSearchByUsers
     */
    static testmethod void testGetDefaultProductSearchByUsers() {
        List<User> userList = [SELECT id FROM user WHERE lastName = 'lastName123' limit 1];
        Set<String> fieldSet = new Set<String>{'Id', 'User__c'};
        Test.startTest();
            List<Default_Product_Search__c> defaultSearchList = new SLT_Default_Product_Search().getDefaultProductSearchByUsers(new Set<Id>{userList[0].Id}, fieldSet);
        Test.stopTest();
        Integer expected = 1;
        Integer actual = defaultSearchList.size();
        System.assertEquals(expected, actual);
    }
    
}