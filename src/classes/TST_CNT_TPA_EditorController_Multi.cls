@isTest(SeeAllData = False)
public class TST_CNT_TPA_EditorController_Multi {
    private static CNT_TPA_EditorController_Multi editorControllerInstance;
    private static TPA_Text_Editor__c txtEditorDemo;

    public static testMethod void testTpaEditorController() {
        txtEditorDemo = UTL_TPA_SetupTestData.createTpaTestEditorData('Test Page Name', 'Test Content', 'Test Page Title', 'Test Category');
        txtEditorDemo.Is_Active__c = true;
        update txtEditorDemo;

        list<TPA_Multilingual_Global_Settings__c> setObjList = new list<TPA_Multilingual_Global_Settings__c>();
        TPA_Multilingual_Global_Settings__c obj1 = new TPA_Multilingual_Global_Settings__c(Name = 'Test1', Supported_Language_Field_Map__c = 'Japanese~Japanese_Translation__c;English~English_Translation__c');
        setObjList.add(obj1);
        insert  setObjList;

        PageReference pageRef = Page.VFP_TPA_Documents_Editor_Multilingual;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', txtEditorDemo.Id);

        editorControllerInstance = new CNT_TPA_EditorController_Multi();
        editorControllerInstance.isPageTypeFixed = true;
        editorControllerInstance.pTypeName = 'Test Category';
        editorControllerInstance.isSorteable = true;
        editorControllerInstance.isSearchAllowed = true;
        editorControllerInstance.content = 'Test Content';
        editorControllerInstance.name = 'Test Name';
        editorControllerInstance.title = 'Test Title';
        String cont = editorControllerInstance.getHtmlContent();
        String recId = editorControllerInstance.getRecordId();
        String name = editorControllerInstance.getPageName();
        String globalSettings = editorControllerInstance.getGlobalSettings();
        String tpaTextEditor = '{"Content__c":"Test Content","Page_Name__c":"Test Page Name","Page_Title__c":"Test Page Title","Page_Type__c":"Test Category"}';

        Test.startTest();
        CNT_TPA_EditorController_Multi.saveRecord(tpaTextEditor);
        String completeData = editorControllerInstance.getAllData();
        editorControllerInstance.getTPA_EditorLoadData();
        editorControllerInstance.isPageTypeFixed = false;
        editorControllerInstance.getTPA_EditorLoadData();
        Test.stopTest();
    }
}