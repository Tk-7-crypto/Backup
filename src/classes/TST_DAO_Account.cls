/**
* This test class is used to test all methods in Account Domain class.
* version : 1.0
*/
@isTest
private class TST_DAO_Account {
    
    @testsetup
    static void setupData(){
        upsert new User_Permissions__c(IES_User__c = true,Name = 'Sales_with_Bid_History',Can_Edit_Risk_Rating__c = true,Stop_Risk_Rating_Account_Notifications__c = false);
        upsert new Credit_Control_Groups__c(Name = 'Group Names', Group_Names__c = 'Credit Control Groups,Super Credit Control Admins');
        Group grp = new Group(name='Super Credit Control Admins');
        insert grp;  
        Id userId = UserInfo.getUserId();
        User testUser = [Select id, Name from User where id = :userId];
        System.runAs(testUser) {
            GroupMember grpMember = new GroupMember(GroupId = grp.Id, UserOrGroupId = userId);
            insert grpMember;
        }
    }
    
    /**
    * This test method used for insert Account record
    */ 
    static testMethod void testInsertAccount() {
        Test.startTest();
            Account newAccount = UTL_TestData.createAccount();
            insert newAccount;
        Test.stopTest();
        Account existingAccount = [SELECT Id, Name FROM Account LIMIT 1];
        System.assertEquals('TestAccount', existingAccount.Name);
    }
    
    /**
    * This test method used for delete Account record
    */ 
    static testMethod void testDeleteAccount() {
        Test.startTest();
            Account newAccount = UTL_TestData.createAccount();
            newAccount.LI_Account_Id__c = 'testLiId';
            newAccount.LQ_Account_Id__c = 'testLqId';
            insert newAccount;
            List<Account> accList = [SELECT Id FROM Account];
            delete accList;
            List<Outbound_Message_Deletion_queue__c> outboundList = [SELECT Id FROM Outbound_Message_Deletion_queue__c LIMIT 1];
        Test.stopTest();
        System.assertEquals(1, outboundList.size());
    }
    /**
    * This test method used for update Account record
    */ 
    static testMethod void testUpdateAccount() {
        Test.startTest();
            Account newAccount = UTL_TestData.createAccount();
            insert newAccount;
            
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(newAccount.id);
            req1.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        
            //Submit the approval request for the change
            Approval.ProcessResult result = Approval.process(req1);
            
            //newAccount.Name = 'Test Account';
            newAccount.MDM_Validation_Status__c = CON_CRM.MDM_VALIDATION_STATUS_VALIDATED;
            update newAccount;
        Test.stopTest();
        Account existingAccount = [SELECT Id, Name,MDM_Validation_Status__c FROM Account LIMIT 1];
        System.assertEquals(CON_CRM.MDM_VALIDATION_STATUS_VALIDATED, existingAccount.MDM_Validation_Status__c);
    }
    
    /**
    * This test method used for update Account record with rejected status
    */ 
    static testMethod void testUpdateAccountWithRejected() {
        Test.startTest();
            Account newAccount = UTL_TestData.createAccount();
            insert newAccount;
            
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(newAccount.id);
            req1.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        
            //Submit the approval request for the change
            Approval.ProcessResult result = Approval.process(req1);
            
            newAccount.MDM_Validation_Status__c = CON_CRM.MDM_VALIDATION_STATUS_REJECTED;
            update newAccount;
        Test.stopTest();
        Account existingAccount = [SELECT Id, Name,MDM_Validation_Status__c FROM Account LIMIT 1];
        System.assertEquals(CON_CRM.MDM_VALIDATION_STATUS_REJECTED, existingAccount.MDM_Validation_Status__c);
    }
    
    /**
    * This test method used for insert and update Case record
    */ 
    static testMethod void testAuditforContact() {
        Account acc = CSM_Util.createAccount();
        insert acc;
        CNT_CSM_FieldHistoryTracking.saveFields('Account','AccountNumber,AccountSource,AccountStatus__c,AnnualRevenue,CTIVDN__c,CurrencyIsoCode,Department__c,Description,DocumentationURLLink__c,Email__c,Fax,CustomerSegment__c,InterfaceStatus__c,IsExcludedFromRealign,IsThisASpecialHandlingClient__c,Jigsaw,JigsawCompanyId,LastActivityDate,MasterRecordId,MDMID__c,MIData__c,NumberOfEmployees,Ownership,ParentId,Phone,PhotoUrl,Rating,RDClinicalSite__c,RDSponsor__c,RecordTypeId,Region__c,SAPID__c,SendAutomaticCaseAcknowledgmentEmail__c,ShippingAddress,Sic,SicDesc,Site,SLAApplies__c,SLAPenalties__c,SystemModstamp,Tags__c,TickerSymbol,Type,Type2__c,Website');
        Account accP = CSM_Util.createAccount();
        insert accP;
        Account accP1 = CSM_Util.createAccount();
        insert accP1;
        Test.startTest();
        accP.Description = 'Test Description';
        accP.CustomerSegment__c = 'FINANCIAL COMPANY';
        accP.Sub_Industry__c = 'BANKING';
        accP.Website = 'http://gmail.com';
        update accP;
        accP.Description = 'Test Description Changed';
        accP.Website = 'http://yahoo.com';
        accP.CustomerSegment__c = 'GOVERNMENT';
        accp.Sub_Industry__c = 'STATE';
        update accP;
        accP.Description = null;
        accP.Website = null;
        accP.CustomerSegment__c = null;
        accP.Sub_Industry__c = null;
        update accP;
        CNT_CSM_FieldHistoryTracking.saveFields('Account','AccountNumber,AccountSource,AccountStatus__c,AnnualRevenue,BillingAddress,CTIVDN__c,CurrencyIsoCode,Department__c,Description,DocumentationURLLink__c,Email__c,Fax,CustomerSegment__c,InterfaceStatus__c,IsExcludedFromRealign,IsThisASpecialHandlingClient__c,Jigsaw,JigsawCompanyId,LastActivityDate,MasterRecordId,MDMID__c,MIData__c,NumberOfEmployees,Ownership,ParentId,Phone,PhotoUrl,Rating,RDClinicalSite__c,RDSponsor__c,RecordTypeId,Region__c,SAPID__c,SendAutomaticCaseAcknowledgmentEmail__c,ShippingAddress,Sic,SicDesc,Site,SLAApplies__c,SLAPenalties__c,SystemModstamp,Tags__c,TickerSymbol,Type,Type2__c,Website');
        acc.BillingCity = 'Bangalore';
        acc.BillingCountry = 'India';
        acc.BillingPostalCode = '560016';
        acc.BillingState = 'Karnataka';
        acc.BillingStreet = 'KB-11';
        acc.ParentId = accP.Id;
        update acc;
        acc.BillingCity = 'Paris';
        acc.BillingCountry = 'France';
        acc.BillingPostalCode = '500016';
        acc.BillingState = 'Telangana';
        acc.BillingStreet = 'TH-11';
        acc.ParentId = accP1.Id;
        update acc;
        acc.BillingCity = null;
        acc.BillingCountry = null;
        acc.BillingPostalCode = null;
        acc.BillingState = null;
        acc.BillingStreet = null;
        acc.ParentId = null;
        update acc;
        Test.stopTest(); 
    }
    
    /**
    * This test method used for insert and update on Account for method setAccountLabel
    */ 
    @isTest
    static void testSetAccountLabel() {
    	test.startTest();
        Test.setMock(WebServiceMock.Class, new partnerSoapSforceComMock());
        
    	Account acc = CSM_Util.createAccount();
    	acc.AccountCountry__c = 'FR';
        database.insert(acc, true);
        
        acc.AccountCountry__c = 'DE';
        database.update(acc, true);
        test.stopTest();
    }
    
    /**
    * This test method used for insert and update on Account for method mergeAccounts
    */ 
    @isTest
    static void testMergeAccounts() {
    	test.startTest();
        List<Account> acc = new List<Account>();
    	Account acc1 = UTL_TestData.createAccount();
        Account acc2 = UTL_TestData.createAccount();
        acc.add(acc1);
        acc.add(acc2);
        insert acc;
        acc1.LI_Account_Id__c = acc2.Id;
        acc1.LQ_Account_Id__c = acc2.Id;
        update acc1;
        acc2.MDM_SFDC_Golden_Record_Id__c = acc1.Id;
        acc2.MDM_Validation_Status__c = 'Rejected';
        update acc2;
        test.stopTest();
    }
	
    @isTest
    static void testCheckIfCSHSelfRegistration() {
    	test.startTest();
        List<Account> acc = new List<Account>();
    	Account acc1 = UTL_TestData.createAccount();
        acc1.CSH_Self_Registration__c = 'Information Offering';
        acc.add(acc1);
        try{
             insert acc;
        }catch(Exception ex){
            Boolean expectedExceptionThrown = ex.getMessage().contains('Account should be customer portal enabled for self registration') ? true : false;
            System.assertEquals(true,expectedExceptionThrown,'account is updated' );
        }       
        test.stopTest();
    }
    
    static void testCheckIfCSHSelfRegistrationWillUpdate() {
    	test.startTest();
        List<Account> acc = new List<Account>();
    	Account acc1 = UTL_TestData.createAccount();
        acc.add(acc1);
        try{
             insert acc;
        }catch(Exception ex){
            Boolean expectedExceptionThrown = ex.getMessage().contains('Account should be customer portal enabled for self registration') ? true : false;
            System.assertEquals(false,expectedExceptionThrown,'account is updated' );
        }       
        test.stopTest();
    }
    
     /**
    * This test method used for update Account record of Global Customer Account
    */ 
    //User Story - ESPSFDCQI-4268
    
    @isTest
    static void testUpdateAccountOfGlobalCustomerType() {
        Account newAccount = UTL_TestData.createAccount();
        insert newAccount;
        Account existingAccount = [SELECT Id, Name,MDM_Category__c,RecordTypeId FROM Account where name = 'TestAccount']; 
        existingAccount.MDM_Category__c = CON_CRM.ACCOUNT_MDM_CATEGORY_LARGE_PHARMA; 
        existingAccount.RecordTypeId = CON_CRM.GLOBAL_CUSTOMER_ACCOUNT_RECORD_TYPE_ID;
        Test.startTest();
        update existingAccount;
        Test.stopTest();
    }
}