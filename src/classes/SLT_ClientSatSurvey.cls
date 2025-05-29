/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Client Sat Survey
 */
public class SLT_ClientSatSurvey {
    
    /**
     * This method is used to get Client Sat Survey by Opportunity and created Date
     * @params Set<Id> oppIdset
     * @params Date createdDate
     * @return  List<Client_Sat_Survey__c>
     */
    public List<Client_Sat_Survey__c> getClientSurveyByOpportunityAndCreatedDate(Set<Id> oppIdSet, Date createdDate) {
        return [SELECT Opportunity__c, Id 
                FROM Client_Sat_Survey__c 
                WHERE Opportunity__c IN : oppIdSet
                AND CreatedDate >: createdDate
               ];
    }
    
    /**
     * This method is used to get Client Sat Survey by Id
     * @params Set<Id> csIdSet
     * @return  List<Client_Sat_Survey__c>
     */
    public List<Client_Sat_Survey__c> getClientSurveyById(Set<Id> csIdSet) {
        return [SELECT Id, Survey_Send_Date__c, Opportunity__c, Opportunity__r.Is_Survey_eligible_for_RDS_Auto__c, Opportunity__r.Is_Survey_eligible_for_RDS_Manual__c, Opportunity__r.Is_Survey_Eligible_for_Non_RDS__c,Opportunity__r.Principle_inCharge__r.pse__Salesforce_User__r.Business_Unit__c,
                Opportunity__r.Principle_inCharge__r.pse__Salesforce_User__r.PeopleSoft_Product_Offering_Type__c,
                Opportunity__r.Main_Delivery_Country__c,
                Opportunity__r.Principle_inCharge__r.pse__Salesforce_User__r.User_Country__c,
                Opportunity__r.ZREP_Product_Count__c,
                Opportunity__r.Contract_End_Date__c,
                Opportunity__r.Expected_Project_End_Date__c,
                Opportunity__r.Line_of_Business__c
                FROM Client_Sat_Survey__c 
                WHERE Id IN : csIdSet
               ];
    }

    /**
     * This method is used to get Client Sat Survey by Id and Survey_Initiation_Status__c
     * @params  Set<Id> csIdSet
     * @params  String status
     * @return  List<Client_Sat_Survey__c>
     */
    public List<Client_Sat_Survey__c> getClientSurveyByIdAndStatus(Set<Id> csIdSet, List<String> status){
        return [Select id, Name, Don_t_Send_Survey_Reason__c, Survey_Initiation_Status__c, Send_Survey__c, Declined_SurveyApprover_1__r.Email, 
                Declined_SurveyApprover_2__r.Email, Declined_SurveyApprover_3__r.Email,Decline_Survey_Approver_Email__c, Need_Escalation__c, Survey_Send_Date__c,
                Opportunity__r.Next_Survey_Send_Date__c, Opportunity__r.Upcoming_Survey_Send_Date__c, Opportunity__r.Is_Survey_Eligible_for_Non_RDS__c,
                Opportunity__r.Is_Survey_Eligible_for_RDS_Auto__c, Opportunity__r.Is_Survey_Eligible_for_RDS_Manual__c, Opportunity__r.ZREP_Product_Count__c
                ,Opportunity__r.Contract_End_Date__c, Opportunity__r.Expected_Project_End_Date__c, Opportunity__r.Line_of_Business__c 
                from Client_Sat_Survey__c where Id IN : csIdSet and Survey_Initiation_Status__c IN :status];
        
    }
}