public class SLT_PSA_Event extends fflib_SObjectSelector{

    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_PSA_Event () {
        super(false, false, false);
    }
    
    /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_PSA_Event (Boolean enforceFLS) {
        super(false, false, enforceFLS);
    }
    public SLT_PSA_Event(Boolean enforceFLS,Boolean enforceCRUD) {
        super(false, enforceFLS, enforceCRUD);
    }
    
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList () {
        Schema.DescribeSObjectResult describeResult = getSObjectType().getDescribe(); 
        Map<String,Schema.SObjectField> fieldsMap = describeResult.fields.getMap();   
        return fieldsMap.values();
    }

    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType () {
        return PSA_Event__c.sObjectType;
    }

    /**
     * This method gets PSA Events which reference a set of field names
     * @params Set<String> dateFields
     * @return Map<String, PSA_Event__c>
     */
    public Map<String, PSA_Event__c> getPSAEventsByPlannedDateField(Set<String> dateFields){
        fflib_QueryFactory queryFactory = newQueryFactory(false);
        queryFactory.selectFields(getDefaultFields());
        queryFactory.setCondition('Planned_Date_Field__c IN :dateFields');
        String queryString = queryFactory.toSOQL();
        System.debug('DateFields: '+dateFields);
        System.debug(queryString);
        List<PSA_Event__c> eventList = (List<PSA_Event__c>) Database.query(queryString);
        Map<String, PSA_Event__c> eventMap = new Map<String, PSA_Event__c>();
        for(PSA_Event__c event : eventList){
            eventMap.put(event.Planned_Date_Field__c, event);
        }
        return eventMap;
    }

    /**
     * This method gets All PSA Events with optional object type filter
     * @params String objectApiName
     * @return List<PSA_Event__c>
     */
    public List<PSA_Event__c> getAllPSAEvents(){
        return getAllPSAEvents(null);
    }

    public List<PSA_Event__c> getAllPSAEvents(String objectApiName){
        fflib_QueryFactory queryFactory = newQueryFactory(false);
        queryFactory.selectFields(getDefaultFields());
        if(objectApiName != null){
            queryFactory.setCondition('Object__c = :objectApiName');
        }
        String queryString = queryFactory.toSOQL();
        return (List<PSA_Event__c>) Database.query(queryString);
    }

    /**
     * Method to get default fields for use in queries
     * @return Set<String>
     */
    public Set<String> getDefaultFields(){
        return new Set<String>{
            'Id',
            'Actual_Date_Field__c',
            'CreatedById',
            'CurrencyIsoCode',
            'Event_Name__c',
            'LastModifiedById',
            'Notification_Offset__c',
            'Object__c',
            'Other_Email__c',
            'Other_Resource_Field__c',
            'OwnerId',
            'Planned_Date_Field__c',
            'Primary_Resource_Field__c',
            'Name',
            'RecordTypes__c',
            'Secondary_Resource_Field__c',
            'Send_Missed_Due_Date_Notification__c',
            'Stakeholder_Fields__c'
        };
    }

}
