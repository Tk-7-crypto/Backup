/**
* Created by Ronak Mehta on 05-Apr-2025
* Description : This Apex class is selector layer for Billing Schedule Item Object.
*/
public class SLT_BillingScheduleItem extends fflib_SObjectSelector{
    
    /************constructor************/
    public SLT_BillingScheduleItem(){
        super(true, true, true);
    }
    
    /************param constructor************/
    public SLT_BillingScheduleItem(Boolean enforceCRUD,Boolean enforceFLS) {
        super(true, enforceCRUD, enforceFLS);
    }
    
    /************Method used to get field list of sobject************/
    public List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField> { Billing_Schedule_Item__c.Id, Billing_Schedule_Item__c.Billing_Amount__c};
    }
    
    /************Method used to set up type of sobject************/
    public Schema.SObjectType getSObjectType(){
        return Billing_Schedule_Item__c.sObjectType;
    }
    
    /**
     * This Method Used to get BillingScheduleItem by OLI Id
     * @params Set<Id> OLIIdSet
     * @params Set<String> fieldSet
     * @return List<Billing_Schedule_Item__c>
     **/
    public List<Billing_Schedule_Item__c> getBillingScheduleItemOliId(Set<Id> OLIIdSet, Set<String> fieldSet){
        return (List<Billing_Schedule_Item__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Billing_Schedule__r.OLIId__c in :OLIIdSet').setOrdering('Billing_Date__c', fflib_QueryFactory.SortOrder.ASCENDING, false).toSOQL());
    }

}