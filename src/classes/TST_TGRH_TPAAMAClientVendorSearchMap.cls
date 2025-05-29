@isTest(seeAllData=false)
public class TST_TGRH_TPAAMAClientVendorSearchMap {
    
    private static String clientListCSV;
    private static boolean fileIteratedSuccessfully = false;
    
    public static testMethod void testcases_clientListUploaded() {
        Address__c acc =  [select id, Is_AMA_Account__c from Address__c where name = 'Test Account'];
        Address__c acc2 =  [select id, Is_AMA_Account__c from Address__c where name = 'Test Account2'];
        TPA_AMA_Client_Vendor_Search_Map__c clientVendorMatchRecord = new TPA_AMA_Client_Vendor_Search_Map__c(TPA_Account_Address__c = acc.id, AMA_Account_Search_Text__c = 'test');
        Test.startTest();
        insert clientVendorMatchRecord;
        clientVendorMatchRecord.TPA_Account_Address__c = acc2.id;
        update clientVendorMatchRecord;
        clientVendorMatchRecord.AMA_Account_Search_Text__c = 'Test Client';
        update clientVendorMatchRecord;
        acc = [select id, Is_AMA_Account__c from Address__c where id = :acc.id];
        //System.assertNotEquals(null,clientVendorMatchRecord.id);
        //System.assertEquals(true,acc.Is_AMA_Account__c);
        Test.stopTest();
    }
    
    @TestSetup
    static void setupTestData() {
        Address__c testAccount = UTL_TPA_SetupTestData.getTestAccountByNameAndRegNum('Test Account',1201);
        Address__c testAccount1 = UTL_TPA_SetupTestData.getTestAccountByNameAndRegNum('Test Account2',1202);
        
    }
}