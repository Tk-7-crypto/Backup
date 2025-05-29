@isTest
private with sharing class TST_DAOH_COE_Quality_Check {
    @IsTest
    static void testInsertRecords(){
        case newCase = UTL_TestData.createCase();
        insert newCase;
        Account newAccount = UTL_TestData.createAccount();
        insert newAccount;
        Contact con =  new Contact(FirstName = 'TestFirstName', Email =' mishmaurya@gmail.com' , LastName = 'TestContact', accountId = newAccount.id);
        insert con;
        List<CSM_QI_Tech_COE_QualityCheck__c> qualityCheckObjList = new List<CSM_QI_Tech_COE_QualityCheck__c>();
        CSM_QI_Tech_COE_QualityCheck__c qualityCheckObj = new CSM_QI_Tech_COE_QualityCheck__c(Case__c = newCase.Id,Overall_Comments__c = null, Overall_Compliance__c = null);
        qualityCheckObjList.add(qualityCheckObj);
        DAOH_COE_Quality_Check.checkOverallCompliance(qualityCheckObjList);
        System.assertEquals(false,qualityCheckObj.Case_Checked__c);
    }
    @IsTest
    static void testUpdateCaseFields(){
        case newCase = UTL_TestData.createCase();
        insert newCase;  
            
        CSM_QI_Tech_COE_QualityCheck__c f1 =new CSM_QI_Tech_COE_QualityCheck__c(Form_Request_Type__c='FCR Quality Check',Case__C = newCase.Id,FCR_Review_Escalation_Lst__c = 'Non-Essential Escalation');
        insert f1;
        
          CSM_QI_Tech_COE_QualityCheck__c irt1 =new CSM_QI_Tech_COE_QualityCheck__c(Form_Request_Type__c='IRT Quality Check',Case__c = newCase.Id);
        insert irt1;
        
        CSM_QI_Tech_COE_QualityCheck__c csat1 =new CSM_QI_Tech_COE_QualityCheck__c(Form_Request_Type__c='CSAT Quality Check',Case__c = newCase.Id);
        insert csat1;
        
        
        
    }
    
    @IsTest
    static void testInsertRecords1(){
        case newCase1 = UTL_TestData.createCase();
        insert newCase1;
        Account newAccount1 = UTL_TestData.createAccount();
        insert newAccount1;
        Contact con1 =  new Contact(FirstName = 'Test1FirstName', Email ='vinaybly@gmail.com' , LastName = 'Tes1tContact', accountId = newAccount1.id);
        insert con1;
        
        List<CSAT_Responses__c> lstcsat =  new List<CSAT_Responses__c>();
        lstcsat.add(new CSAT_Responses__c(Case__c = newCase1.Id,Question__c = 'Would you agree to IQVIA contacting you in case of additional questions?',Answer__c = '1'));
        lstcsat.add(new CSAT_Responses__c(Case__c = newCase1.Id,Question__c = 'How satisfied are you with the overall support you received for this request?',Answer__c = '4'));
        insert lstcsat;
            
        
        CSM_case_Trigger_Handler__c setting = new CSM_case_Trigger_Handler__c();
        setting.CSAT_Quality_Check_Question_1__c = 'Would you agree to IQVIA contacting you in case of additional questions?';
        setting.CSAT_Quality_Check_Question_2__c = 'How satisfied are you with the overall support you received for this request?';
        //setting1.Value__c = '4';
        insert setting;
        
        Id [] fixedSearchResults= new Id[2];
        fixedSearchResults[0] = lstcsat[0].Id;
        fixedSearchResults[1] = lstcsat[1].Id;
        Test.setFixedSearchResults(fixedSearchResults);
        
        
        List<CSM_QI_Tech_COE_QualityCheck__c> qualityCheckObjList1 = new List<CSM_QI_Tech_COE_QualityCheck__c>();
        CSM_QI_Tech_COE_QualityCheck__c qualityCheckObj1 = new CSM_QI_Tech_COE_QualityCheck__c(Case__c = newCase1.Id,Overall_Comments__c='Test Comment',Overall_Compliance__c='C');
        qualityCheckObjList1.add(qualityCheckObj1);
        DAOH_COE_Quality_Check.checkOverallCompliance(qualityCheckObjList1);
        
        List<CSM_QI_Tech_COE_QualityCheck__c> qualityCheckObjList2 = new List<CSM_QI_Tech_COE_QualityCheck__c>();
        CSM_QI_Tech_COE_QualityCheck__c qualityCheckObj2 = new CSM_QI_Tech_COE_QualityCheck__c(Case__c = newCase1.Id,Form_Request_Type__c = 'CSAT Quality Check');
        qualityCheckObjList2.add(qualityCheckObj2);
        DAOH_COE_Quality_Check.AddCSATAnswers(qualityCheckObjList2);
        
        
        System.assertEquals(true,qualityCheckObj1.Case_Compliant__c);
        
        System.assertEquals('Yes',qualityCheckObj2.Agreed__c);
        System.assertEquals('4',qualityCheckObj2.CSAT_overall_satisfaction__c);
        

    }
}
