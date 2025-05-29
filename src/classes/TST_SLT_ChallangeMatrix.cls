@isTest
private class TST_SLT_ChallangeMatrix {

    static Challenge_Matrix__c setChallangeMatrixData(String migrationId){
        Challenge_Matrix__c challangeMatrix = UTL_TestData.createChallengeMatrix(CON_CPQ.TOTAL_IQVIA_FEES_CDS_0TO3, CON_CPQ.OPPORTUNITY_TYPE_FSP, CON_CPQ.REVIEW_TYPE_CHALLENGE,
                                      CON_CPQ.EMAIL, CON_CPQ.NO_TITLE_CASE, CON_CPQ.WIN_PROBABILITY_0, CON_CPQ.POTENTIAL_REGION_EMEA);
        challangeMatrix.Migration_Id__c = migrationId;
        insert challangeMatrix;
        return challangeMatrix;
    }
    
    @isTest
    static void testSelectChallangeMatrixById(){
        Challenge_Matrix__c testChallangeMatrix  = setChallangeMatrixData('CM-19');
        
        Test.startTest();
        	List<Challenge_Matrix__c> challangeMatrixList = new SLT_ChallangeMatrix().selectById(new Set<Id>{testChallangeMatrix.Id});
        Test.stopTest();
    }
    
    @isTest
    static void testSelectChallangeMatrixCondition(){
        setChallangeMatrixData('CM-20');
        
        Test.startTest();
        	List<Challenge_Matrix__c> testChallangeList = new SLT_ChallangeMatrix().selectChallangeMatrixCondition(CON_CPQ.TOTAL_IQVIA_FEES_CDS_0TO3,
                                                              CON_CPQ.OPPORTUNITY_TYPE_FSP, CON_CPQ.REVIEW_TYPE_CHALLENGE, CON_CPQ.NO_TITLE_CASE);
        Test.stopTest();
    }
    
    @isTest
    static void testSelectChallangeMatrixConditionChallenge(){
        setChallangeMatrixData('CM-21');
        
        Test.startTest();
        	List<Challenge_Matrix__c> testChallangeListChallenge = new SLT_ChallangeMatrix().selectChallangeMatrixConditionChallenge(CON_CPQ.TOTAL_IQVIA_FEES_CDS_0TO3,
                                                                       CON_CPQ.OPPORTUNITY_TYPE_FSP, CON_CPQ.REVIEW_TYPE_CHALLENGE, CON_CPQ.NO_TITLE_CASE, CON_CPQ.WIN_PROBABILITY_0, CON_CPQ.POTENTIAL_REGION_EMEA);
        Test.stopTest();
    }
}
