public class SLT_CSMQIFieldTrackingC extends fflib_SObjectSelector {
    
    /**
     * constructor to initialise CRUD and FLS
     */
    public SLT_CSMQIFieldTrackingC() {
        super(false, false, false);
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
        return CSM_QI_Field_Tracking__c.sObjectType;
    }
    
    /**
     * This method used to get Casse by Id
     * @return  List<CSM_QI_Field_Tracking__c>
     */
    public List<CSM_QI_Field_Tracking__c> selectByObjectName(Set<string> name, Set<String> fieldSet) {
        return new List<CSM_QI_Field_Tracking__c>((List<CSM_QI_Field_Tracking__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Name in :name').toSOQL()));
    }
}