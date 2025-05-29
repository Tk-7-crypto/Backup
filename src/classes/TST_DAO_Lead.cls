/**
 * This test class is used to test all methods in Lead Domain class.
 * version : 1.0
 */
@isTest
private class TST_DAO_Lead {
    
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
		pim2.EmployeeNumber = '9093874689'; */
        User adminUser = TST_PEP_TestDataFactory.createAdminUser('admin','adminPartner@iqvia.com');        
        adminUser.EmployeeNumber = '9093854789';
        Account partnerAcc = TST_PEP_TestDataFactory.createAccount('Digitas');
        insert partnerAcc;
        
        User partnerUserAcc2 = TST_PEP_TestDataFactory.createPartnerUserByAccount('partnerUserAcc2@iqvia.partner.com',partnerAcc);
        partnerUser2.PortalRole = 'Worker';

        User pim1Acc2 = TST_PEP_TestDataFactory.createPartnerUserByAccount('pim1Acc2@iqvia.partner.com', partnerAcc);        
        pim1.PortalRole = 'Manager';

        /*User pim2Acc2 = TST_PEP_TestDataFactory.createPartnerUserByAccount('pim2Acc2@iqvia.partner.com', partnerAcc);        
        pim2.PortalRole = 'Manager'; */
        
        List<User> lstUsers = new List<User>{partnerUser, partnerUser2,pim1, adminUser, partnerUserAcc2, pim1Acc2};
        insert lstUsers;

        AccountTeamMember atm = TST_PEP_TestDataFactory.createAccountTeamMember(acc,
                        lstUsers[0].id, 'Alliance Manager' );
        insert atm;
    }

    /**
     * This test method used for insert Lead record
     */ 
    static testMethod void testInsertLead() {
        test.startTest();
            Lead newLead = UTL_TestData.createLead();
            newLead.Status= 'Registered';
            newLead.Product__c= 'OneKey';
            newLead.FirstName= 'Test Name';
            newLead.Status='Not Started';
            insert newLead;
        test.stopTest();
        Lead existingLead = [SELECT Id, Invalid_Email_Address__c, Consented_to_Marketing_Emails__c FROM Lead LIMIT 1];
        //System.assertEquals(true, existingLead.Invalid_Email_Address__c);
        System.assertEquals(null, existingLead.Consented_to_Marketing_Emails__c);
    }
    
    /**
     * This test method used for update Lead record
     */ 
    static testMethod void testUpdateLead() {
        test.startTest();
            Lead newLead = UTL_TestData.createLead();
            newLead.Email = 'test123@iqvia.com';
            newLead.Status='Not Started';
            insert newLead;
            newLead.Email = null;
            update newLead;
        test.stopTest();
        Lead existingLead = [SELECT Id, Invalid_Email_Address__c, Consented_to_Marketing_Emails__c FROM Lead LIMIT 1];
        //System.assertEquals(true, existingLead.Invalid_Email_Address__c);
        //System.assertEquals(null, existingLead.Consented_to_Marketing_Emails__c);
    }

    /**
     * This test method to insert PRM lead
     */ 
    static testMethod void testPRMInsertLead() {
        User partnerUser = [SELECT id,AccountId FROM User WHERE email='partneruser@iqvia.partner.com'];        
        System.runAs(partnerUser){            
            Lead led = TST_PEP_TestDataFactory.createLead('lead1@yopmail.com', 
                            'OneKey','ABC company', 'Jones', 'Dr.');
            led.OwnerId = partnerUser.Id;
            Lead led2 = TST_PEP_TestDataFactory.createLead('lead11@yopmail.com', 
                            'OneKey','ABC company1', 'Jones', 'Dr.');
            led2.OwnerId = partnerUser.Id;
            List<Lead> lstLead = new List<Lead>{led,led2};

            Test.startTest();               
                insert lstLead;
                Integer invocations = Limits.getEmailInvocations();
            Test.stopTest();
            //system.assertEquals(1, invocations);
         }            
    }

    /**
     * This test method to update PRM lead
     */ 
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

    static testMethod void testPRMInsertLeadSetAllMgr() {
        User adminUser = [SELECT id FROM User WHERE email='adminPartner@iqvia.com'];
        User partnerUser = [SELECT id,AccountId FROM User WHERE email='partneruser@iqvia.partner.com']; 
        System.runAs(adminUser){            
            Lead led = TST_PEP_TestDataFactory.createLead('lead1@yopmail.com', 
                            'OneKey','ABC company', 'Jones', 'Dr.');
            led.TECH_Partner_Account__c = partnerUser.AccountId;

            Test.startTest();               
                insert led;
                Integer invocations = Limits.getEmailInvocations();
            Test.stopTest();
            system.assertEquals(0, invocations);
         }            
    }

    /**
     * This test method to update PRM owner
     */ 
    static testMethod void testPRMUpdateOwner() {
        User partnerUser = [SELECT id,AccountId FROM User WHERE email='partneruser@iqvia.partner.com'];
        User adminUser = [SELECT id FROM User WHERE email='adminPartner@iqvia.com'];
        System.runAs(adminUser){
            Lead led = TST_PEP_TestDataFactory.createLead('lead3@yopmail.com', 
                            'OneKey','ABC3 company', 'Jones', 'Dr.');
            led.OwnerId = partnerUser.Id;
            Test.startTest();
                insert led;
                led.OwnerId = [select id from group where developerName = 'Partner_Referral_Leads' and type='Queue'].Id;
                update led;
                Integer invocations = Limits.getEmailInvocations();
            Test.stopTest();
            List<User> lstPartners = [select id from User where AccountId =:partnerUser.AccountId];
            List<LeadShare> lstLeadShare = [select id from LeadShare where 
                                            LeadId =:led.Id and UserOrGroupId IN :lstPartners
                                            and RowCause =:Schema.LeadShare.RowCause.Manual];
 
            system.assertEquals(0, invocations);    
            system.assertEquals(3, lstLeadShare.size()); 
         }       
     
    }

    /**
     * This test method to update PRM lead status
     */ 
    static testMethod void testPRMUpdateStatusRejected() {
        User partnerUser = [SELECT id,AccountId FROM User WHERE email='partneruser@iqvia.partner.com'];
        User adminUser = [SELECT id FROM User WHERE email='adminPartner@iqvia.com'];
        System.runAs(partnerUser){
            Lead led = TST_PEP_TestDataFactory.createLead('lead3@yopmail.com', 
                            'OneKey','ABC3 company', 'Jones', 'Dr.');
            led.OwnerId = partnerUser.Id;
            System.runAs(adminUser){
                Test.startTest();  
                    insert led;
                    led.Status = CON_PEP.S_PEP_LD_STATUS_REJECTED;
                    led.Reason_Code__c = 'Other';
                    led.Comment__c ='not valid';         
                    update led;
                    Integer invocations = Limits.getEmailInvocations();
                Test.stopTest();
                //system.assertEquals(1, invocations);
            }
         }       
     
    }

    /**
     * This test method to update PRM lead status
     */ 
/*    static testMethod void testPRMUpdateStatusConverted() {
        User partnerUser = [SELECT id,AccountId FROM User WHERE email='partneruser@iqvia.partner.com'];
        User adminUser = [SELECT id FROM User WHERE email='adminPartner@iqvia.com'];
        Account acc = [select id from account where name = 'Acme'];
        System.runAs(partnerUser){
            Lead led = TST_PEP_TestDataFactory.createLead('lead4@yopmail.com', 
                            'OneKey','ABC4 company', 'Jones', 'Dr.');
            led.OwnerId = partnerUser.Id;
            insert led;
            System.runAs(adminUser){
                Test.startTest();  
                    Database.LeadConvert lc = new Database.LeadConvert();
                    lc.setLeadId(led.id);
                    LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
                    lc.setConvertedStatus(convertStatus.MasterLabel);
                    lc.setAccountId(acc.Id);
                    Database.convertLead(lc);
                    Integer invocations = Limits.getEmailInvocations();
                Test.stopTest();
                system.assertEquals(1, invocations);
            }
         }       
     
    }*/

    /**
     * This test method to update PRM lead Partner Account
     */ 
    static testMethod void testAMUpdateLeadPartnerAc() {
        User adminUser = [SELECT id,AccountId FROM User WHERE email='adminPartner@iqvia.com'];
        Account ac =[SELECT id, name from Account where name='Digitas'];
        Account ac1 = [select id from account where name = 'Acme'];
        System.runAs(adminUser){
                             
             Lead led = TST_PEP_TestDataFactory.createLead('lead2@yopmail.com', 
                            'OneKey','ABC2 company', 'Jones', 'Dr.');
            led.TECH_Partner_Account__c = ac1.Id;
            Test.startTest();
            insert led;
            Lead ledToUpd = [SELECT Id, Tech_Partner_Account__c from Lead where Id =: led.Id];
            ledToUpd.Tech_Partner_Account__c = ac.Id; 
            update ledToUpd;
            Integer invocations = Limits.getEmailInvocations();
            Test.stopTest();
            List<User> lstPartners = [select id from User where AccountId =:ac.Id];
            List<LeadShare> lstLeadShare = [select id from LeadShare where 
                                            LeadId =:led.Id and UserOrGroupId IN :lstPartners
                                            and RowCause =:Schema.LeadShare.RowCause.Manual];
 
            system.assertEquals(0, invocations);    
            system.assertEquals(2, lstLeadShare.size()); 
         }       
     
    }
}