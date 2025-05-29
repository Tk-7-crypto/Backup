public class SLT_PSA_CountryRegionMap extends fflib_SObjectSelector {

    public SLT_PSA_CountryRegionMap() {
        super(false, true, true);
    }

    public SLT_PSA_CountryRegionMap(Boolean enforceFLS) {
        super(false, true, enforceFLS);
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>();
    }

    public Schema.SObjectType getSObjectType(){
        return PSA_Country_Region_Map__mdt.sObjectType;
    }

    /**
     * This method will return the complete country name/country code/region listing with all entries and fields
     */
    public List<PSA_Country_Region_Map__mdt> selectAllMappings(){
        fflib_QueryFactory queryFactory = newQueryFactory(true);
        String queryString = queryFactory.selectFields(getFields()).toSOQL();
        List<PSA_Country_Region_Map__mdt> mappings = (List<PSA_Country_Region_Map__mdt>) Database.query(queryString);
        return mappings;
    }

    /**
     * This method will return a region mapping for a full QIP country name
     */
    public Map<String,PSA_Country_Region_Map__mdt> selectMappingsByQIPCountry(Set<String> QIPCountrySet){
        fflib_QueryFactory queryFactory = newQueryFactory(true);
        String queryString = queryFactory.selectFields(getFields()).setCondition('QIP_Country__c IN :QIPCountrySet').toSOQL();
        List<PSA_Country_Region_Map__mdt> mappings = (List<PSA_Country_Region_Map__mdt>) Database.query(queryString);
        Map<String,PSA_Country_Region_Map__mdt> mappingMap = new Map<String,PSA_Country_Region_Map__mdt>();
        for(PSA_Country_Region_Map__mdt mapping : mappings){
            mappingMap.put(mapping.QIP_Country__c, mapping);
        }
        return mappingMap;
    }

    /**
     * This method will return a region mapping for 2 digit country codes
     */
    public Map<String,PSA_Country_Region_Map__mdt> selectMappingsByCountryCode2(Set<String> countryCode2Set){
        return selectMappingsByCountryCode2(countryCode2Set, getFields());
    }

    public Map<String,PSA_Country_Region_Map__mdt> selectMappingsByCountryCode2(Set<String> countryCode2Set, Set<String> fieldSet){
        fflib_QueryFactory queryFactory = newQueryFactory(true);
        String queryString = queryFactory.selectFields(fieldSet).setCondition('Country_Code_2_Char__c IN :countryCode2Set').toSOQL();
        List<PSA_Country_Region_Map__mdt> mappings = (List<PSA_Country_Region_Map__mdt>) Database.query(queryString);
        Map<String,PSA_Country_Region_Map__mdt> mappingMap = new Map<String,PSA_Country_Region_Map__mdt>();
        for(PSA_Country_Region_Map__mdt mapping : mappings){
            mappingMap.put(mapping.Country_Code_2_Char__c, mapping);
        }
        return mappingMap;
    }

    /**
     * This method will return a region mapping for 3 digit country codes
     */
    public Map<String,PSA_Country_Region_Map__mdt> selectMappingsByCountryCode3(Set<String> countryCode3Set){
        return selectMappingsByCountryCode3(countryCode3Set, getFields());
    }

    public Map<String,PSA_Country_Region_Map__mdt> selectMappingsByCountryCode3(Set<String> countryCode3Set, Set<String> fieldSet){
        fflib_QueryFactory queryFactory = newQueryFactory(true);
        String queryString = queryFactory.selectFields(fieldSet).setCondition('Country_Code_3_Char__c IN :countryCode3Set').toSOQL();
        List<PSA_Country_Region_Map__mdt> mappings = (List<PSA_Country_Region_Map__mdt>) Database.query(queryString);
        Map<String,PSA_Country_Region_Map__mdt> mappingMap = new Map<String,PSA_Country_Region_Map__mdt>();
        for(PSA_Country_Region_Map__mdt mapping : mappings){
            mappingMap.put(mapping.Country_Code_3_Char__c, mapping);
        }
        return mappingMap;
    }

    /**
     * This method will return a region mapping for any mix of 2 or 3 digit country code
     */
    public Map<String,PSA_Country_Region_Map__mdt> selectMappingsByCountryCode(Set<String> countryCodeSet){
        return selectMappingsByCountryCode(countryCodeSet, getFields());
    }

    public Map<String,PSA_Country_Region_Map__mdt> selectMappingsByCountryCode(Set<String> countryCodeSet, Set<String> fieldSet){
        Map<String,PSA_Country_Region_Map__mdt> countryCode2Mappings = selectMappingsByCountryCode2(countryCodeSet, fieldSet);
        Map<String,PSA_Country_Region_Map__mdt> countryCode3Mappings = selectMappingsByCountryCode3(countryCodeSet, fieldSet);
        Map<String,PSA_Country_Region_Map__mdt> mappingMap = new Map<String,PSA_Country_Region_Map__mdt>();
        mappingMap.putAll(countryCode2Mappings);
        mappingMap.putAll(countryCode3Mappings);
        return mappingMap;
    }

    /**
     * This method returns and country codes that are not found with a mapping
     */
    public Set<String> findInvalidCountryCodes(Set<String> countryCodes){
        Set<String> invalidCodeSet = new Set<String>(); 
        Map<String,PSA_Country_Region_Map__mdt> mappings = selectMappingsByCountryCode(countryCodes, new Set<String>{'Country_Code_2_Char__c', 'Country_Code_3_Char__c'});
        for(String code : countryCodes){
            if(mappings.get(code) == null){
                invalidCodeSet.add(code);
            }
        }
        return invalidCodeSet;
    }

    public Set<String> getFields(){
        return new Set<String>{'Country_Code_2_Char__c', 'Country_Code_3_Char__c', 'QIP_Country__c', 'Region__c', 'SFDC_Country__c'};
    }
}