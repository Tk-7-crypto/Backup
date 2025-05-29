public class SRV_CLM_Opportunity {
    /**
     * This method used to get details of Opportunity
     * @params  Set<Id> oppIdset
     * @params  Set<string> oppFieldSet
     * @return  Map<Id, Opportunity>
     */
    public static Map<Id, Opportunity> getOppDetail(Set<Id> oppIdset, Set<string> oppFieldSet) {
        Map<Id, Opportunity> idToOpportunityMap = new Map<Id, Opportunity>();
        try {
            idToOpportunityMap = new SLT_Opportunity().getOpportunityById(oppIdSet, oppFieldSet);
        } catch (exception ex) {
            Set<String> errorMsgList = new Set<String>();   
            if(ex.getTypeName() == 'System.DmlException') {
                for(Integer i = 0; i < ex.getNumDml(); i++) {
                   errorMsgList.add(ex.getDmlMessage(i));
                }
            }
            else {
            	errorMsgList.add(ex.getMessage() + ' ' + ex.getStackTraceString());
            }
            throw new SRV_CLM_Opportunity_Exception(new List<String>(errorMsgList));
        }
        return idToOpportunityMap;
    }

    public class SRV_CLM_Opportunity_Exception extends Exception {
        List<String> errorList = new List<String>();
        
        /**
        * constructor of SRV_CLM_Opportunity_Exception
        */
        public SRV_CLM_Opportunity_Exception (List<String> errorList) {
            this.errorList = errorList;
        }
    }
}