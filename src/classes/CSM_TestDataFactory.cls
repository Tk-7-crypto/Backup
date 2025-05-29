public class CSM_TestDataFactory {
    
    public static Account createAccount(){
        Id mdmValidAccount = Schema.SObjectType.account.getRecordTypeInfosByName().get('MDM Validated Account').getRecordTypeId();
        Account accountObj = new Account();
        accountObj.RecordTypeId = mdmValidAccount;
        accountObj.Name = 'Techno Portal';
        accountObj.RDSponsor__c = false;
        accountObj.RDCategorization__c = 'Site';
        accountObj.CustomerSegment__c = 'GOVERNMENT';
        accountObj.Sub_Industry__c = 'STATE';
        return accountObj;
    }
    
    public static Account createAccount(String categorization){
        Id mdmValidAccount = Schema.SObjectType.account.getRecordTypeInfosByName().get('MDM Validated Account').getRecordTypeId();
        Account accountObj = new Account();
        accountObj.RecordTypeId = mdmValidAccount;
        accountObj.Name = 'Techno Portal';
        accountObj.RDSponsor__c = true;
        accountObj.RDCategorization__c = categorization;
        accountObj.CustomerSegment__c = 'GOVERNMENT';
        accountObj.Sub_Industry__c = 'STATE';
        return accountObj;
    }
    
    public static Contact createContact(Id accountId, String firstName,String lastName,String email){
        Contact contactObj = new Contact();
        contactObj.AccountId = accountId;
        contactObj.FirstName = firstName;
        contactObj.LastName = lastName;
        contactObj.Email = email;
        contactObj.Portal_Case_Type__c = 'Technology Solutions';
        return contactObj;
    }
    
    public static Case createCase(Id accountId, Id contactId, Id recordTypeId, Id assetId, String origin, Id parentId, String subject, String description, Id queueUserId){
        User u = [Select id from User where Id = :UserInfo.getUserId() and ProfileId = :UserInfo.getProfileId()];
        Case caseRecord = new Case();
        
        system.runAs(u) {
            caseRecord.AccountId = accountId;
            caseRecord.RecordTypeId = recordTypeId;
            caseRecord.ContactId = contactId;
            caseRecord.Origin = origin;
            caseRecord.AssetId = assetId;
            caseRecord.ParentId = parentId;
            caseRecord.Subject = subject;
            caseRecord.Description = description;
            caseRecord.CurrentQueue__c = queueUserId;
            caseRecord.OwnerId = u.Id;
            
        }
        return caseRecord;
    }
    
    public static Case createClosedCase(Id accountId, Id recordTypeId, Id contactId, boolean isContactKnown, String origin, String subject, String description, 
                                        Id ownerId, String status, String resolution, String resolutionCode, Id assetId, boolean caseToUser, Id queueUserRelation){
                                            Case caseRecord = new Case();
                                            caseRecord.AccountId = accountId;
                                            caseRecord.RecordTypeId = recordTypeId;
                                            caseRecord.ContactId = contactId;
                                            caseRecord.Origin = origin;
                                            caseRecord.Subject = subject;
                                            caseRecord.Description = description;
                                            caseRecord.ownerId = ownerId;
                                            caseRecord.Status = status;
                                            caseRecord.Resolution__c = resolution;
                                            caseRecord.NoContactKnown__c = TRUE;
                                            caseRecord.ResolutionCode__c = resolutionCode;
                                            caseRecord.AssetId =  assetId;
                                            caseRecord.AssignCaseToCurrentUser__c = caseToUser;
                                            caseRecord.CurrentQueue__c = queueUserRelation;
                                            return caseRecord;
                                        }
    
    private static Integer recordCount = 1;
    public static Major_Incident__c createMajorIncident(){
        Major_Incident__c majorRecord = new Major_Incident__c();
        majorRecord.Major_Incident_Subject__c = 'Test Subject '+recordCount;
        majorRecord.Major_Incident_Description__c = 'Test Description '+recordCount;
        majorRecord.Major_Incident_Internal_Communication__c = 'Internal Communication '+recordCount;
        majorRecord.Major_Incident_Customer_Communication__c = 'Customer Communication '+recordCount;
        recordCount++;
        return majorRecord;
    }
}