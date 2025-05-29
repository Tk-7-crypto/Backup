public with sharing class SLT_ApprovalMatrix extends fflib_SObjectSelector {
    public SLT_ApprovalMatrix() {
		    super(false, false, false);
	  }
    
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Approval_Matrix__c.Id,
            Approval_Matrix__c.Name,
            Approval_Matrix__c.Opportunity_Type__c,
            Approval_Matrix__c.X0_5M_USD__c,
            Approval_Matrix__c.X10_20M_USD__c,
            Approval_Matrix__c.X20_50M_USD__c,
            Approval_Matrix__c.X5_10M_USD__c,
            Approval_Matrix__c.X50M_USD__c
        };
    }    
    	/**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Approval_Matrix__c.sObjectType;
    }
    
    /**
     * This method used to get Approval Matrix by Id
     * @return  List<Approval_Matrix__c>
     */
    public List<Approval_Matrix__c> selectById(Set<ID> idSet) {
        return (List<Approval_Matrix__c>) selectSObjectsById(idSet);
    }
    
    /**
     * This method used to get Approval Matrix by Opportunity Type and Region
     * @return  List<Approval_Matrix__c>
     */
    public List<Approval_Matrix__c> selectApprovalMatrixCondition(String opportunityType, String region) {
        return Database.query('SELECT Id, Name, Approver_Group__c, Opportunity_Type__c, Region__c, Therapy_Area__c, X0_5M_USD__c, X0_5M_USD_Email__c, X5_10M_USD__c, X5_10M_USD_Email__c, X10_20M_USD__c, X10_20M_USD_Email__c, X20_50M_USD__c, X20_50M_USD_Email__c,  X50M_USD__c, X50M_USD_Email__c, Approver_Group__r.Name, Sales__c FROM Approval_Matrix__c WHERE Opportunity_Type__c = \'' + opportunityType + '\' AND Region__c = \'' + region + '\'');
    }
    
    /**
     * This method used to get Approval Matrix by Opportunity Type
     * @return  List<Approval_Matrix__c>
     */
    public List<Approval_Matrix__c> selectApprovalMatrixByOpportunityType(String opportunityType) {
        return Database.query('SELECT Id, Name, Approver_Group__c, Opportunity_Type__c, Region__c, Therapy_Area__c, X0_5M_USD__c, X0_5M_USD_Email__c, X5_10M_USD__c, X5_10M_USD_Email__c, X10_20M_USD__c, X10_20M_USD_Email__c, X20_50M_USD__c, X20_50M_USD_Email__c,  X50M_USD__c, X50M_USD_Email__c, Approver_Group__r.Name, Sales__c FROM Approval_Matrix__c WHERE Opportunity_Type__c = \'' + opportunityType + '\'');
    }
    
    /**
     * This method used to get Approval Matrix for Approval Process
     * @return  List<Approval_Matrix__c>
     */
    public List<Approval_Matrix__c> getApprover(Set<String> fieldSet, String condition) {
        fflib_QueryFactory quoteQueryFactory = newQueryFactory(true);
        String queryString = quoteQueryFactory.selectFields(fieldSet).setCondition(condition).toSOQL();
        return (List<Approval_Matrix__c>)Database.query(queryString);
    }

    public List<Approval_Matrix__c> getDiscountMatrix(Set<String> fieldSet, String condition) {
        fflib_QueryFactory quoteQueryFactory = newQueryFactory(true);
        String queryString = quoteQueryFactory.selectFields(fieldSet).setCondition(condition).toSOQL();
        return (List<Approval_Matrix__c>)Database.query(queryString);
    }

    public List<Approval_Matrix__c> getApprover(Set<String> fieldSet, String condition, Set<String> countryCodes) {
        fflib_QueryFactory quoteQueryFactory = newQueryFactory(true);
        String queryString = quoteQueryFactory.selectFields(fieldSet).setCondition(condition).setOrdering('Priority__c', fflib_QueryFactory.SortOrder.ASCENDING).toSOQL();
        return (List<Approval_Matrix__c>)Database.query(queryString);
    }
    public List<Approval_Matrix__c> getDiscountThresholdMatrix() {
        return [SELECT Id, Min_Amount__c, Max_Amount__c, Min_Discount_Amount__c, Min_Discount_Percent__c FROM Approval_Matrix__c WHERE Process_Type__c = 'Discount Validation' AND Pricing_Tool__c = 'AMESA' ORDER BY Min_Discount_Percent__c];
    }
    public List<Approval_Matrix__c> getApproverByPricingTool(Set<String> fieldSet, String condition, List<String> assignedPricingTools) {
        fflib_QueryFactory quoteQueryFactory = newQueryFactory(true);
        String queryString = quoteQueryFactory.selectFields(fieldSet).setCondition(condition).toSOQL();
        return (List<Approval_Matrix__c>)Database.query(queryString);
    }
}