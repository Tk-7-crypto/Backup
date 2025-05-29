@isTest
private class TST_CNT_CLM_ConfirmBoxPopup {
    
    @isTest
    private static void testDeleteAgreementByIdShouldDeleteRecord() {
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(null,true);

        Test.startTest();
            Boolean isDeleted = CNT_CLM_ConfirmBoxPopup.deleteAgreementById(agreement.Id);
        Test.stopTest();

        System.assertEquals(true,isDeleted, 'Agreement deletion failure.');
        
    }

    @isTest
    private static void testDeleteAgreementByIdShouldThrowException(){
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(null,false);
        Boolean isDeleted = false;

        Test.startTest();
            try{
                isDeleted = CNT_CLM_ConfirmBoxPopup.deleteAgreementById(agreement.Id);
            }catch(Exception ex){
                System.assertEquals(false,isDeleted, 'Agreement deleted successfully when not expected');
            }
        Test.stopTest();
    }
}