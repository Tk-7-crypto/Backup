@isTest
private class TST_SCM_SelectTemplateController {
	private static Account testAccount;
	private static Opportunity testOpportunity;
	private static Agreement__c testAgreement;
	private static User testUser;
	private static SCM_SelectTemplateController scmSelectTemplateController ;
	private static Apttus__APTS_Template__c testTemplate;
    private static Attachment testAttachment;
    private static Task testTask;
    private static Document testDocument;
	
	private static void setupData() {
        insert new pse__Region__c(name='xz',pse__Hierarchy_Depth__c = 0);   
        List<User> listOfUsers = new List<User>();
        List<Profile> profiles = [select id from profile where name = 'System Administrator']; 
        testUser = new User(FirstName = 'testM',LastName = 'testM',Username = 'testSCM@metacube.com',EmployeeNumber='070547073',
                            Email =  'testMetacube@metacube.com',Alias = 'TestUsr1',TimeZoneSidKey = 'America/Los_Angeles',
                            LocaleSidKey = 'en_US',EmailEncodingKey = 'UTF-8',ProfileId = profiles.get(0).id ,LanguageLocaleKey ='en_US',
                            Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description');
        listOfUsers.add(testUser);
        insert listOfUsers;
		
        List<Account> listOfAccount = new List<Account>();
        testAccount = new Account(Name = 'Test',CurrencyIsoCode = 'USD',Region_Territory__c = 'India',Industry_IMS__c = 'Biotech',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        listOfAccount.add(testAccount);
        insert listOfAccount;
        
		//Create a controller to get all the options
        testOpportunity = new Opportunity (Name='Default' ,StageName = '2 - Verify Opportunity',CloseDate = System.today() ,Budget_Available__c = 'Yes',CurrencyIsoCode = 'USD');
        insert testOpportunity;
        
        List<Agreement__c> agreements = new List<Agreement__c>();
        testAgreement = new Agreement__c(Name ='testAgree1',Account__c = testAccount.id,Active__c = true,
        	Company_Signed_Date__c = Date.Today().addDays(2),Parent_Agreement__c = null,
            Status_Category__c = 'In Authoring',
			RecordTypeId = ConstantClass.getRecordTypeId('Agreement__c','Japan Agreement')); 
        agreements.add(testAgreement);
        insert agreements;
        
        testAttachment = new Attachment(ParentId=testAgreement.Id,Name='Test Generated Doc For Agreement',
        	Body=Blob.valueOf('Test Data'));  
        insert testAttachment;
        
        testTask = new Task(WhatId = testAgreement.Id,Subject = 'Generated Agreement',
        	Status = 'Generated',Description = 'Generated');
        insert testTask;
		
		testTemplate = new Apttus__APTS_Template__c(Name = 'test', Apttus__IsActive__c = true,
        	Apttus__BusinessObject__c = 'Opportunity');
        insert testTemplate;
         
		
        testDocument = new Document();
        testDocument.Body = Blob.valueOf('Some Text');
        testDocument.ContentType = 'application/pdf';
        testDocument.DeveloperName = 'my_document';
        testDocument.IsPublic = true;
        testDocument.Name = 'My Document';
        testDocument.FolderId = UserInfo.getUserId() ;//[select id from folder where name = 'Japan' limit 1].id;
        insert testDocument;
         
	}
	
    @isTest
    private static void testSCM_SelectTemplateControllerShouldSetAttributesWhenLoggedInUserIsSysAdm(){
		setupData();
		System.runAs(testUser){
			Contract_Management_Setting__c mycs = Contract_Management_Setting__c.getValues(UserInfo.getUserId());
  
            if(mycs == null) {
              mycs = new Contract_Management_Setting__c(Name= UserInfo.getUserId());
              mycs.Perform_SCM_Functions_Flag__c = true;
              insert mycs;
            }
			
			Test.startTest();
                PageReference pageRef = Page.SCM_SelectTemplate;
                Test.setCurrentPage(pageRef); 
                ApexPages.currentPage().getParameters().put('Id',testOpportunity.Id);  
				ApexPages.currentPage().getParameters().put('AgreementType','OpportunityDocument');  
              scmSelectTemplateController = new SCM_SelectTemplateController();
				      scmSelectTemplateController.agreement = testAgreement;
            	scmSelectTemplateController.sessionId = '';
            	scmSelectTemplateController.serverUrl = '';
              scmSelectTemplateController.docSize = Integer.valueOf('12');
              scmSelectTemplateController.isRapidSOWUsedBySales = false;
              scmSelectTemplateController.atchAddendum = testAttachment;
			Test.stopTest();
			
			System.assertNotEquals(true,scmSelectTemplateController.isSalesuser , 'Logged in user is Sales User');
			System.assertEquals('DOC',scmSelectTemplateController.selectedFormat , 'The selected format of document is not PDF');
		}
    }
	
	@isTest
    private static void testGetOutputFormatListShouldReturnOptionWhenLoggedInUserIsSysAdm(){
		setupData();
		System.runAs(testUser){
			Contract_Management_Setting__c mycs = Contract_Management_Setting__c.getValues(UserInfo.getUserId());
  
            if(mycs == null) {
              mycs = new Contract_Management_Setting__c(Name= UserInfo.getUserId());
              mycs.Perform_SCM_Functions_Flag__c = true;
              insert mycs;
            }
			
			Test.startTest();
                PageReference pageRef = Page.SCM_SelectTemplate;
                Test.setCurrentPage(pageRef); 
                ApexPages.currentPage().getParameters().put('Id',testOpportunity.Id);  
				ApexPages.currentPage().getParameters().put('AgreementType','OpportunityDocument');  
                scmSelectTemplateController = new SCM_SelectTemplateController();
				scmSelectTemplateController.agreement = testAgreement;
                List<SelectOption> listSelectOption = scmSelectTemplateController.getOutputFormatList();
            
			Test.stopTest();
			
			System.assertEquals(3,listSelectOption.size() , 'Some options are not visible to logged in user');
		}
    }
    
    @isTest
    private static void testSearchTempShouldSetWrapperWhenAgreementTypeIsOpportunityDocument(){
		setupData();
		System.runAs(testUser){
			Contract_Management_Setting__c mycs = Contract_Management_Setting__c.getValues(UserInfo.getUserId());
  
            if(mycs == null) {
              mycs = new Contract_Management_Setting__c(Name= UserInfo.getUserId());
              mycs.Perform_SCM_Functions_Flag__c = true;
              insert mycs;
            }
			
			Test.startTest();
                PageReference pageRef = Page.SCM_SelectTemplate;
                Test.setCurrentPage(pageRef); 
                ApexPages.currentPage().getParameters().put('Id',testOpportunity.Id);  
				ApexPages.currentPage().getParameters().put('AgreementType','OpportunityDocument');  
                scmSelectTemplateController = new SCM_SelectTemplateController();
				scmSelectTemplateController.agreement = testAgreement;
                scmSelectTemplateController.searchTemp();
            
			Test.stopTest();
			
			System.assertEquals(2,scmSelectTemplateController.templateWrpList.size() , 'templateWrpList is blank when not expected');
		}
    }
	
    @isTest
    private static void testGenerateShouldGenerateDocWhenAgreementTypeIsOpportunityDocument(){
		setupData();
		System.runAs(testUser){
			Contract_Management_Setting__c mycs = Contract_Management_Setting__c.getValues(UserInfo.getUserId());
  
            if(mycs == null) {
              mycs = new Contract_Management_Setting__c(Name= UserInfo.getUserId());
              mycs.Perform_SCM_Functions_Flag__c = true;
              insert mycs;
            }
			
			Test.startTest();
                PageReference pageRef = Page.SCM_SelectTemplate;
                Test.setCurrentPage(pageRef); 
                ApexPages.currentPage().getParameters().put('Id',testOpportunity.Id);  
				ApexPages.currentPage().getParameters().put('AgreementType','OpportunityDocument');  
                scmSelectTemplateController = new SCM_SelectTemplateController();
				scmSelectTemplateController.agreement = testAgreement;
            	scmSelectTemplateController.docId = testAttachment.Id;
                scmSelectTemplateController.generate();
            
			Test.stopTest();
			
			System.assertEquals(null,scmSelectTemplateController.atch , 'Attachment is null when not expected');
		}
    }
    
    @isTest
    private static void testGenerateShouldGenerateDocWhenAgreementTypeIsAgreement(){
		setupData();
		System.runAs(testUser){
			Contract_Management_Setting__c mycs = Contract_Management_Setting__c.getValues(UserInfo.getUserId());
  
            if(mycs == null) {
              mycs = new Contract_Management_Setting__c(Name= UserInfo.getUserId());
              mycs.Perform_SCM_Functions_Flag__c = true;
              insert mycs;
            }
			
			Test.startTest();
                PageReference pageRef = Page.SCM_SelectTemplate;
                Test.setCurrentPage(pageRef); 
                ApexPages.currentPage().getParameters().put('Id',testOpportunity.Id);  
            	ApexPages.currentPage().getParameters().put('AgreementType','Agreement');  
                scmSelectTemplateController = new SCM_SelectTemplateController();
				scmSelectTemplateController.agreement = testAgreement;
            	scmSelectTemplateController.docId = testAttachment.Id;
                scmSelectTemplateController.generate();
            
			Test.stopTest();
			
			System.assertEquals(true,scmSelectTemplateController.hasDocGenerated , 'Error in Document generation');
		}
    }
    
    @isTest
    private static void testGenerateShouldReGenerateDocWhenAgreementHasIsDocumentGenerationTrue(){
		setupData();
		System.runAs(testUser){
			Contract_Management_Setting__c mycs = Contract_Management_Setting__c.getValues(UserInfo.getUserId());
  
            if(mycs == null) {
              mycs = new Contract_Management_Setting__c(Name= UserInfo.getUserId());
              mycs.Perform_SCM_Functions_Flag__c = true;
              insert mycs;
            }
			
			Test.startTest();
            	testAgreement.Is_Document_Generated__c = true;
            	update testAgreement;
                PageReference pageRef = Page.SCM_SelectTemplate;
                Test.setCurrentPage(pageRef); 
                ApexPages.currentPage().getParameters().put('Id',testOpportunity.Id);  
            	ApexPages.currentPage().getParameters().put('AgreementType','Agreement');  
                scmSelectTemplateController = new SCM_SelectTemplateController();
				scmSelectTemplateController.agreement = testAgreement;
            	scmSelectTemplateController.docId = testAttachment.Id;
            	scmSelectTemplateController.atch = testAttachment;  
                scmSelectTemplateController.generate();
            
			Test.stopTest();
			
			System.assertNotEquals(false,scmSelectTemplateController.hasDocGenerated , 'Document generation Successfully');
		}
    }
    
     @isTest
    private static void testGenerateShouldReGenerateDocWhenisPreviewFlagIsTrue(){
		setupData();
		System.runAs(testUser){
			Contract_Management_Setting__c mycs = Contract_Management_Setting__c.getValues(UserInfo.getUserId());
  
            if(mycs == null) {
              mycs = new Contract_Management_Setting__c(Name= UserInfo.getUserId());
              mycs.Perform_SCM_Functions_Flag__c = true;
              insert mycs;
            }
			
			Test.startTest();
            	testAgreement.Is_Document_Generated__c = true;
            	update testAgreement;
                PageReference pageRef = Page.SCM_SelectTemplate;
                Test.setCurrentPage(pageRef); 
                ApexPages.currentPage().getParameters().put('Id',testOpportunity.Id);  
            	ApexPages.currentPage().getParameters().put('AgreementType','Agreement');  
                scmSelectTemplateController = new SCM_SelectTemplateController();
				scmSelectTemplateController.agreement = testAgreement;
            	scmSelectTemplateController.docId = testAttachment.Id;
            	scmSelectTemplateController.atch = testAttachment;  
            	scmSelectTemplateController.isPreview = true;
                scmSelectTemplateController.generate();
            
			Test.stopTest();
			
			System.assertNotEquals(false,scmSelectTemplateController.hasDocGenerated , 'Document generated successfully');
		}
    }
    
    @isTest
    private static void testDeleteDocumentShouldDeleteDocWhenAdminIsLoggedIn(){
		setupData();
		System.runAs(testUser){
			Contract_Management_Setting__c mycs = Contract_Management_Setting__c.getValues(UserInfo.getUserId());
  
            if(mycs == null) {
              mycs = new Contract_Management_Setting__c(Name= UserInfo.getUserId());
              mycs.Perform_SCM_Functions_Flag__c = true;
              insert mycs;
            }
			
			Test.startTest();
            	testAgreement.Is_Document_Generated__c = true;
            	update testAgreement;
                PageReference pageRef = Page.SCM_SelectTemplate;
                Test.setCurrentPage(pageRef); 
                ApexPages.currentPage().getParameters().put('Id',testOpportunity.Id);  
            	ApexPages.currentPage().getParameters().put('AgreementType','Agreement');  
                scmSelectTemplateController = new SCM_SelectTemplateController();
                scmSelectTemplateController.document = testDocument;
            	scmSelectTemplateController.deleteDocument();
            
			Test.stopTest();
			
			System.assertNotEquals(null,scmSelectTemplateController.document , 'Document is null when not expected');
		}
    }

	
}