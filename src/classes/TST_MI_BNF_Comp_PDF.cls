@isTest
private Class TST_MI_BNF_Comp_PDF {
    
    @testSetup static void setupTestData(){
        UTL_ExecutionControl.stopAuditTriggerExecution = true;
        Trigger_Control_For_Migration__c tcm = Trigger_Control_For_Migration__c.getInstance();
        tcm.Disable_MIBNF_Trigger__c = true;
        upsert tcm;
        Current_Release_Version__c crv = new Current_Release_Version__c();
        crv.Current_Release__c = '3000.01';
        upsert crv;
        
        Global_Variables.PCFlag = false;
        Global_Variables.RunQuickOppLimitTrigger = false;
        Global_Variables.RenewalCloneFlag = TRUE;
        Global_Variables.syncAgreementToOppty=false;
        Global_Variables.PCTrigger_Hault_Execution=false;
        
        Account TestAccount = BNF_Test_Data.createAccount();
        List<Address__c> TestAddress_Array = BNF_Test_Data.createAddress_Array();
        List<SAP_Contact__c> TestSapContact_Array = BNF_Test_Data.createSapContact_Array();
        Competitor__c comp = UTL_TestData.createCompetitor();
        insert comp;
        Opportunity TestOpp = new Opportunity(Name='test',StageName='1. Identifying Opportunity',CloseDate=System.today());
        Testopp.Opportunity_Number__c = '123';
        TestOpp.LeadSource = 'Account Planning';
        TestOpp.Budget_Available__c = 'Yes';
        TestOpp.StageName='5. Finalizing Deal';
        TestOpp.AccountId = TestAccount.Id;
        TestOpp.Contract_Term__c='Single-Period';
        TestOpp.Contract_End_Date__c = system.today();
        TestOpp.Contract_Start_Date__c = system.today();
        TestOpp.Contract_Type__c='Individual';
        TestOpp.LeadSource = 'Account Planning';
        TestOpp.CurrencyIsoCode = 'USD';
        TestOpp.Global_project_unit__c = 'AA/Japan';
        TestOpp.Potential_Competitor_1__c = comp.Id;
        insert TestOpp;
        
        BNF_Settings__c bnfsetting = BNF_Test_Data.createBNFSetting();
        List<User_Locale__c> User_LocaleSetting = BNF_Test_Data.create_User_LocaleSetting();
        Product2 objProduct1 = new Product2(Name='test1', ProductCode='1', Enabled_Sales_Orgs__c='CH03', Offering_Type__c = 'Commercial Tech', Material_Type__c = 'ZREP',CanUseRevenueSchedule= true, Delivery_Media__c = 'DVD [DV]:CD [CD]',Delivery_Frequency__c = 'Monthly:Quaterly');
        insert objProduct1;
        PricebookEntry pbe = new PricebookEntry();
        pbe.UseStandardPrice = false;
        pbe.Pricebook2Id = Test.getStandardPricebookId();
        pbe.Product2Id=objProduct1.id;
        pbe.IsActive=true;
        pbe.UnitPrice=100.0;
        pbe.CurrencyIsoCode = 'USD';
        insert pbe;
        
        OpportunityLineItem add1_oli = new OpportunityLineItem();
        add1_oli.OpportunityId = TestOpp.Id;
        add1_oli.Product_Start_Date__c = Date.today();
        add1_oli.Product_End_Date__c = Date.today().addYears(1) ;
        add1_oli.PricebookEntryId = pbe.Id;
        add1_oli.Billing_Frequency__c = 'Once';
        add1_oli.Proj_Rpt_Frequency__c='Once [O]';
        add1_oli.Therapy_Area__c= 'Hepatitis C [21]';
        add1_oli.Quantity = 1.00;
        add1_oli.UnitPrice = 10000;  
        add1_oli.List_Price__c = 100;
        add1_oli.Sale_Type__c = 'New';
        add1_oli.Delivery_Country__c = 'USA';
        add1_oli.Revenue_Type__c = 'Ad Hoc';
        add1_oli.Revised_Revenue_Schedule__c = '20160222:100|20160628:100';
        insert add1_oli;
        
        OpportunityLineItemSchedule olis = UTL_TestData.createOpportunityLineItemSchedule(add1_oli.Id);
        insert olis;
        
        Revenue_Analyst__c TestLocalRA = UTL_TestData.createRevenueAnalyst();
        insert TestLocalRA;
        MIBNF2__c TestMIBNF = new MIBNF2__c();
        TestMIBNF.Client__c=TestOpp.AccountId;
        TestMIBNF.Opportunity__c=TestOpp.Id;
        TestMIBNF.Sales_Org_Code__c='CH08';
        TestMIBNF.Billing_Currency__c='USD';
        TestMIBNF.IMS_Sales_Org__c='Acceletra';
        TestMIBNF.Fair_Value_Type__c='Stand Alone';
        TestMIBNF.Invoice_Default_Day__c='15';
        TestMIBNF.Contract_Start_Date__c=system.today();
        TestMIBNF.Contract_End_Date__c=system.today();
        TestMIBNF.Contract_Type__c='Individual';
        TestMIBNF.Contract_Term__c='Single-Period';
        TestMIBNF.IMS_Sales_Org__c = 'IMS Spain';
        TestMIBNF.Payment_Terms__c='0000-Default Payment Terms of Customer Master Data';
        TestMIBNF.Revenue_Analyst__c = TestLocalRA.id;
        insert TestMIBNF;
        tcm = Trigger_Control_For_Migration__c.getInstance();
        tcm.Disable_MIBNF_Trigger__c = false;
        upsert tcm;
        
        MIBNF_Component__c TestMIBNF_Comp = new MIBNF_Component__c();
        TestMIBNF_Comp.MIBNF__c=TestMIBNF.Id;
        TestMIBNF_Comp.BNF_Status__c='New';
        TestMIBNF_Comp.Is_this_a_retainer_downpayment__c='No';
        TestMIBNF_Comp.Print_Shop__c='No';
        TestMIBNF_Comp.Bill_To__c=TestAddress_Array[0].id;
        TestMIBNF_Comp.X2nd_Copy__c=TestAddress_Array[1].id;
        TestMIBNF_Comp.Carbon_Copy__c=TestAddress_Array[2].id;
        TestMIBNF_Comp.Ship_To__c=TestAddress_Array[3].id;
        TestMIBNF_Comp.Cover_Sheet__c=TestAddress_Array[4].id;
        TestMIBNF_Comp.RA_End_Date__c = Date.today();
        insert TestMIBNF_Comp;
        
        UTL_ExecutionControl.stopAuditTriggerExecution = false;
    } 
    static testmethod void  testMIBNFCompPDF() {
        Test.startTest();
        Trigger_Control_For_Migration__c tcm = Trigger_Control_For_Migration__c.getInstance();
        tcm.Disable_MIBNF_Trigger__c = true;
        upsert tcm;
        MIBNF_Component__c mibnfc = [SELECT Id FROM MIBNF_Component__c LIMIT 1];
        List<OpportunityLineItem> add1_oli = [SELECT Id, TotalPrice FROM OpportunityLineItem LIMIT 1];
        MI_BNF_LineItem__c TestMI_BNFLineItem = new MI_BNF_LineItem__c();
        TestMI_BNFLineItem.MIBNF_Component__c = mibnfc.id;
        TestMI_BNFLineItem.Opportunity_Line_Itemid__c = add1_oli[0].Id;
        TestMI_BNFLineItem.Total_Price__c = add1_oli[0].TotalPrice;
        insert TestMI_BNFLineItem;
        
        Billing_Schedule__c sche = new Billing_Schedule__c(name = 'textSchedule', OLIId__c = add1_oli[0].id);
        insert sche;
        
        List<Billing_Schedule_Item__c> billingScheduleItem = new List<Billing_Schedule_Item__c>();
        Billing_Schedule_Item__c sche1 = new Billing_Schedule_Item__c(name = 'textScheduleItem', Billing_Amount__c = 2000,Billing_Date__c = system.today(),Billing_Schedule__c = sche.id);
        Billing_Schedule_Item__c sche2 = new Billing_Schedule_Item__c(name = 'textScheduleItemTemp', Billing_Amount__c = 3000, Billing_Date__c = system.today().addYears(1),Billing_Schedule__c = sche.id);
        billingScheduleItem.add(sche1);
        billingScheduleItem.add(sche2);
        insert billingScheduleItem;
        
        tcm = Trigger_Control_For_Migration__c.getInstance();
        tcm.Disable_MIBNF_Trigger__c = false;
        upsert tcm;
        MIBNF_Component__c mibnfComp = [Select id ,MIBNF__c ,Addendum__c,Revised_BNF_Reason__c,  Revised_BNF_Comment__c, Revised_BNF_Date__c,Orignal_BNF__c, Name ,Opportunity__C,RA_End_Date__c from MIBNF_Component__c limit 1];
        MIBNF_Component__c TestMIBNF_Comp=new MIBNF_Component__c();
        TestMIBNF_Comp.Name = mibnfComp.Name;
        TestMIBNF_Comp.MIBNF__c= mibnfComp.MIBNF__c;
        TestMIBNF_Comp.BNF_Status__c='RA_ACCEPTED';
        TestMIBNF_Comp.Is_this_a_retainer_downpayment__c='No';
        TestMIBNF_Comp.Print_Shop__c='No';
        TestMIBNF_Comp.RA_End_Date__c = Date.today();
        TestMIBNF_Comp.Opportunity__C = mibnfComp.Opportunity__C;
        insert TestMIBNF_Comp;
        
        tcm = Trigger_Control_For_Migration__c.getInstance();
        tcm.Disable_MIBNF_Trigger__c = true;
        upsert tcm;
        TestMIBNF_Comp.BNF_Status__c='SAP Contract Confirmed';
        TestMIBNF_Comp.OLI_Json_Data_1__c = JSON.serialize(add1_oli);
        upsert TestMIBNF_Comp;
        
        mibnfComp.Addendum__c=true;
        mibnfComp.Revised_BNF_Comment__c = 'Test';
        mibnfComp.Revised_BNF_Reason__c = 'Cancellation';
        mibnfComp.Revised_BNF_Date__c = System.today();
        mibnfComp.RA_End_Date__c = Date.today();
        mibnfComp.Orignal_BNF__c = TestMIBNF_Comp.Id;
        upsert mibnfComp;
        
        ApexPages.CurrentPage().getParameters().put('id' , mibnfComp.id );
        ApexPages.CurrentPage().getParameters().put('mibnfid' , mibnfComp.MIBNF__c);
        
        add1_oli[0].Revised_Revenue_Schedule__c = '201211:201211|201211:201211';
        UTL_ExecutionControl.stopTriggerExecution = true;
        update add1_oli[0];
        UTL_ExecutionControl.stopTriggerExecution = false;
        MI_BNF_Comp_PDF compPDF = new MI_BNF_Comp_PDF();
        compPDF.getOpportunityLineItem();
        compPDF.GetBilling_Schedule_Items();
        compPDF.GetRevenue_Schedule_Items();
        
        compPDF.getRevenue_Schedule_Items_String();
        compPDF.getCurrentTime();
        Test.stopTest();
    }
}