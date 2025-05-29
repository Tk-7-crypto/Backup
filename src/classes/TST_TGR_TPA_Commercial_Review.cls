@isTest
public class TST_TGR_TPA_Commercial_Review {
	private static testmethod void testRecordUpdation(){
        UTL_TPA_SetupTestData.createMultilingualTemplateSettingData();
        Account acc = new Account(Name = 'Test acc', CurrencyIsoCode = 'USD', Region_Territory__c = 'China', BillingStreet = 'test1', BillingCity = 'test1', BillingCountry = 'test1', BillingPostalCode = 'test1',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');//Modified by C.P.Pandey under Issue-7181
        insert acc;
        Contact  con = new Contact(FirstName = 'TestFirstName', LastName = 'Test Contact', Email = 'sunny.bansal@metacube.com', AccountId = acc.id);
        insert con;
        TPA_Request__c tpaRequest = new TPA_Request__c(ClientContact__c = con.id,Client_Language__c = 'English', Data_Asset_List__c = 'AAN',
                                                       Purpose_List__c = 'Test Purpose List', IMS_Legal_Entity_List__c = 'test',
                                                       Agreement_Number__c = '123', Secondary_Data_Asset_List__c = 'Test',Request_Status__c='In Review by IQVIA');
        insert tpaRequest;
        TPA_Commercial_Review__c comRev = new TPA_Commercial_Review__c(Is_ReviewForm_Acknowledged__c = false,Action_Needed_By__c='TP-country',Status__c='Awaiting Review',Receiver_s_Email__c='test@mail.com',TP_Country_Email__c='test1@mail.com',Manual_Review_Reason__c='test Reason',TPA_Request__c=tpaRequest.Id);
        insert comRev;
        comRev.Status__c = 'Combination Approved';
        update comRev;
    }
}