@isTest
public class TST_DAOH_Agency_Program {
    @testSetup
    public static void setup(){
        User adminUser = TST_PEP_TestDataFactory.createAdminUser('admin','adminPartner@iqvia.com');
        
        System.runAs(adminUser){
            Product2 prod = TST_PEP_TestDataFactory.createProduct('Test');
            insert prod;
            Agency_Program__c ap = TST_PEP_TestDataFactory.createAgencyProgram(prod);
            ap.Status__c = 'Inactive';
            insert ap;
            
            EmailTemplate testEmailTemplate1 = TST_PEP_TestDataFactory.createEmailTemplate('Test_First', 'Test_Template1', 'custom');
            testEmailTemplate1.Body = 'test1';
            testEmailTemplate1.FolderId = UserInfo.getUserId();
            insert testEmailTemplate1;
            EmailTemplate testEmailTemplate2 = TST_PEP_TestDataFactory.createEmailTemplate('Test_Second', 'Test_Template2', 'custom');
            testEmailTemplate2.Body = 'test2';
            testEmailTemplate2.FolderId = UserInfo.getUserId();
            insert testEmailTemplate2;
            EmailTemplate testEmailTemplate3 = TST_PEP_TestDataFactory.createEmailTemplate('Test_Third', 'Test_Template3', 'custom');
            testEmailTemplate3.Body = 'test3';
            testEmailTemplate3.FolderId = UserInfo.getUserId();
            insert testEmailTemplate3;
            EmailTemplate testEmailTemplate4 = TST_PEP_TestDataFactory.createEmailTemplate('Test_Expired', 'Test_Template4', 'custom');
            testEmailTemplate4.Body = 'test4';
            testEmailTemplate4.FolderId = UserInfo.getUserId();
            insert testEmailTemplate4;
        }
        
    }
    
    @isTest
    public static void testUpdateAgencyProgram(){
        List<Agency_Program__c> ap = [SELECT ID,Status__c FROM Agency_Program__c];
        ap[0].Status__c = 'Active';
        update ap;
    }
}