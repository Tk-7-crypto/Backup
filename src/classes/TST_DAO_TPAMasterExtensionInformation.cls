@isTest
public class TST_DAO_TPAMasterExtensionInformation {
 @TestSetup static void setup() {
        Account testAccount1 = new Account();
        testAccount1.Name = 'Test Acc';
        testAccount1.CustomerSegment__c = 'GOVERNMENT';
        testAccount1.Sub_Industry__c = 'STATE';
        insert testAccount1;
        
        Address__c testNewClientAccount = UTL_TPA_SetupTestData.getAddress();
        testNewClientAccount.Name = 'test New Client';
        testNewClientAccount.is_TPA_Account__c = true;
        testNewClientAccount.Account__c = testAccount1.Id;
        testNewClientAccount.Street__c = 'test';
        testNewClientAccount.City__c = 'test';
        testNewClientAccount.Country__c = 'test';
        testNewClientAccount.PostalCode__c = 'test';
        insert testNewClientAccount;
        
       
        TPA_Master_Extension_Information__c vendorOffRetAckObj = new TPA_Master_Extension_Information__c(
            TPA_Accounts_Address__c = testNewClientAccount.Id,
            Return_Destruction_Ack_Outstanding__c = true);
        
        insert vendorOffRetAckObj;
    }
    
    @isTest static void test_DAO_TPAMasterExtensionInformation() {
        Test.StartTest();
        TGRH_TPARequest.isOnHoldFieldUpdate = true;
        List<TPA_Master_Extension_Information__c> tpaMasterExtLst = [SELECT Id FROM TPA_Master_Extension_Information__c LIMIT 1];
        if(tpaMasterExtLst.size() > 0) {
            update tpaMasterExtLst[0];
        }
    }
}