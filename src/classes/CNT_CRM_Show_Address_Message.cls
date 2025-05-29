/*
 * Author: Balkrishan Gohil
 * Description: Apex Controller for lwc_crm_vaidated_account_address lightning component.
 */
public class CNT_CRM_Show_Address_Message {
    /*
    * This method is used to check if any Validated Address is Exist on the Account
    * @param Id accountId
    * @return Boolean Value
    */
    @AuraEnabled(cacheable=true)
    public static Boolean getValidatedAddress(Id accountId) {
        Integer Size;
        Id recordTypeId = CON_CRM.Validated_Address_RecordId;
        List<AggregateResult> GroupResult = [SELECT Count(Id)cnt FROM Address__c WHERE Account__c =:accountId AND RecordType.Id = :recordTypeId];
        Size = Integer.valueOf(GroupResult[0].get('cnt'));
        
        if(Size > 0){
            return false;
        }
        else{
            return true;
        }
    }
    
    /*
    * This method is used to check if on any EMEA Opportunity the Related Primary IQVIA Quote is on Accepted Stage AND OLI Synced with QLI
    * @param Id opportunityId
    * @return String Value
    */

    @AuraEnabled(cacheable=true)
    public static string getOpportunityDetails(Id opportunityId) {
        String ErrorMsg ;
        Map<Id,String> oppIdToErrorMsgMap = new Map<Id,String>();
        oppIdToErrorMsgMap = CPQ_QuoteUtilityWO.validateQuoteSyncWithOpportunities(new Set<Id>{opportunityId});
        String result =  oppIdToErrorMsgMap.get(opportunityId);
        if(result != 'Error:NonEMEAEligibleOpportunity' && (result == 'Error:PrimaryQuoteNotAcceptedAndSyncMissMatched' || result == 'Error:SyncMissMatched')){
            ErrorMsg = 'Please make sure an IQVIA Quote record is in sync with Opportunity record';
        }
        return ErrorMsg;
    }
}