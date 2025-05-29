@isTest
public class TST_CNT_TPA_AccountCompAttachmentReport {
    @testSetup
    static void dataSetUp(){
        Account acc = new Account(Name = 'Test acc', CurrencyIsoCode = 'USD', Region_Territory__c = 'China', BillingStreet = 'test1', BillingCity = 'test1', BillingCountry = 'test1', BillingPostalCode = 'test1', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');//Modified by C.P.Pandey under Issue-7181
        insert acc;
        Address__c testAddrs = new Address__c(Name = 'TPA Test Acc', recordTypeId = UTL_TPA_SetupTestData.getTPAVendorAddressRecordTypeId, CurrencyIsoCode = 'USD', Account__c = acc.Id, Industry__c = 'Biotech', Vendor_Tier__c = 'Y', Is_Payment_Risk__c = true, Vendor_Registration_Number__c = 9999, is_TPA_Account__c=true, Street__c = 'test', City__c = 'test', Country__c = 'test', PostalCode__c = 'test');
        insert testAddrs;
        Contact  con = new Contact(FirstName = 'TestFirstName', LastName = 'Test Contact', Email = 'sunny.bansal@metacube.com', AccountId = acc.id);
        insert con;
        
        acc = [select Id from Account where name = 'Test acc'];
        
        Account_Compliance__c accCompl = new Account_Compliance__c(Account__c = acc.Id, Client_TPA_Compliance_Hold__c = true, Vendor_TPA_Compliance_Hold__c = true, Client_TPA_Compliance_Hold_Reason__c = 'Client on Hold', Vendor_TPA_Compliance_Hold_Reason__c = 'Vendor on Hold');
        insert accCompl;
        
        
        
        
        ContentVersion cv = createContentVersionWithLink(accCompl.Id, 'Test Document');
        ContentVersion cv1 = createContentVersionWithLink(accCompl.Id, 'Test Document - IQ AGR');
    }

    public static ContentVersion createContentVersionWithLink(Id parentId, String title){
        Blob blobData = Blob.valueOf('Unit Test Attachment Body');
        ContentVersion contentVersionRecord = new ContentVersion();
        contentVersionRecord.title = title;
        contentVersionRecord.Description = 'TPA Certificate';
        contentVersionRecord.PathOnClient = title;
        contentVersionRecord.IsMajorVersion = true;
        contentVersionRecord.VersionData = blobData;
        insert contentVersionRecord;
        
        ContentDocument document = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE Title =: title];
        
        ContentDocumentLink contentDocumentlink = new ContentDocumentLink();
        contentDocumentlink.ContentDocumentId = document.Id;
        contentDocumentlink.LinkedEntityId = parentId;
        insert contentDocumentlink;
        
        return contentVersionRecord;
    }
    
    @isTest
    private static void testsendCertificateEmailPreviewP(){
        
        Account acc = [select Id from Account where name = 'Test acc'];
        Account_Compliance__c accComp = [select Id from Account_Compliance__c where Account__c =: acc.Id];
        Test.startTest();
        CNT_TPA_AccountCompAttachmentReport.searchData();
        Test.stopTest();
        
    }

}