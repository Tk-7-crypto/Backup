@IsTest
public  class TST_SLT_ContentWorkspace {
    @testSetup
    static void dataSetup() {
        ContentWorkspace cws = new ContentWorkspace(Name='TestContentWorkspaces');
        insert cws;
    }
    
    testmethod static void selectContentWorkspace(){
        SLT_ContentWorkspace slt = new SLT_ContentWorkspace();
        slt.getSObjectFieldList();
        slt.getSObjectType();
        ContentWorkspace w = slt.selectByName(new Set<String>{'TestContentWorkspaces'})[0];
        List<ContentWorkspace> ws = new List<ContentWorkspace>();
        ws = slt.selectByRootContentFolderId(new Set<Id>{w.RootContentFolderId});
        System.assertEquals(1, ws.size());
    }
}