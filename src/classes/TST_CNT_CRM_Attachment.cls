@isTest
public class TST_CNT_CRM_Attachment {

    @testSetup
    public static void setup(){
        Account testAccount = UTL_TestData.createAccount();
        insert testAccount;
        Attachment testAttachment = UTL_TestData.createAttachment();
        testAttachment.Body = Blob.toPDF('testBlob');
        testAttachment.ParentId = testAccount.id; 
        insert testAttachment;    
    }
    
    @isTest
    public static void testConstructor(){
        Account testAccount =  [Select id,Name from Account where Name = 'TestAccount'];
        Attachment testAttachment =  [Select id, ParentId from Attachment where ParentId =: testAccount.id];
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(testAttachment); 
        PageReference pageRef = Page.VFP_CRM_Attachment;
        pageRef.getParameters().put('parentId', String.valueOf(testAttachment.ParentId));
        Test.setCurrentPage(pageRef); 
        CNT_CRM_Attachment testCNTAttachment = new CNT_CRM_Attachment();
        System.currentPageReference().getParameters().put('attachmentId', testAttachment.id);
        testCNTAttachment.deleteAttachment();
        Test.stopTest();
    }
}