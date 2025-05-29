/*
 * Test Class for Apex Batch : BCH_Devops_PostSandboxCreation 
*/
@IsTest
public class TST_BCH_Devops_PostSandboxCreation {
    
	@IsTest
    static void testMFAPermissionRemoval() {
        List<User> userList = UTL_TestData.createUser('System Administrator', 1);
        userList[0].isActive = true;
        insert userList;
        
        PermissionSet pr = [SELECT Id from permissionset where Label  = 'Multi-Factor Authentication for UI Login'];

		PermissionSetAssignment pm = new PermissionSetAssignment(AssigneeId=userList[0].id,PermissionSetId=pr.id);
		insert pm;
        Test.startTest();
        BCH_Devops_PostSandboxCreation bch = new BCH_Devops_PostSandboxCreation();
        Database.executeBatch(bch, 200);
        Test.stopTest();
    }
}