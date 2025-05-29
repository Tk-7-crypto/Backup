@istest 
public class TST_ATCSearch{
    
    private static String Textsearch = 'J07C';
    private static String Textsearch_nochar = '*****';
    private static List<ATCSearch.ATCSearchWrapper> testlstATC = new List<ATCSearch.ATCSearchWrapper>();
    private static List<ATCSearch.ATCSearchWrapper> testlstATCSelected = new List<ATCSearch.ATCSearchWrapper>();
    private static List<ATCSearch.ATCSearchWrapper> lstATC ;
    private static string testALIId;
    private static ATCSearch testatcsearch;
    private static Profile profile=[select name from profile where name='System administrator' Limit 1];    
    private static User u ;
    
    static void createUser()
    {
    	 upsert new PseSecurityConfig__c(DisableSecurityTriggers__c=true,UserName__c = 'testt@imshealth1.com.dev2',DefaultOwnerUsername__c='integration@uk.imshealth1.com.dev2', SetupOwnerId = UserInfo.getOrganizationId());
         u = new User();
         Profile p = [select id from profile where name='System administrator'];
         u = new User (
                        alias               = 'testUser',
                        email               = 'standarduser@testorg.com',
                        emailencodingkey    = 'UTF-8', 
                        lastname            = 'Testing',
                        languagelocalekey   = 'en_US',
                        localesidkey        = 'en_US',
                        profileid           = p.Id,
                        timezonesidkey      = 'America/Los_Angeles', 
                        username            = 'teststandarduser@testorg.com',
                        IsActive            = true
                       );
          insert u ;
    }
    
    public static void setupData(){ 
        Date strtDate = date.newInstance(2012, 1, 1);
        Date endDate = date.newInstance(2012, 12, 31);
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
        testProducts.add(testproduct1);
        Product2 testproduct2 = new Product2(Name = 'tstpro2',CurrencyIsoCode = 'USD',Material_Type__c = 'ZPUB');
        testProducts.add(testproduct2);
        Product2 testproduct3 = new Product2(Name = 'tstpro3',CurrencyIsoCode = 'USD',Material_Type__c = 'ZPUB');
        testProducts.add(testproduct3);
        Product2 testproduct4 = new Product2(Name = 'tstpro4',CurrencyIsoCode = 'USD',Material_Type__c = 'ZPUB');
        testProducts.add(testproduct4);
        Product2 testproduct5 = new Product2(Name = 'tstpro5',CurrencyIsoCode = 'USD',Material_Type__c = 'ZPUB');
        testProducts.add(testproduct5);
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
    
    public static testMethod void testcases1()
    {   
    	Contract_Management_Setting__c contractMgmtSCMFlag = new Contract_Management_Setting__c();
    	contractMgmtSCMFlag.Perform_SCM_Functions_Flag__c = false;
    	insert contractMgmtSCMFlag;
    	setupData();
        Test.startTest();
        Agreement__c ATCChart_testAgreementAPTS1 = [SELECT id, Name FROM Agreement__c WHERE Name='testAgree3'];
        Account testAtcChartAcc1 = [SELECT id FROM Account WHERE name='testAtcChartAcc1'];
        Agreement_Line_Item__c testLineItem1 = [SELECT id FROM Agreement_Line_Item__c WHERE AgreementId__c = :ATCChart_testAgreementAPTS1.Id];
        testatcsearch = new ATCSearch(new Apexpages.Standardcontroller(testLineItem1));
        testatcsearch.searchText = Textsearch; 
        testatcsearch.callErrorMsg();
        testatcsearch.callErrorMsg2();
        testatcsearch.profile = profile.name;
        Test.stopTest(); 
    }    
    
    /**
     * Test case to check functionality of AddSelected method of ATCSearch controller.
     */  
    public static testMethod void testcases2()
    {
    	Contract_Management_Setting__c contractMgmtSCMFlag = new Contract_Management_Setting__c();
    	contractMgmtSCMFlag.Perform_SCM_Functions_Flag__c = false;
    	insert contractMgmtSCMFlag;
    	
        setupData();
        Agreement__c ATCChart_testAgreementAPTS1 = [SELECT id, Name FROM Agreement__c WHERE Name='testAgree3'];
        Account testAtcChartAcc1 = [SELECT id FROM Account WHERE name='testAtcChartAcc1'];
        Agreement_Line_Item__c ATCChart_testLineItem1 = [SELECT id FROM Agreement_Line_Item__c WHERE AgreementId__c = :ATCChart_testAgreementAPTS1.Id];
        Test.startTest();
        testALIId = ATCChart_testLineItem1 .id+'';
        
        PageReference pageRef = Page.ATC_Search;
        Test.setCurrentPage(pageRef); 
        ApexPages.currentPage().getParameters().put('id',testALIId);   
                                          
        testatcsearch = new ATCSearch(new Apexpages.Standardcontroller(ATCChart_testLineItem1));
        testatcsearch.profile = profile.name;
        testatcsearch.searchText = Textsearch; 
        testatcsearch.SearchMarketDefinition();
        //testatcsearch.SearchATC();
                               
        for(integer i=0; i< testatcsearch.lstATC.size(); i++)
        {
            testatcsearch.lstATC[i].selectedFlag  = true;
        }
        testatcsearch.getObjectList(); // test case for single method
        
        ApexPages.currentPage().getParameters().put('selObjSL',ConstantClass.getRecordTypeId('ATC__c','ATC'));
        testatcsearch.setSelObj();
        
        testatcsearch.AddSelected();
        
        testatcsearch.searchText = Textsearch_nochar;  
        testatcsearch.SearchMarketDefinition();
        Test.stopTest();
    }    
    
    /**
    * Test case to check functionality of AddLineItem and CancelATCSearch method of ATCSearch controller.
    */
    public static testMethod void testcases3()
    { 
        upsert new PseSecurityConfig__c(DisableSecurityTriggers__c=true,UserName__c = 'testt@imshealth1.com.dev2',DefaultOwnerUsername__c='integration@uk.imshealth1.com.dev2', SetupOwnerId = UserInfo.getOrganizationId());
    	Contract_Management_Setting__c contractMgmtSCMFlag = new Contract_Management_Setting__c();
    	contractMgmtSCMFlag.Perform_SCM_Functions_Flag__c = false;
    	insert contractMgmtSCMFlag;
    	setupData(); 
        Agreement__c ATCChart_testAgreementAPTS1 = [SELECT id, Name FROM Agreement__c WHERE Name='testAgree3'];
        Account testAtcChartAcc1 = [SELECT id FROM Account WHERE name='testAtcChartAcc1'];
        Agreement_Line_Item__c ATCChart_testLineItem1 = [SELECT id FROM Agreement_Line_Item__c WHERE AgreementId__c = :ATCChart_testAgreementAPTS1.Id];
        List<ATC__c> atcList = [SELECT id FROM ATC__c];
        test.startTest();
        testALIId = ATCChart_testLineItem1 .id+'';
        PageReference pageRef = Page.ATC_Search;
        Test.setCurrentPage(pageRef); 
        ApexPages.currentPage().getParameters().put('id',testALIId);  
        testatcsearch = new ATCSearch(new Apexpages.Standardcontroller(ATCChart_testLineItem1));          
        ATCSearch.ATCSearchWrapper atcwrapper = new  ATCSearch.ATCSearchWrapper(atcList[0]);     
        testatcsearch.searchText = Textsearch;
        testatcsearch.profile = profile.name;          
        testatcsearch.SearchMarketDefinition();
        for(integer i=0; i< testatcsearch.lstATC.size(); i++)
        {
            testatcsearch.lstATC[i].selectedFlag  = true;
        }
        testatcsearch.getObjectList(); // test case for single method
        testatcsearch.AddSelected();
        
        List<ATCSearch.ATCSearchWrapper> atcwrapperlist=new List<ATCSearch.ATCSearchWrapper>();
        ATCSearch.ATCSearchWrapper tempatcwrapper=new ATCSearch.ATCSearchWrapper(atcList[0] , false);
        atcwrapperlist.add(tempatcwrapper);
        tempatcwrapper=new ATCSearch.ATCSearchWrapper(atcList[1] , false);
        atcwrapperlist.add(tempatcwrapper);
        tempatcwrapper=new ATCSearch.ATCSearchWrapper(atcList[2] , true);
        atcwrapperlist.add(tempatcwrapper);
        tempatcwrapper=new ATCSearch.ATCSearchWrapper(atcList[3] , false);
        atcwrapperlist.add(tempatcwrapper);
        testatcsearch.listOfAllSelectedData=new List<List<ATCSearch.ATCSearchWrapper>>();
        testatcsearch.listOfAllSelectedData.add(atcwrapperlist);
        pageReference ref1 = testatcsearch.AddLineItemATCs();
        pageReference ref2 = testatcsearch.CancelATCSearch();
        
        tempatcwrapper=new ATCSearch.ATCSearchWrapper(atcList[0] , true);
        atcwrapperlist.add(tempatcwrapper);
        tempatcwrapper=new ATCSearch.ATCSearchWrapper(atcList[1] , true);
        atcwrapperlist.add(tempatcwrapper);
        testatcsearch.lstATC.addAll(atcwrapperlist);
        testatcsearch.AddSelected();
        
        ApexPages.currentPage().getParameters().put('selObjSL',null);
        testatcsearch.setSelObj();
        Test.stopTest();
     }

     
     /**
     * Test case to check functionality of RemoveSelected method of ATCSearch controller.
     */
     public static testMethod void testcases4()
     {  
     	Contract_Management_Setting__c contractMgmtSCMFlag = new Contract_Management_Setting__c();
    	contractMgmtSCMFlag.Perform_SCM_Functions_Flag__c = false;
    	insert contractMgmtSCMFlag;
    	setupData();
        Agreement__c ATCChart_testAgreementAPTS1 = [SELECT id, Name FROM Agreement__c WHERE Name='testAgree3'];
        Account testAtcChartAcc1 = [SELECT id FROM Account WHERE name='testAtcChartAcc1'];
        Agreement_Line_Item__c ATCChart_testLineItem1 = [SELECT id FROM Agreement_Line_Item__c WHERE AgreementId__c = :ATCChart_testAgreementAPTS1.Id];
        List<ATC__c> atcList = [SELECT id FROM ATC__c];
        Test.startTest();       
        testALIId = ATCChart_testLineItem1 .id+'';
        PageReference pageRef = Page.ATC_Search;
        Test.setCurrentPage(pageRef); 
        ApexPages.currentPage().getParameters().put('id',testALIId);  
        testatcsearch = new ATCSearch(new Apexpages.Standardcontroller(ATCChart_testLineItem1));        
        ATCSearch.ATCSearchWrapper atcwrapper = new  ATCSearch.ATCSearchWrapper(atcList[0]);     
        testatcsearch.searchText = Textsearch;
        testatcsearch.profile = profile.name;        
        testatcsearch.SearchMarketDefinition();
        testatcsearch.profile=null;
        testatcsearch.SearchMarketDefinition();
        for(integer i=0; i< testatcsearch.lstATC.size(); i++)
        {
            testatcsearch.lstATC[i].selectedFlag  = true;
        }
        testatcsearch.AddSelected();
        testatcsearch.RemoveSelected();
        Test.stopTest();
    }
    
    public static testMethod void testcases5()
    { 
    	Contract_Management_Setting__c contractMgmtSCMFlag = new Contract_Management_Setting__c();
    	contractMgmtSCMFlag.Perform_SCM_Functions_Flag__c = false;
    	insert contractMgmtSCMFlag;
    	setupData(); 
        Agreement__c ATCChart_testAgreementAPTS1 = [SELECT id, Name FROM Agreement__c WHERE Name='testAgree3'];
        Agreement_Line_Item__c AGLI = [SELECT id,AgreementId__c FROM Agreement_Line_Item__c WHERE AgreementId__c = :ATCChart_testAgreementAPTS1.Id];
        List<ATC__c> atcList = [SELECT id FROM ATC__c];
        List<Product2> productList = [SELECT id FROM Product2];
        testALIId = AGLI.id;
        List<Agreement_Line_Item__c> tstAgreementLineItems = new List<Agreement_Line_Item__c>();
        Agreement_Line_Item__c tstLineItem2 = new Agreement_Line_Item__c(AgreementId__c = AGLI.AgreementId__c, Additional_Price__c = 123,ExtendedPrice__c = 123,List_Price__c = 123,Net_Price__c = 123,ProductId__c = productList[2].id,Quantity__c = 4);
        tstAgreementLineItems.add(tstLineItem2);
        Agreement_Line_Item__c tstLineItem3 = new Agreement_Line_Item__c(AgreementId__c = AGLI.AgreementId__c, Additional_Price__c = 123,ExtendedPrice__c = 123,List_Price__c = 123,Net_Price__c = 123,ProductId__c = productList[1].id,Quantity__c = 4);
        tstAgreementLineItems.add(tstLineItem3);
        insert tstAgreementLineItems;
        test.startTest();
        
        PageReference pageRef = Page.ATC_Search;
        Test.setCurrentPage(pageRef); 
        ApexPages.currentPage().getParameters().put('id',testALIId);  
        testatcsearch = new ATCSearch(new Apexpages.Standardcontroller(AGLI));          
        
        ATCSearch.ATCSearchWrapper atcwrapper = new  ATCSearch.ATCSearchWrapper(atcList[1]);     
		testatcsearch.profile = profile.name;          
		testatcsearch.getObjectList();
        testatcsearch.searchText = 'xyz';
        
        testatcsearch.SearchMarketDefinition();
        for(integer i=0; i< testatcsearch.lstATC.size(); i++)
        {
            testatcsearch.lstATC[i].selectedFlag  = true;
        }
        List<selectOption> allALISelectList = testatcsearch.getAGLIListOption();
        testatcsearch.applyToOtherLineItem = true;
        testatcsearch.isAllSelected = false;
        testatcsearch.selectedAGLILineItem.add(allALISelectList.get(1).getValue());
        testatcsearch.AddSelected();
        pageReference ref1 = testatcsearch.AddLineItemATCs();
        Map<ID, Agreement_Line_Item__c> AGLIIdwithMarketDefMap = new Map<ID, Agreement_Line_Item__c>([select Id, Name, (select id, Name, Agreement_Line_Item__c, ATC__c from Agreement_Line_Item_ATCs__r ) from Agreement_Line_Item__c where AgreementId__c = : AGLI.AgreementId__c ]);
        testatcsearch.RemoveSelected();
        Test.stopTest();     
     }
}