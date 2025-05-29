/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Report Country
 */
public class SLT_Report_Country extends fflib_SObjectSelector {
    
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_Report_Country() {
        super(false, true, true);
    }
    
    /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_Report_Country(Boolean enforceFLS) {
        super(false, true, enforceFLS);
    }
    public SLT_Report_Country(Boolean enforceFLS,Boolean enforceCRUD) {
        super(false, enforceCRUD, enforceFLS);
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
        return Report_Country__c.sObjectType;
    }

    /**
     * This method used to get lists of Report Countries by Aggregate Report Id
     * @return  Map<Id, List<Report_Country__c>>
     */
    public Map<Id, List<Report_Country__c>> getReportCountriesByReport(Set<ID> idSet) {
        Set<String> fieldSet = new Set<String>{'Id','Name', 'Aggregate_Report__c', 'Country__c', 'Legacy_ID__c'};
        List<Report_Country__c> countries = (List<Report_Country__c>) Database.query( newQueryFactory(true).selectFields(fieldSet).setCondition('Aggregate_Report__c IN :idSet').toSOQL() );
        Map<Id,List<Report_Country__c>> reportToCountryMap = new Map<Id,List<Report_Country__c>>();
        for(Report_Country__c country : countries){
            if(reportToCountryMap.get(country.Aggregate_Report__c) == null){
                reportToCountryMap.put(country.Aggregate_Report__c, new List<Report_Country__c>());
            }
            reportToCountryMap.get(country.Aggregate_Report__c).add(country);
        }
        return reportToCountryMap;
    }
}