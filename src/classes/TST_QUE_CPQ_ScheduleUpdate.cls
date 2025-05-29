@isTest
private class TST_QUE_CPQ_ScheduleUpdate {
    
    /**
    * This method is used to setup data for all methods.
    */
    @testSetup
    static void dataSetup() { 
        Account acc = UTL_TestData.createAccount();
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'TestOpportunity';
        opp.stageName = CON_CRM.IDENTIFYING_OPP_STAGE;
        opp.AccountId = acc.Id;
        opp.CurrencyIsoCode = CON_CPQ.USD;
        opp.Is_this_IQVIA_Biotech__c = CON_CPQ.YES_TITLE_CASE;
        opp.Legacy_Quintiles_Opportunity_Number__c = CON_CPQ.TEST_OPPORTUNITY_NUMBER;
        opp.CloseDate = System.today();
        opp.Global_project_unit__c = 'AA/Japan';
        opp.Number_of_Potential_Regions__c = 0;
        insert opp;
        
        Product2 testProduct = UTL_TestData.createProduct();
        testProduct.Billing_System__c = 'SAP';
        insert testProduct;
        PricebookEntry testPricebookEntry = UTL_TestData.createPricebookEntry(testProduct.Id);
        testPricebookEntry.CurrencyIsoCode = CON_CPQ.USD;
        insert testPricebookEntry;
        
        Bid_History__c testClinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, opp.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);
        
        Apttus_Proposal__Proposal__c quote = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, opp.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, testClinicalBid.Id);
        quote.CurrencyIsoCode = CON_CPQ.USD;
        update quote;
        
        List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItemList = new List<Apttus_Proposal__Proposal_Line_Item__c>();
        proposalLineItemList.add(new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Proposal__c = quote.Id,Revenue_Type__c = CON_CPQ.AD_HOC, IQVIA_Line_Type__c = CON_CPQ.CRM_Product,Sale_Type__c = CON_CPQ.SALE_TYPE_NEW,
                                                                           BIDGRID_COUNTRY__C = 'USA', Apttus_QPConfig__NetPrice__c = 2000, Apttus_Proposal__Product__c=testProduct.Id, Apttus_Proposal__Quantity__c = 1) );
        proposalLineItemList.add(new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Proposal__c = quote.Id,Revenue_Type__c = CON_CPQ.AD_HOC, IQVIA_Line_Type__c = CON_CPQ.CRM_Product,Sale_Type__c = CON_CPQ.SALE_TYPE_NEW,
                                                                           BIDGRID_COUNTRY__C = 'Brazil', Apttus_QPConfig__NetPrice__c = 3000, Apttus_Proposal__Product__c=testProduct.Id, Apttus_Proposal__Quantity__c = 1) );
        proposalLineItemList.add(new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Proposal__c = quote.Id,Revenue_Type__c = CON_CPQ.AD_HOC, IQVIA_Line_Type__c = CON_CPQ.CRM_Product,Sale_Type__c = CON_CPQ.SALE_TYPE_NEW,
                                                                           BIDGRID_COUNTRY__C = 'Argentina', Apttus_QPConfig__NetPrice__c = 4000, Apttus_Proposal__Product__c=testProduct.Id, Apttus_Proposal__Quantity__c = 1) );
        proposalLineItemList.add(new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Proposal__c = quote.Id,Revenue_Type__c = CON_CPQ.AD_HOC, IQVIA_Line_Type__c = CON_CPQ.CRM_Product,Sale_Type__c = CON_CPQ.SALE_TYPE_NEW,
                                                                           BIDGRID_COUNTRY__C = 'Australia', Apttus_QPConfig__NetPrice__c = 5000, Apttus_Proposal__Product__c=testProduct.Id, Apttus_Proposal__Quantity__c = 1) );
        proposalLineItemList.add(new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Proposal__c = quote.Id,Revenue_Type__c = CON_CPQ.AD_HOC, IQVIA_Line_Type__c = CON_CPQ.CRM_Product,Sale_Type__c = CON_CPQ.SALE_TYPE_NEW,
                                                                           BIDGRID_COUNTRY__C = 'Austria', Apttus_QPConfig__NetPrice__c = 6000, Apttus_Proposal__Product__c=testProduct.Id, Apttus_Proposal__Quantity__c = 1) );
        proposalLineItemList.add(new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Proposal__c = quote.Id,Revenue_Type__c = CON_CPQ.AD_HOC, IQVIA_Line_Type__c = CON_CPQ.CRM_Product,Sale_Type__c = CON_CPQ.SALE_TYPE_NEW,
                                                                           BIDGRID_COUNTRY__C = 'Belgium', Apttus_QPConfig__NetPrice__c = 7000, Apttus_Proposal__Product__c=testProduct.Id, Apttus_Proposal__Quantity__c = 1) );
        proposalLineItemList.add(new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Proposal__c = quote.Id,Revenue_Type__c = CON_CPQ.AD_HOC, IQVIA_Line_Type__c = CON_CPQ.CRM_Product,Sale_Type__c = CON_CPQ.SALE_TYPE_NEW,
                                                                           BIDGRID_COUNTRY__C = 'Canada', Apttus_QPConfig__NetPrice__c = 8000, Apttus_Proposal__Product__c=testProduct.Id, Apttus_Proposal__Quantity__c = 1) );
        proposalLineItemList.add(new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Proposal__c = quote.Id,Revenue_Type__c = CON_CPQ.AD_HOC, IQVIA_Line_Type__c = CON_CPQ.CRM_Product,Sale_Type__c = CON_CPQ.SALE_TYPE_NEW,
                                                                           BIDGRID_COUNTRY__C = 'France', Apttus_QPConfig__NetPrice__c = 9000, Apttus_Proposal__Product__c=testProduct.Id, Apttus_Proposal__Quantity__c = 1) );
        proposalLineItemList.add(new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Proposal__c = quote.Id,Revenue_Type__c = CON_CPQ.AD_HOC, IQVIA_Line_Type__c = CON_CPQ.CRM_Product,Sale_Type__c = CON_CPQ.SALE_TYPE_NEW,
                                                                           BIDGRID_COUNTRY__C = 'Germany', Apttus_QPConfig__NetPrice__c = 10000, Apttus_Proposal__Product__c=testProduct.Id, Apttus_Proposal__Quantity__c = 1) );
        proposalLineItemList.add(new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Proposal__c = quote.Id,Revenue_Type__c = CON_CPQ.AD_HOC, IQVIA_Line_Type__c = CON_CPQ.CRM_Product,Sale_Type__c = CON_CPQ.SALE_TYPE_NEW,
                                                                           BIDGRID_COUNTRY__C = 'India', Apttus_QPConfig__NetPrice__c = 11000, Apttus_Proposal__Product__c=testProduct.Id, Apttus_Proposal__Quantity__c = 1) );
        proposalLineItemList.add(new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Proposal__c = quote.Id,Revenue_Type__c = CON_CPQ.AD_HOC, IQVIA_Line_Type__c = CON_CPQ.CRM_Product,Sale_Type__c = CON_CPQ.SALE_TYPE_NEW,
                                                                           BIDGRID_COUNTRY__C = 'Japan', Apttus_QPConfig__NetPrice__c = 12000, Apttus_Proposal__Product__c=testProduct.Id, Apttus_Proposal__Quantity__c = 1) );
        insert proposalLineItemList;
        
        List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
        for (Integer i=0; i<proposalLineItemList.size(); i++) {
            oppLineItemList.add(new OpportunityLineItem(OpportunityId = opp.Id, priceBookEntryId = testPricebookEntry.id, Product2Id = testProduct.id,
                                                       UnitPrice =proposalLineItemList[i].Apttus_QPConfig__NetPrice__c ,Agreement_Line_Item_Id__c = proposalLineItemList[i].Id,
                                                       Quantity = proposalLineItemList[i].Apttus_Proposal__Quantity__c, Sale_Type__c = proposalLineItemList[i].Sale_Type__c,
                                                       Revenue_Type__c= proposalLineItemList[i].Revenue_Type__c, Delivery_Country__c = proposalLineItemList[i].BIDGRID_COUNTRY__C));
        }
        insert oppLineItemList; 
    }

    @isTest 
    static void testLargerScheduleUpdate() {
        
        Map<Id, List<OpportunityLineItemSchedule>> lineItemScheduleMap =new Map<Id, List<OpportunityLineItemSchedule>>();
        CPQ_Settings__c cpqSetting = new CPQ_Settings__c();
        cpqSetting.Name = 'Test CPQ Setting';
        cpqSetting.No_of_Installment_for_Schedule_Creation__c = 20;
        insert cpqSetting;
        
        List<OpportunitylineItem> oppLineItemList = [Select Id,UnitPrice,Opportunity.CloseDate from OpportunitylineItem];

        for(OpportunitylineItem oli :oppLineItemList) {
            List<OpportunityLineItemSchedule> oliSchList = new List<OpportunityLineItemSchedule>();
            Integer numberOfInstallment = (Integer)cpqSetting.No_of_Installment_for_Schedule_Creation__c;
            Decimal price = oli.UnitPrice;
            Decimal amount = Math.floor(price/numberOfInstallment);
            Decimal sumOfAmount = amount * (numberOfInstallment - 1);
            Date revenueDate = oli.Opportunity.CloseDate;
            for (integer index = 0; index < numberOfInstallment - 1; index++) {
                OpportunityLineItemSchedule oliSchedule = new OpportunityLineItemSchedule(Revenue = amount, OpportunityLineItemId = oli.ID, ScheduleDate = revenueDate, Type = 'Revenue');
                revenueDate = revenueDate.addMonths(1);
                oliSchList.add(oliSchedule);
            }
            OpportunityLineItemSchedule oliSchedule = new OpportunityLineItemSchedule(Revenue = price - sumOfAmount, OpportunityLineItemId = oli.ID, ScheduleDate = revenueDate, Type = 'Revenue');
            oliSchList.add(oliSchedule);
            lineItemScheduleMap.put(oli.id,oliSchList);
            
        }   
        Apttus_Proposal__Proposal__c proposal =[Select Id from Apttus_Proposal__Proposal__c Limit 1];
        
        Test.startTest();
            QUE_CPQ_ScheduleUpdate.isTestRun = true;
        	Queueable k = new QUE_CPQ_ScheduleUpdate(lineItemScheduleMap,proposal.id, true);
        	k.execute(null);
        Test.stopTest();
        
        List<OpportunityLineItemSchedule> olisList = [Select Id from OpportunityLineItemSchedule];
        System.assertEquals(220, olisList.size(), 'Schedule Inserted Successfully');
    }

   @isTest
    static void testScheduleUpdateWithValidation() {        
        Apttus_Proposal__Proposal__c proposal = [SELECT Id,Name FROM Apttus_Proposal__Proposal__c Limit 1];
        
        Map<Id, List<OpportunityLineItemSchedule>> scheduleMap =new Map<Id, List<OpportunityLineItemSchedule>>();
        CPQ_Settings__c cpqSetting = new CPQ_Settings__c();
        cpqSetting.Name = 'Test CPQ Setting';
        cpqSetting.No_of_Installment_for_Schedule_Creation__c = 20;
        insert cpqSetting;
        
        List<OpportunitylineItem> oppLineItem = [Select Id,UnitPrice,Opportunity.CloseDate from OpportunitylineItem];
        for(OpportunitylineItem oli :oppLineItem) {
            List<OpportunityLineItemSchedule> lineItemScheduleList = new List<OpportunityLineItemSchedule>();
            Integer numberOfInstallment = (Integer)cpqSetting.No_of_Installment_for_Schedule_Creation__c;
            Decimal price = oli.UnitPrice;
            Decimal amount = Math.floor(price/numberOfInstallment);
            Decimal sumOfAmount = amount * (numberOfInstallment - 1);
            Date revenueDate = null;
            for (integer index = 0; index < numberOfInstallment - 1; index++) {
                OpportunityLineItemSchedule oliSchedule = new OpportunityLineItemSchedule(Revenue = amount, OpportunityLineItemId = oli.ID, ScheduleDate = revenueDate, Type = 'Revenue');
                revenueDate = null;
                lineItemScheduleList.add(oliSchedule);
            }
            OpportunityLineItemSchedule oliSchedule = new OpportunityLineItemSchedule(Revenue = price - sumOfAmount, OpportunityLineItemId = oli.ID, ScheduleDate = revenueDate, Type = 'Revenue');
            lineItemScheduleList.add(oliSchedule); 
            scheduleMap.put(oli.Id, lineItemScheduleList);
        }
        
        Test.startTest();
            QUE_CPQ_ScheduleUpdate.isTestRun = true;
            System.enqueueJob(new QUE_CPQ_ScheduleUpdate(scheduleMap,proposal.id, True));
        Test.stopTest();
    }
    
    @isTest 
    static void testSmallerScheduleUpdate() {
        
        Map<Id, List<OpportunityLineItemSchedule>> scheduleMap =new Map<Id, List<OpportunityLineItemSchedule>>();
        CPQ_Settings__c cpqSetting = new CPQ_Settings__c();
        cpqSetting.Name = 'Test CPQ Setting';
        cpqSetting.No_of_Installment_for_Schedule_Creation__c = 20;
        insert cpqSetting;
        
        List<OpportunitylineItem> oppLineItem = [Select Id,UnitPrice,Opportunity.CloseDate from OpportunitylineItem Limit 1];
        List<OpportunityLineItemSchedule> lineItemScheduleList = new List<OpportunityLineItemSchedule>();
        Integer numberOfInstallment = (Integer)cpqSetting.No_of_Installment_for_Schedule_Creation__c;
        Decimal price = oppLineItem[0].UnitPrice;
        Decimal amount = Math.floor(price/numberOfInstallment);
        Decimal sumOfAmount = amount * (numberOfInstallment - 1);
        Date revenueDate = oppLineItem[0].Opportunity.CloseDate;
        for (integer index = 0; index < numberOfInstallment - 1; index++) {
            OpportunityLineItemSchedule oliSchedule = new OpportunityLineItemSchedule(Revenue = amount, OpportunityLineItemId = oppLineItem[0].ID, ScheduleDate = revenueDate, Type = 'Revenue');
            revenueDate = revenueDate.addMonths(1);
            lineItemScheduleList.add(oliSchedule);
        }
        OpportunityLineItemSchedule oliSchedule = new OpportunityLineItemSchedule(Revenue = price - sumOfAmount, OpportunityLineItemId = oppLineItem[0].ID, ScheduleDate = revenueDate, Type = 'Revenue');
        lineItemScheduleList.add(oliSchedule); 
        scheduleMap.put(oppLineItem[0].Id, lineItemScheduleList);
        
        Apttus_Proposal__Proposal__c proposal =[Select Id from Apttus_Proposal__Proposal__c Limit 1];
        
        Test.startTest();
            QUE_CPQ_ScheduleUpdate.isTestRun = true;
            System.enqueueJob(new QUE_CPQ_ScheduleUpdate(scheduleMap,proposal.id, true));
        Test.stopTest();
        
        List<OpportunityLineItemSchedule> olisList = [Select Id from OpportunityLineItemSchedule];
        System.assertEquals(20, olisList.size(), 'Schedule Inserted Successfully');
    }
 
}