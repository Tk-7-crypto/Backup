/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Report Drug 
 */
public class SLT_Report_Drug extends fflib_SObjectSelector{
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_Report_Drug() {
        super(false, true, true);
    }
    
    /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_Report_Drug(Boolean enforceFLS) {
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
        return Report_Drug__c.sObjectType;
    }
    
    /**
     * This method used to get Report Drug 
     * @return  List<Report_Drug__c>
     */
    public List<Report_Drug__c> getReportDrugList(Set<ID> idSet,Set<String> fieldSet,String fieldFilter) {
        return ((List<Report_Drug__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(fieldFilter + ' in :idSet').toSOQL()));
    }

}