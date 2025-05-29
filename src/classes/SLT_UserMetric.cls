/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for User Metric
 */
public class SLT_UserMetric extends fflib_SObjectSelector {
    
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_UserMetric() {
        super(false, true, true);
    }
    
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
                User_Metric__c.Id
                };
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return User_Metric__c.sObjectType;
    }
    
    /**
     * This method used to get User Metric record by User Ids
     * @return List<User_Metric__c>
     */
    public List<User_Metric__c> selectByUserId(Set<Id> userIdSet) {
        return (List<User_Metric__c>)Database.query(newQueryFactory(true).setCondition('User__c IN :userIdSet').toSOQL());
    }
}