/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Field_History_Tracking_Field__mdt
 */
public class SLT_FieldHistoryTrackingFields  extends fflib_SObjectSelector {
    
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_FieldHistoryTrackingFields() {
        super(false, true, true);
    }
    
    /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_FieldHistoryTrackingFields(Boolean enforceFLS) {
        super(false, true, enforceFLS);
    }
    
    public SLT_FieldHistoryTrackingFields(Boolean enforceFLS,Boolean enforceCRUD) {
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
    public Schema.SObjectType getSObjectType(){
        return Field_History_Tracking_Field__mdt.sObjectType;
    }
    /**
     * This method used to get Field_History_Tracking_Field__mdt 
     * @return  List<Field_History_Tracking_Field__mdt>
     */
    public List<Field_History_Tracking_Field__mdt> TrackingFields(Set<String> fieldSet, String condition,String ftobjectid) {
        fflib_QueryFactory quoteQueryFactory = newQueryFactory(true);
        String queryString = quoteQueryFactory.selectFields(fieldSet).setCondition(condition).toSOQL();
        return (List<Field_History_Tracking_Field__mdt>)Database.query(queryString);
    }
    /**
     * This method used to get recordName
     * @return recordName
     */    
    Public string getRecordIdName(Id recordId){
        if(recordId != null){
            String objectName = String.valueof(recordId.getsobjecttype());
            Sobject rec =  Database.query('SELECT Id, Name FROM '+ objectName + ' WHERE Id = \''+ recordId +'\'');
            return (String) rec.get('Name');
        }
        return null;
    }
    
}