@isTest(seeAllData=false)
public class TST_AgreementLocatorController {
    private static final String QUICKSEARCHBY_ACCOUNTNAME = 'Account Name';
    private static final String TIMEFRAME_DATA_PERIOD_START = 'Data Period Start (ATC)';
    private static final String ACTIVE = 'Active';
    private static User u ;
    
    static void createUser() {
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
            IsActive            = true,
            Change_Request_Description__c = 'test',
            Change_Request_Ticket_Number__c ='test description',
            EmployeeNumber = '090909091'
        );
        insert u ;
        
        Contract_Management_Setting__c contractMgmtSCMFlag = new Contract_Management_Setting__c();
        contractMgmtSCMFlag.Perform_SCM_Functions_Flag__c = false;
        insert contractMgmtSCMFlag;
    }
    
    public static void preparingData() {
        Date strtDate = Date.today();
        Date endDate = Date.today().addDays(30);
        List<Account> testAccounts = new List<Account>();
        List<ATC__c> testATCs = new List<ATC__c>();
        List<Product2> testProducts = new List<Product2>();
        List<Agreement__c> testAgreements = new List<Agreement__c>();
        List<Agreement_Line_Item__c> testAgreementLineItems = new List<Agreement_Line_Item__c>();
        List<Agreement_Line_Item_ATCs__c> testAgreementLineItemATCs = new List<Agreement_Line_Item_ATCs__c>();
        
        Account testacc1 = new Account(Name = 'TestAccountNameForSCM1',CurrencyIsoCode = 'USD',Region_Territory__c = 'India',Industry_IMS__c = 'Biotech',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        testAccounts.add(testacc1);
        Account testacc2 = new Account(Name = 'TestAccountNameForSCM2',CurrencyIsoCode = 'USD',Region_Territory__c = 'India',Industry_IMS__c = 'Biotech',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        testAccounts.add(testacc2);
        Account testAtcChartAcc1 = new Account(Name = 'testAtcChartAcc1',CurrencyIsoCode = 'USD',Region_Territory__c = 'India',Industry_IMS__c = 'Biotech',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        testAccounts.add(testAtcChartAcc1);
        Account testAggAccount1 = new Account(Name = 'IMS Health Global',CurrencyIsoCode = 'USD',Region_Territory__c = 'India',Industry_IMS__c = 'Biotech',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        testAccounts.add(testAggAccount1);
        insert testAccounts;
        
        ATC__c atc1 = new ATC__c(ATC_Code__c = 'J07C',CurrencyIsoCode= 'USD');
        testATCs.add(atc1);
        ATC__c atc2 = new ATC__c(ATC_Code__c = 'XYZ1234',CurrencyIsoCode= 'USD');
        testATCs.add(atc2);
        insert testATCs;
        
        Product2 testproduct1 = new Product2(Name = 'tstpro1',CurrencyIsoCode = 'USD',Material_Type__c = 'ZPUB');
        testproduct1.Pillar__c = 'Information Offering; Technology Solutions; R&D';
        testProducts.add(testproduct1);
        Product2 testproduct2 = new Product2(Name = 'tstpro2',CurrencyIsoCode = 'USD',Material_Type__c = 'ZPUB');
        testproduct2.Pillar__c = 'Information Offering; Technology Solutions; R&D';
        testProducts.add(testproduct2);
        insert testProducts;
        
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
    
    public static testMethod void testcases1() {  
        createUser();
        system.runAs(u)
        {
            preparingData(); 
            test.startTest();
            //Test converage for the myPage visualforce page
            PageReference pageRef = Page.Agreementlocator;
            Test.setCurrentPageReference(pageRef);
            AgreementLocatorController agreeloccont  = new AgreementLocatorController();
            
            agreeloccont.quickSearchby = QUICKSEARCHBY_ACCOUNTNAME;
            //Updated by :-Ekta ,Date-15th June-2013
            agreeloccont.quickSearchByStr = 'testAtcChartAcc1';
            agreeloccont.atcCodeStr = 'J07C';
            agreeloccont.contractType = 'CES Memorandum';
            agreeloccont.agreementTerm =  'Ad-Hoc';
            list<SelectOption> testTimeFrame_1 = agreeloccont.getLstTimeFrame();
            agreeloccont.timeFrame = 'None';
            agreeloccont.timeFrameChanged();
            //Updated by :-Ekta ,Date-15th June-2013
            agreeloccont.applyFilter();
            if(testTimeFrame_1.size()>0) {
                agreeloccont.timeFrame = testTimeFrame_1.get(6).getValue();
            }
            agreeloccont.applyFilter();
            agreeloccont.ExcelExport();
            Account testAtcChartAcc1 = [Select id FROM Account Where Name='testAtcChartAcc1'];
            List<Id> lst=new List<Id>();
            lst.add(testAtcChartAcc1.id);
            agreeloccont.CommaSeperatedvalues(lst);
            AgreementLocatorController.agreementWrapper testWrapper = new AgreementLocatorController.agreementWrapper(new Agreement__c());
            AgreementLocatorController.agreementWrapper testWrapper1 = new AgreementLocatorController.agreementWrapper(new Agreement_Line_Item__c());
            Test.stopTest();
        }
    }
    
    public static testMethod void testcases2(){
        createUser();
        system.runAs(u) {
            preparingData();
            Test.startTest();		
            PageReference pageRef = Page.Agreementlocator;
            Test.setCurrentPageReference(pageRef);
            AgreementLocatorController agreeloccont  = new AgreementLocatorController();
            agreeloccont.quickSearchby = 'None' ;
            list<SelectOption> testTimeFrame_1 = agreeloccont.getLstTimeFrame();
            if(testTimeFrame_1.size()>0) {
                agreeloccont.timeFrame = testTimeFrame_1.get(2).getValue();
            }
            agreeloccont.timeFrameChanged();
            agreeloccont.active = 'None'  ;
            agreeloccont.atcCodeStr = '' ;
            agreeloccont.contractType = 'None';
            agreeloccont.agreementTerm =  'None';
            agreeloccont.applyFilter();
            agreeloccont.gotoNextPage();
            agreeloccont.gotoPreviousPage();
            agreeloccont.gotoFirstPage();
            agreeloccont.gotoLastPage();
            agreeloccont.ExcelExport();
            Test.stopTest();
        }
    }
    
    public static testMethod void testcases_AggWithotALI(){
        createUser();
        system.runAs(u) {
            preparingData();
            test.startTest();
            PageReference pageRef = Page.Agreementlocator;
            Test.setCurrentPageReference(pageRef);
            AgreementLocatorController agreeloccont  = new AgreementLocatorController();
            agreeloccont.quickSearchby = QUICKSEARCHBY_ACCOUNTNAME ;
            agreeloccont.quickSearchByStr = 'IMS Health Global' ;
            list<SelectOption> testTimeFrame_1 = agreeloccont.getLstTimeFrame();
            if(testTimeFrame_1.size()>0) {
                agreeloccont.timeFrame = 'Signed Date';
            }
            agreeloccont.timeFrameChanged();
            agreeloccont.active = ACTIVE  ;
            agreeloccont.atcCodeStr = '' ;
            agreeloccont.contractType = 'CES Memorandum';
            agreeloccont.agreementTerm =  'Ad-Hoc';
            agreeloccont.applyFilter();
            Test.stopTest();
        }
    }
    
    public static testMethod void quickSearchQueryCondition(){
        createUser();
        system.runAs(u) {
            preparingData();
            Test.startTest();
            PageReference pageRef = Page.Agreementlocator;
            Test.setCurrentPageReference(pageRef);
            AgreementLocatorController agreeloccont  = new AgreementLocatorController();
            agreeloccont.quickSearchby = 'Account Local Name';
            agreeloccont.quickSearchByStr = 'Account Local Name';
            agreeloccont.quickSearchQueryCondition();
            agreeloccont.quickSearchATCCondition();
            agreeloccont.quickSearchby = 'Account Name';
            agreeloccont.quickSearchByStr = 'Account Name'+'\\';
            agreeloccont.quickSearchQueryCondition();
            agreeloccont.quickSearchATCCondition();
            agreeloccont.quickSearchby = 'Opportunity Number';
            agreeloccont.quickSearchByStr = 'Opportunity Number*';
            agreeloccont.quickSearchQueryCondition();
            agreeloccont.quickSearchATCCondition();
            agreeloccont.quickSearchby = 'Product Name';
            agreeloccont.quickSearchByStr = 'Product Name';
            agreeloccont.quickSearchQueryCondition();
            agreeloccont.quickSearchATCCondition();
            agreeloccont.quickSearchby = 'Agreement Number';
            agreeloccont.quickSearchByStr = 'Agreement Number';
            agreeloccont.quickSearchQueryCondition();
            agreeloccont.quickSearchATCCondition();
            agreeloccont.quickSearchby = 'Account Local Name';
            agreeloccont.quickSearchByStr = 'Account Local Name';
            agreeloccont.quickSearchQueryCondition();
            agreeloccont.quickSearchATCCondition();
            test.stopTest();
        }
    }
    
    public static testMethod void timeFrameQueryCondition(){
        createUser();
        system.runAs(u) {
            preparingData();
            Test.startTest();
            PageReference pageRef = Page.Agreementlocator;
            Test.setCurrentPageReference(pageRef);
            AgreementLocatorController agreeloccont  = new AgreementLocatorController();
            agreeloccont.timeFrame =  'Agreement Start Date';
            agreeloccont.timeFrameQueryCondition('','');
            agreeloccont.timeFrameATCCondition('','');
            agreeloccont.timeFrameQueryforAggLevel('','');
            agreeloccont.timeFrame = 'Agreement End Date';
            agreeloccont.timeFrameQueryCondition('','');
            agreeloccont.timeFrameATCCondition('','');
            agreeloccont.timeFrameQueryforAggLevel('','');
            agreeloccont.timeFrame =  'Signed Date';
            agreeloccont.timeFrameQueryCondition('','');
            agreeloccont.timeFrameATCCondition('','');
            agreeloccont.timeFrameQueryforAggLevel('','');
            agreeloccont.timeFrame = 'Data Period Start (Product)';
            agreeloccont.timeFrameQueryCondition('','');
            agreeloccont.timeFrameATCCondition('','');
            agreeloccont.timeFrameQueryforAggLevel('','');
            agreeloccont.timeFrame =  'Data Period End (Product)';
            agreeloccont.timeFrameQueryCondition('','');
            agreeloccont.timeFrameATCCondition('','');
            agreeloccont.timeFrameQueryforAggLevel('','');
            agreeloccont.timeFrame =    'Data Period Start (ATC)';
            agreeloccont.timeFrameQueryCondition('','');
            agreeloccont.timeFrameATCCondition('','');
            agreeloccont.timeFrameQueryforAggLevel('','');
            agreeloccont.timeFrame =   'Data Period End (ATC)';
            agreeloccont.timeFrameQueryCondition('','');
            agreeloccont.timeFrameATCCondition('','');
            agreeloccont.timeFrameQueryforAggLevel('','');
            Test.stopTest();
        }
    }  
    
    
    public static testMethod void testcasesForAttachNumber() {
        createUser();
        system.runAs(u) {
            preparingData();
            test.startTest();
            PageReference pageRef = Page.Agreementlocator;
            Test.setCurrentPageReference(pageRef);
            AgreementLocatorController agreeloccont  = new AgreementLocatorController();
       
            agreeloccont.quickSearchby = 'None' ;
            agreeloccont.contractType= 'None' ;
            agreeloccont.agreementTerm= 'None' ;
            agreeloccont.active= 'None' ;
            agreeloccont.applyFilter();
            Agreement__c testAgreement = [SELECT id FROM Agreement__c WHERE Name = 'testAgree1'];
            Agreement_Line_Item__c testLineItem1 = [SELECT id, attach_number__c FROM Agreement_Line_Item__c WHERE AgreementId__c =: testAgreement.Id];
            testLineItem1.attach_number__c = '123456';
            update testLineItem1;
            agreeloccont.attachNumber= '123456' ;
       
            agreeloccont.timeFrame = 'None';
            agreeloccont.applyFilter();
            agreeloccont.ExcelExport();
            Test.stopTest();
        }
    }
}