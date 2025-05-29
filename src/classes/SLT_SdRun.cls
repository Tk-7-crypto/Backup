/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Sd Run
 */
public class SLT_SdRun extends fflib_SObjectSelector {
    
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_SdRun() {
        super(false, true, true);
    }
    
    /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_SdRun(Boolean enforceFLS) {
        super(false, true, enforceFLS);
    }
    public SLT_SdRun(Boolean enforceFLS,Boolean enforceCRUD) {
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
        return SD_Runs__c.sObjectType;
    }
    
    public override String getOrderBy(){
      return 'createdDate DESC';
   }

    /**
     * This method used to get Project by Id
     * @return  Map<Id, SD_Runs__c>
     */
    public Map<Id, SD_Runs__c> getSdRunMapBySdRunIds(Set<ID> idSet, Set<String> fieldSet) {
        return new Map<Id, SD_Runs__c>((List<SD_Runs__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet and Project__r.Service_Line__r.name = ' + '\'' + 'Signal Management' + '\'').toSOQL()));
    }
    /**
     * This method used to get Project by Id
     * @return  list<SD_Runs__c>
     */
    public list<SD_Runs__c> getSdRunById(Set<ID> idSet, Set<String> fieldSet) {
        return (List<SD_Runs__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet and Project__r.Service_Line__r.name = ' + '\'' + 'Signal Management' + '\'').toSOQL());
    }
    
    public list<SD_Runs__c> getLastCreatedSdRunRecord(Set<String> fieldSet) {
        return (List<SD_Runs__c>) Database.query(newQueryFactory().selectFields(fieldSet).setLimit(1).toSOQL());
    }
    
     /*
     * finds project metrics for specific fields and conditions
     * fieldSet - specific fields to query
     * conditions - specific condition to apply
     */
    public SD_Runs__c[] findBy (Set<String> fieldSet, String conditions) {
        return findByIds(fieldSet, conditions, null);
    }    

    /*
     * finds project metrics for specific fields and conditions
     * fieldSet - specific fields to query
     * conditions - specific condition to apply
     */
    public SD_Runs__c[] findByIds (Set<String> fieldSet, String conditions, Set<Id> idSet) {
        system.debug('FindBy id' + fieldSet +  conditions);
        fflib_QueryFactory soqlBuilder = newQueryFactory(true);
        soqlBuilder.selectFields(fieldSet);
        soqlBuilder.setCondition(conditions);
        return ((SD_Runs__c[]) Database.query(soqlBuilder.toSOQL()));
    }    
} 
