@IsTest
public class TST_DAO_COE_Quality_Check {
    @IsTest
    static void testInsertRecords(){
        case newCase = UTL_TestData.createCase();
        insert newCase;
        Account newAccount = UTL_TestData.createAccount();
        insert newAccount;
        Contact con =  new Contact(FirstName = 'TestFirstName', Email =' mishmaurya@gmail.com' , LastName = 'TestContact', accountId = newAccount.id);
        insert con;
        CSM_QI_Tech_COE_QualityCheck__c qualityCheckObj = new CSM_QI_Tech_COE_QualityCheck__c(Case__c = newCase.Id,Overall_Comments__c = null, 
                                                                                              Form_Request_Type__c = 'COE Quality Check',
                                                                                              Overall_Compliance__c = null,Quality_Result_attributed_to__c = UserInfo.getUserId());
        insert qualityCheckObj;
        
        CSM_QI_Tech_COE_QualityCheck__c qualityCheckObj2 = new CSM_QI_Tech_COE_QualityCheck__c(Case__c = newCase.Id,Form_Request_Type__c = 'CSAT Quality Check'); 
        insert qualityCheckObj2;
        
         
        CSM_QI_Tech_COE_QualityCheck__c f1 =new CSM_QI_Tech_COE_QualityCheck__c(Form_Request_Type__c='FCR Quality Check',Case__C = newCase.Id,FCR_Review_Escalation_Lst__c = 'Non-Essential Escalation');
        insert f1;
        
        CSM_QI_Tech_COE_QualityCheck__c irt1 =new CSM_QI_Tech_COE_QualityCheck__c(Form_Request_Type__c='IRT Quality Check',Case__c = newCase.Id);
        insert irt1;
        
        
        qualityCheckObj.Overall_Comments__c = 'abc@gmail.com';
        update qualityCheckObj;
    }
}
