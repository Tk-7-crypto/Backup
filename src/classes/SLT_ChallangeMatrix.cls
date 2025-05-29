public with sharing class SLT_ChallangeMatrix extends fflib_SObjectSelector {
    public SLT_ChallangeMatrix() {
		    super(false, false, false);
	  }
    
	/**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Challenge_Matrix__c.Id,
            Challenge_Matrix__c.Name,
            Challenge_Matrix__c.Fees__c,
            Challenge_Matrix__c.Opportunity_Type__c,
            Challenge_Matrix__c.Review_Type__c
        };
    }    
    	/**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Challenge_Matrix__c.sObjectType;
    }
    
    /**
     * This method used to get Challenge Matrix by Id
     * @return  List<Challenge_Matrix__c>
     */
    public List<Challenge_Matrix__c> selectById(Set<ID> idSet) {
        return (List<Challenge_Matrix__c>) selectSObjectsById(idSet);
    }
    
    /**
     * This method used to get Challange Matrix by Fee, Opportunity Type and Reviw Type
     * @return  List<Challenge_Matrix__c>
     */
    public List<Challenge_Matrix__c> selectChallangeMatrixCondition(String laborFee, String opportunityType, String reviewSignOff, String isThisIQB) {
        String query = 'SELECT Id, Fees__c, Opportunity_Type__c, Review_Type__c, Action__c FROM Challenge_Matrix__c WHERE Fees__c=\'' +laborFee + '\' AND Opportunity_Type__c=\'' +opportunityType+ '\' AND Review_Type__c=\'' +reviewSignOff + '\' AND Is_this_IQB__c =\'' +isThisIQB +'\'';
		return Database.query(query);
    }
    
    /**
     * This method used to get Challange Matrix by Fee, Opportunity Type and Reviw Type
     * @return  List<Challenge_Matrix__c>
     */
    public List<Challenge_Matrix__c> selectChallangeMatrixConditionChallenge(String laborFee, String opportunityType, String reviewSignOff, String isThisIQB, String winProbabilityRange, String deliveryPotentialRegion) {
        String query = 'SELECT Id, Fees__c, Opportunity_Type__c, Review_Type__c, Action__c FROM Challenge_Matrix__c WHERE Fees__c=\'' +laborFee + '\' AND Opportunity_Type__c=\'' +opportunityType+ '\' AND Review_Type__c=\'' +reviewSignOff + '\' AND Is_this_IQB__c =\'' +isThisIQB + '\' AND Win_Probability__c=\'' + winProbabilityRange +'\' AND Delivery_Region__c=\'' + deliveryPotentialRegion  + '\'';
		return Database.query(query);
    }
}