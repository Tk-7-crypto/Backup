@isTest
private class TST_SLT_Document {

    static Document setDocumentData(){
        Document documentRecord = UTL_TestData.createDocument(CON_CPQ.QC_CHECK_LIST, 'QC_Check_List', 'application/pdf');
        documentRecord.IsPublic = true;
        documentRecord.FolderId = UserInfo.getUserId();
        insert documentRecord;
        return documentRecord;
    }

    @isTest
    static void testSelectDocumentById(){
        Document testDocument  = setDocumentData();

        Test.startTest();
            List<Document> documentList = new SLT_Document().selectById(new Set<Id>{testDocument.Id});
        Test.stopTest();
    }

    @isTest
    static void testSelectDocumentByName(){
        setDocumentData();

        Test.startTest();
            List<Document> documentList = new SLT_Document().selectUserByName(CON_CPQ.QC_CHECK_LIST);
            List<Document> documentList2 = new SLT_Document().selectByDeveloperName('GRA_Template');
        Test.stopTest();
    }
}