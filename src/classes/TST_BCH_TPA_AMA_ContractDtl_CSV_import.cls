@isTest(seeAllData=false)
public class TST_BCH_TPA_AMA_ContractDtl_CSV_import {
    
    @testSetup 
    static void setup() {
        List<Address__c> accounts = new List<Address__c>();
        List<AMA_Contract_Detail__c> amaContracts = new List<AMA_Contract_Detail__c>();
        
        Address__c acc = UTL_TPA_SetupTestData.getAddress();
        acc.name='Bratton';
        acc.Street__c = 'Test Street';
        acc.City__c = 'Delhi';
        acc.Country__c = 'India';
        acc.PostalCode__c = '110092';
        acc.Vendor_Registration_Number__c = null;
        accounts.add(acc);
        insert accounts;
        
        AMA_Contract_Detail__c amaContract = UTL_TPA_SetupTestData.getAmaContractDetail();
        amaContract.Client__c='abc';
        amaContract.Client_Services_On_Behalf_Of__c='abc123 .inc';
                
        amaContracts.add(amaContract);
        insert amaContracts;
    }

    static testmethod void test() {
        Test.startTest();
        List<AMA_Contract_Detail__c> lst = [select id from AMA_Contract_Detail__c];
        BCH_TPA_AMA_ContractDtl_CSV_import bchObj = new BCH_TPA_AMA_ContractDtl_CSV_import();
        bchObj.action = 'deleteRecords';
        bchObj.contractsListToDelete = lst;
        bchObj.contractsListToinsert = lst;
        Id batchId = Database.executeBatch(bchObj);
        Test.stopTest();
        
    }

}