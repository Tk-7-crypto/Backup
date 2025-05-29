/*
* Version       : 1.0
* Description   : This Apex class is selector layer for Territory2
*/
public class SLT_Territory extends fflib_SObjectSelector {
    
    /**
* constructor to initialize CRUD and FLS
*/
    public SLT_Territory() {
        super(false, true, false);
    }
    
    /**
* constructor to initialize CRUD and FLS
*/
    public SLT_Territory(Boolean enforceCRUD, Boolean enforceFLS) {
        super(false, enforceCRUD, enforceFLS);
    }
    
    /**
* This method used to get field list of sobject
*/
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{Territory2.Id,Territory2.Name,Territory2.Legacy_Id__c,Territory2.ParentTerritory2Id};
            }
    
    /**
* This method used to set up type of sobject
* @return  Schema.SObjectType
*/
    public Schema.SObjectType getSObjectType() {
        return Territory2.sObjectType;
    }
    
    /**
* This method used to get Territory2 by Id
* @return  Map<Id, Opportunity>
*/
    public List<Territory2> getTerritoryById(Set<ID> idSet, Set<String> fieldSet) {
        return (List<Territory2>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL());
    }
    
    public List<Territory2> getTerritory(Set<String> fieldSet) {
        return (List<Territory2>) Database.query(newQueryFactory(true).selectFields(fieldSet).toSOQL());
    }
    
    /**
* This method is used to get Territory2 with Parent Id
* @return List<Territory2>
*/
    public List<Territory2> getTerritoryByParentId(Set<String> fieldSet, Set<Id> parentIdSet) {
        return (List<Territory2>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('ParentTerritory2Id IN :parentIdSet').toSOQL());
    }
    
    /**
* This method is used to get Territory2 with WhereCondtion
* @return List<Territory2>
*/
    public List<Territory2> getTerritoryByWhereCondtion(Set<String> fieldSet, String whereCondtion) {
        return (List<Territory2>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(whereCondtion).toSOQL());
    }
    
}