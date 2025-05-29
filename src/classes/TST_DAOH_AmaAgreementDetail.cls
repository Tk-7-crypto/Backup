@isTest
public class TST_DAOH_AmaAgreementDetail { 
    @isTest
    static void TestDAOH_AmaAgreementDetail(){
        TPA_Request__c objTpaReq = UTL_TPA_SetupTestData.getTPARequest();
        AMA_Agreement_Detail__c amaObj = UTL_TPA_SetupTestData.getAMAAgreementDetail('Test DBL', 'Test AMA', objTpaReq.Id);
        amaObj.AMA_Manual_Review__c = false;
        update amaObj;
        
    }

}