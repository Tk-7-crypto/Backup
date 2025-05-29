public class SLT_ProposalQASelfCheckList extends fflib_SObjectSelector{

    /**
    * This method used to get field list of sobject
    */
    public List<Schema.SObjectField> getSObjectFieldList(){

        return new List<Schema.SObjectField> {
            Proposal_QA_Self_Check_List__c.Id,
            Proposal_QA_Self_Check_List__c.Budget__c,
            Proposal_QA_Self_Check_List__c.Type__c,
            Proposal_QA_Self_Check_List__c.Question__c,
            Proposal_QA_Self_Check_List__c.Guidelines__c,
            Proposal_QA_Self_Check_List__c.PD_Self_Review__c,
            Proposal_QA_Self_Check_List__c.PD_s_Comment__c,
            Proposal_QA_Self_Check_List__c.Line_Manager_QC_Comments__c,
            Proposal_QA_Self_Check_List__c.Proposal_QC_Comment__c,
            Proposal_QA_Self_Check_List__c.Type_Of_Process_Step__c
        };
    }

    /**
    * This method used to set up type of sobject
    * @return  Schema.SObjectType
    */
    public Schema.SObjectType getSObjectType(){

        return Proposal_QA_Self_Check_List__c.sObjectType;
    }

    /**
    * This method used to get Proposal_QA_Self_Check_List__c by Id
    * @return  List<Proposal_QA_Self_Check_List__c>
    */
    public List<Proposal_QA_Self_Check_List__c> selectById(Set<Id> idSet){

        return (List<Proposal_QA_Self_Check_List__c>) selectSObjectsById(idSet);
    }

    
    /*
    * This method is use to query Proposal QA Self Check List for budget according to type of process step and type of bids 
    *
    */
    public List<Proposal_QA_Self_Check_List__c> getProposalCheckListForProcessStepAndBidTypeOfBudget(Set<Id> budgetIDsSet, 
        Set<String> fieldSet, String typeOfProcessStep, Decimal instanceId, String pricingTool){

        return (List<Proposal_QA_Self_Check_List__c>) Database.query(
            newQueryFactory(true).selectFields(fieldSet).setCondition('Budget__c =: budgetIDsSet AND ' + 
                'Type_Of_Process_Step__c =: typeOfProcessStep AND '+
                    'Instance_Id__c =: instanceId AND Pricing_Tool__c =: pricingTool').toSOQL());
    }
    
    /*
    * This method is use to query Proposal QA Self Check List for budget according to state
    *
    */
    public List<Proposal_QA_Self_Check_List__c> getProposalCheckListForBudget(Id budgetId,Set<String> fieldSet, String stage, Decimal instanceId){

        return (List<Proposal_QA_Self_Check_List__c>) Database.query(
            newQueryFactory(true).selectFields(fieldSet).setCondition('Budget__c =: budgetId AND ' + 
                'Stage__c =: stage AND ' + 'Instance_Id__c =: instanceId').setOrdering('Order__c', fflib_QueryFactory.SortOrder.ASCENDING, true).toSOQL());
    }
    
    /*
    * This method is use to query Proposal QA Self Check List for budget according to state and applied Filter
    *
    */
    public List<Proposal_QA_Self_Check_List__c> getProposalCheckListForBudgetFiltered(Id budgetId,Set<String> fieldSet, String stage, Decimal instanceId, String filter){

        return (List<Proposal_QA_Self_Check_List__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(
            'Budget__c =: budgetId AND ' + 
            'Stage__c =: stage AND ' + 
            'Instance_Id__c =: instanceId AND ' + 
            'Filter__c =: filter').setOrdering('Order__c', fflib_QueryFactory.SortOrder.ASCENDING, true).toSOQL());
    }
}