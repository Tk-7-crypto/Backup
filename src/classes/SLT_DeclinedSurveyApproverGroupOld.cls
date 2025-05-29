/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Declined Survey Approver Group
 */
public class SLT_DeclinedSurveyApproverGroupOld {
    public SLT_DeclinedSurveyApproverGroupOld(){
        String demoString = '';
    }
    /**
     * This method used to get DeclinedSurveyApproverGroup Ordererd by priority
     * @return List<DeclinedSurveyApproverGroup__c> 
     */
    /*commenting method for reference
    public List<DeclinedSurveyApproverGroup__c> getDeclinedSurveyApproverGroupOrderByPriority() {
        return [SELECT BusinessUnit__c, DeclinedSurveyApproverGroup__c, PeopleSoft_User_Country__c, 
                MainDeliveryCountry__c, PeopleSoftProductOfferingType__c, Priority__c
                FROM DeclinedSurveyApproverGroup__c 
                ORDER BY Priority__c
               ];
    }
	*/
}