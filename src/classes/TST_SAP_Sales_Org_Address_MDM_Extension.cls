@isTest
public class TST_SAP_Sales_Org_Address_MDM_Extension {
    @testSetup
    static void dataSetup() {
        Test.startTest();
        Account account =  UTL_TestData.createAccount();
        insert account;
        List<Address__c> address = UTL_TestData.createAddresses(account);
        if(address != null){
            address[0].New_Sales_Org__c = '[BE52] Forcea NV';
            address[0].Enabled_for_Email_invoicing__c = 'No';
        }
        insert address;
        Test.stopTest();
    }
    
    @isTest
    static void testSendNewSalesOrgRequestNotificationEmail(){
        User user = [Select Id from User where Profile.Name = 'System Administrator'AND IsActive = true Limit 1];
        Address__c address = [Select Id from  Address__c limit 1];
        Test.startTest();
        System.runAs(user){
            ApexPages.currentPage().getParameters().put('AddressId',address.Id);
            ApexPages.StandardController stc = new ApexPages.StandardController(address);
            SAP_Sales_Org_Address_MDM_Extension sapSales = new SAP_Sales_Org_Address_MDM_Extension(stc);
            sapSales.sendNewSalesOrgRequestNotificationEmail();
            sapSales.goBack();
        }
        Test.stopTest();
    }
}