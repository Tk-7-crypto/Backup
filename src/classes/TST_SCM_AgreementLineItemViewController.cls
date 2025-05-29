@isTest
private class TST_SCM_AgreementLineItemViewController {
    private static User testUser;
    private static User testItalianUser;
    private static SCM_AgreementLineItemViewController lineItemViewController;
    private static Agreement__c activeAgreement,inActiveAgreement;
    private static Agreement_Line_Item__c testAgreementLineItem;
    private static Account imsHealthAccount,testAccount;
    private static ATC__c atcObj;
    private static Product2 testproduct;
    private static date strtDate = date.newInstance(2019, 1, 1);
    private static date endDate = date.newInstance(2019, 12, 31); 
    private static Boolean checkcanChangeProduct;
    private static Boolean checkisAggActivated;
    private static Boolean checkisProposalCancelled;    
    private static Boolean checkisSowCancelled;
    
    
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
    }
    
    private static void setUpUser(){
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
    private static void testSCM_AgreementLineItemViewControllerShouldSetValuesWhenRunningThroughNonItalyUser(){
        setUpUser();
        System.runAs(testUser)
        { 
            Contract_Management_Setting__c mycs = Contract_Management_Setting__c.getValues(UserInfo.getUserId());
  
            if(mycs == null) {
              mycs = new Contract_Management_Setting__c(Name= UserInfo.getUserId());
              mycs.Perform_SCM_Functions_Flag__c = true;
              insert mycs;
            }
            setupData();
            Test.startTest();
                PageReference pageRef = Page.SCM_AgreementLineItemView;
                Test.setCurrentPage(pageRef); 
                ApexPages.currentPage().getParameters().put('id',testAgreementLineItem.Id);  
            	ApexPages.currentPage().getParameters().put('frmSave','true');  
                lineItemViewController = new SCM_AgreementLineItemViewController(
                    new Apexpages.StandardController(testAgreementLineItem));
                lineItemViewController.aggStatusCategory = '';
            Test.stopTest();
            
            System.assertEquals('',lineItemViewController.userPermission,'User not assigned to any permission set');
            System.assertEquals('Annual',lineItemViewController.invoicingScheduleString,'Incorrect invoicing schedule set');
            System.assertEquals(false,lineItemViewController.isFrmSave,'isFrmSave flag is true when false expected');
            System.assertEquals(false,lineItemViewController.isItalyUser,'Italy user found, when not expected');
            System.assertEquals(true,lineItemViewController.isVisibleAcceleratedDAPDaysOther,
                                    'isVisibleAcceleratedDAPDaysOther is false when true expected');
            System.assertEquals(true,lineItemViewController.isCreateAgliAllowed,
                                    'isCreateAgliAllowed is false when true expected');
            System.assertEquals(true,lineItemViewController.isUpdateAgliAllowed,
                                    'isUpdateAgliAllowed is false when true expected');
            System.assertEquals(false,lineItemViewController.canChangeProduct,
                                    'canChangeProduct is true when false expected'); 
        }
    }
    
    @isTest
    private static void testSCM_AgreementLineItemViewControllerShouldSetIsAggActivatedFlagToTrueWhenValidDataPassed(){
        setUpUser();
        System.runAs(testUser)
        { 
            Contract_Management_Setting__c mycs = Contract_Management_Setting__c.getValues(UserInfo.getUserId());
  
            if(mycs == null) {
              mycs = new Contract_Management_Setting__c(Name= UserInfo.getUserId());
              mycs.Perform_SCM_Functions_Flag__c = true;
              insert mycs;
            }
            setupData();
           
            Test.startTest();
            	activeAgreement.Status__c = 'Activated';
            	update activeAgreement;
            
                PageReference pageRef = Page.SCM_AgreementLineItemView;
                Test.setCurrentPage(pageRef); 
                ApexPages.currentPage().getParameters().put('id',testAgreementLineItem.Id);  
                lineItemViewController = new SCM_AgreementLineItemViewController(
                    new Apexpages.StandardController(testAgreementLineItem));
            Test.stopTest();
            
            System.assertEquals(true,lineItemViewController.isAggActivated,'isAggActivated flag is false, when true expected');
            
        }
    }
    
    @isTest
    private static void testSCM_AgreementLineItemViewControllerShouldSetIsSowCancelledToTrueWhenValidDataPassed(){
        setUpUser();
        System.runAs(testUser)
        { 
            Contract_Management_Setting__c mycs = Contract_Management_Setting__c.getValues(UserInfo.getUserId());
  
            if(mycs == null) {
              mycs = new Contract_Management_Setting__c(Name= UserInfo.getUserId());
              mycs.Perform_SCM_Functions_Flag__c = true;
              insert mycs;
            }
            setupData();
            
            Test.startTest();
            	activeAgreement.Status_Category__c = 'Cancelled';
            	update activeAgreement;
            
            	testAgreementLineItem.Apts_DAP__c = 'Accelerated DAP';
            	update testAgreementLineItem;
            
                PageReference pageRef = Page.SCM_AgreementLineItemView;
                Test.setCurrentPage(pageRef); 
                ApexPages.currentPage().getParameters().put('id',testAgreementLineItem.Id);  
                lineItemViewController = new SCM_AgreementLineItemViewController(
                    new Apexpages.StandardController(testAgreementLineItem));
            Test.stopTest();
            
            System.assertEquals(true,lineItemViewController.IsSowCancelled,'IsSowCancelled flag is false, when true expected');
            System.assertEquals(true,lineItemViewController.isVisibleAcceleratedDAPDays,'isVisibleAcceleratedDAPDays flag is false, when true expected');
            
        }
    }
    
    @isTest
    private static void testSCM_AgreementLineItemViewControllerShouldSetValuesWhenRunningThroughItalyUser(){
        setUpUser();
        System.runAs(testItalianUser)
        { 
            Contract_Management_Setting__c mycs = Contract_Management_Setting__c.getValues(UserInfo.getUserId());
  
            if(mycs == null) {
              mycs = new Contract_Management_Setting__c(Name= UserInfo.getUserId());
              mycs.Perform_SCM_Functions_Flag__c = true;
              insert mycs;
            }
            setupData();
            Test.startTest();
            	activeAgreement.Status_Category__c = null;
            	update activeAgreement;
            
                PageReference pageRef = Page.SCM_AgreementLineItemView;
                Test.setCurrentPage(pageRef); 
                ApexPages.currentPage().getParameters().put('id',testAgreementLineItem.Id);  
            	ApexPages.currentPage().getParameters().put('frmSave','true');  
                lineItemViewController = new SCM_AgreementLineItemViewController(
                    new Apexpages.StandardController(testAgreementLineItem));
                
            Test.stopTest();
            
            System.assertEquals('',lineItemViewController.userPermission,'User not assigned to any permission set');
            System.assertEquals('Annuale',lineItemViewController.invoicingScheduleString,'Incorrect invoicing schedule set');
            System.assertEquals(false,lineItemViewController.isFrmSave,'Incorrect Status Category for Agreement');
            System.assertEquals(true,lineItemViewController.isItalyUser,'Non-Italy user found, when not expected');
            System.assertEquals(true,lineItemViewController.isVisibleAcceleratedDAPDaysOther,
            'isVisibleAcceleratedDAPDaysOther is false when true expected');
            System.assertEquals(false,lineItemViewController.isVisibleAcceleratedDAPDays,
            'isVisibleAcceleratedDAPDays is true when false expected');
            System.assertEquals(true,lineItemViewController.isUpdateAgliAllowed,
            'isUpdateAgliAllowed is false when true expected');
            System.assertEquals(false,lineItemViewController.canChangeProduct,
            'canChangeProduct is true when false expected');
        }
    }
    
    @isTest
    private static void testCancelUncancelShouldNotReturnNullWhenRunningThroughNonItalyUser(){
        setUpUser();
        System.runAs(testUser)
        { 
            Contract_Management_Setting__c mycs = Contract_Management_Setting__c.getValues(UserInfo.getUserId());
  
            if(mycs == null) {
              mycs = new Contract_Management_Setting__c(Name= UserInfo.getUserId());
              mycs.Perform_SCM_Functions_Flag__c = true;
              insert mycs;
            }
            setupData();
            Test.startTest();
                PageReference pageRef = Page.SCM_AgreementLineItemView;
                Test.setCurrentPage(pageRef); 
                ApexPages.currentPage().getParameters().put('id',testAgreementLineItem.Id);  
                lineItemViewController = new SCM_AgreementLineItemViewController(
                    new Apexpages.StandardController(testAgreementLineItem));
            	PageReference returnPageRef = lineItemViewController.cancelUncancel();
            Test.stopTest();
            
            System.assertNotEquals(null,returnPageRef,'The returned page reference is null when not expected');
        }
    }
    
    @isTest
    private static void testEditAgliShouldNotReturnNullWhenRunningThroughNonItalyUser(){
        setUpUser();
        System.runAs(testUser)
        { 
            Contract_Management_Setting__c mycs = Contract_Management_Setting__c.getValues(UserInfo.getUserId());
  
            if(mycs == null) {
              mycs = new Contract_Management_Setting__c(Name= UserInfo.getUserId());
              mycs.Perform_SCM_Functions_Flag__c = true;
              insert mycs;
            }
            setupData();
            Test.startTest();
                PageReference pageRef = Page.SCM_AgreementLineItemView;
                Test.setCurrentPage(pageRef); 
                ApexPages.currentPage().getParameters().put('id',testAgreementLineItem.Id);  
                lineItemViewController = new SCM_AgreementLineItemViewController(
                    new Apexpages.StandardController(testAgreementLineItem));
            	PageReference returnPageRef = lineItemViewController.editAgli();
            Test.stopTest();
            
            System.assertNotEquals(null,returnPageRef,'The returned page reference is null when not expected');
        }
    }
    
    @isTest
    private static void testDelAgliShouldNotReturnNullWhenRunningThroughNonItalyUser(){
        setUpUser();
        System.runAs(testUser)
        { 
            Contract_Management_Setting__c mycs = Contract_Management_Setting__c.getValues(UserInfo.getUserId());
  
            if(mycs == null) {
              mycs = new Contract_Management_Setting__c(Name= UserInfo.getUserId());
              mycs.Perform_SCM_Functions_Flag__c = true;
              insert mycs;
            }
            setupData();
            Test.startTest();
                PageReference pageRef = Page.SCM_AgreementLineItemView;
                Test.setCurrentPage(pageRef); 
                ApexPages.currentPage().getParameters().put('id',testAgreementLineItem.Id);  
                lineItemViewController = new SCM_AgreementLineItemViewController(
                    new Apexpages.StandardController(testAgreementLineItem));
            	PageReference returnPageRef = lineItemViewController.delAgli();
            Test.stopTest();
            
            System.assertNotEquals(null,returnPageRef,'The returned page reference is null when not expected');
        }
    }
    
    @isTest
    private static void testCloneRecordShouldNotReturnNullWhenRunningThroughNonItalyUser(){
        setUpUser();
        System.runAs(testUser)
        { 
            Contract_Management_Setting__c mycs = Contract_Management_Setting__c.getValues(UserInfo.getUserId());
  
            if(mycs == null) {
              mycs = new Contract_Management_Setting__c(Name= UserInfo.getUserId());
              mycs.Perform_SCM_Functions_Flag__c = true;
              insert mycs;
            }
            setupData();
            Test.startTest();
                PageReference pageRef = Page.SCM_AgreementLineItemView;
                Test.setCurrentPage(pageRef); 
                ApexPages.currentPage().getParameters().put('id',testAgreementLineItem.Id);  
                lineItemViewController = new SCM_AgreementLineItemViewController(
                    new Apexpages.StandardController(testAgreementLineItem));
            	PageReference returnPageRef = lineItemViewController.cloneRecord();
            Test.stopTest();
            
            System.assertNotEquals(null,returnPageRef,'The returned page reference is null when not expected');
        }
    }
    
    @isTest
    private static void testSelectMarketDefShouldNotReturnNullWhenRunningThroughNonItalyUser(){
        setUpUser();
        System.runAs(testUser)
        { 
            Contract_Management_Setting__c mycs = Contract_Management_Setting__c.getValues(UserInfo.getUserId());
  
            if(mycs == null) {
              mycs = new Contract_Management_Setting__c(Name= UserInfo.getUserId());
              mycs.Perform_SCM_Functions_Flag__c = true;
              insert mycs;
            }
            setupData();
            Test.startTest();
                PageReference pageRef = Page.SCM_AgreementLineItemView;
                Test.setCurrentPage(pageRef); 
                ApexPages.currentPage().getParameters().put('id',testAgreementLineItem.Id);  
                lineItemViewController = new SCM_AgreementLineItemViewController(
                    new Apexpages.StandardController(testAgreementLineItem));
            	PageReference returnPageRef = lineItemViewController.selectMarketDef();
            Test.stopTest();
            
            System.assertNotEquals(null,returnPageRef,'The returned page reference is null when not expected');
        }
    }
    
    @isTest
    private static void testCopyToAllShouldNotReturnNullWhenRunningThroughNonItalyUser(){
        setUpUser();
        System.runAs(testUser)
        { 
            Contract_Management_Setting__c mycs = Contract_Management_Setting__c.getValues(UserInfo.getUserId());
  
            if(mycs == null) {
              mycs = new Contract_Management_Setting__c(Name= UserInfo.getUserId());
              mycs.Perform_SCM_Functions_Flag__c = true;
              insert mycs;
            }
            setupData();
            Test.startTest();
                PageReference pageRef = Page.SCM_AgreementLineItemView;
                Test.setCurrentPage(pageRef); 
                ApexPages.currentPage().getParameters().put('id',testAgreementLineItem.Id);  
                lineItemViewController = new SCM_AgreementLineItemViewController(
                    new Apexpages.StandardController(testAgreementLineItem));
            	PageReference returnPageRef = lineItemViewController.copyToAll();
            Test.stopTest();
            
            System.assertNotEquals(null,returnPageRef,'The returned page reference is null when not expected');
        }
    }
    
    @isTest
    private static void testgetRelatedListsShouldReturnListWhenRunningThroughNonItalyUser(){
        setUpUser();
        System.runAs(testUser)
        { 
            Contract_Management_Setting__c mycs = Contract_Management_Setting__c.getValues(UserInfo.getUserId());
  
            if(mycs == null) {
              mycs = new Contract_Management_Setting__c(Name= UserInfo.getUserId());
              mycs.Perform_SCM_Functions_Flag__c = true;
              insert mycs;
            }
            setupData();
            Test.startTest();
                PageReference pageRef = Page.SCM_AgreementLineItemView;
                Test.setCurrentPage(pageRef); 
                ApexPages.currentPage().getParameters().put('id',testAgreementLineItem.Id);  
                lineItemViewController = new SCM_AgreementLineItemViewController(
                    new Apexpages.StandardController(testAgreementLineItem));
            	lineItemViewController.getRelatedLists();
            Test.stopTest();
            
            System.assertNotEquals(0,lineItemViewController.relatedListSize.size(),'The related lists are blank for agreement line item');
        }
    }
}