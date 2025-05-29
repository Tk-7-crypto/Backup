/**
 * @Author: Babita Dadarwal
 * @Date: 5 Jan 2016
 * @Purpose: Test Class for TPA_AllRequestsTTController class
 */

@isTest(SeeAllData=false)
public class TST_CNT_TPA_AllReqTATReport {

    @testSetup
    static void setupData() {
        Date todayDate = Date.today();

        Address__c testAccount1 = UTL_TPA_SetupTestData.getAccount();
        testAccount1.Name = 'Test Acc';
        insert testAccount1;

        TPA_Request__c tpaRequest = UTL_TPA_SetupTestData.getTestTPARequest();
        tpaRequest.OwnerId = UserInfo.getUserId();
        tpaRequest.Service_Provider_Address__c = testAccount1.Id;
        tpaRequest.Client_Address__c = testAccount1.Id;
        tpaRequest.Is_Submitted__c  = true;
        tpaRequest.Client_Region__c = 'US';
        tpaRequest.Data_Provided_By__c = 'IMS in lieu of Client';
        tpaRequest.Is_Data_Accessed_Via_IMS_Software__c = 'Yes';
        tpaRequest.AMA_USPrescriberData__c = 'Yes';
        tpaRequest.Does_the_request_require_information_con__c = 'Yes';
        tpaRequest.TPA_Request_Marked_as__c = 'Public';
        tpaRequest.Vendor_Company_Name__c = 'Test company';
        tpaRequest.LastAction__c = 'Request Edited By Client';
        tpaRequest.Is_Mail_Feature_Required__c = true;
        tpaRequest.Data_Access_Start_Date__c=todayDate;
        tpaRequest.Data_Access_End_Date__c=todayDate.addDays(2);
        tpaRequest.Requires_Manual_Review__c = false;
        tpaRequest.TP_Processor_Email__c = 'a.a@gmail.com';
        tpaRequest.TP_Processor_Name__c = 'Test TP Processor';
        tpaRequest.Vendor_Contact_e_mail__c = 'vendor.email@gmail.com';
        tpaRequest.TPA_Authorised_Signer__c = 'Yes';
        tpaRequest.Authorized_Signer_Email__c = 'email.authorised@gmail.com';
        tpaRequest.Request_status__c = 'In Effect';
        tpaRequest.Vendor_Contact_First_Name_Client__c = 'Test Client First Name';
        tpaRequest.Client_Request_Submission__c = todayDate;
        tpaRequest.In_IMS_Review__c = todayDate.addDays(2);
        tpaRequest.Sent_for_Signature__c = todayDate.addDays(2);
        tpaRequest.In_Effect_Date__c = Date.today();
        insert tpaRequest;
        
        TPA_TP_Processor__c tpProcessor = new TPA_TP_Processor__c(TP_Processor_Name__c = 'US TP Proccessor',
                                                                  TP_Processor_Email__c = 'a.b@metacube.com'); 
        insert tpProcessor;
        
        //Creating TPA_Region_Country
        TPA_Region_Country__c tpaRegionCountry = new TPA_Region_Country__c(Country__c = 'United States', TP_Processor__c = tpProcessor.id);
        insert tpaRegionCountry;
        
        TPA_Assigned_TP_Processor__c tpaAssignedTPProcessor = new TPA_Assigned_TP_Processor__c(Email__c = 'a.c@metacube.com', Initials__c = 'AB', Is_Active__c = true, TP_Processor__c = tpProcessor.id);
        insert tpaAssignedTPProcessor;
        
    }

    public static testMethod void testGetFinalReport() {
        Test.startTest();

        PageReference pageRef = Page.VFP_TPA_AllReqTATReport;
        pageRef.getParameters().put('RequestType', 'AMA');
        Test.setCurrentPage(pageRef);

        CNT_TPA_AllReqTATReport objController = new CNT_TPA_AllReqTATReport();
        //objController.getfinalReport();
        CNT_TPA_AllReqTATReport.allConditions objConditions = new CNT_TPA_AllReqTATReport.allConditions();
        objConditions.fromDate = Date.today();
        objConditions.toDate = Date.today();
        objConditions.RequestType = 'AMA';
        CNT_TPA_AllReqTATReport.getfinalReport(JSON.serialize(objConditions), 10, null);

        Test.stopTest();
    }
}