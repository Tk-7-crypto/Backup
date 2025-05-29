@isTest
public class TST_DAO_Site_Submission {
    
    @testSetup
    private static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        
        Product2 pd = UTL_TestData.createProduct();
        pd.ProductCode='Q_112941';
        insert pd;
        
        PricebookEntry pe = UTL_TestData.createPricebookEntry(pd.Id);
        pe.CurrencyIsoCode = 'USD';
        insert pe;
    }
    
    @isTest
    private static void testCase1() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        UserRole avacareUserRole = [Select id from UserRole where Name = 'Avacare'];
        
        List<User> userList = UTL_TestData.createUser(CON_CRM.SYSTEM_ADMIN_PROFILE,1);
        userList[0].UserRoleId = avacareUserRole.id;
        insert userList;
        
        System.runAs(userList[0]){
            Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
            opp.Line_of_Business__c = 'Avacare';
            insert opp;
            
            Test.startTest();
            Site_Submission__c ss = UTL_TestData.creatSiteSubmissionRecord(opp.Id, null, null);
            insert ss;

            ss.Pre_FQ_Submitted__c = System.Today();
			update ss;
            Test.stopTest();
        }
    }
}