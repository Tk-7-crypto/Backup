public class CNT_CRM_AgreementBox {
	@AuraEnabled(cacheable = true) 
    public static Map<String,Object> fetchAgreement(String recordId){
        Id recId = (Id)recordId;
        Map<String,Object> returnMap = new Map<String,Object>();
        List<Contract> currentContract = new SLT_Contract().selectByContractIdList(new Set<Id>{recId}, new Set<String>{'Id','Opportunity__c'});
        if(currentContract.size() > 0){
            if(currentContract[0].Opportunity__c != null){
                //commented as part of CPQ ageement cleanup LC-6767
                //agrrementList = new SLT_Agreement().selectLatestAgreementFieldsByOpportunityIdAndCondition(new Set<String>{'Id','Name'}, new List<String>{currentContract[0].Opportunity__c},new Set<Id>{CON_CRM.AGREEMENT_RECORD_TYPE_RDS_BUDGET});
            }
        }
        returnMap.put('error','No record found');
        return returnMap;
    }
}