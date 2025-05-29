@isTest
private class TST_SCM_EditAll_ALI_ATCs {
    private static User testUser;
    private static SCM_EditAll_ALI_ATCs scmEditAllController;
    private static Agreement__c activeAgreement,inActiveAgreement;
    private static Agreement_Line_Item__c testAgreementLineItem;
    private static Account imsHealthAccount,testAccount;
    private static ATC__c atcObj;
    private static Product2 testproduct;
    private static  date strtDate = Date.newInstance(2019, 1, 1);
    private static date endDate = Date.newInstance(2019, 12, 31);
    
   
	private static void setupData() {
        List<Account> listOfAccount = new List<Account>();
        imsHealthAccount = new Account(Name = 'IMS Health Global',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');       
        listOfAccount.add(imsHealthAccount);
        
        testAccount = new Account(Name = 'Test',CurrencyIsoCode = 'USD',Region_Territory__c = 'India',Industry_IMS__c = 'Biotech',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        listOfAccount.add(testAccount);
        insert listOfAccount;
        //Updated By:-Ekta , Date :-9th Dec, 2014 , Details - Add Material Type(4th Dec Deployment)
        testproduct = new Product2(Name = 'test prod',CurrencyIsoCode = 'USD',Material_Type__c = 'ZPUB');
        testproduct.Pillar__c = 'Technology Solutions; Information Offering';
        insert testproduct;
        
        atcObj = new ATC__c(ATC_Code__c = 'J07C',CurrencyIsoCode= 'USD',RecordTypeId = ConstantClass.getRecordTypeId('ATC__c','ATC'));
        insert atcObj;
        
        List<Agreement__c> agreements = new List<Agreement__c>();
        inActiveAgreement = new Agreement__c(Name ='testAgree2',Account__c = testAccount.id,Active__c = false,
        	Company_Signed_Date__c = strtDate,Contract_Start_Date__c = strtDate.addDays(2),
            Contract_Type__c = 'CES Memorandum',Agreement_Term__c = 'Ad-Hoc'); 
        agreements.add(inActiveAgreement);
        activeAgreement= new Agreement__c(Name ='testAgree1',Account__c = testAccount.id,Active__c = true,
        	Company_Signed_Date__c = Date.Today().addDays(2),Parent_Agreement__c = inActiveAgreement.Id,
            Status_Category__c = 'In Authoring'); 
        agreements.add(activeAgreement);
        insert agreements;
         
        List<Agreement_Line_Item__c> testAgreementLineItems = new List<Agreement_Line_Item__c>();
        testAgreementLineItem = new Agreement_Line_Item__c(AgreementId__c =activeAgreement.Id,Additional_Price__c = 0,
        	ExtendedPrice__c = 0,List_Price__c = 0,Net_Price__c= 0,ProductId__c = testproduct.id,Quantity__c = 0,
          	Contract_Start_Date__c=date.newInstance(2012,7,6),Invoicing_Schedule__c = 'Annual',
            Apts_DAP__c = 'Other') ;
        testAgreementLineItems.add(testAgreementLineItem);
        insert testAgreementLineItems;  
        
        List<Agreement_Line_Item_ATCs__c> testAgreementLineItemATCs = new List<Agreement_Line_Item_ATCs__c>();
        Agreement_Line_Item_ATCs__c agreementLineItemATC1 = new Agreement_Line_Item_ATCs__c(ATC__c = atcObj.id, 
            Agreement_Line_Item__c = testAgreementLineItem.id,Data_Period_Start__c = strtDate.addDays(2) ,
            Data_Period_End__c = endDate,Non_Charge_deliver_of_ATC__c = true,
            Period_of_Non_Charge_Deliver_Start__c = strtDate,Period_of_Non_Charge_Deliver_End__c = endDate,
            Termination_Date__c = strtDate.addDays(2));
        testAgreementLineItemATCs.add(agreementLineItemATC1);
        Agreement_Line_Item_ATCs__c agreementLineItemATC2 = new Agreement_Line_Item_ATCs__c(ATC__c = atcObj.id, 
        	Agreement_Line_Item__c = testAgreementLineItem.id,Data_Period_Start__c = strtDate.addDays(2) ,
            Data_Period_End__c = endDate,Non_Charge_deliver_of_ATC__c = true,
            Period_of_Non_Charge_Deliver_Start__c = strtDate,Period_of_Non_Charge_Deliver_End__c = endDate);  
        testAgreementLineItemATCs.add(agreementLineItemATC2);
        insert testAgreementLineItemATCs;
        
        
        upsert new  PseSecurityConfig__c(DisableSecurityTriggers__c=true,UserName__c = 'testt@imshealth.com.dev2',DefaultOwnerUsername__c='integration@uk.imshealth.com.dev2');
        
        insert new pse__Region__c(name='xz',pse__Hierarchy_Depth__c = 0);   
        List<User> listOfUsers = new List<User>();
        List<Profile> profiles = [select id from profile where name = 'System Administrator']; 
        testUser = new User(FirstName = 'testM',LastName = 'testM',Username = 'testSCM@metacube.com',Email =  'testMetacube@metacube.com',Alias = 'TestUsr1',TimeZoneSidKey = 'America/Los_Angeles',LocaleSidKey = 'en_US',EmailEncodingKey = 'UTF-8',ProfileId = profiles.get(0).id ,LanguageLocaleKey ='en_US', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description', EmployeeNumber ='08080808');
        listOfUsers.add(testUser);
        insert listOfUsers;
    }
    
    @isTest
    private static void testSCM_EditAll_ALI_ATCsShouldSetWrapperWhenAgreementLineItemPassed(){
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
                PageReference pageRef = Page.SCM_EditAgreementLineItemATCs;
                Test.setCurrentPage(pageRef); 
                ApexPages.currentPage().getParameters().put('ALI_Id',testAgreementLineItem.Id); 
            	scmEditAllController = new SCM_EditAll_ALI_ATCs();
            Test.stopTest();
    	}
    }
    
    @isTest
    private static void testSaveShouldUpdateALIATCsWhenValidAgreementLineItemPassed(){
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
                PageReference pageRef = Page.SCM_EditAgreementLineItemATCs;
                Test.setCurrentPage(pageRef); 
                ApexPages.currentPage().getParameters().put('ALI_Id',testAgreementLineItem.Id); 
            	scmEditAllController = new SCM_EditAll_ALI_ATCs();
            	scmEditAllController.wrapList.get(0).isSelected = true;
            	pageReference returedPageRef = scmEditAllController.save();
            Test.stopTest();
            
            System.assertNotEquals(null,returedPageRef,'Exception occurred during save operation');
            
    	}
    }
    
    @isTest
    private static void testCancelShouldReturnPageRefWhenAgreementLineItemPassed(){
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
                PageReference pageRef = Page.SCM_EditAgreementLineItemATCs;
                Test.setCurrentPage(pageRef); 
                ApexPages.currentPage().getParameters().put('ALI_Id',testAgreementLineItem.Id); 
            	scmEditAllController = new SCM_EditAll_ALI_ATCs();
            	scmEditAllController.wrapList.get(0).isSelected = true;
            	pageReference returedPageRef = scmEditAllController.cancel();
            Test.stopTest();
            
            System.assertNotEquals(null,returedPageRef,'failure during cancel operation');
            
    	}
    }
}