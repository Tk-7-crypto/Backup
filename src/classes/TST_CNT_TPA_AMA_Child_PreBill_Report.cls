@isTest(seeAllData = false)
public class TST_CNT_TPA_AMA_Child_PreBill_Report {
    @isTest
    public static void testPreBill(){
        test.startTest();
        Address__c testAddress = new Address__c(Name = 'Stark Tower');
        insert testAddress;
        TPA_Request__c testRequest = UTL_TPA_SetupTestData.getTestTPARequest();
        testRequest.Vendor_Contact_e_mail__c = 'vendor.email@gmail.com';
        testRequest.Authorized_Signer_Email__c = 'email.authorised@gmail.com';
        testRequest.Client_Company_Name_Address__r = testAddress;
        testRequest.Docusign_Custom_Picklist__c = 'test';
        insert testRequest;
        AMA_Agreement_Detail__c testAMAAgreement = new AMA_Agreement_Detail__c(TPA_Request__c = testRequest.id, Purchase_order_number__c = '31415', Current_Year_Fees__c = 3.0,  Date_Agreement_Activated__c = Date.newInstance(2023, 5,1), Contract_Type__c= 'testContract',Invoice_Contact__c = 'testContact',  Invoice_Contact_Email__c = 'test.contact@mail.com');
        insert testAMAAgreement;
        ApexPages.currentPage().getParameters().put('id', testAMAAgreement.id);
        CNT_TPA_AMA_Child_PreBill_Report report = new CNT_TPA_AMA_Child_PreBill_Report();
        report.sendMails();
        test.stopTest();
    }
}