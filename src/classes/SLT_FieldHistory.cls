/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Field_History__c
 */
public class SLT_FieldHistory  extends fflib_SObjectSelector {
    
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     **/
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>();
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     **/
    public Schema.SObjectType getSObjectType(){
        return Field_History__c.sObjectType;
    }
    
    /**
     * This method used to get Field_History__c 
     * @return  List<Field_History__c>
     **/
    public List<Field_History__c> getFieldHistory(Set<String> fieldSet, Id recordId) {
        String condition = 'Tracked_Record_Id__c =:recordId';
        fflib_QueryFactory quoteQueryFactory = newQueryFactory(true);
        String queryString = quoteQueryFactory.selectFields(fieldSet).setCondition(condition).setOrdering('Action_Date_Time__c', fflib_QueryFactory.SortOrder.DESCENDING, true).toSOQL();
        return (List<Field_History__c>)Database.query(queryString);
    }
}