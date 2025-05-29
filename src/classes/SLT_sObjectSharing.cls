/*
* Version       : 1.0
* Description   : This Apex class is selector layer for SObject Sharing
*/
public class SLT_sObjectSharing extends fflib_SObjectSelector {
    
    /**
* constructor to initialize CRUD and FLS
*/
    public SLT_sObjectSharing() {
        super(false, true, false);
    }
    
    /**
* constructor to initialize CRUD and FLS
*/
    public SLT_sObjectSharing(Boolean enforceCRUD, Boolean enforceFLS) {
        super(false, enforceCRUD, enforceFLS);
    }
    
    /**
* This method used to get field list of sobject
*/
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{SObject_Sharing__c.Id,SObject_Sharing__c.Name,SObject_Sharing__c.Enable_Sharing_Calculation__c};
            }
    
    /**
* This method used to set up type of sobject
* @return  Schema.SObjectType
*/
    public Schema.SObjectType getSObjectType() {
        return SObject_Sharing__c.sObjectType;
    }
    
    /**
* This method is used to get SObject Sharing
* @return List<Group>
*/
    public List<SObject_Sharing__c> getSObjectSharing(Set<String> fieldSet) {
        return (List<SObject_Sharing__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).toSOQL());
    }
}