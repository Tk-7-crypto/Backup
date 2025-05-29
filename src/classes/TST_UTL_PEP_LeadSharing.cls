@isTest
private class TST_UTL_PEP_LeadSharing {
    
    @testSetup
    public static void prmDataSetup(){
        User partnerUser = TST_PEP_TestDataFactory.createPartnerUser('partneruser@iqvia.partner.com');
        partnerUser.PortalRole = 'Manager';
        partnerUser.EmployeeNumber = '9098789';
        Account acc = [select id from account where name = 'Acme'];
        User partnerUser2 = TST_PEP_TestDataFactory.createPartnerUserByAccount('partneruser2@iqvia.partner.com',acc);
        partnerUser2.PortalRole = 'Worker';
		partnerUser2.EmployeeNumber = '90938789';
        User pim1 = TST_PEP_TestDataFactory.createPartnerUserByAccount('pim1@iqvia.partner.com', acc);        
        pim1.PortalRole = 'Manager';
		pim1.EmployeeNumber = '9093874589';
        /*User pim2 = TST_PEP_TestDataFactory.createPartnerUserByAccount('pim2@iqvia.partner.com', acc);        
        pim2.PortalRole = 'Manager';
		pim2.EmployeeNumber = '9093874689';*/
        User adminUser = TST_PEP_TestDataFactory.createAdminUser('admin','adminPartner@iqvia.com');        
        adminUser.EmployeeNumber = '9093854789';
        Account partnerAcc = TST_PEP_TestDataFactory.createAccount('Digitas');
        insert partnerAcc;
        
        User partnerUserAcc2 = TST_PEP_TestDataFactory.createPartnerUserByAccount('partnerUserAcc2@iqvia.partner.com',partnerAcc);
        partnerUser2.PortalRole = 'Worker';

        User pim1Acc2 = TST_PEP_TestDataFactory.createPartnerUserByAccount('pim1Acc2@iqvia.partner.com', partnerAcc);        
        pim1.PortalRole = 'Manager';

        /*User pim2Acc2 = TST_PEP_TestDataFactory.createPartnerUserByAccount('pim2Acc2@iqvia.partner.com', partnerAcc);        
        pim2.PortalRole = 'Manager';*/
        
        List<User> lstUsers = new List<User>{partnerUser, partnerUser2, pim1, adminUser, partnerUserAcc2, pim1Acc2};
        insert lstUsers;

        AccountTeamMember atm = TST_PEP_TestDataFactory.createAccountTeamMember(acc,
                        lstUsers[0].id, 'Alliance Manager' );
        insert atm;
    }

    static testMethod void testPRMUpdateLead() {
        User partnerUser = [SELECT id,AccountId FROM User WHERE email='partneruser@iqvia.partner.com'];
        System.runAs(partnerUser){
            Lead led = TST_PEP_TestDataFactory.createLead('lead2@yopmail.com', 
                            'OneKey','ABC2 company', 'Jones', 'Dr.');
            led.OwnerId = partnerUser.Id;

            Lead led2 = TST_PEP_TestDataFactory.createLead('lead11@yopmail.com', 
                            'OneKey','ABC company1', 'Jones', 'Dr.');
            led2.OwnerId = partnerUser.Id;
            List<Lead> lstLead = new List<Lead>{led,led2};            
            Test.startTest();
                insert lstLead;
                led.Product__c = 'OCE Personal';          
                led2.Product__c = 'OCE Digital';       
                update lstLead;
                Integer invocations = Limits.getEmailInvocations();
            Test.stopTest();
            //system.assertEquals(0, invocations);
         }       
     
    }
}
