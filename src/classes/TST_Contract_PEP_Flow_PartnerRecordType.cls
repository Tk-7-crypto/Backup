@isTest
private class TST_Contract_PEP_Flow_PartnerRecordType {
    
    @testSetup
    static void dataSetup() {
        List<User> listOfUser = UTL_TestData.createUser('Service User', 2);
        listOfUser[0].IsActive = true;
        listOfUser.add(UTL_TestData.createUser('System Administrator', 1)[0]);
        Insert listOfUser;
        
        Account acc = new Account(Name = 'testSetupTestContractAccount',AccountCountry__c= 'US',CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert acc;
       
        Agency_Program__c ap = new Agency_Program__c();	
        ap.Name = 'OCE Personal';
        ap.Duration_in_month__c = 12;
        ap.First_Notification__c = 1;
        ap.Second_Notification__c = 2;
        ap.Third_Notification__c = 3;
        insert ap;
               
        Date startDate = Date.Today();
        List<Contract> contractList = new List<Contract>();
        Contract cont1 = new Contract();
        cont1.AccountId = acc.Id;
        cont1.PRM_Contract_type__c = 'Agency Program SOW';
        cont1.StartDate = startDate;
        cont1.EndDate = startDate.addMonths(12);
        cont1.Non_Standard_Contract__c = True;
        cont1.Agency_Program__c = ap.Id;
        contractList.add(cont1);
        
        Contract cont2 = new Contract();
        cont2.AccountId = acc.Id;
        cont2.PRM_Contract_type__c = 'Agency Program SOW';
        cont2.StartDate = startDate;
        cont2.Non_Standard_Contract__c = False;
        cont2.Agency_Program__c = ap.Id;
        contractList.add(cont2);
        
        Test.startTest();
        insert contractList;
        Test.stopTest();
    }
       
    @isTest
    static void testPRMContract(){
        List<Contract> contractList = Database.query('Select id,AccountId,PRM_Contract_type__c,Agency_Program__c,StartDate,EndDate From Contract where Non_Standard_Contract__c=True');
        for(Contract c : contractList){
            c.First_Notification_Date__c = c.EndDate-3;
            c.Second_Notification_Date__c = c.EndDate-2;
            c.Third_Notification_Date__c = c.EndDate-1;
            c.Renewal_date__c = c.EndDate; 
        }
        if(contractList != null && !contractList.isEmpty()){
            Test.startTest();
            update contractList;
            Test.stopTest();
        }
    }

}