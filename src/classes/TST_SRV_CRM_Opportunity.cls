/*
* Version       : 1.0
* Description   : Test Class for SRV_CRM_Opportunity
*/
@isTest
public class TST_SRV_CRM_Opportunity {
    
    /**
    * This method is used to setup data for all methods.
    */
    @testSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Contact con = UTL_TestData.createContact(acc.Id);
        insert con;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opp.Name = 'Test';
        opp.Mulesoft_External_Id__c = '3456';
        opp.Proposal_Sent_Date__c =system.today() - 1;
        insert opp;
        List<User> userList = UTL_TestData.createUser(CON_CRM.SYSTEM_ADMIN_PROFILE, 1);
        insert userList;
        OpportunityTeamMember teamMember = UTL_TestData.createOpportunityTeamMember(opp.Id, userList[0].Id);
        insert teamMember;
        Id splitTypeId = SRV_CRM_OpportunitySplit.getOpportunitySplitTypeIdByName(CON_CRM.SPLIT_TYPE_NAME);
        System.runAs(userList[0]) {
            OpportunitySplit oppSplit = UTL_TestData.createOpportunitySplit(opp.Id, userList[0].Id, splitTypeId);
            insert oppSplit;
        }
        OpportunityContactRole ocr = UTL_TestData.createOpportunityContactRole(con.Id, opp.Id);
        insert ocr;
        Product2 product2 = UTL_TestData.createProduct();
        insert product2;
        PricebookEntry pbe = UTL_TestData.createPricebookEntry(product2.Id);
        insert pbe;
        PricebookEntry pbe2 = UTL_TestData.createPricebookEntry(product2.Id);
        pbe2.CurrencyIsoCode = 'INR';
        insert pbe2;
        OpportunityLineItem oli = UTL_TestData.createOpportunityLineItem(opp.Id, pbe.Id);
        oli.Project_Awarded_Price__c = 100.00;
        oli.Signed_Contract_Price__c = 100.00;
        insert oli;
        OpportunityLineItemSchedule olis = UTL_TestData.createOpportunityLineItemSchedule(Oli.Id);
        insert olis;
        Proxy_Project__c proxyProject = UTL_TestData.createProxyProject(opp.Id);
        insert proxyProject;
        Proxy_SCM_Agreement__c proxySCMAgreement = UTL_TestData.createProxySCMAgreement(opp.Id);
        insert proxySCMAgreement;
        List<Address__c> addressList = UTL_TestData.createAddresses(acc);
        for(Integer index = 0; index < addressList.size(); index++) {
            addressList[index].MDM_Validation_Status__c = 'Validated';
            addressList[index].RecordTypeId = Schema.SObjectType.Address__c.getRecordTypeInfosByDeveloperName().get('MDM_Validated').getRecordTypeId(); 
        }
        CON_GLOBAL.RELEASE_MAY_2021 = 9999.99;
        insert addressList;
        Revenue_Analyst__c revenueAnalyst = UTL_TestData.createRevenueAnalyst();
        insert revenueAnalyst;
    }
    
    /**
    * test method to get Opp detail
    */  
    static testmethod void testOppDetail() {
        Opportunity opp = [SELECT Id, AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];
        User userRecord = [SELECT Id FROM User WHERE LastName = 'lastName123' limit 1];
        System.runAs(userRecord) {
            Test.startTest();
            	OpportunityLineItem oli = [SELECT Id FROM OpportunityLineItem LIMIT 1];
            	List<Address__c> addressList = [SELECT Id FROM Address__c];
            	Revenue_Analyst__c revenueAnalyst = [SELECT Id FROM Revenue_Analyst__c LIMIT 1];
            
                BNF2__c bnf2 = UTL_TestData.createBNFRecord(opp, oli, addressList, revenueAnalyst.Id);
                insert bnf2;
                Mulesoft_Integration_Control__c mic = new Mulesoft_Integration_Control__c();
                mic.Allow_Opportunity_Number_Override__c = true;
                insert mic;
                
                Set<String> fieldSet = new Set<String>{'Name', 'Id'};
                Set<Id> oppIdSet = new Set<Id> {opp.Id};
                Map<Id, Opportunity> idToOpportunityMap = SRV_CRM_Opportunity.getOppDetail(oppIdSet, fieldSet);
                List<Opportunity> oppList = idToOpportunityMap.values();
            Test.stopTest();
            String expected = 'Test';
            String actual = oppList[0].Name;
            System.assertEquals(expected, actual);
        }
    }
    
    /**
    * test method to get Opp detail exception
    */  
    static testmethod void testGetOppDetailEx() {
        Opportunity opp = [SELECT Id, AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];
        Set<String> fieldSet = new Set<String>{'Name', 'I'}; 
        Set<Id> oppIdSet = new Set<Id> {opp.Id};
        User userRecord = [SELECT Id FROM User WHERE LastName = 'lastName123' limit 1];
        System.runAs(userRecord) {
            Test.startTest();
                try {
            	OpportunityLineItem oli  = [SELECT Id FROM OpportunityLineItem LIMIT 1];
            	List<Address__c> addressList = [SELECT Id FROM Address__c];
            	Revenue_Analyst__c revenueAnalyst = [SELECT Id FROM Revenue_Analyst__c LIMIT 1];
            
                BNF2__c bnf2 = UTL_TestData.createBNFRecord(opp, oli, addressList, revenueAnalyst.Id);
                insert bnf2;
                Mulesoft_Integration_Control__c mic = new Mulesoft_Integration_Control__c();
                mic.Allow_Opportunity_Number_Override__c = true;
                insert mic;
                    Map<Id, Opportunity> idToOpportunityMap = SRV_CRM_Opportunity.getOppDetail(oppIdSet, fieldSet);
                    system.assert(false);
                } catch(Exception ex) {
                    System.assertEquals('SRV_CRM_Opportunity.SRV_CRM_Opportunity_Exception', ex.getTypeName());
                }
            Test.stopTest();
        }
    }
    
    /**
    * test method to get Opp detail exception
    */  
    static testmethod void testGetOppDetailWithOppSplit() {
        Opportunity opp = [SELECT Id, AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];
        Set<Id> oppIdSet = new Set<Id>{opp.Id};
        Set<String> oppfieldSet = new Set<String>{'Id'};
        Set<String> oppSplitFieldSet = new Set<String>{'Id', 'Name'};
        Set<String> oppTeamFieldSet = new Set<String>{'Id'};
        User userRecord = [SELECT Id FROM User WHERE LastName = 'lastName123' limit 1];
        System.runAs(userRecord) {
            Test.startTest();
            	OpportunityLineItem oli  = [SELECT Id FROM OpportunityLineItem LIMIT 1];
            	List<Address__c> addressList = [SELECT Id FROM Address__c];
            	Revenue_Analyst__c revenueAnalyst = [SELECT Id FROM Revenue_Analyst__c LIMIT 1];
            
                BNF2__c bnf2 = UTL_TestData.createBNFRecord(opp, oli, addressList, revenueAnalyst.Id);
                insert bnf2;
                Mulesoft_Integration_Control__c mic = new Mulesoft_Integration_Control__c();
                mic.Allow_Opportunity_Number_Override__c = true;
                insert mic;
                try {
                    Map<Id, Opportunity> idToOpportunityMap = SRV_CRM_Opportunity.getOppByIdWithOppTeamSplits(oppIdSet, oppfieldSet, oppSplitFieldSet, oppTeamFieldSet, CON_CRM.SPLIT_TYPE_NAME);
                    system.assert(false);
                } catch(Exception ex) {
                    System.assertEquals('SRV_CRM_Opportunity.SRV_CRM_Opportunity_Exception', ex.getTypeName());
                }
            Test.stopTest();
        }
    }
    
    /**
    * test method to get Opp detail no exception
    */  
    static testmethod void testGetOppDetailWithOppSplitNoException() {
        Opportunity opp = [SELECT Id, AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];
        Set<Id> oppIdSet = new Set<Id>{opp.Id};
        Set<String> oppfieldSet = new Set<String>{'Id'};
        Set<String> oppSplitFieldSet = new Set<String>{'Id'};
        Set<String> oppTeamFieldSet = new Set<String>{'Id'};
        User userRecord = [SELECT Id FROM User WHERE LastName = 'lastName123' limit 1];
        System.runAs(userRecord) {
            Test.startTest();
            	OpportunityLineItem oli  = [SELECT Id FROM OpportunityLineItem LIMIT 1];
            	List<Address__c> addressList = [SELECT Id FROM Address__c];
            	Revenue_Analyst__c revenueAnalyst = [SELECT Id FROM Revenue_Analyst__c LIMIT 1];
            
                BNF2__c bnf2 = UTL_TestData.createBNFRecord(opp, oli, addressList, revenueAnalyst.Id);
                insert bnf2;
                Mulesoft_Integration_Control__c mic = new Mulesoft_Integration_Control__c();
                mic.Allow_Opportunity_Number_Override__c = true;
                insert mic;
                Map<Id, Opportunity> idToOpportunityMap = SRV_CRM_Opportunity.getOppByIdWithOppTeamSplits(oppIdSet, oppfieldSet, oppSplitFieldSet, oppTeamFieldSet, CON_CRM.SPLIT_TYPE_NAME);
            Test.stopTest();
            Integer expected = 1;
            Integer actual = idToOpportunityMap.size();
            System.assertEquals(expected, actual);
        }
    }
    
    /**
    * test method to check cloneOpportunity method
    */  
    static testmethod void testCloneOpportunity() {
        Opportunity opp = [SELECT Id, AccountId, Opportunity_Number__c,StageName FROM Opportunity LIMIT 1];
        Set<Id> oppIdSet = new Set<Id>{opp.Id};
        Set<String> oppfieldSet = new Set<String>{'Id'};
        Set<String> oppSplitFieldSet = new Set<String>{'Id'};
        Set<String> oppTeamFieldSet = new Set<String>{'Id'};
        User userRecord = [SELECT Id FROM User WHERE LastName = 'lastName123' limit 1];
        System.runAs(userRecord) {
            Test.startTest();
            OpportunityLineItem oli  = [SELECT Id FROM OpportunityLineItem LIMIT 1];
            List<Address__c> addressList = [SELECT Id FROM Address__c];
            Revenue_Analyst__c revenueAnalyst = [SELECT Id FROM Revenue_Analyst__c LIMIT 1];
            
            BNF2__c bnf2 = UTL_TestData.createBNFRecord(opp, oli, addressList, revenueAnalyst.Id);
            insert bnf2;
            Mulesoft_Integration_Control__c mic = new Mulesoft_Integration_Control__c();
            mic.Allow_Opportunity_Number_Override__c = true;
            insert mic;
            Map<String, String> mapTofieldValue = new Map<String, String>();
            mapTofieldValue.put('CloseDate', String.valueOf(Date.today()));
            mapTofieldValue.put('Name','OPP12345');
            mapTofieldValue.put('StageName',opp.StageName);
            mapTofieldValue.put('Opportunity_Number__c','54123245');
            mapTofieldValue.put('Mulesoft_External_Id__c','5412345');
            mapTofieldValue.put('CurrencyIsoCode','USD');
            
            Map<String, Boolean> objectTypeToIsCloneMap = new Map<String, Boolean>();
            objectTypeToIsCloneMap.put('Product2', true);
            objectTypeToIsCloneMap.put('RenewalOptions', true);
            objectTypeToIsCloneMap.put('OpportunityContactRole', true);
            SRV_CRM_Opportunity.cloneOpportunity(opp.Id, mapTofieldValue, true, 1, 1, objectTypeToIsCloneMap);
            Test.stopTest();
        }
        List<Opportunity> oppList = [SELECT Id FROM Opportunity];
        System.assertEquals(2, oppList.size()); 
    }
    
    /**
     * test method to check getClonedOpportunityContactRole method
     */ 
    static testMethod void testGetClonedOpportunityContactRole() {
        Opportunity opp = [SELECT Id, AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];
        OpportunityContactRole ocr = [SELECT Id, ContactId FROM OpportunityContactRole LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1]; 
        Test.startTest();
        OpportunityLineItem oli  = [SELECT Id FROM OpportunityLineItem LIMIT 1];
        List<Address__c> addressList = [SELECT Id FROM Address__c];
        Revenue_Analyst__c revenueAnalyst = [SELECT Id FROM Revenue_Analyst__c LIMIT 1];
        
        BNF2__c bnf2 = UTL_TestData.createBNFRecord(opp, oli, addressList, revenueAnalyst.Id);
        insert bnf2;
        Mulesoft_Integration_Control__c mic = new Mulesoft_Integration_Control__c();
        mic.Allow_Opportunity_Number_Override__c = true;
        insert mic;
        List<OpportunityContactRole> actualOppContactRoleList = SRV_CRM_Opportunity.getClonedOpportunityContactRole(opp.Id);
        Test.stopTest();
        System.assertEquals(con.Id, actualOppContactRoleList[0].ContactId);
    }
    
    /**
     * test method to check getClonedLineItemGroup method
     */ 
    /*static testMethod void testGetClonedLineItemGroup() {
        Opportunity opp = [SELECT Id, CloseDate FROM Opportunity LIMIT 1];
        Test.startTest();
        SRV_CRM_Opportunity.getClonedLineItemGroup(opp.Id);
        Test.stopTest();
    }*/
    
    /**
     * test method to check getCurrencyTypeRecords method
     */ 
    static testMethod void testGetCurrencyTypeRecords() {
        Test.startTest();
        SRV_CRM_Opportunity.getCurrencyTypeRecords();
        Test.stopTest();
    }
    
    /**
     * test method to check updateCloseDateOfOpportunity method
     */ 
    static testMethod void testUpdateCloseDateOfOpportunity() {
        Opportunity opp = [SELECT Id, AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];
        User userRecord = [SELECT Id FROM User WHERE LastName = 'lastName123' limit 1];  
        List<String> olifieldList = new List<String>{'Name','Id'};
        List<String> oliSchedulefieldList = new List<String>{'Id','ScheduleDate'};    
        System.runAs(userRecord) {
            Test.startTest();
            OpportunityLineItem oli  = [SELECT Id FROM OpportunityLineItem LIMIT 1];
            List<Address__c> addressList = [SELECT Id FROM Address__c];
            Revenue_Analyst__c revenueAnalyst = [SELECT Id FROM Revenue_Analyst__c LIMIT 1];
            
            BNF2__c bnf2 = UTL_TestData.createBNFRecord(opp, oli, addressList, revenueAnalyst.Id);
            insert bnf2;
            Mulesoft_Integration_Control__c mic = new Mulesoft_Integration_Control__c();
            mic.Allow_Opportunity_Number_Override__c = true;
            insert mic;
            SRV_CRM_Opportunity.updateCloseDateOfOpportunity(opp.Id, 4, true, olifieldList, oliSchedulefieldList);    
            Test.stopTest();
        }
        opp = [SELECT Id, CloseDate FROM Opportunity LIMIT 1];
        System.assertEquals(System.today().addYears(1).addDays(4), opp.CloseDate);
    }
    
    /**
     * test method to check updateCloseDateOfOpportunity method with Exception
     */ 
    static testMethod void testUpdateCloseDateOfOpportunityException() {
        Opportunity opp = [SELECT Id, AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];
        User userRecord = [SELECT Id FROM User WHERE LastName = 'lastName123' limit 1];  
        List<String> olifieldList = new List<String>{'Name','I'};
        List<String> oliSchedulefieldList = new List<String>{'Id','ScheduleDate'};    
        System.runAs(userRecord) {
            Test.startTest();
            OpportunityLineItem oli  = [SELECT Id FROM OpportunityLineItem LIMIT 1];
            List<Address__c> addressList = [SELECT Id FROM Address__c];
            Revenue_Analyst__c revenueAnalyst = [SELECT Id FROM Revenue_Analyst__c LIMIT 1];
            
            BNF2__c bnf2 = UTL_TestData.createBNFRecord(opp, oli, addressList, revenueAnalyst.Id);
            insert bnf2;
            Mulesoft_Integration_Control__c mic = new Mulesoft_Integration_Control__c();
            mic.Allow_Opportunity_Number_Override__c = true;
            insert mic;
            try {
                SRV_CRM_Opportunity.updateCloseDateOfOpportunity(opp.Id, 4, true, olifieldList, oliSchedulefieldList);    
            } catch(Exception ex) {
                System.assertEquals('SRV_CRM_Opportunity.SRV_CRM_Opportunity_Exception', ex.getTypeName());  
            }
            Test.stopTest();
        } 
    }
    
    /**
     * test method to check changeCurrencyOfOpportunity method
     */ 
    static testMethod void testChangeCurrencyOfOpportunity() {
        Opportunity opp = [SELECT Id, AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];
        User userRecord = [SELECT Id FROM User WHERE LastName = 'lastName123' limit 1];
        System.runAs(userRecord) {
            Test.startTest();
            OpportunityLineItem oli = [SELECT Id FROM OpportunityLineItem LIMIT 1];
            List<Address__c> addressList = [SELECT Id FROM Address__c];
            Revenue_Analyst__c revenueAnalyst = [SELECT Id FROM Revenue_Analyst__c LIMIT 1];
            
            BNF2__c bnf2 = UTL_TestData.createBNFRecord(opp, oli, addressList, revenueAnalyst.Id);
            insert bnf2;
            Mulesoft_Integration_Control__c mic = new Mulesoft_Integration_Control__c();
            mic.Allow_Opportunity_Number_Override__c = true;
            insert mic;
            SRV_CRM_Opportunity.changeCurrencyOfOpportunity(opp.Id, 'INR');
            Test.stopTest();
        }
        opp = [SELECT Id, CurrencyIsoCode FROM Opportunity LIMIT 1];
        System.assertEquals('INR', opp.CurrencyIsoCode);
    }
    
    /**
     * test method to check changeCurrencyOfOpportunity method with Exception
     */ 
    static testMethod void testChangeCurrencyOfOpportunityException() {
        Opportunity opp = [SELECT Id, AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];   
        User userRecord = [SELECT Id FROM User WHERE LastName = 'lastName123' limit 1];
        System.runAs(userRecord) {
            Test.startTest();
            OpportunityLineItem oli  = [SELECT Id FROM OpportunityLineItem LIMIT 1];
            List<Address__c> addressList = [SELECT Id FROM Address__c];
            Revenue_Analyst__c revenueAnalyst = [SELECT Id FROM Revenue_Analyst__c LIMIT 1];
            
            BNF2__c bnf2 = UTL_TestData.createBNFRecord(opp, oli, addressList, revenueAnalyst.Id);
            insert bnf2;
            Mulesoft_Integration_Control__c mic = new Mulesoft_Integration_Control__c();
            mic.Allow_Opportunity_Number_Override__c = true;
            insert mic;
            try {
                SRV_CRM_Opportunity.changeCurrencyOfOpportunity(opp.Id, 'I');
            } catch (Exception ex) {
                System.assertEquals('SRV_CRM_Opportunity.SRV_CRM_Opportunity_Exception', ex.getTypeName());   
            }
            Test.stopTest();
        }
    }
    
    /**
     * testMethod to check validateProxyObjectRecordsForOpportunity method
     */ 
    static testMethod void testValidateProxyObjectRecordsForOpportunity() {
        Opportunity opp = [SELECT Id, AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];
        User userRecord = [SELECT Id FROM User WHERE LastName = 'lastName123' limit 1];
        System.runAs(userRecord) {
            Test.startTest();
            OpportunityLineItem oli  = [SELECT Id FROM OpportunityLineItem LIMIT 1];
            List<Address__c> addressList = [SELECT Id FROM Address__c];
            Revenue_Analyst__c revenueAnalyst = [SELECT Id FROM Revenue_Analyst__c LIMIT 1];
            
            BNF2__c bnf2 = UTL_TestData.createBNFRecord(opp, oli, addressList, revenueAnalyst.Id);
            insert bnf2;
            Mulesoft_Integration_Control__c mic = new Mulesoft_Integration_Control__c();
            mic.Allow_Opportunity_Number_Override__c = true;
            insert mic;
            String errorMsg = SRV_CRM_Opportunity.validateProxyObjectRecordsForOpportunity(opp.Id);
            Test.stopTest();
            System.assertEquals('Opportunity is related to the following records and cannot change currency: SCM Agreement and Project', errorMsg);
        }
    }
    
    /**
     * test method to check updateAccountOnOpportunity method
     */ 
    static testMethod void testUpdateAccountOnOpportunity() {
        Opportunity opp = [SELECT Id, AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];
        User userRecord = [SELECT Id FROM User WHERE LastName = 'lastName123' limit 1];
        System.runAs(userRecord) {
            Test.startTest();
            OpportunityLineItem oli  = [SELECT Id FROM OpportunityLineItem LIMIT 1];
            List<Address__c> addressList = [SELECT Id FROM Address__c];
            Revenue_Analyst__c revenueAnalyst = [SELECT Id FROM Revenue_Analyst__c LIMIT 1];
            
            BNF2__c bnf2 = UTL_TestData.createBNFRecord(opp, oli, addressList, revenueAnalyst.Id);
            insert bnf2;
            Mulesoft_Integration_Control__c mic = new Mulesoft_Integration_Control__c();
            mic.Allow_Opportunity_Number_Override__c = true;
            insert mic;
            SRV_CRM_Opportunity.updateAccountOnOpportunity(opp);
            Test.stopTest();
        }
    }
}