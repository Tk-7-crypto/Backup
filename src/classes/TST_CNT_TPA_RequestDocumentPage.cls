/**
* @Author: Govind Narayan Sharma
* @Description : Test Class for TPA_RequestDocumentController
*/
@isTest(SeeAllData=false)
private class TST_CNT_TPA_RequestDocumentPage { 

    @TestSetup static void setup() {
        Date todayDate = Date.today();

        TPA_Request__c tpaRequest1 = UTL_TPA_SetupTestData.getTestTPARequest();
        tpaRequest1.OwnerId = UserInfo.getUserId();
        tpaRequest1.Data_Access_End_Date__c = todayDate.addDays(3);
        tpaRequest1.Vendor_e_mail__c = 'test@mail.com';
        tpaRequest1.OwnerId = UserInfo.getUserId();
        tpaRequest1.Is_Mail_Feature_Required__c = true;
        tpaRequest1.Data_Access_Start_Date__c = todayDate;
        tpaRequest1.Data_Access_End_Date__c = todayDate.addDays(2);
        tpaRequest1.Request_status__c = 'Awaiting Vendor Signature';
        insert tpaRequest1;

        TPA_RequestDocument__c tpaRequestDoc = UTL_TPA_SetupTestData.getTPARequestDocument(tpaRequest1);
        insert tpaRequestDoc;
    }

    @isTest static void test_GetDocument() {
        Test.startTest();
        PageReference pageRef = new PageReference(String.valueOf(URL.getOrgDomainUrl())+'/tpa/TPA_RequestDocumentPage');
        Test.setCurrentPageReference(pageRef);

        CNT_TPA_RequestDocumentPage objController = new CNT_TPA_RequestDocumentPage();

        List<TPA_Request__c> requestList = [SELECT Id, Name FROM TPA_Request__c LIMIT 3];
        if(requestList.size() > 0) {
            //Added by Babita Dadarwal under ER-2106 Start
            pageRef.getparameters().put('EmailTitle', 'OND:IMS TPA Program:' + requestList[0].Name+', Signature Request for Vendor Tes TLLA');
            objController.getDocument();
            //Added by Babita Dadarwal under ER-2106 End

            String title = 'CP:IMS TPA Program:' + requestList[0].Name+', Signature Request for Vendor Tes TLLA';
            pageRef.getparameters().put('EmailTitle', title);
            objController.getDocument();
        }
        Test.stopTest();
    }
}