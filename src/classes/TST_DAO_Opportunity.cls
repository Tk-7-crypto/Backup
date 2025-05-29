/**
* This test class is used to test all methods in opportunity trigger helper.
* version : 1.0
*/
@isTest
private class TST_DAO_Opportunity {
    
    /**
    * This method is used to setup data for all methods.
    */
    @testSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Contact cnt = UTL_TestData.createContact(acc.Id);
        insert cnt;

        User partnerUser = TST_PEP_TestDataFactory.createPartnerUser('partneruser@iqvia.partner.com');
        partnerUser.PortalRole = 'Worker';
        partnerUser.EmployeeNumber = '123543';
        User adminUser = TST_PEP_TestDataFactory.createAdminUser('admin','adminPartner@iqvia.com');
        adminUser.EmployeeNumber = '1234543';
        List<User> lstUsers = new List<User>{partnerUser, adminUser};
        insert lstUsers;
    }
    
    /**
    * This test method used for insert and update opportunity record
    */ 
    static testMethod void testOpportunityUpdateStage() {   
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        Test.startTest();
            insert opp;
            opp.StageName = CON_CRM.QUALIFYING_OPP_STAGE;
            Contact cnt = [SELECT id FROM Contact WHERE LastName = 'TestContact'];
            OpportunityContactRole contactRole = UTL_TestData.createOpportunityContactRole(cnt.Id, opp.Id);
            insert contactRole;
            Product2 product = UTL_TestData.createProduct();
            insert product;
            PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
            insert pbEntry;
            OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
            insert oppLineItem;
            update opp;
        Test.stopTest();
        List<Opportunity> OppList = [SELECT id , stageName FROM Opportunity WHERE name = 'TestOpportunity'];
        String expected = CON_CRM.QUALIFYING_OPP_STAGE;
        String actual = OppList[0].stageName;
        System.assertEquals(expected, actual);
    }
    
    /**
    * This test method used to create OutboundMessageDeletionQueue
    */ 
    static testMethod void testCreateOutboundMessageDeletionQueue() {   
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        Test.startTest();
            insert opp;
            List<Opportunity> oppList = [SELECT Id FROM Opportunity];
            delete oppList;
            List<Outbound_Message_Deletion_queue__c> outboundList = [SELECT Id FROM Outbound_Message_Deletion_queue__c LIMIT 1];
        Test.stopTest();
        System.assertEquals(1, outboundList.size());
    }
    
    /**
    * This test method used to Test resetLegacyAccountId
    */ 
    static testMethod void testResetLegacyAccountId() {   
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opp.LI_Account_Id__c = acc.Id;
        Test.startTest();
            insert opp;
            opp.AccountId = null;
            update opp;
            opp = [SELECT LI_Account_Id__c FROM Opportunity WHERE ID =: opp.Id];
        Test.stopTest();
        System.assertEquals(null, opp.LI_Account_Id__c);
    }
    
    /**
    * This test method used to test method setNoOfPotentialRegionsBasedOnPotentialRegions
    */     
    static testMethod void testSetNoOfPotentialRegionsBasedOnPotentialRegions(){
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = UTL_OWF_TestData.createOpportunity(acc.Id);
        Test.startTest();
            opp.Potential_Regions__c = 'Asia Pacific';
            insert opp;
            Opportunity modifiedOpp = [Select Id, Number_of_Potential_Regions__c From Opportunity Where Id = :opp.Id];
            system.assertEquals(1, modifiedOpp.Number_of_Potential_Regions__c, 'Validating no of potential regions after inserting opportunity.');
            opp.Potential_Regions__c = 'Asia Pacific;Japan';
            update opp;
            modifiedOpp = [Select Id, Number_of_Potential_Regions__c From Opportunity Where Id = :opp.Id];
            system.assertEquals(2, modifiedOpp.Number_of_Potential_Regions__c, 'Validating no of potential regions after inserting opportunity.');
            opp.Potential_Regions__c = '';
            update opp;
            modifiedOpp = [Select Id, Number_of_Potential_Regions__c From Opportunity Where Id = :opp.Id];
            system.assertEquals(0, modifiedOpp.Number_of_Potential_Regions__c, 'Validating no of potential regions after inserting opportunity.');
        Test.stopTest();
        
    }

/*    static testMethod void testLeadUpdateOnClosedWon(){
         Id cnt; 
         User partnerUser = [SELECT id,AccountId, contactId FROM User WHERE email='partneruser@iqvia.partner.com'];
         User adminUser = [SELECT id,AccountId FROM User WHERE email='adminPartner@iqvia.com'];
         Lead led = TST_PEP_TestDataFactory.createLead('lead2@yopmail.com', 
                            'ePromo','ABC2 company', 'Jones', 'Dr.');
         
            System.runAs(partnerUser){         
            insert led;
            cnt = partnerUser.contactId;
         }
         
         System.runAs(adminUser){
            Product2 prod = TST_PEP_TestDataFactory.createProduct('OCE Marketing');
            prod.Material_Type__c = 'ZREP';
            prod.Hierarchy_Level__c = 'Material';
            insert prod;
             
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(led.Id);
            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            lc.setConvertedStatus(convertStatus.MasterLabel);
            Database.convertLead(lc);
            
            Lead convertedLed = [Select Id, convertedOpportunityId from Lead where Id= : led.Id];
            Opportunity convertedOpp = [SELECT id, stagename , Mulesoft_Opportunity_Sync__c from Opportunity where Id= : convertedLed.ConvertedOpportunityId];
           
            Test.startTest();
                PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(prod.Id);
                //insert pbEntry;
                OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(convertedOpp.Id,pbEntry.Id);
                //insert oppLineItem;
                 
                Competitor__c comp = UTL_TestData.createCompetitor();
                //insert comp;
                 
                OpportunityContactRole contactRole = UTL_TestData.createOpportunityContactRole(cnt, convertedOpp.Id);
                //insert contactRole;
                
                //convertedOpp.Principle_inCharge__c = cnt;
                convertedOpp.Potential_Competitor_1__c = comp.Id;
                convertedOpp.Line_of_Business__c = 'Clinical';
                convertedOpp.Path_Probability__c = 'Confident';
                convertedOpp.Contract_Start_Date__c=system.today();
                convertedOpp.Contract_End_Date__c=system.today();
                convertedOpp.Awarded_Date__c = system.today();
                convertedOpp.ATP_Date__c = system.today();
                convertedOpp.StageName = CON_PEP.S_PEP_OPP_CLOSED_WON;
                convertedOpp.Primary_Win_Reason__c = 'Project Performance';
                convertedOpp.Primary_Win_Reason_Detail__c = 'Other';
                convertedOpp.Win_Type__c = 'Competitive status unknown';
                convertedOpp.Specify_Primary_Win_Reason__c ='Other';
                convertedOpp.Secondary_Win_Reason__c = 'Delivery';
                convertedOpp.Secondary_Win_Reason_Detail__c = 'Other';
                convertedOpp.Specify_Secondary_Win_Reason__c = 'Other';
                convertedOpp.ATP_Professional_Fees__c = 5555.00;
                convertedOpp.ATP_Expenses__c = 55.00; 
                 
                 
                //Database.update(convertedOpp);
            Test.stopTest();
             
            Lead updatedLead = [SELECT Id, Status from Lead where convertedOpportunityId= : convertedOpp.Id];
            //System.assertEquals(CON_PEP.S_PEP_LED_CLOSED_WON, updatedLead.Status);
             
            }
    }
         
    static testMethod void testLeadUpdateOnClosedLost(){
         Id cnt; 
         User partnerUser = [SELECT id,AccountId, contactId FROM User WHERE email='partneruser@iqvia.partner.com'];
         User adminUser = [SELECT id,AccountId FROM User WHERE email='adminPartner@iqvia.com'];
         Lead led = TST_PEP_TestDataFactory.createLead('lead2@yopmail.com', 
                            'ePromo','ABC2 company', 'Jones', 'Dr.');
         
        System.runAs(partnerUser){         
            insert led;
            cnt = partnerUser.contactId;
        }
         
        System.runAs(adminUser){
            Product2 prod = TST_PEP_TestDataFactory.createProduct('OCE Marketing');
            prod.Material_Type__c = 'ZREP';
            prod.Hierarchy_Level__c = 'Material';
            insert prod;
             
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(led.Id);
            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            lc.setConvertedStatus(convertStatus.MasterLabel);
            Database.convertLead(lc);
            
            Lead convertedLed = [Select Id, convertedOpportunityId from Lead where Id= : led.Id];
            Opportunity convertedOpp = [SELECT id, stagename , Mulesoft_Opportunity_Sync__c from Opportunity where Id= : convertedLed.ConvertedOpportunityId];
           
            Test.startTest();
                PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(prod.Id);
                //insert pbEntry;
                OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(convertedOpp.Id,pbEntry.Id);
                //insert oppLineItem;
                 
                Competitor__c comp = UTL_TestData.createCompetitor();
                //insert comp;
                 
                OpportunityContactRole contactRole = UTL_TestData.createOpportunityContactRole(cnt, convertedOpp.Id);
                //insert contactRole;
                
                //convertedOpp.Principle_inCharge__c = cnt;
                convertedOpp.Potential_Competitor_1__c = comp.Id;
                convertedOpp.Line_of_Business__c = 'Clinical';
                convertedOpp.Path_Probability__c = 'Confident';
                convertedOpp.Contract_Start_Date__c=system.today();
                convertedOpp.Contract_End_Date__c=system.today();
                convertedOpp.StageName = CON_PEP.S_PEP_OPP_CLOSED_LOST;
                convertedOpp.Specify_Primary_Loss_Reason__c = 'Other';
                convertedOpp.Specify_Secondary_Loss_Reason__c = 'Other';
                convertedOpp.Loss_Type__c = 'Competitive status unknown';
                convertedOpp.Primary_Loss_Reason__c ='Project Performance';
                convertedOpp.Secondary_Loss_Reason__c = 'Delivery';
                convertedOpp.Secondary_Loss_Reason_Detail__c = 'Other';
                convertedOpp.Primary_Loss_Reason_Detail__c = 'Other';
                convertedOpp.Lost_Date__c = system.today();         
                convertedOpp.ATP_Date__c = system.today();
                convertedOpp.ATP_Professional_Fees__c = 5555.00;
                convertedOpp.ATP_Expenses__c = 55.00;

            //Database.update(convertedOpp);
            Test.stopTest();
         
            Lead updatedLead = [SELECT Id, Status from Lead where convertedOpportunityId= : convertedOpp.Id];
            //System.assertEquals(CON_PEP.S_PEP_LED_CLOSED_LOST, updatedLead.Status);
        }
         
    }*/
    
    /**
     * This method is used to test setParentNumber method
     */
    @isTest
    public static void testSetParentNumber() {
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp1 = UTL_TestData.createOpportunity(acc.Id);
        opp1.StageName = CON_CRM.IDENTIFYING_OPP_STAGE;
        opp1.Line_of_Business__c = 'Data Sciences';
        opp1.Potential_Regions__c = 'Asia Pacific';
        Opportunity opp2 = UTL_TestData.createOpportunity(acc.Id);
        opp2.Name = 'Test';
        opp2.StageName = CON_CRM.IDENTIFYING_OPP_STAGE;
        opp2.Line_of_Business__c = 'Data Sciences';
        opp2.Potential_Regions__c = 'Asia Pacific';
        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(opp1);
        oppList.add(opp2);
        Test.startTest();
        insert oppList;
        opp1 = [SELECT Id FROM Opportunity where Name = 'TestOpportunity'];
        opp2.Parent_Opportunity__c = opp1.Id;
        update opp2;
        delete opp1; 
        Test.stopTest();
    }
    
    /**
     * This method is used to test updateSalesSpotCompetitor method
     */
    @isTest
    public static void testUpdateSalesSpotCompetitor() {
        Competitor__c comp1 = UTL_TestData.createCompetitor();
        comp1.SalesSpot_Enabled__c = true;
        insert comp1;
        Competitor__c comp2 = UTL_TestData.createCompetitor();
        comp2.SalesSpot_Enabled__c = false;
        insert comp2;
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp1 = UTL_TestData.createOpportunity(acc.Id);
        opp1.Potential_Competitor_1__c = comp1.Id;
        opp1.Potential_Competitor_2__c = comp2.Id;
        Test.startTest();
        insert opp1;
        opp1.Potential_Competitor_1__c = comp2.Id;
        update opp1;
        opp1.Potential_Competitor_1__c = null;
        update opp1;
        opp1.Potential_Competitor_2__c = null;
        update opp1;
        opp1.Potential_Competitor_1__c = comp1.Id;
        opp1.Potential_Competitor_2__c = comp1.Id;
        update opp1;
        Test.stopTest();
    }

    @isTest
    private static void testUpdateIsStudyAwaredOfAgreement() {
        Opportunity opp = TST_CLM_TestDataFactory.createOpportunity(false);
        opp.StageName = '1. Identifying Opportunity';
        insert opp;

        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(
            CON_CLM.PRELIMINARY_RECORDTYPEID, false);
        agreement.Apttus__Related_Opportunity__c = opp.Id;
        agreement.Is_Study_Awarded__c = 'Yes';
        insert agreement;

        Test.startTest();
            opp.Probability = 30;
            update opp;
        Test.stopTest();
        
        Apttus__APTS_Agreement__c resultAgreement = [SELECT Id, Is_Study_Awarded__c FROM Apttus__APTS_Agreement__c 
            WHERE Id=:agreement.Id];
        System.assertEquals('No', resultAgreement.Is_Study_Awarded__c, 
            'Is_Study_Awarded__c field value must be updated to No but it is not.');
    }
}