/*
 * Version       : 1.0
 * Description   : Test Class for SLT_ProductConfiguration
 */
@IsTest
public class TST_SLT_ProductConfiguration {
    /**
     * This method used to set up testdata
     */ 
    @TestSetup
    static void dataSetup() {
        Account account = UTL_OCE_TestData.createaccount();
        insert account;
        Opportunity opportunity = UTL_OCE_TestData.createOpportunity(account.Id);
        insert opportunity;
        
        Quote__c quote = UTL_TestData.createIqviaQuote(account.Id, opportunity.Id, null, CON_CPQ.Q2_Solutions, CON_CPQ.GBU_RDS, true);

        Apttus_Proposal__Proposal__c proposal = UTL_TestData.setTSProposalData(false, CON_CPQ.TECH_SOLUTION, opportunity.Id, CON_CPQ.OCE);
        proposal.Apttus_Proposal__Account__c = account.Id;
        proposal.IQVIA_Quote__c = quote.Id;
        insert proposal;

        Apttus_Config2__ProductConfiguration__c prodConfig;
        prodConfig = UTL_TestData.createProductConfiguration(proposal.Id, CON_CPQ.SALE_TYPE_NEW);
        insert prodConfig;
        prodConfig = UTL_TestData.createProductConfiguration(proposal.Id, CON_CPQ.FINALIZED);
        insert prodConfig;
    }
    
    @IsTest
    static void testSelectById() {
    	List<Apttus_Config2__ProductConfiguration__c> prodConfigIdList;
        Test.startTest();
        prodConfigIdList = new SLT_ProductConfiguration().selectById(getConfigsIdSet());
        Test.stopTest();

        System.assertEquals(2, prodConfigIdList.size());
    }

    @IsTest
    static void testSelectFieldSetById() {
        List<Apttus_Config2__ProductConfiguration__c> prodConfigNameList;
        Test.startTest();
        prodConfigNameList = new SLT_ProductConfiguration()
            .selectFieldSetById(getConfigsIdSet(), new Set<String>{CON_CPQ.NAME});
        Test.stopTest();

        System.assertEquals(2, prodConfigNameList.size());
        System.assertEquals(CON_OCE.TEST_PRODUCT_CONFIG_NAME, prodConfigNameList.get(0).Name);
    }

    private static Set<Id> getConfigsIdSet() {
        List<Apttus_Config2__ProductConfiguration__c> configList = [
                SELECT Id
                FROM Apttus_Config2__ProductConfiguration__c
                WHERE Name = :CON_OCE.TEST_PRODUCT_CONFIG_NAME
        ];
        return new Map<Id, Apttus_Config2__ProductConfiguration__c>(configList).keySet();
    }
    
    @IsTest
    static void testGetProductConfigByProposalIdAndStatus() {
        Opportunity testOpportunity = [SELECT Id FROM Opportunity LIMIT 1];

        Apttus_Proposal__Proposal__c quote = [SELECT Id FROM Apttus_Proposal__Proposal__c LIMIT 1];
        
        Apttus_Config2__ProductConfiguration__c prodConfig = [SELECT Id FROM Apttus_Config2__ProductConfiguration__c WHERE Apttus_Config2__Status__c =: CON_CPQ.SALE_TYPE_NEW];
        List<Apttus_Config2__ProductConfiguration__c> prodConfigNameList;
        Test.startTest();
            prodConfigNameList = new SLT_ProductConfiguration().getProductConfigByProposalIdAndStatus(new Set<Id> {quote.Id}, CON_CPQ.SALE_TYPE_NEW, new Set<String> {CON_CPQ.ID, CON_CPQ.NAME});
        Test.stopTest();

        System.assertEquals(1, prodConfigNameList.size());
    }

    @IsTest
    static void testGetProductConfigByQuoteId() {
        Quote__c quote = [SELECT Id FROM Quote__c LIMIT 1];
        Test.startTest();
            String condition = 'Apttus_QPConfig__Proposald__r.IQVIA_Quote__c IN :quoteIds';
            List<Apttus_Config2__ProductConfiguration__c> prodConfigNameList = new SLT_ProductConfiguration().getProductConfigByQuoteId(new Set<Id>{quote.Id}, new Set<String>{CON_CPQ.ID}, condition);
        Test.stopTest();
        System.assertEquals(2, prodConfigNameList.size());
    }
    
    @IsTest
    static void testSelectFinalizedProposalConfig() {
        
        Account account = [SELECT Id FROM Account Limit 1];
        
        Opportunity opportunity = [SELECT Id FROM Opportunity LIMIT 1];
        
        RecordType recordType  = [SELECT Id FROM RecordType WHERE DeveloperName = :CON_CPQ.TECH_SOLUTION 
                                  AND SobjectType = 'Apttus_Proposal__Proposal__c' LIMIT 1];
        
        Apttus_Proposal__Proposal__c proposal = [SELECT Id FROM Apttus_Proposal__Proposal__c LIMIT 1];
        
        Apttus_Config2__ProductConfiguration__c configuration = UTL_TestData.createProductConfiguration(proposal.Id, CON_CPQ.FINALIZED);
        configuration.Name = 'Proposal Configuration';
        insert configuration;
        
        Map<Id, Apttus_Config2__ProductConfiguration__c> prodConfigMap;
        Test.startTest();
        prodConfigMap = new SLT_ProductConfiguration()
            .selectProposalConfigsWithLineItemsForRecordType(new Set<Id>{configuration.Id}, 
                                                             new Set<Id>{recordType.Id},
                                                             new Set<String>{CON_CPQ.ID, CON_CPQ.NAME},
                                                             new Set<String>{CON_CPQ.ID});
        Test.stopTest();

        System.assertEquals(1, prodConfigMap.size());
        System.assertEquals('Proposal Configuration', prodConfigMap.values()[0].Name);
    }
    
    @IsTest
    static void testGetProductConfigByCondition() {
        Apttus_Proposal__Proposal__c quote = [SELECT Id FROM Apttus_Proposal__Proposal__c LIMIT 1];
        Apttus_Config2__ProductConfiguration__c prodConfig = [SELECT Id FROM Apttus_Config2__ProductConfiguration__c WHERE Apttus_Config2__Status__c =: CON_CPQ.SALE_TYPE_NEW];
        String condition = 'Id = ' + '\'' + prodConfig.Id + '\'';
        List<Apttus_Config2__ProductConfiguration__c> prodConfigNameList;
        Test.startTest();
            prodConfigNameList = new SLT_ProductConfiguration().getProductConfigByCondition(new Set<Id> {prodConfig.Id}, condition, new Set<String> {CON_CPQ.ID, CON_CPQ.NAME});
        Test.stopTest();
        System.assertEquals(1, prodConfigNameList.size());
    }
}