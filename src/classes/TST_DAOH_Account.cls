/**
* This test class is used to test all methods in Account Domain class.
* version : 1.0
*/
@isTest
private class TST_DAOH_Account {
    
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
        accP.CustomerSegment__c = 'FINANCIAL COMPANY';
        accP.Sub_Industry__c = 'BANKING';
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
    
    
    @isTest
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
    @isTest
    static void testCheck1() {
        test.startTest();
        Account acc1 = UTL_TestData.createAccount();
        acc1.RecordTypeId = CON_CRM.GLOBAL_CUSTOMER_ACCOUNT_RECORD_TYPE_ID;
        insert acc1;   
        acc1.MDM_Validation_Status__c = 'Validated';
        acc1.Risk_Rating__c = CON_CRM.ACCOUNT_RISK_RATING_6_DO_NOT_SELL;
        acc1.RecordTypeId = CON_CRM.GLOBAL_CUSTOMER_ACCOUNT_RECORD_TYPE_ID;
        update acc1;
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
        existingAccount = [SELECT Id, Name,MDM_Category__c,RecordTypeId FROM Account where name = 'TestAccount'];
        existingAccount.MDM_Category__c = CON_CRM.ACCOUNT_MDM_CATEGORY_NON_MID_SIZE_PHARMA; 
        update existingAccount;
        Test.stopTest();
    }

    @isTest
    static void testSetTpaVendorChecklist() {
        test.startTest();
        Address__c account = UTL_TPA_SetupTestData.getBlankAccount();
        account.Name = 'Test Account veeva';
        account.Vendor_Tier__c = 'N';
        account.Is_Payment_Risk__c = true;
        account.Vendor_Registration_Number__c = 9999;
        account.is_TPA_Account__c = true;
        account.Street__c = 'test';
        account.City__c = 'test';
        account.Country__c = 'test';
        account.PostalCode__c = 'test';
        account.AMA_Check_List__c = 'Y';
        insert account;
        account.Vendor_Tier__c = 'Y';
        update account;
        test.stopTest();
    }     
    
    @isTest
    public static void testSendEmail(){
        List<Account> accList = new List<Account>();
        Account parentAcc = UTL_TestData.createAccount();
        parentAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('MDM Validated Account').getRecordTypeId();
        parentAcc.name = 'Parent Account';
        parentAcc.Risk_Rating__c = CON_CRM.ACCOUNT_RISK_RATING_1_VERY_LOW;
        insert parentAcc;
        Account childAcc = UTL_TestData.createAccount();
        childAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('MDM Validated Account').getRecordTypeId();
        childAcc.ParentId = parentAcc.id;
        insert childAcc;
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp1 = UTL_TestData.createOpportunity(childAcc.id);
        opp1.OwnerId = UserInfo.getUserId();
        insert opp1;
        Opportunity opp2 = UTL_TestData.createOpportunity(parentAcc.id);
        opp2.OwnerId = UserInfo.getUserId();
        insert opp2;
        parentAcc = [Select id,Global_Risk_Rating__c from Account where name = 'Parent Account'];
        parentAcc.Risk_Rating__c = CON_CRM.ACCOUNT_RISK_RATING_6_DO_NOT_SELL;
        Test.startTest();
        update parentAcc;
        Test.stopTest();
    }
    
    @isTest
    public static void testSetRiskRating() {
        Test.startTest();
        Account parentAcc = UTL_TestData.createAccount();
        parentAcc.name = 'Parent Account';
        parentAcc.Risk_Rating__c = CON_CRM.ACCOUNT_RISK_RATING_1_VERY_LOW;
        insert parentAcc;
        Account childAcc = UTL_TestData.createAccount();
        childAcc.ParentId = parentAcc.id;
        insert childAcc;
        parentAcc.Risk_Rating__c = CON_CRM.ACCOUNT_RISK_RATING_6_DO_NOT_SELL;
        update parentAcc;
        parentAcc.Risk_Rating__c = CON_CRM.ACCOUNT_RISK_RATING_1_VERY_LOW;
        update parentAcc;
        Test.stopTest();
    }
    
    @isTest
    private static void testCreditAssessmentCheck() {
        Account acc = UTL_TestData.createAccount();
        acc.Date_Risk_Assessed__c = Date.newInstance(2021, 2, 2);
        insert acc;
        
        List<Credit_Control_Threshold__c> creditControlList = new List<Credit_Control_Threshold__c>();
        Credit_Control_Threshold__c cct = new Credit_Control_Threshold__c(Country__c = 'AL', Threshold_value_USD__c=50.00, Description__c='test');
        creditControlList.add(cct);
        Credit_Control_Threshold__c cct2 = new Credit_Control_Threshold__c(Account__c=acc.Id, Threshold_value_USD__c=50.00, Description__c='test', Business_Unit__c = 'RDS');
        creditControlList.add(cct2);
        insert creditControlList;
        
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opp.Line_of_Business__c ='Clinical';
        opp.Potential_Regions__c = 'Asia Pacific';
        opp.FPI_Date__c = Date.newInstance(2021, 12, 9);
        opp.FSP__c = 'No';
        opp.Global_project_unit__c = 'Biostats';
        opp.Population_Age_Group__c = 'Unknown';
        opp.Verbatim_Indication_Term__c = 'Test';
        opp.InterventionType__c = 'Biosimilar';
        opp.Early_Engagement_COE__c = 'Not Applicable';
        opp.StageName = CON_CRM.DEVELOPING_PROP_STAGE;
        insert opp;
        Contact cnt = UTL_TestData.createContact(acc.Id);
        insert cnt;
        OpportunityContactRole contactRole = UTL_TestData.createOpportunityContactRole(cnt.Id, opp.Id);
        insert contactRole;
        Product2 product = UTL_TestData.createProduct();
        product.Hierarchy_Level__c = CON_CRM.MATERIAL_LEVEL_HIERARCHY_OLI;
        product.ProductCode = 'Test01';
        product.Offering_Group_Code__c = 'GPRDSX';
        product.Material_Type__c = 'ZQUI';
        insert product;
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        oppLineItem.Description = 'Testing';
        oppLineItem.TotalPrice = 10001;
        oppLineItem.Update_Type__c = CON_CRM.UPDATE_TYPE_MULESOFT_SLAVE;
        insert oppLineItem;
        
        Test.startTest();
        acc.Date_Risk_Assessed__c = null;
        update acc;
        Test.stopTest();
        
    }
    
    @isTest
    public static void testValidateDescartesApproval() {
        upsert new  Descartes_Approval_Setting__c(Account_Enabled__c = true); 
        Account acc1 = UTL_TestData.createAccount();
        acc1.Name = 'Test Account DSP';
        Test.startTest();
            insert acc1;        
        Test.stopTest();
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest> ();
        Approval.ProcessSubmitRequest submitRequest = new Approval.ProcessSubmitRequest();
        submitRequest.setComments('Submitting request for approval');
        submitRequest.setObjectId(acc1.Id);
        requests.add(submitRequest); 
        Approval.ProcessResult[] processResults = Approval.process(requests, true);
        acc1.DPS_Status__c = 'Cleared';
        update acc1;  
        acc1.DPS_Status__c = 'Pending';
        update acc1; 
    }  
        
}