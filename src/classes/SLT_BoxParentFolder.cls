public with sharing class SLT_BoxParentFolder extends fflib_SObjectSelector{
    
    public Set<String> fieldSet{
        get{
            fieldSet = new Set<String>();
            fieldSet.add('Related_Object__r.Label');
            fieldSet.add('Folder_Name__c');
            fieldSet.add('QualifiedApiName');
            fieldSet.add('IsRootFolder__c');
            fieldSet.add('Label');
            return fieldSet;
        } 
        set {
              fieldSet = value;        
        }
    }
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>();
    }
    public Schema.SObjectType getSObjectType() {
        return Box_Parent_Folder__mdt.sObjectType;
    }
    public Box_Parent_Folder__mdt getParentFolder(String objectName) {
        return ((Box_Parent_Folder__mdt) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Related_Object__r.Label =: objectName AND IsRootFolder__c = true').toSOQL()));
    }
}