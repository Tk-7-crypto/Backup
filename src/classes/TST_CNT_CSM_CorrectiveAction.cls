@IsTest
private class TST_CNT_CSM_CorrectiveAction {
    @IsTest
    private static void testSaveShouldSave() {
        Corrective_Action__c correctiveAction = new Corrective_Action__c();
        correctiveAction.Type__c = 'Professionals';
        correctiveAction.Corrective_Field_Name__c = 'Address Submitted';
        correctiveAction.Corrective_Field_Value__c = 5;  
        
        CNT_CSM_CorrectiveAction.CorrectiveActionWrapper wrapper = new CNT_CSM_CorrectiveAction.CorrectiveActionWrapper();
        wrapper.correctiveAction = correctiveAction;
        wrapper.isShowFieldNameError = false;
        List<CNT_CSM_CorrectiveAction.CorrectiveActionWrapper> correctiveActionWrapperList = 
            new List<CNT_CSM_CorrectiveAction.CorrectiveActionWrapper>{wrapper};
         
        Boolean isError = false;
        
        Test.startTest();
            try{
                CNT_CSM_CorrectiveAction.save(JSON.serialize(correctiveActionWrapperList));           
            } catch(Exception ex) {
                isError = true;
            }
        Test.stopTest();
        
        List<Corrective_Action__c> correctiveActionList = [SELECT Id, Name FROM Corrective_Action__c];
        System.assertEquals(false, isError, 'Saved successfully');
        System.assertEquals(true, correctiveActionList.size() == 1, 'Saved successfully');
    }
    
    @IsTest
    private static void testCheckComponentVisibilityForAdmin() {
        List<User> listOfUser = UTL_TestData.createUser(CON_CSM.S_P_SYS_ADMIN, 1);
        insert listOfUser;
        User userToRunAs = listOfUser[0];
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: CON_CSM.S_DATA_RECORD_TYPE_US_FIELD_ACCESS];
        insert new PermissionSetAssignment(AssigneeId = userToRunAs.id, PermissionSetId = ps.Id);
        
        System.runAs(userToRunAs) {
            Test.startTest();
                Boolean isComponentVisible = CNT_CSM_CorrectiveAction.checkComponentVisibility();
            Test.stopTest();
            System.assertEquals(true, isComponentVisible, 'Component is visible for Admin User');
        }
    }
    
    @IsTest
    private static void testCheckComponentVisibility() {
        List<User> listOfUser = UTL_TestData.createUser(CON_CSM.S_PROFILENAME, 1);
        insert listOfUser;
        User userToRunAs = listOfUser[0];
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: CON_CSM.S_DATA_RECORD_TYPE_US_FIELD_ACCESS];
        insert new PermissionSetAssignment(AssigneeId = userToRunAs.id, PermissionSetId = ps.Id);
        
        System.runAs(userToRunAs) {
            Test.startTest();
                Boolean isComponentVisible = CNT_CSM_CorrectiveAction.checkComponentVisibility();
            Test.stopTest();
            System.assertEquals(true, isComponentVisible, 'Component is visible for Non-Admin User');
        }
    }
    
    @IsTest
    private static void testGetPickListValues() {
        Test.startTest();
            String picklistValues = CNT_CSM_CorrectiveAction.getPickListValues();
        Test.stopTest();
        System.assertEquals(true, picklistValues != null , 'Got picklist values');
    }
    
    @IsTest
    private static void testGetDependentPicklistMap() {
        
        Test.startTest();
            Map<String, List<String>> picklistValuesMap = CNT_CSM_CorrectiveAction.getDependentPicklistMap('Corrective_Action__c', 'Type__c', 'Corrective_Field_Name__c');
        Test.stopTest();
        
        System.assertEquals(true, picklistValuesMap != null, 'Got dependant corrective field picklist map');
    }
}