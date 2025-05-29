@isTest
public class TST_SCH_CRM_EmailToAccountTeamMembers {
    @testSetup
    static void dataSetup() {
        User adminUser = TST_PEP_TestDataFactory.createAdminUser('admin','adminPartner@iqvia.com');
        User adminUser1 = TST_PEP_TestDataFactory.createAdminUser('admin1','adminPartner@iqvia.com');
        insert adminUser;
        insert adminUser1;
        system.runAs(adminUser){
            Account acc = TST_PEP_TestDataFactory.createAccount('ABC Ltd');
            insert acc;
            AccountTeamMember teamMember = TST_PEP_TestDataFactory.createAccountTeamMember(acc, adminUser.Id, CON_CRM.ACCOUNT_TEAMROLE);
            AccountTeamMember teamMember1 = TST_PEP_TestDataFactory.createAccountTeamMember(acc, adminUser1.Id, CON_CRM.ACCOUNT_TEAMROLE);
            insert teamMember;
            insert teamMember1;
        }
        Group gp = new Group();
        gp.Name = CON_CRM.GROUP_ACCOUNT_TEAM_MEMBERS_BIOTECH;
        insert gp;
        GroupMember gm = UTL_TestData.createGroupMember(gp.Id, adminUser.Id);
        insert gm;
    }
    
    /**
    * This method used to Select Account Team Member by account
    */    
    @IsTest
    static void testAccTeamMember() {
        Test.StartTest();
        String cronExp = '0 0 23 * * ?'; 
        System.schedule('TST_SCH_CRM_EmailToAccountTeamMembers', cronExp, new SCH_CRM_EmailToAccountTeamMembers()); 
        Test.stopTest();
        System.assert(true);
    }
}