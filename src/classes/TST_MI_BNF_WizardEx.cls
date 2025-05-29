@isTest
private class TST_MI_BNF_WizardEx {
    
    @testSetup static void setupTestData(){
        Current_Release_Version__c crv = new Current_Release_Version__c();
        crv.Current_Release__c = '3000.01';
        upsert crv;
        //BNF_Settings__c bs = new BNF_Settings__c();
        //bs.BNF_Release__c = 2019.01;
        //upsert bs;
        
        Global_Variables.PCFlag = false;
        Global_Variables.RunQuickOppLimitTrigger = false;
        Global_Variables.RenewalCloneFlag = TRUE;
        Global_Variables.syncAgreementToOppty=false;
        Global_Variables.PCTrigger_Hault_Execution=false;
        
        UTL_ExecutionControl.stopTriggerExecution = true;
        Trigger_Control_For_Migration__c tcm = Trigger_Control_For_Migration__c.getInstance();
        tcm.Disable_MIBNF_Trigger__c = true;
        upsert tcm;
        Account TestAccount = BNF_Test_Data.createAccount();
        //Contact  TestContact = BNF_Test_Data.createContact();
        List<Address__c> TestAddress_Array = BNF_Test_Data.createAddress_Array();
        Opportunity opp = BNF_Test_Data.createOpp();
        BNF_Settings__c bnfsetting = BNF_Test_Data.createBNFSetting();
        List<OpportunityLineItem> OLI_Array = BNF_Test_Data.createOppLineItem();
        List<Billing_Schedule__c> billingSchedule = BNF_Test_Data.createBillingSchedule();
        List<Billing_Schedule_Item__c> billingScheduleItem = BNF_Test_Data.createBillingScheduleItem();
        Revenue_Analyst__c TestLocalRA = UTL_TestData.createRevenueAnalyst();
        insert TestLocalRA;
        MIBNF2__c TestMIBNF = UTL_TestData.createMIBNF(opp, TestLocalRA);
        insert TestMIBNF;
        tcm = Trigger_Control_For_Migration__c.getInstance();
        tcm.Disable_MIBNF_Trigger__c = false;
        update tcm;
        MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF, TestAddress_Array);
        insert TestMIBNF_Comp;
        UTL_ExecutionControl.stopTriggerExecution = false;
    }
    
    static testMethod void MIBNFSaveTest() {
        MIBNF_Component__c TestMIBNF_Comp = [Select id,name,MIBNF__c, Addendum__c,Is_this_a_retainer_downpayment__c, Print_Shop__c,BNF_Status__c, Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c,
                                             Pass_thru_schedules__c, Retainer_Opportunity_Number__c, Travel_Amount__c, Accomodation_Amount__c, Sub_Contractor_Amount__c, Hono__c from MIBNF_Component__c][0];
        MIBNF2__c TestMIBNF = [Select id,name,Client__c,Opportunity__c,Opportunity_Number__c,Sales_Org_Code__c,Billing_Currency__c,IMS_Sales_Org__c,Fair_Value_Type__c,Invoice_Default_Day__c,Contract_Start_Date__c,Contract_End_Date__c,Contract_Type__c,Contract_Term__c,Payment_Terms__c,Revenue_Analyst__c from MIBNF2__c][0];
        List<OpportunityLineItem> oliList = [select id, OpportunityId, Opportunity.StageName, Opportunity.currencyIsoCode, Opportunity.Contract_Start_Date__c, Opportunity.Contract_End_Date__c, Project_Start_Date__c,Project_End_Date__c,
                                             TotalPrice,PricebookEntry.Product2.Name, PricebookEntry.Product2.material_type__c,PricebookEntry.Product2.ProductCode, PricebookEntry.Product2.Item_Category_Group__c, Product_Start_Date__c, Product_End_Date__c,Revised_Price__c,Revised_Revenue_Schedule__c from OpportunityLineItem];
        Opportunity TestOpp = [Select id,Name,StageName,CloseDate,Budget_Available__c, AccountId,Contract_Term__c,Contract_End_Date__c,Contract_Start_Date__c,Contract_Type__c,LeadSource,CurrencyIsoCode from Opportunity][0];
        Test.startTest();
        delete TestMIBNF;
        
        ApexPages.CurrentPage().getParameters().put('oppid' , TestOpp.id );
        ApexPages.CurrentPage().getParameters().put('revised' ,'1');
        PageReference pageRef = ApexPages.currentPage();
        Test.setCurrentPageReference(pageRef);
        MI_BNF_WizardEx controller = new MI_BNF_WizardEx();
        controller.getMIBNF();
        controller.getMIBNF_Comp();
        controller.getMIBNF_LineItem();
        controller.step2();
        controller.step1();
        PageReference pg=controller.save();
        Test.stopTest();
    }
    
    // Test method for Cancel from wizard page
     static testMethod void CancelTest() {
        test.starttest();
        MIBNF_Component__c TestMIBNF_Comp = [Select SAP_Contract__c,SAP_Master_Contract__c,  id,name,MIBNF__c, Addendum__c,Is_this_a_retainer_downpayment__c, Print_Shop__c,BNF_Status__c, Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from MIBNF_Component__c][0];
        MIBNF2__c TestMIBNF = [Select id,name,Client__c,Opportunity__c,Opportunity_Number__c,Sales_Org_Code__c,Billing_Currency__c,IMS_Sales_Org__c,Fair_Value_Type__c,Invoice_Default_Day__c,Contract_Start_Date__c,Contract_End_Date__c,Contract_Type__c,Contract_Term__c,Payment_Terms__c,Revenue_Analyst__c from MIBNF2__c][0];
        List<OpportunityLineItem> oliList = [select id, OpportunityId, Opportunity.StageName, Opportunity.currencyIsoCode, Opportunity.Contract_Start_Date__c, Opportunity.Contract_End_Date__c, Project_Start_Date__c,Project_End_Date__c,
                                    TotalPrice,PricebookEntry.Product2.Name, PricebookEntry.Product2.material_type__c,PricebookEntry.Product2.ProductCode, PricebookEntry.Product2.Item_Category_Group__c, Product_Start_Date__c, Product_End_Date__c,Revised_Price__c,Revised_Revenue_Schedule__c from OpportunityLineItem];
        Opportunity TestOpp = [Select id,Name,StageName,CloseDate,Budget_Available__c, AccountId,Contract_Term__c,Contract_End_Date__c,Contract_Start_Date__c,Contract_Type__c,LeadSource,CurrencyIsoCode from Opportunity][0];
        
      
       

         
       TestMIBNF_Comp.SAP_Contract__c = '1234567890';
       TestMIBNF_Comp.SAP_Master_Contract__c = '1234567890';
       //upsert TestMIBNF_Comp;
       MI_BNF_Approval_Extension.CustomApprovalPage = true;
       TestMIBNF_Comp.BNF_Status__c = 'RA Accepted';
       upsert TestMIBNF_Comp;
       
       ApexPages.CurrentPage().getParameters().put('oppid',TestOpp.id );
       ApexPages.CurrentPage().getParameters().put('id',TestMIBNF_Comp.id );
       PageReference pageRef = ApexPages.currentPage();
       Test.setCurrentPageReference(pageRef);

       MI_BNF_WizardEx controller = new MI_BNF_WizardEx();
       PageReference pg=controller.cancel();

       test.stopTest();
        
    }
    
     // Test method for Cancel if MIBNF id passed
     static testMethod void CancelTest1() {
         test.startTest();
        MIBNF_Component__c TestMIBNF_Comp = [Select id,name,MIBNF__c, Addendum__c,Is_this_a_retainer_downpayment__c, Print_Shop__c,BNF_Status__c, Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from MIBNF_Component__c][0];
        MIBNF2__c TestMIBNF = [Select id,name,Client__c,Opportunity__c,Opportunity_Number__c,Sales_Org_Code__c,Billing_Currency__c,IMS_Sales_Org__c,Fair_Value_Type__c,Invoice_Default_Day__c,Contract_Start_Date__c,Contract_End_Date__c,Contract_Type__c,Contract_Term__c,Payment_Terms__c,Revenue_Analyst__c from MIBNF2__c][0];
        List<OpportunityLineItem> oliList = [select id, OpportunityId, Opportunity.StageName, Opportunity.currencyIsoCode, Opportunity.Contract_Start_Date__c, Opportunity.Contract_End_Date__c, Project_Start_Date__c,Project_End_Date__c, Cancel__c,
                                    TotalPrice,PricebookEntry.Product2.Name, PricebookEntry.Product2.material_type__c,PricebookEntry.Product2.ProductCode, PricebookEntry.Product2.Item_Category_Group__c, Product_Start_Date__c, Product_End_Date__c,Revised_Price__c,Revised_Revenue_Schedule__c from OpportunityLineItem];
        Opportunity TestOpp = [Select id,Name,StageName,CloseDate,Budget_Available__c, AccountId,Contract_Term__c,Contract_End_Date__c,Contract_Start_Date__c,Contract_Type__c,LeadSource,CurrencyIsoCode from Opportunity][0];
        
        //Ghanshyam
         if(oliList.size() > 0){
             for(OpportunityLineItem oliObj : oliList){
                 oliObj.Cancel__c = true;
             }             
             upsert oliList;
         } 
      
      
       ApexPages.CurrentPage().getParameters().put('oppid',TestOpp.id);
       //Ghanshyam
       //ApexPages.CurrentPage().getParameters().put('mibnfid',TestMIBNF.id);
       PageReference pageRef = ApexPages.currentPage();
       Test.setCurrentPageReference(pageRef);
       MI_BNF_WizardEx controller = new MI_BNF_WizardEx();
       pageRef=controller.cancel();
       test.stopTest(); 
    }
    
    
     static testMethod void ContractDateTest() {
        MIBNF_Component__c TestMIBNF_Comp = [Select id,name,MIBNF__c, Addendum__c,Is_this_a_retainer_downpayment__c, Print_Shop__c,BNF_Status__c, Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from MIBNF_Component__c][0];
        MIBNF2__c TestMIBNF = [Select id,name,Client__c,Opportunity__c,Opportunity_Number__c,Sales_Org_Code__c,Billing_Currency__c,IMS_Sales_Org__c,Fair_Value_Type__c,Invoice_Default_Day__c,Contract_Start_Date__c,Contract_End_Date__c,Contract_Type__c,Contract_Term__c,Payment_Terms__c,Revenue_Analyst__c from MIBNF2__c][0];
        List<OpportunityLineItem> oliList = [select id, OpportunityId, Opportunity.StageName, Opportunity.currencyIsoCode, Opportunity.Contract_Start_Date__c, Opportunity.Contract_End_Date__c, Project_Start_Date__c,Project_End_Date__c,
                                    TotalPrice,PricebookEntry.Product2.Name, PricebookEntry.Product2.material_type__c,PricebookEntry.Product2.ProductCode, PricebookEntry.Product2.Item_Category_Group__c, Product_Start_Date__c, Product_End_Date__c,Revised_Price__c,Revised_Revenue_Schedule__c from OpportunityLineItem];
        Opportunity TestOpp = [Select id,Name,StageName,CloseDate,Budget_Available__c, AccountId,Contract_Term__c,Contract_End_Date__c,Contract_Start_Date__c,Contract_Type__c,LeadSource,CurrencyIsoCode from Opportunity][0];
        
        test.starttest();
        
        ApexPages.CurrentPage().getParameters().put('oppid' , TestOpp.id );
        PageReference pageRef = ApexPages.currentPage();
        Test.setCurrentPageReference(pageRef);
        MI_BNF_WizardEx controller = new MI_BNF_WizardEx();
        controller.getMIBNF();
        controller.getMIBNF_LineItem();
        pageRef=controller.step2();
        //commented by ranu - Validation is written for Contract start date can not be less them End date 
       // System.assertEquals(controller.Errorflag,true);
       // ApexPages.Message msg1 = ApexPages.getMessages()[0];
        //System.assertEquals('Contract End Date cannot be before Contract Start Date', msg1.getDetail());
        test.stoptest();
        
    }
    
     // Revised BNF Test
   	static testMethod void BNFRevisedValidate() {
       
      MIBNF_Component__c TestMIBNF_Comp = [Select id,name,MIBNF__c, Addendum__c,Is_this_a_retainer_downpayment__c, Print_Shop__c,BNF_Status__c, Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from MIBNF_Component__c][0];
        MIBNF2__c TestMIBNF = [Select id,name,Client__c,Opportunity__c,Opportunity_Number__c,Sales_Org_Code__c,Billing_Currency__c,IMS_Sales_Org__c,Fair_Value_Type__c,Invoice_Default_Day__c,Contract_Start_Date__c,Contract_End_Date__c,Contract_Type__c,Contract_Term__c,Payment_Terms__c,Revenue_Analyst__c from MIBNF2__c][0];
        List<OpportunityLineItem> oliList = [select id, OpportunityId, Opportunity.StageName, Opportunity.currencyIsoCode, Opportunity.Contract_Start_Date__c, Opportunity.Contract_End_Date__c, Project_Start_Date__c,Project_End_Date__c,
                                    TotalPrice,PricebookEntry.Product2.Name, PricebookEntry.Product2.material_type__c,PricebookEntry.Product2.ProductCode, PricebookEntry.Product2.Item_Category_Group__c, Product_Start_Date__c, Product_End_Date__c,Revised_Price__c,Revised_Revenue_Schedule__c from OpportunityLineItem];
        Opportunity TestOpp = [Select id,Name,StageName,CloseDate,Budget_Available__c, AccountId,Contract_Term__c,Contract_End_Date__c,Contract_Start_Date__c,Contract_Type__c,LeadSource,CurrencyIsoCode from Opportunity][0];
        
       test.startTest();
       
       ApexPages.CurrentPage().getParameters().put('minfid' , TestMIBNF.id );
       ApexPages.CurrentPage().getParameters().put('prdids' , oliList[1].Id);
       MI_BNF_ADD_Product prdcontroller = new MI_BNF_ADD_Product();
       prdcontroller.selectedInvoice=TestMIBNF_Comp.Id;
               
       PageReference prdpageRef=prdcontroller.Save();
       ApexPages.CurrentPage().getParameters().put('mibnfid' ,  TestMIBNF.id);
       ApexPages.CurrentPage().getParameters().put('id' ,TestMIBNF_Comp.id);
       ApexPages.CurrentPage().getParameters().put('revised' ,'1');
       ApexPages.CurrentPage().getParameters().put('oppid', TestOpp.id);
       
       PageReference pageRef = ApexPages.currentPage();
       Test.setCurrentPageReference(pageRef);
       MI_BNF_WizardEx controller = new MI_BNF_WizardEx();
       
       ApexPages.Message msg1 = ApexPages.getMessages()[0];
        test.stopTest();
    } 
   
    // Revised BNF Test
     static testMethod void BNFRevised() {
       
      
       MIBNF_Component__c TestMIBNF_Comp = [Select id,name,MIBNF__c, Addendum__c,Is_this_a_retainer_downpayment__c, Print_Shop__c,BNF_Status__c, Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from MIBNF_Component__c][0];
        MIBNF2__c TestMIBNF = [Select Id, IsDeleted, Name, CurrencyIsoCode, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate,  
                              Opportunity__c, Addendum_Reasons__c, Addendum__c, Additional_Billing_Date_Information__c, Billing_Currency__c, Client__c, Comments__c, Contract_End_Date__c, Contract_Start_Date__c,
                              Contract_Term__c, Contract_Type__c, Description__c, Display_Currency__c, Fair_Value_Type__c, IMS_Sales_Org__c, Invoice_Default_Day__c, MIBNF_Status__c, Manual_Handling_in_SAP__c,
                              Max_Invoice_Count__c, Opportunity_Number__c, Original_Prior_Opportunity_Id__c, Original_Prior_Opportunity__c, Parent_Code__c, Payment_Terms__c, Print_Shop__c, Product_SAP_Code__c,
                              RA_Rejection_Count__c, Rejection_Reasons__c, Renewal__c, Retainer_Data_Value__c, Revenue_Analyst__c, Revenue_Analyst_del__c, Revised_BNF_Comment__c, Revised_BNF_Date__c, SAP_Contract_Type__c,
                              SAP_Master_Contract__c, SAP_PC_Code__c, SAP_Rejection_Count__c, SAP_SD_Error_Group__c, SAP_SD_Error_Message__c, Sales_Org_Code__c, Specification__c, Subscription_Type__c, Therapy_Area__c, BNF_Count__c, Contract_Value__c FROM MIBNF2__c][0];
        List<OpportunityLineItem> oliList = [select id, OpportunityId, Opportunity.StageName, Opportunity.currencyIsoCode, Opportunity.Contract_Start_Date__c, Opportunity.Contract_End_Date__c, Project_Start_Date__c,Project_End_Date__c,
                                    TotalPrice,PricebookEntry.Product2.Name, PricebookEntry.Product2.material_type__c,PricebookEntry.Product2.ProductCode, PricebookEntry.Product2.Item_Category_Group__c, Product_Start_Date__c, Product_End_Date__c,Revised_Price__c,Revised_Revenue_Schedule__c from OpportunityLineItem];
        Opportunity TestOpp = [Select id,Name,StageName,CloseDate,Budget_Available__c, AccountId,Contract_Term__c,Contract_End_Date__c,Contract_Start_Date__c,Contract_Type__c,LeadSource,CurrencyIsoCode from Opportunity][0];
        
       Test.startTest();      
       
       ApexPages.CurrentPage().getParameters().put('mibnfid' ,  TestMIBNF.id);
       ApexPages.CurrentPage().getParameters().put('id' ,TestMIBNF_Comp.id);
       ApexPages.CurrentPage().getParameters().put('revised' ,'1');
       ApexPages.CurrentPage().getParameters().put('oppid', TestOpp.id);
       
       PageReference pageRef = ApexPages.currentPage();
       Test.setCurrentPageReference(pageRef);
       MI_BNF_WizardEx controller2 = new MI_BNF_WizardEx();
       
       pageRef=controller2.save();
       Test.stopTest();   
        
    }
   
     // Revised BNF Test
     static testMethod void BNFNotRevised() {
       
      MIBNF_Component__c TestMIBNF_Comp = [Select id,name,MIBNF__c, Addendum__c,Is_this_a_retainer_downpayment__c, Print_Shop__c,BNF_Status__c, Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c,
         Pass_thru_schedules__c, Retainer_Opportunity_Number__c, Travel_Amount__c, Accomodation_Amount__c, Sub_Contractor_Amount__c, Hono__c from MIBNF_Component__c][0];
        MIBNF2__c TestMIBNF = [Select Id, IsDeleted, Name, CurrencyIsoCode, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate,  
                              Opportunity__c, Addendum_Reasons__c, Addendum__c, Additional_Billing_Date_Information__c, Billing_Currency__c, Client__c, Comments__c, Contract_End_Date__c, Contract_Start_Date__c,
                              Contract_Term__c, Contract_Type__c, Description__c, Display_Currency__c, Fair_Value_Type__c, IMS_Sales_Org__c, Invoice_Default_Day__c, MIBNF_Status__c, Manual_Handling_in_SAP__c,
                              Max_Invoice_Count__c, Opportunity_Number__c, Original_Prior_Opportunity_Id__c, Original_Prior_Opportunity__c, Parent_Code__c, Payment_Terms__c, Print_Shop__c, Product_SAP_Code__c,
                              RA_Rejection_Count__c, Rejection_Reasons__c, Renewal__c, Retainer_Data_Value__c, Revenue_Analyst__c, Revenue_Analyst_del__c, Revised_BNF_Comment__c, Revised_BNF_Date__c, SAP_Contract_Type__c,
                              SAP_Master_Contract__c, SAP_PC_Code__c, SAP_Rejection_Count__c, SAP_SD_Error_Group__c, SAP_SD_Error_Message__c, Sales_Org_Code__c, Specification__c, Subscription_Type__c, Therapy_Area__c, BNF_Count__c, Contract_Value__c FROM MIBNF2__c ][0];
        List<OpportunityLineItem> oliList = [select id, OpportunityId, Opportunity.StageName, Opportunity.currencyIsoCode, Opportunity.Contract_Start_Date__c, Opportunity.Contract_End_Date__c, Project_Start_Date__c,Project_End_Date__c,
                                    TotalPrice,PricebookEntry.Product2.Name, PricebookEntry.Product2.material_type__c,PricebookEntry.Product2.ProductCode, PricebookEntry.Product2.Item_Category_Group__c, Product_Start_Date__c, Product_End_Date__c,Revised_Price__c,Revised_Revenue_Schedule__c from OpportunityLineItem];
        Opportunity TestOpp = [Select id,Name,StageName,CloseDate,Budget_Available__c, AccountId,Contract_Term__c,Contract_End_Date__c,Contract_Start_Date__c,Contract_Type__c,LeadSource,CurrencyIsoCode from Opportunity][0];
    
       Test.startTest();
         
       ApexPages.CurrentPage().getParameters().put('mibnfid' ,  TestMIBNF.id);
       //Ghanshyam 
       ApexPages.CurrentPage().getParameters().put('oppid' , TestOpp.id ); 
       ApexPages.CurrentPage().getParameters().put('id' ,TestMIBNF_Comp.id);

       PageReference pageRef = ApexPages.currentPage();
       Test.setCurrentPageReference(pageRef);
       MI_BNF_WizardEx controller = new MI_BNF_WizardEx();

       controller.MIBNF = TestMIBNF;
       //controller.SelectProductList = (String)oliList[0].Id; 
       PageReference pg=controller.save();
       Test.stopTest();
        
    }
    
         // Revised BNF Test
     static testMethod void BNFNotRevised1() {
       
      MIBNF_Component__c TestMIBNF_Comp = [Select id,name,MIBNF__c, Addendum__c,Is_this_a_retainer_downpayment__c, Print_Shop__c,BNF_Status__c, Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c,
         Pass_thru_schedules__c, Retainer_Opportunity_Number__c, Travel_Amount__c, Accomodation_Amount__c, Sub_Contractor_Amount__c, Hono__c from MIBNF_Component__c][0];
        MIBNF2__c TestMIBNF = [Select Id, IsDeleted, Name, CurrencyIsoCode, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate,  
                              Opportunity__c, Addendum_Reasons__c, Addendum__c, Additional_Billing_Date_Information__c, Billing_Currency__c, Client__c, Comments__c, Contract_End_Date__c, Contract_Start_Date__c,
                              Contract_Term__c, Contract_Type__c, Description__c, Display_Currency__c, Fair_Value_Type__c, IMS_Sales_Org__c, Invoice_Default_Day__c, MIBNF_Status__c, Manual_Handling_in_SAP__c,
                              Max_Invoice_Count__c, Opportunity_Number__c, Original_Prior_Opportunity_Id__c, Original_Prior_Opportunity__c, Parent_Code__c, Payment_Terms__c, Print_Shop__c, Product_SAP_Code__c,
                              RA_Rejection_Count__c, Rejection_Reasons__c, Renewal__c, Retainer_Data_Value__c, Revenue_Analyst__c, Revenue_Analyst_del__c, Revised_BNF_Comment__c, Revised_BNF_Date__c, SAP_Contract_Type__c,
                              SAP_Master_Contract__c, SAP_PC_Code__c, SAP_Rejection_Count__c, SAP_SD_Error_Group__c, SAP_SD_Error_Message__c, Sales_Org_Code__c, Specification__c, Subscription_Type__c, Therapy_Area__c, BNF_Count__c, Contract_Value__c FROM MIBNF2__c ][0];
        List<OpportunityLineItem> oliList = [select id, OpportunityId, Opportunity.StageName, Opportunity.currencyIsoCode, Opportunity.Contract_Start_Date__c, Opportunity.Contract_End_Date__c, Project_Start_Date__c,Project_End_Date__c,
                                    TotalPrice,PricebookEntry.Product2.Name, PricebookEntry.Product2.material_type__c,PricebookEntry.Product2.ProductCode, PricebookEntry.Product2.Item_Category_Group__c, Product_Start_Date__c, Product_End_Date__c,Revised_Price__c,Revised_Revenue_Schedule__c from OpportunityLineItem];
        Opportunity TestOpp = [Select id,Name,StageName,CloseDate,Budget_Available__c, AccountId,Contract_Term__c,Contract_End_Date__c,Contract_Start_Date__c,Contract_Type__c,LeadSource,CurrencyIsoCode from Opportunity][0];
    
       Test.startTest();
         
       ApexPages.CurrentPage().getParameters().put('mibnfid' ,  TestMIBNF.id);
       //Ghanshyam 
       ApexPages.CurrentPage().getParameters().put('oppid' , TestOpp.id ); 
       ApexPages.CurrentPage().getParameters().put('id' ,TestMIBNF_Comp.id);

       PageReference pageRef = ApexPages.currentPage();
       Test.setCurrentPageReference(pageRef);
       MI_BNF_WizardEx controller = new MI_BNF_WizardEx();
        controller.SelectProductList = oliList[0].id +','+oliList[1];
       controller.MIBNF = TestMIBNF;
       //controller.SelectProductList = (String)oliList[0].Id; 
       PageReference pg=controller.save();
       Test.stopTest();
        
    }
    
     // MIBNFConstructorTest
     static testMethod void MIBNFConstructorTest() {

      MIBNF_Component__c TestMIBNF_Comp = [Select id,name,MIBNF__c, Addendum__c,Is_this_a_retainer_downpayment__c, Print_Shop__c,BNF_Status__c, Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c,
         Pass_thru_schedules__c, Retainer_Opportunity_Number__c, Travel_Amount__c, Accomodation_Amount__c, Sub_Contractor_Amount__c, Hono__c from MIBNF_Component__c][0];
        MIBNF2__c TestMIBNF = [Select Id, IsDeleted, Name, CurrencyIsoCode, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate,  
                              Opportunity__c, Addendum_Reasons__c, Addendum__c, Additional_Billing_Date_Information__c, Billing_Currency__c, Client__c, Comments__c, Contract_End_Date__c, Contract_Start_Date__c,
                              Contract_Term__c, Contract_Type__c, Description__c, Display_Currency__c, Fair_Value_Type__c, IMS_Sales_Org__c, Invoice_Default_Day__c, MIBNF_Status__c, Manual_Handling_in_SAP__c,
                              Max_Invoice_Count__c, Opportunity_Number__c, Original_Prior_Opportunity_Id__c, Original_Prior_Opportunity__c, Parent_Code__c, Payment_Terms__c, Print_Shop__c, Product_SAP_Code__c,
                              RA_Rejection_Count__c, Rejection_Reasons__c, Renewal__c, Retainer_Data_Value__c, Revenue_Analyst__c, Revenue_Analyst_del__c, Revised_BNF_Comment__c, Revised_BNF_Date__c, SAP_Contract_Type__c,
                              SAP_Master_Contract__c, SAP_PC_Code__c, SAP_Rejection_Count__c, SAP_SD_Error_Group__c, SAP_SD_Error_Message__c, Sales_Org_Code__c, Specification__c, Subscription_Type__c, Therapy_Area__c, BNF_Count__c, Contract_Value__c FROM MIBNF2__c ][0];
        List<OpportunityLineItem> oliList = [select id, OpportunityId, Opportunity.StageName, Opportunity.currencyIsoCode, Opportunity.Contract_Start_Date__c, Opportunity.Contract_End_Date__c, Project_Start_Date__c,Project_End_Date__c,
                                    TotalPrice,PricebookEntry.Product2.Name, PricebookEntry.Product2.material_type__c,PricebookEntry.Product2.ProductCode, PricebookEntry.Product2.Item_Category_Group__c, Product_Start_Date__c, Product_End_Date__c,Revised_Price__c,Revised_Revenue_Schedule__c from OpportunityLineItem];
        Opportunity TestOpp = [Select id,Name,StageName,CloseDate,Budget_Available__c, AccountId,Contract_Term__c,Contract_End_Date__c,Contract_Start_Date__c,Contract_Type__c,LeadSource,CurrencyIsoCode from Opportunity][0];
        
       Test.startTest();
       ApexPages.CurrentPage().getParameters().put('revised' ,'1');
       PageReference pageRef = ApexPages.currentPage();
       Test.setCurrentPageReference(pageRef);
       MI_BNF_WizardEx controller = new MI_BNF_WizardEx(TestMIBNF_Comp.id,TestMIBNF.id,TestOpp.id);
       controller.getMIBNF();
       controller.getMIBNF_Comp();
       controller.getMIBNF_LineItem();
       Test.stopTest();
    }
    
    
    
     // Component PDF
     static testMethod void TestCompPDF() {
       
       MIBNF_Component__c TestMIBNF_Comp = [Select id,name,MIBNF__c, Addendum__c,Is_this_a_retainer_downpayment__c, Print_Shop__c,BNF_Status__c, Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from MIBNF_Component__c][0];
        MIBNF2__c TestMIBNF = [Select id,name,Client__c,Opportunity__c,Opportunity_Number__c,Sales_Org_Code__c,Billing_Currency__c,IMS_Sales_Org__c,Fair_Value_Type__c,Invoice_Default_Day__c,Contract_Start_Date__c,Contract_End_Date__c,Contract_Type__c,Contract_Term__c,Payment_Terms__c,Revenue_Analyst__c from MIBNF2__c][0];
        List<OpportunityLineItem> oliList = [select id, OpportunityId, Opportunity.StageName, Opportunity.currencyIsoCode, Opportunity.Contract_Start_Date__c, Opportunity.Contract_End_Date__c, Project_Start_Date__c,Project_End_Date__c,
                                    TotalPrice,PricebookEntry.Product2.Name, PricebookEntry.Product2.material_type__c,PricebookEntry.Product2.ProductCode, PricebookEntry.Product2.Item_Category_Group__c, Product_Start_Date__c, Product_End_Date__c,Revised_Price__c,Revised_Revenue_Schedule__c from OpportunityLineItem];
        Opportunity TestOpp = [Select id,Name,StageName,CloseDate,Budget_Available__c, AccountId,Contract_Term__c,Contract_End_Date__c,Contract_Start_Date__c,Contract_Type__c,LeadSource,CurrencyIsoCode from Opportunity][0];
        
       Test.startTest();
         
       ApexPages.CurrentPage().getParameters().put('id' ,TestMIBNF_Comp.id);
       ApexPages.CurrentPage().getParameters().put('mibnfid' ,TestMIBNF.id);
       PageReference pageRef = ApexPages.currentPage();
       Test.setCurrentPageReference(pageRef);
       MI_BNF_Comp_PDF controller = new MI_BNF_Comp_PDF();
       controller.getMIBNF_Comp();
       controller.getMIBNF(); 
       controller.getOpportunityLineItem(); 
       Test.stopTest();
    }
    
    
     // Component PDF
     static testMethod void TestCompPDFwithoutLineItem() {
       
       MIBNF_Component__c TestMIBNF_Comp = [Select id,name,MIBNF__c, Addendum__c,Is_this_a_retainer_downpayment__c, Print_Shop__c,BNF_Status__c, Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from MIBNF_Component__c][0];
        MIBNF2__c TestMIBNF = [Select id,name,Client__c,Opportunity__c,Opportunity_Number__c,Sales_Org_Code__c,Billing_Currency__c,IMS_Sales_Org__c,Fair_Value_Type__c,Invoice_Default_Day__c,Contract_Start_Date__c,Contract_End_Date__c,Contract_Type__c,Contract_Term__c,Payment_Terms__c,Revenue_Analyst__c from MIBNF2__c][0];
        List<OpportunityLineItem> oliList = [select id, OpportunityId, Opportunity.StageName, Opportunity.currencyIsoCode, Opportunity.Contract_Start_Date__c, Opportunity.Contract_End_Date__c, Project_Start_Date__c,Project_End_Date__c,
                                    TotalPrice,PricebookEntry.Product2.Name, PricebookEntry.Product2.material_type__c,PricebookEntry.Product2.ProductCode, PricebookEntry.Product2.Item_Category_Group__c, Product_Start_Date__c, Product_End_Date__c,Revised_Price__c,Revised_Revenue_Schedule__c from OpportunityLineItem];
        Opportunity TestOpp = [Select id,Name,StageName,CloseDate,Budget_Available__c, AccountId,Contract_Term__c,Contract_End_Date__c,Contract_Start_Date__c,Contract_Type__c,LeadSource,CurrencyIsoCode from Opportunity][0];
        
        Test.startTest() ;
         
       ApexPages.CurrentPage().getParameters().put('id' ,TestMIBNF_Comp.id);
      
      
        ApexPages.CurrentPage().getParameters().put('mibnfid' ,TestMIBNF.id);
       
       
       PageReference pageRef = ApexPages.currentPage();
       Test.setCurrentPageReference(pageRef);
       MI_BNF_Comp_PDF controller = new MI_BNF_Comp_PDF();
       controller.getMIBNF_Comp();
       controller.getOpportunityLineItem(); 
       Test.stopTest();
    }
    
  
 
    static testMethod void BNFApprove() {
       
       MIBNF_Component__c TestMIBNF_Comp = [Select id,name,MIBNF__c, Addendum__c,Is_this_a_retainer_downpayment__c, Print_Shop__c,BNF_Status__c, Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from MIBNF_Component__c][0];
        MIBNF2__c TestMIBNF = [Select id,name,Client__c,Opportunity__c,Opportunity_Number__c,Sales_Org_Code__c,Billing_Currency__c,IMS_Sales_Org__c,Fair_Value_Type__c,Invoice_Default_Day__c,Contract_Start_Date__c,Contract_End_Date__c,Contract_Type__c,Contract_Term__c,Payment_Terms__c,Revenue_Analyst__c from MIBNF2__c][0];
        List<OpportunityLineItem> oliList = [select id, OpportunityId, Opportunity.StageName, Opportunity.currencyIsoCode, Opportunity.Contract_Start_Date__c, Opportunity.Contract_End_Date__c, Project_Start_Date__c,Project_End_Date__c,
                                    TotalPrice,PricebookEntry.Product2.Name, PricebookEntry.Product2.material_type__c,PricebookEntry.Product2.ProductCode, PricebookEntry.Product2.Item_Category_Group__c, Product_Start_Date__c, Product_End_Date__c,Revised_Price__c,Revised_Revenue_Schedule__c from OpportunityLineItem];
        Opportunity TestOpp = [Select id,Name,StageName,CloseDate,Budget_Available__c, AccountId,Contract_Term__c,Contract_End_Date__c,Contract_Start_Date__c,Contract_Type__c,LeadSource,CurrencyIsoCode from Opportunity][0];
        
        Test.startTest();
        
       ApexPages.CurrentPage().getParameters().put('id' ,TestMIBNF_Comp.id);
       
       PageReference pageRef = ApexPages.currentPage();
       Test.setCurrentPageReference(pageRef);
       MI_BNF_Comp_Submit_Approval controller = new MI_BNF_Comp_Submit_Approval();
       
       PageReference pg=controller.SubmitRequest();
       
       //  Create an instance of the standard controller
       ApexPages.StandardController stc = new ApexPages.StandardController(TestMIBNF_Comp);
       //  Create an instance of the controller extension       
       MI_BNF_Approval_Extension controller1 = new MI_BNF_Approval_Extension(stc);
       controller1.Init();
       controller1.RejectionReason = 'Multiple Error';
       controller1.ApproverComments = 'Rejected for testing';
       controller1.BNF.SAP_Contract__c='9999999999';
       controller1.BNF.SAP_Master_Contract__c='9999999999';
       pg =controller1.Approve();
       Test.stoptest();
    }
    
    static testMethod void AddInvoiceLineItem() {
        MIBNF_Component__c TestMIBNF_Comp = [Select id,name,MIBNF__c, Addendum__c,Is_this_a_retainer_downpayment__c, Print_Shop__c,BNF_Status__c, Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c,
                                             Pass_thru_schedules__c, Retainer_Opportunity_Number__c, Travel_Amount__c, Accomodation_Amount__c, Sub_Contractor_Amount__c, Hono__c,CurrencyIsoCode from MIBNF_Component__c][0];
        Opportunity TestOpp = [Select id,Name,StageName,CloseDate,Budget_Available__c, AccountId,Contract_Term__c,Contract_End_Date__c,Contract_Start_Date__c,Contract_Type__c,LeadSource,CurrencyIsoCode from Opportunity][0];
        
        String SelectProductList = '';
        for(OpportunityLineItem oli: [SELECT Id FROM OpportunityLineItem]){
            SelectProductList += oli.id +',';
        }
        SelectProductList.removeEnd(',');
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('oppid' , TestOpp.id );
        ApexPages.CurrentPage().getParameters().put('revised' ,'1');
        PageReference pageRef = ApexPages.currentPage();
        Test.setCurrentPageReference(pageRef);
        MI_BNF_WizardEx controller = new MI_BNF_WizardEx();
        controller.getMIBNF();
        //controller.getMIBNF_Comp();
        //controller.getMIBNF_LineItem();
        controller.step2();
        
        TestMIBNF_Comp.Pass_thru_schedules__c =null;
        TestMIBNF_Comp.Travel_Amount__c = 1200;
        TestMIBNF_Comp.Retainer_Opportunity_Number__c = null;
        TestMIBNF_Comp.Retainer_Data_Value__c = -400;
        controller.MIBNF_Comp = TestMIBNF_Comp;
        PageReference pg=controller.save();
        
        delete [SELECT id FROM MI_BNF_LineItem__c];
        controller.SelectProductList = SelectProductList;
        controller.AddInvoiceLineItem(TestMIBNF_Comp);
    }
    static testMethod void updateRA() {
        Opportunity TestOpp = [Select id,Name,StageName,CloseDate,Budget_Available__c, AccountId,Contract_Term__c,Contract_End_Date__c,Contract_Start_Date__c,Contract_Type__c,LeadSource,CurrencyIsoCode,Multi_Country_Billing__c from Opportunity][0];
        
        Revenue_Analyst__c revenueAnalyst = new Revenue_Analyst__c(User__c = UserInfo.getUserId(), Name='GFSS RA DE');
        insert revenueAnalyst;
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('oppid' , TestOpp.id );
        MI_BNF_WizardEx controller = new MI_BNF_WizardEx();
        MIBNF2__c TestMIBNF = controller.getMIBNF();
        TestMIBNF.IMS_Sales_Org__c = '[DE82] Kairos GmbH';
        insert TestMIBNF;
        MI_BNF_WizardEx.updateRevenueAnalyst('[DE82] Kairos GmbH');
        TestMIBNF.Contract_Start_Date__c = TestMIBNF.Contract_Start_Date__c.addDays(2); 
        controller.step2();
        Test.StopTest();
    }
}