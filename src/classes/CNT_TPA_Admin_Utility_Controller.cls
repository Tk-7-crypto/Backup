public with sharing class CNT_TPA_Admin_Utility_Controller { 
    public String strClientAccounts {get;set;}
    public static List<TPA_Country_Codes__c> lstCountryCode;
    public String strCountryCodes {get;set;} 
    
    public CNT_TPA_Admin_Utility_Controller() {
        //system.debug('lstClientAccounts size = ' + conAddCrosswalk.size());
        Map<Id, String> mapUsersWithUniqueAccount = new Map<Id, String>();
        for(Contact_Address_Crosswalk__c objUser: [Select Id, Contact__r.Name, Contact__r.FirstName, Contact__r.LastName, Address__c, Address__r.Name, Contact__c, Address__r.TPA_Address_Country__c  from Contact_Address_Crosswalk__c where Contact__c in (Select ContactId from User) order by Address__r.Name ASC]) {
            if(mapUsersWithUniqueAccount.get(objUser.Address__c) == null) {
                system.debug('objUser size = ' + objUser);
                mapUsersWithUniqueAccount.put(objUser.Address__c, createDummyUser(objUser));
            }
        }
        system.debug(mapUsersWithUniqueAccount.size());
        
        lstCountryCode = TPA_Country_Codes__c.getall().values();
        system.debug('lstCountryCode size: ' + lstCountryCode.size());
        strCountryCodes = JSON.serialize(lstCountryCode);
        strCountryCodes = String.escapeSingleQuotes(strCountryCodes);
        strClientAccounts = String.Join(mapUsersWithUniqueAccount.values(), ',');
        strClientAccounts = '[' + strClientAccounts + ']';
    }
    
    @remoteAction
    public static List<Contact> getClientContacts(String addId) {
        addId = (String)JSON.deserialize(addId, String.class);
        Set<Id> conIdSet = new Set<Id>();
        for(Contact_Address_Crosswalk__c c: [Select Contact__c from Contact_Address_Crosswalk__c where Address__c = :addId]) {
            conIdSet.add(c.Contact__c);
        }
        Set<String> fieldSet = new Set<String>{'Id', 'Name', 'AccountId'};
        List<Contact> lstClientContacts = new SLT_Contact().selectByContactIdList(conIdSet, fieldSet); 
        system.debug('lstClientContacts size = ' + lstClientContacts.size());
        return lstClientContacts;
    }
    
    @remoteAction
    public static List<TPA_Request__c> getTPARequests(String contactId) {
        contactId = (String)JSON.deserialize(contactId, String.class);
        Set<Id> contactIdsSet = new Set<Id>{contactId};
        List<TPA_Request__c> lstTPARequests = new SLT_TPARequest().selectByContactId(contactIdsSet, new Set<String>());
        system.debug('lstTPARequests size = ' + lstTPARequests.size());
        return lstTPARequests;
    }
    
    @remoteAction
    public static boolean isUserPresent(String contactId) {
        contactId = (String)JSON.deserialize(contactId, String.class);
        List<User> lstUser = new SLT_User().selectByContactId(new Set<id>{contactId}, new Set<String>());
        system.debug('lstUser size = ' + lstUser.size());
        if(lstUser == null || lstUser.size() == 0) {
            return false;
        }  
        return true;
    }

    @remoteAction
    public static void moveTPARequests(String contId, String accountId, String lstToBeMoved) {
        Set<Id> stTPAId = new Set<Id>();
        contId = (String)JSON.deserialize(contId, String.class);
        accountId = (String)JSON.deserialize(accountId, String.class);

        TPA_Settings__c objTPASetting = TPA_Settings__c.getInstance();
        TPA_Settings__c toggleTPASetting = [select Id, TPA_Send_Emails__c from TPA_Settings__c where Id =: objTPASetting.SystemAdminId__c];
        toggleTPASetting.TPA_Send_Emails__c = false;
        toggleTPASetting.Modify_Agreement_Request__c = true;
        update toggleTPASetting;

        List<User> lstUser = new SLT_User().selectByContactId(new Set<id>{contId}, new Set<String>());
        system.debug('lstUser1 size = ' + lstUser.size());
        User objUser;
        if(lstUser != null || lstUser.size() > 0) {
            objUser = lstUser[0];
        }
         
        List<TPA_request__c> lstTPARequest = (List<TPA_request__c>)JSON.deserialize(lstToBeMoved,List<TPA_request__c>.class);
        
        Set<String> fieldSet = new Set<String>{'Id', 'Name', 'AccountId'};
        List<Contact> lstContact = new SLT_Contact().selectByContactIdList(new Set<Id>{contId}, fieldSet); 
        system.debug('lstContact size = ' + lstContact.size());
        String contactName = '';
        if(lstContact.size() > 0) {
            contactName = lstContact[0].name;
        }

        for(Integer counter = 0; counter < lstTPARequest.size(); counter++) {
          stTPAId.add(lstTPARequest.get(counter).Id);
        }
        system.debug('Batch params : stTPAId = ' + stTPAId);
        BCH_TPA_MoveTPARequests agrmntsUpdate= new BCH_TPA_MoveTPARequests(stTPAId, accountId, contId, objUser.Id, contactName);//Modified by Govind under CR-9411
        Database.executebatch(agrmntsUpdate, 1); 
    }

    public String createDummyUser(Contact_Address_Crosswalk__c addressCrosswalk){
        String addressName = addressCrosswalk.Address__r.Name;
        String contactLastName = addressCrosswalk.Contact__r.LastName;
        String contactFirstName = addressCrosswalk.Contact__r.FirstName;
        String contactName = addressCrosswalk.Contact__r.Name;
        if(addressName.length() > 0){
            addressName = addressName.replace('\'', '\\\'');
            addressName = addressName.replace('\"', '\\\\"');
        }
        if(contactLastName.length() > 0){
            contactLastName = contactLastName.replace('\'', '\\\'');
        }
        if(contactFirstName != null && contactFirstName.length() > 0){
            contactFirstName = contactFirstName.replace('\'', '\\\'');
        }
        if(contactName.length() > 0){
            contactName = contactName.replace('\'', '\\\'');
        }
        String s = '{"AccountId": "' + addressCrosswalk.Address__c + '", "ContactId": "'+ addressCrosswalk.Contact__c + '", "FirstName": "' + contactFirstName + '", "LastName": "' + contactLastName + '", "Contact": { "AccountId": "' + addressCrosswalk.Address__c + '", "Id": "' + addressCrosswalk.Contact__c + '", "Account": { "BillingCountry": "' + addressCrosswalk.Address__r.TPA_Address_Country__c + '", "Name": "' + addressName + '", "Id": "' + addressCrosswalk.Address__c + '"}}}';
        return s;
    }
}