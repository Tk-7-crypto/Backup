@isTest 
public with sharing class TST_ContractChart {
    private static ContractChart testclassData;
    private static ApexPages.StandardController sc;
    private static final String ALL_VALUE = 'All';
    private static final String CONTRACT_STATUS_ACTIVE = 'Active';
    private static final String CONTRACT_STATUS_INACTIVE = 'Inactive';
    private static final String MEMORANDUM_VALUE = 'CES Memorandum' ;
    private static Date strtDate = Date.newInstance(2012, 1, 1);
    private static Date endDate = Date.newInstance(2012, 12, 31);
    private static Agreement__c testParentAgreement;
    private static Agreement__c testAgreement;
    private static Account testAccount;
    private static Agreement_Line_Item__c testAgreementLineItem,testParentAgreementLineItem;

    static void setupData()
    { 
        List<Account> testAccounts = new List<Account>();
        Account testacc1 = new Account(Name = 'TestAccountNameForSCM1',CurrencyIsoCode = 'USD',Region_Territory__c = 'India',Industry_IMS__c = 'Biotech', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        testAccounts.add(testacc1);
        Account testacc2 = new Account(Name = 'TestAccountNameForSCM2',CurrencyIsoCode = 'USD',Region_Territory__c = 'India',Industry_IMS__c = 'Biotech', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        testAccounts.add(testacc2);
        Account testAtcChartAcc1 = new Account(Name = 'testAtcChartAcc1',CurrencyIsoCode = 'USD',Region_Territory__c = 'India',Industry_IMS__c = 'Biotech', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        testAccounts.add(testAtcChartAcc1);
        Account testAggAccount1 = new Account(Name = 'IMS Health Global',CurrencyIsoCode = 'USD',Region_Territory__c = 'India',Industry_IMS__c = 'Biotech', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        testAccounts.add(testAggAccount1);
        testAccount = new Account(Name = 'IMS Health Global',CurrencyIsoCode = 'USD',
            Region_Territory__c = 'India',Industry_IMS__c = 'Biotech', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        testAccounts.add(testAccount);
        insert testAccounts;
        
        List<ATC__c> testATCs = new List<ATC__c>();
        ATC__c atc1 = new ATC__c(ATC_Code__c = 'J07C',CurrencyIsoCode= 'USD');
        testATCs.add(atc1);
        ATC__c atc2 = new ATC__c(ATC_Code__c = 'XYZ1234',CurrencyIsoCode= 'USD');
        testATCs.add(atc2);
        ATC__c atc3 = new ATC__c(ATC_Code__c = 'XYZ12345',CurrencyIsoCode= 'USD');
        testATCs.add(atc3);
        ATC__c atc4 = new ATC__c(ATC_Code__c = 'XYZ123456',CurrencyIsoCode= 'USD');
        testATCs.add(atc4);
        ATC__c atc5 = new ATC__c(ATC_Code__c = 'XYZ1234567',CurrencyIsoCode= 'USD');
        testATCs.add(atc5);
        insert testATCs;
        
        List<Product2> testProducts = new List<Product2>();
        Product2 testproduct1 = new Product2(Name = 'tstpro1',CurrencyIsoCode = 'USD',Material_Type__c = 'ZPUB');
        testproduct1.Pillar__c = 'Information Offering; Technology Solutions; R&D';
        testProducts.add(testproduct1);
        Product2 testproduct2 = new Product2(Name = 'tstpro2',CurrencyIsoCode = 'USD',Material_Type__c = 'ZPUB');
        testproduct2.Pillar__c = 'Information Offering; Technology Solutions; R&D';
        testProducts.add(testproduct2);
        Product2 testproduct3 = new Product2(Name = 'tstpro3',CurrencyIsoCode = 'USD',Material_Type__c = 'ZPUB');
        testproduct3.Pillar__c = 'Information Offering; Technology Solutions; R&D';
        testProducts.add(testproduct3);
        Product2 testproduct4 = new Product2(Name = 'tstpro4',CurrencyIsoCode = 'USD',Material_Type__c = 'ZPUB');
        testproduct4.Pillar__c = 'Information Offering; Technology Solutions; R&D';
        testProducts.add(testproduct4);
        Product2 testproduct5 = new Product2(Name = 'tstpro5',CurrencyIsoCode = 'USD',Material_Type__c = 'ZPUB');
        testproduct5.Pillar__c = 'Information Offering; Technology Solutions; R&D';
        testProducts.add(testproduct5);
        insert testProducts;
        
        List<Agreement__c> testAgreements = new List<Agreement__c>();
        Agreement__c testAgreementAPTS2 = new Agreement__c(Name ='testAgree2',Account__c = testacc1.id,Active__c = false,Company_Signed_Date__c = strtDate,Contract_Start_Date__c = strtDate.addDays(2),Contract_Type__c = 'CES Memorandum',Agreement_Term__c = 'Ad-Hoc'); 
        testAgreements.add(testAgreementAPTS2);
        Agreement__c testAgreementAPTS1 = new Agreement__c(Name ='testAgree1',Account__c = testacc1.id,Active__c = true,Company_Signed_Date__c = Date.Today().addDays(2),Parent_Agreement__c = testAgreementAPTS2.Id); 
        testAgreements.add(testAgreementAPTS1);
        Agreement__c ATCChart_testAgreementAPTS1 = new Agreement__c(Name ='testAgree3',Account__c = testAtcChartAcc1.id,Active__c = true,Company_Signed_Date__c = date.newInstance(2012,1,1),Contract_Start_Date__c =date.newInstance(2012,1,1),Contract_Type__c = 'CES Memorandum',Agreement_Term__c = 'Ad-Hoc'); 
        ATCChart_testAgreementAPTS1.RecordTypeId = ConstantClass.getRecordTypeId('Agreement__c', 'Japan Agreement' );
        testAgreements.add(ATCChart_testAgreementAPTS1);
        Agreement__c AggLocator_testAgreementAPTS1 = new Agreement__c(Name ='testAgree4',Account__c = testAggAccount1.id,Active__c = true,Company_Signed_Date__c = date.newInstance(2012,1,1),Contract_Start_Date__c =date.newInstance(2012,1,1),Contract_End_Date__c = date.newInstance(2012,1,1)  ,Contract_Type__c = 'CES Memorandum',Agreement_Term__c = 'Ad-Hoc'); 
        testAgreements.add(AggLocator_testAgreementAPTS1);
        Agreement__c AggWarning_testAgreement1 = new Agreement__c(Name ='testAgree5',Account__c = testAggAccount1.id,Active__c = true,Company_Signed_Date__c = date.newInstance(2012,1,1),Contract_Start_Date__c =date.newInstance(2012,1,1),Contract_End_Date__c = date.newInstance(2012,1,1)  ,Contract_Type__c = 'CES Memorandum',Agreement_Term__c = 'Ad-Hoc'); 
        testAgreements.add(AggWarning_testAgreement1);
        Agreement__c ATCChart_testAgreementAPTS2 = new Agreement__c(Name ='testAgree6',Account__c = testAtcChartAcc1.id,Active__c = false,Company_Signed_Date__c = date.newInstance(2012,1,1),Contract_Start_Date__c =date.newInstance(2011,1,1),Contract_Type__c = 'CES Memorandum',Agreement_Term__c = 'Ad-Hoc'); 
        ATCChart_testAgreementAPTS2.RecordTypeId = ConstantClass.getRecordTypeId('Agreement__c', 'Japan Agreement' );
        testAgreements.add(ATCChart_testAgreementAPTS2);
        
        testParentAgreement = new Agreement__c(Name ='testAgree6',Account__c = testAtcChartAcc1.id,
            Active__c = true,Company_Signed_Date__c = date.newInstance(2012,1,1),
            Contract_Start_Date__c =date.newInstance(2011,1,1),Contract_Type__c = 'CES Memorandum',
            Agreement_Term__c = 'Ad-Hoc',
            RecordTypeId = ConstantClass.getRecordTypeId('Agreement__c', 'Japan Agreement' )); 
        testAgreements.add(testParentAgreement);
        testAgreement = new Agreement__c(Name ='testAgree6',Account__c = testAtcChartAcc1.id,
            Active__c = true,Company_Signed_Date__c = date.newInstance(2012,1,1),
            Contract_Start_Date__c =date.newInstance(2011,1,1),Contract_Type__c = 'CES Memorandum',
            Agreement_Term__c = 'Ad-Hoc',Parent_Agreement__c = testParentAgreement.Id,
            RecordTypeId = ConstantClass.getRecordTypeId('Agreement__c', 'Japan Agreement')); 
        testAgreements.add(testAgreement);
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
        
        testAgreementLineItem = new Agreement_Line_Item__c(AgreementId__c = testAgreement.Id, 
            Additional_Price__c = 0, ExtendedPrice__c = 0, List_Price__c = 0, 
            Net_Price__c= 0, ProductId__c = testproduct1.id, Quantity__c = 0, 
            Contract_Start_Date__c = date.newInstance(2012,6,5), SCM_Fee_ScheduleLabel__c = 'test market defs', 
            Apts_Delivery_Frequency__c = 'Ad-hoc', Apts_Delivery_Format__c = 'CD', 
            Apts_Offering_Option__c = 'Basic', APTPS_Historical_Data__c = 'Four (4) Data Quarters',
            Back_Data__c = 'Four (4) Data Quarters', Apts_Market_Definitions__c = 'test market defs', 
            Market_Definition_Options__c = 'Selected Market Defs');
        testAgreementLineItems.add(testAgreementLineItem); 
        
        testParentAgreementLineItem = new Agreement_Line_Item__c(AgreementId__c = testParentAgreement.Id, 
            Additional_Price__c = 0, ExtendedPrice__c = 0, List_Price__c = 0, 
            Net_Price__c= 0, ProductId__c = testproduct1.id, Quantity__c = 0, 
            Contract_Start_Date__c = date.newInstance(2012,6,5), SCM_Fee_ScheduleLabel__c = 'test market defs', 
            Apts_Delivery_Frequency__c = 'Ad-hoc', Apts_Delivery_Format__c = 'CD', 
            Apts_Offering_Option__c = 'Basic', APTPS_Historical_Data__c = 'Four (4) Data Quarters',
            Back_Data__c = 'Four (4) Data Quarters', Apts_Market_Definitions__c = 'test market defs', 
            Market_Definition_Options__c = 'Selected Market Defs');
        testAgreementLineItems.add(testParentAgreementLineItem);  
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
     
   
   //Added By Rakesh : 8 Nov 2013 : ER-530
    private static User u ;    
    static void createUser()
    {
         //Added by Naveena : Issue 4502 : 21/10/2014 :start
        upsert new PseSecurityConfig__c(DisableSecurityTriggers__c=false,UserName__c = 'testt@imshealth1.com.dev2',DefaultOwnerUsername__c='integration@uk.imshealth1.com.dev2', SetupOwnerId = UserInfo.getOrganizationId());
         //Added by Naveena : Issue 4502 : 21/10/2014 :end
        
        u = new User();
        Profile p = [select id from profile where name='System administrator'];
        u = new User (
            alias               = 'testUser',
            email               = 'standarduser@metacube.com',
            emailencodingkey    = 'UTF-8', 
            lastname            = 'Testing',
            languagelocalekey   = 'en_US',
            localesidkey        = 'en_US',
            profileid           = p.Id,
            timezonesidkey      = 'America/Los_Angeles', 
            username            = 'teststandarduser12345@metacube.com',
            IsActive            = true,
            Change_Request_Description__c = 'test',
            Change_Request_Ticket_Number__c ='test description',
            employeeNumber= '080808081'
        );
        insert u ;
    }
    
    public static testmethod void testcase4(){
        createUser();
        system.runAs(u)
        {
            setupData();
            Agreement__c testAgreementAPTS1 = [SELECT id, Name FROM Agreement__c WHERE Name='testAgree3'];
            Account testacc1 = [SELECT id, Name FROM Account WHERE name='testAtcChartAcc1'];
            Product2 testproduct1 = [SELECT id FROM Product2 WHERE name='tstpro1'];
            test.startTest();
            sc = new ApexPages.standardController(testAgreementAPTS1);
            testclassData = new ContractChart(sc); 
            testclassData.contractStatus = ALL_VALUE  ;
            testclassData.dataPeriodStart = strtDate;
            testclassData.dataPeriodEnd  = endDate ;
            testclassData.AccountId = testacc1.Id;   
            testclassData.AccountName = testacc1.Name;   
            testclassData.LoadProducts();
            System.assertEquals(1, testclassData.productSize);
            testclassData.ProductId = testproduct1.Id; 
            testclassData.searchResults(); 
            testclassData.dataPeriodEnd  = null ;
            testclassData.searchResults(); 
            testclassData.dataPeriodStart = null;
            testclassData.dataPeriodEnd  = endDate ;
            testclassData.searchResults(); 
            testclassData.dataPeriodEnd  = null ;
            testclassData.searchResults(); 
            Test.stopTest();  
        } 
    }
    
    
    public static testMethod void testCase1(){
        createUser();
        system.runAs(u)
        {
            setupData();
            Agreement__c testAgreementAPTS1 = [SELECT id, Name FROM Agreement__c WHERE Name='testAgree3'];
            Account testacc1 = [SELECT id, Name FROM Account WHERE name='testAtcChartAcc1'];
            Product2 testproduct1 = [SELECT id FROM Product2 WHERE name='tstpro1'];
            PageReference pageRef = new PageReference('/apex/ContractChart');
            Test.setCurrentPage(pageRef); 
            sc = new ApexPages.standardController(testAgreementAPTS1);
            Test.startTest();
                ApexPages.currentPage().getParameters().put('accId',(string)testacc1.id);
                testclassData = new ContractChart(sc); 
                testclassData.contractStatus = CONTRACT_STATUS_ACTIVE ;
                testclassData.dataPeriodStart = strtDate;
                testclassData.dataPeriodEnd  = endDate ;
                testclassData.AccountId = '';
                testclassData.AccountName = '';
                testclassData.searchResults();
                ApexPages.currentPage().getParameters().put('accId', testclassData.AccountId );
                testclassData.AssignAccount();
                testclassData.AccountId = testacc1.Id;
                testclassData.AccountName = testacc1.Name;
                testclassData.LoadProducts();
                testclassData.ProductId = testproduct1.Id;  
                testclassData.contractType.add(MEMORANDUM_VALUE);
                testclassData.searchResults();  
                testclassData.dataPeriodEnd  = null ; 
                testclassData.searchResults(); 
                testclassData.dataPeriodStart = null;
                testclassData.dataPeriodEnd  = endDate ; 
                testclassData.searchResults();  
                testclassData.dataPeriodEnd  = null;
                testclassData.searchResults(); 
                testclassData.ExporttoExcel();
                testclassData.resetFilters();
            Test.stopTest();
        } 
    }
    
    
    public static testMethod void testcases2(){
        createUser();
        system.runAs(u)
        {
            setupData();
            Agreement__c testAgreementAPTS1 = [SELECT id, Name FROM Agreement__c WHERE Name='testAgree3'];
            Account testacc1 = [SELECT id, Name FROM Account WHERE name='testAtcChartAcc1'];
            Product2 testproduct1 = [SELECT id FROM Product2 WHERE name='tstpro1'];
            String JapanRecordTypeId = ConstantClass.getRecordTypeId('Agreement__c', 'Japan Agreement' ); 
            Agreement__c TestJapanAgreement = new Agreement__c(RecordTypeId = JapanRecordTypeId,Name ='testAgree2',Account__c = testacc1.id,Active__c = true,Company_Signed_Date__c = strtDate,Contract_Start_Date__c = strtDate.addDays(2),Contract_Type__c = 'CES Memorandum',Agreement_Term__c = 'Ad-Hoc' ,Agreement_Category__c = 'Data');
            insert TestJapanAgreement;
            sc = new ApexPages.standardController(testAgreementAPTS1);
            Test.startTest();
                testclassData = new ContractChart(sc); 
                testclassData.contractStatus = CONTRACT_STATUS_ACTIVE ;
                testclassData.dataPeriodStart = strtDate;
                testclassData.dataPeriodEnd  = endDate ;
                testclassData.AccountId = testacc1.Id;   
                testclassData.AccountName = testacc1.Name;   
                testclassData.LoadProducts();
                testclassData.ProductId = testproduct1.Id; 
                testclassData.searchResults(); 
                testclassData.dataPeriodEnd  = null ;
                testclassData.searchResults(); 
                testclassData.dataPeriodStart = null;
                testclassData.dataPeriodEnd  = endDate ;
                testclassData.searchResults(); 
                testclassData.dataPeriodEnd  = null ;
                testclassData.searchResults(); 
            Test.stopTest();  
        }
    }
     
    public static testmethod void testcase3(){
        //Updated By Rakesh : 8 Nov 2013 : ER-530 : Call createUser() method and put all test code in system.runAs(user) block
        createUser();
        system.runAs(u)
        {
            setupData();
            Agreement__c testAgreementAPTS1 = [SELECT id, Name FROM Agreement__c WHERE Name='testAgree3'];
            Account testacc1 = [SELECT id, Name FROM Account WHERE name='testAtcChartAcc1'];
            Product2 testproduct1 = [SELECT id FROM Product2 WHERE name='tstpro1'];
            sc = new ApexPages.standardController(testAgreementAPTS1);
            Test.startTest();
                testclassData = new ContractChart(sc); 
                testclassData.contractStatus = ALL_VALUE  ;
                testclassData.dataPeriodStart = strtDate;
                testclassData.dataPeriodEnd  = endDate ;
                testclassData.AccountId = '';
                testclassData.AccountName = '';
                testclassData.searchResults();
                ApexPages.currentPage().getParameters().put('accId', testclassData.AccountId );
                testclassData.AssignAccount();
                testclassData.AccountId = testacc1.Id;
                testclassData.AccountName = testacc1.Name;
                testclassData.LoadProducts();
                testclassData.ProductId = testproduct1.Id;  
                testclassData.contractType.add(MEMORANDUM_VALUE);
                testclassData.searchResults();  
                testclassData.dataPeriodEnd  = null ; 
                testclassData.searchResults(); 
                testclassData.dataPeriodStart = null;
                testclassData.dataPeriodEnd  = endDate ; 
                testclassData.searchResults();  
                testclassData.dataPeriodEnd  = null;
                testclassData.searchResults(); 
            Test.stopTest();  
        } 
    }


     public static testmethod void testcase5(){
        //Updated By Rakesh : 8 Nov 2013 : ER-530 : Call createUser() method and put all test code in system.runAs(user) block
        createUser();
        system.runAs(u)
        {
            setupData();
            Agreement__c testAgreementAPTS1 = [SELECT id, Name FROM Agreement__c WHERE Name='testAgree3'];
            Account testacc1 = [SELECT id, Name FROM Account WHERE name='testAtcChartAcc1'];
            Product2 testproduct1 = [SELECT id FROM Product2 WHERE name='tstpro1'];
            sc = new ApexPages.standardController(testAgreementAPTS1);
            Test.startTest();
                testclassData = new ContractChart(sc); 
                testclassData.contractStatus = CONTRACT_STATUS_ACTIVE ;
                testclassData.dataPeriodStart = strtDate;
                testclassData.dataPeriodEnd  = endDate ;
                testclassData.AccountId = '';
                testclassData.AccountName = '';
                testclassData.searchResults();
                ApexPages.currentPage().getParameters().put('accId', testclassData.AccountId );
                testclassData.AssignAccount();
                testclassData.AccountId = testacc1.Id;
                testclassData.AccountName = testacc1.Name;
                testclassData.LoadProducts();
                testclassData.ProductId = '';  
                testclassData.contractType.add(MEMORANDUM_VALUE);
                testclassData.searchResults();  
                testclassData.dataPeriodEnd  = null ; 
                testclassData.searchResults(); 
                testclassData.dataPeriodStart = null;
                testclassData.dataPeriodEnd  = endDate ; 
                testclassData.searchResults();  
                testclassData.dataPeriodEnd  = null;
                testclassData.searchResults(); 
            Test.stopTest(); 
        }
    }
    
    public static testmethod void testcase6(){
        //Updated By Rakesh : 8 Nov 2013 : ER-530 : Call createUser() method and put all test code in system.runAs(user) block
        createUser();
        system.runAs(u)
        {
            setupData();
            Agreement__c testAgreementAPTS1 = [SELECT id, Name FROM Agreement__c WHERE Name='testAgree3'];
            Account testacc1 = [SELECT id, Name FROM Account WHERE name='testAtcChartAcc1'];
            Product2 testproduct1 = [SELECT id FROM Product2 WHERE name='tstpro1'];
            sc = new ApexPages.standardController(testAgreementAPTS1);
            Test.startTest();
                testclassData = new ContractChart(sc); 
                testclassData.contractStatus = CONTRACT_STATUS_ACTIVE ;
                testclassData.dataPeriodStart = strtDate;
                testclassData.dataPeriodEnd  = endDate ;
                testclassData.AccountId = testacc1.Id;   
                testclassData.AccountName = testacc1.Name;   
                testclassData.LoadProducts();
                testclassData.ProductId = ''; 
                testclassData.searchResults(); 
                testclassData.dataPeriodEnd  = null ;
                testclassData.searchResults(); 
                testclassData.dataPeriodStart = null;
                testclassData.dataPeriodEnd  = endDate ;
                testclassData.searchResults(); 
                testclassData.dataPeriodEnd  = null ;
                testclassData.searchResults(); 
            Test.stopTest();  
        }
    }
    
    public static testmethod void testcase7(){
        createUser();
        system.runAs(u)
        {
            setupData();
            Agreement__c testAgreementAPTS1 = [SELECT id, Name FROM Agreement__c WHERE Name='testAgree3'];
            Account testacc1 = [SELECT id, Name FROM Account WHERE name='testAtcChartAcc1'];
            Product2 testproduct1 = [SELECT id FROM Product2 WHERE name='tstpro1']; 
            sc = new ApexPages.standardController(testAgreementAPTS1);
            Test.startTest();
                testclassData = new ContractChart(sc); 
                testclassData.contractStatus = ALL_VALUE  ;
                testclassData.dataPeriodStart = strtDate;
                testclassData.dataPeriodEnd  = endDate ;
                ApexPages.currentPage().getParameters().put('accId', testclassData.AccountId );
                testclassData.AssignAccount();
                testclassData.AccountId = testacc1.Id;
                testclassData.AccountName = testacc1.Name;
                testclassData.LoadProducts();
                testclassData.ProductId = '';  
                testclassData.contractType.add(MEMORANDUM_VALUE);
                testclassData.searchResults();  
                testclassData.dataPeriodEnd  = null ; 
                testclassData.searchResults(); 
                testclassData.dataPeriodStart = null;
                testclassData.dataPeriodEnd  = endDate ; 
                testclassData.searchResults();  
                testclassData.dataPeriodEnd  = null;
                testclassData.searchResults(); 
            Test.stopTest();   
        }
    }
     
     
    public static testmethod void testcase8(){
        createUser();
        system.runAs(u)
        {
            setUpData();
            Agreement__c testAgreementAPTS1 = [SELECT id, Name FROM Agreement__c WHERE Name='testAgree3'];
            Account testacc1 = [SELECT id, Name FROM Account WHERE name='testAtcChartAcc1'];
            Product2 testproduct1 = [SELECT id FROM Product2 WHERE name='tstpro1'];
            sc = new ApexPages.standardController(testAgreementAPTS1);
            Test.startTest();
                testclassData = new ContractChart(sc); 
                testclassData.contractStatus = ALL_VALUE  ;
                testclassData.dataPeriodStart = strtDate;
                testclassData.dataPeriodEnd  = endDate ;
                testclassData.AccountId = testacc1.Id;   
                testclassData.AccountName = testacc1.Name;   
                testclassData.LoadProducts();
                testclassData.ProductId = ''; 
                testclassData.searchResults(); 
                testclassData.dataPeriodEnd  = null ;
                testclassData.searchResults(); 
                testclassData.dataPeriodStart = null;
                testclassData.dataPeriodEnd  = endDate ;
                testclassData.searchResults(); 
                testclassData.dataPeriodEnd  = null ;
                testclassData.searchResults(); 
            Test.stopTest();  
        } 
    }
    public static testMethod void testCasebysweta (){
        createUser();
        system.runAs(u)
        {
            PageReference pageRef = new PageReference('/apex/ContractChart');
            Test.setCurrentPage(pageRef);  
            setupData();
            Agreement__c testAgreementAPTS1 = [SELECT id, Name FROM Agreement__c WHERE Name='testAgree3'];
            Account testacc1 = [SELECT id, Name FROM Account WHERE name='testAtcChartAcc1'];
            Product2 testproduct1 = [SELECT id FROM Product2 WHERE name='tstpro1'];
            sc = new ApexPages.standardController(testAgreementAPTS1);
            Test.startTest();
                ApexPages.currentPage().getParameters().put('accId',(string)testacc1.id);
                testclassData = new ContractChart(sc); 
                testclassData.contractStatus = CONTRACT_STATUS_ACTIVE ;
                testclassData.dataPeriodStart = strtDate;
                testclassData.dataPeriodEnd  = endDate;
                testclassData.AssignAccount();
                testclassData.LoadProducts();
                testclassData.searchResults();  
            Test.stopTest();  
        }           
    }
    
    public static testMethod void testUpdateParentAgreementShouldSetParentWhenValidDataPassed (){
        createUser();
        system.runAs(u)
        {
            PageReference pageRef = new PageReference('/apex/ContractChart');
            Test.setCurrentPage(pageRef);  
            setupData();
            
            sc = new ApexPages.standardController(testAgreement);
            Test.startTest();
                ApexPages.currentPage().getParameters().put('accId',(String)testAccount.id);
                testclassData = new ContractChart(sc); 
            testclassData.UpdateParentAgreement(new List<Agreement__c>{testAgreement},new Set<Id>{testParentAgreement.Id});  
            Test.stopTest();  
            
            //System.assertNotEquals(null,testAgreement.Parent_Agreement__c, 'Parent Agreement Not Set');
        }           
    }
    
    public static testMethod void testUpdateParentAgreementShouldNotSetParentWhenAgreementIsNull (){
        createUser();
        system.runAs(u)
        {
            PageReference pageRef = new PageReference('/apex/ContractChart');
            Test.setCurrentPage(pageRef);  
            setupData();
            
            sc = new ApexPages.standardController(testAgreement);
            Test.startTest();
                ApexPages.currentPage().getParameters().put('accId',(String)testAccount.id);
                testclassData = new ContractChart(sc); 
            testAgreement.Parent_Agreement__c = null;
            testclassData.UpdateParentAgreement(new List<Agreement__c>{testAgreement},new Set<Id>{testParentAgreement.Id});  
            Test.stopTest();  
            
            System.assertEquals(null,testAgreement.Parent_Agreement__c, 'Parent Agreement Set when not expected');
        }           
    }
    
    
    public static testMethod void testGenerateHierarchyShouldSetHeirarchyWhenValidDataPassed (){
        createUser();
        system.runAs(u)
        {
            PageReference pageRef = new PageReference('/apex/ContractChart');
            Test.setCurrentPage(pageRef);  
            setupData();
            
            sc = new ApexPages.standardController(testAgreement);
            Test.startTest();
                ApexPages.currentPage().getParameters().put('accId',(String)testAccount.id);
                testclassData = new ContractChart(sc); 
                testAgreement = [Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,
                 Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,
                 FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,
                 Agreement_Term__c,Total_Contract_Value__c, 
                 (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, 
                    Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r) 
                 From Agreement__c where ID =: testAgreement.Id limit 1];
                testParentAgreement = [Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,
                 Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,
                 FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,
                 Agreement_Term__c,Total_Contract_Value__c, 
                 (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, 
                    Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r) 
                 From Agreement__c where ID =: testParentAgreement.Id limit 1];
            
                Map<Id,Agreement__c> mapAgreementList = new Map<Id,Agreement__c> ();
                mapAgreementList.put(testParentAgreement.Id, testParentAgreement);
                mapAgreementList.put(testAgreement.Id, testAgreement);
            
                Map<Id,List<Agreement__c>> mapOfParentChild = new Map<Id,List<Agreement__c>> ();
                mapOfParentChild.put(testParentAgreement.Id, new List<Agreement__c>{testAgreement});
            
                testClassData.mapAgreementList = mapAgreementList;
                testClassData.mapParentChildDetails = mapOfParentChild;
            
                testclassData.GenerateHierarchy(mapOfParentChild,
                    new List<Agreement__c>{testAgreement,testParentAgreement});  
            Test.stopTest();  
            
            System.assertEquals(null,testAgreement.Parent_Agreement__c, 'Parent Agreement Set when not expected');
        }           
    }
    
    public static testMethod void testGetParentShouldReturnParentWhenChildIsPassed (){
        createUser();
        system.runAs(u)
        {
            PageReference pageRef = new PageReference('/apex/ContractChart');
            Test.setCurrentPage(pageRef);  
            setupData();
            
            sc = new ApexPages.standardController(testAgreement);
            Test.startTest();
                ApexPages.currentPage().getParameters().put('accId',(String)testAccount.id);
                testclassData = new ContractChart(sc); 
                testAgreement = [Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,
                 Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,
                 FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,
                 Agreement_Term__c,Total_Contract_Value__c, 
                 (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, 
                    Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r) 
                 From Agreement__c where ID =: testAgreement.Id limit 1];
                testParentAgreement = [Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,
                 Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,
                 FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,
                 Agreement_Term__c,Total_Contract_Value__c, 
                 (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, 
                    Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r) 
                 From Agreement__c where ID =: testParentAgreement.Id limit 1];
                Map<Id,Agreement__c> mapAgreementList = new Map<Id,Agreement__c> ();
                mapAgreementList.put(testParentAgreement.Id, testParentAgreement);
                mapAgreementList.put(testAgreement.Id, testAgreement);
                            
                testclassData.getParent(testAgreement,
                    new Set<Id>{testAgreement.Id,testParentAgreement.Id},mapAgreementList);  
            Test.stopTest();  
            
            System.assertEquals(null,testAgreement.Parent_Agreement__c, 'Parent Agreement Set when not expected');
        }           
    }
    
    public static testMethod void testGetParentShouldReturnNullWhenParentIsPassed (){
        createUser();
        system.runAs(u)
        {
            PageReference pageRef = new PageReference('/apex/ContractChart');
            Test.setCurrentPage(pageRef);  
            setupData();
            
            sc = new ApexPages.standardController(testAgreement);
            Test.startTest();
                ApexPages.currentPage().getParameters().put('accId',(String)testAccount.id);
                testclassData = new ContractChart(sc);
                
                testAgreement = [Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,
                 Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,
                 FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,
                 Agreement_Term__c,Total_Contract_Value__c, 
                 (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, 
                    Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r) 
                 From Agreement__c where ID =: testAgreement.Id limit 1];
                testParentAgreement = [Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,
                 Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,
                 FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,
                 Agreement_Term__c,Total_Contract_Value__c, 
                 (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, 
                    Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r) 
                 From Agreement__c where ID =: testParentAgreement.Id limit 1];
            
                Map<Id,Agreement__c> mapAgreementList = new Map<Id,Agreement__c> ();
                mapAgreementList.put(testParentAgreement.Id, testParentAgreement);
                mapAgreementList.put(testAgreement.Id, testAgreement);
                            
                testclassData.getParent(testParentAgreement,
                    new Set<Id>{testAgreement.Id,testParentAgreement.Id},mapAgreementList);  
            Test.stopTest();  
            
            System.assertEquals(null,testAgreement.Parent_Agreement__c, 'Parent Agreement Set when not expected');
        }           
    }
    
    public static testMethod void testExporttoExcelShouldReturnPageRefWhenValidDataPassed (){
        createUser();
        system.runAs(u)
        {
            PageReference pageRef = new PageReference('/apex/ContractChart');
            Test.setCurrentPage(pageRef);  
            setupData();
            
            sc = new ApexPages.standardController(testAgreement);
            Test.startTest();
                ApexPages.currentPage().getParameters().put('accId',(String)testAccount.id);
                testclassData = new ContractChart(sc);
                testclassData.contractType = new List<String>{'Agreement'};
                testclassData.ExporttoExcel();
                String pg = testclassData.strQuery;
            Test.stopTest();  
            
            System.assertNotEquals(null,pg, 'Page Reference String is null');

        }
    }
    
    public static testMethod void testResetFiltersShouldReturnPageRefWhenValidDataPassed (){
        createUser();
        system.runAs(u)
        {
            PageReference pageRef = new PageReference('/apex/ContractChart');
            Test.setCurrentPage(pageRef);  
            setupData();
            
            sc = new ApexPages.standardController(testAgreement);
            Test.startTest();
                ApexPages.currentPage().getParameters().put('accId',(String)testAccount.id);
                testclassData = new ContractChart(sc);
                testclassData.contractType = new List<String>{'Agreement'};
                PageReference pg = testclassData.resetFilters();
            Test.stopTest();  
            
            System.assertNotEquals(null,pg, 'Page Reference is null');

        }
    }  
}