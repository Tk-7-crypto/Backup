@isTest
private class TST_SLT_FieldDefinition {
    
    testmethod static void testselectField(){
        SLT_FieldDefinition slt=new SLT_FieldDefinition();
        slt.getSObjectFieldList();
        slt.getSObjectType();
        slt.selectFieldByEntityId('Case','\'Id\',\'CaseNumber\''); 
        slt.selectFieldByEntityIdAndDefaultField('Activity__c'); 
        slt.selectshowFieldGroupCheckboxData('Activity__c');
        slt.showFieldGroupCheckboxCustomData('Activity__c');
        
    }
}