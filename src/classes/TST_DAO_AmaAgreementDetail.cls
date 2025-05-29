@isTest
public class TST_DAO_AmaAgreementDetail { 
    @isTest
    static void TestDAO_AmaAgreementDetail(){
        TPA_Request__c objTpaReq = UTL_TPA_SetupTestData.getTPARequest();
        AMA_Agreement_Detail__c amaAgg = new AMA_Agreement_Detail__c(AMA_Manual_Review__c = false, Is_AMA_License_Required__c = true,
                                            DBL__c = 'Test DBL', Send_DBL_Notification_To_AMA__c = true, TPA_Request__c = objTpaReq.Id, Current_Year_Fees__c = 21000,Next_Year_Fees__c = 56000,
                                            Initial_Termination_Date__c = date.newInstance(2017, 12, 31), Agreement_End_Date__c = date.newInstance(2020, 12, 31),
                                            Date_Agreement_Activated__c = system.now());
        insert amaAgg;
        amaAgg.AMA_Manual_Review__c = false;
        update amaAgg;
        
    }

}
