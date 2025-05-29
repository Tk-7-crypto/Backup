public class SLT_QCCheckListItem extends fflib_SObjectSelector{

    /**
    * This method used to get field list of sobject
    */
    public List<Schema.SObjectField> getSObjectFieldList(){

        return new List<Schema.SObjectField> {
            QC_Check_List_Item__c.Id,
            QC_Check_List_Item__c.Type__c,
            QC_Check_List_Item__c.Question__c,
            QC_Check_List_Item__c.Guidelines__c,
            QC_Check_List_Item__c.Type_Of_Process_Step__c,
            QC_Check_List_Item__c.Record_Type__c   
        };
    }

    /**
    * This method used to set up type of sobject
    * @return  Schema.SObjectType
    */
    public Schema.SObjectType getSObjectType(){

        return QC_Check_List_Item__c.sObjectType;
    }

    /**
    * This method used to get QC_Check_List_Item__c by Id
    * @return  List<QC_Check_List_Item__c>
    */
    public List<QC_Check_List_Item__c> selectById(Set<Id> idSet){

        return (List<QC_Check_List_Item__c>) selectSObjectsById(idSet);
    }

    /*
    * This method is use to query QC Check List Item for agreement according to type of process step and type of bids 
    *
    */
    public List<QC_Check_List_Item__c> getQCCheckListItemByProcessStepBidTypeRecordType(String recordType, 
        Set<String> fieldSet, String typeOfProcessStep, String pricingTool){

        return (List<QC_Check_List_Item__c>) Database.query(
            newQueryFactory(true).selectFields(fieldSet).setCondition('Record_Type__c =: recordType AND ' + 
                                                                    'Type_Of_Process_Step__c =: typeOfProcessStep AND ' + 
                                                                     'Pricing_Tool__c =: pricingTool').toSOQL());
    }

    /*
    * This method is use to query QC Check List Item  according to record type 
    *
    */
    public List<QC_Check_List_Item__c> getQCCheckListItemByRecordType(String recordType, Set<String> fieldSet){

        return (List<QC_Check_List_Item__c>) Database.query(
            newQueryFactory(true).selectFields(fieldSet).setCondition('Record_Type__c =: recordType').toSOQL());
    }
    
    /*
    * This method is use to query QC Check List Item according to budget parameters
    *
    */
    public List<QC_Check_List_Item__c> getQCCheckListItemForBudget(Set<String> fieldSet, String opportunityType, String budgetType, String pricingTool, String stage)
    {
        return (List<QC_Check_List_Item__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(
            'Opportunity_Type__c includes (:opportunityType) AND ' + 
            'Budget_Type__c includes (:budgetType)  AND ' + 
            'Pricing_Tool__c includes (:pricingTool) AND '+
            'Stage__c includes (:stage)').setOrdering('Order__c', fflib_QueryFactory.SortOrder.ASCENDING, true).toSOQL());
    }
    
    /*
    * This method is use to query QC Check List Item according to budget parameters with applied filters
    *
    */
    public List<QC_Check_List_Item__c> getQCCheckListItemForBudgetFiltered(Set<String> fieldSet, String opportunityType, String budgetType, String pricingTool, String stage, String filter)
    {
        return (List<QC_Check_List_Item__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(
            'Opportunity_Type__c includes (:opportunityType) AND ' + 
            'Budget_Type__c includes (:budgetType)  AND ' + 
            'Pricing_Tool__c includes (:pricingTool) AND '+
            'Stage__c includes (:stage) AND ' +
            'Filter__c includes (:filter)').setOrdering('Order__c', fflib_QueryFactory.SortOrder.ASCENDING, true).toSOQL());
    }

}