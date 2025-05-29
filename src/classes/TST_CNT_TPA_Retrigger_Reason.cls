@isTest
public class TST_CNT_TPA_Retrigger_Reason {
	@TestSetup
    static void setupTestData()
    {
    }
    
    private static testmethod void testRetriggerReason(){
        TPA_Request__c tpaRequest = new TPA_Request__c(Client_Language__c = 'English', Data_Asset_List__c = 'AAN',
                                                       Purpose_List__c = 'Test Purpose List', IMS_Legal_Entity_List__c = 'test',
                                                       Agreement_Number__c = '123', Secondary_Data_Asset_List__c = 'Test');
        insert tpaRequest;
        TPA_Commercial_Review__c comRev = new TPA_Commercial_Review__c(Is_ReviewForm_Acknowledged__c = true,Action_Needed_By__c='TP-country',Action__c='Assigned to Commercial Owner (CO) – Awaiting CO Review',Receiver_s_Email__c='test@mail.com',TP_Country_Email__c='test1@mail.com',Manual_Review_Reason__c='test Reason',TPA_Request__c=tpaRequest.Id);
        insert comRev;
        CNT_TPA_Retrigger_Reason cntTgrReason = new CNT_TPA_Retrigger_Reason();
        cntTgrReason.recordId = comRev.Id;
        cntTgrReason.retriggerReason();
        List<TPA_Data_Asset__c> assetList = cntTgrReason.getDataAsset(tpaRequest.Id);
    } 
}