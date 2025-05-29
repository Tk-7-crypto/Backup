@isTest
private class TST_SCM_NewAggOverrideExt {
	private static User testUser;
    private static Opportunity testOpportunity;
    private static Account testAccount;
    private static SCM_NewAggOverrideExt scmAggOverrideExt;
    private static Agreement__c testAgreement;
    private static void setUpData(){
        List<Account> testAccounts = new List<Account>();
        testAccount = new Account(Name = 'TestAccountNameForSCM1',CurrencyIsoCode = 'USD',
            Region_Territory__c = 'India',Industry_IMS__c = 'Biotech',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        testAccounts.add(testAccount);
        insert testAccounts;
        
        insert new pse__Region__c(name='xz',pse__Hierarchy_Depth__c = 0);   
        List<User> listOfUsers = new List<User>();
        List<Profile> profiles = [select id from profile where name = 'System Administrator']; 
        testUser = new User(FirstName = 'testM',LastName = 'testM',Username = 'testSCM'+Math.random()+'@metacube.com',
                            Email =  'testMetacube@metacube.com',Alias = 'TestUsr1',TimeZoneSidKey = 'America/Los_Angeles',EmployeeNumber='0773'+ String.valueOf(System.currentTimeMillis()),
                            LocaleSidKey = 'en_US',EmailEncodingKey = 'UTF-8',ProfileId = profiles.get(0).id ,LanguageLocaleKey ='en_US',
                            Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description');
        listOfUsers.add(testUser);
        insert listOfUsers;
        
        testOpportunity = new Opportunity (Name='Default' ,StageName = '2 - Verify Opportunity',
            CloseDate = System.today() ,Budget_Available__c = 'Yes',CurrencyIsoCode = 'USD',Amount = 100.00);
        insert testOpportunity; 
        
        List<Agreement__c> testAgreements = new List<Agreement__c>();
        testAgreement = new Agreement__c(Name ='testAgree2',Account__c = testAccount.id,
            Active__c = false,Company_Signed_Date__c = Date.today(),Contract_Start_Date__c = Date.today().addDays(2),
            Contract_Type__c = 'CES Memorandum',Agreement_Term__c = 'Ad-Hoc',
            Related_Opportunity__c = testOpportunity.Id); 
        testAgreements.add(testAgreement);
        insert testAgreements;
    }
    
    @isTest
    private static void testSCM_NewAggOverrideExtShouldReturnSetAttributesWhenValidParamPassed(){
        setUpData();
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
                PageReference pageRef = Page.SCM_AgreementRecordTypeSelectionPage;
                Test.setCurrentPage(pageRef); 
                ApexPages.currentPage().getParameters().put('oppId',testOpportunity.Id);  
            	ApexPages.currentPage().getParameters().put('AccId',testAccount.Id);  
                scmAggOverrideExt = new SCM_NewAggOverrideExt(
                    new Apexpages.StandardController(testAgreement));
            Test.stopTest();
			
            System.assertNotEquals(null,scmAggOverrideExt.oppRec, 'Opportunity Record is null when not expected');
                        
        } 
    }
    
    @isTest
    private static void testRedirectCustomShouldInsertAgreementWhenFieldValueExists(){
        setUpData();
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
                PageReference pageRef = Page.SCM_AgreementRecordTypeSelectionPage;
                Test.setCurrentPage(pageRef); 
                ApexPages.currentPage().getParameters().put('oppId',testOpportunity.Id);  
            	ApexPages.currentPage().getParameters().put('AccId',testAccount.Id);  
                scmAggOverrideExt = new SCM_NewAggOverrideExt(
                    new Apexpages.StandardController(testAgreement));
            	scmAggOverrideExt.selectedAggRecTypeId = ConstantClass.getRecordTypeId('Agreement__c','Japan Agreement');
            	system.debug(scmAggOverrideExt.selectedAggRecTypeId);
            	PageReference returnedPageRef = scmAggOverrideExt.redirectCustom();
            Test.stopTest();
			
            System.assertNotEquals(null,returnedPageRef, 'There is error in insertion of Agreement');
                        
        } 
    }
    
    @isTest
    private static void testRetShouldReturnPageReferenceWhenOppIdPassed(){
        setUpData();
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
                PageReference pageRef = Page.SCM_AgreementRecordTypeSelectionPage;
                Test.setCurrentPage(pageRef); 
                ApexPages.currentPage().getParameters().put('oppId',testOpportunity.Id);     
                scmAggOverrideExt = new SCM_NewAggOverrideExt(
                    new Apexpages.StandardController(testAgreement));
            	PageReference returnedPageRef = scmAggOverrideExt.ret();
            Test.stopTest();
			
            System.assertNotEquals(null,returnedPageRef, 'returnedPageRef is null when not expected');
                        
        } 
    }
    
    @isTest
    private static void testRetShouldReturnPageReferenceWhenAccountIdPassed(){
        setUpData();
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
                PageReference pageRef = Page.SCM_AgreementRecordTypeSelectionPage;
                Test.setCurrentPage(pageRef); 
                ApexPages.currentPage().getParameters().put('AccId',testAccount.Id);    
                scmAggOverrideExt = new SCM_NewAggOverrideExt(
                    new Apexpages.StandardController(testAgreement));
            	PageReference returnedPageRef = scmAggOverrideExt.ret();
            Test.stopTest();
			
            System.assertNotEquals(null,returnedPageRef, 'returnedPageRef is null when not expected');
                        
        } 
    }
    
    @isTest
    private static void testRetShouldReturnPageReferenceWhenNoIdIsPassed(){
        setUpData();
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
                PageReference pageRef = Page.SCM_AgreementRecordTypeSelectionPage;
                Test.setCurrentPage(pageRef); 
                scmAggOverrideExt = new SCM_NewAggOverrideExt(
                    new Apexpages.StandardController(testAgreement));
            	PageReference returnedPageRef = scmAggOverrideExt.ret();
            Test.stopTest();
			
            System.assertNotEquals(null,returnedPageRef, 'returnedPageRef is null when not expected');
                        
        } 
    }
    
    @isTest
    private static void testGetAggRecordTypesShouldReturnRecordTypeOptionsWhenLoggedInUserIsSysAdm(){
        setUpData();
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
                PageReference pageRef = Page.SCM_AgreementRecordTypeSelectionPage;
                Test.setCurrentPage(pageRef); 
            	ApexPages.currentPage().getParameters().put('oppId',testOpportunity.Id);  
            	ApexPages.currentPage().getParameters().put('AccId',testAccount.Id);
                scmAggOverrideExt = new SCM_NewAggOverrideExt(
                    new Apexpages.StandardController(testAgreement));
            	List<SelectOption> listSelectOption = scmAggOverrideExt.getAggRecordTypes();
            Test.stopTest();
			
            System.assertNotEquals(true,listSelectOption.isEmpty(), 'The returned list is blank when not expected');
                        
        } 
    }
}