@isTest
private class TST_SLT_EntityDefinition {
    testmethod static void selectEntityDefinition(){
        SLT_EntityDefinition slt= new SLT_EntityDefinition();
        slt.getSObjectFieldList();
        slt.getSObjectType();
        slt.selectNameByEntityName(new Set<String>{'Account','Case','Contact'});
    }
}