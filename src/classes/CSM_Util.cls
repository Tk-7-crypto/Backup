public class CSM_Util {
    
    /**
* This method used to insert Account
* @return  Account
*/
    public static Account createAccount() {
        return new Account(Name = 'CaseTestAccount',RDSponsor__c=true,RDClinicalSite__c=true,RDCategorization__c = 'Site',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
    }
    
    /**
* This method used to insert Account
* @return  Account
*/
    public static Account createRDAccount() {
        return new Account(Name = 'CaseRDTestAccount',RDSponsor__c=true,
                           RDCategorization__c = 'Sponsor',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
    }
    
    /**
* This method used to insert Contact
* @params  Id accountId
* @return  Contact
*/
    public static Contact createContact(Id accountId,String name) {
        return new Contact(FirstName = name, LastName = name, accountId = accountId);
    }
    
    /**
* This method used to insert Asset
* @params  Id productId,Id accountId,Id contactId,Id studyId
* @return  Asset
*/
    public static Asset createAsset(String pname,Id productId,Id accountId,Id contactId,Id studyId) {
        return new Asset(Name = pname,Status='Registered',Price=100,Quantity=2, Product2Id=productId,AccountId=accountId,ContactId=contactId,Study__c=studyId);
    }
    
    /**
* This method used to insert Product2
* @params  
* @return  Product2
*/
    public static Product2 createProduct2() {
        return new Product2(Name = 'CaseTestProduct', ProductCode='TSTP-0001',Family='None',IsActive=true);
    }
    
    /**
* This method used to insert Study__c
* @params  Id accountId
* @return  Study__c
*/
    public static Study__c createStudy(Id accountId) {
        return new Study__c(Name = 'CaseTestStudy', Sponsor__c = accountId,CRO__c='CRO Test');
    }
    
    /**
* This method used to insert Study_Site_Relationship__c
* @params  Id accountId,Id studyId,Id contactId
* @return  Study_Site_Relationship__c
*/
    public static Study_Site_Relationship__c createStudySiteRelationship(Id accountId,Id studyId,Id contactId) {
        return new Study_Site_Relationship__c(Status__c = 'Active', Site__c = accountId,Study__c=studyId    , KeyContacts__c=contactId);
    }
    
    /**
* This method used to insert Study_Contact_Relationship__c
* @params  Id studyId,Id contactId
* @return  Study_Contact_Relationship__c
*/
    public static Study_Contact_Relationship__c createStudyContactRelationship(Id studyId,Id contactId) {
        return new Study_Contact_Relationship__c(Status__c = 'Active', Study__c=studyId, Contact__c=contactId);
    }
    
    
    /**
* This method used to insert Case
* @params  String recordTypeName,Id accountId,Id contactId
* @return  Case
*/
    /*public static Case createCase(Id recordType,String recordTypeName,Id accountId,Id contactId,Id studyId,Id asetId,Id queueID) {
        Case cs=null;
        if(recordTypeName.equalsIgnoreCase('R&D - Assistance Request Case')){
            //Status,Origin,Account,Study,Subject
            cs= new Case(recordtypeId=recordType,Subject = 'CaseTest',Status='New',Priority='Medium',Origin='Email',CaseSubType1__c='TBD', Study__c=studyId,accountId = accountId,contactId= contactId,assetId=asetId,CurrentQueue__c=queueID,Current_Queue__c = 'Q1',OwnerId = UserInfo.getUserId());    
        }else if(recordTypeName.equalsIgnoreCase('R&D - Activity Plan Case')){
            //Status,Origin,Contact,Type,Sponsor(Account),Study,Subject,Templete
            cs= new Case(recordtypeId=recordType,Subject = 'CaseTest',Status='New',Priority='Medium',Origin='Email',Type='Contact',Template__c='Kit Order',Sponsor__c=accountId,Study__c=studyId, accountId = accountId,contactId= contactId,CurrentQueue__c=queueID,Current_Queue__c = 'Q1',OwnerId = UserInfo.getUserId());    
        }else if(recordTypeName.equalsIgnoreCase('TechnologyCase')){
            //Status,Origin,Account,Contact,Subject,Priority,CaseSubType1__c
            cs= new Case(recordtypeId=recordType,Subject = 'CaseTest',Status='New',Priority='Medium',Origin='Email',CaseSubType1__c='TBD', accountId = accountId,contactId= contactId,CurrentQueue__c=queueID,Current_Queue__c = 'Q1',OwnerId = UserInfo.getUserId());    
        }else if(recordTypeName.equalsIgnoreCase('DATACase')){
            //Status,Origin,--Account,Contact,Subject,CaseSubType1__c
            cs= new Case(recordtypeId=recordType,Subject = 'CaseTest',Status='New',Priority='Medium',Origin='Email',CaseSubType1__c='TBD', accountId = accountId,contactId= contactId,CurrentQueue__c=queueID,Current_Queue__c = 'Q1',OwnerId = UserInfo.getUserId());    
        }
        return cs; 
    }*/
}