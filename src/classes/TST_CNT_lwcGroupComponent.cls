@isTest
public without sharing class TST_CNT_lwcGroupComponent {
    
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
     * method to test retriveUsersByName() method.
     */
    @isTest
    public static void testRetriveGroups() {
        Test.startTest();
        List<Group> expectedUserList = CNT_lwcGroupComponent.retriveGroups();
        Test.stopTest();
        System.assertEquals(expectedUserList.size(), 2);
    }

    /**
     * method to test showButtons() method.
     */
    @isTest public static void testShowButtons() {
        Test.startTest();
        Boolean result = CNT_lwcGroupComponent.showButtons();
        Test.stopTest();
        System.assertEquals(result,false);
    }

    /**
     * method to test showLwcSearchComponent() method.
     */
    @isTest public static void testShowAddUserCompoent() {
        Test.startTest();
        Boolean result = CNT_lwcGroupComponent.showAddUserCompoent();
        Test.stopTest();
        System.assertEquals(result,false);
    }
}