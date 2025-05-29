public class SLT_UserTimezoneKeyMapping extends fflib_SObjectSelector  {
	/**
     * constructor to initialise CRUD and FLS
     */
    public SLT_UserTimezoneKeyMapping() {
        super(false, true, false);
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
        return User_Timezone_Mapping__mdt.sObjectType;
    }
    /**
     * This method used to get CRM_MSA_Contract_Mapping__mdt
     * @return  Map<Id, Contact>
     */
    public List<User_Timezone_Mapping__mdt> fetchTimezoneMapping(Set<String> fieldSet,Set<String> idSet) {
        return ((List<User_Timezone_Mapping__mdt>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('CountryCode__c in :idSet').toSOQL()));
    }
}