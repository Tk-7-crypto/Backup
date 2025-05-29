@isTest
public class TST_TGRH_CDADocusignStatus { 
	@isTest
    static void test1(){
        TST_CDA_SetupData testSetup = new TST_CDA_SetupData();
        testSetup.setUpCustomSetting();
        testSetup.setUpContactForEmail();
        testSetup.setupUserRequestor();
        testSetup.setupUserNegotiator();

        CDA_Approved_Governing_Law_Location__c governingLaw = TST_CDA_SetupData.getGoverningLaw('Test GL');
        insert governingLaw;

        QI_Legal_Entity__c testQiLegalEntity = TST_CDA_SetupData.createQiLegalEntity('Test Entity1', UTL_CDAUtility.CDA_BUSINESS_PART_LQ, governingLaw);
        insert testQiLegalEntity;

        CDA_Legal_POC_Cross_Walk__c testLegalPOC = new CDA_Legal_POC_Cross_Walk__c(CDA_Language__c='Chinese',Legal_POC_First_Name__c='TestChinese',Legal_POC_Last_Name__c='Attorney',Legal_POC_Email_Address__c='test@abc.com');
		insert testLegalPOC;

        CDA_Account__c testCdaAccount = testSetup.cdaAccount;

        CDA_Request__c cdaRequest = testSetup.setupTestDataForCustomer(testQiLegalEntity);
        CDA_Request__c testCDAReq = [Select Name, CDA_Id__c from CDA_Request__c where Id = :cdaRequest.Id];
        
        dsfs__DocuSign_Status__c testDSStatus = TST_CDA_SetupData.getDSStatusByRequestId(testCDAReq.CDA_Id__c);
        system.debug('--------------------> ' + testCDAReq.CDA_Id__c);
        testDSStatus.dsfs__Envelope_Status__c = 'Delivered';
        testDSStatus.dsfs__Subject__c = testCDAReq.CDA_Id__c + '-test Subject';
        update testDSStatus;
        Delete  testDSStatus;	
    }
}