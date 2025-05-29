@isTest
private class TST_MIBNF_ProductControllerLockedGrid {
    
    private static OpportunityLineItem OLI1;
    
    @testSetup static void setupTestData(){
        Current_Release_Version__c crv = new Current_Release_Version__c();
        crv.Current_Release__c = '3000.01';
        upsert crv;

        Global_Variables.PCFlag = false;
        Global_Variables.RunQuickOppLimitTrigger = false;
        Global_Variables.RenewalCloneFlag = TRUE;
        Global_Variables.syncAgreementToOppty=false;
        Global_Variables.PCTrigger_Hault_Execution=false;
        UTL_ExecutionControl.stopTriggerExecution = true;
        User u = BNF_Test_Data.createUser();
        Account TestAccount = BNF_Test_Data.createAccount();
        Contact cnt = UTL_TestData.createContact(TestAccount.Id);
        cnt.RecordTypeId = CON_CRM.IQVIA_USER_CONTACT_RECORD_TYPE_ID;
        cnt.Salesforce_User__c = u.id;
        insert cnt;
        
        List<Address__c> TestAddress_Array = BNF_Test_Data.createAddress_Array();
        List<SAP_Contact__c> TestSapContact_Array = BNF_Test_Data.createSapContact_Array();

        Opportunity opp = BNF_Test_Data.createOpp();
        opp.Opportunity_Number__c = '123';
        update opp;
        BNF_Settings__c bnfsetting = BNF_Test_Data.createBNFSetting();
        List<User_Locale__c> User_LocaleSetting = BNF_Test_Data.create_User_LocaleSetting();
        List<OpportunityLineItem> OLI_Array = BNF_Test_Data.createOppLineItem();
        
        Profit_Centre__c pseregion = CommanUtilityTestFunction.setUpRegion();
        pseregion.Profit_Center_Code_Chain__c = 'test(TOTGEO)test';
        insert pseregion;
        
        Revenue_Analyst__c TestLocalRA = BNF_Test_Data.createRA();
        MIBNF2__c TestMIBNF = BNF_Test_Data.createMIBNF();
        Trigger_Control_For_Migration__c tcm = Trigger_Control_For_Migration__c.getInstance();
        tcm.Disable_MIBNF_Trigger__c = true;
        MIBNF_Component__c TestMIBNF_Comp = BNF_Test_Data.createMIBNF_Comp();
        //remove code from here
        UTL_ExecutionControl.stopTriggerExecution = false;
        upsert tcm;
    }
    
    public static testMethod void testMyController() {
        MIBNF_Component__c TestMIBNF_Comp = [Select id,name,MIBNF__c, Addendum__c,Is_this_a_retainer_downpayment__c, Print_Shop__c,BNF_Status__c, Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from MIBNF_Component__c][0];
        MIBNF2__c TestMIBNF = [Select id,name,Client__c,Opportunity__c,Sales_Org_Code__c,Billing_Currency__c,IMS_Sales_Org__c,Fair_Value_Type__c,Invoice_Default_Day__c,Contract_Start_Date__c,Contract_End_Date__c,Contract_Type__c,Contract_Term__c,Payment_Terms__c,Revenue_Analyst__c from MIBNF2__c][0];
        List<OpportunityLineItem> olis = [SELECT Id, TotalPrice FROM OpportunityLineItem];
        
        Test.startTest();
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, olis[0]);
        insert TestMI_BNFLineItem;
        List<Billing_Schedule__c> billingSchedule = UTL_TestData.createBillingSchedules(olis);
        insert billingSchedule;
        List<Billing_Schedule_Item__c> billingScheduleItem = UTL_TestData.createBillingScheduleItems(billingSchedule);
        insert billingScheduleItem;        
        PageReference pageRef = new PageReference('Page.MIBNF_ProductController');
        pageRef.getParameters().put('compid', TestMIBNF_Comp.id);
        Test.setCurrentPage(pageRef);
        ApexPages.standardController controller = new ApexPages.standardController(new MIBNF_Component__c());
        MIBNF_ProductControllerLockedGrid extension = new MIBNF_ProductControllerLockedGrid(controller);
        
        extension.testCheck();
        
        ApexPages.currentPage().getParameters().put('compid',TestMIBNF_Comp.id);
        extension = new MIBNF_ProductControllerLockedGrid(controller);
        
        PageReference dummy = extension.save();
        
        for(Integer i=0;i<extension.opptyLineItem2.size();i++)
        {
            extension.opptyLineItem2[i].Billing_Date__c=system.today();  
            extension.opptyLineItem2[i].Delivery_Date__c=system.today();    
            
        }
        extension.ProductCheck();
        dummy = extension.save();
        
        List<OpportunityLineItem> dummyList = extension.getOpportunityLineItem2();
        //   extension.setDeliveryMediaAll();
        ApexPages.currentPage().getParameters().put('retURL','/'+TestMIBNF_Comp.id);
        ApexPages.currentPage().getParameters().put('editbnf','editbnf');
        dummy = extension.cancel();
        extension.setDeliveryMediaOpt(true);
        extension.getDeliveryMediaOpt();
        extension.getMIBNF_Comp();
        
        extension.setTemp('Temp');
        String temp = extension.getTemp();
        Test.stoptest();
        
    }
    
    public static testMethod void test5() {
        MIBNF_Component__c TestMIBNF_Comp = [Select id,name,MIBNF__c, Addendum__c,Is_this_a_retainer_downpayment__c, Print_Shop__c,BNF_Status__c, Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from MIBNF_Component__c][0];
        MIBNF2__c TestMIBNF = [Select id,name,Client__c,Opportunity__c,Sales_Org_Code__c,Billing_Currency__c,IMS_Sales_Org__c,Fair_Value_Type__c,Invoice_Default_Day__c,Contract_Start_Date__c,Contract_End_Date__c,Contract_Type__c,Contract_Term__c,Payment_Terms__c,Revenue_Analyst__c from MIBNF2__c][0];
        List<OpportunityLineItem> olis = [SELECT Id, TotalPrice FROM OpportunityLineItem];
        
        Test.startTest();
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, olis[0]);
        insert TestMI_BNFLineItem;
        List<Billing_Schedule__c> billingSchedule = UTL_TestData.createBillingSchedules(olis);
        insert billingSchedule;
        List<Billing_Schedule_Item__c> billingScheduleItem = UTL_TestData.createBillingScheduleItems(billingSchedule);
        insert billingScheduleItem;        
        PageReference pageRef = new PageReference('Page.MIBNF_ProductController');
        pageRef.getParameters().put('compid', TestMIBNF_Comp.id);
        Test.setCurrentPage(pageRef);
        ApexPages.standardController controller = new ApexPages.standardController(new MIBNF_Component__c());
        MIBNF_ProductControllerLockedGrid extension = new MIBNF_ProductControllerLockedGrid(controller);
        
        ApexPages.currentPage().getParameters().put('compid',TestMIBNF_Comp.id);
        extension = new MIBNF_ProductControllerLockedGrid(controller);
        
        
        for(Integer i=0;i<extension.opptyLineItem2.size();i++)
        {
            extension.opptyLineItem2[i].Billing_Frequency__c='Once';
            extension.opptyLineItem2[i].Proj_Rpt_Frequency__c='Once [O]';
            extension.opptyLineItem2[i].List_Price__c=2;
            extension.opptyLineItem2[i].Billing_Date__c=null;  
            extension.opptyLineItem2[i].Delivery_Date__c=null;
            extension.opptyLineItem2[i].Revenue_Type__c='Ad Hoc';
            
        }
        extension.setOpportunityLineItem(extension.opptyLineItem2);
        pageRef = extension.save();
        ApexPages.Message msg1 = ApexPages.getMessages()[0];        
        msg1 = ApexPages.getMessages()[1];
        
        test.stoptest();
        
    }
    
    
    //This Method test for MIBNF LineItem and redirect user directly to MIBNF view page when user is following wizard steps  
    /*public static testmethod void LineItemTest()
    {
        MIBNF_Component__c TestMIBNF_Comp = [Select id,name,MIBNF__c, Addendum__c,Is_this_a_retainer_downpayment__c, Print_Shop__c,BNF_Status__c, Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from MIBNF_Component__c][0];
        MIBNF2__c TestMIBNF = [Select id,name,Client__c,Opportunity__c,Sales_Org_Code__c,Billing_Currency__c,IMS_Sales_Org__c,Fair_Value_Type__c,Invoice_Default_Day__c,Contract_Start_Date__c,Contract_End_Date__c,Contract_Type__c,Contract_Term__c,Payment_Terms__c,Revenue_Analyst__c from MIBNF2__c][0];
        List<OpportunityLineItem> oliList = [Select   Opportunity.CEQActiveRelease__c,Discount_Percentage_Formula__c, PricebookEntry.Name, 
                                             PricebookEntry.Product2.Material_Type__c,PricebookEntry.Product2.Offering_Group__c ,Opportunity.Therapy_Area__c,  
                                             PricebookEntry.Product2.Offering_Type__c , List_Price__c, Nbr_of_Users__c, Book_No__c,Other_Ship_To_SAP_Contact__c,
                                             CurrencyISOCode,TotalPrice,Delivery_Media__c, Product_Invoice_Text__c, PricebookEntry.ProductCode,PricebookEntry.Product2.Delivery_Media__c,
                                             PricebookEntry.Product2.Delivery_Frequency__c,Other_Ship_To_Address__c,Surcharge_Text__c,
                                             Billing_Frequency__c,Product_Start_Date__c,Product_End_Date__c, Proj_Rpt_Frequency__c,Discount_Reason__c, 
                                             Discount_Amount_Formula__c, Other_Ship_To__c, Billing_Date__c, Sale_Type__c, Revenue_Type__c,PricebookEntry.Product2.Item_Category_Group__c,  
                                             Invoice_Lag_to_Data_Period__c, Revised_Price__c,Therapy_Area__c, Cancel__c,Business_Type__c, Delivery_Date__c,PO_Number__c,
                                             Sales_Text__c,Budget_Therapy_Area__c,Project_Start_Date__c,Project_End_Date__c, 
                                             OpportunityId,Billing_Schedule_Error_Msg__c,Revised_Revenue_Schedule__c,Revenue_Schedule_Error_Msg__c From OpportunityLineItem o Limit 5] ;   
        Test.starttest();
        
        
        ApexPages.CurrentPage().getParameters().put('minfid' , TestMIBNF.Id );
        ApexPages.CurrentPage().getParameters().put('prdids' , oliList[1].Id);
        MI_BNF_ADD_Product prdcontroller = new MI_BNF_ADD_Product();
        prdcontroller.selectedInvoice=TestMIBNF_Comp.Id;
        PageReference prdpageRef=prdcontroller.Save();
        
        PageReference pageRef = new PageReference('Page.MIBNF_ProductController');
        pageRef.getParameters().put('compid', TestMIBNF_Comp.id);
        Test.setCurrentPage(pageRef);
        ApexPages.standardController controller = new ApexPages.standardController(new MIBNF_Component__c());
        MIBNF_ProductControllerLockedGrid extension = new MIBNF_ProductControllerLockedGrid(controller);
        
        PageReference pg=extension.ProductCheck();
        test.stoptest();
    }*/
    
    public static testmethod void LineItemTestwithoutProductTest()
    {
        List<OpportunityLineItem> olis = [SELECT Id, TotalPrice FROM OpportunityLineItem];
        MIBNF_Component__c TestMIBNF_Comp = [Select id,name,MIBNF__c, Addendum__c,Is_this_a_retainer_downpayment__c, Print_Shop__c,BNF_Status__c, Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from MIBNF_Component__c][0];
        MIBNF2__c TestMIBNF = [Select id,name,Client__c,Opportunity__c,Sales_Org_Code__c,Billing_Currency__c,IMS_Sales_Org__c,Fair_Value_Type__c,Invoice_Default_Day__c,Contract_Start_Date__c,Contract_End_Date__c,Contract_Type__c,Contract_Term__c,Payment_Terms__c,Revenue_Analyst__c from MIBNF2__c][0];
        
        Test.startTest();
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, olis[0]);
        insert TestMI_BNFLineItem;
        List<Billing_Schedule__c> billingSchedule = UTL_TestData.createBillingSchedules(olis);
        insert billingSchedule;
        List<Billing_Schedule_Item__c> billingScheduleItem = UTL_TestData.createBillingScheduleItems(billingSchedule);
        insert billingScheduleItem;        
        
        PageReference pageRef = new PageReference('Page.MIBNF_ProductController');
        pageRef.getParameters().put('compid', TestMIBNF_Comp.id);
        Test.setCurrentPage(pageRef);
        ApexPages.standardController controller = new ApexPages.standardController(new MIBNF_Component__c());
        MIBNF_ProductControllerLockedGrid extension = new MIBNF_ProductControllerLockedGrid(controller);
        
        PageReference pg=extension.ProductCheck();
        //ApexPages.Message msg1 = ApexPages.getMessages()[0];
        test.stoptest();
    }
    
    public static testmethod void LineItemTestSetLocale()
    {
        List<OpportunityLineItem> olis = [SELECT Id, TotalPrice FROM OpportunityLineItem];
        MIBNF_Component__c TestMIBNF_Comp = [Select id,name,MIBNF__c, Addendum__c,Is_this_a_retainer_downpayment__c, Print_Shop__c,BNF_Status__c, Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from MIBNF_Component__c][0];
        MIBNF2__c TestMIBNF = [Select id,name,Client__c,Opportunity__c,Sales_Org_Code__c,Billing_Currency__c,IMS_Sales_Org__c,Fair_Value_Type__c,Invoice_Default_Day__c,Contract_Start_Date__c,Contract_End_Date__c,Contract_Type__c,Contract_Term__c,Payment_Terms__c,Revenue_Analyst__c from MIBNF2__c][0];
        
        Test.startTest();
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, olis[0]);
        insert TestMI_BNFLineItem;
        List<Billing_Schedule__c> billingSchedule = UTL_TestData.createBillingSchedules(olis);
        insert billingSchedule;
        List<Billing_Schedule_Item__c> billingScheduleItem = UTL_TestData.createBillingScheduleItems(billingSchedule);
        insert billingScheduleItem;        
        
        PageReference pageRef = new PageReference('Page.MIBNF_ProductController');
        pageRef.getParameters().put('compid', TestMIBNF_Comp.id);
        Test.setCurrentPage(pageRef);
        ApexPages.standardController controller = new ApexPages.standardController(new MIBNF_Component__c());
        MIBNF_ProductControllerLockedGrid extension = new MIBNF_ProductControllerLockedGrid(controller);
        
        User_Locale__c userlo = [Select id ,LocaleSidKey__c, LocaleSidKey1__c from User_Locale__c where name ='Format6'];
        userlo.LocaleSidKey__c = ';en_US;' ;
        userlo.LocaleSidKey1__c = ';en_US;' ;
        upsert userlo;
        extension.setLocaleFormat();
        
        userlo = [Select id ,LocaleSidKey__c, LocaleSidKey1__c from User_Locale__c where name ='Format5'];
        userlo.LocaleSidKey__c = ';en_US;' ;
        userlo.LocaleSidKey1__c = ';en_US;' ;
        upsert userlo;
        extension.setLocaleFormat();
        
        userlo = [Select id ,LocaleSidKey__c, LocaleSidKey1__c from User_Locale__c where name ='Format4'];
        userlo.LocaleSidKey__c = ';en_US;' ;
        userlo.LocaleSidKey1__c = ';en_US;' ;
        upsert userlo;
        extension.setLocaleFormat();
        
        userlo = [Select id ,LocaleSidKey__c, LocaleSidKey1__c from User_Locale__c where name ='Format3'];
        userlo.LocaleSidKey__c = ';en_US;' ;
        userlo.LocaleSidKey1__c = ';en_US;' ;
        upsert userlo;
        extension.setLocaleFormat();
        
        userlo = [Select id ,LocaleSidKey__c, LocaleSidKey1__c from User_Locale__c where name ='Format2'];
        userlo.LocaleSidKey__c = ';en_US;' ;
        userlo.LocaleSidKey1__c = ';en_US;' ;
        upsert userlo;
        extension.setLocaleFormat();
        
        userlo = [Select id ,LocaleSidKey__c, LocaleSidKey1__c from User_Locale__c where name ='Format1'];
        userlo.LocaleSidKey__c = ';en_US;' ;
        userlo.LocaleSidKey1__c = ';en_US;' ;
        upsert userlo;
        extension.setLocaleFormat();
        //ApexPages.Message msg1 = ApexPages.getMessages()[0];
        test.stoptest();
    }
    
    public static testmethod void LineItemTestwithoutProductCheck()
    {
        List<OpportunityLineItem> olis = [SELECT Id, TotalPrice FROM OpportunityLineItem];
        MIBNF_Component__c TestMIBNF_Comp = [Select id,name,MIBNF__c, Addendum__c,Is_this_a_retainer_downpayment__c, Print_Shop__c,BNF_Status__c, Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from MIBNF_Component__c][0];
        MIBNF2__c TestMIBNF = [Select id,name,Client__c,Opportunity__c,Sales_Org_Code__c,Billing_Currency__c,IMS_Sales_Org__c,Fair_Value_Type__c,Invoice_Default_Day__c,Contract_Start_Date__c,Contract_End_Date__c,Contract_Type__c,Contract_Term__c,Payment_Terms__c,Revenue_Analyst__c from MIBNF2__c][0];
        
        Test.startTest();
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, olis[0]);
        insert TestMI_BNFLineItem;
        List<Billing_Schedule__c> billingSchedule = UTL_TestData.createBillingSchedules(olis);
        insert billingSchedule;
        List<Billing_Schedule_Item__c> billingScheduleItem = UTL_TestData.createBillingScheduleItems(billingSchedule);
        insert billingScheduleItem;        
        
        PageReference pageRef = new PageReference('Page.MIBNF_ProductController');
        pageRef.getParameters().put('compid', TestMIBNF_Comp.id);
        Test.setCurrentPage(pageRef);
        ApexPages.standardController controller = new ApexPages.standardController(new MIBNF_Component__c());
        MIBNF_ProductControllerLockedGrid extension = new MIBNF_ProductControllerLockedGrid(controller);
        extension.setOpportunityLineItem(new List<OpportunityLineItem>());
        PageReference pg=extension.ProductCheck();
        //ApexPages.Message msg1 = ApexPages.getMessages()[0];
        pageRef.getParameters().put('wz', '1');
        pg=extension.ProductCheck();
        test.stoptest();
    }
    
    public static testmethod void t1()
    {
        CLS_ProductionReference Convertor = new CLS_ProductionReference();
        Integer iTest = Convertor.CalculateElapsedMinsThisYear();
        system.debug('Mins this year: '+ iTest.format());
        String sOutput = Convertor.ConvertToRadix34(364883);
        system.debug('Output: '+ sOutput);
        system.assertEquals('AAMV',sOutput);
    }
    
    // Added By Himanshu Parashar
    // Date : 14 May 2012
    // Validation checkes
    public static testMethod void DeliveryDateValidationchecks() {
        List<OpportunityLineItem> olis = [SELECT Id, TotalPrice FROM OpportunityLineItem];
        MIBNF_Component__c TestMIBNF_Comp = [Select id,name,MIBNF__c, Addendum__c,Is_this_a_retainer_downpayment__c, Print_Shop__c,BNF_Status__c, Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from MIBNF_Component__c][0];
        MIBNF2__c TestMIBNF = [Select id,name,Client__c,Opportunity__c,Sales_Org_Code__c,Billing_Currency__c,IMS_Sales_Org__c,Fair_Value_Type__c,Invoice_Default_Day__c,Contract_Start_Date__c,Contract_End_Date__c,Contract_Type__c,Contract_Term__c,Payment_Terms__c,Revenue_Analyst__c from MIBNF2__c][0];
        
        Test.startTest();
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, olis[0]);
        insert TestMI_BNFLineItem;
        List<Billing_Schedule__c> billingSchedule = UTL_TestData.createBillingSchedules(olis);
        insert billingSchedule;
        List<Billing_Schedule_Item__c> billingScheduleItem = UTL_TestData.createBillingScheduleItems(billingSchedule);
        insert billingScheduleItem;        
        
        PageReference pageRef = new PageReference('Page.MIBNF_ProductController');
        pageRef.getParameters().put('compid', TestMIBNF_Comp.id);
        Test.setCurrentPage(pageRef);
        ApexPages.standardController controller = new ApexPages.standardController(new MIBNF_Component__c());
        MIBNF_ProductControllerLockedGrid extension = new MIBNF_ProductControllerLockedGrid(controller);
        
        ApexPages.currentPage().getParameters().put('compid',TestMIBNF_Comp.id);
        extension = new MIBNF_ProductControllerLockedGrid(controller);
        
        Date dateval = date.today();
        for(Integer i=0;i<extension.opptyLineItem2.size();i++)
        {
            extension.opptyLineItem2[i].Billing_Frequency__c='Once';
            extension.opptyLineItem2[i].Proj_Rpt_Frequency__c='Once [O]';
            extension.opptyLineItem2[i].List_Price__c=2;
            extension.opptyLineItem2[i].Billing_Date__c=null;  
            extension.opptyLineItem2[i].Delivery_Date__c=dateval.addDays(-5);
            extension.opptyLineItem2[i].Revenue_Type__c='Ad Hoc';
            extension.opptyLineItem2[i].Product_End_Date__c=dateval;
            extension.opptyLineItem2[i].Product_Start_Date__c=dateval.addDays(5);
            extension.opptyLineItem2[i].surcharge_text__c='Test';
            
        }
        extension.setOpportunityLineItem(extension.opptyLineItem2);
        pageRef = extension.save();
        ApexPages.Message msg1 = ApexPages.getMessages()[0];
        test.stoptest();
    }
    
    public static testMethod void DeliveryDateValidationchecks1() {
        List<OpportunityLineItem> olis = [SELECT Id, TotalPrice FROM OpportunityLineItem];
        MIBNF_Component__c TestMIBNF_Comp = [Select id,name,MIBNF__c, Addendum__c,Is_this_a_retainer_downpayment__c, Print_Shop__c,BNF_Status__c, Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from MIBNF_Component__c][0];
        MIBNF2__c TestMIBNF = [Select id,name,Client__c,Opportunity__c,Sales_Org_Code__c,Billing_Currency__c,IMS_Sales_Org__c,Fair_Value_Type__c,Invoice_Default_Day__c,Contract_Start_Date__c,Contract_End_Date__c,Contract_Type__c,Contract_Term__c,Payment_Terms__c,Revenue_Analyst__c from MIBNF2__c][0];
        
        Test.startTest();
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, olis[0]);
        insert TestMI_BNFLineItem;
        List<Billing_Schedule__c> billingSchedule = UTL_TestData.createBillingSchedules(olis);
        insert billingSchedule;
        List<Billing_Schedule_Item__c> billingScheduleItem = UTL_TestData.createBillingScheduleItems(billingSchedule);
        insert billingScheduleItem;        
        
        PageReference pageRef = new PageReference('Page.MIBNF_ProductController');
        pageRef.getParameters().put('compid', TestMIBNF_Comp.id);
        Test.setCurrentPage(pageRef);
        ApexPages.standardController controller = new ApexPages.standardController(new MIBNF_Component__c());
        MIBNF_ProductControllerLockedGrid extension = new MIBNF_ProductControllerLockedGrid(controller);
        
        ApexPages.currentPage().getParameters().put('compid',TestMIBNF_Comp.id);
        extension = new MIBNF_ProductControllerLockedGrid(controller);
        
        Date dateval = date.today();
        List<Product2> prodlist = [Select id from Product2 ];
        for(Product2 prod : prodlist) {
            prod.Delivery_Frequency__c = null;
            prod.Delivery_Media__c = null;
            prod.Offering_Type__c = 'Commercial Tech';
        }
        upsert prodlist;
        for(Integer i=0;i<extension.opptyLineItem2.size();i++)
        {
            extension.opptyLineItem2[i].Billing_Frequency__c='Once';
            extension.opptyLineItem2[i].Proj_Rpt_Frequency__c='Once [O]';
            extension.opptyLineItem2[i].List_Price__c= null;
            extension.opptyLineItem2[i].Billing_Date__c=null;  
            extension.opptyLineItem2[i].Delivery_Date__c=dateval.addDays(-5);
            extension.opptyLineItem2[i].Revenue_Type__c='Subscription';
            extension.opptyLineItem2[i].Product_End_Date__c= dateval.addDays(5);
            extension.opptyLineItem2[i].Product_Start_Date__c=dateval.addDays(5);
            extension.opptyLineItem2[i].surcharge_text__c='Test';
            
            extension.opptyLineItem2[i].Revised_Revenue_Schedule__c = '20160222:100|20160628:100';  
            extension.opptyLineItem2[i].Revised_Price__c  = 100;    
            extension.opptyLineItem2[i].Billing_Date__c  = null; 
            extension.opptyLineItem2[i].Billing_Frequency__c  = 'Once';
            extension.opptyLineItem2[i].Proj_Rpt_Frequency__c  = 'Once [O]';    
            
        }
        
        extension.setOpportunityLineItem(extension.opptyLineItem2);
        pageRef = extension.save();
        test.stoptest();
    }
    
    public static testMethod void DeliveryDateValidationchecks2() {
        List<OpportunityLineItem> olis = [SELECT Id, TotalPrice FROM OpportunityLineItem];
        Date dateval = date.today();
        MIBNF_Component__c TestMIBNF_Comp = [Select id,name,MIBNF__c, Addendum__c,Is_this_a_retainer_downpayment__c, Print_Shop__c,BNF_Status__c, Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from MIBNF_Component__c][0];
        MIBNF2__c TestMIBNF = [Select id,name,Client__c,Opportunity__c,Sales_Org_Code__c,Billing_Currency__c,IMS_Sales_Org__c,Fair_Value_Type__c,Invoice_Default_Day__c,Contract_Start_Date__c,Contract_End_Date__c,Contract_Type__c,Contract_Term__c,Payment_Terms__c,Revenue_Analyst__c from MIBNF2__c][0];
        
        Test.startTest();
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, olis[0]);
        insert TestMI_BNFLineItem;
        List<Billing_Schedule__c> billingSchedule = UTL_TestData.createBillingSchedules(olis);
        insert billingSchedule;
        List<Billing_Schedule_Item__c> billingScheduleItem = UTL_TestData.createBillingScheduleItems(billingSchedule);
        insert billingScheduleItem;        
        BNF_Settings__c bnfsetting = [Select id, BNF_Opportunity_Threshold__c from  BNF_Settings__c limit 1 ];
        bnfsetting.BNF_Opportunity_Threshold__c = 11417163;
        upsert bnfsetting;
        List<OpportunityLineItem> oliList = [Select id from OpportunityLineItem ];
        for(OpportunityLineItem oli : oliList) {
            oli.Billing_Frequency__c='Once';
            oli.Proj_Rpt_Frequency__c='Once [O]';
            oli.List_Price__c= null;
            oli.Billing_Date__c=null;  
            oli.Delivery_Date__c=dateval.addDays(-5);
            oli.Revenue_Type__c='Subscription';
            oli.Product_End_Date__c= dateval.addDays(5);
            oli.Product_Start_Date__c=dateval.addDays(5);
            oli.surcharge_text__c='Test';
            oli.Revised_Revenue_Schedule__c = '20160222:100|20160628:100';  
            oli.Revised_Price__c  = 100;    
            oli.Billing_Date__c  = null; 
            oli.Billing_Frequency__c  = 'Once';
            oli.Proj_Rpt_Frequency__c  = 'Once [O]';
        }
        upsert oliList;
        List<Product2> prodlist = [Select id from Product2 ];
        for(Product2 prod : prodlist) {
            prod.Delivery_Frequency__c = null;
            prod.Delivery_Media__c = null;
            prod.Offering_Type__c = 'Commercial Tech';
        }
        upsert prodlist;
        PageReference pageRef = new PageReference('Page.MIBNF_ProductController');
        pageRef.getParameters().put('compid', TestMIBNF_Comp.id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.standardController controller = new ApexPages.standardController(new MIBNF_Component__c());
        MIBNF_ProductControllerLockedGrid extension = new MIBNF_ProductControllerLockedGrid(controller);
        
        ApexPages.currentPage().getParameters().put('compid',TestMIBNF_Comp.id);
        extension = new MIBNF_ProductControllerLockedGrid(controller);
        
        
        
        for(Integer i=0;i<extension.opptyLineItem2.size();i++)
        {
            extension.opptyLineItem2[i].Billing_Frequency__c='Once';
            extension.opptyLineItem2[i].Proj_Rpt_Frequency__c='Once [O]';
            extension.opptyLineItem2[i].List_Price__c= null;
            extension.opptyLineItem2[i].Billing_Date__c=null;  
            extension.opptyLineItem2[i].Delivery_Date__c=dateval.addDays(-5);
            extension.opptyLineItem2[i].Revenue_Type__c='Subscription';
            extension.opptyLineItem2[i].Product_End_Date__c= dateval.addDays(5);
            extension.opptyLineItem2[i].Product_Start_Date__c=dateval.addDays(5);
            extension.opptyLineItem2[i].surcharge_text__c='Test';
            
            extension.opptyLineItem2[i].Revised_Revenue_Schedule__c = '20160222:100|20160628:100';  
            extension.opptyLineItem2[i].Revised_Price__c  = 100;    
            extension.opptyLineItem2[i].Billing_Date__c  = null; 
            extension.opptyLineItem2[i].Billing_Frequency__c  = 'Once';
            extension.opptyLineItem2[i].Proj_Rpt_Frequency__c  = 'Once [O]';    
            
        }
        
        extension.setOpportunityLineItem(extension.opptyLineItem2);
        pageRef = extension.save();
        test.stoptest();
    }
    
    public static testMethod void DataPeriodValidationchecks() {
        List<OpportunityLineItem> olis = [SELECT Id, TotalPrice FROM OpportunityLineItem];
        MIBNF_Component__c TestMIBNF_Comp = [Select id,name,MIBNF__c, Addendum__c,Is_this_a_retainer_downpayment__c, Print_Shop__c,BNF_Status__c, Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from MIBNF_Component__c][0];
        MIBNF2__c TestMIBNF = [Select id,name,Client__c,Opportunity__c,Sales_Org_Code__c,Billing_Currency__c,IMS_Sales_Org__c,Fair_Value_Type__c,Invoice_Default_Day__c,Contract_Start_Date__c,Contract_End_Date__c,Contract_Type__c,Contract_Term__c,Payment_Terms__c,Revenue_Analyst__c from MIBNF2__c][0];
        
        Test.startTest();
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, olis[0]);
        insert TestMI_BNFLineItem;
        List<Billing_Schedule__c> billingSchedule = UTL_TestData.createBillingSchedules(olis);
        insert billingSchedule;
        List<Billing_Schedule_Item__c> billingScheduleItem = UTL_TestData.createBillingScheduleItems(billingSchedule);
        insert billingScheduleItem;        
        
        PageReference pageRef = new PageReference('Page.MIBNF_ProductController');
        pageRef.getParameters().put('compid', TestMIBNF_Comp.id);
        Test.setCurrentPage(pageRef);
        ApexPages.standardController controller = new ApexPages.standardController(new MIBNF_Component__c());
        MIBNF_ProductControllerLockedGrid extension = new MIBNF_ProductControllerLockedGrid(controller);
        
        ApexPages.currentPage().getParameters().put('compid',TestMIBNF_Comp.id);
        extension = new MIBNF_ProductControllerLockedGrid(controller);
        
        Date dateval = date.today();
        
        for(Integer i=0;i<extension.opptyLineItem2.size();i++)
        {
            extension.opptyLineItem2[i].Billing_Frequency__c='Once';
            extension.opptyLineItem2[i].Proj_Rpt_Frequency__c='Once [O]';
            extension.opptyLineItem2[i].List_Price__c=2;
            extension.opptyLineItem2[i].Billing_Date__c=null;  
            extension.opptyLineItem2[i].Delivery_Date__c=dateval.addDays(10);
            extension.opptyLineItem2[i].Revenue_Type__c='Back Data';
            extension.opptyLineItem2[i].Product_End_Date__c=dateval.addDays(3);
            extension.opptyLineItem2[i].Product_Start_Date__c=dateval.addDays(5);
            
        }
        extension.setOpportunityLineItem(extension.opptyLineItem2);
        pageRef = extension.save();
        ApexPages.Message msg1 = ApexPages.getMessages()[0];
        msg1 = ApexPages.getMessages()[1];
        test.stoptest();
    }
    
    public static testMethod void SubscriptionProductValidationchecks() {
        List<OpportunityLineItem> olis = [SELECT Id, TotalPrice FROM OpportunityLineItem];
        MIBNF_Component__c TestMIBNF_Comp = [Select id,name,MIBNF__c, Addendum__c,Is_this_a_retainer_downpayment__c, Print_Shop__c,BNF_Status__c, Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from MIBNF_Component__c][0];
        MIBNF2__c TestMIBNF = [Select id,name,Client__c,Opportunity__c,Sales_Org_Code__c,Billing_Currency__c,IMS_Sales_Org__c,Fair_Value_Type__c,Invoice_Default_Day__c,Contract_Start_Date__c,Contract_End_Date__c,Contract_Type__c,Contract_Term__c,Payment_Terms__c,Revenue_Analyst__c from MIBNF2__c][0];
        
        Test.startTest();
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, olis[0]);
        insert TestMI_BNFLineItem;
        List<Billing_Schedule__c> billingSchedule = UTL_TestData.createBillingSchedules(olis);
        insert billingSchedule;
        List<Billing_Schedule_Item__c> billingScheduleItem = UTL_TestData.createBillingScheduleItems(billingSchedule);
        insert billingScheduleItem;        
        
        PageReference pageRef = new PageReference('Page.MIBNF_ProductController');
        pageRef.getParameters().put('compid', TestMIBNF_Comp.id);
        Test.setCurrentPage(pageRef);
        ApexPages.standardController controller = new ApexPages.standardController(new MIBNF_Component__c());
        MIBNF_ProductControllerLockedGrid extension = new MIBNF_ProductControllerLockedGrid(controller);
        
        ApexPages.currentPage().getParameters().put('compid',TestMIBNF_Comp.id);
        extension = new MIBNF_ProductControllerLockedGrid(controller);
        
        
        Date dateval = date.today();
        
        
        for(Integer i=0;i<extension.opptyLineItem2.size();i++)
        {
            extension.opptyLineItem2[i].Billing_Frequency__c='Once';
            extension.opptyLineItem2[i].Proj_Rpt_Frequency__c='Once [O]';
            extension.opptyLineItem2[i].List_Price__c=2;
            extension.opptyLineItem2[i].Billing_Date__c=null;  
            extension.opptyLineItem2[i].Delivery_Date__c=dateval.addDays(10);
            extension.opptyLineItem2[i].Revenue_Type__c='Subscription';
            extension.opptyLineItem2[i].Product_End_Date__c=dateval.addDays(-3);
            extension.opptyLineItem2[i].Product_Start_Date__c=dateval.addDays(-5);
            
        }
        extension.setOpportunityLineItem(extension.opptyLineItem2);
        pageRef = extension.save();
        ApexPages.Message msg1 = ApexPages.getMessages()[0];
        msg1 = ApexPages.getMessages()[1];
        test.stoptest();
    }
    
    public static testMethod void test6() {
        List<OpportunityLineItem> olis = [SELECT Id, TotalPrice FROM OpportunityLineItem];
        MIBNF_Component__c TestMIBNF_Comp = [Select id,name,Addendum__c,MIBNF__c, Is_this_a_retainer_downpayment__c, Print_Shop__c,BNF_Status__c, Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from MIBNF_Component__c][0];
        MIBNF2__c TestMIBNF = [Select id,name,Client__c,Opportunity__c,Sales_Org_Code__c,Billing_Currency__c,IMS_Sales_Org__c,Fair_Value_Type__c,Invoice_Default_Day__c,Contract_Start_Date__c,Contract_End_Date__c,Contract_Type__c,Contract_Term__c,Payment_Terms__c,Revenue_Analyst__c from MIBNF2__c][0];
        
        Test.startTest();
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, olis[0]);
        insert TestMI_BNFLineItem;
        List<Billing_Schedule__c> billingSchedule = UTL_TestData.createBillingSchedules(olis);
        insert billingSchedule;
        List<Billing_Schedule_Item__c> billingScheduleItem = UTL_TestData.createBillingScheduleItems(billingSchedule);
        insert billingScheduleItem;        
        
        PageReference pageRef = new PageReference('Page.MIBNF_ProductController');
        pageRef.getParameters().put('compid', TestMIBNF_Comp.id);
        pageRef.getParameters().put('itemindex', '0');
        pageRef.getParameters().put('itemindex2', '0');
        pageRef.getParameters().put('pricevalue', '200');
        pageRef.getParameters().put('isRevised', '0');
        Test.setCurrentPage(pageRef);
        ApexPages.standardController controller = new ApexPages.standardController(new MIBNF_Component__c());
        MIBNF_ProductControllerLockedGrid extension = new MIBNF_ProductControllerLockedGrid(controller);
        
        ApexPages.currentPage().getParameters().put('compid',TestMIBNF_Comp.id);
        extension = new MIBNF_ProductControllerLockedGrid(controller);
        
        
        for(Integer i=0;i<extension.opptyLineItem2.size();i++)
        {
            extension.opptyLineItem2[i].Billing_Frequency__c='Once';
            extension.opptyLineItem2[i].Proj_Rpt_Frequency__c='Once [O]';
            extension.opptyLineItem2[i].List_Price__c=2;
            extension.opptyLineItem2[i].Billing_Date__c=null;  
            extension.opptyLineItem2[i].Delivery_Date__c=null;
            extension.opptyLineItem2[i].Revenue_Type__c='Ad Hoc';
            
        }
        extension.setOpportunityLineItem(extension.opptyLineItem2);
        pageRef = extension.save();
        extension.CalculateSurcharge();
        
        PageReference pageRef1 = new PageReference('Page.MIBNF_ProductController');
        pageRef1.getParameters().put('compid', TestMIBNF_Comp.id);
        pageRef1.getParameters().put('itemindex', '0');
        pageRef1.getParameters().put('itemindex2', '0');
        pageRef1.getParameters().put('pricevalue', '200');
        pageRef1.getParameters().put('isRevised', '1');
        Test.setCurrentPage(pageRef1);
        
        MIBNF_ProductControllerLockedGrid extension1 = new MIBNF_ProductControllerLockedGrid(controller);
        
        ApexPages.currentPage().getParameters().put('compid',TestMIBNF_Comp.id);
        extension1 = new MIBNF_ProductControllerLockedGrid(controller);
        extension1.CalculateSurcharge();
        extension1.CalculateRevisedPrice();
        extension1.oppLiId = extension1.opptyLineItem2[0].id;
        extension1.showBNFInfo();
        Double amt = extension1.billScheduleAmt;
        Integer num = extension1.billScheduleNum;
        
        test.stoptest();
        
    }
    public static testMethod void test7() {
        List<OpportunityLineItem> olis = [SELECT Id, TotalPrice FROM OpportunityLineItem];
        MIBNF_Component__c TestMIBNF_Comp = [Select id,name,Addendum__c,MIBNF__c, Is_this_a_retainer_downpayment__c, Print_Shop__c,BNF_Status__c, Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from MIBNF_Component__c][0];
        MIBNF2__c TestMIBNF = [Select id,name,Client__c,Opportunity__c,Sales_Org_Code__c,Billing_Currency__c,IMS_Sales_Org__c,Fair_Value_Type__c,Invoice_Default_Day__c,Contract_Start_Date__c,Contract_End_Date__c,Contract_Type__c,Contract_Term__c,Payment_Terms__c,Revenue_Analyst__c from MIBNF2__c][0];
        
        Test.startTest();
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, olis[0]);
        insert TestMI_BNFLineItem;
        List<Billing_Schedule__c> billingSchedule = UTL_TestData.createBillingSchedules(olis);
        insert billingSchedule;
        List<Billing_Schedule_Item__c> billingScheduleItem = UTL_TestData.createBillingScheduleItems(billingSchedule);
        insert billingScheduleItem;        
        BNF_Settings__c bnfsetting = [Select id, BNF_Opportunity_Threshold__c from  BNF_Settings__c limit 1 ];
        bnfsetting.BNF_Opportunity_Threshold__c = 11417163;
        upsert bnfsetting;
        PageReference pageRef = new PageReference('Page.MIBNF_ProductController');
        pageRef.getParameters().put('compid', TestMIBNF_Comp.id);
        pageRef.getParameters().put('itemindex', '0');
        pageRef.getParameters().put('itemindex2', '0');
        pageRef.getParameters().put('pricevalue', '200');
        pageRef.getParameters().put('isRevised', '0');
        Test.setCurrentPage(pageRef);
        ApexPages.standardController controller = new ApexPages.standardController(new MIBNF_Component__c());
        MIBNF_ProductControllerLockedGrid extension = new MIBNF_ProductControllerLockedGrid(controller);
        
        ApexPages.currentPage().getParameters().put('compid',TestMIBNF_Comp.id);
        extension = new MIBNF_ProductControllerLockedGrid(controller);
        
        
        for(Integer i=0;i<extension.opptyLineItem2.size();i++)
        {
            extension.opptyLineItem2[i].Billing_Frequency__c='Once';
            extension.opptyLineItem2[i].Proj_Rpt_Frequency__c='Once [O]';
            extension.opptyLineItem2[i].List_Price__c=2;
            extension.opptyLineItem2[i].Billing_Date__c=null;  
            extension.opptyLineItem2[i].Delivery_Date__c=null;
            extension.opptyLineItem2[i].Revenue_Type__c='Ad Hoc';
            
        }
        extension.setOpportunityLineItem(extension.opptyLineItem2);
        pageRef = extension.save();
        extension.CalculateSurcharge();
        
        PageReference pageRef1 = new PageReference('Page.MIBNF_ProductController');
        pageRef1.getParameters().put('compid', TestMIBNF_Comp.id);
        pageRef1.getParameters().put('itemindex', '0');
        pageRef1.getParameters().put('itemindex2', '0');
        pageRef1.getParameters().put('pricevalue', '200');
        pageRef1.getParameters().put('isRevised', '1');
        Test.setCurrentPage(pageRef1);
        
        MIBNF_ProductControllerLockedGrid extension1 = new MIBNF_ProductControllerLockedGrid(controller);
        
        ApexPages.currentPage().getParameters().put('compid',TestMIBNF_Comp.id);
        extension1 = new MIBNF_ProductControllerLockedGrid(controller);
        extension1.CalculateSurcharge();
        extension1.CalculateRevisedPrice();
        extension1.oppLiId = extension1.opptyLineItem2[0].id;
        extension1.showBNFInfo();
        Double amt = extension1.billScheduleAmt;
        Integer num = extension1.billScheduleNum;
        
        test.stoptest();
        
    }
    
    public static testMethod void testRevisedMIBNF() {
        List<OpportunityLineItem> olis = [SELECT Id, TotalPrice FROM OpportunityLineItem];
        MIBNF_Component__c TestMIBNF_Comp = [Select id,name,Addendum__c,MIBNF__c, Is_this_a_retainer_downpayment__c, Print_Shop__c,BNF_Status__c, Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from MIBNF_Component__c][0];
        MIBNF2__c TestMIBNF = [Select id,name,Client__c,Opportunity__c,Sales_Org_Code__c,Billing_Currency__c,IMS_Sales_Org__c,Fair_Value_Type__c,Invoice_Default_Day__c,Contract_Start_Date__c,Contract_End_Date__c,Contract_Type__c,Contract_Term__c,Payment_Terms__c,Revenue_Analyst__c from MIBNF2__c][0];
        
        Test.startTest();
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, olis[0]);
        insert TestMI_BNFLineItem;
        List<Billing_Schedule__c> billingSchedule = UTL_TestData.createBillingSchedules(olis);
        insert billingSchedule;
        List<Billing_Schedule_Item__c> billingScheduleItem = UTL_TestData.createBillingScheduleItems(billingSchedule);
        insert billingScheduleItem;        
        TestMIBNF_Comp.Addendum__c = true;
        TestMIBNF_Comp.Revised_BNF_Reason__c = 'Additional Fees';
        TestMIBNF_Comp.Revised_BNF_Date__c = system.today();
        upsert TestMIBNF_Comp;
        OpportunityLineItem olilist = [Select id , Revised_Revenue_Schedule__c from OpportunityLineItem limit 1];
        olilist.Revised_Revenue_Schedule__c = '20160222:100|20160628:100';
        upsert olilist; 
        PageReference pageRef = new PageReference('Page.MIBNF_ProductController');
        pageRef.getParameters().put('compid', TestMIBNF_Comp.id);
        pageRef.getParameters().put('itemindex', '0');
        pageRef.getParameters().put('itemindex2', '0');
        pageRef.getParameters().put('pricevalue', '200');
        pageRef.getParameters().put('isRevised', '0');
        Test.setCurrentPage(pageRef);
        ApexPages.standardController controller = new ApexPages.standardController(new MIBNF_Component__c());
        MIBNF_ProductControllerLockedGrid extension = new MIBNF_ProductControllerLockedGrid(controller);
        
        ApexPages.currentPage().getParameters().put('compid',TestMIBNF_Comp.id);
        extension = new MIBNF_ProductControllerLockedGrid(controller);
        pageRef = extension.save();
        
  
        test.stoptest();
        
    }
    
    static testMethod void testCalculateRevisedPrice1() {
        List<OpportunityLineItem> olis = [SELECT Id, TotalPrice FROM OpportunityLineItem];
        MIBNF_Component__c TestMIBNF_Comp = [Select id,name,Addendum__c,MIBNF__c, Is_this_a_retainer_downpayment__c, Print_Shop__c,BNF_Status__c, Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from MIBNF_Component__c][0];
        MIBNF2__c TestMIBNF = [Select id,name,Client__c,Opportunity__c,Sales_Org_Code__c,Billing_Currency__c,IMS_Sales_Org__c,Fair_Value_Type__c,Invoice_Default_Day__c,Contract_Start_Date__c,Contract_End_Date__c,Contract_Type__c,Contract_Term__c,Payment_Terms__c,Revenue_Analyst__c from MIBNF2__c][0];
        
        Test.startTest();
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, olis[0]);
        insert TestMI_BNFLineItem;
        List<Billing_Schedule__c> billingSchedule = UTL_TestData.createBillingSchedules(olis);
        insert billingSchedule;
        List<Billing_Schedule_Item__c> billingScheduleItem = UTL_TestData.createBillingScheduleItems(billingSchedule);
        insert billingScheduleItem;        
        PageReference pageRef = new PageReference('Page.MIBNF_ProductController');
        pageRef.getParameters().put('compid', TestMIBNF_Comp.id);
        pageRef.getParameters().put('itemindex', '0');
        pageRef.getParameters().put('itemindex2', '0');
        pageRef.getParameters().put('pricevalue', '200');
        pageRef.getParameters().put('isRevised', '0');
        Test.setCurrentPage(pageRef);
        ApexPages.standardController controller = new ApexPages.standardController(new MIBNF_Component__c());
        MIBNF_ProductControllerLockedGrid extension = new MIBNF_ProductControllerLockedGrid(controller);
        
        extension = new MIBNF_ProductControllerLockedGrid(controller);
        OpportunityLineItem olilist = [Select id , Revised_Revenue_Schedule__c from OpportunityLineItem limit 1];
        olilist.Revised_Revenue_Schedule__c = 'x|20160222:100|20160628:100';
        upsert olilist; 
        extension.CalculateRevisedPrice();
        
        olilist.Revised_Revenue_Schedule__c = '20160222:100|20160628:100';
        upsert olilist; 
        extension.CalculateRevisedPrice();
  
        test.stoptest();
        
    }
    
    static testMethod void partialSave1(){
        List<OpportunityLineItem> olis = [SELECT Id, TotalPrice FROM OpportunityLineItem];
        MIBNF_Component__c TestMIBNF_Comp = [Select Id,name,MIBNF__c,Opportunity__r.Opportunity_Number__c, Addendum__c,Is_this_a_retainer_downpayment__c, Print_Shop__c,BNF_Status__c, Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from MIBNF_Component__c][0];
        MIBNF2__c TestMIBNF = [Select Id,name,Client__c,Opportunity__c,Sales_Org_Code__c,Billing_Currency__c,IMS_Sales_Org__c,Fair_Value_Type__c,Invoice_Default_Day__c,Contract_Start_Date__c,Contract_End_Date__c,Contract_Type__c,Contract_Term__c,Payment_Terms__c,Revenue_Analyst__c from MIBNF2__c][0];
        Mulesoft_Integration_Control__c mulsoftSetting = Mulesoft_Integration_Control__c.getOrgDefaults();
        mulsoftSetting.Ignore_Validation_Rules__c = true;
        upsert mulsoftSetting;
        
        Test.startTest();
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, olis[0]);
        insert TestMI_BNFLineItem;
        List<Billing_Schedule__c> billingSchedule = UTL_TestData.createBillingSchedules(olis);
        insert billingSchedule;
        List<Billing_Schedule_Item__c> billingScheduleItem = UTL_TestData.createBillingScheduleItems(billingSchedule);
        insert billingScheduleItem;        
        Product2 product = [Select Id, Name from Product2 where Material_Type__c = 'ZPUB' Limit 1];
        upsert new Product2(Id = product.Id ,Item_Category_Group__c = 'ZPLU');
        OpportunityLineItem oppLineItem = [Select Id, TotalPrice from OpportunityLineItem Where PricebookEntry.Product2Id = :product.Id];
        upsert new OpportunityLineItem(Id = oppLineItem.Id, Product_Start_Date__c = Null,Nbr_of_Users__c = Null, Therapy_Area__c = Null, Billing_Frequency__c = Null,Delivery_Country__c = 'USA',
                                       Proj_Rpt_Frequency__c = Null, Billing_Date__c = Null, Delivery_Date__c = Null, Product_End_Date__c = Null, Delivery_Media__c = 'CD [CD]',
                                       Sale_Type__c = Null, Revenue_Type__c = Null );
        BNF_Settings__c bnfSetting = BNF_Settings__c.getOrgDefaults();
        bnfSetting.BNF_Opportunity_Threshold__c = decimal.valueOf(TestMIBNF_Comp.Opportunity__r.Opportunity_Number__c);
        upsert bnfSetting;
        addLineItemToMIBNFLineItem(TestMIBNF_Comp, oppLineItem);
        PageReference pageRef = new PageReference('Page.MIBNF_ProductController');
        pageRef.getParameters().put('compid', TestMIBNF_Comp.id);
        Test.setCurrentPage(pageRef);
        ApexPages.standardController controller = new ApexPages.standardController(new MIBNF_Component__c());
        MIBNF_ProductControllerLockedGrid extension = new MIBNF_ProductControllerLockedGrid(controller);
        
        extension.testCheck();
        
        ApexPages.currentPage().getParameters().put('compid',TestMIBNF_Comp.id);
        extension = new MIBNF_ProductControllerLockedGrid(controller);
        
        PageReference dummy = extension.save();
    }
    
    static testMethod void partialSave2(){
        List<OpportunityLineItem> olis = [SELECT Id, TotalPrice FROM OpportunityLineItem];
        MIBNF_Component__c TestMIBNF_Comp = [Select Id,name,MIBNF__c,Opportunity__r.Opportunity_Number__c, Addendum__c,Is_this_a_retainer_downpayment__c, Print_Shop__c,BNF_Status__c, Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from MIBNF_Component__c][0];
        MIBNF2__c TestMIBNF = [Select Id,name,Client__c,Opportunity__c,Sales_Org_Code__c,Billing_Currency__c,IMS_Sales_Org__c,Fair_Value_Type__c,Invoice_Default_Day__c,Contract_Start_Date__c,Contract_End_Date__c,Contract_Type__c,Contract_Term__c,Payment_Terms__c,Revenue_Analyst__c from MIBNF2__c][0];
        
        Mulesoft_Integration_Control__c mulsoftSetting = Mulesoft_Integration_Control__c.getOrgDefaults();
        mulsoftSetting.Ignore_Validation_Rules__c = true;
        upsert mulsoftSetting;
        
        Test.startTest();
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, olis[0]);
        insert TestMI_BNFLineItem;
        List<Billing_Schedule__c> billingSchedule = UTL_TestData.createBillingSchedules(olis);
        insert billingSchedule;
        List<Billing_Schedule_Item__c> billingScheduleItem = UTL_TestData.createBillingScheduleItems(billingSchedule);
        insert billingScheduleItem;        
        Product2 product = [Select Id, Name from Product2 where Material_Type__c = 'ZPUB' Limit 1];
        upsert new Product2(Id = product.Id ,Item_Category_Group__c = 'ZPLU');
        OpportunityLineItem oppLineItem = [Select Id, TotalPrice from OpportunityLineItem Where PricebookEntry.Product2Id = :product.Id];
        upsert new OpportunityLineItem(Id = oppLineItem.Id, Product_Start_Date__c = Null,Nbr_of_Users__c = Null, Therapy_Area__c = Null, Billing_Frequency__c = Null,Delivery_Country__c = 'USA',
                                       Proj_Rpt_Frequency__c = Null, Billing_Date__c = Null, Delivery_Date__c = Null, Product_End_Date__c = Null, Delivery_Media__c = 'CPA',
                                       Sale_Type__c = Null, Revenue_Type__c = Null );
        BNF_Settings__c bnfSetting = BNF_Settings__c.getOrgDefaults();
        bnfSetting.BNF_Opportunity_Threshold__c = Null;
        upsert bnfSetting;
        addLineItemToMIBNFLineItem(TestMIBNF_Comp, oppLineItem);
        PageReference pageRef = new PageReference('Page.MIBNF_ProductController');
        pageRef.getParameters().put('compid', TestMIBNF_Comp.id);
        Test.setCurrentPage(pageRef);
        ApexPages.standardController controller = new ApexPages.standardController(new MIBNF_Component__c());
        MIBNF_ProductControllerLockedGrid extension = new MIBNF_ProductControllerLockedGrid(controller);
        
        extension.testCheck();
        
        ApexPages.currentPage().getParameters().put('compid',TestMIBNF_Comp.id);
        extension = new MIBNF_ProductControllerLockedGrid(controller);
        extension.savePartial();
        PageReference dummy = extension.save();
    }
    
    static testMethod void test8(){
        Test.startTest();
        MIBNF_Component__c TestMIBNF_Comp = [Select Id,name from MIBNF_Component__c][0];
        MIBNF_ProductControllerLockedGrid extension = new MIBNF_ProductControllerLockedGrid(); 
        extension.setOpportunityLineItem();
        extension.setOppLineItem(TestMIBNF_Comp.Id);
        extension.setMIBNFComp(TestMIBNF_Comp.Id);
        Test.stopTest();
    }
    
    private static void addLineItemToMIBNFLineItem(MIBNF_Component__c TestMIBNF_Comp, OpportunityLineItem oppLineItem){
        
        MI_BNF_LineItem__c TestMI_BNFLineItem = new MI_BNF_LineItem__c();
        TestMI_BNFLineItem.MIBNF_Component__c = TestMIBNF_Comp.Id;
        TestMI_BNFLineItem.Opportunity_Line_Itemid__c = oppLineItem.Id;
        TestMI_BNFLineItem.Total_Price__c = oppLineItem.TotalPrice;
        upsert TestMI_BNFLineItem;
    }
    
    /**********************************************************************************************/
    
    public static testMethod void testForisNewBNFcase() {
        List<OpportunityLineItem> olis = [SELECT Id, TotalPrice FROM OpportunityLineItem];
        Date dateval = date.today();
        MIBNF_Component__c TestMIBNF_Comp = [Select id,name,MIBNF__c, Addendum__c,Is_this_a_retainer_downpayment__c, Print_Shop__c,BNF_Status__c, Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from MIBNF_Component__c][0];
        MIBNF2__c TestMIBNF = [Select id,name,Client__c,Opportunity__c,Sales_Org_Code__c,Billing_Currency__c,IMS_Sales_Org__c,Fair_Value_Type__c,Invoice_Default_Day__c,Contract_Start_Date__c,Contract_End_Date__c,Contract_Type__c,Contract_Term__c,Payment_Terms__c,Revenue_Analyst__c from MIBNF2__c][0];
        
        Test.startTest();
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, olis[0]);
        insert TestMI_BNFLineItem;
        List<Billing_Schedule__c> billingSchedule = UTL_TestData.createBillingSchedules(olis);
        insert billingSchedule;
        List<Billing_Schedule_Item__c> billingScheduleItem = UTL_TestData.createBillingScheduleItems(billingSchedule);
        insert billingScheduleItem;        
        BNF_Settings__c bnfsetting = [Select id, BNF_Opportunity_Threshold__c from  BNF_Settings__c limit 1 ];
        bnfsetting.BNF_Opportunity_Threshold__c = null;
        upsert bnfsetting;
        List<OpportunityLineItem> oliList = [Select id from OpportunityLineItem ];
        for(OpportunityLineItem oli : oliList) {
            oli.Billing_Frequency__c='Once';
            oli.Proj_Rpt_Frequency__c='Once [O]';
            oli.List_Price__c= null;
            oli.Billing_Date__c=null;  
            oli.Delivery_Date__c=dateval.addDays(-5);
            oli.Revenue_Type__c='Subscription';
            oli.Product_End_Date__c= dateval.addDays(5);
            oli.Product_Start_Date__c=dateval.addDays(5);
            oli.surcharge_text__c='Test';
            oli.Revised_Revenue_Schedule__c = '20160222:100|20160628:100';  
            oli.Revised_Price__c  = 100;    
            oli.Billing_Date__c  = null; 
            oli.Billing_Frequency__c  = 'Once';
            oli.Proj_Rpt_Frequency__c  = 'Once [O]';
        }
        upsert oliList;
        List<Product2> prodlist = [Select id from Product2 ];
        for(Product2 prod : prodlist) {
            prod.Delivery_Frequency__c = null;
            prod.Delivery_Media__c = 'CPA';
            prod.Offering_Type__c = 'Commercial Tech';
        }
        upsert prodlist;
        PageReference pageRef = new PageReference('Page.MIBNF_ProductController');
        pageRef.getParameters().put('compid', TestMIBNF_Comp.id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.standardController controller = new ApexPages.standardController(new MIBNF_Component__c());
        MIBNF_ProductControllerLockedGrid extension = new MIBNF_ProductControllerLockedGrid(controller);
        
        ApexPages.currentPage().getParameters().put('compid',TestMIBNF_Comp.id);
        extension = new MIBNF_ProductControllerLockedGrid(controller);
        
        
        
        for(Integer i=0;i<extension.opptyLineItem2.size();i++)
        {
            extension.opptyLineItem2[i].Billing_Frequency__c='Once';
            extension.opptyLineItem2[i].Proj_Rpt_Frequency__c='Once [O]';
            extension.opptyLineItem2[i].List_Price__c= 12;
            extension.opptyLineItem2[i].Billing_Date__c= null;  
            extension.opptyLineItem2[i].Delivery_Date__c=dateval.addDays(-5);
            extension.opptyLineItem2[i].Revenue_Type__c='Subscription';
            extension.opptyLineItem2[i].Product_End_Date__c= dateval.addDays(5);
            extension.opptyLineItem2[i].Product_Start_Date__c=dateval.addDays(5);
            extension.opptyLineItem2[i].surcharge_text__c='Test';
            
            extension.opptyLineItem2[i].Revised_Revenue_Schedule__c = '20160222:100|20160628:100';  
            extension.opptyLineItem2[i].Revised_Price__c  = 100;    
            extension.opptyLineItem2[i].Billing_Date__c  = null; 
            extension.opptyLineItem2[i].Billing_Frequency__c  = 'Once';
            extension.opptyLineItem2[i].Proj_Rpt_Frequency__c  = 'Once [O]';  
            extension.opptyLineItem2[i].PO_line_item_number__c = '123';
            
        }
        
        extension.setOpportunityLineItem(extension.opptyLineItem2);
        pageRef = extension.save();
        
        test.stoptest();
    }
    
    public static testMethod void testForisNewBNFcase2() {
        List<OpportunityLineItem> olis = [SELECT Id, TotalPrice FROM OpportunityLineItem];
        Date dateval = date.today();
        MIBNF_Component__c TestMIBNF_Comp = [Select id,name,MIBNF__c, Addendum__c,Is_this_a_retainer_downpayment__c, Print_Shop__c,BNF_Status__c, Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from MIBNF_Component__c][0];
        MIBNF2__c TestMIBNF = [Select id,name,Client__c,Opportunity__c,Sales_Org_Code__c,Billing_Currency__c,IMS_Sales_Org__c,Fair_Value_Type__c,Invoice_Default_Day__c,Contract_Start_Date__c,Contract_End_Date__c,Contract_Type__c,Contract_Term__c,Payment_Terms__c,Revenue_Analyst__c from MIBNF2__c][0];
        
        Test.startTest();
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, olis[0]);
        insert TestMI_BNFLineItem;
        List<Billing_Schedule__c> billingSchedule = UTL_TestData.createBillingSchedules(olis);
        insert billingSchedule;
        List<Billing_Schedule_Item__c> billingScheduleItem = UTL_TestData.createBillingScheduleItems(billingSchedule);
        insert billingScheduleItem;        
        BNF_Settings__c bnfsetting = [Select id, BNF_Opportunity_Threshold__c from  BNF_Settings__c limit 1 ];
        bnfsetting.BNF_Opportunity_Threshold__c = null;
        upsert bnfsetting;
        List<OpportunityLineItem> oliList = [Select id from OpportunityLineItem ];
        for(OpportunityLineItem oli : oliList) {
            oli.Billing_Frequency__c='Once';
            oli.Proj_Rpt_Frequency__c='Once [O]';
            oli.List_Price__c= null;
            oli.Billing_Date__c=null;  
            oli.Delivery_Date__c=dateval.addDays(-5);
            oli.Revenue_Type__c='Subscription';
            oli.Product_End_Date__c= dateval.addDays(5);
            oli.Product_Start_Date__c=dateval.addDays(5);
            oli.surcharge_text__c='Test';
            oli.Revised_Revenue_Schedule__c = '20160222:100|20160628:100';  
            oli.Revised_Price__c  = 100;    
            oli.Billing_Date__c  = null; 
            oli.Billing_Frequency__c  = 'Once';
            oli.Proj_Rpt_Frequency__c  = 'Once [O]';
        }
        upsert oliList;
        List<Product2> prodlist = [Select id from Product2 ];
        for(Product2 prod : prodlist) {
            prod.Delivery_Frequency__c = null;
            prod.Delivery_Media__c = 'CPA';
            prod.Offering_Type__c = 'Commercial Tech';
        }
        upsert prodlist;
        PageReference pageRef = new PageReference('Page.MIBNF_ProductController');
        pageRef.getParameters().put('compid', TestMIBNF_Comp.id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.standardController controller = new ApexPages.standardController(new MIBNF_Component__c());
        MIBNF_ProductControllerLockedGrid extension = new MIBNF_ProductControllerLockedGrid(controller);
        
        ApexPages.currentPage().getParameters().put('compid',TestMIBNF_Comp.id);
        extension = new MIBNF_ProductControllerLockedGrid(controller);
        
        
        
        for(Integer i=0;i<extension.opptyLineItem2.size();i++)
        {
            extension.opptyLineItem2[i].Billing_Frequency__c='Once';
            extension.opptyLineItem2[i].Proj_Rpt_Frequency__c='Once [O]';
            extension.opptyLineItem2[i].List_Price__c= null;
            extension.opptyLineItem2[i].Billing_Date__c= null;  
            extension.opptyLineItem2[i].Delivery_Date__c=dateval.addDays(-5);
            extension.opptyLineItem2[i].Revenue_Type__c='Subscription';
            extension.opptyLineItem2[i].Product_End_Date__c= dateval.addDays(5);
            extension.opptyLineItem2[i].Product_Start_Date__c=dateval.addDays(5);
            extension.opptyLineItem2[i].surcharge_text__c='Test';
            
            extension.opptyLineItem2[i].Revised_Revenue_Schedule__c = '20160222:100|20160628:100';  
            extension.opptyLineItem2[i].Revised_Price__c  = 100;    
            extension.opptyLineItem2[i].Billing_Date__c  = null; 
            extension.opptyLineItem2[i].Billing_Frequency__c  = 'Once';
            extension.opptyLineItem2[i].Proj_Rpt_Frequency__c  = 'Once [O]';  
            extension.opptyLineItem2[i].PO_line_item_number__c = '123';
            
        }
        
        extension.setOpportunityLineItem(extension.opptyLineItem2);
        pageRef = extension.save();
        
        test.stoptest();
    }
    
    public static testMethod void testForisNewBNFcase3() {
        List<OpportunityLineItem> olis = [SELECT Id, TotalPrice FROM OpportunityLineItem];
        Date dateval = date.today();
        MIBNF_Component__c TestMIBNF_Comp = [Select id,name,MIBNF__c, Addendum__c,Is_this_a_retainer_downpayment__c, Print_Shop__c,BNF_Status__c, Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from MIBNF_Component__c][0];
        MIBNF2__c TestMIBNF = [Select id,name,Client__c,Opportunity__c,Sales_Org_Code__c,Billing_Currency__c,IMS_Sales_Org__c,Fair_Value_Type__c,Invoice_Default_Day__c,Contract_Start_Date__c,Contract_End_Date__c,Contract_Type__c,Contract_Term__c,Payment_Terms__c,Revenue_Analyst__c from MIBNF2__c][0];
        
        Test.startTest();
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, olis[0]);
        insert TestMI_BNFLineItem;
        List<Billing_Schedule__c> billingSchedule = UTL_TestData.createBillingSchedules(olis);
        insert billingSchedule;
        List<Billing_Schedule_Item__c> billingScheduleItem = UTL_TestData.createBillingScheduleItems(billingSchedule);
        insert billingScheduleItem;        
        BNF_Settings__c bnfsetting = [Select id, BNF_Opportunity_Threshold__c from  BNF_Settings__c limit 1 ];
        bnfsetting.BNF_Opportunity_Threshold__c = null;
        upsert bnfsetting;
       
        List<OpportunityLineItem> oliList = [Select id from OpportunityLineItem ];
        for(OpportunityLineItem oli : oliList) {
            oli.Billing_Frequency__c='Once';
            oli.Proj_Rpt_Frequency__c='Once [O]';
            oli.List_Price__c= null;
            oli.Billing_Date__c=null;  
            oli.Delivery_Date__c=dateval.addDays(-5);
            oli.Revenue_Type__c='Subscription';
            oli.Product_End_Date__c= dateval.addDays(5);
            oli.Product_Start_Date__c=dateval.addDays(5);
            oli.surcharge_text__c='Test';
            oli.Revised_Revenue_Schedule__c = '20160222:100|20160628:100';  
            oli.Revised_Price__c  = 100;    
            oli.Billing_Date__c  = null; 
            oli.Billing_Frequency__c  = 'Once';
            oli.Proj_Rpt_Frequency__c  = 'Once [O]';
        }
        upsert oliList;
        List<Product2> prodlist = [Select id from Product2 ];
        for(Product2 prod : prodlist) {
            prod.Delivery_Frequency__c = null;
            prod.Delivery_Media__c = 'CPA';
            prod.Offering_Type__c = 'Commercial Tech';
            prod.Material_Type__c = 'ZPUB';
            prod.Item_Category_Group__c = 'ZLIC';
            prod.Delivery_Frequency__c = 'delivery_frequency';
        }
        upsert prodlist;
        PageReference pageRef = new PageReference('Page.MIBNF_ProductController');
        pageRef.getParameters().put('compid', TestMIBNF_Comp.id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.standardController controller = new ApexPages.standardController(new MIBNF_Component__c());
        MIBNF_ProductControllerLockedGrid extension = new MIBNF_ProductControllerLockedGrid(controller);
        
        ApexPages.currentPage().getParameters().put('compid',TestMIBNF_Comp.id);
        extension = new MIBNF_ProductControllerLockedGrid(controller);
                
        
        for(Integer i=0;i<extension.opptyLineItem2.size();i++)
        {
            System.debug(extension.opptyLineItem2[i].PricebookEntry.Product2.Material_Type__c);
            if(extension.opptyLineItem2[i].PricebookEntry.Product2.Material_Type__c != 'ZREP'){
                extension.opptyLineItem2[i].Billing_Frequency__c='Once';
                extension.opptyLineItem2[i].Proj_Rpt_Frequency__c='Once [O]';
                extension.opptyLineItem2[i].List_Price__c= null;
                extension.opptyLineItem2[i].Billing_Date__c= null;  
                extension.opptyLineItem2[i].Delivery_Date__c=dateval.addDays(-5);
                extension.opptyLineItem2[i].Revenue_Type__c='Subscription';
                extension.opptyLineItem2[i].Product_End_Date__c= dateval.addDays(5);
                extension.opptyLineItem2[i].Product_Start_Date__c=dateval.addDays(5);
                extension.opptyLineItem2[i].surcharge_text__c='Test';
                
                extension.opptyLineItem2[i].Revised_Revenue_Schedule__c = '20160222:100|20160628:100';  
                extension.opptyLineItem2[i].Revised_Price__c  = 100;    
                extension.opptyLineItem2[i].Billing_Date__c  = null; 
                extension.opptyLineItem2[i].Billing_Frequency__c  = 'Once';
                extension.opptyLineItem2[i].Proj_Rpt_Frequency__c  = 'Once [O]';  
                extension.opptyLineItem2[i].PO_line_item_number__c = '123';
            } 
        }
        
        extension.setOpportunityLineItem(extension.opptyLineItem2);
        pageRef = extension.save();
        
        test.stoptest();
    }
    
    
    public static testMethod void testForisNewBNFcase4() {
        List<OpportunityLineItem> olis = [SELECT Id, TotalPrice FROM OpportunityLineItem];
        Date dateval = date.today();
        MIBNF_Component__c TestMIBNF_Comp = [Select id,name,MIBNF__c, Addendum__c,Is_this_a_retainer_downpayment__c, Print_Shop__c,BNF_Status__c, Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from MIBNF_Component__c][0];
        MIBNF2__c TestMIBNF = [Select id,name,Client__c,Opportunity__c,Sales_Org_Code__c,Billing_Currency__c,IMS_Sales_Org__c,Fair_Value_Type__c,Invoice_Default_Day__c,Contract_Start_Date__c,Contract_End_Date__c,Contract_Type__c,Contract_Term__c,Payment_Terms__c,Revenue_Analyst__c from MIBNF2__c][0];
        
        Test.startTest();
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, olis[0]);
        insert TestMI_BNFLineItem;
        List<Billing_Schedule__c> billingSchedule = UTL_TestData.createBillingSchedules(olis);
        insert billingSchedule;
        List<Billing_Schedule_Item__c> billingScheduleItem = UTL_TestData.createBillingScheduleItems(billingSchedule);
        insert billingScheduleItem;        
        BNF_Settings__c bnfsetting = [Select id, BNF_Opportunity_Threshold__c from  BNF_Settings__c limit 1 ];
        bnfsetting.BNF_Opportunity_Threshold__c = null;
        upsert bnfsetting;
       
        List<OpportunityLineItem> oliList = [Select id from OpportunityLineItem ];
        for(OpportunityLineItem oli : oliList) {
            oli.Billing_Frequency__c='Once';
            oli.Proj_Rpt_Frequency__c='Once [O]';
            oli.List_Price__c= null;
            oli.Billing_Date__c=null;  
            oli.Delivery_Date__c=dateval.addDays(-5);
            oli.Revenue_Type__c='Subscription';
            oli.Product_End_Date__c= dateval.addDays(5);
            oli.Product_Start_Date__c=dateval.addDays(5);
            oli.surcharge_text__c='Test';
            oli.Revised_Revenue_Schedule__c = '20160222:100|20160628:100';  
            oli.Revised_Price__c  = 100;    
            oli.Billing_Date__c  = null; 
            oli.Billing_Frequency__c  = 'Once';
            oli.Proj_Rpt_Frequency__c  = 'Once [O]';
        }
        upsert oliList;
        List<Product2> prodlist = [Select id from Product2 ];
        for(Product2 prod : prodlist) {
            prod.Delivery_Frequency__c = null;
            prod.Delivery_Media__c = 'CPA';
            prod.Offering_Type__c = 'Commercial Tech';
            prod.Material_Type__c = 'ZREP';
            prod.Therapy_Class__c = 'therapy_class_1';
        }
        upsert prodlist;
        PageReference pageRef = new PageReference('Page.MIBNF_ProductController');
        pageRef.getParameters().put('compid', TestMIBNF_Comp.id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.standardController controller = new ApexPages.standardController(new MIBNF_Component__c());
        MIBNF_ProductControllerLockedGrid extension = new MIBNF_ProductControllerLockedGrid(controller);
        
        ApexPages.currentPage().getParameters().put('compid',TestMIBNF_Comp.id);
        extension = new MIBNF_ProductControllerLockedGrid(controller);
                
        
        for(Integer i=0;i<extension.opptyLineItem2.size();i++)
        {
            System.debug(extension.opptyLineItem2[i].PricebookEntry.Product2.Material_Type__c);
            if(extension.opptyLineItem2[i].PricebookEntry.Product2.Material_Type__c != 'ZREP'){
                extension.opptyLineItem2[i].Billing_Frequency__c='Once';
                extension.opptyLineItem2[i].Proj_Rpt_Frequency__c='Once [O]';
                extension.opptyLineItem2[i].List_Price__c= null;
                extension.opptyLineItem2[i].Billing_Date__c= null;  
                extension.opptyLineItem2[i].Delivery_Date__c=dateval.addDays(-5);
                extension.opptyLineItem2[i].Revenue_Type__c='Subscription';
                extension.opptyLineItem2[i].Product_End_Date__c= dateval.addDays(5);
                extension.opptyLineItem2[i].Product_Start_Date__c=dateval.addDays(5);
                extension.opptyLineItem2[i].surcharge_text__c='Test';
                
                extension.opptyLineItem2[i].Revised_Revenue_Schedule__c = '20160222:100|20160628:100';  
                extension.opptyLineItem2[i].Revised_Price__c  = 100;    
                extension.opptyLineItem2[i].Billing_Date__c  = null; 
                extension.opptyLineItem2[i].Billing_Frequency__c  = 'Once';
                extension.opptyLineItem2[i].Proj_Rpt_Frequency__c  = 'Once [O]';  
                extension.opptyLineItem2[i].PO_line_item_number__c = '123';
            } 
        }
        
        extension.setOpportunityLineItem(extension.opptyLineItem2);
        pageRef = extension.save();
        
        test.stoptest();
    }
}