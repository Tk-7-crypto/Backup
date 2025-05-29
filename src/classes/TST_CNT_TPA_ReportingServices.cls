/*
*@Author  : Chandra Prakash Pandey
*@Purpose : 1. Test class for TPA_ReportingServicesController controller class

*/
@isTest(seeAllData=false)
public class TST_CNT_TPA_ReportingServices {

    public static testMethod void testLoadReport() {
    	Address__c testAccount1 = UTL_TPA_SetupTestData.getAccount();
        testAccount1.Name = 'Test Acc';
        insert testAccount1;

    	TPA_Request__c tpaRequest1 = UTL_TPA_SetupTestData.getTestTPARequest();
        tpaRequest1.OwnerId = UserInfo.getUserId();
        tpaRequest1.Service_Provider_Address__c = testAccount1.Id;
        tpaRequest1.Client_Address__c = testAccount1.Id;
        tpaRequest1.Client_Language__c = 'Japanese';
        tpaRequest1.Vendor_Language__c = 'Japanese';
        tpaRequest1.Vendor_Billing_Mailing_Country__c = 'united states';
        tpaRequest1.Request_Status__c = 'Expired';
        tpaRequest1.Data_Access_End_Date__c = Date.today().addDays(-1);
        tpaRequest1.Is_Potential_Vendor_Case__c = false;
        insert tpaRequest1;
        
        update new User(Id = UserInfo.getUserId(), EmployeeNumber = String.valueOf(System.currentTimeMillis()));
        
        Test.startTest();
        PageReference pageRef = Page.VFP_TPA_ReportingServices;
		Test.setCurrentPage(pageRef);
        String toDate = (DateTime.now()).format('MM/dd/yyyy');
        String endDate = (DateTime.newInstance(2023, 4, 8)).format('MM/dd/yyyy');
        String startDate = (DateTime.newInstance(2023, 1, 1)).format('MM/dd/yyyy');
        String inEffectFromDate = String.valueOf(DateTime.newInstance(2023,6,30).format('yyyy-MM-dd hh:mm:ss'));
        String inEffectToDate = String.valueOf(DateTime.newInstance(2023,7,15).format('yyyy-MM-dd hh:mm:ss'));
        String searchFil = '{"startDate":"' + startDate + '","endDate":"'+ endDate +'","status":"Awaiting Vendor Submission","reqType":"Bulk","requestingCountry":"United States","vendorName":"testing","clientName":""}';
		ApexPages.currentPage().getParameters().put('report','Test');
        ApexPages.currentPage().getParameters().put('searchFil',searchFil);
        ApexPages.currentPage().getParameters().put('showTestRequests','true');
        ApexPages.currentPage().getParameters().put('volDates', inEffectFromDate + ';' + inEffectToDate);
        CNT_TPA_ReportingServices reportObj = new CNT_TPA_ReportingServices();
        reportObj.initializeValues();
        reportObj.getCountryList();
        reportObj.getRequestTypeList();
        reportObj.getStatusList();
        reportObj.searchDet = '{"startDate":"' + startDate + '","endDate":"' + endDate + '","status":"Awaiting Vendor Submission","reqType":"Bulk","requestingCountry":"United States","vendorName":"testing","clientName":""}';
        reportObj.redirectToExport();
        reportObj.redirectVolToExport();
        String t = reportObj.completedKeyword;
        String conditions = '{"fromDate":"' + startDate + '","toDate":"'+ toDate +'","pageSize":"100"}';
        CNT_TPA_ReportingServices.loadReport('CDL', 10,'{"startDate":"' + startDate + '","endDate":"' + endDate + '","status":"Awaiting Vendor Submission","reqType":"Bulk","requestingCountry":"United States","vendorName":"testing","clientName":""}', null);
        CNT_TPA_ReportingServices.loadReport('ITPR', 10,'{"startDate":"' + startDate + '","endDate":"' + endDate + '","status":"Awaiting Vendor Submission","reqType":"Bulk","requestingCountry":"United States","vendorName":"testing","clientName":""}', null);
        
        CNT_TPA_ReportingServices.loadVendorLicenseReport(1, null, String.valueof(DateTime.now()), String.valueof(DateTime.now()), true);
        CNT_TPA_ReportingServices.loadGenerateTPSAReport( null, conditions);
        
        CNT_TPA_ReportingServices.loadVendorLicenseReport(1, tpaRequest1.Id, String.valueof(DateTime.now()), String.valueof(DateTime.now()), true);
        CNT_TPA_ReportingServices.loadGenerateTPSAReport(tpaRequest1.Id,conditions);
        Test.stopTest();
    }
}