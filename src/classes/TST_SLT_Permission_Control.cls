/**
 * This test class is used to test all methods in SLT_Permission_Control class
 * version : 1.0
 */
@isTest
private class TST_SLT_Permission_Control {

     /**
     * This test method used to cover basic methods
     */ 
    static testmethod void testGetPermissionControlId(){
        PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'OWF_Triage_Manager'];
        SLT_Permission_Control sltPermissionControl = new SLT_Permission_Control();
        SLT_Permission_Control sltPermissionControl1 = new SLT_Permission_Control(true);
        SLT_Permission_Control sltPermissionControl2 = new SLT_Permission_Control(true,true);
        Test.startTest();
        Map<Id, pse__Permission_Control__c> permissionControlMap = 
            sltPermissionControl.getPermissionControlId(new Set<ID> {ps.id}, new Set<String> {'Id'});
        Test.stopTest();
    }
}
