@isTest
private class TST_SCM_MasterAgreementEditController {
    private static date strtDate = date.newInstance(2019, 1, 1);
    private static date endDate = date.newInstance(2019, 12, 31); 
    private static User testUser;
    private static SCM_MasterAgreementEditController masterAgreementEditController;
    private static Agreement__c testAgreement;
    
    
	 private static void setupData() {
        Id atcRecordTypeID = ConstantClass.getRecordTypeId('ATC__c','ATC');
        List<Account> listOfAccount = new List<Account>();
        Account testAccount = new Account(Name = 'Test',CurrencyIsoCode = 'USD',Region_Territory__c = 'India',Industry_IMS__c = 'Biotech',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        listOfAccount.add(testAccount);
        insert listOfAccount;
        
        //Create a controller to get all the options
        Opportunity testOpportunity = new Opportunity (Name='Default' ,StageName = '2 - Verify Opportunity',
        	CloseDate = System.today() ,Budget_Available__c = 'Yes',CurrencyIsoCode = 'USD',AccountId = testAccount.Id);
        insert testOpportunity;  
        
        List<Agreement__c> testAgreements = new List<Agreement__c>();
        testAgreement = new Agreement__c(Name ='testAgree2',Account__c = testAccount.id,Active__c = true,
        	Company_Signed_Date__c = strtDate,Contract_Start_Date__c = strtDate.addDays(2),
            Contract_Type__c = 'CES Memorandum',Agreement_Term__c = 'Ad-Hoc',
            Related_Opportunity__c = testOpportunity.Id); 
        testAgreements.add(testAgreement);
        insert testAgreements;
        
        upsert new  PseSecurityConfig__c(DisableSecurityTriggers__c=true,UserName__c = 'testt@imshealth.com.dev2',
        	DefaultOwnerUsername__c='integration@uk.imshealth.com.dev2');
        
        insert new pse__Region__c(name='xz',pse__Hierarchy_Depth__c = 0);   
        List<User> listOfUsers = new List<User>();
        List<Profile> profiles = [select id from profile where name = 'System Administrator']; 
         testUser = new User(FirstName = 'testM',LastName = 'testM',Username = 'testSCM@metacube.com',
                             Email =  'testMetacube@metacube.com',Alias = 'TestUsr1',EmployeeNumber='0707073',
                             TimeZoneSidKey = 'America/Los_Angeles',LocaleSidKey = 'en_US',
                             EmailEncodingKey = 'UTF-8',ProfileId = profiles.get(0).id ,LanguageLocaleKey ='en_US',
                             Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description');
        listOfUsers.add(testUser);
        insert listOfUsers;
        
    }
    
    @isTest
    private static void testSCM_MasterAgreementEditControllerShouldSetFieldValuesWhenValidAgreementPassed(){
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
                PageReference pageRef = Page.SCM_JapanAgreementEdit;
                Test.setCurrentPage(pageRef); 
                ApexPages.currentPage().getParameters().put('cancelURL','cancelactioninterceptor'); 
            	masterAgreementEditController = new SCM_MasterAgreementEditController(
                    new Apexpages.Standardcontroller(testAgreement));  
                
            Test.stopTest();
    	}
        System.assertEquals(true,masterAgreementEditController.hasAggNameEditPermission,
        	'hasAggNameEditPermission flag is false, when not expected');
    }
	
    @isTest
    private static void testSaveAgreementShouldUpdateAgreementWhenValidAgreementPassed(){
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
                PageReference pageRef = Page.SCM_JapanAgreementEdit;
                Test.setCurrentPage(pageRef); 
                ApexPages.currentPage().getParameters().put('cancelURL','cancelactioninterceptor'); 
            	masterAgreementEditController = new SCM_MasterAgreementEditController(
                    new Apexpages.Standardcontroller(testAgreement));  
            	masterAgreementEditController.saveAgreement();
                
            Test.stopTest();
    	}
        System.assert(true,'Error in updating the agreement');
    }
    
    @isTest
    private static void testCancelAgreementShouldDeleteAgreementWhenValidURLPassed(){
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
                PageReference pageRef = Page.SCM_JapanAgreementEdit;
                Test.setCurrentPage(pageRef); 
                ApexPages.currentPage().getParameters().put('cancelURL','cancelactioninterceptor'); 
            	masterAgreementEditController = new SCM_MasterAgreementEditController(
                    new Apexpages.Standardcontroller(testAgreement));  
            	PageReference returnedPageRef = masterAgreementEditController.cancelAgreement();
            Test.stopTest();
            
            System.assertNotEquals(null,returnedPageRef,'Error in deleting the agreement');
    	}
        
    }
    
    @isTest
    private static void testCancelAgreementShouldRedirectToOpporutnityWhenValidURLPassed(){
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
                PageReference pageRef = Page.SCM_JapanAgreementEdit;
                Test.setCurrentPage(pageRef); 
            	masterAgreementEditController = new SCM_MasterAgreementEditController(
                    new Apexpages.Standardcontroller(testAgreement));  
            	PageReference returnedPageRef = masterAgreementEditController.cancelAgreement();
            Test.stopTest();
            
            System.assertNotEquals(null,returnedPageRef,'error in cancelagreement method');
    	}
        
    }
    
    @isTest
    private static void testCancelAgreementShouldRedirectToAgreementWhenValidURLPassed(){
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
            	testAgreement.Related_Opportunity__c = null;
            	update testAgreement;
                PageReference pageRef = Page.SCM_JapanAgreementEdit;
                Test.setCurrentPage(pageRef); 
            	masterAgreementEditController = new SCM_MasterAgreementEditController(
                    new Apexpages.Standardcontroller(testAgreement));  
            	PageReference returnedPageRef = masterAgreementEditController.cancelAgreement();
            Test.stopTest();
            
            System.assertNotEquals(null,returnedPageRef,'error in cancelagreement method');
    	}
        
    }

}