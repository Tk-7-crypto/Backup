/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Declined Survey Approver Group
 */
public class SLT_DeclinedSurveyApproverGroup extends fflib_SObjectSelector {
    
    /**
    * This method used to set up type of sobject
    * @return Schema.SObjectType
    */
    public Schema.SObjectType getSObjectType(){
        return DeclinedSurveyApproverGroup__c.SObjectType;
    }
    
    /**
    * This method used to get field list of sobject
    * @return List<Schema.SObjectField>
    */
    public List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField>{ 
            DeclinedSurveyApproverGroup__c.Priority__c,
            DeclinedSurveyApproverGroup__c.BusinessUnit__c,
            DeclinedSurveyApproverGroup__c.PeopleSoft_User_Country__c, 
            DeclinedSurveyApproverGroup__c.PeopleSoft_Product_Offering_Segment__c,
            DeclinedSurveyApproverGroup__c.PeopleSoftBusinessUnit__c, 
            DeclinedSurveyApproverGroup__c.PeopleSoftProductCOE__c, 
            DeclinedSurveyApproverGroup__c.MainDeliveryCountry__c,
            DeclinedSurveyApproverGroup__c.PeopleSoftProductOfferingType__c,
            DeclinedSurveyApproverGroup__c.Line_of_Business__c, 
            DeclinedSurveyApproverGroup__c.Declined_SurveyApprover_1__c, 
            DeclinedSurveyApproverGroup__c.Declined_SurveyApprover_2__c, 
            DeclinedSurveyApproverGroup__c.Declined_SurveyApprover_3__c,
            DeclinedSurveyApproverGroup__c.Decline_Survey_Approver_Email__c 
            };
    }
    
    /**
     * This method used to get DeclinedSurveyApproverGroup Ordererd by priority
     * @return List<DeclinedSurveyApproverGroup__c> 
     */
    public List<DeclinedSurveyApproverGroup__c>  getDeclinedSurveyApproverNonRDSOrderByPriority(Set<String> PIC_productOfferingSegment, Set<String> PIC_productOfferingType, Set<String> PIC_ProductCOE, Set<String> PIC_BU, Set<String> PIC_userCntry, Set<String> oppBU, Set<String> oppMainDeliveryCountry){
        String queryCondition = 'Line_of_Business__c = \'' + CON_Qualtrics.ALL +'\' AND PeopleSoft_Product_Offering_Segment__c IN :PIC_productOfferingSegment' +
            ' AND PeopleSoftProductOfferingType__c IN :PIC_productOfferingType AND PeopleSoftProductCOE__c IN: PIC_ProductCOE '+ 
            ' AND PeopleSoftBusinessUnit__c IN :PIC_BU AND PeopleSoft_User_Country__c IN :PIC_userCntry AND BusinessUnit__c IN :oppBU AND MainDeliveryCountry__c IN: oppMainDeliveryCountry';
        String queryString = newQueryFactory().setCondition(queryCondition).toSOQL();
        return (List<DeclinedSurveyApproverGroup__c>)Database.query(queryString);
    }
    
    /**
     * This method used to get DeclinedSurveyApproverGroup Ordererd by priority
     * @return List<DeclinedSurveyApproverGroup__c> 
     */
    public List<DeclinedSurveyApproverGroup__c>  getDeclinedSurveyApproverRDSOrderByPriority(Set<String> oppBU, Set<String> oppLOB){
        String queryCondition = 'Line_of_Business__c != \''+ CON_Qualtrics.ALL +
                '\' AND BusinessUnit__c IN :oppBU AND Line_of_Business__c IN :oppLOB AND Is_This_Iqvia_Biotech__c = False';
        String queryString = newQueryFactory().setCondition(queryCondition).toSOQL();
        return (List<DeclinedSurveyApproverGroup__c>)Database.query(queryString);
    }
    
    public List<DeclinedSurveyApproverGroup__c>  getDeclinedSurveyApproverRDSOrderByPriorityYes(Set<String> oppBU, Set<String> oppLOB){
        String queryCondition = 'Line_of_Business__c != \''+ CON_Qualtrics.ALL +
                '\' AND BusinessUnit__c IN :oppBU AND Line_of_Business__c IN :oppLOB AND Is_This_Iqvia_Biotech__c = True';
        String queryString = newQueryFactory().setCondition(queryCondition).toSOQL();
        return (List<DeclinedSurveyApproverGroup__c>)Database.query(queryString);
    }
    
    public List<DeclinedSurveyApproverGroup__c>  getDeclinedSurveyApprovernonRDSWithLOBset(Set<String> oppBU, Set<String> oppLOB){
        String queryCondition = 'Line_of_Business__c != \''+ CON_Qualtrics.ALL +
                '\' AND BusinessUnit__c IN :oppBU AND Line_of_Business__c IN :oppLOB';
        String queryString = newQueryFactory().setCondition(queryCondition).toSOQL();
        return (List<DeclinedSurveyApproverGroup__c>)Database.query(queryString);
    }
    
    /**
     * Method to override OrderBy
     */
    public override String getOrderBy(){
        return 'Priority__c';
    }
}