@isTest(seeAllData = false)
public with sharing class TST_Clone_Agreement {
    private static User u ;
    private static date strtDate = date.newInstance(2012, 1, 1);
    private static date endDate = date.newInstance(2012, 12, 31); 
    static void createUser()
    {
        u = new User();
        Profile p = [select id from profile where name='System administrator'];
         //Updated by Naveena : Issue 4502 :updated user details
        u = new User (
            alias               = 'Test_SCM',
            email               = 'standarduser@metacube.com',
            emailencodingkey    = 'UTF-8', 
            lastname            = 'SCMTesting',
            languagelocalekey   = 'en_US',
            localesidkey        = 'en_US',
            profileid           =  p.Id,
            timezonesidkey      = 'America/Los_Angeles', 
            username            = 'testSCMuser@metacube.com',
            IsActive            = true,
            Change_Request_Description__c = 'test', 
            Change_Request_Ticket_Number__c ='test description',
            EmployeeNumber = '08080808'
        );
        insert u ;
    }
    static void preparingData()
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
        insert testAccounts;
        
        List<ATC__c> testATCs = new List<ATC__c>();
        ATC__c atc1 = new ATC__c(ATC_Code__c = 'J07C',CurrencyIsoCode= 'USD');
        testATCs.add(atc1);
        ATC__c atc2 = new ATC__c(ATC_Code__c = 'XYZ1234',CurrencyIsoCode= 'USD');
        testATCs.add(atc2);
        insert testATCs;
        
        List<Product2> testProducts = new List<Product2>();
        Product2 testproduct1 = new Product2(Name = 'tstpro1',CurrencyIsoCode = 'USD',Material_Type__c = 'ZPUB');
        testproduct1.Pillar__c = 'Information Offering; Technology Solutions; R&D';
        testProducts.add(testproduct1);
        Product2 testproduct2 = new Product2(Name = 'tstpro2',CurrencyIsoCode = 'USD',Material_Type__c = 'ZPUB');
        testproduct2.Pillar__c = 'Information Offering; Technology Solutions; R&D';
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

        List<Agreement_Line_Item_Discount__c> AGLIDiscountToInsert = new List<Agreement_Line_Item_Discount__c>() ;
        Agreement_Line_Item_Discount__c testAgLIDiscount1 = new Agreement_Line_Item_Discount__c(Discount_Price__c = 100, CurrencyIsoCode  = 'USD'  ,Agreement_Line_Item__C = testLineItem1.id ) ;
        AGLIDiscountToInsert.add(testAgLIDiscount1) ; 
        Agreement_Line_Item_Discount__c testAgLIDiscount2 = new Agreement_Line_Item_Discount__c(Discount_Price__c = 200, CurrencyIsoCode  = 'USD' , Agreement_Line_Item__C = testLineItem1.id ) ;
        AGLIDiscountToInsert.add(testAgLIDiscount2) ;
        insert AGLIDiscountToInsert ;   
     }
    
   static testMethod void testingCloneOnlyAgreement() 
    {
        createUser();
        system.runAs(u)
        {  
            Contract_Management_Setting__c mycs = Contract_Management_Setting__c.getValues(UserInfo.getUserId());
            if(mycs == null) {
              mycs = new Contract_Management_Setting__c(Name= UserInfo.getUserId());
              mycs.Perform_SCM_Functions_Flag__c = true;
              //insert mycs;
            }
                      
            preparingData();
            Agreement__c testAgreementAPTS1 = [SELECT id, Name FROM Agreement__c WHERE Name='testAgree3'];
            apexpages.currentpage().getparameters().put('Id',testAgreementAPTS1.id);
            ApexPages.StandardController sc = new ApexPages.standardController(testAgreementAPTS1);
            Clone_Agreement clsObj = new Clone_Agreement(sc);       
            test.startTest();   
                clsObj.getCloneOptions();                   
                clsObj.selectedOption = null ; 
                clsObj.cloneObject();
                clsObj.selectedOption = ConstantClass.Agreement ;
                clsObj.cloneObject();
            test.stopTest();
        }
    }
    

    // Testing Option 4 which will cover all other three option logic
    static testMethod void testingCloneAll() 
    {
            //Added By Rakesh : 31 July 2013
            //*** Start ***
            Contract_Management_Setting__c mycs = Contract_Management_Setting__c.getValues(UserInfo.getUserId());
  
            if(mycs == null) {
              mycs = new Contract_Management_Setting__c(Name= UserInfo.getUserId());
              mycs.Perform_SCM_Functions_Flag__c = true;
              //insert mycs;
            }
            //End
        
        
        createUser();
        system.runAs(u)
        {            
            preparingData();
            Agreement__c testAgreementAPTS1 = [SELECT id, Name FROM Agreement__c WHERE Name='testAgree3'];
            apexpages.currentpage().getparameters().put('Id',testAgreementAPTS1.id);
            ApexPages.StandardController sc = new ApexPages.standardController(testAgreementAPTS1);
            Clone_Agreement clsObj = new Clone_Agreement(sc);       
            Integer totalAggBeforeCloning  = 0;
            Integer totalAggLIBeforeCLoning  = 0 ;
              
              test.startTest();      
                for(Agreement__c agg : [select id, (select id from Agreement_Line_Items__r) from Agreement__c ]) {
                    if(agg.Agreement_Line_Items__r != null)
                        totalAggLIBeforeCloning  += agg.Agreement_Line_Items__r.size();
                    totalAggBeforeCloning++ ; 
                }
                
                clsObj.selectedOption = ConstantClass.Clone_All ;
                clsObj.cloneObject();
                Integer totalAggAfterCloning  = 0 ;
                Integer totalAggLIAfterCLoning = 0  ;
                
                for(Agreement__c agg : [select id, (select id from Agreement_Line_Items__r) from Agreement__c ])
                {   
                    if(agg.Agreement_Line_Items__r != null){                  
                        totalAggLIAfterCLoning  += agg.Agreement_Line_Items__r.size();
                    }
                    totalAggAfterCloning++; 
                }               
            test.stopTest();
        }
    }
}