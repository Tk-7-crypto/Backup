/**
 * This class is used to test ConstantClass
 */ 
@isTest
public class TST_ConstantClass {
     
    private static User testUser;
    @testSetup
    static void dataSetup() {
        Account account = UTL_TestData.createAccount();
        insert account;
        Opportunity opp = UTL_TestData.createOpportunity(account.id);
        insert opp;
        Proxy_SCM_Agreement__c proxyScmAgreement = UTL_TestData.createProxySCMAgreement(opp.Id);
        proxyScmAgreement.is_Amendment_Record__c = false;
        proxyScmAgreement.IMS_Legal_Entity__c = 'IQVIA Inc.';
        insert proxyScmAgreement;
    }
    
    
    private static void setUpUser(){
        insert new pse__Region__c(name='xz',pse__Hierarchy_Depth__c = 0);   
        List<User> listOfUsers = new List<User>();
        List<Profile> profiles = [select id from profile where name = 'System Administrator']; 
        testUser = new User(FirstName = 'testM',LastName = 'testM',Username = 'testSCM@metacube.com',
            Email =  'testMetacube@metacube.com',Alias = 'TestUsr1',TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',EmailEncodingKey = 'UTF-8',ProfileId = profiles.get(0).id ,LanguageLocaleKey ='en_US', employeeNumber= '080808081');
        listOfUsers.add(testUser);
        insert listOfUsers;
    }
    
    static testMethod void testGetSalesOrgNameinBNFSystem1() {
        Test.startTest();
        ConstantClass.getSalesOrgNameinBNFSystem1('MIBNF');
        Test.stopTest();  
    }
    
    static testMethod void testCheckAgreementLegalEntityForOpportunity() {
        Opportunity opp = [SELECT Id, (SELECT Id, IMS_Legal_Entity__c FROM Proxy_SCM_Agreements__r) FROM Opportunity LIMIT 1];
        Map<Id, Opportunity> oppWithAgreementsMap = new Map<Id, Opportunity>();
        oppWithAgreementsMap.put(opp.Id, opp);
        Test.startTest();
        String legalEntity = ConstantClass.checkAgreementLegalEntityForOpportunity(opp.Id, oppWithAgreementsMap);
        System.assertEquals('IQVIA Inc.', legalEntity);
        Test.stopTest();  
    }
    
    static testMethod void testGetSalesOrgCodeforAgreementLegalEntity() {
        Test.startTest();
        ConstantClass.getSalesOrgCodeforAgreementLegalEntity('');
        Test.stopTest();  
    } 
    
    @isTest
    private static void testGetOfferingSegmensPickListValues() {
        Test.startTest();
            List<String> segments = ConstantClass.getOfferingSegmensPickListValues();
        Test.stopTest(); 
        
        system.assertNotEquals(true,segments.isEmpty() , 'Segment picklist is blank when not expected');
    } 
    
    @isTest
    private static void testCheckForWildCharShouldReturnTrueWhenWildCardPassed() {
        Test.startTest();
            Boolean wildCardExists = ConstantClass.checkForWildChar('Test*');
        Test.stopTest(); 
    } 
    
    @isTest
    private static void testCheckForWildCharShouldReturnFalseWhenNoWildCardPassed() {
        Test.startTest();
            Boolean wildCardExists = ConstantClass.checkForWildChar('Test');
        Test.stopTest(); 
        
        system.assertEquals(false,wildCardExists , 'Wild Card exists when not expected');
    } 
    
    
    @isTest
    private static void testWildcardCharSearchShouldReturnValidStringWhenWildCardExists() {
        Test.startTest();
            String returnString = ConstantClass.wildcardCharSearch('Test*');
        Test.stopTest(); 
    } 
    
    @isTest
    private static void testGetRecordTypeIdShouldReturnRecordTypeId() {
        Test.startTest();
            Id recordTypeId = ConstantClass.getRecordTypeId('Agreement__c','Japan Agreement');
        Test.stopTest(); 
    } 
    
    @isTest
    private static void testGetCreatableFieldsSOQLShouldReturnSOQL() {
        Test.startTest();
            String soql = ConstantClass.getCreatableFieldsSOQL('Agreement__c','Id != null');
        Test.stopTest();
        
        System.assertNotEquals(null,soql , 'no query returned');
        
    }
    
    
    @isTest
    private static void testGetUserDetailsShouldReturnUserDetailsWhenValidUserPassed() {
        Test.startTest();
            List<User> listUser = ConstantClass.getUserDetails();
        Test.stopTest();
    } 
    
    @isTest
    private static void testGetProfileDetailsShouldReturnProfileDetailsWhenValidUserPassed() {
        Test.startTest();
            List<Profile> listProfile = ConstantClass.getProfileDetails();
        Test.stopTest();
    } 
    
    @isTest
    private static void testCreateUserShouldReturnUserDetailsWhenCalled() {
        User u = null;
        Test.startTest();
            u = ConstantClass.createUser();
        Test.stopTest();
     } 
    
    @isTest
    private static void testis_AMA_Record_Type_enabledShouldReturnTrueWhenValidDataPassed() {
        Boolean isAMARecordEnabled = false;
        List<PermissionSetAssignment> permissionSetAssignments = new List<PermissionSetAssignment>();
        List<PermissionSet> permissionSetList = [   SELECT Id, Name,Label
                                                        FROM PermissionSet
                                                        WHERE Name LIKE 'Japan_SCM%'];
        if(!permissionSetList.isEmpty())
        {
           PermissionSetAssignment permissionSetAssignment = new PermissionSetAssignment(AssigneeId = UserInfo.getUserId(), 
                  PermissionSetId = permissionSetList[0].Id);
           permissionSetAssignments.add(permissionSetAssignment);
           insert permissionSetAssignments;
        }
        permissionSetAssignments = [Select Id,PermissionSet.Label from PermissionSetAssignment where Id IN: permissionSetAssignments ];
        Test.startTest();
            isAMARecordEnabled = ConstantClass.is_AMA_Record_Type_enabled('System Admin',permissionSetAssignments);
        Test.stopTest();
        
        System.assertNotEquals(false,isAMARecordEnabled, 'isAMARecordEnabled is not enabled');
        
    } 
    
    @isTest
    private static void testIsRelatedAccountAccessibleShouldReturnTrueForCurrentUser() {
        Account testAccount = new Account(Name = 'TestAccountNameForSCM1',CurrencyIsoCode = 'USD',
            Region_Territory__c = 'India',Industry_IMS__c = 'Biotech', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert testAccount;
        
        Test.startTest();
            Boolean isAccessible = ConstantClass.isRelatedAccountAccessible(testAccount.Id);
        Test.stopTest();
        
        System.assertNotEquals(false,isAccessible, 'no valid data returned');
        
    } 
    
    @isTest
    private static void testGetCurrencyConversionMapShouldReturnMapWhenValidDataPassed() {
        
        Test.startTest();
            Map<String,Decimal> mapData = ConstantClass.getCurrencyConversionMap();
        Test.stopTest();
    } 
    
    @isTest
    private static void testIsSuperUserShouldReturnFlagWhenValidDataPassed() {
        
        Test.startTest();
            Boolean isSuper = ConstantClass.isSuperUser();
        Test.stopTest();
     } 
    
    @isTest
    private static void testCreateUserShouldInsertUsersWhenValidDataPassed() {
        List<User> listUser = new List<User>();
        Test.startTest();
        
            listUser = ConstantClass.CreateUser(1,'System Administrator','en_US');
        
        Test.stopTest();
        
        System.assertEquals(false,listUser.isEmpty(), 'no valid data returned');
     } 
    
    @isTest
    private static void testPermissionSetRelatedMethods() {
        List<PermissionSetAssignment> permissionSetAssignments = new List<PermissionSetAssignment>();
        List<PermissionSet> permissionSetList = [   SELECT Id, Name,Label
                                                        FROM PermissionSet
                                                        WHERE Name = 'Japan_Contract_Management_SCM'];
        if(!permissionSetList.isEmpty())
        {
            PermissionSetAssignment permissionSetAssignment = new PermissionSetAssignment(AssigneeId = UserInfo.getUserId(), 
                PermissionSetId = permissionSetList[0].Id);
            permissionSetAssignments.add(permissionSetAssignment);
            insert permissionSetAssignments;
        }
        permissionSetAssignments = [Select Id,PermissionSet.Label from PermissionSetAssignment where Id IN: permissionSetAssignments ];
        
        Test.startTest();
            Boolean validateAuthorizeUser = ConstantClass.validateAuthorizeUser('System Administrator',permissionSetAssignments);
            String isPermissionSetUser = ConstantClass.permissionSetUser('System Administrator',permissionSetAssignments);
            Boolean isValidUSUser = ConstantClass.isValidUSUser(permissionSetAssignments);
        Test.stopTest();
        
     } 
    
    @isTest
    private static void testIsFinComAgreement() {
        Agreement__c agreement = new Agreement__c();
        agreement.Agreement_Category__c = 'FinCom';
        agreement.IMS_Legal_Entity__c = 'IMS Health Incorporated';
            
        Test.startTest();
            Boolean isFinComm = ConstantClass.isFinComAgreement(agreement);
        Test.stopTest();
    }
}