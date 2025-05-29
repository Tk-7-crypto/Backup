@isTest
private class TST_SRV_CRM_Default_Product_Search {
    
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
     * test method for updateDefaultProductSearchFilter
     */
    static testmethod void testUpdateDefaultProductSearchFilter() {
        List<Default_Product_Search__c> defaultSearchList = [SELECT id FROM Default_Product_Search__c WHERE user__r.lastName = 'lastName123' limit 1];
        defaultSearchList[0].Default_Offering_Group__c = 'Test';
        Test.startTest();
            SRV_CRM_Default_Product_Search.updateDefaultProductSearchFilter(defaultSearchList);
        Test.stopTest();
        defaultSearchList = [SELECT id FROM Default_Product_Search__c WHERE Default_Offering_Group__c = 'Test'];
        Integer expected = 1;
        Integer actual = defaultSearchList.size();
        System.assertEquals(expected, actual);
    }
    
    /**
     * test method for updateDefaultProductSearchFilter with Exception
     */
    static testmethod void testUpdateDefaultProductSearchFilterException() {
        List<Default_Product_Search__c> defaultSearchList = [SELECT id FROM Default_Product_Search__c WHERE user__r.lastName = 'lastName123' limit 1];
        String  offeringGroup = '';
        Integer i = 0;
        while(i < 500) {
            offeringGroup += 'Test';
            i++;
        }
        defaultSearchList[0].Default_Offering_Group__c = offeringGroup;
        Test.startTest();
            try {
                SRV_CRM_Default_Product_Search.updateDefaultProductSearchFilter(defaultSearchList);
                System.assert(false);
            } catch(Exception ex) {
                System.assertEquals('SRV_CRM_Default_Product_Search.DefaultProductSearchException', ex.getTypeName());
            }
        Test.stopTest();
    }
    
    /**
     * test method for getDefaultProductSearchFilter
     */
    static testmethod void testGetDefaultProductSearchFilter() {
        List<User> userList = [SELECT id FROM user WHERE lastName = 'lastName123' limit 1];
        Set<String> fieldSet = new Set<String>{'Id', 'User__c'};
        Test.startTest();
            List<Default_Product_Search__c> defaultSearchList = SRV_CRM_Default_Product_Search.getDefaultProductSearchFilter(new Set<Id>{userList[0].Id}, fieldSet);
        Test.stopTest();
        Integer expected = 1;
        Integer actual = defaultSearchList.size();
        System.assertEquals(expected, actual);
    }
    
    /**
     * test method for getDefaultProductSearchFilter with Exception
     */
    static testmethod void testGetDefaultProductSearchFilterException() {
        List<User> userList = [SELECT id FROM user WHERE lastName = 'lastName123' limit 1];
        Set<String> fieldSet = new Set<String>{'Id', 'User__'};
        Test.startTest();
        try {
            List<Default_Product_Search__c> defaultSearchList = SRV_CRM_Default_Product_Search.getDefaultProductSearchFilter(new Set<Id>{userList[0].Id}, fieldSet);
        } catch(Exception ex) {
            System.assertEquals('SRV_CRM_Default_Product_Search.DefaultProductSearchException', ex.getTypeName());
        }   
        Test.stopTest();
    }
}