/**************************************************************************************************
* @Author:      Ashish Verma 
* @Date:        21/03/2022
* @PageCode:    
* @CurErrCode: 
* @Description: IQVIACBEX-1804:Test class for CNT_RFP_UnityFlag_Queuable
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
***************************************************************************************************/
@isTest(seeAllData = false)
public class TST_CNT_RFP_UnityFlag_Queuable {

    private static Account setAccountData() {
        Account testAccount = UTL_TestData.createAccount();
        insert testAccount;
        return testAccount;
    }
    
    private static List<Id> getOpportunityData(Id accountId) {    
        List<Id> lstOpptyId =  new List<Id>();
        List<Opportunity> listOfOpportunitiesToInsert = new List<Opportunity>(); 
        
        Opportunity testOpportunity = UTL_TestData.createOpportunity(accountId);
        testOpportunity.Line_of_Business__c = 'Data Sciences';
        testOpportunity.Legacy_Quintiles_Opportunity_Number__c = CON_CPQ.TEST_OPPORTUNITY_NUMBER;
        listOfOpportunitiesToInsert.add(testOpportunity);
        insert listOfOpportunitiesToInsert;
        
        for(Opportunity opp : listOfOpportunitiesToInsert) {
            lstOpptyId.add(opp.Id);
        }
        return lstOpptyId;
    }
    
    public static testmethod void testProcessOutbound() {
        List<Intake_Unity_Flag_Sync__c> LstFlagSync = new List<Intake_Unity_Flag_Sync__c>();
        Account testAccount = setAccountData();
        CNT_RFP_UnityFlag_Queuable flagJob = new CNT_RFP_UnityFlag_Queuable(CON_CBEx.OPPORTUNITY_OBJECT, getOpportunityData(testAccount.Id));
        Test.startTest();
        	System.enqueueJob(flagJob);
        Test.stopTest();
    }
}