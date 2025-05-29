@isTest(seeAllData=false)
public class TST_DAO_ContentDocumentLink {
    @isTest
    static void testFileUpload() {
        Address__c testAccount1 = UTL_TPA_SetupTestData.getAccount();
        testAccount1.Name = 'Test Acc';
        insert testAccount1;

        TPA_Request__c tpaRequest1 = UTL_TPA_SetupTestData.getTestTPARequest();
        tpaRequest1.Request_Status__c = 'In Effect';
        tpaRequest1.OwnerId = UserInfo.getUserId();
        tpaRequest1.Service_Provider_Address__c = testAccount1.Id;
        tpaRequest1.Client_Address__c = testAccount1.Id;
        tpaRequest1.Client_Language__c = 'Japanese';
        tpaRequest1.Vendor_Language__c = 'Japanese';
        tpaRequest1.Vendor_Billing_Mailing_Country__c = 'united states';
        tpaRequest1.Is_CPC_Renewal_Notice_Sent__c = true;
        tpaRequest1.Is_CPC_Expiration_Notice_Sent__c = true;
        tpaRequest1.Is_CPC_Post_Expiration_Notice_Sent__c = true;
        insert tpaRequest1;
        
        Test.startTest();
        String file1 = 'Test Content'; 
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
        conVer.PathOnClient = 'ionicLogo.png'; // The files name, extension is very important here which will help the file in preview.
        conVer.Title = 'Proposal '; // Display name of the files
        conVer.VersionData = EncodingUtil.base64Decode(file1); // converting your binary string to Blog
        insert conVer;
        
        // First get the content document Id from ContentVersion
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
         
        //Create ContentDocumentLink
        ContentDocumentLink cDe = new ContentDocumentLink();
        cDe.ContentDocumentId = conDoc;
        cDe.LinkedEntityId = tpaRequest1.Id; // you can use objectId,GroupId etc
        cDe.ShareType = 'I'; // Inferred permission
        cDe.Visibility = 'InternalUsers';
        insert cDe;
        delete cDe;
        
        Test.stopTest();
    }
}