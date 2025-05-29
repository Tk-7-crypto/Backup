@isTest(seeAllData = false)
public class TST_SLT_TPATextEditor { 
    @isTest
    static void testSLT_TPATextEditor() {
      //  Id testId = 'asedhnwaedqw345';
        String query = 'select id from TPA_Request__c';
        SLT_TPATextEditor.instance.getTPATextEditorData(new Set<String>());
        SLT_TPATextEditor.instance.getTPATextEditorDataById(null, new Set<String>());
        SLT_TPATextEditor.instance.getTPATextEditorDataByCondition('name = \'test\' ', new Set<String>());
        SLT_TPATextEditor.instance.getTPATextEditorDataByListOfId(new Set<String>(), new List<String>());
        SLT_TPATextEditor.instance.getTPATextEditorDataById(null);
    }

}