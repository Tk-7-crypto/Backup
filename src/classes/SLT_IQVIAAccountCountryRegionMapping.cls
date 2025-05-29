/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for IQVIA_Account_Country_Region_Mapping Lookup Metadata Type.
 */
public class SLT_IQVIAAccountCountryRegionMapping extends fflib_SObjectSelector {
    
    /**
     * This method used to set field list of AccountCountryRegionMapping metadata.
     */
    public Set<String> fieldSet{
        get{
            fieldSet = new Set<String>();
            fieldSet.add('Region__c');
            fieldSet.add('Country__c');
            fieldSet.add('DeveloperName');
            fieldSet.add('Label');
            fieldSet.add('Potential_Region__c');
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
        return IQVIA_Account_Country_Region_Mapping__mdt.sObjectType;
    }
    
    /**
     * This method used to get all records of AccountCountryRegionMapping Metadata.
     * @return  Map<String, IQVIA_Account_Country_Region_Mapping__mdt>
     */
    public Map<String, IQVIA_Account_Country_Region_Mapping__mdt> getaccountCountryToRegionMetadataMap() {
        Map<String, IQVIA_Account_Country_Region_Mapping__mdt> accountCountryToRegionMetadataMap = new Map<String, IQVIA_Account_Country_Region_Mapping__mdt> ();
        List<IQVIA_Account_Country_Region_Mapping__mdt> accountCountryToRegionMetadataList = new List<IQVIA_Account_Country_Region_Mapping__mdt>();   
        accountCountryToRegionMetadataList = ((List<IQVIA_Account_Country_Region_Mapping__mdt>) Database.query(newQueryFactory(true).selectFields(fieldSet).toSOQL()));
        for(IQVIA_Account_Country_Region_Mapping__mdt accountCountryToRegionMetadata : accountCountryToRegionMetadataList) {
            if(!String.isBlank(accountCountryToRegionMetadata.Label)) {
               accountCountryToRegionMetadataMap.put(accountCountryToRegionMetadata.Label, accountCountryToRegionMetadata);
            }
        }
        return accountCountryToRegionMetadataMap;
    }
}