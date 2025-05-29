/*
*@Author  : Supriya Johari
*@Purpose : 1. Test class for Script AMA_Batch_Client_Vendor_Matching_Script
*/
@isTest(seeAllData=false)
public class TST_BCH_TPA_AMA_New_Client_Vendor_Script {
    
    @testSetup 
    static void setup() {
        List<Address__c> accounts = new List<Address__c>();
        List<AMA_Contract_Detail__c> amaContracts = new List<AMA_Contract_Detail__c>();
        List<TPA_AMA_Client_Vendor_Search_Map__c> amaClientVendorSearchList = new List<TPA_AMA_Client_Vendor_Search_Map__c>();
        List<TPA_AMA_Client_Vendor_Match__c> amaClientVendorMatchingList = new List<TPA_AMA_Client_Vendor_Match__c>();
        
        Address__c acc = UTL_TPA_SetupTestData.getAddress();
        acc.name='Bratton';
        acc.Street__c = 'Test Street';
        acc.City__c = 'Delhi';
        acc.Country__c = 'India';
        acc.PostalCode__c = '110092';
        acc.Vendor_Registration_Number__c = null;
        accounts.add(acc);
        Address__c acc1 = UTL_TPA_SetupTestData.getAddress();
        acc1.name='abc LLc';
        acc1.Street__c = 'Test Street';
        acc1.City__c = 'Delhi';
        acc1.Country__c = 'India';
        acc1.PostalCode__c = '110092';
        acc1.Vendor_Registration_Number__c = null;
        accounts.add(acc1);
        Address__c acc2 = UTL_TPA_SetupTestData.getAddress();
        acc2.name='xyz';
        acc2.Street__c = 'Test Street';
        acc2.City__c = 'Delhi';
        acc2.Country__c = 'India';
        acc2.PostalCode__c = '110092';
        acc2.Vendor_Registration_Number__c = null;
        accounts.add(acc2);
        Address__c acc3 = UTL_TPA_SetupTestData.getAddress();
        acc3.name='testClient1';
        acc3.Street__c = 'Test Street';
        acc3.City__c = 'Delhi';
        acc3.Country__c = 'India';
        acc3.PostalCode__c = '110092';
        acc3.Vendor_Registration_Number__c = null;
        accounts.add(acc3);
        insert accounts;
        
        
        AMA_Contract_Detail__c amaContract = UTL_TPA_SetupTestData.getAmaContractDetail();
        amaContract.Client__c='abc';
        amaContract.Client_Services_On_Behalf_Of__c='abc123 .inc';
        AMA_Contract_Detail__c amaContract1 = UTL_TPA_SetupTestData.getAmaContractDetail();
        amaContract1.Client__c='xyz';
        amaContract1.Client_Services_On_Behalf_Of__c='xyz Ltd';
        AMA_Contract_Detail__c amaContract2 = UTL_TPA_SetupTestData.getAmaContractDetail();
        amaContract2.Client__c='testClient1 us';
        amaContract2.Client_Services_On_Behalf_Of__c='abc LLc';
                
        amaContracts.add(amaContract);
        amaContracts.add(amaContract1);
        amaContracts.add(amaContract2);
        insert amaContracts;
        
       
        TPA_AMA_Client_Vendor_Search_Map__c clientVendorMatchRecord1 = UTL_TPA_SetupTestData.getTpaAmaClientVendSearchMap();
        clientVendorMatchRecord1.TPA_Account_Address__c = acc.id;
        clientVendorMatchRecord1.AMA_Account_Search_Text__c = 'Bratton';
        amaClientVendorSearchList.add(clientVendorMatchRecord1);
        insert amaClientVendorSearchList;
        
        TPA_AMA_Settings__c amaSetting = new TPA_AMA_Settings__c(Name ='AMA Settings',Dev_Mail_ID__c='neha.bansal@metacube.com;test@gmail.com');
        insert amaSetting;
       
    }

    static testmethod void test() {
        Test.startTest();
        BCH_TPA_AMA_New_Client_Vendor_Script amaBatchClientVendorMatchingScript = new BCH_TPA_AMA_New_Client_Vendor_Script();
        Id batchId = Database.executeBatch(amaBatchClientVendorMatchingScript);
        Test.stopTest();
        List<TPA_AMA_Client_Vendor_Match__c> allac = [select id ,Client_Name__c, Client_Services_On_Behalf_Of__c, IMS_Client_Names__c, IMS_Total_Clients__c, Mapped_Account_Id__c, Mapped_Account_Name__c, Truncated_Name__c from TPA_AMA_Client_Vendor_Match__c];
        system.debug('TPA_AMA_Client_Vendor_Match__c is: '+ allac);
        
    }

}