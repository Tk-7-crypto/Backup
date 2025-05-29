@isTest
public class TST_CNT_CPQ_AgreementSection {

    @testSetup
    static void dataSetUp() {

        List<Account> accountList = new List<Account>();
        Account testAccount = UTL_TestData.createAccount();
        testAccount.MDM_Category__c = CON_CPQ.ACCOUNT_CATEGORY_GLOBAL_PHARMA;
        accountList.add(testAccount);

        Account testAccount1 = UTL_TestData.createAccount();
        testAccount1.MDM_Validation_Status__c = 'Rejected';
        testAccount1.ParentId = testAccount.Id;
        testAccount1.RecordTypeId = SObjectType.Account.getRecordTypeInfosByName().get(
            'Global Customer Account').getRecordTypeId();
        testAccount1.MDM_Category__c = CON_CPQ.ACCOUNT_CATEGORY_GLOBAL_PHARMA;
        accountList.add(testAccount1);

        insert accountList;

        Opportunity testOpportunity= UTL_TestData.createOpportunity(testAccount.Id);
        testOpportunity.Line_of_Business__c = CON_CPQ.SAMPLE_LINE_OF_BUSINESS;
        testOpportunity.Legacy_Quintiles_Opportunity_Number__c='MVP123';
        testOpportunity.Is_this_IQVIA_Biotech__c = 'No';
        testOpportunity.Potential_Regions__c = CON_CPQ.REGION_ASIA_PASIFIC;
        insert testOpportunity;

        String profileName = [SELECT Id, Name FROM Profile WHERE Name='Sales User' LIMIT 1].Name;
        User usr = UTL_TestData.createUser(profileName, 1)[0];
        usr.Region__c = CON_CPQ.REGION_EMEA;
        insert usr;
        
        Bid_History__c testClinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);

        List<Challenge_Matrix__c> challengeMatrixList = new List<Challenge_Matrix__c>();
        Challenge_Matrix__c testMatrix = UTL_TestData.createChallengeMatrix(CON_CPQ.TOTAL_IQVIA_FEES_CDS_0TO3, CON_CPQ.OPPORTUNITY_TYPE_FSP, CON_CPQ.REVIEW_TYPE_CHALLENGE, CON_CPQ.EMAIL, CON_CPQ.YES, '', '');
        testMatrix.Migration_Id__c = 'CM-011';
        challengeMatrixList.add(testMatrix);
        Challenge_Matrix__c testMatrix1 = UTL_TestData.createChallengeMatrix(CON_CPQ.TOTAL_IQVIA_FEES_CDS_5, CON_CPQ.OPPORTUNITY_TYPE_FSP, CON_CPQ.REVIEW_TYPE_CHALLENGE, CON_CPQ.CALL, CON_CPQ.NO_TITLE_CASE, CON_CPQ.WIN_PROBABILITY_0, CON_CPQ.REGION_EMEA);
        testMatrix1.Migration_Id__c = 'CM-012';
        challengeMatrixList.add(testMatrix1);
        Challenge_Matrix__c testMatrix2 = UTL_TestData.createChallengeMatrix(CON_CPQ.TOTAL_IQVIA_FEES_CDS_10, CON_CPQ.OPPORTUNITY_TYPE_BTS_BALLPARK, CON_CPQ.REVIEW_TYPE_CHALLENGE, CON_CPQ.CALL, CON_CPQ.NO_TITLE_CASE, CON_CPQ.WIN_PROBABILITY_0, CON_CPQ.REGION_EMEA);
        testMatrix2.Migration_Id__c = 'CM-013';
        challengeMatrixList.add(testMatrix2);
        Challenge_Matrix__c testMatrix3 = UTL_TestData.createChallengeMatrix(CON_CPQ.TOTAL_IQVIA_FEES_CDS_3, CON_CPQ.OPPORTUNITY_TYPE_FSP, CON_CPQ.REVIEW_TYPE_CHALLENGE, CON_CPQ.CALL, CON_CPQ.NO_TITLE_CASE, CON_CPQ.WIN_PROBABILITY_50, CON_CPQ.REGION_ASIA_PASIFIC);
        testMatrix3.Migration_Id__c = 'CM-014';
        challengeMatrixList.add(testMatrix3);
        Challenge_Matrix__c testMatrix4 = UTL_TestData.createChallengeMatrix(CON_CPQ.TOTAL_IQVIA_FEES_CDS_7, CON_CPQ.OPPORTUNITY_TYPE_FSP, CON_CPQ.REVIEW_TYPE_CHALLENGE, CON_CPQ.CALL, CON_CPQ.NO_TITLE_CASE, CON_CPQ.WIN_PROBABILITY_0, CON_CPQ.REGION_ASIA_PASIFIC);
        testMatrix4.Migration_Id__c = 'CM-015';
        challengeMatrixList.add(testMatrix4);
        Challenge_Matrix__c testMatrix5 = UTL_TestData.createChallengeMatrix(CON_CPQ.TOTAL_IQVIA_FEES_CDS_5, CON_CPQ.OPPORTUNITY_TYPE_FSP, CON_CPQ.REVIEW_TYPE_CHALLENGE, CON_CPQ.CALL, CON_CPQ.NO_TITLE_CASE, CON_CPQ.WIN_PROBABILITY_1TO49, CON_CPQ.REGION_ASIA_PASIFIC);
        testMatrix5.Migration_Id__c = 'CM-016';
        challengeMatrixList.add(testMatrix5);
        insert challengeMatrixList;

        //Approval_Matrix__c approvalMatrix = new Approval_Matrix__c(approverGroup, 'RFP',
          //  'Latin America', 'Oncology', 'Test User', '', '', '', '', 'Large');

    }
    
    @isTest
    static void testGetBudgetDetailsForProposal() {
        
        Account acc = [SELECT Id,AccountCountry__c FROM Account Limit 1];
        Opportunity opp = [SELECT Id FROM Opportunity Limit 1];
        Bid_History__c clinicalBid = [SELECT Id FROM Bid_History__c Limit 1];
        
        Apttus_Proposal__Proposal__c proposal = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, opp.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, clinicalBid.Id);
        proposal.Apttus_Proposal__Account__c = acc.Id;
        update proposal;
            
        Test.startTest();
        CNT_CPQ_AgreementSection.BudgetDetails budgetDetailObj = CNT_CPQ_AgreementSection.getBudgetDetails(proposal.Id, 'Apttus_Proposal__Proposal__c');
        Test.stopTest();
        
        System.assertEquals(true, budgetDetailObj != null, 'should return Budget Detail');
    }

}