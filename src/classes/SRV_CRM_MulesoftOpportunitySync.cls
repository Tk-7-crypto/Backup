/*
 * Version       : 1.0
 * Description   : Service Class for MuleSoft Opportunity Sync
 */
global class SRV_CRM_MulesoftOpportunitySync {
    
    /**
     * service method used to getMulesoft Opportunity Sync Records By Opp Ids
     * @params  Set<Id> oppIdSet
     * @return  List<Mulesoft_Opportunity_Sync__c>
     */
    public static List<Mulesoft_Opportunity_Sync__c> getMulesoftOpportunitySyncByOppIds(Set<Id> oppIdSet) {
        List<Mulesoft_Opportunity_Sync__c> mulesoftOpportunitySyncList = null;
        try {
            mulesoftOpportunitySyncList = new SLT_MulesoftOpportunitySync().selectByOppIds(oppIdSet);
        } catch(Exception ex) {
            String errMsg = ex.getMessage();
            throw new MulesoftOpportunitySyncException(new List<String>{errMsg});
        }  
        return mulesoftOpportunitySyncList;
    }
    
    // Exception Class for Mulesoft Opportunity Sync
    public Class MulesoftOpportunitySyncException extends Exception {
        List<String> errorList;
        
        /**
         * constructor
         * @params  List<String> errorList
         */ 
        public MulesoftOpportunitySyncException(List<String> errorList) {
            this.errorList = errorList;
        }
    }
}