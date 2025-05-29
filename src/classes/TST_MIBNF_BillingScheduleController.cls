@isTest
private class TST_MIBNF_BillingScheduleController { 
    
    static MIBNF_BillingScheduleController classObj;
    //static BNF2__c bnf ; 
    static List<opportunity> test_oppList;
    static Integer PROD_SIZE = 5;
    static List<OpportunityLineItem> oliList;
    private static final String ERR_BILLINGPLAN_MISSING =  'Please select billing plan pattern.';
    private static final String ERR_NEGATIVE_AMOUNT     ='Error:BIllingAmount can not be negative  ';
    private static final String ERR_ZEROAMOUNT          = 'Error:bIlling Amount can not zero  ';
    private static final String ERR_BILLINGDATE         = 'Error: Billing Date of same opportunity Line item can not same ';                 
    private static final String ERR_COMPLEVEL_NEGATIVE_AMOUNT = 'Error: Amount can not be negative  ';
    private static final String ERR_COMPLEVEL_ZEROAMOUNT      = 'Error: Amount can not be zero';
    private static final String ERR_TOTALAMOUNT         = 'Error while saving schedules: Total amount of Billing schedule Amount  can not more than Opportunity Total amount' ; 
    
    @testSetup static void setupTestData(){
        UTL_ExecutionControl.stopTriggerExecution = true;
        Global_Variables.PCFlag = false;
        Global_Variables.RunQuickOppLimitTrigger = false;
        Global_Variables.RenewalCloneFlag = true;
        Global_Variables.syncAgreementToOppty=false;
        Global_Variables.PCTrigger_Hault_Execution=false;
        //OpportunityTriggerUtil.RunBeforeTrigger = false;
        //OpportunityTriggerUtil.RunAfterTrigger = false;
        Global_Variables.isupdatableOppPlan = false;
        Global_Variables.isclonningOpportunity = true;
        Current_Release_Version__c currReleaseVersion = new Current_Release_Version__c();
        currReleaseVersion.Current_Release__c = '2019.02';
        insert currReleaseVersion;        
        Account TestAccount = BNF_Test_Data.createAccount();
        List<Address__c> TestAddress_Array = BNF_Test_Data.createAddress_Array();
        List<SAP_Contact__c> TestSapContact_Array = BNF_Test_Data.createSapContact_Array();
        BNF_Settings__c bnfsetting = BNF_Test_Data.createBNFSetting();
        UTL_ExecutionControl.stopTriggerExecution = false;
        Opportunity opp = BNF_Test_Data.createOpp();
        UTL_ExecutionControl.stopTriggerExecution = true;
        List<OpportunityLineItem> OLI_Array = BNF_Test_Data.createOppLineItem();
    }
    
    //**************** to initialize Object of class ================
    static void resetmethod(){ 
        List<MIBNF_Component__c> bnfList = [Select id,name,MIBNF__c, Addendum__c,Is_this_a_retainer_downpayment__c, Print_Shop__c,BNF_Status__c, Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from MIBNF_Component__c];
        MIBNF2__c TestMIBNF = [Select id,name,Client__c,Opportunity__c,Sales_Org_Code__c,Billing_Currency__c,IMS_Sales_Org__c,Fair_Value_Type__c,Invoice_Default_Day__c,Contract_Start_Date__c,Contract_End_Date__c,Contract_Type__c,Contract_Term__c,Payment_Terms__c,Revenue_Analyst__c from MIBNF2__c][0];
        Opportunity TestOpp = [Select id,Name,StageName,CloseDate,Budget_Available__c, AccountId,Contract_Term__c,Contract_End_Date__c,Contract_Start_Date__c,Contract_Type__c,LeadSource,CurrencyIsoCode from Opportunity][0];
        
        Id bnfid = bnfList[0].Id;
        PageReference pageRef = new PageReference('Page.MIBNF_AddBillingSchedule');
        //pageRef.getParameters().put('mibnfid',bnfid);
        pageRef.getParameters().put('salesOrg',TestMIBNF.Sales_Org_Code__c);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdController = new ApexPages.standardController(bnfList[0]); 
        classObj = new MIBNF_BillingScheduleController(stdController);     
        MIBNF_BillingScheduleController.getBillingPatterns();
        MIBNF_BillingScheduleController.getBillingLevels();
        
    }
    
    //************to Test calculateSchedules method
    static testMethod void calculateSchedules_testingMethod() {
        Opportunity opp = [Select id,Name,StageName,CloseDate,Budget_Available__c, AccountId,Contract_Term__c,Contract_End_Date__c,Contract_Start_Date__c,Contract_Type__c,LeadSource,CurrencyIsoCode from Opportunity][0];
        List<OpportunityLineitem> oliList1 = [Select   Opportunity.CEQActiveRelease__c,Discount_Percentage_Formula__c, PricebookEntry.Name,
                                              PricebookEntry.Product2.Material_Type__c,PricebookEntry.Product2.Offering_Group__c ,Opportunity.Therapy_Area__c,  
                                              PricebookEntry.Product2.Offering_Type__c , List_Price__c, Nbr_of_Users__c, Book_No__c,Other_Ship_To_SAP_Contact__c,
                                              CurrencyISOCode,TotalPrice,Delivery_Media__c, Product_Invoice_Text__c, PricebookEntry.ProductCode,PricebookEntry.Product2.Delivery_Media__c,
                                              PricebookEntry.Product2.Delivery_Frequency__c,Other_Ship_To_Address__c,Surcharge_Text__c,
                                              Billing_Frequency__c,Product_Start_Date__c,Product_End_Date__c, Proj_Rpt_Frequency__c,Discount_Reason__c, 
                                              Discount_Amount_Formula__c, Other_Ship_To__c, Billing_Date__c, Sale_Type__c, Revenue_Type__c,PricebookEntry.Product2.Item_Category_Group__c,  
                                              Invoice_Lag_to_Data_Period__c, Revised_Price__c,Therapy_Area__c, Cancel__c,Business_Type__c, Delivery_Date__c,PO_Number__c,
                                              Sales_Text__c,Budget_Therapy_Area__c,Project_Start_Date__c,Project_End_Date__c, 
                                              OpportunityId,Billing_Schedule_Error_Msg__c,Revised_Revenue_Schedule__c,Revenue_Schedule_Error_Msg__c From OpportunityLineItem where OpportunityId = :opp.id ];
        
        List<Address__c> TestAddress_Array = [Select id,Name,Enabled_Sales_Orgs__c,Account__c,Street__c,City__c,Country__c,SAP_Reference__c from Address__c];
        Revenue_Analyst__c TestLocalRA = UTL_TestData.createRevenueAnalyst();
        insert TestLocalRA;
        MIBNF2__c TestMIBNF = UTL_TestData.createMIBNF(opp, TestLocalRA);
        insert TestMIBNF;
        
        Test.startTest();
        MIBNF_Component__c bnf = UTL_TestData.createMIBNF_Comp(TestMIBNF, TestAddress_Array);
        insert bnf;
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(bnf.Id, oliList1[0]);
        insert TestMI_BNFLineItem;
        List<Billing_Schedule__c> billingSchedule = UTL_TestData.createBillingSchedules(oliList1);
        insert billingSchedule;
        List<Billing_Schedule_Item__c> billingScheduleItem = UTL_TestData.createBillingScheduleItems(billingSchedule);
        insert billingScheduleItem;
        
        resetmethod();
        //*************** Calling calculation method****************************
        
        classObj.billingLevel = 'Component Level';
        classObj.billingPattern= '50/50';
        classObj.calculateSchedules();          
        
        decimal sumoftotalPrice =0;
        
        for(OpportunityLineItem oli : oliList1){             
            sumoftotalPrice  += oli.totalPrice;
        }
        
        classObj.billingLevel = 'Component Level';
        classObj.billingPattern= '60/40';
        classObj.calculateSchedules();                        
        
        classObj.billingLevel = 'Component Level';
        classObj.billingPattern= '100% on signature';
        classObj.calculateSchedules();           
        
        classObj.billingLevel = 'Component Level';
        classObj.billingPattern= '100% on delivery';
        classObj.calculateSchedules();          
        
        classObj.billingLevel = 'Component Level';
        classObj.billingPattern= 'MONTHLY';
        classObj.calculateSchedules();    
        Integer monthsBetween = TestMIBNF.Contract_Start_Date__c.monthsBetween(TestMIBNF.Contract_End_Date__c);    
        if(monthsBetween < 0) 
            monthsBetween *= (-1);  
        
        classObj.billingLevel = 'Component Level';
        classObj.billingPattern= 'QUARTERLY';
        classObj.calculateSchedules();  
        monthsBetween = TestMIBNF.Contract_Start_Date__c.monthsBetween(TestMIBNF.Contract_End_Date__c);        
        Decimal quartesBetweenDecimal = monthsBetween/3.00;            
        Integer quartesBetween = monthsBetween/3;
        quartesBetween = (quartesBetweenDecimal > quartesBetween)? (quartesBetween + 1) : quartesBetween ;
        if(quartesBetween < 0) 
            quartesBetween *= (-1);            
        if(quartesBetween == 0) 
            quartesBetween  = 1;
        
        Test.stopTest(); 
        
    }
    
    //************to Test Reset method
    static testMethod void Reset_tesingMethod() {
        
        Opportunity opp =[SELECT Id,AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];
        List<OpportunityLineItem> olis =[SELECT Id,TotalPrice FROM OpportunityLineItem];
        
        List<Address__c> TestAddress_Array = [Select id,Name,Enabled_Sales_Orgs__c,Account__c,Street__c,City__c,Country__c,SAP_Reference__c from Address__c];
        Revenue_Analyst__c TestLocalRA = UTL_TestData.createRevenueAnalyst();
        insert TestLocalRA;
        MIBNF2__c TestMIBNF = UTL_TestData.createMIBNF(opp, TestLocalRA);
        insert TestMIBNF;
        
        Test.startTest();
        MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF, TestAddress_Array);
        insert TestMIBNF_Comp;
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, olis[0]);
        insert TestMI_BNFLineItem;
        List<Billing_Schedule__c> billingSchedule = UTL_TestData.createBillingSchedules(olis);
        insert billingSchedule;
        List<Billing_Schedule_Item__c> billingScheduleItem = UTL_TestData.createBillingScheduleItems(billingSchedule);
        insert billingScheduleItem;
        
        resetmethod();
        PageReference page = classObj.crudeReset();           
        Test.stopTest(); 
    }
    
    //************to Test delete method
    static testmethod void delete_schedule_tesingMethod(){
        
        //********deletion for Opportunity Level
        Opportunity opp = [Select id,Name,StageName,CloseDate,Budget_Available__c, AccountId,Contract_Term__c,Contract_End_Date__c,Contract_Start_Date__c,Contract_Type__c,LeadSource,CurrencyIsoCode from Opportunity][0];           
        List<OpportunityLineitem> oliList1 = [Select   Opportunity.CEQActiveRelease__c,Discount_Percentage_Formula__c, PricebookEntry.Name,
                                              PricebookEntry.Product2.Material_Type__c,PricebookEntry.Product2.Offering_Group__c ,Opportunity.Therapy_Area__c,  
                                              PricebookEntry.Product2.Offering_Type__c , List_Price__c, Nbr_of_Users__c, Book_No__c,Other_Ship_To_SAP_Contact__c,
                                              CurrencyISOCode,TotalPrice,Delivery_Media__c, Product_Invoice_Text__c, PricebookEntry.ProductCode,PricebookEntry.Product2.Delivery_Media__c,
                                              PricebookEntry.Product2.Delivery_Frequency__c,Other_Ship_To_Address__c,Surcharge_Text__c,
                                              Billing_Frequency__c,Product_Start_Date__c,Product_End_Date__c, Proj_Rpt_Frequency__c,Discount_Reason__c, 
                                              Discount_Amount_Formula__c, Other_Ship_To__c, Billing_Date__c, Sale_Type__c, Revenue_Type__c,PricebookEntry.Product2.Item_Category_Group__c,  
                                              Invoice_Lag_to_Data_Period__c, Revised_Price__c,Therapy_Area__c, Cancel__c,Business_Type__c, Delivery_Date__c,PO_Number__c,
                                              Sales_Text__c,Budget_Therapy_Area__c,Project_Start_Date__c,Project_End_Date__c, 
                                              OpportunityId,Billing_Schedule_Error_Msg__c,Revised_Revenue_Schedule__c,Revenue_Schedule_Error_Msg__c From OpportunityLineItem where OpportunityId = :opp.id ];
        List<Address__c> TestAddress_Array = [Select id,Name,Enabled_Sales_Orgs__c,Account__c,Street__c,City__c,Country__c,SAP_Reference__c from Address__c];
        Revenue_Analyst__c TestLocalRA = UTL_TestData.createRevenueAnalyst();
        insert TestLocalRA;
        MIBNF2__c TestMIBNF = UTL_TestData.createMIBNF(opp, TestLocalRA);
        insert TestMIBNF;
        
        Test.startTest();
        MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF, TestAddress_Array);
        insert TestMIBNF_Comp;
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, oliList1[0]);
        insert TestMI_BNFLineItem;
        List<Billing_Schedule__c> billingSchedule = UTL_TestData.createBillingSchedules(oliList1);
        insert billingSchedule;
        List<Billing_Schedule_Item__c> billingScheduleItem = UTL_TestData.createBillingScheduleItems(billingSchedule);
        insert billingScheduleItem;
        resetmethod();
        
        classObj.billingLevel = 'Opportunity Level';
        classObj.billingPattern= '100% on delivery';   
        
        classObj.calculateSchedules();
        
        integer Opplevelschduels_before_deleteschedule = classObj.oppLvlSchWrapper.size();
        
        // testing for deleting
        if(classObj.oppLvlSchWrapper.size()>0){
            classobj.selectedOpLevel = 1;
            classobj.deleteScheduleOppLevel();
        }
        
        // ******** deletion for component Level 
        classObj.billingLevel = 'Opportunity Level';
        classObj.billingPattern= '50/50';
        classObj.calculateSchedules();           
        Id oliIdtodelete;
        //system.assert(false, 'oliList = ' + oliList1);
        for( OpportunityLineItem oli :  oliList1){
            oliIdtodelete = oli.Id;
            break;
        }
        classObj.selectedOLIId = oliIdtodelete;
        classObj.selectedIdx = 1;          
        classObj.saveOppLevelSchedules();           
        integer complevel_deletedSchedules_size_before_delete = classObj.deletedSchedules.size();
        
        classObj.selectedOLIId = oliList1[0].id;
        classObj.deleteSchedule();    
        Test.stopTest();      
        
    }
    
    //************to Test addOppLevelSchedule method
    static testMethod void addOppLevelSchedule_testingMethod(){
        //**********Adding billing Schedule for Oppolevel 
        
        
        Opportunity opp =[SELECT Id,AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];
        List<OpportunityLineItem> olis =[SELECT Id,TotalPrice FROM OpportunityLineItem];
        
        List<Address__c> TestAddress_Array = [Select id,Name,Enabled_Sales_Orgs__c,Account__c,Street__c,City__c,Country__c,SAP_Reference__c from Address__c];
        Revenue_Analyst__c TestLocalRA = UTL_TestData.createRevenueAnalyst();
        insert TestLocalRA;
        MIBNF2__c TestMIBNF = UTL_TestData.createMIBNF(opp, TestLocalRA);
        insert TestMIBNF;
        
        Test.startTest();
        MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF, TestAddress_Array);
        insert TestMIBNF_Comp;
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, olis[0]);
        insert TestMI_BNFLineItem;
        List<Billing_Schedule__c> billingSchedule = UTL_TestData.createBillingSchedules(olis);
        insert billingSchedule;
        List<Billing_Schedule_Item__c> billingScheduleItem = UTL_TestData.createBillingScheduleItems(billingSchedule);
        insert billingScheduleItem;
        resetmethod();
        classObj.billingLevel = 'Opportunity Level';
        classObj.billingPattern= '100% on signature';
        classObj.calculateSchedules();
        
        Integer Opplevelschduels_before_addschedule = classObj.oppLvlSchWrapper.size();
        classObj.addOppLevelSchedule();   
        
        Opplevelschduels_before_addschedule = classObj.oppLvlSchWrapper.size();
        classObj.addOppLevelSchedule();
        
        classObj.oliWrapperList [0].addBilingSchedule();
        Test.stopTest();       
    }
    //************to Test Apex error message 
    static testmethod void errormessage_testingmethod(){        
        
        
        Opportunity opp =[SELECT Id,AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];
        List<OpportunityLineItem> olis =[SELECT Id,TotalPrice FROM OpportunityLineItem];
        
        List<Address__c> TestAddress_Array = [Select id,Name,Enabled_Sales_Orgs__c,Account__c,Street__c,City__c,Country__c,SAP_Reference__c from Address__c];
        Revenue_Analyst__c TestLocalRA = UTL_TestData.createRevenueAnalyst();
        insert TestLocalRA;
        MIBNF2__c TestMIBNF = UTL_TestData.createMIBNF(opp, TestLocalRA);
        insert TestMIBNF;
        
        Test.startTest();
        MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF, TestAddress_Array);
        insert TestMIBNF_Comp;
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, olis[0]);
        insert TestMI_BNFLineItem;
        List<Billing_Schedule__c> billingSchedule = UTL_TestData.createBillingSchedules(olis);
        insert billingSchedule;
        List<Billing_Schedule_Item__c> billingScheduleItem = UTL_TestData.createBillingScheduleItems(billingSchedule);
        insert billingScheduleItem;
        resetmethod();
        classObj.billingLevel = 'Opportunity Level';
        classObj.billingPattern= '-';
        classObj.calculateSchedules();
        ApexPages.Message mssgs = ApexPages.getMessages()[0];
        boolean errorfound = false;       
        if(mssgs.getDetail().contains(ERR_BILLINGPLAN_MISSING))
            errorFound=true;     
        
        //***** for Zero Amount *********
        resetmethod();
        classObj.billingLevel = 'Opportunity Level';
        classObj.billingPattern= '100% on signature'; 
        
        classObj.calculateSchedules();              
        classObj.oppLvlSchWrapper[0].scheduleItem.Billing_Amount__c = 0;
        classObj.saveOppLevelSchedules();
        
        errorfound = false;       
        List<ApexPages.Message> mssgs1 = ApexPages.getMessages();
        for(ApexPages.Message m : mssgs1 ){        
            if(m.getDetail().contains(ERR_ZEROAMOUNT))
                errorFound=true;                 
        }
        
        //****** for Negative Amount************
        
        classObj.billingLevel = 'Opportunity Level';
        classObj.billingPattern= '100% on signature'; 
        
        classObj.calculateSchedules();              
        classObj.oppLvlSchWrapper[0].scheduleItem.Billing_Amount__c = -10000;
        classObj.saveOppLevelSchedules();
        
        errorfound = false;       
        List<ApexPages.Message> mssgs2  = ApexPages.getMessages();
        for(ApexPages.Message m : mssgs2 ){         
            if(m.getDetail().contains(ERR_NEGATIVE_AMOUNT))
                errorFound=true;                 
        }
        Test.stopTest();
    }
    
    static testmethod void Date_and_other_validation_tesingMethod1(){
        Opportunity opp =[SELECT Id,AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];
        List<OpportunityLineItem> olis =[SELECT Id,TotalPrice FROM OpportunityLineItem];
        
        List<Address__c> TestAddress_Array = [Select id,Name,Enabled_Sales_Orgs__c,Account__c,Street__c,City__c,Country__c,SAP_Reference__c from Address__c];
        Revenue_Analyst__c TestLocalRA = UTL_TestData.createRevenueAnalyst();
        insert TestLocalRA;
        MIBNF2__c TestMIBNF = UTL_TestData.createMIBNF(opp, TestLocalRA);
        insert TestMIBNF;
        
        Test.startTest();
        MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF, TestAddress_Array);
        insert TestMIBNF_Comp;
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, olis[0]);
        insert TestMI_BNFLineItem;
        List<Billing_Schedule__c> billingSchedule = UTL_TestData.createBillingSchedules(olis);
        insert billingSchedule;
        List<Billing_Schedule_Item__c> billingScheduleItem = UTL_TestData.createBillingScheduleItems(billingSchedule);
        insert billingScheduleItem;
        resetmethod();
        classObj.billingLevel = 'Opportunity Level';
        classObj.billingPattern= '50/50';            
        classObj.calculateSchedules();        
        classObj.oliWrapperList[0].schedules[0].scheduleItem.Billing_Amount__c = 0;
        classObj.saveSchedules();
        boolean errorfound = false;       
        List<ApexPages.Message> mssgs  = ApexPages.getMessages();
        for(ApexPages.Message m : mssgs ){         
            if(m.getDetail().contains(ERR_COMPLEVEL_ZEROAMOUNT))
                errorFound=true;                 
        }  
        
        Test.stopTest();
    }
    
    static testmethod void Date_and_other_validation_tesingMethod2(){
        //********** testing for Billing amount negative
        Opportunity opp =[SELECT Id,AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];
        List<OpportunityLineItem> olis =[SELECT Id,TotalPrice FROM OpportunityLineItem];
        
        List<Address__c> TestAddress_Array = [Select id,Name,Enabled_Sales_Orgs__c,Account__c,Street__c,City__c,Country__c,SAP_Reference__c from Address__c];
        Revenue_Analyst__c TestLocalRA = UTL_TestData.createRevenueAnalyst();
        insert TestLocalRA;
        MIBNF2__c TestMIBNF = UTL_TestData.createMIBNF(opp, TestLocalRA);
        insert TestMIBNF;
        
        Test.startTest();
        MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF, TestAddress_Array);
        insert TestMIBNF_Comp;
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, olis[0]);
        insert TestMI_BNFLineItem;
        List<Billing_Schedule__c> billingSchedule = UTL_TestData.createBillingSchedules(olis);
        insert billingSchedule;
        List<Billing_Schedule_Item__c> billingScheduleItem = UTL_TestData.createBillingScheduleItems(billingSchedule);
        insert billingScheduleItem;
        
        resetmethod();
        classObj.billingLevel = 'Opportunity Level';
        classObj.billingPattern= '50/50';            
        classObj.calculateSchedules(); 
        classObj.oliWrapperList[0].schedules[0].scheduleItem.Billing_Amount__c = -500;
        classObj.saveSchedules();
        
        classObj.SaveOppLvlScheduleListNClose();
        boolean errorfound = false;       
        List<ApexPages.Message> mssgs1 = ApexPages.getMessages();
        for(ApexPages.Message m : mssgs1 ){        
            if(m.getDetail().contains(ERR_COMPLEVEL_NEGATIVE_AMOUNT)) 
                errorFound=true;                 
        }   
        
        //********* testing Amount greater than Billing amount  for component Level   
        classObj.billingLevel = 'Component Level';
        classObj.billingPattern= '50/50';            
        classObj.calculateSchedules();        
        classObj.oliWrapperList[0].schedules[0].scheduleItem.Billing_Amount__c = classobj.zrepamount+10;          
        
        classObj.saveSchedules();
        classObj.SaveScheduleListNClose();
        errorfound = false;       
        List<ApexPages.Message> mssgs2 = ApexPages.getMessages();         
        for(ApexPages.Message m : mssgs2 ){                   
            if(m.getDetail().contains('Error while saving schedules: '+'Total scheduled amount '))
                errorFound=true;                 
        }
        Test.stopTest();
        
    }
    
    static testmethod void updateBillingScheduleTest(){
        //********** testing for Billing amount negative
        Opportunity opp =[SELECT Id,AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];
        List<OpportunityLineItem> olis =[SELECT Id,TotalPrice FROM OpportunityLineItem];
        
        List<Address__c> TestAddress_Array = [Select id,Name,Enabled_Sales_Orgs__c,Account__c,Street__c,City__c,Country__c,SAP_Reference__c from Address__c];
        Revenue_Analyst__c TestLocalRA = UTL_TestData.createRevenueAnalyst();
        insert TestLocalRA;
        MIBNF2__c TestMIBNF = UTL_TestData.createMIBNF(opp, TestLocalRA);
        insert TestMIBNF;
        MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF, TestAddress_Array);
        insert TestMIBNF_Comp;
        Test.startTest();
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, olis[0]);
        insert TestMI_BNFLineItem;
        List<Billing_Schedule__c> billingSchedule = UTL_TestData.createBillingSchedules(olis);
        insert billingSchedule;
        List<Billing_Schedule_Item__c> billingScheduleItem = UTL_TestData.createBillingScheduleItems(billingSchedule);
        insert billingScheduleItem;
        
        resetmethod();
        classObj.billingLevel = 'Opportunity Level';
        classObj.billingPattern= '50/50';            
        classObj.calculateSchedules(); 
        classObj.oliWrapperList[0].schedules[0].scheduleItem.Billing_Amount__c = null	;
        //classObj.oliWrapperList[0].schedules[0].scheduleItem.Billing_Date__c = System.today()	;
        classObj.SaveScheduleListNClose();
        Test.stopTest();
    }
    
    static testmethod void updateBillingScheduleTest1(){
        //********** testing for Billing amount negative
        Opportunity opp =[SELECT Id,AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];
        List<OpportunityLineItem> olis =[SELECT Id,TotalPrice FROM OpportunityLineItem];
        
        List<Address__c> TestAddress_Array = [Select id,Name,Enabled_Sales_Orgs__c,Account__c,Street__c,City__c,Country__c,SAP_Reference__c from Address__c];
        Revenue_Analyst__c TestLocalRA = UTL_TestData.createRevenueAnalyst();
        insert TestLocalRA;
        MIBNF2__c TestMIBNF = UTL_TestData.createMIBNF(opp, TestLocalRA);
        insert TestMIBNF;
        MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF, TestAddress_Array);
        insert TestMIBNF_Comp;
        
        Test.startTest();
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, olis[0]);
        insert TestMI_BNFLineItem;
        List<Billing_Schedule__c> billingSchedule = UTL_TestData.createBillingSchedules(olis);
        insert billingSchedule;
        List<Billing_Schedule_Item__c> billingScheduleItem = UTL_TestData.createBillingScheduleItems(billingSchedule);
        insert billingScheduleItem;
        resetmethod();
        classObj.billingLevel = 'Component Level';
        classObj.billingPattern= '50/50';            
        classObj.calculateSchedules(); 
        classObj.oliWrapperList[0].schedules[0].scheduleItem.Billing_Date__c = null	;
        //classObj.oliWrapperList[0].schedules[0].scheduleItem.Billing_Date__c = System.today()	;
        classObj.SaveScheduleListNClose();
        Test.stopTest();
        
    }
    
    static testmethod void updateBillingScheduleTest2(){
        //********** testing for Billing amount negative
        Opportunity opp =[SELECT Id,AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];
        List<OpportunityLineItem> olis =[SELECT Id,TotalPrice FROM OpportunityLineItem];
        
        List<Address__c> TestAddress_Array = [Select id,Name,Enabled_Sales_Orgs__c,Account__c,Street__c,City__c,Country__c,SAP_Reference__c from Address__c];
        Revenue_Analyst__c TestLocalRA = UTL_TestData.createRevenueAnalyst();
        insert TestLocalRA;
        MIBNF2__c TestMIBNF = UTL_TestData.createMIBNF(opp, TestLocalRA);
        insert TestMIBNF;
        
        Test.startTest();
        MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF, TestAddress_Array);
        insert TestMIBNF_Comp;
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, olis[0]);
        insert TestMI_BNFLineItem;
        List<Billing_Schedule__c> billingSchedule = UTL_TestData.createBillingSchedules(olis);
        insert billingSchedule;
        List<Billing_Schedule_Item__c> billingScheduleItem = UTL_TestData.createBillingScheduleItems(billingSchedule);
        insert billingScheduleItem;
        resetmethod();
        classObj.billingLevel = 'Opportunity Level';
        classObj.billingPattern= '50/50';            
        classObj.calculateSchedules(); 
        classObj.oliWrapperList[0].schedules[0].scheduleItem.Billing_Date__c = null	;
        classObj.oliWrapperList[0].schedules[0].scheduleItem.Billing_Amount__c = null	;
        //classObj.oliWrapperList[0].schedules[0].scheduleItem.Billing_Date__c = System.today()	;
        classObj.SaveScheduleListNClose();
        Test.stopTest();
    }
    
    static testmethod void Date_and_other_validation_tesingMethod3(){
        Opportunity opp =[SELECT Id,AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];
        List<OpportunityLineItem> olis =[SELECT Id,TotalPrice FROM OpportunityLineItem];
        
        List<Address__c> TestAddress_Array = [Select id,Name,Enabled_Sales_Orgs__c,Account__c,Street__c,City__c,Country__c,SAP_Reference__c from Address__c];
        Revenue_Analyst__c TestLocalRA = UTL_TestData.createRevenueAnalyst();
        insert TestLocalRA;
        MIBNF2__c TestMIBNF = UTL_TestData.createMIBNF(opp, TestLocalRA);
        insert TestMIBNF;
        
        Test.startTest();
        MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF, TestAddress_Array);
        insert TestMIBNF_Comp;
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, olis[0]);
        insert TestMI_BNFLineItem;
        List<Billing_Schedule__c> billingSchedule = UTL_TestData.createBillingSchedules(olis);
        insert billingSchedule;
        List<Billing_Schedule_Item__c> billingScheduleItem = UTL_TestData.createBillingScheduleItems(billingSchedule);
        insert billingScheduleItem;
        
        //***************Date Validation*********************
        
        resetmethod();
        classObj.billingLevel = 'Opportunity Level';
        classObj.billingPattern= '50/50';   
        classObj.calculateSchedules();
        classObj.oliWrapperList[0].schedules[0].scheduleItem.Billing_Date__c = system.today();
        classObj.oliWrapperList[0].schedules[1].scheduleItem.Billing_Date__c = system.today(); 
        classObj.saveSchedules();
        
        classObj.Cancel();
        boolean errorfound = false;       
        
        List<ApexPages.Message> mssgs3 = ApexPages.getMessages();
        for(ApexPages.Message m : mssgs3 ){        
            if(m.getDetail().contains(ERR_BILLINGDATE ))
                errorFound=true;                 
        }
        Test.stopTest();
    }
    
    static testmethod void getExport_TestMethod(){
        Opportunity opp =[SELECT Id,AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];
        List<OpportunityLineItem> olis =[SELECT Id,TotalPrice FROM OpportunityLineItem];
        
        List<Address__c> TestAddress_Array = [Select id,Name,Enabled_Sales_Orgs__c,Account__c,Street__c,City__c,Country__c,SAP_Reference__c from Address__c];
        Revenue_Analyst__c TestLocalRA = UTL_TestData.createRevenueAnalyst();
        insert TestLocalRA;
        MIBNF2__c TestMIBNF = UTL_TestData.createMIBNF(opp, TestLocalRA);
        insert TestMIBNF;
        
        Test.startTest();
        
        MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF, TestAddress_Array);
        insert TestMIBNF_Comp;
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, olis[0]);
        insert TestMI_BNFLineItem;
        
        Id bnfid = TestMIBNF.Id;
        PageReference pageRef = new PageReference('Page.MIBNF_AddBillingSchedule');
        pageRef.getParameters().put('salesOrg',TestMIBNF.Sales_Org_Code__c);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdController = new ApexPages.standardController(TestMIBNF_Comp); 
        classObj = new MIBNF_BillingScheduleController(stdController);
        classObj.getExport();
        Test.stopTest();
    }
    
    static testmethod void uploadFile_TestMethod(){
        Opportunity opp =[SELECT Id,AccountId, Opportunity_Number__c,CurrencyIsoCode FROM Opportunity LIMIT 1];
        List<OpportunityLineItem> olis =[SELECT Id,TotalPrice FROM OpportunityLineItem];
        
        List<Address__c> TestAddress_Array = [Select id,Name,Enabled_Sales_Orgs__c,Account__c,Street__c,City__c,Country__c,SAP_Reference__c from Address__c];
        Revenue_Analyst__c TestLocalRA = UTL_TestData.createRevenueAnalyst();
        insert TestLocalRA;
        MIBNF2__c TestMIBNF = UTL_TestData.createMIBNF(opp, TestLocalRA);
        insert TestMIBNF;
        
        Test.startTest();
        
        MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF, TestAddress_Array);
        insert TestMIBNF_Comp;
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, olis[0]);
        insert TestMI_BNFLineItem;
        
        Id bnfid = TestMIBNF.Id;
        PageReference pageRef = new PageReference('Page.MIBNF_AddBillingSchedule');
        pageRef.getParameters().put('salesOrg',TestMIBNF.Sales_Org_Code__c);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdController = new ApexPages.standardController(TestMIBNF_Comp); 
        classObj = new MIBNF_BillingScheduleController(stdController);
       
        String bscurrencyISOCode = 'Billing Amount (' + opp.CurrencyIsoCode + ')';        
       
        //Correct excel json data - rows and headers 
        Integer year = classObj.oliWrapperList[0].oli.Product_Start_Date__c.year();
        Integer month = classObj.oliWrapperList[0].oli.Product_Start_Date__c.month();
        Integer dateComp = classObj.oliWrapperList[0].oli.Product_Start_Date__c.day();
        String billingDate = month + '-' + dateComp + '-' + year;
        classObj.excelJsonData = 'Serial Number,OLI Id(Required),Product Name (Optional),Product Code (Optional),Delivery Country,Total Price,Billing Date (mm-dd-yyyy),Billing Amount (USD),Invoice Description'+'\r\n';
        classObj.excelJsonData += '1,' + classObj.oliWrapperList[0].oli.Id + ',' + classObj.oliWrapperList[0].oli.PricebookEntry.Product2.Name + ',' + classObj.oliWrapperList[0].oli.PricebookEntry.Product2.ProductCode + ',' + classObj.oliWrapperList[0].oli.Delivery_Country__c;
        classObj.excelJsonData += ',' + classObj.oliWrapperList[0].oli.TotalPrice + ',' + billingDate + ',' + classObj.oliWrapperList[0].oli.TotalPrice + ',' +'Invoice desc Test' + '\n';
        classObj.uploadFile();
        Test.stopTest();
    }
    
    static testmethod void uploadFile_TestMethod1(){
        Opportunity opp =[SELECT Id,AccountId, Opportunity_Number__c,CurrencyIsoCode FROM Opportunity LIMIT 1];
        List<OpportunityLineItem> olis =[SELECT Id,TotalPrice FROM OpportunityLineItem];
        
        List<Address__c> TestAddress_Array = [Select id,Name,Enabled_Sales_Orgs__c,Account__c,Street__c,City__c,Country__c,SAP_Reference__c from Address__c];
        Revenue_Analyst__c TestLocalRA = UTL_TestData.createRevenueAnalyst();
        insert TestLocalRA;
        MIBNF2__c TestMIBNF = UTL_TestData.createMIBNF(opp, TestLocalRA);
        insert TestMIBNF;
        
        Test.startTest();
        
        MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF, TestAddress_Array);
        insert TestMIBNF_Comp;
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, olis[0]);
        insert TestMI_BNFLineItem;
        
        Id bnfid = TestMIBNF.Id;
        PageReference pageRef = new PageReference('Page.MIBNF_AddBillingSchedule');
        pageRef.getParameters().put('salesOrg',TestMIBNF.Sales_Org_Code__c);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdController = new ApexPages.standardController(TestMIBNF_Comp); 
        classObj = new MIBNF_BillingScheduleController(stdController);
        
        //incorrect header data - 1
        classObj.excelJsonData = 'Serial Number,OLI Id(Required),Product Name (Optional),Product Code (Optional),Delivery Country,Total Price,Billing Date (mm-dd-yyyy),Billing Amount (USD),Invoice Description,NA,NA'+'\r\n';
        classObj.uploadFile();
        Test.stopTest();
    }  
    
    static testmethod void uploadFile_TestMethod2(){
        Opportunity opp =[SELECT Id,AccountId, Opportunity_Number__c,CurrencyIsoCode FROM Opportunity LIMIT 1];
        List<OpportunityLineItem> olis =[SELECT Id,TotalPrice FROM OpportunityLineItem];
        
        List<Address__c> TestAddress_Array = [Select id,Name,Enabled_Sales_Orgs__c,Account__c,Street__c,City__c,Country__c,SAP_Reference__c from Address__c];
        Revenue_Analyst__c TestLocalRA = UTL_TestData.createRevenueAnalyst();
        insert TestLocalRA;
        MIBNF2__c TestMIBNF = UTL_TestData.createMIBNF(opp, TestLocalRA);
        insert TestMIBNF;
        
        Test.startTest();
        
        MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF, TestAddress_Array);
        insert TestMIBNF_Comp;
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, olis[0]);
        insert TestMI_BNFLineItem;
        
        Id bnfid = TestMIBNF.Id;
        PageReference pageRef = new PageReference('Page.MIBNF_AddBillingSchedule');
        pageRef.getParameters().put('salesOrg',TestMIBNF.Sales_Org_Code__c);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdController = new ApexPages.standardController(TestMIBNF_Comp); 
        classObj = new MIBNF_BillingScheduleController(stdController);
        
        //incorrect header data - 2
        classObj.excelJsonData = 'Serial Number,OLI Id(Required),Product Name (Optional),Product Code (Optional),Delivery Country,Total Price,Billing Date (mm-dd-yyyy),Billing Amount (USD),Invoice Description,NA'+'\r\n';
        classObj.uploadFile();
        Test.stopTest();
    } 
    
    static testmethod void uploadFile_TestMethod3(){
        Opportunity opp =[SELECT Id,AccountId, Opportunity_Number__c,CurrencyIsoCode FROM Opportunity LIMIT 1];
        List<OpportunityLineItem> olis =[SELECT Id,TotalPrice FROM OpportunityLineItem];
        
        List<Address__c> TestAddress_Array = [Select id,Name,Enabled_Sales_Orgs__c,Account__c,Street__c,City__c,Country__c,SAP_Reference__c from Address__c];
        Revenue_Analyst__c TestLocalRA = UTL_TestData.createRevenueAnalyst();
        insert TestLocalRA;
        MIBNF2__c TestMIBNF = UTL_TestData.createMIBNF(opp, TestLocalRA);
        insert TestMIBNF;
        
        Test.startTest();
        
        MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF, TestAddress_Array);
        insert TestMIBNF_Comp;
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, olis[0]);
        insert TestMI_BNFLineItem;
        
        Id bnfid = TestMIBNF.Id;
        PageReference pageRef = new PageReference('Page.MIBNF_AddBillingSchedule');
        pageRef.getParameters().put('salesOrg',TestMIBNF.Sales_Org_Code__c);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdController = new ApexPages.standardController(TestMIBNF_Comp); 
        classObj = new MIBNF_BillingScheduleController(stdController);
        
        classObj.excelJsonData = 'Serial Num,OLI Id(Required),Product Name (Optional),Product Code (Optional),Delivery Country,Total Price,Billing Date (mm-dd-yyyy),Billing Amount (USD),Invoice Description'+'\r\n';
        classObj.excelJsonData += '1,' + classObj.oliWrapperList[0].oli.Id + ',' + classObj.oliWrapperList[0].oli.PricebookEntry.Product2.Name + ',' + classObj.oliWrapperList[0].oli.PricebookEntry.Product2.ProductCode + ',' + classObj.oliWrapperList[0].oli.Delivery_Country__c;
        classObj.excelJsonData += ',' + classObj.oliWrapperList[0].oli.TotalPrice + ',' + classObj.oliWrapperList[0].oli.Product_Start_Date__c + ',' + classObj.oliWrapperList[0].oli.TotalPrice + ',' +'Invoice desc Test' + '\n';
        classObj.uploadFile();
        Test.stopTest();
    } 
    
    static testmethod void uploadFile_TestMethod4(){
        Opportunity opp =[SELECT Id,AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];
        List<OpportunityLineItem> olis =[SELECT Id,TotalPrice FROM OpportunityLineItem];
        
        List<Address__c> TestAddress_Array = [Select id,Name,Enabled_Sales_Orgs__c,Account__c,Street__c,City__c,Country__c,SAP_Reference__c from Address__c];
        Revenue_Analyst__c TestLocalRA = UTL_TestData.createRevenueAnalyst();
        insert TestLocalRA;
        MIBNF2__c TestMIBNF = UTL_TestData.createMIBNF(opp, TestLocalRA);
        insert TestMIBNF;
        
        Test.startTest();
        
        MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF, TestAddress_Array);
        insert TestMIBNF_Comp;
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, olis[0]);
        insert TestMI_BNFLineItem;
        
        Id bnfid = TestMIBNF.Id;
        PageReference pageRef = new PageReference('Page.MIBNF_AddBillingSchedule');
        pageRef.getParameters().put('salesOrg',TestMIBNF.Sales_Org_Code__c);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdController = new ApexPages.standardController(TestMIBNF_Comp); 
        classObj = new MIBNF_BillingScheduleController(stdController);
        
        classObj.excelJsonData = 'Serial Number,OLI Id(Require),Product Name (Optional),Product Code (Optional),Delivery Country,Total Price,Billing Date (mm-dd-yyyy),Billing Amount (USD),Invoice Description'+'\r\n';
        classObj.excelJsonData += '1,' + classObj.oliWrapperList[0].oli.Id + ',' + classObj.oliWrapperList[0].oli.PricebookEntry.Product2.Name + ',' + classObj.oliWrapperList[0].oli.PricebookEntry.Product2.ProductCode + ',' + classObj.oliWrapperList[0].oli.Delivery_Country__c;
        classObj.excelJsonData += ',' + classObj.oliWrapperList[0].oli.TotalPrice + ',' + classObj.oliWrapperList[0].oli.Product_Start_Date__c + ',' + classObj.oliWrapperList[0].oli.TotalPrice + ',' +'Invoice desc Test' + '\n';
        classObj.uploadFile();
        Test.stopTest();
    } 
    
    static testmethod void uploadFile_TestMethod5(){
        Opportunity opp =[SELECT Id,AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];
        List<OpportunityLineItem> olis =[SELECT Id,TotalPrice FROM OpportunityLineItem];
        
        List<Address__c> TestAddress_Array = [Select id,Name,Enabled_Sales_Orgs__c,Account__c,Street__c,City__c,Country__c,SAP_Reference__c from Address__c];
        Revenue_Analyst__c TestLocalRA = UTL_TestData.createRevenueAnalyst();
        insert TestLocalRA;
        MIBNF2__c TestMIBNF = UTL_TestData.createMIBNF(opp, TestLocalRA);
        insert TestMIBNF;
        
        Test.startTest();
        
        MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF, TestAddress_Array);
        insert TestMIBNF_Comp;
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, olis[0]);
        insert TestMI_BNFLineItem;
        
        Id bnfid = TestMIBNF.Id;
        PageReference pageRef = new PageReference('Page.MIBNF_AddBillingSchedule');
        pageRef.getParameters().put('salesOrg',TestMIBNF.Sales_Org_Code__c);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdController = new ApexPages.standardController(TestMIBNF_Comp); 
        classObj = new MIBNF_BillingScheduleController(stdController);
        
        classObj.excelJsonData = 'Serial Number,OLI Id(Required),Product Name (Option),Product Code (Optional),Delivery Country,Total Price,Billing Date (mm-dd-yyyy),Billing Amount (USD),Invoice Description'+'\r\n';
        classObj.excelJsonData += '1,' + classObj.oliWrapperList[0].oli.Id + ',' + classObj.oliWrapperList[0].oli.PricebookEntry.Product2.Name + ',' + classObj.oliWrapperList[0].oli.PricebookEntry.Product2.ProductCode + ',' + classObj.oliWrapperList[0].oli.Delivery_Country__c;
        classObj.excelJsonData += ',' + classObj.oliWrapperList[0].oli.TotalPrice + ',' + classObj.oliWrapperList[0].oli.Product_Start_Date__c + ',' + classObj.oliWrapperList[0].oli.TotalPrice + ',' +'Invoice desc Test' + '\n';
        classObj.uploadFile();
        Test.stopTest();
    } 
    
    static testmethod void uploadFile_TestMethod6(){
        Opportunity opp =[SELECT Id,AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];
        List<OpportunityLineItem> olis =[SELECT Id,TotalPrice FROM OpportunityLineItem];
        
        List<Address__c> TestAddress_Array = [Select id,Name,Enabled_Sales_Orgs__c,Account__c,Street__c,City__c,Country__c,SAP_Reference__c from Address__c];
        Revenue_Analyst__c TestLocalRA = UTL_TestData.createRevenueAnalyst();
        insert TestLocalRA;
        MIBNF2__c TestMIBNF = UTL_TestData.createMIBNF(opp, TestLocalRA);
        insert TestMIBNF;
        
        Test.startTest();
        
        MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF, TestAddress_Array);
        insert TestMIBNF_Comp;
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, olis[0]);
        insert TestMI_BNFLineItem;
        
        Id bnfid = TestMIBNF.Id;
        PageReference pageRef = new PageReference('Page.MIBNF_AddBillingSchedule');
        pageRef.getParameters().put('salesOrg',TestMIBNF.Sales_Org_Code__c);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdController = new ApexPages.standardController(TestMIBNF_Comp); 
        classObj = new MIBNF_BillingScheduleController(stdController);
        
        classObj.excelJsonData = 'Serial Number,OLI Id(Required),Product Name (Optional),Product Code (Option),Delivery Country,Total Price,Billing Date (mm-dd-yyyy),Billing Amount (USD),Invoice Description'+'\r\n';
        classObj.excelJsonData += '1,' + classObj.oliWrapperList[0].oli.Id + ',' + classObj.oliWrapperList[0].oli.PricebookEntry.Product2.Name + ',' + classObj.oliWrapperList[0].oli.PricebookEntry.Product2.ProductCode + ',' + classObj.oliWrapperList[0].oli.Delivery_Country__c;
        classObj.excelJsonData += ',' + classObj.oliWrapperList[0].oli.TotalPrice + ',' + classObj.oliWrapperList[0].oli.Product_Start_Date__c + ',' + classObj.oliWrapperList[0].oli.TotalPrice + ',' +'Invoice desc Test' + '\n';
        classObj.uploadFile();
        Test.stopTest();
    } 
    
    static testmethod void uploadFile_TestMethod7(){
        Opportunity opp =[SELECT Id,AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];
        List<OpportunityLineItem> olis =[SELECT Id,TotalPrice FROM OpportunityLineItem];
        
        List<Address__c> TestAddress_Array = [Select id,Name,Enabled_Sales_Orgs__c,Account__c,Street__c,City__c,Country__c,SAP_Reference__c from Address__c];
        Revenue_Analyst__c TestLocalRA = UTL_TestData.createRevenueAnalyst();
        insert TestLocalRA;
        MIBNF2__c TestMIBNF = UTL_TestData.createMIBNF(opp, TestLocalRA);
        insert TestMIBNF;
        
        Test.startTest();
        
        MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF, TestAddress_Array);
        insert TestMIBNF_Comp;
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, olis[0]);
        insert TestMI_BNFLineItem;
        
        Id bnfid = TestMIBNF.Id;
        PageReference pageRef = new PageReference('Page.MIBNF_AddBillingSchedule');
        pageRef.getParameters().put('salesOrg',TestMIBNF.Sales_Org_Code__c);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdController = new ApexPages.standardController(TestMIBNF_Comp); 
        classObj = new MIBNF_BillingScheduleController(stdController);
        
        classObj.excelJsonData = 'Serial Number,OLI Id(Required),Product Name (Optional),Product Code (Optional),Deliry Count,Total Price,Billing Date (mm-dd-yyyy),Billing Amount (USD),Invoice Description'+'\r\n';
        classObj.excelJsonData += '1,' + classObj.oliWrapperList[0].oli.Id + ',' + classObj.oliWrapperList[0].oli.PricebookEntry.Product2.Name + ',' + classObj.oliWrapperList[0].oli.PricebookEntry.Product2.ProductCode + ',' + classObj.oliWrapperList[0].oli.Delivery_Country__c;
        classObj.excelJsonData += ',' + classObj.oliWrapperList[0].oli.TotalPrice + ',' + classObj.oliWrapperList[0].oli.Product_Start_Date__c + ',' + classObj.oliWrapperList[0].oli.TotalPrice + ',' +'Invoice desc Test' + '\n';
        classObj.uploadFile();
        Test.stopTest();
    } 
    
    static testmethod void uploadFile_TestMethod8(){
        Opportunity opp =[SELECT Id,AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];
        List<OpportunityLineItem> olis =[SELECT Id,TotalPrice FROM OpportunityLineItem];
        
        List<Address__c> TestAddress_Array = [Select id,Name,Enabled_Sales_Orgs__c,Account__c,Street__c,City__c,Country__c,SAP_Reference__c from Address__c];
        Revenue_Analyst__c TestLocalRA = UTL_TestData.createRevenueAnalyst();
        insert TestLocalRA;
        MIBNF2__c TestMIBNF = UTL_TestData.createMIBNF(opp, TestLocalRA);
        insert TestMIBNF;
        
        Test.startTest();
        
        MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF, TestAddress_Array);
        insert TestMIBNF_Comp;
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, olis[0]);
        insert TestMI_BNFLineItem;
        
        Id bnfid = TestMIBNF.Id;
        PageReference pageRef = new PageReference('Page.MIBNF_AddBillingSchedule');
        pageRef.getParameters().put('salesOrg',TestMIBNF.Sales_Org_Code__c);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdController = new ApexPages.standardController(TestMIBNF_Comp); 
        classObj = new MIBNF_BillingScheduleController(stdController);
        
        classObj.excelJsonData = 'Serial Number,OLI Id(Required),Product Name (Optional),Product Code (Optional),Delivery Country,Total,Billing Date (mm-dd-yyyy),Billing Amount (USD),Invoice Description'+'\r\n';
        classObj.excelJsonData += '1,' + classObj.oliWrapperList[0].oli.Id + ',' + classObj.oliWrapperList[0].oli.PricebookEntry.Product2.Name + ',' + classObj.oliWrapperList[0].oli.PricebookEntry.Product2.ProductCode + ',' + classObj.oliWrapperList[0].oli.Delivery_Country__c;
        classObj.excelJsonData += ',' + classObj.oliWrapperList[0].oli.TotalPrice + ',' + classObj.oliWrapperList[0].oli.Product_Start_Date__c + ',' + classObj.oliWrapperList[0].oli.TotalPrice + ',' +'Invoice desc Test' + '\n';
        classObj.uploadFile();
        Test.stopTest();
    }
    
    static testmethod void uploadFile_TestMethod9(){
        Opportunity opp =[SELECT Id,AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];
        List<OpportunityLineItem> olis =[SELECT Id,TotalPrice FROM OpportunityLineItem];
        
        List<Address__c> TestAddress_Array = [Select id,Name,Enabled_Sales_Orgs__c,Account__c,Street__c,City__c,Country__c,SAP_Reference__c from Address__c];
        Revenue_Analyst__c TestLocalRA = UTL_TestData.createRevenueAnalyst();
        insert TestLocalRA;
        MIBNF2__c TestMIBNF = UTL_TestData.createMIBNF(opp, TestLocalRA);
        insert TestMIBNF;
        
        Test.startTest();
        
        MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF, TestAddress_Array);
        insert TestMIBNF_Comp;
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, olis[0]);
        insert TestMI_BNFLineItem;
        
        Id bnfid = TestMIBNF.Id;
        PageReference pageRef = new PageReference('Page.MIBNF_AddBillingSchedule');
        pageRef.getParameters().put('salesOrg',TestMIBNF.Sales_Org_Code__c);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdController = new ApexPages.standardController(TestMIBNF_Comp); 
        classObj = new MIBNF_BillingScheduleController(stdController);
        
        classObj.excelJsonData = 'Serial Number,OLI Id(Required),Product Name (Optional),Product Code (Optional),Delivery Country,Total Price,Billing Date (mm-dd-),Billing Amount (USD),Invoice Description'+'\r\n';
        classObj.excelJsonData += '1,' + classObj.oliWrapperList[0].oli.Id + ',' + classObj.oliWrapperList[0].oli.PricebookEntry.Product2.Name + ',' + classObj.oliWrapperList[0].oli.PricebookEntry.Product2.ProductCode + ',' + classObj.oliWrapperList[0].oli.Delivery_Country__c;
        classObj.excelJsonData += ',' + classObj.oliWrapperList[0].oli.TotalPrice + ',' + classObj.oliWrapperList[0].oli.Product_Start_Date__c + ',' + classObj.oliWrapperList[0].oli.TotalPrice + ',' +'Invoice desc Test' + '\n';
        classObj.uploadFile();
        Test.stopTest();
    } 
    
    static testmethod void uploadFile_TestMethod10(){
       Opportunity opp =[SELECT Id,AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];
        List<OpportunityLineItem> olis =[SELECT Id,TotalPrice FROM OpportunityLineItem];
        
        List<Address__c> TestAddress_Array = [Select id,Name,Enabled_Sales_Orgs__c,Account__c,Street__c,City__c,Country__c,SAP_Reference__c from Address__c];
        Revenue_Analyst__c TestLocalRA = UTL_TestData.createRevenueAnalyst();
        insert TestLocalRA;
        MIBNF2__c TestMIBNF = UTL_TestData.createMIBNF(opp, TestLocalRA);
        insert TestMIBNF;
        
        Test.startTest();
        
        MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF, TestAddress_Array);
        insert TestMIBNF_Comp;
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, olis[0]);
        insert TestMI_BNFLineItem;
        
        Id bnfid = TestMIBNF.Id;
        PageReference pageRef = new PageReference('Page.MIBNF_AddBillingSchedule');
        pageRef.getParameters().put('salesOrg',TestMIBNF.Sales_Org_Code__c);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdController = new ApexPages.standardController(TestMIBNF_Comp); 
        classObj = new MIBNF_BillingScheduleController(stdController);
        
        classObj.excelJsonData = 'Serial Number,OLI Id(Required),Product Name (Optional),Product Code (Optional),Delivery Country,Total Price,Billing Date (mm-dd-yyyy),Billing Amount(),Invoice Description'+'\r\n';
        classObj.excelJsonData += '1,' + classObj.oliWrapperList[0].oli.Id + ',' + classObj.oliWrapperList[0].oli.PricebookEntry.Product2.Name + ',' + classObj.oliWrapperList[0].oli.PricebookEntry.Product2.ProductCode + ',' + classObj.oliWrapperList[0].oli.Delivery_Country__c;
        classObj.excelJsonData += ',' + classObj.oliWrapperList[0].oli.TotalPrice + ',' + classObj.oliWrapperList[0].oli.Product_Start_Date__c + ',' + classObj.oliWrapperList[0].oli.TotalPrice + ',' +'Invoice desc Test' + '\n';
        classObj.uploadFile();
        Test.stopTest();
    } 
    
    static testmethod void uploadFile_TestMethod11(){
       Opportunity opp =[SELECT Id,AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];
        List<OpportunityLineItem> olis =[SELECT Id,TotalPrice FROM OpportunityLineItem];
        
        List<Address__c> TestAddress_Array = [Select id,Name,Enabled_Sales_Orgs__c,Account__c,Street__c,City__c,Country__c,SAP_Reference__c from Address__c];
        Revenue_Analyst__c TestLocalRA = UTL_TestData.createRevenueAnalyst();
        insert TestLocalRA;
        MIBNF2__c TestMIBNF = UTL_TestData.createMIBNF(opp, TestLocalRA);
        insert TestMIBNF;
        
        Test.startTest();
        
        MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF, TestAddress_Array);
        insert TestMIBNF_Comp;
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, olis[0]);
        insert TestMI_BNFLineItem;
        
        Id bnfid = TestMIBNF.Id;
        PageReference pageRef = new PageReference('Page.MIBNF_AddBillingSchedule');
        pageRef.getParameters().put('salesOrg',TestMIBNF.Sales_Org_Code__c);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdController = new ApexPages.standardController(TestMIBNF_Comp); 
        classObj = new MIBNF_BillingScheduleController(stdController);
        
        classObj.excelJsonData = 'Serial Number,OLI Id(Required),Product Name (Optional),Product Code (Optional),Delivery Country,Total Price,Billing Date (mm-dd-yyyy),Billing Amount (USD),Invoice Descri'+'\r\n';
        classObj.excelJsonData += '1,' + classObj.oliWrapperList[0].oli.Id + ',' + classObj.oliWrapperList[0].oli.PricebookEntry.Product2.Name + ',' + classObj.oliWrapperList[0].oli.PricebookEntry.Product2.ProductCode + ',' + classObj.oliWrapperList[0].oli.Delivery_Country__c;
        classObj.excelJsonData += ',' + classObj.oliWrapperList[0].oli.TotalPrice + ',' + classObj.oliWrapperList[0].oli.Product_Start_Date__c + ',' + classObj.oliWrapperList[0].oli.TotalPrice + ',' +'Invoice desc Test' + '\n';
        classObj.uploadFile();
        Test.stopTest();
    }
}