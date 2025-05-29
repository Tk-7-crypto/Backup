public class DAOH_AccountContactRelation {
    
    /**
	* This method is used to prevent duplicate record creation of account contact relationship for a particular account 
	* @params newList List<AccountContactRelation>
	* @return void
	*/
    public static void preventDuplicateAccountContactRelationOnAccount(List<AccountContactRelation> newList, Map<Id, AccountContactRelation> oldMap){
        
        Set<Id> accountIDs = new Set<Id>();
        for(AccountContactRelation acr : newList){
            if(trigger.isBefore && ((trigger.isInsert && String.isNotBlank(acr.Function__c) && String.isNotBlank(acr.Geographic_Responsibility__c) && String.isNotBlank(acr.Focus__c)) || (trigger.isUpdate && (oldMap.get(acr.Id).IsActive != acr.IsActive || oldMap.get(acr.Id).Function__c != acr.Function__c || oldMap.get(acr.Id).Focus__c != acr.Focus__c || oldMap.get(acr.Id).Geographic_Responsibility__c != acr.Geographic_Responsibility__c)))){
                accountIDs.add(acr.AccountId);
            }
        }
        
        if(accountIDs.size() > 0){
            Set<String> fieldSet = new Set<String>{'AccountId', 'Function__c', 'Geographic_Responsibility__c', 'Focus__c', 'IsActive'};
            String condition = 'IsActive = true';    
            List<AccountContactRelation> acrList = new SLT_AccountContactRelation().getAccountContactRelationsWithCondition(fieldSet, accountIDs, condition);
            Map<String, AccountContactRelation> existingAccountContactRelations = new Map<String, AccountContactRelation>();
            for(AccountContactRelation acr : acrList){
                String key;
                key = acr.AccountId;
                key += acr.Function__c;
                key += acr.Geographic_Responsibility__c;
                key += acr.Focus__c;
                existingAccountContactRelations.put(key, acr);
            }
            
            for(AccountContactRelation acr : newList){
                String key;
                key = acr.AccountId;
                key += acr.Function__c;
                key += acr.Geographic_Responsibility__c;
                key += acr.Focus__c;
                if(String.isNotBlank(acr.Function__c) && String.isNotBlank(acr.Geographic_Responsibility__c) && String.isNotBlank(acr.Focus__c)){
                    if(existingAccountContactRelations.containsKey(key)){
                        acr.addError('There is already existing team member in Active with EXACT same Function, Focus, and Geographic Responsibility. Please make existing Team member Inactive and add new one.');
                    }
                }
            } 
        }
    }       
}