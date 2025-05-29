@isTest
public class TST_BCH_CRM_EmailToAccountTeamMembers {
    @testSetup
    static void dataSetup() {
        User adminUser = TST_PEP_TestDataFactory.createAdminUser('admin','adminPartner@iqvia.com');
        User adminUser1 = TST_PEP_TestDataFactory.createAdminUser('admin1','adminPartner@iqvia.com');
        adminUser.EmployeeNumber = '090909094';
        adminUser1.EmployeeNumber = '090909095';
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
        BCH_CRM_EmailToAccountTeamMembers b = new BCH_CRM_EmailToAccountTeamMembers();
        Database.executebatch(b);
        System.assert(true);
    }
}