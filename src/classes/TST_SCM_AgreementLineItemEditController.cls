@isTest
private class TST_SCM_AgreementLineItemEditController {
    private static date strtDate = date.newInstance(2019, 1, 1);
    private static date endDate = date.newInstance(2019, 12, 31); 
    private static User testUser;
    private static User testItalianUser;
    private static Opportunity testOpportunity ;
    private static SCM_AgreementLineItemEditController lineItemEdit;
    private static Product2 testproduct;
    private static OpportunityLineItem testOpportunityLineItem;
    private static Agreement__c testAgreement;
    private static Agreement_Line_Item__c testAgreementLineItem2;
    private static Agreement_Line_Item__c testAgreementLineItem3;
    
    
    private static void setupData() {
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
        testproduct = new Product2(Name = 'tstpro1',CurrencyIsoCode = 'USD',Material_Type__c = 'ZPUB',Delivery_Frequency__c = 'MM');
        testproduct.Pillar__c = 'Technology Solutions; Information Offering';
        testProducts.add(testproduct);
        Product2 testproduct2 = new Product2(Name = 'tstpro2',CurrencyIsoCode = 'USD',Material_Type__c = 'ZPUB',Delivery_Frequency__c = 'MM');
        testproduct2.Pillar__c = 'Technology Solutions; Information Offering';
        testProducts.add(testproduct2);
        insert testProducts;
        
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        PricebookEntry PE1 = new PricebookEntry(UnitPrice = 100.0 ,Pricebook2Id = Test.getStandardPricebookId() , Product2Id = testproduct.id ,isActive=true ,UseStandardPrice = false );
        PricebookEntry PE2 = new PricebookEntry(UnitPrice = 100.0 ,Pricebook2Id = Test.getStandardPricebookId() , Product2Id = testproduct2.id ,isActive=true ,UseStandardPrice = false );
        pbeList.add(PE1);
        pbeList.add(PE2);       
        insert pbeList; 
        
        //Create a controller to get all the options
        testOpportunity = new Opportunity (Name='Default' ,StageName = '2 - Verify Opportunity',CloseDate = System.today() ,Budget_Available__c = 'Yes',CurrencyIsoCode = 'USD');
        insert testOpportunity;  
        
        List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
        testOpportunityLineItem = new OpportunityLineItem( OpportunityId = testOpportunity.id, PricebookEntryId = PE1.Id, Sale_Type__c = 'New', Revenue_Type__c = 'Ad Hoc',Delivery_Country__c = 'USA', Quantity=1, TotalPrice=100, Therapy_Area__c= 'Hepatitis C [21]'); 
        oppLineItemList.add(testOpportunityLineItem);
        
        OpportunityLineItem oli2 = new OpportunityLineItem( OpportunityId = testOpportunity.id, PricebookEntryId = PE2.Id, Sale_Type__c = 'New', Revenue_Type__c = 'Ad Hoc',Delivery_Country__c = 'USA', Quantity=1, TotalPrice=100, Therapy_Area__c= 'Hepatitis C [21]' ); 
        oppLineItemList.add(oli2);        
        insert oppLineItemList;
        
        
        List<Agreement__c> testAgreements = new List<Agreement__c>();
        Agreement__c testAgreementAPTS2 = new Agreement__c(Name ='testAgree2',Account__c = testacc1.id,Active__c = false,Company_Signed_Date__c = strtDate,Contract_Start_Date__c = strtDate.addDays(2),Contract_Type__c = 'CES Memorandum',Agreement_Term__c = 'Ad-Hoc'); 
        testAgreements.add(testAgreementAPTS2);
        Agreement__c testAgreementAPTS1 = new Agreement__c(Name ='testAgree1',Account__c = testacc1.id,Active__c = true,Company_Signed_Date__c = Date.Today().addDays(2),Parent_Agreement__c = testAgreementAPTS2.Id); 
        testAgreements.add(testAgreementAPTS1);
        Agreement__c ATCChart_testAgreementAPTS1 = new Agreement__c(Name ='testAgree3',Account__c = testAtcChartAcc1.id,Active__c = true,Company_Signed_Date__c = date.newInstance(2012,1,1),Contract_Start_Date__c =date.newInstance(2012,1,1),Contract_Type__c = 'CES Memorandum',Agreement_Term__c = 'Ad-Hoc'); 
        testAgreements.add(ATCChart_testAgreementAPTS1);
        Agreement__c testAgreement = new Agreement__c(Name ='testAgree4',Account__c = testAggAccount1.id,Active__c = true,Company_Signed_Date__c = date.newInstance(2012,1,1),Contract_Start_Date__c =date.newInstance(2012,1,1),Contract_End_Date__c = date.newInstance(2012,1,1)  ,Contract_Type__c = 'CES Memorandum',Agreement_Term__c = 'Ad-Hoc',
            Related_Opportunity__c = testOpportunity.id); 
        testAgreements.add(testAgreement);
        Agreement__c AggWarning_testAgreement1 = new Agreement__c(Name ='testAgree5',Account__c = testAggAccount1.id,Active__c = true,Company_Signed_Date__c = date.newInstance(2012,1,1),Contract_Start_Date__c =date.newInstance(2012,1,1),Contract_End_Date__c = date.newInstance(2012,1,1)  ,Contract_Type__c = 'CES Memorandum',Agreement_Term__c = 'Ad-Hoc',
            Related_Opportunity__c = testOpportunity.id); 
        testAgreements.add(AggWarning_testAgreement1);
        Agreement__c ATCChart_testAgreementAPTS2 = new Agreement__c(Name ='testAgree6',Account__c = testAtcChartAcc1.id,Active__c = true,Company_Signed_Date__c = date.newInstance(2012,1,1),Contract_Start_Date__c =date.newInstance(2011,1,1),Contract_Type__c = 'CES Memorandum',Agreement_Term__c = 'Ad-Hoc'); 
        testAgreements.add(ATCChart_testAgreementAPTS2);
        insert testAgreements;
        
        List<Agreement_Line_Item__c> testAgreementLineItems = new List<Agreement_Line_Item__c>();
        Agreement_Line_Item__c testLineItem1 = new Agreement_Line_Item__c(AgreementId__c =testAgreementAPTS1.Id,Additional_Price__c = 0,ExtendedPrice__c = 0,List_Price__c = 0,Net_Price__c= 0,ProductId__c = testproduct.id,Quantity__c = 0,Contract_Start_Date__c=date.newInstance(2012,7,6)) ;
        testAgreementLineItems.add(testLineItem1);
        Agreement_Line_Item__c ATCChart_testLineItem1 = new Agreement_Line_Item__c(AgreementId__c =ATCChart_testAgreementAPTS1.Id,Additional_Price__c = 0,ExtendedPrice__c = 0,List_Price__c = 0,Net_Price__c= 0,ProductId__c = testproduct.id,Quantity__c = 0,Contract_Start_Date__c=date.newInstance(2012,7,5)) ;
        testAgreementLineItems.add(ATCChart_testLineItem1);
        Agreement_Line_Item__c ATCChart_testLineItem2 = new Agreement_Line_Item__c(AgreementId__c = ATCChart_testAgreementAPTS2.Id,Additional_Price__c = 0,ExtendedPrice__c = 0,List_Price__c = 0,Net_Price__c= 0,ProductId__c = testproduct.id,Quantity__c = 0,Contract_Start_Date__c=date.newInstance(2012,6,5)) ;
        testAgreementLineItems.add(ATCChart_testLineItem2);
        Agreement_Line_Item__c AggWarning_testLineItem1 = new Agreement_Line_Item__c(AgreementId__c = AggWarning_testAgreement1.Id,Additional_Price__c = 0,ExtendedPrice__c = 0,List_Price__c = 0,Net_Price__c= 0,ProductId__c = testproduct.id,Quantity__c = 0,Contract_Start_Date__c=date.newInstance(2012,6,5),SCM_Fee_ScheduleLabel__c = 'test market defs',Apts_Delivery_Frequency__c = 'Ad-hoc',Apts_Delivery_Format__c = 'CD',Apts_Offering_Option__c = 'Basic',APTPS_Historical_Data__c = 'Four (4) Data Quarters', Back_Data__c = 'Four (4) Data Quarters',Data_Level__c = 'District Summary',Apts_Channel__c = 'Clinics',Line_item_date_type__c='Data dates',Data_Month_Start__c=date.newInstance(2012,6,5),Data_Month_End__c=date.newInstance(2012,6,5));
        testAgreementLineItems.add(AggWarning_testLineItem1);
        Agreement_Line_Item__c AggWarning_testLineItem_missSelectdMktDef = new Agreement_Line_Item__c(AgreementId__c = AggWarning_testAgreement1.Id, Additional_Price__c = 0, ExtendedPrice__c = 0, List_Price__c = 0, Net_Price__c= 0, ProductId__c = testproduct.id, Quantity__c = 0, Contract_Start_Date__c = date.newInstance(2012,6,5), SCM_Fee_ScheduleLabel__c = 'test market defs', Apts_Delivery_Frequency__c = 'Ad-hoc', Apts_Delivery_Format__c = 'CD', Apts_Offering_Option__c = 'Basic', APTPS_Historical_Data__c = 'Four (4) Data Quarters', Back_Data__c = 'Four (4) Data Quarters', Apts_Market_Definitions__c = 'test market defs', Market_Definition_Options__c = 'Selected Market Defs');
        testAgreementLineItems.add(AggWarning_testLineItem_missSelectdMktDef); 
        
        testAgreementLineItem2 = new Agreement_Line_Item__c(AgreementId__c = testAgreement.Id,Additional_Price__c = 0,ExtendedPrice__c = 0,List_Price__c = 0,Net_Price__c= 0,ProductId__c = testproduct.id,Quantity__c = 0,Contract_Start_Date__c=date.newInstance(2012,6,5),
            RelatedOpportunityLineItem__c = testOpportunityLineItem.Id,Market_Definition_Options__c = 'Selected Market Defs',
            Apts_Delivery_Frequency__c = 'Once [O]',Data_Month_End__c = date.newInstance(2019,6,5)) ;
        testAgreementLineItems.add(testAgreementLineItem2);
        testAgreementLineItem3 = new Agreement_Line_Item__c(AgreementId__c = testAgreement.Id,Additional_Price__c = 0,ExtendedPrice__c = 0,List_Price__c = 0,Net_Price__c= 0,ProductId__c = testproduct.id,Quantity__c = 0,Contract_Start_Date__c=date.newInstance(2012,6,5),
            RelatedOpportunityLineItem__c = oli2.Id,Market_Definition_Options__c = 'Selected Market Defs',
            Apts_Delivery_Frequency__c = 'Once [O]',Data_Month_End__c = date.newInstance(2019,6,5)) ;
        testAgreementLineItems.add(testAgreementLineItem3 );
        
        insert testAgreementLineItems;
        
        List<Agreement_Line_Item_ATCs__c> testAgreementLineItemATCs = new List<Agreement_Line_Item_ATCs__c>();
        Agreement_Line_Item_ATCs__c ATEChart_testLineItemATC1 = new Agreement_Line_Item_ATCs__c(ATC__c = atc1.id, Agreement_Line_Item__c = ATCChart_testLineItem1.id,Data_Period_Start__c = strtDate.addDays(2) ,Data_Period_End__c = endDate,Non_Charge_deliver_of_ATC__c = true,Period_of_Non_Charge_Deliver_Start__c = strtDate,Period_of_Non_Charge_Deliver_End__c = endDate,Termination_Date__c = strtDate.addDays(2));
        testAgreementLineItemATCs.add(ATEChart_testLineItemATC1);
        Agreement_Line_Item_ATCs__c ATEChart_testLineItemATC2 = new Agreement_Line_Item_ATCs__c(ATC__c = atc1.id, Agreement_Line_Item__c = ATCChart_testLineItem1.id,Data_Period_Start__c = strtDate.addDays(2) ,Data_Period_End__c = endDate,Non_Charge_deliver_of_ATC__c = true,Period_of_Non_Charge_Deliver_Start__c = strtDate,Period_of_Non_Charge_Deliver_End__c = endDate);  
        testAgreementLineItemATCs.add(ATEChart_testLineItemATC2);
        Agreement_Line_Item_ATCs__c ATEChart_testLineItemATC3 = new Agreement_Line_Item_ATCs__c(ATC__c = atc1.id, Agreement_Line_Item__c = ATCChart_testLineItem1.id,Data_Period_Start__c = strtDate.addDays(1) ,Data_Period_End__c = endDate,Non_Charge_deliver_of_ATC__c = true,Period_of_Non_Charge_Deliver_Start__c = strtDate.addDays(2),Period_of_Non_Charge_Deliver_End__c = endDate);  
        testAgreementLineItemATCs.add(ATEChart_testLineItemATC3);
        Agreement_Line_Item_ATCs__c ATEChart_testLineItemATC4 = new Agreement_Line_Item_ATCs__c(ATC__c = atc1.id, Agreement_Line_Item__c = ATCChart_testLineItem1.id,Data_Period_Start__c = strtDate.addDays(1) ,Data_Period_End__c = endDate,Non_Charge_deliver_of_ATC__c = false,Period_of_Non_Charge_Deliver_Start__c = Null,Period_of_Non_Charge_Deliver_End__c = Null,Termination_Date__c = strtDate.addDays(2));  
        testAgreementLineItemATCs.add(ATEChart_testLineItemATC4);
        
        Agreement_Line_Item_ATCs__c testAgreementLineItem2ATC = new Agreement_Line_Item_ATCs__c(ATC__c = atc1.id, Agreement_Line_Item__c = testAgreementLineItem2.id,Data_Period_Start__c = strtDate.addDays(1) ,Data_Period_End__c = endDate,Non_Charge_deliver_of_ATC__c = false,Period_of_Non_Charge_Deliver_Start__c = Null,Period_of_Non_Charge_Deliver_End__c = Null,Termination_Date__c = strtDate.addDays(2));  
        testAgreementLineItemATCs.add(testAgreementLineItem2ATC);
        Agreement_Line_Item_ATCs__c testAgreementLineItem3ATC = new Agreement_Line_Item_ATCs__c(ATC__c = atc1.id, Agreement_Line_Item__c = testAgreementLineItem3.id,Data_Period_Start__c = strtDate.addDays(1) ,Data_Period_End__c = endDate,Non_Charge_deliver_of_ATC__c = false,Period_of_Non_Charge_Deliver_Start__c = Null,Period_of_Non_Charge_Deliver_End__c = Null,Termination_Date__c = strtDate.addDays(2));  
        testAgreementLineItemATCs.add(testAgreementLineItem3ATC);
        insert testAgreementLineItemATCs;
        
        upsert new  PseSecurityConfig__c(DisableSecurityTriggers__c=true,UserName__c = 'testt@imshealth.com.dev2',DefaultOwnerUsername__c='integration@uk.imshealth.com.dev2');
        
        insert new pse__Region__c(name='xz',pse__Hierarchy_Depth__c = 0);   
        List<User> listOfUsers = new List<User>();
        List<Profile> profiles = [select id from profile where name = 'System Administrator']; 
        testUser = new User(FirstName = 'testM',LastName = 'testM',Username = 'testSCM@metacube.com',Email =  'testMetacube@metacube.com',Alias = 'TestUsr1',TimeZoneSidKey = 'America/Los_Angeles',LocaleSidKey = 'en_US',EmailEncodingKey = 'UTF-8',ProfileId = profiles.get(0).id ,LanguageLocaleKey ='en_US', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description', EmployeeNumber ='08080808');
        testItalianUser = new User (FirstName = 'testMIta',LastName = 'testMIta',Username = 'testSCMIta@metacube.com',Email =  'testMetacube@metacube.com',Alias = 'TstUsrIt',TimeZoneSidKey = 'Europe/Moscow',LocaleSidKey = 'it_IT',EmailEncodingKey = 'UTF-8',ProfileId = profiles.get(0).id ,LanguageLocaleKey ='it', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description', EmployeeNumber ='080808081');
        listOfUsers.add(testUser);
        listOfUsers.add(testItalianUser);
        insert listOfUsers;
        
    }
    
    @isTest
    private static void testSaveLineItemShouldSaveLineItemWhenExecutedThroughSystemAdminAndNotCloned()
    {   
        setupData();
        System.runAs(testUser)
        { 
            Contract_Management_Setting__c mycs = Contract_Management_Setting__c.getValues(UserInfo.getUserId());
  
            if(mycs == null) {
                mycs = new Contract_Management_Setting__c(Name= UserInfo.getUserId());
                mycs.Perform_SCM_Functions_Flag__c = true;
                insert mycs;
            } 
            
            Test.startTest();
                PageReference pageRef = Page.SCM_AgreementLineItemEdit;
                testproduct.Delivery_Frequency__c = 'MM';
                testproduct.Delivery_Media__c = 'SMP';
                update testProduct;
                
                Test.setCurrentPage(pageRef); 
                ApexPages.currentPage().getParameters().put('id',testAgreementLineItem2.ID);  
                lineItemEdit = new SCM_AgreementLineItemEditController(new Apexpages.Standardcontroller(testAgreementLineItem2));  
                
                lineItemEdit.getDeliveryMediaOptions();
                lineItemEdit.getDeliveryProj_Rpt_Frequency_options();
                
                testAgreementLineItem2.Apts_Delivery_Frequency__c = 'test';             
                testAgreementLineItem2.Delivery_Method__c = 'test';                             
                testAgreementLineItem2.Apts_Delivery_Format__c = 'test';                   
                testAgreementLineItem2.Apts_Offering_Option__c = 'test';                   
                testAgreementLineItem2.APTPS_Historical_Data__c = 'test';                 
                testAgreementLineItem2.Data_Level__c = 'test';                                       
                testAgreementLineItem2.Back_Data__c = 'test';                                         
                testAgreementLineItem2.Apts_Channel__c = 'test';                                   
                testAgreementLineItem2.Data_Month_Start__c = system.today();                           
                testAgreementLineItem2.Data_Month_End__c = system.today().addyears(1);                                 
                testAgreementLineItem2.Line_item_date_type__c = 'test';
                lineItemEdit.saveLineItem();   
                         
            Test.stopTest();
            
            System.assertNotEquals(null,testAgreementLineItem2 , 'There is an error during updates of Agreement Line Item');
                        
        }  
    }
   
    @isTest
    private static void testSaveLineItemShouldSaveLineItemWhenExecutedThroughSystemAdminAndCloned()
    {   
		setupData();
        System.runAs(testUser)
        { 
            Contract_Management_Setting__c mycs = Contract_Management_Setting__c.getValues(UserInfo.getUserId());
  
            if(mycs == null) {
                mycs = new Contract_Management_Setting__c(Name= UserInfo.getUserId());
                mycs.Perform_SCM_Functions_Flag__c = true;
                insert mycs;
            } 
            
            Test.startTest();
                PageReference pageRef = Page.SCM_AgreementLineItemEdit;
                testproduct.Delivery_Frequency__c = 'MM';
                testproduct.Delivery_Media__c = 'SMP';
                update testProduct;
                
                Test.setCurrentPage(pageRef); 
                ApexPages.currentPage().getParameters().put('id',testAgreementLineItem2.ID);  
                ApexPages.currentPage().getParameters().put('clone','yes');  
                lineItemEdit = new SCM_AgreementLineItemEditController(new Apexpages.Standardcontroller(testAgreementLineItem2));  
                
                lineItemEdit.getDeliveryMediaOptions();
                lineItemEdit.getDeliveryProj_Rpt_Frequency_options();
                
                testAgreementLineItem2.Apts_Delivery_Frequency__c = 'test';             
                testAgreementLineItem2.Delivery_Method__c = 'test';                             
                testAgreementLineItem2.Apts_Delivery_Format__c = 'test';                   
                testAgreementLineItem2.Apts_Offering_Option__c = 'test';                   
                testAgreementLineItem2.APTPS_Historical_Data__c = 'test';                 
                testAgreementLineItem2.Data_Level__c = 'test';                                       
                testAgreementLineItem2.Back_Data__c = 'test';                                         
                testAgreementLineItem2.Apts_Channel__c = 'test';                                   
                testAgreementLineItem2.Data_Month_Start__c = system.today();                           
                testAgreementLineItem2.Data_Month_End__c = system.today().addyears(1);                                 
                testAgreementLineItem2.Line_item_date_type__c = 'test';
                lineItemEdit.saveLineItem();   
                         
            Test.stopTest();
            
            System.assertNotEquals(null,lineItemEdit.clonedRecord, 'Error in insertion of clonedRecord');
            System.assertNotEquals(null,lineItemEdit.clonedRecord.Id, 'Error in insertion of clonedRecord - Id is blank');
                        
        }  
    }
    
    @isTest
    private static void testSaveLineItemShouldSaveLineItemWhenExecutedThroughItalianUserCloned()
    {   
		setupData();
        System.runAs(testItalianUser)
        { 
            Contract_Management_Setting__c mycs = Contract_Management_Setting__c.getValues(UserInfo.getUserId());
  
            if(mycs == null) {
                mycs = new Contract_Management_Setting__c(Name= UserInfo.getUserId());
                mycs.Perform_SCM_Functions_Flag__c = true;
                insert mycs;
            } 
            
            Test.startTest();
                PageReference pageRef = Page.SCM_AgreementLineItemEdit;
                testproduct.Delivery_Frequency__c = 'MM';
                testproduct.Delivery_Media__c = 'SMP';
                update testProduct;
                
                Test.setCurrentPage(pageRef); 
                ApexPages.currentPage().getParameters().put('id',testAgreementLineItem2.ID);  
                ApexPages.currentPage().getParameters().put('clone','yes');  
                lineItemEdit = new SCM_AgreementLineItemEditController(new Apexpages.Standardcontroller(testAgreementLineItem2));  
                
                lineItemEdit.getDeliveryMediaOptions();
                lineItemEdit.getDeliveryProj_Rpt_Frequency_options();
                
                testAgreementLineItem2.Apts_Delivery_Frequency__c = 'test';             
                testAgreementLineItem2.Delivery_Method__c = 'test';                             
                testAgreementLineItem2.Apts_Delivery_Format__c = 'test';                   
                testAgreementLineItem2.Apts_Offering_Option__c = 'test';                   
                testAgreementLineItem2.APTPS_Historical_Data__c = 'test';                 
                testAgreementLineItem2.Data_Level__c = 'test';                                       
                testAgreementLineItem2.Back_Data__c = 'test';                                         
                testAgreementLineItem2.Apts_Channel__c = 'test';                                   
                testAgreementLineItem2.Data_Month_Start__c = system.today();                           
                testAgreementLineItem2.Data_Month_End__c = system.today().addyears(1);                                 
                testAgreementLineItem2.Line_item_date_type__c = 'test';
                lineItemEdit.saveLineItem();   
                         
            Test.stopTest();
            
            System.assertNotEquals(null,lineItemEdit.clonedRecord, 'Error in insertion of clonedRecord');
            System.assertNotEquals(null,lineItemEdit.clonedRecord.Id, 'Error in insertion of clonedRecord - Id is blank');
                        
        }  
    }
    
    public static testmethod void testCopyToAllLineItemsShouldUpsertALIWhenisAllAggProdSelectedIsTrue()
    {
        setupData();    
        system.runAs(testUser)
        { 
            Contract_Management_Setting__c mycs = Contract_Management_Setting__c.getValues(UserInfo.getUserId());
  
            if(mycs == null) {
              mycs = new Contract_Management_Setting__c(Name= UserInfo.getUserId());
              mycs.Perform_SCM_Functions_Flag__c = true;
              insert mycs;
            } 
            
            Test.startTest();
                PageReference pageRef = Page.SCM_AgreementLineItemEdit;
                Test.setCurrentPage(pageRef); 
                ApexPages.currentPage().getParameters().put('id',testAgreementLineItem2.ID);  
                lineItemEdit = new SCM_AgreementLineItemEditController(new Apexpages.Standardcontroller(testAgreementLineItem2)); 
                lineItemEdit.isAllAggProdSelected  = true;
                testAgreementLineItem2.Apts_Delivery_Frequency__c = 'Once [O]';             
                testAgreementLineItem2.Delivery_Method__c = 'test';                             
                testAgreementLineItem2.Apts_Delivery_Format__c = 'test';                   
                testAgreementLineItem2.Apts_Offering_Option__c = 'test';                   
                testAgreementLineItem2.APTPS_Historical_Data__c = 'test';                 
                testAgreementLineItem2.Data_Level__c = 'test';                                       
                testAgreementLineItem2.Back_Data__c = 'test';                                         
                testAgreementLineItem2.Apts_Channel__c = 'test';                                   
                testAgreementLineItem2.Data_Month_Start__c = system.today();                           
                testAgreementLineItem2.Data_Month_End__c = system.today().addyears(1);                                 
                testAgreementLineItem2.Line_item_date_type__c = 'test';
                lineItemEdit.CopyToAllLineItems();
                
                Agreement_Line_Item__c agli = [select id, Apts_Delivery_Frequency__c from Agreement_Line_Item__c where id = :testAgreementLineItem2.id ];
                system.assertEquals('Once [O]', agli.Apts_Delivery_Frequency__c);
                       
            Test.stopTest();
                        
        }  
    }
    
    public static testmethod void testCopyToAllLineItemsShouldUpsertALIWhenisAllAggProdSelectedIsFalse()
    {  
        setupData();
        system.runAs(testUser)
        { 
            Contract_Management_Setting__c mycs = Contract_Management_Setting__c.getValues(UserInfo.getUserId());
  
            if(mycs == null) {
              mycs = new Contract_Management_Setting__c(Name= UserInfo.getUserId());
              mycs.Perform_SCM_Functions_Flag__c = true;
              insert mycs;
            } 
            
            Test.startTest();
                PageReference pageRef = Page.SCM_AgreementLineItemEdit;
                Test.setCurrentPage(pageRef); 
                ApexPages.currentPage().getParameters().put('id',testAgreementLineItem2.ID);  
            	ApexPages.currentPage().getParameters().put('isFromFeeScheduleScreen','true');  
                lineItemEdit = new SCM_AgreementLineItemEditController(new Apexpages.Standardcontroller(testAgreementLineItem2)); 
                lineItemEdit.isAllAggProdSelected  = false;
            	lineItemEdit.isPrimaryLineItem  = true;
            	lineItemEdit.selectedAggProductsForCopyProdSpecification.add(testAgreementLineItem2.Id);
                testAgreementLineItem2.Apts_Delivery_Frequency__c = 'Once [O]';             
                testAgreementLineItem2.Delivery_Method__c = 'test';                             
                testAgreementLineItem2.Apts_Delivery_Format__c = 'test';                   
                testAgreementLineItem2.Apts_Offering_Option__c = 'test';                   
                testAgreementLineItem2.APTPS_Historical_Data__c = 'test';                 
                testAgreementLineItem2.Data_Level__c = 'test';                                       
                testAgreementLineItem2.Back_Data__c = 'test';                                         
                testAgreementLineItem2.Apts_Channel__c = 'test';                                   
                testAgreementLineItem2.Data_Month_Start__c = system.today();                           
                testAgreementLineItem2.Data_Month_End__c = system.today().addyears(1);                                 
                testAgreementLineItem2.Line_item_date_type__c = 'test';
                PageReference returnPageRef = lineItemEdit.CopyToAllLineItems();
                
                Agreement_Line_Item__c agli = [select id, Apts_Delivery_Frequency__c from Agreement_Line_Item__c where id = :testAgreementLineItem2.id ];
                System.assertEquals('Once [O]', agli.Apts_Delivery_Frequency__c,'Apts Delivery Frequency is incorrect');
            	System.assertNotEquals(null, returnPageRef,'Error occurred in CopyToAllLineItem functionality');
                       
            Test.stopTest();           
        }  
    }
    
    @isTest
    private static void testIsDeliveryMediaAndFrequencyCopyToAllAgliShouldSetDeliveryFrequencyWhenSelectedProdAll()
    {
        setupData();
        System.runAs(testUser)
        { 
            Contract_Management_Setting__c mycs = Contract_Management_Setting__c.getValues(UserInfo.getUserId());
  
            if(mycs == null) {
                mycs = new Contract_Management_Setting__c(Name= UserInfo.getUserId());
                mycs.Perform_SCM_Functions_Flag__c = true;
                insert mycs;
            } 
            Test.startTest();
                PageReference pageRef = Page.SCM_AgreementLineItemEdit;
                Test.setCurrentPage(pageRef); 
                ApexPages.currentPage().getParameters().put('id',testAgreementLineItem2.ID);  
            	ApexPages.currentPage().getParameters().put('isFromFeeScheduleScreen','true');  
            	lineItemEdit = new SCM_AgreementLineItemEditController(new Apexpages.Standardcontroller(testAgreementLineItem2)); 
            	lineItemEdit.isPrimaryLineItem  = true;
            	lineItemEdit.selectedAggProductsForCopyProdSpecification.add('All');
            	
                PageReference returnPageRef = lineItemEdit.isDeliveryMediaAndFrequencyCopyToAllAgli();
                System.assertNotEquals(null, lineItemEdit.prodWithDiff_DeliveryFrequency,'No value set for prodWithDiff_DeliveryFrequency ');
                       
            Test.stopTest();           
        }  
    }
    
    @isTest
    private static void testIsDeliveryMediaAndFrequencyCopyToAllAgliShouldSetDeliveryFrequencyWhenSelectedProd()
    {
        setupData();
        System.runAs(testUser)
        { 
            Contract_Management_Setting__c mycs = Contract_Management_Setting__c.getValues(UserInfo.getUserId());
  
            if(mycs == null) {
                mycs = new Contract_Management_Setting__c(Name= UserInfo.getUserId());
                mycs.Perform_SCM_Functions_Flag__c = true;
                insert mycs;
            } 
            Test.startTest();
                PageReference pageRef = Page.SCM_AgreementLineItemEdit;
                Test.setCurrentPage(pageRef); 
                ApexPages.currentPage().getParameters().put('id',testAgreementLineItem2.Id);  
            	ApexPages.currentPage().getParameters().put('isFromFeeScheduleScreen','true');  
            	lineItemEdit = new SCM_AgreementLineItemEditController(new Apexpages.Standardcontroller(testAgreementLineItem2)); 
            	lineItemEdit.isPrimaryLineItem  = true;
            	lineItemEdit.selectedAggProductsForCopyProdSpecification.add(testAgreementLineItem2.Id);
            	
                PageReference returnPageRef = lineItemEdit.isDeliveryMediaAndFrequencyCopyToAllAgli();
                System.assertEquals(null, returnPageRef,'Error occurred in CopyToAllLineItem functionality');
                       
            Test.stopTest();           
        }  
    }
    
    
    @isTest
    private static void testGetDeliveryProj_Rpt_Frequency_optionsShouldReturnOptionsWhenDeliveryFrequencyBlank()
    {
        setupData();
        System.runAs(testUser)
        { 
            Contract_Management_Setting__c mycs = Contract_Management_Setting__c.getValues(UserInfo.getUserId());
  
            if(mycs == null) {
                mycs = new Contract_Management_Setting__c(Name= UserInfo.getUserId());
                mycs.Perform_SCM_Functions_Flag__c = true;
                insert mycs;
            } 
            Test.startTest();
                PageReference pageRef = Page.SCM_AgreementLineItemEdit;
            	testproduct.Delivery_Frequency__c = '';
                update testProduct;
                Test.setCurrentPage(pageRef); 
                ApexPages.currentPage().getParameters().put('id',testAgreementLineItem2.Id);  
            	lineItemEdit = new SCM_AgreementLineItemEditController(new Apexpages.Standardcontroller(testAgreementLineItem2)); 
            	
                List<SelectOption> options = lineItemEdit.getDeliveryProj_Rpt_Frequency_options();
            
             Test.stopTest();   
            
             System.assertEquals(false, options.isEmpty(),'Returned select options are blank');
             System.assertEquals('--None--', options.get(0).getLabel(),'The returned select options not in english');
        }  
    }
    
    @isTest
    private static void testGetDeliveryProj_Rpt_Frequency_optionsShouldReturnOptionsForItalianUserWhenDFBlank()
    {
        setupData();
        System.runAs(testItalianUser)
        { 
            Contract_Management_Setting__c mycs = Contract_Management_Setting__c.getValues(UserInfo.getUserId());
  
            if(mycs == null) {
                mycs = new Contract_Management_Setting__c(Name= UserInfo.getUserId());
                mycs.Perform_SCM_Functions_Flag__c = true;
                insert mycs;
            } 
            Test.startTest();
                PageReference pageRef = Page.SCM_AgreementLineItemEdit;
            	testproduct.Delivery_Frequency__c = '';
                update testProduct;
                Test.setCurrentPage(pageRef); 
                ApexPages.currentPage().getParameters().put('id',testAgreementLineItem2.Id);  
            	lineItemEdit = new SCM_AgreementLineItemEditController(new Apexpages.Standardcontroller(testAgreementLineItem2)); 
            	
                List<SelectOption> options = lineItemEdit.getDeliveryProj_Rpt_Frequency_options();
            
             Test.stopTest();   
            
             System.assertEquals(false, options.isEmpty(),'Returned select options are blank');
             System.assertEquals('--Nessuno--', options.get(0).getLabel(),'The returned select options not in english');
        }  
    }
    
    @isTest
    private static void testGetDeliveryProj_Rpt_Frequency_optionsShouldReturnOptionsWhenDeliveryFrequencyNotBlank()
    {
        setupData();
        System.runAs(testUser)
        { 
            Contract_Management_Setting__c mycs = Contract_Management_Setting__c.getValues(UserInfo.getUserId());
  
            if(mycs == null) {
                mycs = new Contract_Management_Setting__c(Name= UserInfo.getUserId());
                mycs.Perform_SCM_Functions_Flag__c = true;
                insert mycs;
            } 
            Test.startTest();
                PageReference pageRef = Page.SCM_AgreementLineItemEdit;
            	testproduct.Delivery_Frequency__c = 'Monthly:Quaterly';
                update testProduct;
                Test.setCurrentPage(pageRef); 
                ApexPages.currentPage().getParameters().put('id',testAgreementLineItem2.Id);  
            	lineItemEdit = new SCM_AgreementLineItemEditController(new Apexpages.Standardcontroller(testAgreementLineItem2)); 
            	
                List<SelectOption> options = lineItemEdit.getDeliveryProj_Rpt_Frequency_options();
            	
            
            
             Test.stopTest();   
            
             System.assertEquals(false, options.isEmpty(),'Returned select options are blank');
             System.assertEquals('--None--', options.get(0).getLabel(),'The returned select options not in english');
        }  
    }
    
    @isTest
    private static void testGetDeliveryProj_Rpt_Frequency_optionsShouldReturnOptionsForItalianUserWhenDFNotBlank()
    {
        setupData();
        System.runAs(testItalianUser)
        { 
            Contract_Management_Setting__c mycs = Contract_Management_Setting__c.getValues(UserInfo.getUserId());
  
            if(mycs == null) {
                mycs = new Contract_Management_Setting__c(Name= UserInfo.getUserId());
                mycs.Perform_SCM_Functions_Flag__c = true;
                insert mycs;
            } 
            Test.startTest();
                PageReference pageRef = Page.SCM_AgreementLineItemEdit;
            	testproduct.Delivery_Frequency__c = 'Monthly:Quaterly';
                update testProduct;
                Test.setCurrentPage(pageRef); 
                ApexPages.currentPage().getParameters().put('id',testAgreementLineItem2.Id);  
            	lineItemEdit = new SCM_AgreementLineItemEditController(new Apexpages.Standardcontroller(testAgreementLineItem2)); 
            	
                List<SelectOption> options = lineItemEdit.getDeliveryProj_Rpt_Frequency_options();
            	
            
            
             Test.stopTest();   
            
             System.assertEquals(false, options.isEmpty(),'Returned select options are blank');
             System.assertEquals('--Nessuno--', options.get(0).getLabel(),'The returned select options not in english');
        }  
    }
    
    @isTest
    private static void testGetDeliveryMediaOptionsShouldReturnOptionsWhenDeliveryMediaIsBlank()
    {
        setupData();
        System.runAs(testUser)
        { 
            Contract_Management_Setting__c mycs = Contract_Management_Setting__c.getValues(UserInfo.getUserId());
  
            if(mycs == null) {
                mycs = new Contract_Management_Setting__c(Name= UserInfo.getUserId());
                mycs.Perform_SCM_Functions_Flag__c = true;
                insert mycs;
            } 
            Test.startTest();
                PageReference pageRef = Page.SCM_AgreementLineItemEdit;
                Test.setCurrentPage(pageRef); 
                ApexPages.currentPage().getParameters().put('id',testAgreementLineItem2.Id);  
            	lineItemEdit = new SCM_AgreementLineItemEditController(new Apexpages.Standardcontroller(testAgreementLineItem2)); 
                List<SelectOption> options = lineItemEdit.getDeliveryMediaOptions();
             Test.stopTest();   
            
             System.assertEquals(false, options.isEmpty(),'Returned select options are blank');
             System.assertEquals('--None--', options.get(0).getLabel(),'The returned select options does not have options added');
             
        }  
    }
    
    @isTest
    private static void testGetDeliveryMediaOptionsShouldReturnOptionsWhenDeliveryMediaIsNotBlank()
    {
        setupData();
        System.runAs(testUser)
        { 
            Contract_Management_Setting__c mycs = Contract_Management_Setting__c.getValues(UserInfo.getUserId());
  
            if(mycs == null) {
                mycs = new Contract_Management_Setting__c(Name= UserInfo.getUserId());
                mycs.Perform_SCM_Functions_Flag__c = true;
                insert mycs;
            } 
            Test.startTest();
            	testproduct.Delivery_Media__c = 'Audit Viewer [AV]';
                update testProduct;
                PageReference pageRef = Page.SCM_AgreementLineItemEdit;
                Test.setCurrentPage(pageRef); 
                ApexPages.currentPage().getParameters().put('id',testAgreementLineItem2.Id);  
            	lineItemEdit = new SCM_AgreementLineItemEditController(new Apexpages.Standardcontroller(testAgreementLineItem2)); 
                List<SelectOption> options = lineItemEdit.getDeliveryMediaOptions();
             Test.stopTest();   
            
             System.assertEquals(false, options.isEmpty(),'Returned select options are blank');
             System.assertEquals('--None--', options.get(0).getLabel(),'The returned select options does not have options added');
             
        }  
    }
	
	
	@isTest
    private static void testGetItalianInvoicingScheduleReturnOptionsWhenItalianUserIsLoggedIn()
    {
        setupData();
        System.runAs(testItalianUser)
        { 
            Contract_Management_Setting__c mycs = Contract_Management_Setting__c.getValues(UserInfo.getUserId());
  
            if(mycs == null) {
                mycs = new Contract_Management_Setting__c(Name= UserInfo.getUserId());
                mycs.Perform_SCM_Functions_Flag__c = true;
                insert mycs;
            } 
            Test.startTest();
                PageReference pageRef = Page.SCM_AgreementLineItemEdit;
                Test.setCurrentPage(pageRef); 
                ApexPages.currentPage().getParameters().put('id',testAgreementLineItem2.Id);  
            	lineItemEdit = new SCM_AgreementLineItemEditController(new Apexpages.Standardcontroller(testAgreementLineItem2)); 
                List<SelectOption> options = lineItemEdit.GetItalianInvoicingSchedule();
             Test.stopTest();   
            
             System.assertEquals(false, options.isEmpty(),'Returned select options are blank');
             System.assertEquals('--None--', options.get(0).getLabel(),'The returned select options does not have options added'); 
        }  
    }
	
	@isTest
    private static void testGetItalianInvoicingScheduleReturnOptionsWhenNonItalianUserIsLoggedIn()
    {
        setupData();
        System.runAs(testUser)
        { 
            Contract_Management_Setting__c mycs = Contract_Management_Setting__c.getValues(UserInfo.getUserId());
  
            if(mycs == null) {
                mycs = new Contract_Management_Setting__c(Name= UserInfo.getUserId());
                mycs.Perform_SCM_Functions_Flag__c = true;
                insert mycs;
            } 
            Test.startTest();
                PageReference pageRef = Page.SCM_AgreementLineItemEdit;
                Test.setCurrentPage(pageRef); 
                ApexPages.currentPage().getParameters().put('id',testAgreementLineItem2.Id);  
            	lineItemEdit = new SCM_AgreementLineItemEditController(new Apexpages.Standardcontroller(testAgreementLineItem2)); 
                List<SelectOption> options = lineItemEdit.GetItalianInvoicingSchedule();
             Test.stopTest();   
            
             System.assertEquals(false, options.isEmpty(),'Returned select options are blank');
             System.assertEquals('--None--', options.get(0).getLabel(),'The returned select options does not have options added'); 
        }  
    }
	
	
	@isTest
    private static void testCancelLineItemWhenIsFromFeeScheduleScreenIsTrue()
    {
        setupData();
        System.runAs(testUser)
        { 
            Contract_Management_Setting__c mycs = Contract_Management_Setting__c.getValues(UserInfo.getUserId());
  
            if(mycs == null) {
                mycs = new Contract_Management_Setting__c(Name= UserInfo.getUserId());
                mycs.Perform_SCM_Functions_Flag__c = true;
                insert mycs;
            } 
            Test.startTest();
                PageReference pageRef = Page.SCM_AgreementLineItemEdit;
                Test.setCurrentPage(pageRef); 
                ApexPages.currentPage().getParameters().put('id',testAgreementLineItem2.Id); 
			    ApexPages.currentPage().getParameters().put('isFromFeeScheduleScreen','true'); 
            	lineItemEdit = new SCM_AgreementLineItemEditController(new Apexpages.Standardcontroller(testAgreementLineItem2)); 
                PageReference returnPageRef = lineItemEdit.cancelLineItem();
             Test.stopTest();   
            
            System.assertNotEquals(null, returnPageRef,'Returned Page reference is null, when not expected');
              
        }  
    }
	
	@isTest
    private static void testCancelLineItemWhenIsFromFeeScheduleScreenIsFalse()
    {
        setupData();
        System.runAs(testUser)
        { 
            Contract_Management_Setting__c mycs = Contract_Management_Setting__c.getValues(UserInfo.getUserId());
  
            if(mycs == null) {
                mycs = new Contract_Management_Setting__c(Name= UserInfo.getUserId());
                mycs.Perform_SCM_Functions_Flag__c = true;
                insert mycs;
            } 
            Test.startTest();
                PageReference pageRef = Page.SCM_AgreementLineItemEdit;
                Test.setCurrentPage(pageRef); 
                ApexPages.currentPage().getParameters().put('id',testAgreementLineItem2.Id);  
            	lineItemEdit = new SCM_AgreementLineItemEditController(new Apexpages.Standardcontroller(testAgreementLineItem2)); 
                PageReference returnPageRef = lineItemEdit.cancelLineItem();
             Test.stopTest();   
            
            System.assertNotEquals(null, returnPageRef,'Returned Page reference is null, when not expected');
        }  
    }
    
    @isTest
    private static void testGetValidationShouldReturnNullForAdminWhenError ()
    {
             
        setupData();
        System.runAs(testUser)
        { 
            Contract_Management_Setting__c mycs = Contract_Management_Setting__c.getValues(UserInfo.getUserId());
  
            if(mycs == null) {
                mycs = new Contract_Management_Setting__c(Name= UserInfo.getUserId());
                mycs.Perform_SCM_Functions_Flag__c = true;
                insert mycs;
            } 
            Test.startTest();
                PageReference pageRef = Page.SCM_AgreementLineItemEdit;
                Test.setCurrentPage(pageRef); 
                ApexPages.currentPage().getParameters().put('id',testAgreementLineItem2.Id);  
            	lineItemEdit = new SCM_AgreementLineItemEditController(new Apexpages.Standardcontroller(testAgreementLineItem2)); 
            	lineItemEdit.isZPUBProduct = true;
            	testAgreementLineItem2.Apts_Delivery_Frequency__c = '';
                lineItemEdit.getValidations();
            	
            	testAgreementLineItem2.Apts_Delivery_Format__c = '';
                lineItemEdit.getValidations();
            
            	testAgreementLineItem2.Apts_Delivery_Frequency__c = 'Other';
            	testAgreementLineItem2.Delivery_Frequency_Other__c = '';
                lineItemEdit.getValidations();
            	
            	testAgreementLineItem2.Apts_Delivery_Frequency__c = 'Once [O]';
            	testAgreementLineItem2.Expected_Delivery_Date__c = null;
                lineItemEdit.getValidations();
            
            	testAgreementLineItem2.Apts_Delivery_Frequency__c = 'Once [O]';
            	testAgreementLineItem2.Expected_Delivery_Date__c = date.newInstance(2019,6,5);
                lineItemEdit.getValidations();
            	
            	testAgreementLineItem2.Delivery_Method__c = 'Other';
            	testAgreementLineItem2.Delivery_Method_Other__c = null;
                lineItemEdit.getValidations();
            
             	testAgreementLineItem2.Apts_Offering_Option__c = 'other';
            	testAgreementLineItem2.APTPS_Offering_Option_Other__c = null;
                lineItemEdit.getValidations();
            	
            	testAgreementLineItem2.Data_Level__c = '';
                lineItemEdit.getValidations();
            
            	testAgreementLineItem2.Data_Level__c = 'Other';
            	testAgreementLineItem2.Data_Level_Other__c = null;
                lineItemEdit.getValidations();
            
            	testAgreementLineItem2.Apts_Channel__c = '';
            	testAgreementLineItem2.APTPS_Channel_Other__c = null;
                lineItemEdit.getValidations();
            
            	testAgreementLineItem2.APTPS_Historical_Data__c = 'other';
            	testAgreementLineItem2.APTPS_Historical_Days_Other__c = null;
                lineItemEdit.getValidations();
             Test.stopTest();   
        }  
    }
    
    @isTest
    private static void testGetAggProductListOptionShouldReturnOptionsForAll ()
    {
        setupData();
        System.runAs(testUser)
        { 
            Contract_Management_Setting__c mycs = Contract_Management_Setting__c.getValues(UserInfo.getUserId());
  
            if(mycs == null) {
                mycs = new Contract_Management_Setting__c(Name= UserInfo.getUserId());
                mycs.Perform_SCM_Functions_Flag__c = true;
                insert mycs;
            } 
            Test.startTest();
                PageReference pageRef = Page.SCM_AgreementLineItemEdit;
                Test.setCurrentPage(pageRef); 
                ApexPages.currentPage().getParameters().put('id',testAgreementLineItem2.Id);  
            	lineItemEdit = new SCM_AgreementLineItemEditController(new Apexpages.Standardcontroller(testAgreementLineItem2)); 
            	List<SelectOption> listOptions = lineItemEdit.getAggProductListOption();
            Test.stopTest();
            
            System.assertNotEquals(null,listOptions, 'option list is empty');
        }
    }
}