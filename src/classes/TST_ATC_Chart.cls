@isTest
public class TST_ATC_Chart {
    private static date strtDate = date.newInstance(2012, 1, 1);
    private static date endDate = date.newInstance(2012, 12, 31); 
    private static String testAccountID;  
    public static Integer count;
    private static ATC_Chart_Excel testclassDataExcel;
    private static User u;
    
    public static void setupData(){ 
        //Added by Najma Ateeq to fix data issue 
        Id atcRecordTypeID = ConstantClass.getRecordTypeId('ATC__c','ATC');
        List<Account> testAccounts = new List<Account>();
        Account testacc1 = new Account(Name = 'TestAccountNameForSCM1',CurrencyIsoCode = 'USD',Region_Territory__c = 'India',Industry_IMS__c = 'Biotech',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        testAccounts.add(testacc1);
        Account testacc2 = new Account(Name = 'TestAccountNameForSCM2',CurrencyIsoCode = 'USD',Region_Territory__c = 'India',Industry_IMS__c = 'Biotech',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        testAccounts.add(testacc2);
        Account testAtcChartAcc1 = new Account(Name = 'testAtcChartAcc1',CurrencyIsoCode = 'USD',Region_Territory__c = 'India',Industry_IMS__c = 'Biotech',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        testAccounts.add(testAtcChartAcc1);
        Account testAggAccount1 = new Account(Name = 'IMS Health Global',CurrencyIsoCode = 'USD',Region_Territory__c = 'India',Industry_IMS__c = 'Biotech',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        testAccounts.add(testAggAccount1);
        insert testAccounts;
        
        List<ATC__c> testATCs = new List<ATC__c>();
        ATC__c atc1 = new ATC__c(ATC_Code__c = 'J07C',CurrencyIsoCode= 'USD',RecordTypeId = atcRecordTypeID);
        testATCs.add(atc1);
        ATC__c atc2 = new ATC__c(ATC_Code__c = 'XYZ1234',CurrencyIsoCode= 'USD');
        testATCs.add(atc2);
        insert testATCs;
        
        List<Product2> testProducts = new List<Product2>();
        Product2 testproduct1 = new Product2(Name = 'tstpro1',CurrencyIsoCode = 'USD',Material_Type__c = 'ZPUB');
        testProducts.add(testproduct1);
        Product2 testproduct2 = new Product2(Name = 'tstpro2',CurrencyIsoCode = 'USD',Material_Type__c = 'ZPUB');
        testProducts.add(testproduct2);
        insert testProducts;
        
        List<Agreement__c> testAgreements = new List<Agreement__c>();
        Agreement__c testAgreementAPTS2 = new Agreement__c(Name ='testAgree2',Account__c = testacc1.id,Active__c = false,Company_Signed_Date__c = strtDate,Contract_Start_Date__c = strtDate.addDays(2),Contract_Type__c = 'CES Memorandum',Agreement_Term__c = 'Ad-Hoc'); 
        testAgreements.add(testAgreementAPTS2);
        Agreement__c testAgreementAPTS1 = new Agreement__c(Name ='testAgree1',Account__c = testacc1.id,Active__c = true,Company_Signed_Date__c = Date.Today().addDays(2),Parent_Agreement__c = testAgreementAPTS2.Id); 
        testAgreements.add(testAgreementAPTS1);
        Agreement__c ATCChart_testAgreementAPTS1 = new Agreement__c(Name ='testAgree3',Account__c = testAtcChartAcc1.id,Active__c = true,Company_Signed_Date__c = date.newInstance(2012,1,1),Contract_Start_Date__c =date.newInstance(2012,1,1),Contract_Type__c = 'CES Memorandum',Agreement_Term__c = 'Ad-Hoc'); 
        testAgreements.add(ATCChart_testAgreementAPTS1);
        Agreement__c AggLocator_testAgreementAPTS1 = new Agreement__c(Name ='testAgree4',Account__c = testAggAccount1.id,Active__c = true,Company_Signed_Date__c = date.newInstance(2012,1,1),Contract_Start_Date__c =date.newInstance(2012,1,1),Contract_End_Date__c = date.newInstance(2012,1,1)  ,Contract_Type__c = 'CES Memorandum',Agreement_Term__c = 'Ad-Hoc'); 
        testAgreements.add(AggLocator_testAgreementAPTS1);
        Agreement__c AggWarning_testAgreement1 = new Agreement__c(Name ='testAgree5',Account__c = testAggAccount1.id,Active__c = true,Company_Signed_Date__c = date.newInstance(2012,1,1),Contract_Start_Date__c =date.newInstance(2012,1,1),Contract_End_Date__c = date.newInstance(2012,1,1)  ,Contract_Type__c = 'CES Memorandum',Agreement_Term__c = 'Ad-Hoc'); 
        testAgreements.add(AggWarning_testAgreement1);
        Agreement__c ATCChart_testAgreementAPTS2 = new Agreement__c(Name ='testAgree6',Account__c = testAtcChartAcc1.id,Active__c = true,Company_Signed_Date__c = date.newInstance(2012,1,1),Contract_Start_Date__c =date.newInstance(2011,1,1),Contract_Type__c = 'CES Memorandum',Agreement_Term__c = 'Ad-Hoc'); 
        testAgreements.add(ATCChart_testAgreementAPTS2);
        insert testAgreements;
        
        List<Agreement_Line_Item__c> testAgreementLineItems = new List<Agreement_Line_Item__c>();
        Agreement_Line_Item__c testLineItem1 = new Agreement_Line_Item__c(AgreementId__c =testAgreementAPTS1.Id,Additional_Price__c = 0,ExtendedPrice__c = 0,List_Price__c = 0,Net_Price__c= 0,ProductId__c = testproduct1.id,Quantity__c = 0,Contract_Start_Date__c=date.newInstance(2012,7,6)) ;
        testAgreementLineItems.add(testLineItem1);
        Agreement_Line_Item__c ATCChart_testLineItem1 = new Agreement_Line_Item__c(AgreementId__c =ATCChart_testAgreementAPTS1.Id,Additional_Price__c = 0,ExtendedPrice__c = 0,List_Price__c = 0,Net_Price__c= 0,ProductId__c = testproduct1.id,Quantity__c = 0,Contract_Start_Date__c=date.newInstance(2012,7,5)) ;
        testAgreementLineItems.add(ATCChart_testLineItem1);
        Agreement_Line_Item__c AggLocator_testLineItem1 = new Agreement_Line_Item__c(AgreementId__c =AggLocator_testAgreementAPTS1.Id,Additional_Price__c = 0,ExtendedPrice__c = 0,List_Price__c = 0,Net_Price__c= 0,ProductId__c = testproduct1.id,Quantity__c = 0,Contract_Start_Date__c=date.newInstance(2012,6,5)) ;
        testAgreementLineItems.add(AggLocator_testLineItem1);
        Agreement_Line_Item__c AggLocator_testLineItemWIthoutATC1 = new Agreement_Line_Item__c(AgreementId__c =AggLocator_testAgreementAPTS1.Id,Additional_Price__c = 0,ExtendedPrice__c = 0,List_Price__c = 0,Net_Price__c= 0,ProductId__c = testproduct1.id,Quantity__c = 0,Contract_Start_Date__c=date.newInstance(2012,6,5)) ;
        testAgreementLineItems.add(AggLocator_testLineItemWIthoutATC1);
        Agreement_Line_Item__c ATCChart_testLineItem2 = new Agreement_Line_Item__c(AgreementId__c = ATCChart_testAgreementAPTS2.Id,Additional_Price__c = 0,ExtendedPrice__c = 0,List_Price__c = 0,Net_Price__c= 0,ProductId__c = testproduct1.id,Quantity__c = 0,Contract_Start_Date__c=date.newInstance(2012,6,5)) ;
        testAgreementLineItems.add(ATCChart_testLineItem2);
        Agreement_Line_Item__c AggWarning_testLineItem1 = new Agreement_Line_Item__c(AgreementId__c = AggWarning_testAgreement1.Id,Additional_Price__c = 0,ExtendedPrice__c = 0,List_Price__c = 0,Net_Price__c= 0,ProductId__c = testproduct1.id,Quantity__c = 0,Contract_Start_Date__c=date.newInstance(2012,6,5),SCM_Fee_ScheduleLabel__c = 'test market defs',Apts_Delivery_Frequency__c = 'Ad-hoc',Apts_Delivery_Format__c = 'CD',Apts_Offering_Option__c = 'Basic',APTPS_Historical_Data__c = 'Four (4) Data Quarters', Back_Data__c = 'Four (4) Data Quarters',Data_Level__c = 'District Summary',Apts_Channel__c = 'Clinics',Line_item_date_type__c='Data dates',Data_Month_Start__c=date.newInstance(2012,6,5),Data_Month_End__c=date.newInstance(2012,6,5));
        testAgreementLineItems.add(AggWarning_testLineItem1);
        Agreement_Line_Item__c AggWarning_testLineItem_missSelectdMktDef = new Agreement_Line_Item__c(AgreementId__c = AggWarning_testAgreement1.Id, Additional_Price__c = 0, ExtendedPrice__c = 0, List_Price__c = 0, Net_Price__c= 0, ProductId__c = testproduct1.id, Quantity__c = 0, Contract_Start_Date__c = date.newInstance(2012,6,5), SCM_Fee_ScheduleLabel__c = 'test market defs', Apts_Delivery_Frequency__c = 'Ad-hoc', Apts_Delivery_Format__c = 'CD', Apts_Offering_Option__c = 'Basic', APTPS_Historical_Data__c = 'Four (4) Data Quarters', Back_Data__c = 'Four (4) Data Quarters', Apts_Market_Definitions__c = 'test market defs', Market_Definition_Options__c = 'Selected Market Defs');
        testAgreementLineItems.add(AggWarning_testLineItem_missSelectdMktDef); 
        insert testAgreementLineItems;
        
        List<Agreement_Line_Item_ATCs__c> testAgreementLineItemATCs = new List<Agreement_Line_Item_ATCs__c>();
        Agreement_Line_Item_ATCs__c ATEChart_testLineItemATC1 = new Agreement_Line_Item_ATCs__c(ATC__c = atc1.id, Agreement_Line_Item__C = ATCChart_testLineItem1.id,Data_Period_Start__c = strtDate.addDays(2) ,Data_Period_End__c = endDate,Non_Charge_deliver_of_ATC__c = true,Period_of_Non_Charge_Deliver_Start__c = strtDate,Period_of_Non_Charge_Deliver_End__c = endDate,Termination_Date__c = strtDate.addDays(2));
        testAgreementLineItemATCs.add(ATEChart_testLineItemATC1);
        Agreement_Line_Item_ATCs__c ATEChart_testLineItemATC2 = new Agreement_Line_Item_ATCs__c(ATC__c = atc1.id, Agreement_Line_Item__C = ATCChart_testLineItem1.id,Data_Period_Start__c = strtDate.addDays(2) ,Data_Period_End__c = endDate,Non_Charge_deliver_of_ATC__c = true,Period_of_Non_Charge_Deliver_Start__c = strtDate,Period_of_Non_Charge_Deliver_End__c = endDate);  
        testAgreementLineItemATCs.add(ATEChart_testLineItemATC2);
        Agreement_Line_Item_ATCs__c ATEChart_testLineItemATC3 = new Agreement_Line_Item_ATCs__c(ATC__c = atc1.id, Agreement_Line_Item__C = ATCChart_testLineItem1.id,Data_Period_Start__c = strtDate.addDays(1) ,Data_Period_End__c = endDate,Non_Charge_deliver_of_ATC__c = true,Period_of_Non_Charge_Deliver_Start__c = strtDate.addDays(2),Period_of_Non_Charge_Deliver_End__c = endDate);  
        testAgreementLineItemATCs.add(ATEChart_testLineItemATC3);
        Agreement_Line_Item_ATCs__c ATEChart_testLineItemATC4 = new Agreement_Line_Item_ATCs__c(ATC__c = atc1.id, Agreement_Line_Item__C = ATCChart_testLineItem1.id,Data_Period_Start__c = strtDate.addDays(1) ,Data_Period_End__c = endDate,Non_Charge_deliver_of_ATC__c = false,Period_of_Non_Charge_Deliver_Start__c = Null,Period_of_Non_Charge_Deliver_End__c = Null,Termination_Date__c = strtDate.addDays(2));  
        testAgreementLineItemATCs.add(ATEChart_testLineItemATC4);
        insert testAgreementLineItemATCs;
    }
    
    public static void setUpUser() {
        Profile p = [select id from profile where name='System administrator'];
        u = new User (
            alias               = 'testUser',
            email               = 'SCMstandarduser@metacube.com',
            emailencodingkey    = 'UTF-8', 
            lastname            = 'Testing',
            languagelocalekey   = 'en_US',
            localesidkey        = 'en_US',
            profileid           = p.Id,
            timezonesidkey      = 'America/Los_Angeles', 
            username            = 'SCMteststandarduser@testorg.com',
            IsActive            = true
        );
        insert u;
        
        Contract_Management_Setting__c contractMgmt = new Contract_Management_Setting__c();
        contractMgmt.Perform_SCM_Functions_Flag__c = true;
        insert contractMgmt ;
    }
    
    public static testMethod void TestCase1(){ 
        setupData();
        Agreement__c ATCChart_testAgreementAPTS1 = [SELECT id, Name FROM Agreement__c WHERE Name='testAgree3'];
        Account testAtcChartAcc1 = [SELECT id FROM Account WHERE name='testAtcChartAcc1'];
        test.startTest();     
        ApexPages.StandardController  sc = new ApexPages.StandardController(ATCChart_testAgreementAPTS1);
        ATC_Chart testAtcChart= new ATC_Chart();
        testAtcChart.aTCodeCriteria = 'J07C*';
        testAtcChart.dataPeriodStart = strtDate ;
        testAtcChart.dataPeriodEnd = endDate ;
        testAtcChart.AccountId = testAtcChartAcc1.Id;
        testAtcChart.AssignAccount();
        testAtcChart.Non_Chargedeliverof_ATC = true;
        testAtcChart.LoadProducts();
        testAtcChart.ProductId = testAtcChart.lstProducts.get(0).getValue();
        testAtcChart.searchResults();
        testAtcChart.Non_Chargedeliverof_ATC = false;
        testAtcChart.aTCodeCriteria = 'J07C';
        testAtcChart.searchResults();
        
        string qryStr =  '?';
        qryStr = qryStr + 'stDate=' + strtDate ;
        qryStr = qryStr + '&endDate=' + endDate  ;
        qryStr = qryStr + '&accId=' + '' ;
        qryStr = qryStr + '&view=' + 'Product' ;
        qryStr = qryStr + '&atcCode=' + 'J07C*' ;
        qryStr = qryStr + '&Non_Chargedeliverof_ATC='+false;
        qryStr = qryStr + '&SelectedProducts=' + ''; 
        
        PageReference ref = new PageReference('/apex/ATC_Chart_Excel' + qryStr);
        Test.setCurrentPage(ref ); 
        testclassDataExcel = new ATC_Chart_Excel(sc);
        
        qryStr =  '?';
        qryStr = qryStr + 'stDate=' + strtDate ;
        qryStr = qryStr + '&endDate=' + endDate  ;
        qryStr = qryStr + '&accId=' + '' ;
        qryStr = qryStr + '&view=' + 'Product' ;
        qryStr = qryStr + '&atcCode=' + 'J07C' ;
        qryStr = qryStr + '&Non_Chargedeliverof_ATC='+false;
        qryStr = qryStr + '&SelectedProducts=' + ''; 
        
        ref = new PageReference('/apex/ATC_Chart_Excel' + qryStr);
        Test.setCurrentPage(ref ); 
        testclassDataExcel = new ATC_Chart_Excel(sc);
        
        qryStr =  '?';
        qryStr = qryStr + 'stDate=' + strtDate ;
        qryStr = qryStr + '&endDate=' + endDate  ;
        qryStr = qryStr + '&accId=' + '' ;
        qryStr = qryStr + '&view=' + 'Product' ;
        qryStr = qryStr + '&atcCode=' + '' ;
        qryStr = qryStr + '&Non_Chargedeliverof_ATC='+false;
        qryStr = qryStr + '&SelectedProducts=' + ''; 
        ref = new PageReference('/apex/ATC_Chart_Excel' + qryStr);
        Test.setCurrentPage(ref ); 
        testclassDataExcel = new ATC_Chart_Excel(sc);
        test.stopTest(); 
    }
    
    public static testMethod void TestCase2(){ 
        setupData();
        Agreement__c ATCChart_testAgreementAPTS1 = [SELECT id, Name FROM Agreement__c WHERE Name='testAgree3'];
        Account testAtcChartAcc1 = [SELECT id FROM Account WHERE name='testAtcChartAcc1'];
        test.startTest(); 
        ApexPages.StandardController  sc = new ApexPages.StandardController(ATCChart_testAgreementAPTS1);
        ATC_Chart testAtcChart= new ATC_Chart();
        
        testAtcChart.aTCodeCriteria = 'J07C*';
        testAtcChart.dataPeriodStart = date.newInstance(2012, 1, 1); 
        testAtcChart.dataPeriodEnd =  date.newInstance(2012, 12, 3);
        testAccountID = testAtcChartAcc1.Id;
        testAtcChart.AccountId = testAccountID ;
        testAtcChart.AssignAccount();
        testAtcChart.LoadProducts();
        testAtcChart.ProductId = testAtcChart.lstProducts.get(0).getValue(); 
        
        testAtcChart.searchResults();
        testAtcChart.aTCodeCriteria = 'J07C';
        testAtcChart.searchResults();
        
        /************************************************************test case for ATC_Chart_Excel class ***********************************************/
        
        string qryStr =  '?';
        //Update by: Sneha Date: 20 feb, 2012 -- Object Permission fix for date fields
        qryStr = qryStr + 'stDate=' + strtDate ;
        qryStr = qryStr + '&endDate=' + endDate  ;
        qryStr = qryStr + '&accId=' + '' ;
        qryStr = qryStr + '&view=' + 'Product' ;
        qryStr = qryStr + '&atcCode=' + 'J07C$' ; //doller will be converted to %;
        qryStr = qryStr + '&Non_Chargedeliverof_ATC='+'false';
        // qryStr = qryStr + '&SelectedProducts=' + testAtcChart.lstProducts.get(0).getValue(); 
        
        PageReference ref = new PageReference('/apex/ATC_Chart_Excel' + qryStr);
        Test.setCurrentPage(ref ); 
        testclassDataExcel = new ATC_Chart_Excel(sc);
        qryStr =  '?';
        //Update by: Sneha Date: 20 feb, 2012 -- Object Permission fix for date fields
        qryStr = qryStr + 'stDate=' + strtDate ;
        qryStr = qryStr + '&endDate=' + endDate  ;
        qryStr = qryStr + '&accId=' + '' ;
        qryStr = qryStr + '&view=' + 'Product' ;
        qryStr = qryStr + '&atcCode=' + '' ;
        qryStr = qryStr + '&Non_Chargedeliverof_ATC='+false;
        ref = new PageReference('/apex/ATC_Chart_Excel' + qryStr);
        Test.setCurrentPage(ref ); 
        testclassDataExcel = new ATC_Chart_Excel(sc);
        test.stopTest(); 
        //system.assertEquals(1,testAtcChart.lstDataWrapper.size());
    } 
    public static testMethod void TestCase3(){ 
        setupData();
        Agreement__c ATCChart_testAgreementAPTS1 = [SELECT id, Name FROM Agreement__c WHERE Name='testAgree3'];
        Account testAtcChartAcc1 = [SELECT id FROM Account WHERE name='testAtcChartAcc1'];
        test.startTest(); 
        ApexPages.StandardController  sc = new ApexPages.StandardController(ATCChart_testAgreementAPTS1);
        ATC_Chart testAtcChart= new ATC_Chart();
        
        testAtcChart.ViewMode = 'ATC';
        testAtcChart.aTCodeCriteria = 'J07C*';
        testAtcChart.dataPeriodStart = strtDate ;
        testAtcChart.dataPeriodEnd = endDate ;
        testAccountID = testAtcChartAcc1.Id;
        testAtcChart.AccountId = testAccountID ;
        testAtcChart.AssignAccount();
        testAtcChart.LoadProducts();
        testAtcChart.ProductId = testAtcChart.lstProducts.get(0).getValue(); 
        testAtcChart.Non_Chargedeliverof_ATC = true;
        testAtcChart.searchResults();
        
        testAtcChart.aTCodeCriteria = 'J07C';
        testAtcChart.searchResults();
        String qryStr =  '?';
        //Update by: Sneha Date: 20 feb, 2012 -- Object Permission fix for date fields
        qryStr = qryStr + 'stDate=' + strtDate ;
        qryStr = qryStr + '&endDate=' + endDate  ;
        qryStr = qryStr + '&accId=' + testAccountID  ;
        qryStr = qryStr + '&view=' + 'ATC' ;
        qryStr = qryStr + '&atcCode=' + 'J07C' ;
        qryStr = qryStr + '&Non_Chargedeliverof_ATC='+true;
        qryStr = qryStr + '&SelectedProducts=' + testAtcChart.ProductId; 
        
        PageReference ref = new PageReference('/apex/ATC_Chart_Excel' + qryStr);
        Test.setCurrentPage(ref ); 
        testclassDataExcel = new ATC_Chart_Excel(sc);
        
        qryStr =  '?';
        //Update by: Sneha Date: 20 feb, 2012 -- Object Permission fix for date fields
        qryStr = qryStr + 'stDate=' + strtDate ;
        qryStr = qryStr + '&endDate=' + endDate  ;
        qryStr = qryStr + '&accId=' + testAccountID  ;
        qryStr = qryStr + '&view=' + 'ATC' ;
        qryStr = qryStr + '&atcCode=' + 'J07C*' ;
        qryStr = qryStr + '&Non_Chargedeliverof_ATC='+true;
        qryStr = qryStr + '&SelectedProducts=' + testAtcChart.ProductId; 
        ref = new PageReference('/apex/ATC_Chart_Excel' + qryStr);
        Test.setCurrentPage(ref ); 
        testclassDataExcel = new ATC_Chart_Excel(sc);
        
        qryStr =  '?';
        //Update by: Sneha Date: 20 feb, 2012 -- Object Permission fix for date fields
        qryStr = qryStr + 'stDate=' + strtDate ;
        qryStr = qryStr + '&endDate=' + endDate  ;
        qryStr = qryStr + '&accId=' + testAccountID  ;
        qryStr = qryStr + '&view=' + 'ATC' ;
        qryStr = qryStr + '&atcCode=' + '' ;
        qryStr = qryStr + '&Non_Chargedeliverof_ATC='+true;
        qryStr = qryStr + '&SelectedProducts=' + testAtcChart.ProductId; 
        ref = new PageReference('/apex/ATC_Chart_Excel' + qryStr);
        Test.setCurrentPage(ref ); 
        testclassDataExcel = new ATC_Chart_Excel(sc);
        test.stopTest(); 
        //system.assertEquals(1,testAtcChart.lstATCViewWrapper.size());
    }
    
    public static testMethod void TestCase4(){ 
        setupData();
        Agreement__c ATCChart_testAgreementAPTS1 = [SELECT id, Name FROM Agreement__c WHERE Name='testAgree3'];
        Account testAtcChartAcc1 = [SELECT id FROM Account WHERE name='testAtcChartAcc1'];
        test.startTest(); 
        ApexPages.StandardController  sc = new ApexPages.StandardController(ATCChart_testAgreementAPTS1);
        ATC_Chart testAtcChart= new ATC_Chart();
        
        testAtcChart.ViewMode = 'ATC';
        testAtcChart.aTCodeCriteria = 'J07C*';
        testAtcChart.dataPeriodStart = date.newInstance(2012, 1, 1); 
        testAtcChart.dataPeriodEnd =  date.newInstance(2012, 12, 31);
        testAccountID = testAtcChartAcc1.Id;
        testAtcChart.AccountId = testAccountID ;
        testAtcChart.AssignAccount();
        testAtcChart.LoadProducts();
        testAtcChart.ProductId = testAtcChart.lstProducts.get(0).getValue(); 
        testAtcChart.Non_Chargedeliverof_ATC = true;
        testAtcChart.searchResults();
        testAtcChart.aTCodeCriteria = 'J07C';
        testAtcChart.searchResults();
        
        /**************************************** test case for ATC_Chart_Excel class **********************************************************************/
        
        string qryStr =  '?';
        //Update by: Sneha Date: 20 feb, 2012 -- Object Permission fix for date fields
        qryStr = qryStr + 'stDate=' + strtDate ;
        qryStr = qryStr + '&endDate=' + endDate  ;
        qryStr = qryStr + '&accId=' + testAtcChartAcc1.Id ;
        qryStr = qryStr + '&view=' + 'Product' ;
        qryStr = qryStr + '&atcCode=' + '' ;
        qryStr = qryStr + '&Non_Chargedeliverof_ATC='+true;
        qryStr = qryStr + '&SelectedProducts=' + testAtcChart.ProductId; 
        PageReference ref = new PageReference('/apex/ATC_Chart_Excel' + qryStr);
        Test.setCurrentPage(ref ); 
        testclassDataExcel = new ATC_Chart_Excel(sc);
        test.stopTest(); 
        // system.assertEquals(1,testAtcChart.lstATCViewWrapper.size());
    }
    public static testMethod void TestCase5(){
        setupData();
        Agreement__c ATCChart_testAgreementAPTS1 = [SELECT id, Name FROM Agreement__c WHERE Name='testAgree3'];
        Account testAtcChartAcc1 = [SELECT id FROM Account WHERE name='testAtcChartAcc1'];
        test.startTest(); 
        ApexPages.StandardController  sc = new ApexPages.StandardController(ATCChart_testAgreementAPTS1);
        ATC_Chart testAtcChart= new ATC_Chart();
        
        testAtcChart.aTCodeCriteria = '';
        testAtcChart.searchResults();
        ApexPages.Message msg1 = ApexPages.getMessages()[0];
        
        /********************************************************* test case for ATC_Chart_Excel class ************************************************************/
        
        string qryStr =  '?';
        //Update by: Sneha Date: 20 feb, 2012 -- Object Permission fix for date fields
        qryStr = qryStr + 'stDate=' + strtDate ;
        qryStr = qryStr + '&endDate=' + endDate  ;
        qryStr = qryStr + '&accId=' + '' ;
        qryStr = qryStr + '&view=' + 'Product' ;
        qryStr = qryStr + '&atcCode=' + 'J07C*' ;
        qryStr = qryStr + '&Non_Chargedeliverof_ATC='+true;
        PageReference ref = new PageReference('/apex/ATC_Chart_Excel' + qryStr);
        Test.setCurrentPage(ref ); 
        testclassDataExcel = new ATC_Chart_Excel(sc);
        test.stopTest(); 
        // system.assertEquals('Please select an account or specify an ATC code.',msg1.getDetail());
    } 
    
    public static testMethod void TestCase6(){
        setupData();
        Agreement__c ATCChart_testAgreementAPTS1 = [SELECT id, Name FROM Agreement__c WHERE Name='testAgree3'];
        Account testacc1 = [SELECT id FROM Account WHERE name='testAtcChartAcc1'];
        test.startTest(); 
        ApexPages.StandardController  sc = new ApexPages.StandardController(ATCChart_testAgreementAPTS1);
        ATC_Chart testAtcChart= new ATC_Chart();
        
        testAccountID = testacc1.Id;
        testAtcChart.AccountId = testAccountID ;
        testAtcChart.AssignAccount();
        testAtcChart.Non_Chargedeliverof_ATC = true;
        testAtcChart.searchResults();
        ApexPages.Message msg1 = ApexPages.getMessages()[0];
        string qryStr =  '?';
        //Update by: Sneha Date: 20 feb, 2012 -- Object Permission fix for date fields
        qryStr = qryStr + 'stDate=' + strtDate ;
        qryStr = qryStr + '&endDate=' + endDate  ;
        qryStr = qryStr + '&accId=' + '' ;
        qryStr = qryStr + '&view=' + 'Product' ;
        qryStr = qryStr + '&atcCode=' + 'J07C*' ;
        qryStr = qryStr + '&Non_Chargedeliverof_ATC='+true;
        PageReference ref = new PageReference('/apex/ATC_Chart_Excel' + qryStr);
        Test.setCurrentPage(ref ); 
        testclassDataExcel = new ATC_Chart_Excel(sc);
        test.stopTest(); 
        // system.assertEquals('Please select Data Period Start.',msg1.getDetail());
    } 
    public static testMethod void TestCase7(){
        setupData();
        Agreement__c ATCChart_testAgreementAPTS1 = [SELECT id, Name FROM Agreement__c WHERE Name='testAgree3'];
        Account testacc1 = [SELECT id FROM Account WHERE name='testAtcChartAcc1'];
        test.startTest(); 
        ApexPages.StandardController  sc = new ApexPages.StandardController(ATCChart_testAgreementAPTS1);
        ATC_Chart testAtcChart= new ATC_Chart();
        
        testAccountID = testacc1.Id;
        testAtcChart.AccountId = testAccountID ;
        testAtcChart.dataPeriodStart =  date.newInstance(2012, 1, 1);
        testAtcChart.AssignAccount();
        testAtcChart.Non_Chargedeliverof_ATC = true;
        testAtcChart.searchResults();
        ApexPages.Message msg1 = ApexPages.getMessages()[0];
        //  system.assertEquals('Please select Data Period End.',msg1.getDetail());
        testAtcChart.ExporttoExcel();
        test.stopTest(); 
    } 
    
    public static testMethod void TestCase9(){
        setupData();
        Agreement__c ATCChart_testAgreementAPTS1 = [SELECT id, Name FROM Agreement__c WHERE Name='testAgree3'];
        Account testAtcChartAcc1 = [SELECT id FROM Account WHERE name='testAtcChartAcc1'];
        //for(count = 1;count <= 190000;){
        //    count++;
        //}
        test.startTest(); 
        ApexPages.StandardController  sc = new ApexPages.StandardController(ATCChart_testAgreementAPTS1);
        ATC_Chart testAtcChart= new ATC_Chart();
        testAtcChart.ViewMode = 'ATC';
        testAtcChart.dataPeriodStart = date.newInstance(2012, 1, 1); 
        testAtcChart.dataPeriodEnd =  date.newInstance(2012, 12, 31);
        testAtcChart.aTCodeCriteria = 'J07C*';
        testAtcChart.Non_Chargedeliverof_ATC = true;
        testAtcChart.searchResults();
        string qryStr =  '?';
        //Update by: Sneha Date: 20 feb, 2012 -- Object Permission fix for date fields
        qryStr = qryStr + 'stDate=' + strtDate ;
        qryStr = qryStr + '&endDate=' + endDate  ;
        qryStr = qryStr + '&accId=' + '' ;
        qryStr = qryStr + '&view=' + 'ATC' ;
        qryStr = qryStr + '&atcCode=' + 'J07C*' ;
        qryStr = qryStr + '&Non_Chargedeliverof_ATC='+true;
        PageReference ref = new PageReference('/apex/ATC_Chart_Excel' + qryStr);
        Test.setCurrentPage(ref ); 
        testclassDataExcel = new ATC_Chart_Excel(sc);
        test.stopTest(); 
        // system.assertEquals(0,testAtcChart.lstATCViewWrapper.size());
        //  ApexPages.Message msg1 = ApexPages.getMessages()[0];
        // system.assertEquals('Too many results, please refine search criteria.',msg1.getDetail());
    } 
    public static testMethod void TestCase10(){
        setupData();  
        Agreement__c ATCChart_testAgreementAPTS1 = [SELECT id, Name FROM Agreement__c WHERE Name='testAgree3'];
        Account testAtcChartAcc1 = [SELECT id FROM Account WHERE name='testAtcChartAcc1'];
        ApexPages.StandardController  sc = new ApexPages.StandardController(ATCChart_testAgreementAPTS1);
        ATC_Chart testAtcChart= new ATC_Chart();
        
        PageReference pageRef = ApexPages.currentPage();
        testAtcChart.resetFilters();
        //  system.assertEquals(pageRef ,testAtcChart.resetFilters());
    } 
    
    
    /* test cases for AssignAccount() */
    public static testMethod void AssignAccount(){
        ATC_Chart testAtcChart= new ATC_Chart();  // constructor calling 
        testAtcChart.AccountId = '';
        testAtcChart.AssignAccount();
        
    } 
    
    public static testMethod void RemoveProducts(){
        ATC_Chart testAtcChart= new ATC_Chart(); 
        testAtcChart.RemoveProducts();
    }
    
    public static testMethod void wildCardCharReturnfalse(){
        ATC_Chart testAtcChart= new ATC_Chart();  // constructor calling 
        testAtcChart.aTCodeCriteria = '*****';
        testAtcChart.dataPeriodStart = strtDate;
        testAtcChart.dataPeriodEnd = endDate;
        testAtcChart.ProductId = ''; 
        testAtcChart.searchResults() ;
        
    }
    
    public static testMethod void testCaseExcel1(){
        ApexPages.StandardController sc;
        setupData();
        Agreement__c atc1 = [SELECT id, Name FROM Agreement__c WHERE Name='testAgree3'];
        Account testacc1 = [SELECT id FROM Account WHERE name='testAtcChartAcc1'];
        PageReference pageRef = new PageReference('/apex/ATC_Chart_Excel?accId='+testacc1.Id+'&view=ATC&atcCode=null&stDate='+strtDate+'&endDate='+endDate);
        Test.setCurrentPage(pageRef);  
        sc = new ApexPages.standardController(atc1);
        testclassDataExcel = new ATC_Chart_Excel(sc); 
        testclassDataExcel.searchResults();     
    }
    
    public static testMethod void testCaseExcel2(){
        ApexPages.StandardController sc;
        setupData();
        Agreement__c atc1 = [SELECT id, Name FROM Agreement__c WHERE Name='testAgree3'];
        Account testacc1 = [SELECT id FROM Account WHERE name='testAtcChartAcc1'];
        PageReference pageRef = new PageReference('/apex/ATC_Chart_Excel?accId=null&view=ATC&atcCode=A0&stDate='+strtDate+'&endDate='+endDate);
        Test.setCurrentPage(pageRef);  
        sc = new ApexPages.standardController(atc1);
        testclassDataExcel = new ATC_Chart_Excel(sc); 
        testclassDataExcel.searchResults();     
    }
    
    public static testMethod void testCaseExcel3(){
        ApexPages.StandardController sc;
        setupData();
        Agreement__c atc1 = [SELECT id, Name FROM Agreement__c WHERE Name='testAgree3'];
        Account testacc1 = [SELECT id FROM Account WHERE name='testAtcChartAcc1'];
        PageReference pageRef = new PageReference('/apex/ATC_Chart_Excel?accId='+testacc1.Id+'&view=ATC&atcCode=A0&stDate='+strtDate+'&endDate='+endDate);
        Test.setCurrentPage(pageRef);  
        sc = new ApexPages.standardController(atc1);
        testclassDataExcel = new ATC_Chart_Excel(sc); 
        testclassDataExcel.searchResults();     
    }
    
    public static testMethod void testCaseExcel4(){
        ApexPages.StandardController sc;
        setupData();
        Agreement__c atc1 = [SELECT id, Name FROM Agreement__c WHERE Name='testAgree3'];
        Account testacc1 = [SELECT id FROM Account WHERE name='testAtcChartAcc1'];
        PageReference pageRef = new PageReference('/apex/ATC_Chart_Excel?accId='+testacc1.Id+'&view=Product&atcCode=null&stDate='+strtDate+'&endDate='+endDate);
        Test.setCurrentPage(pageRef);  
        sc = new ApexPages.standardController(atc1);
        testclassDataExcel = new ATC_Chart_Excel(sc); 
        testclassDataExcel.searchResults();     
    }
    
    public static testMethod void testCaseExcel5(){
        ApexPages.StandardController sc;
        setupData();
        Agreement__c atc1 = [SELECT id, Name FROM Agreement__c WHERE Name='testAgree3'];
        Account testacc1 = [SELECT id FROM Account WHERE name='testAtcChartAcc1'];
        PageReference pageRef = new PageReference('/apex/ATC_Chart_Excel?accId=null&view=Product&atcCode=A0&stDate='+strtDate+'&endDate='+endDate);
        Test.setCurrentPage(pageRef);  
        sc = new ApexPages.standardController(atc1);
        testclassDataExcel = new ATC_Chart_Excel(sc); 
        testclassDataExcel.searchResults();     
    }
    
    public static testMethod void testCaseExcel6(){
        ApexPages.StandardController sc;
        setupData();
        Agreement__c atc1 = [SELECT id, Name FROM Agreement__c WHERE Name='testAgree3'];
        Account testacc1 = [SELECT id FROM Account WHERE name='testAtcChartAcc1'];
        PageReference pageRef = new PageReference('/apex/ATC_Chart_Excel?accId='+testacc1.Id+'&view=Product&atcCode=A0&stDate='+strtDate+'&endDate='+endDate);
        Test.setCurrentPage(pageRef);  
        sc = new ApexPages.standardController(atc1);
        testclassDataExcel = new ATC_Chart_Excel(sc); 
        testclassDataExcel.searchResults();     
    }
    /** product id = null **/
    public static testMethod void testCaseProductIDNull(){
        setupData();
        Agreement__c ATCChart_testAgreementAPTS1 = [SELECT id, Name FROM Agreement__c WHERE Name='testAgree3'];
        Account testAtcChartAcc1 = [SELECT id FROM Account WHERE name='testAtcChartAcc1'];
        ApexPages.StandardController  sc = new ApexPages.StandardController(ATCChart_testAgreementAPTS1);
        ATC_Chart testAtcChart= new ATC_Chart();
        testAtcChart.aTCodeCriteria = 'J07C%';
        testAtcChart.dataPeriodStart = strtDate ;
        testAtcChart.dataPeriodEnd = endDate ;
        testAccountID = testAtcChartAcc1.Id;
        testAtcChart.AccountId = testAccountID ;
        testAtcChart.AssignAccount();
        testAtcChart.Non_Chargedeliverof_ATC = true;
        testAtcChart.LoadProducts();
        testAtcChart.ProductId = '';
        testAtcChart.searchResults();
        /** product id = null ATC Code null **/
        testAtcChart.aTCodeCriteria = '';
        testAtcChart.searchResults();
        
        /*********************  ATC Chart Excel **********************/
        
        string qryStr =  '?';
        //Update by: Sneha Date: 20 feb, 2012 -- Object Permission fix for date fields
        qryStr = qryStr + 'stDate=' + strtDate ;
        qryStr = qryStr + '&endDate=' + endDate  ;
        qryStr = qryStr + '&accId=' + testAtcChartAcc1.Id;
        qryStr = qryStr + '&view=' + 'Product' ;
        qryStr = qryStr + '&atcCode=' + 'J07C%' ;
        qryStr = qryStr + '&Non_Chargedeliverof_ATC='+true;
        qryStr = qryStr + '&SelectedProducts=' + ''; 
        
        PageReference ref = new PageReference('/apex/ATC_Chart_Excel' + qryStr);
        Test.setCurrentPage(ref ); 
        testclassDataExcel = new ATC_Chart_Excel(sc);
        
        qryStr.replace('J07C%','');
        testclassDataExcel = new ATC_Chart_Excel(sc);
        
        
    }
    
    public static testMethod void testCaseProductIDNullAccountNull(){
        setupData();
        Agreement__c ATCChart_testAgreementAPTS1 = [SELECT id, Name FROM Agreement__c WHERE Name='testAgree3'];
        Account testAtcChartAcc1 = [SELECT id FROM Account WHERE name='testAtcChartAcc1'];
        ApexPages.StandardController  sc = new ApexPages.StandardController(ATCChart_testAgreementAPTS1);
        ATC_Chart testAtcChart= new ATC_Chart();
        testAtcChart.aTCodeCriteria = 'J07C%';
        testAtcChart.dataPeriodStart = strtDate ;
        testAtcChart.dataPeriodEnd = endDate ;
        testAccountID = testAtcChartAcc1.Id;
        testAtcChart.AccountId ='' ;
        testAtcChart.AssignAccount();
        testAtcChart.Non_Chargedeliverof_ATC = true;
        testAtcChart.LoadProducts();
        testAtcChart.ProductId = '';
        testAtcChart.searchResults();
    }
    
    public static testMethod void testCase11()
    {
        setUpData();
        Agreement__c ATCChart_testAgreementAPTS1 = [SELECT id, Name FROM Agreement__c WHERE Name='testAgree3'];
        Account testAtcChartAcc1 = [SELECT id FROM Account WHERE name='testAtcChartAcc1'];
        test.startTest();
        ApexPages.StandardController  sc = new ApexPages.StandardController(ATCChart_testAgreementAPTS1);
        string qryStr =  '?';
        
        qryStr = qryStr + 'stDate=' + strtDate ;
        qryStr = qryStr + '&endDate=' + endDate  ;
        qryStr = qryStr + '&accId=' + testAtcChartAcc1.Id ;
        qryStr = qryStr + '&view=' + 'Product' ;
        qryStr = qryStr + '&atcCode=' + 'J07C*' ;
        qryStr = qryStr + '&Non_Chargedeliverof_ATC='+false;
        qryStr = qryStr + '&SelectedProducts=' + ''; 
        
        PageReference ref = new PageReference('/apex/ATC_Chart_Excel' + qryStr);
        Test.setCurrentPage(ref ); 
        testclassDataExcel = new ATC_Chart_Excel(sc);
        testclassDataExcel.searchResults();
        test.stopTest();
    }
    
    public static testMethod void testCase12()
    {
        setUpData();
        Agreement__c ATCChart_testAgreementAPTS1 = [SELECT id, Name FROM Agreement__c WHERE Name='testAgree3'];
        Account testAtcChartAcc1 = [SELECT id FROM Account WHERE name='testAtcChartAcc1'];
        test.startTest();
        ApexPages.StandardController  sc = new ApexPages.StandardController(ATCChart_testAgreementAPTS1);
        string qryStr =  '?';
        
        qryStr = qryStr + 'stDate=' + strtDate ;
        qryStr = qryStr + '&endDate=' + endDate  ;
        qryStr = qryStr + '&accId=' + testAtcChartAcc1.Id ;
        qryStr = qryStr + '&view=' + 'Productsumm' ;
        qryStr = qryStr + '&atcCode=' + '' ;
        qryStr = qryStr + '&Non_Chargedeliverof_ATC='+false;
        qryStr = qryStr + '&SelectedProducts=' + ''; 
        
        PageReference ref = new PageReference('/apex/ATC_Chart_Excel' + qryStr);
        Test.setCurrentPage(ref ); 
        testclassDataExcel = new ATC_Chart_Excel(sc);
        testclassDataExcel.searchResults();
        test.stopTest();
    }
    
    public static testMethod void testCase13()
    {
        setupData();
        Agreement__c ATCChart_testAgreementAPTS1 = [SELECT id, Name FROM Agreement__c WHERE Name='testAgree3'];
        Account testAtcChartAcc1 = [SELECT id FROM Account WHERE name='testAtcChartAcc1'];
        test.startTest();     
        ApexPages.StandardController  sc = new ApexPages.StandardController(ATCChart_testAgreementAPTS1);
        ATC_Chart testAtcChart= new ATC_Chart();     
        testAtcChart.aTCodeCriteria = 'J07C*';
        testAtcChart.dataPeriodStart = strtDate ;
        testAtcChart.dataPeriodEnd = endDate ;
        testAccountID = testAtcChartAcc1.Id;
        testAtcChart.AccountId = testAccountID ;
        testAtcChart.AssignAccount();
        testAtcChart.Non_Chargedeliverof_ATC = true;
        testAtcChart.LoadProducts();
        testAtcChart.ProductId = testAtcChart.lstProducts.get(0).getValue();
        testAtcChart.searchResults();
        testAtcChart.Non_Chargedeliverof_ATC = false;
        testAtcChart.aTCodeCriteria = 'J07C';
        testAtcChart.ViewMode='Product';
        testAtcChart.searchResults();
        testAtcChart.gotoNextPageOfTable();
        testAtcChart.gotoPreviousPageOfTable();
        testAtcChart.gotoLastPageOfTable();
        string qryStr =  '?';
        
        qryStr = qryStr + 'stDate=' + strtDate ;
        qryStr = qryStr + '&endDate=' + endDate  ;
        qryStr = qryStr + '&accId=' + testAtcChartAcc1.Id ;
        qryStr = qryStr + '&view=' + 'Product' ;
        qryStr = qryStr + '&atcCode=' + 'J07C*' ;
        qryStr = qryStr + '&Non_Chargedeliverof_ATC='+false;
        qryStr = qryStr + '&SelectedProducts=' + ''; 
        
        PageReference ref = new PageReference('/apex/ATC_Chart_Excel' + qryStr);
        Test.setCurrentPage(ref ); 
        testclassDataExcel = new ATC_Chart_Excel(sc);
        testclassDataExcel.searchResults();
        test.stopTest(); 
    }
}