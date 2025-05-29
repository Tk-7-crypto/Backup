@isTest
public class TST_DAO_DocusignStatus { 
    @isTest
    static void TestDAO_DocusignStatus(){
        TPA_Request__c objTpaReq = UTL_TPA_SetupTestData.getTPARequest();
        dsfs__DocuSign_Status__c objDocusignStatus = UTL_TPA_SetupTestData.getDocusignStatus(objTpaReq.id);
        objDocusignStatus.dsfs__Envelope_Status__c = 'Delivered';
        update objDocusignStatus;
        Delete  objDocusignStatus;     
    }    
}