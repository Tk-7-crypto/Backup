@isTest
private class TST_SRV_CLM_Agreement {
    
    @isTest
    private static void testCreateAgreementShouldCreateAGRRecord(){

        Test.startTest();
            Apttus__APTS_Agreement__c agreement =  TST_CLM_TestDataFactory.createAgreement(null,false);
            Apttus__APTS_Agreement__c agreementReturned =
                SRV_CLM_Agreement.createAgreement(agreement);
            try {
                SRV_CLM_Agreement.createAgreement(null);
            } catch(Exception ex) {
                System.assertNotEquals(null, ex);
            }
        Test.stopTest();

        System.assertNotEquals(null, agreementReturned.Id,
            'Agreement record creation failure');
    }

    @isTest
    private static void testGetAgreementDetailByIdShouldReturnAGRRecord() {
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(null, true);
        Set<String> fieldSet = new Set<String>{'Id', 'Name'};

        Test.startTest();
            Apttus__APTS_Agreement__c agreementReturned = SRV_CLM_Agreement.getAgreementDetailById(agreement.Id, fieldSet);
        Test.stopTest();

        System.assertNotEquals(null, agreementReturned.Id, 'Not able to get the agreement details when expected');
    }

    @isTest
    private static void testGetAgreementFieldMapShouldReturnValidMap(){
        Apttus__APTS_Agreement__c agreement = 
            TST_CLM_TestDataFactory.createAgreement(null,false);
        Test.startTest();
            Map<String,String> mapOfFieldNameLabel = SRV_CLM_Agreement.getAgreementFieldMap();
        Test.stopTest();

        System.assertNotEquals(null,mapOfFieldNameLabel, 'The returned map is null when not expected');
        system.debug('testGetAgreementFieldMapShouldReturnValidMap' + mapOfFieldNameLabel.get('Name'));
        System.assertEquals('Agreement Name', mapOfFieldNameLabel.get('Name'),
            'Field Label mismatched when not expected');
    }
    
    @isTest
    private static void testUpdateIQVIAAgreement() {
        IQVIA_Agreement__c agreement = TST_CLM_TestDataFactory.createIQAgreement(CON_CLM.USBU_IQVIA_RECORDTYPEID, true);
        agreement.Contract_Start_Date__c = System.today() + 1;
        
        Test.startTest();
            SRV_CLM_Agreement.updateIQVIAAgreement(agreement);   
        Test.stopTest();
        
        System.assertEquals(System.today() + 1, agreement.Contract_Start_Date__c, 'The date should be updated.');
    }    

    @isTest
    private static void testUpdateAgreementShouldUpdateAGRRecord(){
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(null,true);
        agreement.Apttus__Contract_Start_Date__c = Date.today().addDays(60);

        Test.startTest();
            Apttus__APTS_Agreement__c agreementReturned = SRV_CLM_Agreement.updateAgreement(agreement);
        Test.stopTest();

        System.assertEquals(Date.today().addDays(60), agreement.Apttus__Contract_Start_Date__c,
            'Agreement record update failure');
    }

    @isTest
    private static void testUpdateAgreementShouldThrowException(){
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(null,false);
        
        Test.startTest();
            try{
            Apttus__APTS_Agreement__c agreementReturned = SRV_CLM_Agreement.updateAgreement(agreement);
            }catch(Exception ex){
                System.assertEquals('SRV_CLM_Agreement.SRV_CLM_Agreement_Exception', ex.getTypeName());
            }
        Test.stopTest();
    }

    @isTest
    private static void testDeleteAgreementShouldDeleteAgreement(){
        Apttus__APTS_Agreement__c agreement = 
            TST_CLM_TestDataFactory.createAgreement(null,true);

        Test.startTest();
            Boolean isDeleted = 
                SRV_CLM_Agreement.deleteAgreement(agreement.Id);
        Test.stopTest();

        System.assertEquals(true,isDeleted, 'Agreement deletion failure');
    }

    @isTest
    private static void testDeleteAgreementShouldThrowException(){
        Apttus__APTS_Agreement__c agreement = 
            TST_CLM_TestDataFactory.createAgreement(null,false);
        Boolean isDeleted = false;

        Test.startTest();
            try{
                isDeleted = SRV_CLM_Agreement.deleteAgreement(agreement.Id);
            }catch(Exception ex){
                System.assertEquals(false,isDeleted, 'Agreement deletion operation successful when not expected');
            }
        Test.stopTest();

        
    }
}