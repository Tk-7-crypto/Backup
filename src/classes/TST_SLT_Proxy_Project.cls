/*
 * Version       : 1.0
 * Description   : Test Class for SLT_Proxy_Project
 */
@isTest
public class TST_SLT_Proxy_Project {
    /**
     * This method used to set up testdata
     */ 
    @testSetup
    static void dataSetup() {
        Account account = UTL_TestData.createAccount();
        insert account;
        
        Opportunity opp = UTL_TestData.createOpportunity(account.id);
        insert opp;
    }
    
    /**
     * This method used to test sobject field list
     */    
    @IsTest
    static void testGetSObjectFieldList() {
        Test.startTest();
            SLT_Proxy_Project sltProxyProject = new SLT_Proxy_Project();
            sltProxyProject.getSObjectFieldList();
        Test.stopTest();
    }
    
    /**
     * This method used to test SObjectType
     */    
    @IsTest
    static void testGetSObjectType() {
        Test.startTest();
            SLT_Proxy_Project sltProxyProject = new SLT_Proxy_Project();
            sltProxyProject.getSObjectType();
        Test.stopTest();
    }
    
    /**
     * This method used to get Proxy Project by Opp id
     */    
    @IsTest
    static void testSelectByOppId() {
        List<Proxy_Project__c> proxyProjects = new  List<Proxy_Project__c>();
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];  
        Test.startTest();
            proxyProjects = new SLT_Proxy_Project().selectByFilter(new Set<Id> {opp.Id}, new Set<String> {'Id','Name'});
        Test.stopTest();
        Integer expected = 0;
        Integer actual = proxyProjects.size();
        System.assertEquals(expected, actual);
    }
	
    /**
     * This method used to get Proxy Project by Opp id
     */    
    @IsTest
    static void testSelectByOpportunityId() {
        List<Proxy_Project__c> proxyProjects = new  List<Proxy_Project__c>();
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];  
        Test.startTest();
            proxyProjects = new SLT_Proxy_Project().selectByOpportunityId(new Set<Id> {opp.Id}, new Set<String> {'Id','Name'});
        Test.stopTest();
        Integer expected = 0;
        Integer actual = proxyProjects.size();
        System.assertEquals(expected, actual);
    }
    
    /**
    * This method used to get Proxy Project by Opp id and record type name
    */    
    @IsTest
    static void testGetProjectsByOpportunityIdAndRecordType() {
        List<Proxy_Project__c> proxyProjects = new  List<Proxy_Project__c>();
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];  
        Test.startTest();
        proxyProjects = new SLT_Proxy_Project().getProjectsByOpportunityIdAndRecordType(new Set<String>{opp.Id}, CON_Qualtrics.RECORD_TYPE_ENGAGEMENT);
        Test.stopTest();
        Integer expected = 0;
        Integer actual = proxyProjects.size();
        System.assertEquals(expected, actual);
    }
    
    @IsTest
    static void testgetPlannedProjectByOppId() {
        List<Proxy_Project__c> proxyProjects = new  List<Proxy_Project__c>();
        Map<Id, Proxy_Project__c> mapOfPP = new Map<Id, Proxy_Project__c>();
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];  
        Test.startTest();
            proxyProjects = new SLT_Proxy_Project().getPlannedProjectByOppId(new Set<Id> {opp.Id}, new Set<String> {'Id','Name'});
        	mapOfPP = new SLT_Proxy_Project().getProxyProjectByOppIDAndRecordTypeName(new Set<Id> {opp.Id}, 'Project', new Set<String> {'Id','Name'});
        Test.stopTest();
        Integer expected = 0;
        System.assertEquals(expected, proxyProjects.size());
        System.assertEquals(expected, mapOfPP.size());
    }
}