/* 
* Version       : 1.0
* Description   : Utility Class for sending additional user infos during sso login
*/
global class UTL_PEP_SendOnPointUserInfo extends Auth.ConnectedAppPlugin
{
    // Authorize the app if the user has achieved quota tracked in a custom field
    global override Boolean authorize(Id userId, Id connectedAppId, Boolean isAdminApproved, Auth.InvocationContext context) {
        return isAdminApproved;
    }
    
    global override Map<String,String> customAttributes(Id userId, Id connectedAppId, Map<String,String> formulaDefinedAttributes, Auth.InvocationContext context){
        User u = [SELECT ContactId, Email, userRole.PortalRole, AccountId, TimeZoneSidKey FROM User WHERE Id = :userId];
        
        formulaDefinedAttributes.put('timeZone', u.TimeZoneSidKey);
        
        String role = CON_PEP.S_PEP_CONSULTANT;
        if(u.userRole.PortalRole == CON_PEP.S_PEP_MANAGER){
            role = CON_PEP.S_PEP_MANAGER ;   
        }
        formulaDefinedAttributes.put('userRole', role);
        
        Contact contact = [SELECT ID, FirstName, LastName, Email, Account.Name, Account.AccountCountry__c, Partner_Type__c from Contact where Id =: u.ContactId];
        formulaDefinedAttributes.put('Firstname', contact.FirstName);
        formulaDefinedAttributes.put('Lastname', contact.LastName);
        formulaDefinedAttributes.put('Email', contact.Email);
        
        if(contact.Partner_Type__c != null){
            formulaDefinedAttributes.put('partnerType', contact.Partner_Type__c.replace(';',','));
        }
        formulaDefinedAttributes.put('country', contact.Account.AccountCountry__c);
        formulaDefinedAttributes.put('organization', contact.Account.Name);
        
        List<TS_LMS_Training_Management__c> tmList = [Select Id, Subscription_Start_Date__c, Subscription_End_Date__c from TS_LMS_Training_Management__c Where Account_Name__r.ID= :u.AccountId];
		Set<Id> tmIds = new Set<Id>();

        for(TS_LMS_Training_Management__c tm : tmList){
            if(tm.Subscription_Start_Date__c <= System.Today() && tm.Subscription_End_Date__c >= System.Today()){
                  tmIds.add(tm.Id);  
            }
        }

        List<TS_LMS_Catalog_Relationship__c> catRelationshipList = [Select ID, Licenses__c, Catalog__r.Name, Catalog__r.OnPoint_Skill_Profile_Id__c FROM TS_LMS_Catalog_Relationship__c WHERE Training_Management__c IN :tmIds];
        List<Map<String, String>> catalogWithLicenseMapList = new List<Map<String, String>>();
        for(TS_LMS_Catalog_Relationship__c catRelationship : catRelationshipList){
            Map<String, String> catalogWithLicenseMap = new Map<String, String>();
            catalogWithLicenseMap.put('catalog', catRelationship.Catalog__r.Name);
            catalogWithLicenseMap.put('onPointId', catRelationship.Catalog__r.OnPoint_Skill_Profile_Id__c);
            catalogWithLicenseMap.put('license', catRelationship.Licenses__c+'');
            catalogWithLicenseMapList.add(catalogWithLicenseMap);
        }
        formulaDefinedAttributes.put('training', JSON.serialize(catalogWithLicenseMapList));
        
        System.debug('formulaDefinedAttributes : '+ formulaDefinedAttributes);
        return formulaDefinedAttributes;                              
    } 
}