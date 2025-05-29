public with sharing class SLT_BoxChildFolder extends fflib_SObjectSelector {
    public Set<String> fieldSet{
        get{
            fieldSet = new Set<String>();
            fieldSet.add('Parent_Folder__r.QualifiedApiName');
            fieldSet.add('Folder_Name__c');
            fieldSet.add('QualifiedApiName');
            fieldSet.add('Label');
            fieldSet.add('Line_of_Business__c');
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
        return Box_Folder__mdt.sObjectType;
    }
    public List<Box_Folder__mdt> getChildFolders(String parentFolderName) {
        return ((List<Box_Folder__mdt>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Parent_Folder__r.QualifiedApiName =: parentFolderName').toSOQL()));
    }
    
}