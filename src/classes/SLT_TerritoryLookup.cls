/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Territory Lookup Metadata Type.
 */
public class SLT_TerritoryLookup extends fflib_SObjectSelector {
    
    /**
     * This method used to set field list of Territory Lookup metadata.
     */
    public Set<String> fieldSet{
        get{
            fieldSet = new Set<String>();
            fieldSet.add('AND_Territory_Region__c');
            fieldSet.add('ISO_Code__c');
            fieldSet.add('DeveloperName');
            fieldSet.add('Label');
            return fieldSet;
        } 
        set {
              fieldSet = value;        
        }
    }
        
    /**
     * This method used to get field list of sobject
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>();
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Territory_lookup__mdt.sObjectType;
    }
    
    /**
     * This method used to get all records of Territory Lookup
     * @return  Set<String>
     */
    public Map<String, Territory_lookup__mdt> getTerritoryLookup() {
        Map<String, Territory_lookup__mdt> territoryLookupMetadataMap = new Map<String, Territory_lookup__mdt> ();
        List<Territory_lookup__mdt> territoryLookupList = new List<Territory_lookup__mdt>();   
        territoryLookupList = ((List<Territory_lookup__mdt>) Database.query(newQueryFactory(true).selectFields(fieldSet).toSOQL()));
        for(Territory_lookup__mdt territoryLookup : territoryLookupList) {
            if(!String.isBlank(territoryLookup.Label)) {
               territoryLookupMetadataMap.put(territoryLookup.Label, territoryLookup);
            }
        }
        return territoryLookupMetadataMap;
    }
}