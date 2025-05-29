@isTest
private class TST_BNF_BillingScheduleController { 
    
    static BNF_BillingScheduleController classObj;
    //static BNF2__c bnf ; 
    static List<opportunity> test_oppList;
    static Integer PROD_SIZE = 5;
    static List<OpportunityLineItem> oliList;
    private static final String ERR_BILLINGPLAN_MISSING ='Please select billing plan pattern.';
    private static final String ERR_NEGATIVE_AMOUNT ='Error:BIllingAmount can not be negative';
    private static final String ERR_ZEROAMOUNT= 'Error:bIlling Amount can not zero';
    private static final String ERR_BILLINGDATE = 'Error: Billing Date of same opportunity Line item can not same '; 
    private static final String ERR_COMPLEVEL_NEGATIVE_AMOUNT = 'Error: Amount can not be negative';
    private static final String ERR_COMPLEVEL_ZEROAMOUNT= 'Error: Amount can not be zero';
    private static final String ERR_TOTALAMOUNT = 'Error while saving schedules: Total amount of Billing schedule Amountcan not more than Opportunity Total amount' ; 
    
    @testSetup static void setupTestData(){
        Global_Variables.PCFlag = false;
        Global_Variables.RunQuickOppLimitTrigger = false;
        Global_Variables.RenewalCloneFlag = TRUE;
        Global_Variables.syncAgreementToOppty=false;
        Global_Variables.PCTrigger_Hault_Execution=false;
        
        Account TestAccount = BNF_Test_Data.createAccount();
        List<Address__c> TestAddress_Array = BNF_Test_Data.createAddress_Array();
        List<SAP_Contact__c> TestSapContact_Array = BNF_Test_Data.createSapContact_Array();
        Opportunity opp = BNF_Test_Data.createOpp();
        BNF_Settings__c bnfsetting = BNF_Test_Data.createBNFSetting();
        Current_Release_Version__c currentReleaseVersionSetting = BNF_Test_Data.createCurrentReleaseVersionSetting();
        List<User_Locale__c> User_LocaleSetting = BNF_Test_Data.create_User_LocaleSetting();
        List<OpportunityLineItem> OLI_Array = BNF_Test_Data.createOppLineItem();
        User u = BNF_Test_Data.createUser();
        Revenue_Analyst__c TestLocalRA = BNF_Test_Data.createRA();
        BNF2__c TestBnf = BNF_Test_Data.createBNF();
        
    }
    
    //**************** to initialize Object of class ================
    static void resetmethod(){ 
        List<BNF2__c> bnfList = new List<BNF2__c>([Select id,name,Opportunity__c,BNF_Status__c,IMS_Sales_Org__c,Sales_Org_Code__c,Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from BNF2__c]);
        Opportunity TestOpp = [Select id,Name,StageName,CloseDate,Budget_Available__c, AccountId,Contract_Term__c,Contract_End_Date__c,Contract_Start_Date__c,Contract_Type__c,LeadSource,CurrencyIsoCode from Opportunity][0];
        
        Id bnfid = bnfList[0].Id;
        PageReference pageRef = new PageReference('Page.BNF_AddBillingSchedule');
        pageRef.getParameters().put('bnfid',bnfid);
        pageRef.getParameters().put('salesOrg',bnfList[0].Sales_Org_Code__c);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdController = new ApexPages.standardController(bnfList[0]); 
        classObj = new BNF_BillingScheduleController(stdController); 
        BNF_BillingScheduleController.getBillingPatterns();
        BNF_BillingScheduleController.getBillingLevels(); 
        
    }
    
    //************to Test calculateSchedules method
    static testMethod void calculateSchedules_testingMethod() { 
        //*************** Calling calculation method****************************
        Test.startTest();
        resetmethod();
        classObj.billingLevel = 'Component Level';
        classObj.billingPattern= '50/50';
        classObj.calculateSchedules();
        
        decimal sumoftotalPrice =0;
        BNF2__c bnf = [Select id,name,Contract_Start_Date__c, Contract_End_Date__c, Opportunity__c,BNF_Status__c,IMS_Sales_Org__c,Sales_Org_Code__c,Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from BNF2__c][0];
        Opportunity opp = [Select id,Name,StageName,CloseDate,Budget_Available__c, AccountId,Contract_Term__c,Contract_End_Date__c,Contract_Start_Date__c,Contract_Type__c,LeadSource,CurrencyIsoCode from Opportunity][0];
        
        List<OpportunityLineitem> oliList1 = [Select Opportunity.CEQActiveRelease__c,Discount_Percentage_Formula__c, PricebookEntry.Name,
                                              PricebookEntry.Product2.Material_Type__c,PricebookEntry.Product2.Offering_Group__c ,Opportunity.Therapy_Area__c,
                                              PricebookEntry.Product2.Offering_Type__c , List_Price__c, Nbr_of_Users__c, Book_No__c,Other_Ship_To_SAP_Contact__c,
                                              CurrencyISOCode,TotalPrice,Delivery_Media__c, Product_Invoice_Text__c, PricebookEntry.ProductCode,PricebookEntry.Product2.Delivery_Media__c,
                                              PricebookEntry.Product2.Delivery_Frequency__c,Other_Ship_To_Address__c,Surcharge_Text__c,
                                              Billing_Frequency__c,Product_Start_Date__c,Product_End_Date__c, Proj_Rpt_Frequency__c,Discount_Reason__c, 
                                              Discount_Amount_Formula__c, Other_Ship_To__c, Billing_Date__c, Sale_Type__c, Revenue_Type__c,PricebookEntry.Product2.Item_Category_Group__c,
                                              Invoice_Lag_to_Data_Period__c, Revised_Price__c,Therapy_Area__c, Cancel__c,Business_Type__c, Delivery_Date__c,PO_Number__c,
                                              Sales_Text__c,Budget_Therapy_Area__c,Project_Start_Date__c,Project_End_Date__c, 
                                              OpportunityId,Billing_Schedule_Error_Msg__c,Revised_Revenue_Schedule__c,Revenue_Schedule_Error_Msg__c From OpportunityLineItem where OpportunityId = :opp.id ];
        for(OpportunityLineItem oli : oliList1){ 
            sumoftotalPrice+= oli.totalPrice;
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
        Integer monthsBetween = bnf.Contract_Start_Date__c.monthsBetween(bnf.Contract_End_Date__c);
        if(monthsBetween < 0) 
            monthsBetween *= (-1);
        
        classObj.billingLevel = 'Component Level';
        classObj.billingPattern= 'QUARTERLY';
        classObj.calculateSchedules();
        monthsBetween = bnf.Contract_Start_Date__c.monthsBetween(bnf.Contract_End_Date__c);
        Decimal quartesBetweenDecimal = monthsBetween/3.00;
        Integer quartesBetween = monthsBetween/3;
        quartesBetween = (quartesBetweenDecimal > quartesBetween)? (quartesBetween + 1) : quartesBetween ;
        if(quartesBetween < 0) 
            quartesBetween *= (-1);
        if(quartesBetween == 0) 
            quartesBetween= 1;
        
        Test.stopTest(); 
        
    }
    
    //************to Test Reset method
    static testMethod void Reset_tesingMethod() {
        Test.startTest();
        resetmethod();
        PageReference page = classObj.crudeReset(); 
        Test.stopTest(); 
    }
    
    //************to Test delete method
    static testmethod void delete_schedule_tesingMethod(){
        
        Test.startTest();
        //********deletion for Opportunity Level
        resetmethod();
        Opportunity opp = [Select id,Name,StageName,CloseDate,Budget_Available__c, AccountId,Contract_Term__c,Contract_End_Date__c,Contract_Start_Date__c,Contract_Type__c,LeadSource,CurrencyIsoCode from Opportunity][0]; 
        List<OpportunityLineitem> oliList1 = [Select Opportunity.CEQActiveRelease__c,Discount_Percentage_Formula__c, PricebookEntry.Name,
                                              PricebookEntry.Product2.Material_Type__c,PricebookEntry.Product2.Offering_Group__c ,Opportunity.Therapy_Area__c,
                                              PricebookEntry.Product2.Offering_Type__c , List_Price__c, Nbr_of_Users__c, Book_No__c,Other_Ship_To_SAP_Contact__c,
                                              CurrencyISOCode,TotalPrice,Delivery_Media__c, Product_Invoice_Text__c, PricebookEntry.ProductCode,PricebookEntry.Product2.Delivery_Media__c,
                                              PricebookEntry.Product2.Delivery_Frequency__c,Other_Ship_To_Address__c,Surcharge_Text__c,
                                              Billing_Frequency__c,Product_Start_Date__c,Product_End_Date__c, Proj_Rpt_Frequency__c,Discount_Reason__c, 
                                              Discount_Amount_Formula__c, Other_Ship_To__c, Billing_Date__c, Sale_Type__c, Revenue_Type__c,PricebookEntry.Product2.Item_Category_Group__c,
                                              Invoice_Lag_to_Data_Period__c, Revised_Price__c,Therapy_Area__c, Cancel__c,Business_Type__c, Delivery_Date__c,PO_Number__c,
                                              Sales_Text__c,Budget_Therapy_Area__c,Project_Start_Date__c,Project_End_Date__c, 
                                              OpportunityId,Billing_Schedule_Error_Msg__c,Revised_Revenue_Schedule__c,Revenue_Schedule_Error_Msg__c From OpportunityLineItem where OpportunityId = :opp.id ];
        
        classObj.billingLevel = 'Opportunity Level';
        classObj.billingPattern= '100% on delivery'; 
        classObj.calculateSchedules();
        Test.stopTest();
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
        for( OpportunityLineItem oli :oliList1){
            oliIdtodelete = oli.Id;
            break;
        }
        classObj.selectedOLIId = oliIdtodelete;
        classObj.selectedIdx = 1;
        classObj.saveOppLevelSchedules(); 
        integer complevel_deletedSchedules_size_before_delete = classObj.deletedSchedules.size();
        classObj.deleteSchedule();
        
    }
    
    //************to Test addOppLevelSchedule method
    static testMethod void addOppLevelSchedule_testingMethod(){
        //**********Adding billing Schedule for Oppolevel 
        
        Test.startTest();
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
        Test.startTest();
        resetmethod();
        classObj.billingLevel = 'Opportunity Level';
        classObj.billingPattern= '-';
        classObj.calculateSchedules();
        Test.stopTest();
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
        List<ApexPages.Message> mssgs2= ApexPages.getMessages();
        for(ApexPages.Message m : mssgs2 ){ 
            if(m.getDetail().contains(ERR_NEGATIVE_AMOUNT))
                errorFound=true; 
        } 
    }
    
    static testmethod void Date_and_other_validation_tesingMethod(){
        Test.startTest();
        resetmethod();
        classObj.billingLevel = 'Opportunity Level';
        classObj.billingPattern= '50/50';
        classObj.calculateSchedules();
        classObj.oliWrapperList[0].schedules[0].scheduleItem.Billing_Amount__c = 0;
        classObj.saveSchedules();
        boolean errorfound = false; 
        List<ApexPages.Message> mssgs= ApexPages.getMessages();
        for(ApexPages.Message m : mssgs ){ 
            if(m.getDetail().contains(ERR_COMPLEVEL_ZEROAMOUNT))
                errorFound=true; 
        }
        
        //********** testing for Billing amount negative
        
        resetmethod();
        classObj.billingLevel = 'Opportunity Level';
        classObj.billingPattern= '50/50';
        classObj.calculateSchedules(); 
        classObj.oliWrapperList[0].schedules[0].scheduleItem.Billing_Amount__c = -500;
        classObj.saveSchedules();
        classObj.SaveOppLvlScheduleListNClose();
        errorfound = false; 
        List<ApexPages.Message> mssgs1 = ApexPages.getMessages();
        for(ApexPages.Message m : mssgs1 ){
            if(m.getDetail().contains(ERR_COMPLEVEL_NEGATIVE_AMOUNT)) 
                errorFound=true; 
        } 
        
        //********* testing Amount greater than Billing amountfor component Level 
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
        //***************Date Validation*********************
        resetmethod();
        classObj.billingLevel = 'Opportunity Level';
        classObj.billingPattern= '50/50'; 
        classObj.calculateSchedules();
        classObj.oliWrapperList[0].schedules[0].scheduleItem.Billing_Date__c = system.today();
        classObj.oliWrapperList[0].schedules[1].scheduleItem.Billing_Date__c = system.today(); 
        classObj.saveSchedules();
        errorfound = false; 
        
        List<ApexPages.Message> mssgs3 = ApexPages.getMessages();
        for(ApexPages.Message m : mssgs3 ){
            if(m.getDetail().contains(ERR_BILLINGDATE ))
                errorFound=true; 
        }
        Test.stopTest();
    }
    
    static testmethod void getExport_TestMethod(){
        Test.startTest();
        List<BNF2__c> bnfList = new List<BNF2__c>([Select id,name,Opportunity__c,BNF_Status__c,IMS_Sales_Org__c,Sales_Org_Code__c,Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from BNF2__c]);
        Opportunity TestOpp = [Select id,Name,StageName,CloseDate,Budget_Available__c, AccountId,Contract_Term__c,Contract_End_Date__c,Contract_Start_Date__c,Contract_Type__c,LeadSource,CurrencyIsoCode from Opportunity][0];
        
        Id bnfid = bnfList[0].Id;
        PageReference pageRef = new PageReference('Page.BNF_AddBillingSchedule');
        pageRef.getParameters().put('bnfid',bnfid);
        pageRef.getParameters().put('salesOrg',bnfList[0].Sales_Org_Code__c);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdController = new ApexPages.standardController(bnfList[0]); 
        classObj = new BNF_BillingScheduleController(stdController); 
        classObj.getExport();
        Test.stopTest();
    }
    
    static testmethod void uploadFile_TestMethod(){
        Test.startTest();
        List<BNF2__c> bnfList = new List<BNF2__c>([Select id,name,Opportunity__c,BNF_Status__c,IMS_Sales_Org__c,Sales_Org_Code__c,Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from BNF2__c]);
        Opportunity TestOpp = [Select id,Name,StageName,CloseDate,Budget_Available__c, AccountId,Contract_Term__c,Contract_End_Date__c,Contract_Start_Date__c,Contract_Type__c,LeadSource,CurrencyIsoCode from Opportunity][0];
      
        Id bnfid = bnfList[0].Id;
        PageReference pageRef = new PageReference('Page.BNF_AddBillingSchedule');
        pageRef.getParameters().put('bnfid',bnfid);
        pageRef.getParameters().put('salesOrg',bnfList[0].Sales_Org_Code__c);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdController = new ApexPages.standardController(bnfList[0]); 
        classObj = new BNF_BillingScheduleController(stdController);
       
        String bscurrencyISOCode = 'Billing Amount (' + TestOpp.CurrencyIsoCode + ')';        
       
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
        Test.startTest();
        List<BNF2__c> bnfList = new List<BNF2__c>([Select id,name,Opportunity__c,BNF_Status__c,IMS_Sales_Org__c,Sales_Org_Code__c,Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from BNF2__c]);
        Opportunity TestOpp = [Select id,Name,StageName,CloseDate,Budget_Available__c, AccountId,Contract_Term__c,Contract_End_Date__c,Contract_Start_Date__c,Contract_Type__c,LeadSource,CurrencyIsoCode from Opportunity][0];
        
        Id bnfid = bnfList[0].Id;
        PageReference pageRef = new PageReference('Page.BNF_AddBillingSchedule');
        pageRef.getParameters().put('bnfid',bnfid);
        pageRef.getParameters().put('salesOrg',bnfList[0].Sales_Org_Code__c);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdController = new ApexPages.standardController(bnfList[0]); 
        classObj = new BNF_BillingScheduleController(stdController);
        
        //incorrect header data - 1
        classObj.excelJsonData = 'Serial Number,OLI Id(Required),Product Name (Optional),Product Code (Optional),Delivery Country,Total Price,Billing Date (mm-dd-yyyy),Billing Amount (USD),Invoice Description,NA,NA'+'\r\n';
        classObj.uploadFile();
        Test.stopTest();
    }  
    
    static testmethod void uploadFile_TestMethod2(){
        Test.startTest();
        List<BNF2__c> bnfList = new List<BNF2__c>([Select id,name,Opportunity__c,BNF_Status__c,IMS_Sales_Org__c,Sales_Org_Code__c,Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from BNF2__c]);
        Opportunity TestOpp = [Select id,Name,StageName,CloseDate,Budget_Available__c, AccountId,Contract_Term__c,Contract_End_Date__c,Contract_Start_Date__c,Contract_Type__c,LeadSource,CurrencyIsoCode from Opportunity][0];
        
        Id bnfid = bnfList[0].Id;
        PageReference pageRef = new PageReference('Page.BNF_AddBillingSchedule');
        pageRef.getParameters().put('bnfid',bnfid);
        pageRef.getParameters().put('salesOrg',bnfList[0].Sales_Org_Code__c);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdController = new ApexPages.standardController(bnfList[0]); 
        classObj = new BNF_BillingScheduleController(stdController);
        
        //incorrect header data - 2
        classObj.excelJsonData = 'Serial Number,OLI Id(Required),Product Name (Optional),Product Code (Optional),Delivery Country,Total Price,Billing Date (mm-dd-yyyy),Billing Amount (USD),Invoice Description,NA'+'\r\n';
        classObj.uploadFile();
        Test.stopTest();
    } 
    
    static testmethod void uploadFile_TestMethod3(){
        Test.startTest();
        List<BNF2__c> bnfList = new List<BNF2__c>([Select id,name,Opportunity__c,BNF_Status__c,IMS_Sales_Org__c,Sales_Org_Code__c,Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from BNF2__c]);
        Opportunity TestOpp = [Select id,Name,StageName,CloseDate,Budget_Available__c, AccountId,Contract_Term__c,Contract_End_Date__c,Contract_Start_Date__c,Contract_Type__c,LeadSource,CurrencyIsoCode from Opportunity][0];
        
        Id bnfid = bnfList[0].Id;
        PageReference pageRef = new PageReference('Page.BNF_AddBillingSchedule');
        pageRef.getParameters().put('bnfid',bnfid);
        pageRef.getParameters().put('salesOrg',bnfList[0].Sales_Org_Code__c);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdController = new ApexPages.standardController(bnfList[0]); 
        classObj = new BNF_BillingScheduleController(stdController);
        
        classObj.excelJsonData = 'Serial Num,OLI Id(Required),Product Name (Optional),Product Code (Optional),Delivery Country,Total Price,Billing Date (mm-dd-yyyy),Billing Amount (USD),Invoice Description'+'\r\n';
        classObj.excelJsonData += '1,' + classObj.oliWrapperList[0].oli.Id + ',' + classObj.oliWrapperList[0].oli.PricebookEntry.Product2.Name + ',' + classObj.oliWrapperList[0].oli.PricebookEntry.Product2.ProductCode + ',' + classObj.oliWrapperList[0].oli.Delivery_Country__c;
        classObj.excelJsonData += ',' + classObj.oliWrapperList[0].oli.TotalPrice + ',' + classObj.oliWrapperList[0].oli.Product_Start_Date__c + ',' + classObj.oliWrapperList[0].oli.TotalPrice + ',' +'Invoice desc Test' + '\n';
        classObj.uploadFile();
        Test.stopTest();
    } 
    
    static testmethod void uploadFile_TestMethod4(){
        Test.startTest();
        List<BNF2__c> bnfList = new List<BNF2__c>([Select id,name,Opportunity__c,BNF_Status__c,IMS_Sales_Org__c,Sales_Org_Code__c,Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from BNF2__c]);
        Opportunity TestOpp = [Select id,Name,StageName,CloseDate,Budget_Available__c, AccountId,Contract_Term__c,Contract_End_Date__c,Contract_Start_Date__c,Contract_Type__c,LeadSource,CurrencyIsoCode from Opportunity][0];
        
        Id bnfid = bnfList[0].Id;
        PageReference pageRef = new PageReference('Page.BNF_AddBillingSchedule');
        pageRef.getParameters().put('bnfid',bnfid);
        pageRef.getParameters().put('salesOrg',bnfList[0].Sales_Org_Code__c);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdController = new ApexPages.standardController(bnfList[0]); 
        classObj = new BNF_BillingScheduleController(stdController);
        
        classObj.excelJsonData = 'Serial Number,OLI Id(Require),Product Name (Optional),Product Code (Optional),Delivery Country,Total Price,Billing Date (mm-dd-yyyy),Billing Amount (USD),Invoice Description'+'\r\n';
        classObj.excelJsonData += '1,' + classObj.oliWrapperList[0].oli.Id + ',' + classObj.oliWrapperList[0].oli.PricebookEntry.Product2.Name + ',' + classObj.oliWrapperList[0].oli.PricebookEntry.Product2.ProductCode + ',' + classObj.oliWrapperList[0].oli.Delivery_Country__c;
        classObj.excelJsonData += ',' + classObj.oliWrapperList[0].oli.TotalPrice + ',' + classObj.oliWrapperList[0].oli.Product_Start_Date__c + ',' + classObj.oliWrapperList[0].oli.TotalPrice + ',' +'Invoice desc Test' + '\n';
        classObj.uploadFile();
        Test.stopTest();
    } 
    
    static testmethod void uploadFile_TestMethod5(){
        Test.startTest();
        List<BNF2__c> bnfList = new List<BNF2__c>([Select id,name,Opportunity__c,BNF_Status__c,IMS_Sales_Org__c,Sales_Org_Code__c,Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from BNF2__c]);
        Opportunity TestOpp = [Select id,Name,StageName,CloseDate,Budget_Available__c, AccountId,Contract_Term__c,Contract_End_Date__c,Contract_Start_Date__c,Contract_Type__c,LeadSource,CurrencyIsoCode from Opportunity][0];
        
        Id bnfid = bnfList[0].Id;
        PageReference pageRef = new PageReference('Page.BNF_AddBillingSchedule');
        pageRef.getParameters().put('bnfid',bnfid);
        pageRef.getParameters().put('salesOrg',bnfList[0].Sales_Org_Code__c);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdController = new ApexPages.standardController(bnfList[0]); 
        classObj = new BNF_BillingScheduleController(stdController);
        
        classObj.excelJsonData = 'Serial Number,OLI Id(Required),Product Name (Option),Product Code (Optional),Delivery Country,Total Price,Billing Date (mm-dd-yyyy),Billing Amount (USD),Invoice Description'+'\r\n';
        classObj.excelJsonData += '1,' + classObj.oliWrapperList[0].oli.Id + ',' + classObj.oliWrapperList[0].oli.PricebookEntry.Product2.Name + ',' + classObj.oliWrapperList[0].oli.PricebookEntry.Product2.ProductCode + ',' + classObj.oliWrapperList[0].oli.Delivery_Country__c;
        classObj.excelJsonData += ',' + classObj.oliWrapperList[0].oli.TotalPrice + ',' + classObj.oliWrapperList[0].oli.Product_Start_Date__c + ',' + classObj.oliWrapperList[0].oli.TotalPrice + ',' +'Invoice desc Test' + '\n';
        classObj.uploadFile();
        Test.stopTest();
    } 
    
    static testmethod void uploadFile_TestMethod6(){
        Test.startTest();
        List<BNF2__c> bnfList = new List<BNF2__c>([Select id,name,Opportunity__c,BNF_Status__c,IMS_Sales_Org__c,Sales_Org_Code__c,Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from BNF2__c]);
        Opportunity TestOpp = [Select id,Name,StageName,CloseDate,Budget_Available__c, AccountId,Contract_Term__c,Contract_End_Date__c,Contract_Start_Date__c,Contract_Type__c,LeadSource,CurrencyIsoCode from Opportunity][0];
        
        Id bnfid = bnfList[0].Id;
        PageReference pageRef = new PageReference('Page.BNF_AddBillingSchedule');
        pageRef.getParameters().put('bnfid',bnfid);
        pageRef.getParameters().put('salesOrg',bnfList[0].Sales_Org_Code__c);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdController = new ApexPages.standardController(bnfList[0]); 
        classObj = new BNF_BillingScheduleController(stdController);
        
        classObj.excelJsonData = 'Serial Number,OLI Id(Required),Product Name (Optional),Product Code (Option),Delivery Country,Total Price,Billing Date (mm-dd-yyyy),Billing Amount (USD),Invoice Description'+'\r\n';
        classObj.excelJsonData += '1,' + classObj.oliWrapperList[0].oli.Id + ',' + classObj.oliWrapperList[0].oli.PricebookEntry.Product2.Name + ',' + classObj.oliWrapperList[0].oli.PricebookEntry.Product2.ProductCode + ',' + classObj.oliWrapperList[0].oli.Delivery_Country__c;
        classObj.excelJsonData += ',' + classObj.oliWrapperList[0].oli.TotalPrice + ',' + classObj.oliWrapperList[0].oli.Product_Start_Date__c + ',' + classObj.oliWrapperList[0].oli.TotalPrice + ',' +'Invoice desc Test' + '\n';
        classObj.uploadFile();
        Test.stopTest();
    } 
    
    static testmethod void uploadFile_TestMethod7(){
        Test.startTest();
        List<BNF2__c> bnfList = new List<BNF2__c>([Select id,name,Opportunity__c,BNF_Status__c,IMS_Sales_Org__c,Sales_Org_Code__c,Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from BNF2__c]);
        Opportunity TestOpp = [Select id,Name,StageName,CloseDate,Budget_Available__c, AccountId,Contract_Term__c,Contract_End_Date__c,Contract_Start_Date__c,Contract_Type__c,LeadSource,CurrencyIsoCode from Opportunity][0];
        
        Id bnfid = bnfList[0].Id;
        PageReference pageRef = new PageReference('Page.BNF_AddBillingSchedule');
        pageRef.getParameters().put('bnfid',bnfid);
        pageRef.getParameters().put('salesOrg',bnfList[0].Sales_Org_Code__c);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdController = new ApexPages.standardController(bnfList[0]); 
        classObj = new BNF_BillingScheduleController(stdController);
        
        classObj.excelJsonData = 'Serial Number,OLI Id(Required),Product Name (Optional),Product Code (Optional),Deliry Count,Total Price,Billing Date (mm-dd-yyyy),Billing Amount (USD),Invoice Description'+'\r\n';
        classObj.excelJsonData += '1,' + classObj.oliWrapperList[0].oli.Id + ',' + classObj.oliWrapperList[0].oli.PricebookEntry.Product2.Name + ',' + classObj.oliWrapperList[0].oli.PricebookEntry.Product2.ProductCode + ',' + classObj.oliWrapperList[0].oli.Delivery_Country__c;
        classObj.excelJsonData += ',' + classObj.oliWrapperList[0].oli.TotalPrice + ',' + classObj.oliWrapperList[0].oli.Product_Start_Date__c + ',' + classObj.oliWrapperList[0].oli.TotalPrice + ',' +'Invoice desc Test' + '\n';
        classObj.uploadFile();
        Test.stopTest();
    } 
    
    static testmethod void uploadFile_TestMethod8(){
        Test.startTest();
        List<BNF2__c> bnfList = new List<BNF2__c>([Select id,name,Opportunity__c,BNF_Status__c,IMS_Sales_Org__c,Sales_Org_Code__c,Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from BNF2__c]);
        Opportunity TestOpp = [Select id,Name,StageName,CloseDate,Budget_Available__c, AccountId,Contract_Term__c,Contract_End_Date__c,Contract_Start_Date__c,Contract_Type__c,LeadSource,CurrencyIsoCode from Opportunity][0];
        
        Id bnfid = bnfList[0].Id;
        PageReference pageRef = new PageReference('Page.BNF_AddBillingSchedule');
        pageRef.getParameters().put('bnfid',bnfid);
        pageRef.getParameters().put('salesOrg',bnfList[0].Sales_Org_Code__c);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdController = new ApexPages.standardController(bnfList[0]); 
        classObj = new BNF_BillingScheduleController(stdController);
        
        classObj.excelJsonData = 'Serial Number,OLI Id(Required),Product Name (Optional),Product Code (Optional),Delivery Country,Total,Billing Date (mm-dd-yyyy),Billing Amount (USD),Invoice Description'+'\r\n';
        classObj.excelJsonData += '1,' + classObj.oliWrapperList[0].oli.Id + ',' + classObj.oliWrapperList[0].oli.PricebookEntry.Product2.Name + ',' + classObj.oliWrapperList[0].oli.PricebookEntry.Product2.ProductCode + ',' + classObj.oliWrapperList[0].oli.Delivery_Country__c;
        classObj.excelJsonData += ',' + classObj.oliWrapperList[0].oli.TotalPrice + ',' + classObj.oliWrapperList[0].oli.Product_Start_Date__c + ',' + classObj.oliWrapperList[0].oli.TotalPrice + ',' +'Invoice desc Test' + '\n';
        classObj.uploadFile();
        Test.stopTest();
    }
    
    static testmethod void uploadFile_TestMethod9(){
        Test.startTest();
        List<BNF2__c> bnfList = new List<BNF2__c>([Select id,name,Opportunity__c,BNF_Status__c,IMS_Sales_Org__c,Sales_Org_Code__c,Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from BNF2__c]);
        Opportunity TestOpp = [Select id,Name,StageName,CloseDate,Budget_Available__c, AccountId,Contract_Term__c,Contract_End_Date__c,Contract_Start_Date__c,Contract_Type__c,LeadSource,CurrencyIsoCode from Opportunity][0];
        
        Id bnfid = bnfList[0].Id;
        PageReference pageRef = new PageReference('Page.BNF_AddBillingSchedule');
        pageRef.getParameters().put('bnfid',bnfid);
        pageRef.getParameters().put('salesOrg',bnfList[0].Sales_Org_Code__c);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdController = new ApexPages.standardController(bnfList[0]); 
        classObj = new BNF_BillingScheduleController(stdController);
        
        classObj.excelJsonData = 'Serial Number,OLI Id(Required),Product Name (Optional),Product Code (Optional),Delivery Country,Total Price,Billing Date (mm-dd-),Billing Amount (USD),Invoice Description'+'\r\n';
        classObj.excelJsonData += '1,' + classObj.oliWrapperList[0].oli.Id + ',' + classObj.oliWrapperList[0].oli.PricebookEntry.Product2.Name + ',' + classObj.oliWrapperList[0].oli.PricebookEntry.Product2.ProductCode + ',' + classObj.oliWrapperList[0].oli.Delivery_Country__c;
        classObj.excelJsonData += ',' + classObj.oliWrapperList[0].oli.TotalPrice + ',' + classObj.oliWrapperList[0].oli.Product_Start_Date__c + ',' + classObj.oliWrapperList[0].oli.TotalPrice + ',' +'Invoice desc Test' + '\n';
        classObj.uploadFile();
        Test.stopTest();
    } 
    
    static testmethod void uploadFile_TestMethod10(){
        Test.startTest();
        List<BNF2__c> bnfList = new List<BNF2__c>([Select id,name,Opportunity__c,BNF_Status__c,IMS_Sales_Org__c,Sales_Org_Code__c,Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from BNF2__c]);
        Opportunity TestOpp = [Select id,Name,StageName,CloseDate,Budget_Available__c, AccountId,Contract_Term__c,Contract_End_Date__c,Contract_Start_Date__c,Contract_Type__c,LeadSource,CurrencyIsoCode from Opportunity][0];
        
        Id bnfid = bnfList[0].Id;
        PageReference pageRef = new PageReference('Page.BNF_AddBillingSchedule');
        pageRef.getParameters().put('bnfid',bnfid);
        pageRef.getParameters().put('salesOrg',bnfList[0].Sales_Org_Code__c);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdController = new ApexPages.standardController(bnfList[0]); 
        classObj = new BNF_BillingScheduleController(stdController);
        
        classObj.excelJsonData = 'Serial Number,OLI Id(Required),Product Name (Optional),Product Code (Optional),Delivery Country,Total Price,Billing Date (mm-dd-yyyy),Billing Amount(),Invoice Description'+'\r\n';
        classObj.excelJsonData += '1,' + classObj.oliWrapperList[0].oli.Id + ',' + classObj.oliWrapperList[0].oli.PricebookEntry.Product2.Name + ',' + classObj.oliWrapperList[0].oli.PricebookEntry.Product2.ProductCode + ',' + classObj.oliWrapperList[0].oli.Delivery_Country__c;
        classObj.excelJsonData += ',' + classObj.oliWrapperList[0].oli.TotalPrice + ',' + classObj.oliWrapperList[0].oli.Product_Start_Date__c + ',' + classObj.oliWrapperList[0].oli.TotalPrice + ',' +'Invoice desc Test' + '\n';
        classObj.uploadFile();
        Test.stopTest();
    } 
    
    static testmethod void uploadFile_TestMethod11(){
        Test.startTest();
        List<BNF2__c> bnfList = new List<BNF2__c>([Select id,name,Opportunity__c,BNF_Status__c,IMS_Sales_Org__c,Sales_Org_Code__c,Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from BNF2__c]);
        Opportunity TestOpp = [Select id,Name,StageName,CloseDate,Budget_Available__c, AccountId,Contract_Term__c,Contract_End_Date__c,Contract_Start_Date__c,Contract_Type__c,LeadSource,CurrencyIsoCode from Opportunity][0];
        
        Id bnfid = bnfList[0].Id;
        PageReference pageRef = new PageReference('Page.BNF_AddBillingSchedule');
        pageRef.getParameters().put('bnfid',bnfid);
        pageRef.getParameters().put('salesOrg',bnfList[0].Sales_Org_Code__c);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdController = new ApexPages.standardController(bnfList[0]); 
        classObj = new BNF_BillingScheduleController(stdController);
        
        classObj.excelJsonData = 'Serial Number,OLI Id(Required),Product Name (Optional),Product Code (Optional),Delivery Country,Total Price,Billing Date (mm-dd-yyyy),Billing Amount (USD),Invoice Descri'+'\r\n';
        classObj.excelJsonData += '1,' + classObj.oliWrapperList[0].oli.Id + ',' + classObj.oliWrapperList[0].oli.PricebookEntry.Product2.Name + ',' + classObj.oliWrapperList[0].oli.PricebookEntry.Product2.ProductCode + ',' + classObj.oliWrapperList[0].oli.Delivery_Country__c;
        classObj.excelJsonData += ',' + classObj.oliWrapperList[0].oli.TotalPrice + ',' + classObj.oliWrapperList[0].oli.Product_Start_Date__c + ',' + classObj.oliWrapperList[0].oli.TotalPrice + ',' +'Invoice desc Test' + '\n';
        classObj.uploadFile();
        Test.stopTest();
    }
}