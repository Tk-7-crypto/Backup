/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for 	pse__HolidayObj__c
 */
public class SLT_Holiday extends fflib_SObjectSelector {
    
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_Holiday() {
        super(false, true, true);
    }
    
    /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_Holiday(Boolean enforceFLS) {
        super(false, true, enforceFLS);
    }
    public SLT_Holiday(Boolean enforceFLS,Boolean enforceCRUD) {
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
     * This method used to get field set of field names for the sobject
     * @return  Set<String>
     */
    public Set<String> getSObjectFieldSet () {
        Set<String> fieldNames = new Set<String>();
        List<Schema.SObjectField> fields = getSObjectFieldLists();
        if (fields != null && fields.size() > 0) {
            for (Schema.SObjectField sobjField : fields) {
                fieldNames.add(String.valueof(sobjField));
            }
        }        
        return fieldNames;
    }  
    
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldLists () {
        Schema.DescribeSObjectResult describeResult = getSObjectType().getDescribe(); 
        Map<String,Schema.SObjectField> fieldsMap = describeResult.fields.getMap();   
        return fieldsMap.values();
    }

    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return pse__HolidayObj__c.sObjectType;
    }
    
    public override String getOrderBy(){
      return 'createdDate DESC';
   }

    /**
     * This method used to get Project by Id
     * @return  Map<Id, pse__HolidayObj__c>
     */
    public Map<Id, pse__HolidayObj__c> getHolidayMapByWorkCalendarId(Set<Id> idSet, Set<String> fieldSet) {
        return new Map<Id, pse__HolidayObj__c>((List<pse__HolidayObj__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('pse__Work_Calendar__c  in :idSet ').toSOQL()));
    }
   
}