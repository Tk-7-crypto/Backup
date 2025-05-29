/**
 * Author : Ronak Mehta
 * Created Date : 08-11-2024
 * This is Site_Submission__c Domain handler class.
 **/
public class DAOH_Site_Submission {
    
    /**
     * This method is used to populate Fields on Site Submission.
     * @params  List<Site_Submission__c> newList
     * @params  Map<Id, Site_Submission__c> oldMap
     * @return  void
     **/
    public static void setDefaultvalue(List<Site_Submission__c> newList, Map<Id, Site_Submission__c> oldMap) {
        Set<Id> accIdSet = new Set<Id>();
        Set<String> accFieldSet = new Set<String>{'Id', 'Name'};
            Set<Id> oppIdSet = new Set<Id>();
        Set<String> oppFieldSet = new Set<String>{'Id', 'Name', 'Opportunity_Number__c'};
        
        for(Site_Submission__c ss: newList){
            accIdSet.add(ss.Site__c);
            oppIdSet.add(ss.Opportunity__c);
        }
        
        Map<Id, Account> accountMap = new SLT_Account().selectByAccountId(accIdSet, accFieldSet);
        Map<Id, Opportunity> opportunityMap = new SLT_Opportunity().getOpportunityById(oppIdSet, oppFieldSet);
        
        for(Site_Submission__c ss: newList){
            if(Trigger.isInsert){
                String oppNumber = opportunityMap.ContainsKey(ss.Opportunity__c) ? opportunityMap.get(ss.Opportunity__c).Opportunity_Number__c : '';
                String SiteName = accountMap.ContainsKey(ss.Site__c) ? accountMap.get(ss.Site__c).Name : '';
                SiteName = (SiteName.length() > 70) ? SiteName.substring(0, 70) : SiteName; 
                ss.Name = SiteName + ' ' + oppNumber;
            }
        }
    }
    
	/**
     * This method is used to populate Risk Adjusted Opportunity Estimate on Site Submission.
     * @params  List<Site_Submission__c> newList
     * @return  void
     **/
    public static void setRiskAdjustedOpportunityEstimate(List<Site_Submission__c> newList ) {
        double feasibilityEnrollmentGoal ;
        double siteAwardProbability ;
        decimal ppcEstimate ;
        
        for(Site_Submission__c ss : newList){
            feasibilityEnrollmentGoal = 0 ;
            siteAwardProbability = 0 ;
            ppcEstimate = 0;
            if(ss.Feasibility_Enrollment_Goal__c != null){
                feasibilityEnrollmentGoal = ss.Feasibility_Enrollment_Goal__c ;
            }
            if(ss.Site_Award_Probability__c != null ){
                siteAwardProbability =  ss.Site_Award_Probability__c/100 ;
            }
            if(ss.PPC_Estimate__c != null){
                ppcEstimate = ss.PPC_Estimate__c ;
            }
            ss.Risk_Adjusted_Opportunity_Estimate__c = siteAwardProbability * ( feasibilityEnrollmentGoal * ppcEstimate ) ;
        }
   
    }
}