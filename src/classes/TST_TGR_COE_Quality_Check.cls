@IsTest
public class TST_TGR_COE_Quality_Check {
    @IsTest
    static void testInsertRecords(){
        case newCase = UTL_TestData.createCase();
        insert newCase;
        Account newAccount = UTL_TestData.createAccount();
        insert newAccount;
        Contact con =  new Contact(FirstName = 'TestFirstName', Email =' mishmaurya@gmail.com' , LastName = 'TestContact', accountId = newAccount.id);
        insert con;
        CSM_QI_Tech_COE_QualityCheck__c qualityCheckObj = new CSM_QI_Tech_COE_QualityCheck__c(Case__c = newCase.Id,Overall_Comments__c = null, Overall_Compliance__c = null,Quality_Result_attributed_to__c = UserInfo.getUserId());
        insert qualityCheckObj;
        qualityCheckObj.Overall_Comments__c = 'abc@gmail.com';
        update qualityCheckObj;
    }
}