@isTest(SeeAlldata=false)
public class TST_AccountLookup{
    private static String str;
    private static List<Account> accounts = new List<Account>();
    private static void setupAccount(){
        for(Integer i = 0;i <= 50 ; i++){
            Account acc = UTL_TestData.createAccount();
            acc.Name = 'TestAccount'+ i;
            accounts.add(acc);
        }
        insert accounts;
    }

    public static testMethod void testCase1(){
        // Updated by :Sunil Kumar Sharma Date:Mar 15, 2012: Partial url to set Page reference.
        PageReference pageRef = new PageReference('/apex/Account_Lookup?strText=TestAccount');
        Test.setCurrentPageReference(pageRef);

        Test.startTest();        
			setupAccount();
			AccountLookup acclookup = new AccountLookup ();
			acclookup.getSelectCountry();
			acclookup.Country='USA';  
			acclookup.getListBySearchText();        
        Test.stopTest();
		// acclookup.getListBySearchText();
    }
    
    public static testMethod void testCase2(){
        // Updated by :Sunil Kumar Sharma Date:Mar 15, 2012: Partial url to set Page reference.
        PageReference pageRef = new PageReference('/apex/Account_Lookup');
        Test.setCurrentPageReference(pageRef);
                   
        Test.startTest(); 
			setupAccount();       
			AccountLookup acclookup = new AccountLookup ();
        Test.stopTest();
    }
    
    public static testMethod void testCase3(){
        // Updated by :Sunil Kumar Sharma Date:Mar 15, 2012: Partial url to set Page reference.
        PageReference pageRef = new PageReference('/apex/Account_Lookup?strText=');
        Test.setCurrentPageReference(pageRef);
                   
        Test.startTest(); 
			setupAccount();       
			AccountLookup acclookup = new AccountLookup ();
        Test.stopTest();
    }
    
    public static testMethod void testCase4(){
        // Updated by :Sunil Kumar Sharma Date:Mar 15, 2012: Partial url to set Page reference.
        PageReference pageRef = new PageReference('/apex/Account_Lookup?strText=');
        Test.setCurrentPageReference(pageRef);
                   
        Test.startTest(); 
			setupAccount();       
			AccountLookup acclookup = new AccountLookup ();
			acclookup.getSelectCountry();
			acclookup.Country='USA';  
			acclookup.getListBySearchText();
        Test.stopTest();
    }
}