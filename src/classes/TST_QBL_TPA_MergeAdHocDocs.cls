@isTest(SeeAllData=false)
public class TST_QBL_TPA_MergeAdHocDocs {
    @TestSetup
    static void setupTestData()
    {
        Account acc =  new Account(Name = 'Test acc', CurrencyIsoCode = 'USD', Region_Territory__c = 'China', BillingStreet = 'test1', BillingCity = 'test1', BillingCountry = 'test1', BillingPostalCode = 'test1', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');//Modified by C.P.Pandey under Issue-7181
        insert acc;
        Address__c testAddrs = new Address__c(Name = 'TPA Test Acc', CurrencyIsoCode = 'USD', Account__c = acc.Id, Industry__c = 'Biotech', Vendor_Tier__c = 'Y', Is_Payment_Risk__c = true, Vendor_Registration_Number__c = 9999, is_TPA_Account__c=true, Street__c = 'test', City__c = 'test', Country__c = 'test', PostalCode__c = 'test');
        insert testAddrs;
        Contact  con = new Contact(FirstName = 'TestFirstName', LastName = 'Test Contact', Email = 'sunny.bansal@metacube.com', AccountId = acc.id);
        insert con;
        TPA_Request__c tpaRequest = new TPA_Request__c(
            OwnerId = UserInfo.getUserId(), 
            ClientContact__c = con.id, 
            Client_Language__c = 'English', 
            Data_Asset_List__c = 'AAN',
            Purpose_List__c = 'Test Purpose List', 
            IMS_Legal_Entity_List__c = 'test',
            Agreement_Number__c = '123', 
            Secondary_Data_Asset_List__c = 'Test');

        insert tpaRequest;
        
        TPA_Additional_Term__c newAdditionalTerm = new TPA_Additional_Term__c(
        	Addtional_Term__c = 'abc',
            Category__c = 'General Ad-Hoc Term',
            TPA_Request__c = tpaRequest.Id,
            Exhibit_Attached__c = true
        );
        
        insert newAdditionalTerm;
        
        Attachment attch = new Attachment();
        attch.Name = 'test.pdf';
        attch.ContentType = 'application/pdf';
        attch.Body = EncodingUtil.base64Decode('qwertyuiop');
        attch.ParentId = newAdditionalTerm.Id;
        insert attch;
    }

	@isTest
    public static void testExecute(){
        TPA_Request__c tpaRequest = [select id from TPA_Request__c limit 1];
        QBL_TPA_MergeAdHocDocs queuableObject = new QBL_TPA_MergeAdHocDocs();
        queuableObject.requestId = tpaRequest.Id;
        Test.startTest();
        System.enqueueJob(queuableObject);
        Test.stopTest();
    }
}