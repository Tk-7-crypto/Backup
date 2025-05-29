@isTest
public without sharing class TST_SRV_Group {
    
    @testSetup
    static void dataSetup() {
        List<Group> groupList = new List<Group>();
        for(Integer index=1;index<=2;index++) {
            Group groupRecord = UTL_TestData.createGroup('Test Group '+index,'Regular');
        	groupList.add(groupRecord);
        }
        insert groupList;           
        
        Credit_Control_Groups__c creditControlGroups = new Credit_Control_Groups__c();         
        creditControlGroups.Name = 'Group_Names__c';        
        creditControlGroups.Group_Names__c = 'Test Group 1,Test Group 2';        
        insert creditControlGroups;
    }
    
    /**
     * method to test getGroups() method.
     */
    @isTest
    public static void testGetGroups() {
        Test.startTest();
        List<Group> expectedUserList = SRV_Group.getGroups();
        Test.stopTest();
        System.assertEquals(expectedUserList.size(), 2);
    }

    /**
     * method to test showButtonsForUser() method.
     */
    @isTest public static void testShowButtonsForUser() {
        Test.startTest();
        Boolean result = SRV_Group.showButtonsForUser();
        Test.stopTest();
        System.assertEquals(result,false);
    }

    /**
     * method to test showLwcSearchComponent() method.
     */
    @isTest public static void testShowLwcSearchComponent() {
        Test.startTest();
        Boolean result = SRV_Group.showLwcSearchComponent();
        Test.stopTest();
        System.assertEquals(result,false);
    }
}