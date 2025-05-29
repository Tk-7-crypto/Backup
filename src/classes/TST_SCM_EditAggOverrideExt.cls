@isTest
private class TST_SCM_EditAggOverrideExt {
    
    private static Agreement__c japanAgreement,japanMasterAgreement;
    private static User testUser;
    
	private static void setupData() {
        List<Account> listOfAccount = new List<Account>();
        Account testAccount = new Account(Name = 'Test',CurrencyIsoCode = 'USD',Region_Territory__c = 'India',
        	Industry_IMS__c = 'Biotech',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        listOfAccount.add(testAccount);
        insert listOfAccount;
        
        List<Agreement__c> agreements = new List<Agreement__c>();
        Agreement__c inActiveAgreement = new Agreement__c(Name ='Test Agreement - Inactive',Account__c = testAccount.id,
            Active__c = false,Company_Signed_Date__c = date.newInstance(2019, 1, 1),
            Contract_Start_Date__c = date.newInstance(2019, 1, 1).addDays(2),
            Contract_Type__c = 'CES Memorandum',Agreement_Term__c = 'Ad-Hoc'); 
        agreements.add(inActiveAgreement);
        japanAgreement= new Agreement__c(Name ='Test Agreement - Active',Account__c = testAccount.id,
            Active__c = true,Company_Signed_Date__c = Date.Today().addDays(2),Parent_Agreement__c = inActiveAgreement.Id,
            Status_Category__c = 'In Authoring',RecordTypeId = ConstantClass.getRecordTypeId('Agreement__c','Japan Agreement')); 
        agreements.add(japanAgreement);
        japanMasterAgreement= new Agreement__c(Name ='Test Agreement - Active',Account__c = testAccount.id,
            Active__c = true,Company_Signed_Date__c = Date.Today().addDays(2),Parent_Agreement__c = inActiveAgreement.Id,
            Status_Category__c = 'In Authoring',
            RecordTypeId = ConstantClass.getRecordTypeId('Agreement__c','Japan Master Agreement')); 
        agreements.add(japanMasterAgreement);
        insert agreements;
        
        upsert new  PseSecurityConfig__c(DisableSecurityTriggers__c=true,UserName__c = 'testt@imshealth.com.dev2',
        	DefaultOwnerUsername__c='integration@uk.imshealth.com.dev2');
        
        insert new pse__Region__c(name='xz',pse__Hierarchy_Depth__c = 0);   
        
        Profile adminProfile = [SELECT id FROM Profile WHERE Name = 'System Administrator' Limit 1]; 
       
        testUser = new User(FirstName = 'testM',LastName = 'testM',Username = 'testSCM@metacube.com',
        	Email =  'testMetacube@metacube.com',Alias = 'TestUsr1',TimeZoneSidKey = 'America/Los_Angeles',LocaleSidKey = 'en_US',
        	EmailEncodingKey = 'UTF-8',ProfileId = adminProfile.id ,LanguageLocaleKey ='en_US', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description',
                           EmployeeNumber ='08080808');
        insert testUser;
	}
     
    @isTest
    private static void testSCM_EditAggOverrideExtShouldSetValuesWhenRunningThroughAdminUser(){
        setupData();
        System.runAs(testUser)
        {
            Contract_Management_Setting__c mycs = Contract_Management_Setting__c.getValues(UserInfo.getUserId());
            if(mycs == null) {
                  mycs = new Contract_Management_Setting__c(Name= UserInfo.getUserId());
                  mycs.Perform_SCM_Functions_Flag__c = true;
                  mycs.Japan_Agreement__c = ConstantClass.getRecordTypeId('Agreement__c','Japan Agreement');
                  mycs.Japan_Master_Agreement__c = ConstantClass.getRecordTypeId('Agreement__c','Japan Master Agreement');
                  insert mycs;
            }
            
            
            SCM_EditAggOverrideExt scmEditAggExt = new SCM_EditAggOverrideExt(
                    new Apexpages.StandardController(japanAgreement));
            
            System.assertNotEquals(true,scmEditAggExt.isShowWarning,'isShowWarning is true when false expected');
            
        }
    }
    
   
    @isTest
    private static void testRedirectToWarningOrStandardPageShouldReturnPageRefWhenJapanAgreementIsPassed(){
        setupData();
        System.runAs(testUser)
        {
            Contract_Management_Setting__c mycs = Contract_Management_Setting__c.getValues(UserInfo.getUserId());
            if(mycs == null) {
                  mycs = new Contract_Management_Setting__c(Name= UserInfo.getUserId());
                  mycs.Perform_SCM_Functions_Flag__c = true;
                  mycs.Japan_Agreement__c = ConstantClass.getRecordTypeId('Agreement__c','Japan Agreement');
                  mycs.Japan_Master_Agreement__c = ConstantClass.getRecordTypeId('Agreement__c','Japan Master Agreement');
                  insert mycs;
            }
            
            SCM_EditAggOverrideExt scmEditAggExt = new SCM_EditAggOverrideExt(
                    new Apexpages.StandardController(japanAgreement));
            Test.startTest();
            	PageReference returnPageRef = scmEditAggExt.redirectToWarningOrStandardPage();
            Test.stopTest();
            
            
            System.assertNotEquals(null,returnPageRef,'returnPageRef should not be null');
            
        }
    }
    
    @isTest
    private static void testRedirectToWarningOrStandardPageShouldReturnPageRefWhenJapanMasterAgreementIsPassed(){
        setupData();
        System.runAs(testUser)
        {
            Contract_Management_Setting__c mycs = Contract_Management_Setting__c.getValues(UserInfo.getUserId());
            if(mycs == null) {
                  mycs = new Contract_Management_Setting__c(Name= UserInfo.getUserId());
                  mycs.Perform_SCM_Functions_Flag__c = true;
                  mycs.Japan_Agreement__c = ConstantClass.getRecordTypeId('Agreement__c','Japan Agreement');
                  mycs.Japan_Master_Agreement__c = ConstantClass.getRecordTypeId('Agreement__c','Japan Master Agreement');
                  insert mycs;
            }
           
            SCM_EditAggOverrideExt scmEditAggExt = new SCM_EditAggOverrideExt(
                    new Apexpages.StandardController(japanMasterAgreement));
            Test.startTest();
            	PageReference returnPageRef = scmEditAggExt.redirectToWarningOrStandardPage();
            Test.stopTest();
            
            System.assertNotEquals(null,returnPageRef,'returnPageRef should not be null');
            
        }
    }
}