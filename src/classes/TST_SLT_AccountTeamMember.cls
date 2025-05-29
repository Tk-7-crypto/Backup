/*
 * Version       : 1.0
 * Description   : This test class is used for Select AccountTeamMember
 */
@isTest
private  class TST_SLT_AccountTeamMember {
    
    /**
     * This method used to set up testdata
     */ 
    @testSetup
    static void dataSetup() {
        User adminUser = TST_PEP_TestDataFactory.createAdminUser('admin','adminPartner@iqvia.com');
        adminUser.EmployeeNumber = '07070756';
        insert adminUser;

        system.runAs(adminUser){
	        Account acc = TST_PEP_TestDataFactory.createAccount('ABC Ltd');
	        insert acc;
	        AccountTeamMember teamMember = TST_PEP_TestDataFactory.createAccountTeamMember(acc, adminUser.Id, CON_PEP.ALLIANCE_MANAGER);
	        insert teamMember;
	    }
    }
    
    /**
     * This method used to Select Account Team Member by account
     */    
    @IsTest
    static void testAccTeamMember() {
        User adminUser = [SELECT id FROM User WHERE email='adminPartner@iqvia.com'];
        List<AccountTeamMember> accTeamMemberList = null;
        Account acc = [SELECT Id FROM Account LIMIT 1];
        System.runAs(adminUser){
	        Test.startTest();
	            accTeamMemberList = new SLT_AccountTeamMember().selectByAccountId(new set<Id>{acc.id},CON_PEP.ALLIANCE_MANAGER);
	        Test.stopTest();
	        System.assertEquals(1, accTeamMemberList.size());
	    }
    }
}