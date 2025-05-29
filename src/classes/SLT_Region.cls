public class SLT_Region extends fflib_SObjectSelector {

    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_Region() {
        super(false, true, true);
    }

    /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_Region(Boolean enforceFLS) {
        super(false, true, enforceFLS);
    }

    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>();
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return pse__Region__c.sObjectType;
    }

    /**
    * Method to get a single region by name
    * @return pse__Region__c
    */
    public pse__Region__c selectSingleRegionByName(String regionName, Set<String> regionFieldSet){
        fflib_QueryFactory regionQueryFactory = newQueryFactory(true);
        String queryString = regionQueryFactory.selectFields(regionFieldSet).setCondition('Name = :regionName').toSOQL();
        List<pse__Region__c> regions = (List<pse__Region__c>) Database.query(queryString);
        return (regions.size() > 0) ? regions.get(0) : null;
    }

    /**
    * Method to get a map of regions by name
    * @return Map<String,pse__Region__c> 
    */
    public Map<String,pse__Region__c> selectRegionByName(Set<String> regionNames, Set<String> regionFieldSet){
        regionFieldSet.add('Name');
        fflib_QueryFactory regionQueryFactory = newQueryFactory(true);
        String queryString = regionQueryFactory.selectFields(regionFieldSet).setCondition('Name IN :regionNames').toSOQL();
        List<pse__Region__c> regions = (List<pse__Region__c>) Database.query(queryString);
        Map<String,pse__Region__c> regionMap = new Map<String,pse__Region__c>();
        for(pse__Region__c region : regions){
            regionMap.put(region.Name,region);
        }
        return regionMap;
    }

    /**
     * Method to get a map of regions by 2 or 3 digit country code
     */
    public Map<String,pse__Region__c> selectRegionByCountryCode(Set<String> countryCodeSet){
        Set<String> defaultRegionFieldSet = new Set<String>{'Id', 'Name', 'pse__Parent_Region__c', 'pse__Region_Name_Chain__c', 'pse__Region_ID_Chain__c' };
        return selectRegionByCountryCode(countryCodeSet, defaultRegionFieldSet);
    }

    public Map<String,pse__Region__c> selectRegionByCountryCode(Set<String> countryCodeSet, Set<String> regionFieldSet){
        Set<String> mappingFieldSet = new Set<String>{'Country_Code_2_Char__c', 'Country_Code_3_Char__c', 'Region__c'};
        Map<String, PSA_Country_Region_Map__mdt> mappings = new SLT_PSA_CountryRegionMap().selectMappingsByCountryCode(countryCodeSet, mappingFieldSet);

        Map<String, String> regionNameToCodeMap = new Map<String,String>();
        for(String code : mappings.keySet()){
            PSA_Country_Region_Map__mdt mapping = mappings.get(code);
            regionNameToCodeMap.put(mapping.Region__c,code);
        }
        Set<String> regionNames = regionNameToCodeMap.keySet();

        fflib_QueryFactory regionQueryFactory = newQueryFactory(true);
        String queryString = regionQueryFactory.selectFields(regionFieldSet).setCondition('Name IN :regionNames').toSOQL();
        List<pse__Region__c> regions = (List<pse__Region__c>) Database.query(queryString);

        Map<String,pse__Region__c> regionMap = new Map<String,pse__Region__c>();
        for(pse__Region__c region : regions){
            String regionKey = regionNameToCodeMap.get(region.Name);
            regionMap.put(regionKey, region);
        }
        return regionMap;
    }
}