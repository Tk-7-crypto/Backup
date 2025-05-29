@isTest
public class TST_DAOH_BNF_OpportunityLineItem {
    @testSetup
    static void dataSetup() {
                
        Global_Variables.PCFlag = false;
        Global_Variables.RunQuickOppLimitTrigger = false;
        Global_Variables.RenewalCloneFlag = TRUE;
        Global_Variables.syncAgreementToOppty=false;   
        Global_Variables.PCTrigger_Hault_Execution=false;
        MI_BNF_Approval_Extension.CustomApprovalPage = true;
        BNF_Test_Data.create_User_LocaleSetting();
        User tstUser= BNF_Test_Data.createUser();
        Current_Release_Version__c crv = new Current_Release_Version__c();
        crv.Current_Release__c = '3000.01';
        upsert crv;
        BNF_Settings__c bs = new BNF_Settings__c();
        bs.BNF_Release__c = '2019.01';
        bs.Enable_RSchedule_Validation__c = true;
        upsert bs;
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Contact cnt = UTL_TestData.createContact(acc.Id);
        insert cnt;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        //opp.Enterprise_Lead__c = tstUser.Id;
        //opp.Relationship_Manager__c = tstUser.Id;
        insert opp;
        Product2 product = UTL_TestData.createProduct();
        insert product;
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        oppLineItem.Delivery_Country__c = 'USA';
        oppLineItem.Description = 'Testing';
        insert oppLineItem;
        OpportunityLineItemSchedule olis = UTL_TestData.createOpportunityLineItemSchedule(oppLineItem.Id);
        insert olis;

        //User testUser = [Select id, name from User where isActive = true Limit 1];
        //Revenue_Analyst__c ratest = new Revenue_Analyst__c(Name = 'Test RA', User__c = testUser.id);
        Revenue_Analyst__c ratest = UTL_TestData.createRevenueAnalyst();
        insert ratest;
        //Added by Prakhar
        
        //User tstUser= BNF_Test_Data.createUser();
        //tstUser.email='mdmhelpdesk@imshealth.com';
        //update tstUser;
        //Ended by Prakhar
   
        Address__c testAddress = New Address__c(Name='Test Address',Account__c = acc.Id, Street__c = 'Street',City__c = 'City',Country__c = 'Country',Marked_For_Deletion__c = false,
                                                SAP_Reference__c = '495001', Enabled_Sales_Orgs__c = 'CH08', MDM_Validation_Status__c = 'Validated');
        insert testAddress;
        
        //Product2 product = new Product2 (Name = 'Test Product Entry 1', Description = 'Test Product Entry 1', Material_Type__c = 'ZPUB', IsActive = true, Family = 'Test Family', ProductCode = '122', CanUseRevenueSchedule= true, Enabled_Sales_Orgs__c = 'CH08');
        //insert product;
        
        //Product2 product = new Product2(Name='test1', ProductCode='122', Enabled_Sales_Orgs__c='CH03', Offering_Type__c = 'Commercial Tech', Material_Type__c = 'ZPUB',CanUseRevenueSchedule= true, Delivery_Media__c = 'DVD [DV]:CD [CD]',Delivery_Frequency__c = 'Monthly:Quaterly');
        //insert product;
        Test.startTest();
        MIBNF2__c testMIBNF = UTL_TestData.createMIBNF(opp, ratest);
        insert testMIBNF;
        
        MIBNF_Component__c testMIBNF_Comp = UTL_TestData.createMIBNF_Comp(testMIBNF, new List<Address__c>{testAddress,testAddress,testAddress,testAddress,testAddress});
        insert testMIBNF_Comp;
        
        MI_BNF_LineItem__c miBNFLI = new MI_BNF_LineItem__c();
        miBNFLI.MIBNFComponent_OLI_ID__c = oppLineItem.Id;
        miBNFLI.MIBNF_Component__c = testMIBNF_Comp.Id;
        miBNFLI.Opportunity_Line_Itemid__c = oppLineItem.Id;
        miBNFLI.Total_Price__c = 2000;
        insert miBNFLI;
        Test.stopTest();
    }
    
    static testMethod void testAfterInsert() {  
        Test.startTest();
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE Name = 'TestOpportunity'];
        Contact cnt = [SELECT id FROM Contact WHERE LastName = 'TestContact'];
        OpportunityContactRole contactRole = UTL_TestData.createOpportunityContactRole(cnt.Id, opp.Id);
        insert contactRole;
        Product2 product = UTL_TestData.createProduct();
        product.Offering_Group__c = CON_CRM.OFFERING_GROUP_GLOBAL_RND;
        product.Offering_Group_Code__c = CON_CRM.OFFERING_GROUP_CODE_GLOBAL_RND;
        insert product;
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        insert oppLineItem;
        Test.stopTest();
        List<OpportunityLineItem> actualOppLineItem = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :opp.Id];
        System.assertEquals(2, actualOppLineItem.size()); 
    }
    
    static testMethod void testCreateOutboundMessageDeletionQueue() {   
        List<OpportunityLineItem> oliList = [SELECT Id FROM OpportunityLineItem];
        Test.startTest();
        delete oliList;
        List<Outbound_Message_Deletion_queue__c> outboundList = [SELECT Id FROM Outbound_Message_Deletion_queue__c LIMIT 1];
        Test.stopTest();
    }
    
    @isTest
    static void test5() {
        Test.startTest();
        Account newAccount = [select id from Account where name = 'TestAccount'];
        Opportunity opp = [select id,AccountId from Opportunity where accountId = :newAccount.id];
        MIBNF2__c testMIBNF = [select id from MIBNF2__c where Opportunity__c =: opp.Id];
        MIBNF_Component__c testMIBNF_Comp = [select id,BNF_Status__c from MIBNF_Component__c where MIBNF__c =: testMIBNF.Id];
        
        testMIBNF_Comp.BNF_Status__c='LO Rejected';
        update testMIBNF_Comp;
        testMIBNF_Comp.BNF_Status__c='SAP Rejected';
        update testMIBNF_Comp;
        Test.stopTest();
    }
    
     @isTest
    static void test6() {
        Test.startTest();
        Account newAccount = [select id from Account where name = 'TestAccount'];
        Opportunity opp = [select id,AccountId from Opportunity where accountId = :newAccount.id];
        OpportunityLineItem oliItems = [SELECT Id,TotalPrice,UnitPrice FROM OpportunityLineItem where OpportunityId =: opp.Id ]; 
        OpportunityLineItemSchedule olisch = [SELECT Id,Revenue FROM OpportunityLineItemSchedule where OpportunityLineItemId =: oliItems.Id];
        olisch.Revenue = 5000;
        update olisch;
        Test.stopTest();
    }
}