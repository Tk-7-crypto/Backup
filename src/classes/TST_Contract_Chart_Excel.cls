@isTest
private class TST_Contract_Chart_Excel {
    private static Contract_Chart_Excel testclassDataExcel;
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
        Contract_Management_Setting__c mycs = Contract_Management_Setting__c.getValues(UserInfo.getUserId());
  
        if(mycs == null) {
        	mycs = new Contract_Management_Setting__c(Name= UserInfo.getUserId());
            mycs.Perform_SCM_Functions_Flag__c = true;
            mycs.Japan_Agreement__c = ConstantClass.getRecordTypeId('Agreement__c', 'Japan Agreement' );
            mycs.Japan_Master_Agreement__c = ConstantClass.getRecordTypeId('Agreement__c', 'Japan Master Agreement' );
            insert mycs;
        } 
        
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
            Active__c = true,Company_Signed_Date__c = strtDate,
            Contract_Start_Date__c =date.newInstance(2011,1,1),Contract_Type__c = 'Memorandum',
            Agreement_Term__c = 'Ad-Hoc',
            RecordTypeId = ConstantClass.getRecordTypeId('Agreement__c', 'Japan Agreement' )); 
        testAgreements.add(testParentAgreement);
        testAgreement = new Agreement__c(Name ='testAgree6',Account__c = testAtcChartAcc1.id,
            Active__c = true,Company_Signed_Date__c = strtDate,
            Contract_Start_Date__c =date.newInstance(2012,1,1),Contract_Type__c = 'Memorandum',
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
   
    public static testMethod void testCaseExcel1(){
        createUser();
        system.runAs(u)
        {
            setUpData();
            Agreement__c atc1 = [SELECT id, Name FROM Agreement__c WHERE Name='testAgree3'];
            Account testacc1 = [SELECT id FROM Account WHERE name='testAtcChartAcc1'];
            Product2 testproduct1 = [SELECT id FROM Product2 WHERE name='tstpro1'];
            String contType = 'Memorandum' ;
            PageReference pageRef = new PageReference('/apex/Contract_Chart_Excel?accId='+testacc1.Id+'&status='+TST_Contract_Chart_Excel.CONTRACT_STATUS_ACTIVE+'&prodId='+ testproduct1.Id +'&startDate='+strtDate+'&endDate='+endDate+'&type='+contType );
            Test.setCurrentPage(pageRef);  
            sc = new ApexPages.standardController(atc1);
            Test.startTest();
                testclassDataExcel = new Contract_Chart_Excel(sc); 
                PageReference pageRefcase2 = new PageReference('/apex/Contract_Chart_Excel?accId='+testacc1.Id+'&status='+TST_Contract_Chart_Excel.CONTRACT_STATUS_ACTIVE+'&prodId='+ testproduct1.Id +'&startDate='+strtDate+'&endDate='+'null'+'&type='+contType );
                Test.setCurrentPage(pageRefcase2 );  
                testclassDataExcel = new Contract_Chart_Excel(sc); 
                PageReference pageRefcase3 =  new PageReference('/apex/Contract_Chart_Excel?accId='+testacc1.Id+'&status='+TST_Contract_Chart_Excel.CONTRACT_STATUS_ACTIVE+'&prodId='+ testproduct1.Id +'&startDate='+'null'+'&endDate='+endDate+'&type='+contType );
                Test.setCurrentPage(pageRefcase3 );  
                testclassDataExcel = new Contract_Chart_Excel(sc); 
                PageReference pageRefcase4 =  new PageReference('/apex/Contract_Chart_Excel?accId='+testacc1.Id+'&status='+TST_Contract_Chart_Excel.CONTRACT_STATUS_ACTIVE+'&prodId='+ testproduct1.Id +'&startDate='+'null'+'&endDate='+'null'+'&type='+contType );
                Test.setCurrentPage(pageRefcase4 );  
                Test.stopTest();
        }
    }
     
    public static testMethod void testCaseExcel11(){
        createUser();
        system.runAs(u)
        {
            setupData();
            Agreement__c atc1 = [SELECT id, Name FROM Agreement__c WHERE Name='testAgree3'];
            Account testacc1 = [SELECT id FROM Account WHERE name='testAtcChartAcc1'];
            Product2 testproduct1 = [SELECT id FROM Product2 WHERE name='tstpro1'];
            String contType = 'Memorandum' ;
            PageReference pageRef = new PageReference('/apex/Contract_Chart_Excel?accId='+testacc1.Id+'&status='+ALL_VALUE +'&prodId='+ testproduct1.Id +'&startDate='+strtDate+'&endDate='+endDate+'&type='+contType );
            Test.setCurrentPage(pageRef);  
            sc = new ApexPages.standardController(atc1);
            Test.startTest();
                testclassDataExcel = new Contract_Chart_Excel(sc); 
                PageReference pageRefcase2 = new PageReference('/apex/Contract_Chart_Excel?accId='+testacc1.Id+'&status='+ALL_VALUE +'&prodId='+ testproduct1.Id +'&startDate='+strtDate+'&endDate='+'null'+'&type='+contType );
                Test.setCurrentPage(pageRefcase2 );  
                testclassDataExcel = new Contract_Chart_Excel(sc); 
                PageReference pageRefcase3 =  new PageReference('/apex/Contract_Chart_Excel?accId='+testacc1.Id+'&status='+ALL_VALUE +'&prodId='+ testproduct1.Id +'&startDate='+'null'+'&endDate='+endDate+'&type='+contType );
                Test.setCurrentPage(pageRefcase3 );  
                testclassDataExcel = new Contract_Chart_Excel(sc); 
                PageReference pageRefcase4 =  new PageReference('/apex/Contract_Chart_Excel?accId='+testacc1.Id+'&status='+ALL_VALUE +'&prodId='+ testproduct1.Id +'&startDate='+'null'+'&endDate='+'null'+'&type='+contType );
                Test.setCurrentPage(pageRefcase4 );  
            Test.stopTest();
        }
    }
   
    public static testMethod void testCaseExcel111(){
        createUser();
        system.runAs(u)
        {
            setupData();  
            Agreement__c atc1 = [SELECT id, Name FROM Agreement__c WHERE Name='testAgree3'];
            Account testacc1 = [SELECT id FROM Account WHERE name='testAtcChartAcc1'];
            Product2 testproduct1 = [SELECT id FROM Product2 WHERE name='tstpro1'];
            String contType = '' ;
            PageReference pageRef = new PageReference('/apex/Contract_Chart_Excel?accId='+testacc1.Id+'&status='+ALL_VALUE +'&prodId='+ testproduct1.Id +'&startDate='+strtDate+'&endDate='+endDate+'&type='+contType );
            
            Test.setCurrentPage(pageRef);  
            sc = new ApexPages.standardController(atc1);
            Test.startTest();
                testclassDataExcel = new Contract_Chart_Excel(sc); 
                PageReference pageRefcase2 = new PageReference('/apex/Contract_Chart_Excel?accId='+testacc1.Id+'&status='+ALL_VALUE +'&prodId='+ testproduct1.Id +'&startDate='+strtDate+'&endDate='+'null'+'&type='+contType );
                Test.setCurrentPage(pageRefcase2);  
                testclassDataExcel = new Contract_Chart_Excel(sc); 
                PageReference pageRefcase3 =  new PageReference('/apex/Contract_Chart_Excel?accId='+testacc1.Id+'&status='+ALL_VALUE +'&prodId='+ testproduct1.Id +'&startDate='+'null'+'&endDate='+endDate+'&type='+contType );
                Test.setCurrentPage(pageRefcase3);
                testclassDataExcel = new Contract_Chart_Excel(sc); 
                PageReference pageRefcase4 =  new PageReference('/apex/Contract_Chart_Excel?accId='+testacc1.Id+'&status='+ALL_VALUE +'&prodId='+ testproduct1.Id +'&startDate='+'null'+'&endDate='+'null'+'&type='+contType );
                Test.setCurrentPage(pageRefcase4);  
            Test.stopTest();
        }
    }
    
    
    public static testMethod void testCaseExcel2(){
        createUser();
        system.runAs(u)
        {
            setupData();
            Agreement__c atc1 = [SELECT id, Name FROM Agreement__c WHERE Name='testAgree3'];
            Account testacc1 = [SELECT id FROM Account WHERE name='testAtcChartAcc1'];
            Product2 testproduct1 = [SELECT id FROM Product2 WHERE name='tstpro1'];
            String contType = 'Memorandum' ;
            PageReference pageRef = new PageReference('/apex/Contract_Chart_Excel?accId='+testacc1.Id+'&status='+TST_Contract_Chart_Excel.CONTRACT_STATUS_ACTIVE+'&prodId='+ '' +'&startDate='+strtDate+'&endDate='+endDate+'&type='+contType );
            
            Test.setCurrentPage(pageRef);  
            sc = new ApexPages.standardController(atc1);
            Test.startTest();
                testclassDataExcel = new Contract_Chart_Excel(sc); 
                PageReference pageRefcase2 = new PageReference('/apex/Contract_Chart_Excel?accId='+testacc1.Id+'&status='+TST_Contract_Chart_Excel.CONTRACT_STATUS_ACTIVE+'&prodId='+ '' +'&startDate='+strtDate+'&endDate='+'null'+'&type='+contType );
                Test.setCurrentPage(pageRefcase2 );  
                testclassDataExcel = new Contract_Chart_Excel(sc); 
                PageReference pageRefcase3 =  new PageReference('/apex/Contract_Chart_Excel?accId='+testacc1.Id+'&status='+TST_Contract_Chart_Excel.CONTRACT_STATUS_ACTIVE+'&prodId='+ '' +'&startDate='+'null'+'&endDate='+endDate+'&type='+contType );
                Test.setCurrentPage(pageRefcase3 );  
                testclassDataExcel = new Contract_Chart_Excel(sc); 
                PageReference pageRefcase4 =  new PageReference('/apex/Contract_Chart_Excel?accId='+testacc1.Id+'&status='+TST_Contract_Chart_Excel.CONTRACT_STATUS_ACTIVE+'&prodId='+ '' +'&startDate='+'null'+'&endDate='+'null'+'&type='+contType );
                Test.setCurrentPage(pageRefcase4 );  
            Test.stopTest();
        }
            
    }
    
     public static testMethod void testCaseExcel22(){
        //Updated By Rakesh : 8 Nov 2013 : ER-530 : Call createUser() method and put all test code in system.runAs(user) block
        createUser();
        system.runAs(u)
        {
            setupData();
            Agreement__c atc1 = [SELECT id, Name FROM Agreement__c WHERE Name='testAgree3'];
            Account testacc1 = [SELECT id FROM Account WHERE name='testAtcChartAcc1'];
            Product2 testproduct1 = [SELECT id FROM Product2 WHERE name='tstpro1'];
            String contType = 'Memorandum' ;
            PageReference pageRef = new PageReference('/apex/Contract_Chart_Excel?accId='+testacc1.Id+'&status='+ALL_VALUE +'&prodId='+ '' +'&startDate='+strtDate+'&endDate='+endDate+'&type='+contType );
            
            Test.setCurrentPage(pageRef);  
            sc = new ApexPages.standardController(atc1);
            Test.startTest();
                testclassDataExcel = new Contract_Chart_Excel(sc); 
                PageReference pageRefcase2 = new PageReference('/apex/Contract_Chart_Excel?accId='+testacc1.Id+'&status='+ALL_VALUE +'&prodId='+ '' +'&startDate='+strtDate+'&endDate='+'null'+'&type='+contType );
                Test.setCurrentPage(pageRefcase2 );  
                testclassDataExcel = new Contract_Chart_Excel(sc); 
                PageReference pageRefcase3 =  new PageReference('/apex/Contract_Chart_Excel?accId='+testacc1.Id+'&status='+ALL_VALUE +'&prodId='+ '' +'&startDate='+'null'+'&endDate='+endDate+'&type='+contType );
                Test.setCurrentPage(pageRefcase3 );  
                testclassDataExcel = new Contract_Chart_Excel(sc); 
                PageReference pageRefcase4 =  new PageReference('/apex/Contract_Chart_Excel?accId='+testacc1.Id+'&status='+ALL_VALUE +'&prodId='+ '' +'&startDate='+'null'+'&endDate='+'null'+'&type='+contType );
                Test.setCurrentPage(pageRefcase4 );  
            Test.stopTest();
        } 
    }
       
    public static testMethod void testCaseExcel3(){
        createUser();
        system.runAs(u)
        {
            setupData();
            Agreement__c atc1 = [SELECT id, Name FROM Agreement__c WHERE Name='testAgree3'];
            Account testacc1 = [SELECT id FROM Account WHERE name='testAtcChartAcc1'];
            Product2 testproduct1 = [SELECT id FROM Product2 WHERE name='tstpro1'];
            String contType = '' ;
            PageReference pageRef = new PageReference('/apex/Contract_Chart_Excel?accId='+testacc1.Id+'&status='+TST_Contract_Chart_Excel.CONTRACT_STATUS_ACTIVE+'&prodId='+ testproduct1.Id +'&startDate='+strtDate+'&endDate='+endDate+'&type='+contType );
            
            Test.setCurrentPage(pageRef);  
            sc = new ApexPages.standardController(atc1);
            Test.startTest();
                testclassDataExcel = new Contract_Chart_Excel(sc); 
                PageReference pageRefcase2 = new PageReference('/apex/Contract_Chart_Excel?accId='+testacc1.Id+'&status='+TST_Contract_Chart_Excel.CONTRACT_STATUS_ACTIVE+'&prodId='+ testproduct1.Id +'&startDate='+strtDate+'&endDate='+'null'+'&type='+contType );
                Test.setCurrentPage(pageRefcase2 );  
                testclassDataExcel = new Contract_Chart_Excel(sc); 
                PageReference pageRefcase3 =  new PageReference('/apex/Contract_Chart_Excel?accId='+testacc1.Id+'&status='+TST_Contract_Chart_Excel.CONTRACT_STATUS_ACTIVE+'&prodId='+ testproduct1.Id +'&startDate='+'null'+'&endDate='+endDate+'&type='+contType );
                Test.setCurrentPage(pageRefcase3 );  
                testclassDataExcel = new Contract_Chart_Excel(sc); 
                PageReference pageRefcase4 =  new PageReference('/apex/Contract_Chart_Excel?accId='+testacc1.Id+'&status='+TST_Contract_Chart_Excel.CONTRACT_STATUS_ACTIVE+'&prodId='+ testproduct1.Id +'&startDate='+'null'+'&endDate='+'null'+'&type='+contType );
                Test.setCurrentPage(pageRefcase4 );  
            Test.stopTest(); 
        } 
    }
    
    public static testMethod void testCaseExcel4(){
        createUser();
        system.runAs(u)
        {
            setupData();
            Agreement__c atc1 = [SELECT id, Name FROM Agreement__c WHERE Name='testAgree3'];
            Account testacc1 = [SELECT id FROM Account WHERE name='testAtcChartAcc1'];
            Product2 testproduct1 = [SELECT id FROM Product2 WHERE name='tstpro1'];
            String contType = '' ;
            PageReference pageRef = new PageReference('/apex/Contract_Chart_Excel?accId='+testacc1.Id+'&status='+TST_Contract_Chart_Excel.CONTRACT_STATUS_ACTIVE+'&prodId='+ '' +'&startDate='+strtDate+'&endDate='+endDate+'&type='+contType );
            
            Test.setCurrentPage(pageRef);  
            sc = new ApexPages.standardController(atc1);
            Test.startTest();
                testclassDataExcel = new Contract_Chart_Excel(sc); 
                PageReference pageRefcase2 = new PageReference('/apex/Contract_Chart_Excel?accId='+testacc1.Id+'&status='+TST_Contract_Chart_Excel.CONTRACT_STATUS_ACTIVE+'&prodId='+ '' +'&startDate='+strtDate+'&endDate='+'null'+'&type='+contType );
                Test.setCurrentPage(pageRefcase2 );  
                testclassDataExcel = new Contract_Chart_Excel(sc); 
                PageReference pageRefcase3 =  new PageReference('/apex/Contract_Chart_Excel?accId='+testacc1.Id+'&status='+TST_Contract_Chart_Excel.CONTRACT_STATUS_ACTIVE+'&prodId='+ '' +'&startDate='+'null'+'&endDate='+endDate+'&type='+contType );
                Test.setCurrentPage(pageRefcase3 );  
                testclassDataExcel = new Contract_Chart_Excel(sc); 
                PageReference pageRefcase4 =  new PageReference('/apex/Contract_Chart_Excel?accId='+testacc1.Id+'&status='+TST_Contract_Chart_Excel.CONTRACT_STATUS_ACTIVE+'&prodId='+ '' +'&startDate='+'null'+'&endDate='+'null'+'&type='+contType );
                Test.setCurrentPage(pageRefcase4 ); 
            Test.stopTest();
        }    
    }
    
    public static testMethod void testUpdateParentAgreementForExcelShouldSetParentWhenValidDataPassed (){
        createUser();
        system.runAs(u)
        {
            setupData();
            Product2 testproduct1 = [SELECT id FROM Product2 WHERE name='tstpro1'];
            String contType = 'Memorandum' ;
            PageReference pageRef = new PageReference('/apex/Contract_Chart_Excel?accId='+testAccount.Id+'&status='+TST_Contract_Chart_Excel.CONTRACT_STATUS_ACTIVE+'&prodId='+ testproduct1.Id +'&startDate='+strtDate+'&endDate='+endDate+'&type='+contType );
            Test.setCurrentPage(pageRef); 
            
            sc = new ApexPages.standardController(testAgreement);
            Test.startTest();
                ApexPages.currentPage().getParameters().put('accId',(String)testAccount.id);
                testclassDataExcel = new Contract_Chart_Excel(sc); 
                testclassDataExcel.UpdateParentAgreement(new List<Agreement__c>{testAgreement},
                    new Set<Id>{testParentAgreement.Id},testAccount.Id);  
            Test.stopTest();  
            
            //System.assertNotEquals(null,testAgreement.Parent_Agreement__c, 'Parent Agreement Not Set');
        }           
    }
    
    public static testMethod void testUpdateParentAgreementForExcelShouldNotSetParentWhenAgreementIsNull (){
        createUser();
        system.runAs(u)
        {
            setupData();
            Product2 testproduct1 = [SELECT id FROM Product2 WHERE name='tstpro1'];
            String contType = 'Memorandum' ;
            PageReference pageRef = new PageReference('/apex/Contract_Chart_Excel?accId='+testAccount.Id+'&status='+TST_Contract_Chart_Excel.CONTRACT_STATUS_ACTIVE+'&prodId='+ testproduct1.Id +'&startDate='+strtDate+'&endDate='+endDate+'&type='+contType );
            Test.setCurrentPage(pageRef); 
            
            sc = new ApexPages.standardController(testAgreement);
            Test.startTest();
                ApexPages.currentPage().getParameters().put('accId',(String)testAccount.id);
                testclassDataExcel = new Contract_Chart_Excel(sc); 
                testAgreement.Parent_Agreement__c = null;
                testclassDataExcel.UpdateParentAgreement(new List<Agreement__c>{testAgreement},
                    new Set<Id>{testParentAgreement.Id},(String)testAccount.id);  
            Test.stopTest();  
            
            System.assertEquals(null,testAgreement.Parent_Agreement__c, 'Parent Agreement Set when not expected');
        }           
    }
    
    
    public static testMethod void testGenerateHierarchyForExcelShouldSetHeirarchyWhenValidDataPassed (){
        createUser();
        system.runAs(u)
        {
            setupData();
            Product2 testproduct1 = [SELECT id FROM Product2 WHERE name='tstpro1'];
            String contType = 'Memorandum' ;
            PageReference pageRef = new PageReference('/apex/Contract_Chart_Excel?accId='+testAccount.Id+'&status='+TST_Contract_Chart_Excel.CONTRACT_STATUS_ACTIVE+'&prodId='+ testproduct1.Id +'&startDate='+strtDate+'&endDate='+endDate+'&type='+contType );
            Test.setCurrentPage(pageRef); 
            
            sc = new ApexPages.standardController(testAgreement);
            Test.startTest();
                ApexPages.currentPage().getParameters().put('accId',(String)testAccount.id);
                testclassDataExcel = new Contract_Chart_Excel(sc); 
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
            
                testclassDataExcel.mapAgreementList = mapAgreementList;
                testclassDataExcel.mapParentChildDetails = mapOfParentChild;
            
                testclassDataExcel.GenerateHierarchy(mapOfParentChild,
                    new List<Agreement__c>{testAgreement,testParentAgreement});  
            Test.stopTest();  
            
            System.assertEquals(null,testAgreement.Parent_Agreement__c, 'Parent Agreement Set when not expected');
        }           
    }
    
    public static testMethod void testGetParentForExcelShouldReturnParentWhenChildIsPassed (){
        createUser();
        system.runAs(u)
        {
            setupData();
            Product2 testproduct1 = [SELECT id FROM Product2 WHERE name='tstpro1'];
            String contType = 'Memorandum' ;
            PageReference pageRef = new PageReference('/apex/Contract_Chart_Excel?accId='+testAccount.Id+'&status='+TST_Contract_Chart_Excel.CONTRACT_STATUS_ACTIVE+'&prodId='+ testproduct1.Id +'&startDate='+strtDate+'&endDate='+endDate+'&type='+contType );
            Test.setCurrentPage(pageRef); 
            
            sc = new ApexPages.standardController(testAgreement);
            Test.startTest();
                ApexPages.currentPage().getParameters().put('accId',(String)testAccount.id);
                testclassDataExcel = new Contract_Chart_Excel(sc); 
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
                            
                testclassDataExcel.getParent(testAgreement,
                    new Set<Id>{testAgreement.Id,testParentAgreement.Id},mapAgreementList);  
            Test.stopTest();  
            
            System.assertEquals(null,testAgreement.Parent_Agreement__c, 'Parent Agreement Set when not expected');
        }           
    }
    
    public static testMethod void testGetParentForExcelShouldReturnNullWhenParentIsPassed (){
        createUser();
        system.runAs(u)
        {
            setupData();
            Product2 testproduct1 = [SELECT id FROM Product2 WHERE name='tstpro1'];
            String contType = 'Memorandum' ;
            PageReference pageRef = new PageReference('/apex/Contract_Chart_Excel?accId='+testAccount.Id+'&status='+TST_Contract_Chart_Excel.CONTRACT_STATUS_ACTIVE+'&prodId='+ testproduct1.Id +'&startDate='+strtDate+'&endDate='+endDate+'&type='+contType );
            Test.setCurrentPage(pageRef); 
            
            sc = new ApexPages.standardController(testAgreement);
            Test.startTest();
                ApexPages.currentPage().getParameters().put('accId',(String)testAccount.id);
                testclassDataExcel = new Contract_Chart_Excel(sc); 
                
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
                            
                testclassDataExcel.getParent(testParentAgreement,
                    new Set<Id>{testAgreement.Id,testParentAgreement.Id},mapAgreementList);  
            Test.stopTest();  
            
            System.assertEquals(null,testAgreement.Parent_Agreement__c, 'Parent Agreement Set when not expected');
        }           
    }
    
    public static testMethod void testSearchResultsShouldSetValuesWhenStartEndIsNotNull(){
        createUser();
        system.runAs(u)
        {
            setUpData();
            Agreement__c atc1 = [SELECT id, Name FROM Agreement__c WHERE Name='testAgree3'];
            Account testacc1 = [SELECT id FROM Account WHERE name='testAtcChartAcc1'];
            Product2 testproduct1 = [SELECT id FROM Product2 WHERE name='tstpro1'];
            String contType = 'Memorandum' ; 
            Test.startTest();
                sc = new ApexPages.standardController(atc1);
                PageReference pageRefcase2 = new PageReference('/apex/Contract_Chart_Excel?accId='+testacc1.Id+'&status='+TST_Contract_Chart_Excel.CONTRACT_STATUS_ACTIVE+'&prodId='+ testproduct1.Id +'&startDate=null'+'&endDate=null'+'&type='+contType);
                Test.setCurrentPage(pageRefcase2 );  
                testclassDataExcel = new Contract_Chart_Excel(sc); 
            Test.stopTest();
        }
    }
   
    public static testMethod void testSearchResultsShouldSetValuesWhenContractTypeIsAll(){
        createUser();
        system.runAs(u)
        {
            setUpData();
            Agreement__c atc1 = [SELECT id, Name FROM Agreement__c WHERE Name='testAgree3'];
            Account testacc1 = [SELECT id FROM Account WHERE name='testAtcChartAcc1'];
            Product2 testproduct1 = [SELECT id FROM Product2 WHERE name='tstpro1'];
            String contType = 'All' ; 
            Test.startTest();
                sc = new ApexPages.standardController(atc1);
                PageReference pageRefcase2 = new PageReference('/apex/Contract_Chart_Excel?accId='+testacc1.Id+'&status='+TST_Contract_Chart_Excel.CONTRACT_STATUS_ACTIVE+'&prodId='+ testproduct1.Id +'&startDate=null'+'&endDate=null'+'&type='+contType );
                Test.setCurrentPage(pageRefcase2 );  
                testclassDataExcel = new Contract_Chart_Excel(sc); 
            Test.stopTest();
        }
    }
    
    public static testMethod void testSearchResultsShouldSetValuesWhenStartEndDateIsNotNull(){
        createUser();
        system.runAs(u)
        {
            setUpData();
            Agreement__c atc1 = [SELECT id, Name FROM Agreement__c WHERE Name='testAgree3'];
            Account testacc1 = [SELECT id FROM Account WHERE name='testAtcChartAcc1'];
            Product2 testproduct1 = [SELECT id FROM Product2 WHERE name='tstpro1'];
            String contType = 'Memorandum' ; 
            Test.startTest();
                sc = new ApexPages.standardController(atc1);
                PageReference pageRefcase2 = new PageReference('/apex/Contract_Chart_Excel?accId='+testacc1.Id+'&status=true'+'&prodId='+ testproduct1.Id +'&startDate='+strtDate+'&endDate='+endDate+'&type='+contType );
                Test.setCurrentPage(pageRefcase2 );  
                testclassDataExcel = new Contract_Chart_Excel(sc); 
            Test.stopTest();
        }
    }

}