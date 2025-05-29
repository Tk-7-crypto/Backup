/**
* This test class is used to test Account Trigger.
* version : 1.0
*/
@isTest
private class TST_TGR_Account {
    
    @testsetup
    static void setupData(){
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
    static testMethod void testInsertContact() {
        test.startTest();
        Account newAccount = UTL_TestData.createAccount();
        insert newAccount;
        test.stopTest();
        Account existingAccount = [SELECT Id, Name FROM Account LIMIT 1];
        System.assertEquals('TestAccount', existingAccount.Name);
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
}