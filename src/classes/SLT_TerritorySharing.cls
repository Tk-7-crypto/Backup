/*
* Version       : 1.0
* Description   : This Apex class is selector layer for TerritorySharing
*/
public class SLT_TerritorySharing extends fflib_SObjectSelector {
    
    /**
* constructor to initialize CRUD and FLS
*/
    public SLT_TerritorySharing() {
        super(false, true, false);
    }
    
    /**
* constructor to initialize CRUD and FLS
*/
    public SLT_TerritorySharing(Boolean enforceCRUD, Boolean enforceFLS) {
        super(false, enforceCRUD, enforceFLS);
    }
    
    /**
* This method used to get field list of sobject
*/
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{Territory_Sharing__c.Id,Territory_Sharing__c.Name,Territory_Sharing__c.isActive__c};
            }
    
    /**
* This method used to set up type of sobject
* @return  Schema.SObjectType
*/
    public Schema.SObjectType getSObjectType() {
        return Territory_Sharing__c.sObjectType;
    }
    
    /**
* This method is used to get Territory Sharing
* @return List<Group>
*/
    public List<Territory_Sharing__c> getTerritorySharing(Set<String> fieldSet) {
        return (List<Territory_Sharing__c>) Database.query(newQueryFactory(true).setCondition('isActive__c = true').selectFields(fieldSet).toSOQL());
    }

}