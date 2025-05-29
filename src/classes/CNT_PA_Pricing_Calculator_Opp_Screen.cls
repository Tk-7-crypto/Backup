/***********************************************
   Name      :     CNT_PA_Pricing_Calculator_Opp_Screen 
   Date      :     8-April-2019
   Usage     :     Validate Opportunity for Pricing assistant before redirecting to LI org 
   Author    :     Jyoti Vijayvargiya
***********************************************/

public class CNT_PA_Pricing_Calculator_Opp_Screen {
    @auraEnabled
    public static Map<String, String> getPricingErrors(String opportunityId){
        try {
            Map<String,String> result = new Map<String,String>();
            List<String> errorMessages = new List<String>();
            Boolean isQuoteExist = false;
            Opportunity objOpportunity = [Select Business_Unit__c, Main_Delivery_Country__c, 
                                          Exclude_from_Pricing_Assistant__c, StageName, CloseDate, 
                                          Opportunity_Number__c, Name, Id,LI_Opportunity_Id__c,
                                          Amount, Account.Name, AccountId,
                                          CurrencyIsoCode, Contract_Start_Date__c,Contract_End_Date__c,
                                          (Select id, Pricing_Calculator_Status_c__c  
                                           from Pricing_Assistants__r) 
                                          From Opportunity 
                                          where Id = :opportunityId];
            if(objOpportunity != null ) {            
                if(objOpportunity.Exclude_from_Pricing_Assistant__c) {
                    if(objOpportunity.Pricing_Assistants__r.size() == 0) {
                        errorMessages.add('Can not create Pricing Assistant as this opportunity is excluded from Pricing Assistant');
                    }
                } else {
                    String currentOppStage = objOpportunity.StageName.substring(0,1);
                    if(objOpportunity.Pricing_Assistants__r.size() == 0 && (currentOppStage == '5' || 
                                                                            currentOppStage == '6' || 
                                                                            objOpportunity.StageName == 'In Hand')) {
                                                                                errorMessages.add('Opportunities with Non excluded MC or CES Products must have a Pricing Assistant prior to being in Stage 5. Please update your Opportunity to include a Pricing Assistant.  If you are in Stage 4 you will not be allowed to move to Stage 5 until you have an Approved Pricing Assistant. If you attempt to modify the Opportunity after the Pricing Assistant has been approved, you will need to move the Opportunity into Stage 4 and then un-approve the Pricing Assistant to make adjustments to the Opportunity.');    
                                                                            }
                }
                
                if(objOpportunity.LI_Opportunity_Id__c == null || objOpportunity.LI_Opportunity_Id__c == '') {
                    errorMessages.add('Opportunity Does not exist on Lagacy IMS Side.');
                }
                isQuoteExist = CPQ_QuoteUtilityWO.isQuoteExist(opportunityId);
            }
            result.put('isQuoteExist', String.valueOf(isQuoteExist).toLowerCase()); 
            result.put('errorMessages',JSON.serialize(errorMessages));
            result.put('legacyOrgOppId', objOpportunity.LI_Opportunity_Id__c);
            result.put('legacyOrgLink', Legacy_Org_Link__c.getInstance().Legacy_IMS_URL__c);
            return result;
        } catch(Exception e) {
            system.debug('Error ::'+ e.getStackTraceString());
            system.debug('Error ::'+ e.getMessage());
            return null;
        }
    }
    @auraEnabled
    public static Map<String,String> cancelActiveQuotes(String opportunityId){
        Map<String,String> result = new Map<String,String>();
        String statusRes = '';
        try {
          statusRes = CPQ_QuoteUtilityWO.cancelActiveQuotes(opportunityId);
          statusRes = statusRes?.toLowerCase();
          if(statusRes == 'success'){
              Opportunity objOpportunity = [Select Id,LI_Opportunity_Id__c
                                            From Opportunity where Id = :opportunityId];
              if(objOpportunity != null ) {
                result.put('legacyOrgOppId', objOpportunity.LI_Opportunity_Id__c);
                result.put('legacyOrgLink', Legacy_Org_Link__c.getInstance().Legacy_IMS_URL__c);
              }
              else{
                statusRes = 'Error: Opportunity does not exist.';
              } 
          }
        } catch(Exception e) {
            statusRes = 'Error: ' + e.getMessage();
            system.debug('Error ::'+ e.getStackTraceString());
        }
        result.put('status', statusRes);
        return result;
    }
}