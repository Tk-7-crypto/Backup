/**
* test class for SCM_BNFEditRedirectController
*/ 
@isTest
private class TST_SCM_BNFEditRedirectController {
    
    @testSetup
    static void dataSetup() {
        Account account = UTL_TestData.createAccount();
        insert account;
        
        Opportunity opp = UTL_TestData.createOpportunity(account.id);
        insert opp;
        
        Product2 product2 = UTL_TestData.createProduct();
        insert product2;
        
        PricebookEntry pbe = UTL_TestData.createPricebookEntry(product2.Id);
        insert pbe;
        
        List<Address__c> addressList = UTL_TestData.createAddresses(account);
        insert addressList;
        
        OpportunityLineItem oli = UTL_TestData.createOpportunityLineItem(opp.Id, pbe.Id);
        insert oli;
        
        List<User> userList = UTL_TestData.createUser('System Administrator', 1);
        insert userList;
    }
    
    /**
    * test method to check on Load Redirection method
    */ 
    static testMethod void testOnLoadRedirection() {
        Test.startTest();

        List<Opportunity> oppList = [SELECT Id, AccountId, Opportunity_Number__c FROM Opportunity];
        OpportunityLineItem oli = [SELECT Id FROM OpportunityLineItem LIMIT 1];
        List<User> userList = [SELECT Id FROM User WHERE LastName = 'lastName123'];
        List<Account> accountList = [SELECT Id FROM Account];
        List<Address__c> addressList = [SELECT Id FROM Address__c];
        
        Revenue_Analyst__c revenueAnalyst = UTL_TestData.createRevenueAnalyst();
        insert revenueAnalyst;
        
        BNF2__c bnf2 = UTL_TestData.createBNFRecord(oppList[0], oli, addressList, revenueAnalyst.Id);
        insert bnf2;
        
        MIBNF2__c mibnf2 = UTL_TestData.createMIBNF(oppList[0], revenueAnalyst);
        insert mibnf2;
        
        Contract_Management_Setting__c contractSetting = new Contract_Management_Setting__c();
        contractSetting.Allow_SalesOrg_Update_In_BNF_From_SCM__c = true;
        contractSetting.SOW__c = 'SOW';
        insert contractSetting;
        
        Proxy_SCM_Agreement__c proxyScmAgreement = UTL_TestData.createProxySCMAgreement(oppList[0].Id);
        proxyScmAgreement.is_Amendment_Record__c = false;
        insert proxyScmAgreement;
        
        String url = '';
        url += '/apex/BNF_Sales_Org_Selector?OpportunityId=' + oppList[0].Id;
        Apexpages.currentPage().getParameters().put('id',oppList[0].Id);
        Apexpages.currentPage().getParameters().put('newURL',url);
        System.runAs(userList[0]) {
            SCM_BNFEditRedirectController controller = new SCM_BNFEditRedirectController();
        }
        
        String urlParams =  '?retURL=%2F' + oppList[0].Id + '&ic=1' ; 
        urlParams += '&saveURL=/apex/BNFOpptyList?id=' + oppList[0].Id +'%26ic=1'; 
        urlParams += '&CF' + oppList[0].Id + '_lkid=' + oppList[0].Id;
        
        String redirectionParameters = '/apex/BNF_Sales_Org_Selector?OpportunityId=' + oppList[0].Id + '&AccountId=' + accountList[0].Id + '&' + urlParams;
        url = '/apex/SCM_BNFEditRedirect?newURL=' + redirectionParameters;
        Apexpages.currentPage().getParameters().put('newURL',url);
        System.runAs(userList[0]) {
            SCM_BNFEditRedirectController controller = new SCM_BNFEditRedirectController();
        } 
        Test.stopTest();
    }    
}