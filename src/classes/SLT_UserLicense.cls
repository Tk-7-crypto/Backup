public class SLT_UserLicense  extends fflib_SObjectSelector  {
	/**
     * constructor to initialise CRUD and FLS
     */
    public SLT_UserLicense() {
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
        return UserLicense.sObjectType;
    }
    /**
     * This method used to get UserLicense
     * @return  List<UserLicense>
     */
    public Map<Id, UserLicense> fetchLicenseUsingName(Set<String> fieldSet,Set<String> licenseName) {
        return new Map<Id, UserLicense>((List<UserLicense>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Name in :licenseName').toSOQL()));
    }
}