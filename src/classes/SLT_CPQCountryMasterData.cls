public class SLT_CPQCountryMasterData extends fflib_SObjectSelector {
    public String orderByField = 'Name';
    
    public SLT_CPQCountryMasterData() {
        super(false, true, true);
    }
    
    public SLT_CPQCountryMasterData(Boolean enforceFLS) {
        super(false, true, enforceFLS);
    }
    
    public SLT_CPQCountryMasterData(Boolean enforceCRUD,Boolean enforceFLS) {
        super(true, enforceCRUD, enforceFLS);
    }
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>();
    }
    
    public Schema.SObjectType getSObjectType() {
        return CPQ_Country_Master_Data__c.sObjectType;
    }
    
    public override String getOrderBy() {
        return orderByField;
    }
    public List<CPQ_Country_Master_Data__c> getCountryMasterDataByNames(Set<String> countryNamesSet, Set<String> fieldSet) {
        String query = 'SELECT ' + String.join(new List<String>(fieldSet), ', ') +
            ' FROM CPQ_Country_Master_Data__c ' +
            ' WHERE Country__c IN :countryNamesSet';
        return new List<CPQ_Country_Master_Data__c>((List<CPQ_Country_Master_Data__c>) Database.query(query));
    }
    
}