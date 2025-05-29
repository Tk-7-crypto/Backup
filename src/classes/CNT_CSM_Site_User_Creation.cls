public without sharing class CNT_CSM_Site_User_Creation {
    public static Contact newContact;
    public String ContactType;
    public static ContactInfo contactInfomation;
    
    @AuraEnabled
    public static String createCommunityUser(ContactInfo newContactInfo, String caseId) {
        try{
            UTL_ExecutionControl.stopTriggerExecution = true;
            user newUser = new User();
            newContact = new Contact();
            newContact.firstName = newContactInfo.firstName;
            newContact.lastName = newContactInfo.lastName;
            newContact.Phone = newContactInfo.phoneNumber;
            newContact.MobilePhone = newContactInfo.mobileNumber;
            newContact.Id = newContactInfo.contactId;
            newUser.ContactId = newContactInfo.contactId;
            newUser.FirstName = newContact.FirstName;
            newUser.LastName =  newContact.LastName;
            List<Profile> profileList = new SLT_profile().selectProfileByName(
                New Set<String>{'CSM Customer Community Plus Login User'}, new Set<String>{'Id'});
            if(profileList != null && !profileList.isEmpty()){
                newUser.ProfileId = profileList[0].Id;
            }
            newUser.userName = newContactInfo.Email;
            newUser.Email = newContactInfo.Email;
            if(newContact.FirstName.length() > 8){
                newUser.Alias = newContact.FirstName.substring(0,8);
            }
            else{
                newUser.Alias = newContact.FirstName;
            }
            newUser.CommunityNickname = newContact.Id;
            newUser.LocaleSidKey = CON_CSM.S_EN_US;
            newUser.EmailEncodingKey = CON_CSM.S_UTF_8;
            newUser.LanguageLocaleKey = CON_CSM.S_EN_US;
            newUser.Generate_New_Password__c = true;
            if(String.isBlank(newContactInfo.contactPortalType) &&  newContactInfo.caseType == CON_CSM.S_TECHNOLOGY_R_T) {
                newContact.Portal_Case_Type__c = con_csm.S_TECHNOLOGY_SOLUTIONS;
            } else if(String.isBlank(newContactInfo.contactPortalType)){
                newContact.Portal_Case_Type__c = CON_CSM.S_INFORMATION_OFFERING;
            }
            update newContact;
            return createSiteUser(newUser,newContactInfo.accountId, caseId);
            
        }Catch(Exception e){
            throw new AuraHandledException(e.getMessage());    
        }
    }
    
    public static String createSiteUser(User newUser, Id accountId, String caseId) {
        UTL_ExecutionControl.stopTriggerExecution = true;
        newUser.Id = Site.createPortalUser(newUser, accountId, null,true);
        if(newUser.Id != null){
            Site.forgotPassword(newUser.userName);
            Case newCase = new Case(Id = caseId);
            newCase.Contact_Already_In_Self_Registration__c = true;
            update newCase;
            return newUser.Id;
        }
        return null;
    }
    @AuraEnabled
    public static ContactInfo selectContactInfo(String contactId, String portalType) {
        try{
            List<Contact> lisOfContact = [SELECT Id, firstName, LastName, Phone, MobilePhone, Email, 
                                          Account.Name,Portal_Case_Type__c,AccountId 
                                          FROM Contact 
                                          WHERE Id =: contactId];
            if(lisOfContact!= null ){
                List<User> listOfUser = [SELECT Id FROM User WHERE ContactId =: contactId OR email =: lisOfContact[0].Email];
                if(listOfUser != null && !listOfUser.isEmpty()) {
                    contactInfomation = new ContactInfo(lisOfContact[0].Id, lisOfContact[0].FirstName, lisOfContact[0].LastName, lisOfContact[0].Phone, 
                                                        lisOfContact[0].MobilePhone, lisOfContact[0].Email, 
                                                        lisOfContact[0].Account.Name, portalType, lisOfContact[0].Portal_Case_Type__c,
                                                        lisOfContact[0].AccountId);
                    contactInfomation.UserAlreadyExist = true;
                } else {
                    contactInfomation = new ContactInfo(lisOfContact[0].Id, lisOfContact[0].FirstName, lisOfContact[0].LastName, lisOfContact[0].Phone, 
                                                        lisOfContact[0].MobilePhone, lisOfContact[0].Email, 
                                                        lisOfContact[0].Account.Name, portalType, lisOfContact[0].Portal_Case_Type__c,
                                                        lisOfContact[0].AccountId);
                }
            }
            return contactInfomation;
        }Catch(Exception e){
            throw new AuraHandledException(e.getMessage());    
        }
    }
    
    @AuraEnabled
    public static ContactInfo updateContactInfo(ContactInfo newContactInfo) {
        try{
            UTL_ExecutionControl.stopTriggerExecution = true;
            newContact = new COntact();
            if(String.isBlank(newContactInfo.contactPortalType) &&  newContactInfo.caseType == CON_CSM.S_TECHNOLOGY_R_T) {
                newContact.Portal_Case_Type__c = con_csm.S_TECHNOLOGY_SOLUTIONS;
            } else if(String.isBlank(newContactInfo.contactPortalType)){
                newContact.Portal_Case_Type__c = CON_CSM.S_INFORMATION_OFFERING;
            }
            newContact.firstName = newContactInfo.firstName;
            newContact.lastName = newContactInfo.lastName;
            newContact.Phone = newContactInfo.phoneNumber;
            newContact.MobilePhone = newContactInfo.mobileNumber;
            newContact.Id = newContactInfo.contactId;
            update newContact;
            return newContactInfo;
        } Catch(Exception e){
            throw new AuraHandledException(e.getMessage());    
        }
    }
    
    @AuraEnabled
    public static String getCSMSetting(){
        return CSM_User_Self_Registration__c.getInstance().Community_Link__c;
    }
    
    @AuraEnabled 
    public static void sendResetPassword(String userId){
            String method = CON_CSM.S_GET;
            String endpoint = CON_CSM.S_ENDPOINT+userId;
            HttpRequest request = new HttpRequest();
            request.setEndpoint(CON_CSM.S_ENDPOINT_SELF_REGISTRATION+endpoint);
            request.setMethod(method);
            (new Http()).send(request);
    }
    
    public class ContactInfo {
        @AuraEnabled public String contactId{get; set;}
        @AuraEnabled public String firstName{get; set;}
        @AuraEnabled public String lastName{get; set;}
        @AuraEnabled public String email{get; set;}
        @AuraEnabled public String phoneNumber{get; set;}
        @AuraEnabled public String mobileNumber{get; set;}
        @AuraEnabled public String accountName{get; set;}
        @AuraEnabled public String caseType{get; set;}
        @AuraEnabled public String contactPortalType{get; set;}
        @AuraEnabled public String accountId{get; set;}
        @AuraEnabled public Boolean UserAlreadyExist{get; set;}
        
        public ContactInfo(String contactId, String firstName, String lastName, 
                           String phoneNumber, String mobileNumber, String email, String accountName, 
                           String caseType, String contactPortalType, String accountId) {
                               this.contactId = contactId;
                               this.firstName = firstName;
                               this.lastName = lastName;
                               this.email = email;
                               this.phoneNumber = phoneNumber;
                               this.mobileNumber = mobileNumber;
                               this.accountName = accountName;
                               this.caseType = caseType;
                               this.contactPortalType = contactPortalType;
                               this.accountId = accountId;
                               this.UserAlreadyExist = false;
                           }
        
        public ContactInfo(){
            
        }
    }
}
