/*
* Name              : TST_CNT_PSA_CREATE_PROJECT_OPP_SCREEN
* Created By        : Mahima Gupta
* Created Date      : 15 April, 2019
* Revision          : 
* Description       : Test Class for CNT_PSA_CREATE_PROJECT_OPP_SCREEN apex class
*/
@isTest 
public class TST_CNT_PSA_CREATE_PROJECT_OPP_SCREEN { 
  
    @testSetup
    static void setupTestData(){
        Opportunity NewOpportunity = new Opportunity (Name='Test Opp');
        NewOpportunity.StageName = '4 - Delivering Proposal';
        NewOpportunity.CloseDate = System.today();
        NewOpportunity.Budget_Available__c = 'Yes';
        NewOpportunity.CurrencyIsoCode = 'USD';
        NewOpportunity.LI_Opportunity_Id__c ='TST123';
        insert NewOpportunity;
        Opportunity NewOpportunity1 = new Opportunity (Name='Test Opportunity');
        NewOpportunity1.StageName = '1. Identifying Opportunity';
        NewOpportunity1.CloseDate = System.today();
        NewOpportunity1.Budget_Available__c = 'Yes';
        NewOpportunity1.CurrencyIsoCode = 'USD';
        NewOpportunity1.LI_Opportunity_Id__c ='TST1234';
        insert NewOpportunity1;
        Opportunity newOpportunity2 = TST_CLM_TestDataFactory.createOpportunity(false);
        newOpportunity2.stageName = '5. Finalizing Deal';
        newOpportunity2.LI_Opportunity_Id__c ='TST12345';
        newOpportunity2.Potential_Regions__c='Japan';
        newOpportunity2.QI_Invited_to_Present__c='No';
        insert newOpportunity2;
    }
    
    static void AddLineItems(Opportunity O)
    {
        
        Product2 prod =  UTL_TestData.createProduct();
        User u1 = [SELECT id from User WHERE profile.Name = 'System Administrator' and IsActive = true LIMIT 1];
        System.runAs(u1){
        
        prod.Material_Type__c = 'ZREP';
        prod.CanUseRevenueSchedule = true;
        insert prod;
        
        PricebookEntry PE1 = UTL_TestData.createPricebookEntry(prod.id);
        insert PE1;
        
        List<OpportunityLineItem> testOppLineItem = new List<OpportunityLineItem>();
        List<OpportunityLineItemSchedule> oppLineItemSchedule = new List<OpportunityLineItemSchedule>();
        
        //  Add a line item to the opportunity
        OpportunityLineItem OLI1 = UTL_TestData.createOpportunityLineItem(o.Id, PE1.Id);
        OLI1.Therapy_Area__c = 'Dermatology';
        testOppLineItem.add(OLI1);  
        OpportunityLineItem OLI2 = UTL_TestData.createOpportunityLineItem(o.Id, PE1.Id);
        testOppLineItem.add(OLI2);  
        insert testOppLineItem;     
        
        
        Date strScheduleDate = Date.today();
        for (Integer j = 0; j < 12; j++) 
        {
            OpportunityLineItemSchedule olis = new OpportunityLineItemSchedule();
            olis.opportunityLineItemID = OLI1.Id;
            olis.ScheduleDate = strScheduleDate;
            olis.Type = 'Revenue';
            olis.Revenue = 1000.00;
            olis.ScheduleDate = strScheduleDate;
            strScheduleDate = strScheduleDate.addMonths(1);
            oppLineItemSchedule.add(olis);
        }
       //insert olis;
        insert oppLineItemSchedule;
            
        }
        
    }
    testmethod static void testValidateOppForProjectCreation() {
        
        Opportunity testOpportunity = [select id from opportunity limit 1];
        AddLineItems(testOpportunity);
        
        Test.startTest();
            Map<String, String> validateOppForProjectCreationMap = CNT_PSA_CREATE_PROJECT_OPP_SCREEN.validateOppForProjectCreation(testOpportunity.id);
            //validateOppForProjectCreationMap = CNT_PSA_CREATE_PLANNED_PROJECT.validateOppForProjectCreation(testOpportunity.id);//Added by sangeeta : PSA 3462
        Test.stopTest();
            String liOppID = validateOppForProjectCreationMap.get('legacyOrgOppId');
         System.assertEquals('TST123', liOppID);
    }
    
    testmethod static void testValidateOppForStage1() {
        
        Opportunity testOpportunity = [select id from opportunity where name='Test Opportunity' limit 1];
        AddLineItems(testOpportunity);
        
        Test.startTest();
        Map<String, String> validateOppForProjectCreationMap = CNT_PSA_CREATE_PROJECT_OPP_SCREEN.validateOppForProjectCreation(testOpportunity.id);
        System.debug(validateOppForProjectCreationMap);
        //validateOppForProjectCreationMap = CNT_PSA_CREATE_PLANNED_PROJECT.validateOppForProjectCreation(testOpportunity.id);//Added by sangeeta : PSA 3462
        Test.stopTest();
        String errorMsg = validateOppForProjectCreationMap.get('errorMessages');
        System.assertEquals('["Opportunity stage is not valid for creating both Billable Projects or Planned projects."]', errorMsg);
    }
    
    testmethod static void testValidateOppForPrincipalIncharge() {
        
        Opportunity testOpportunity = [select id from opportunity where name='TestOpportunity' limit 1];
        //AddLineItems(testOpportunity);
        
        Test.startTest();
        Map<String, String> validateOppForProjectCreationMap = CNT_PSA_CREATE_PROJECT_OPP_SCREEN.validateOppForProjectCreation(testOpportunity.id);
        System.debug(validateOppForProjectCreationMap);
        //validateOppForProjectCreationMap = CNT_PSA_CREATE_PLANNED_PROJECT.validateOppForProjectCreation(testOpportunity.id);//Added by sangeeta : PSA 3462
        Test.stopTest();
        String errorMsg = validateOppForProjectCreationMap.get('errorMessages');
        String errMsg= errorMsg.substring(2,18);
        System.assertEquals('At least one MDM',errMsg);
    }
    
    testmethod static void testValidateOppForPrincipalIncharge1() {
        
        Opportunity testOpportunity = [select id from opportunity where name='TestOpportunity' limit 1];
        AddLineItems(testOpportunity);
        
        Test.startTest();
        Map<String, String> validateOppForProjectCreationMap = CNT_PSA_CREATE_PROJECT_OPP_SCREEN.validateOppForProjectCreation(testOpportunity.id);
        System.debug(validateOppForProjectCreationMap);
        //validateOppForProjectCreationMap = CNT_PSA_CREATE_PLANNED_PROJECT.validateOppForProjectCreation(testOpportunity.id);//Added by sangeeta : PSA 3462
        Test.stopTest();
        String errorMsg = validateOppForProjectCreationMap.get('errorMessages');
        String errMsg= errorMsg.substring(2,18);
        System.assertEquals('Principal In cha',errMsg);
    }
    
    testmethod static void testGetComponentListData() {
        Opportunity testOpportunity = [select id from opportunity limit 1];
        Id oppId = testOpportunity.Id;
        List<OpportunityLineItem> oppLineItemList;
        Test.startTest();
         Id componentListData = CNT_PSA_CREATE_PROJECT_OPP_SCREEN.getComponentListData(oppLineItemList);
        Test.stopTest();
          System.assertEquals(null, componentListData);
    }
    
    testmethod static void testCheckForOnDemandProducts() {
        Opportunity testOpportunity = [select id from opportunity limit 1];
        Id oppId = testOpportunity.Id;
        Test.startTest();
        AddLineItems(testOpportunity);
        List<OpportunityLineItem> oppLineItemList = [SELECT o.Id,o.PricebookEntry.Product2.Name,o.PricebookEntry.Product2.Id,o.TotalPrice,
                o.PricebookEntry.Product2.Material_Type__c,o.PricebookEntry.Product2.ZQUI_Product__c, o.PricebookEntry.Product2.Product_Group__c 
                FROM OpportunityLineItem o 
                WHERE o.OpportunityId = :oppId AND o.PSA_Budget__c  = null 
                AND (o.PricebookEntry.Product2.Material_Type__c = 'ZREP' OR 
                (o.PricebookEntry.Product2.Material_Type__c = 'ZQUI' AND o.PricebookEntry.Product2.ZQUI_Product__c = true ))
                ORDER BY o.PricebookEntry.Product2.Name ASC];
         Boolean isTrue = CNT_PSA_CREATE_PROJECT_OPP_SCREEN.checkForOnDemandProducts(oppLineItemList);
        Test.stopTest();
          System.assertNotEquals(true, isTrue);
    }
    
    testmethod static void testCheckForOnDemandProducts2() {
        Opportunity o = [select id from opportunity where name = 'Test Opp' limit 1];
        Id oppId = o.Id;
        Test.startTest();
        //AddLineItems(testOpportunity);
        Product2 prod =  UTL_TestData.createProduct();
        User u1 = [SELECT id from User WHERE profile.Name = 'System Administrator' and IsActive = true LIMIT 1];
        System.runAs(u1){
        
        prod.Material_Type__c = 'ZREP';
            prod.Product_Group__c = 'Novasyte CRM';
        prod.CanUseRevenueSchedule = true;
        insert prod;
        
        PricebookEntry PE1 = UTL_TestData.createPricebookEntry(prod.id);
        insert PE1;
        
        List<OpportunityLineItem> testOppLineItem = new List<OpportunityLineItem>();
        List<OpportunityLineItemSchedule> oppLineItemSchedule = new List<OpportunityLineItemSchedule>();
        
        //  Add a line item to the opportunity
        OpportunityLineItem OLI1 = UTL_TestData.createOpportunityLineItem(o.Id, PE1.Id);
        OLI1.Therapy_Area__c = 'Dermatology';
        testOppLineItem.add(OLI1);  
        OpportunityLineItem OLI2 = UTL_TestData.createOpportunityLineItem(o.Id, PE1.Id);
        testOppLineItem.add(OLI2);  
        insert testOppLineItem;     
        
        
        Date strScheduleDate = Date.today();
        for (Integer j = 0; j < 12; j++) 
        {
            OpportunityLineItemSchedule olis = new OpportunityLineItemSchedule();
            olis.opportunityLineItemID = OLI1.Id;
            olis.ScheduleDate = strScheduleDate;
            olis.Type = 'Revenue';
            olis.Revenue = 1000.00;
            olis.ScheduleDate = strScheduleDate;
            strScheduleDate = strScheduleDate.addMonths(1);
            oppLineItemSchedule.add(olis);
        }
       //insert olis;
        insert oppLineItemSchedule;
            
        }
        
        List<OpportunityLineItem> oppLineItemList = [SELECT o.Id,o.PricebookEntry.Product2.Name,o.PricebookEntry.Product2.Id,o.TotalPrice,
                o.PricebookEntry.Product2.Material_Type__c,o.PricebookEntry.Product2.ZQUI_Product__c, o.PricebookEntry.Product2.Product_Group__c 
                FROM OpportunityLineItem o 
                WHERE o.OpportunityId = :oppId AND o.PSA_Budget__c  = null 
                AND (o.PricebookEntry.Product2.Material_Type__c = 'ZREP' OR 
                (o.PricebookEntry.Product2.Material_Type__c = 'ZQUI' AND o.PricebookEntry.Product2.ZQUI_Product__c = true ))
                ORDER BY o.PricebookEntry.Product2.Name ASC];
         Map<String, String> validateOppForProjectCreationMap = CNT_PSA_CREATE_PROJECT_OPP_SCREEN.validateOppForProjectCreation(o.Id);
        Test.stopTest();
          //System.assertEquals(true, isTrue);
    }
    
    testmethod static void testGetLegacyOrgLink(){
        Test.startTest();
         Legacy_Org_Link__c legacyOrgLink = CNT_PSA_CREATE_PROJECT_OPP_SCREEN.getLegacyOrgLink();
         //legacyOrgLink = CNT_PSA_CREATE_PLANNED_PROJECT.getLegacyOrgLink(); //Added by sangeeta : PSA 3462
        Test.stopTest();
        System.assertNotEquals(null, legacyOrgLink.SetupOwnerId);
    }
}
