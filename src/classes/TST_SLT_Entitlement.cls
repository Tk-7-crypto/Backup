@isTest
private class TST_SLT_Entitlement {
    
    @testSetup
    static void dataSetup() {
        Account acc = CSM_Util.createAccount();
        insert acc;
        Contact cnt = CSM_Util.createContact(acc.Id,'CaseTestContact');
        insert cnt;
        /*Audit trail Log Added Start */
        Account acct2 = CSM_Util.createRDAccount();
        insert acct2;
        
        /*Audit trail Log Added End */
        
    }
    
    testmethod static void selectEntitlement(){
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'CaseTestAccount' LIMIT 1];
        Account acct2= [SELECT Id, Name FROM Account WHERE Name = 'CaseRDTestAccount' LIMIT 1];
        Contact cnt = [SELECT Id, Name FROM Contact WHERE Name = 'CaseTestContact CaseTestContact' LIMIT 1];
        Contact cnt2 = CSM_Util.createContact(acc.Id,'CaseTestContact2');
        insert cnt2;
        Study__c study = CSM_Util.createStudy(acct2.Id);
        insert study;
        Study__c study2 = CSM_Util.createStudy(acct2.Id);
        insert study2;
        Product2 product = CSM_Util.createProduct2();
        insert product;
        Asset aset = CSM_Util.createAsset('CaseTestProduct',product.Id,acc.Id,cnt.Id,study.Id);
        insert aset;
        ServiceNow_Group__c service=new ServiceNow_Group__c();
        service.Group_ID__c='GRP123';
        service.Name = 'Service GRP123';
        insert service;
        
        ServiceNow_Group__c service2=new ServiceNow_Group__c();
        service2.Group_ID__c='GRP123';
        service2.Name = 'Service GRP123';
        insert service2;
        
        BusinessHours bHours = [select Id,Name,IsActive,IsDefault from BusinessHours where IsActive=true and name='Default' LIMIT 1];
        BusinessHours bHours2 = [select Id,Name,IsActive,IsDefault from BusinessHours where IsActive=true and name='EU Business Hours' LIMIT 1];
        
        Entitlement ent = new Entitlement(Name='Testing', AccountId=acc.Id,Type = 'R_D',
                                          BusinessHoursId = bHours.Id,
                                          StartDate=Date.valueof(System.now().addDays(-2)), 
                                          EndDate=Date.valueof(System.now().addYears(2)));
        
        Entitlement ent2 = new Entitlement(Name='Testing2', AccountId=acc.Id,Type = 'R_D',
                                           BusinessHoursId = bHours2.Id,
                                           StartDate=Date.valueof(System.now().addDays(-2)), 
                                           EndDate=Date.valueof(System.now().addYears(2)));
        
        insert ent;
        insert ent2;
        new SLT_Entitlement().selectByEntitlementId(new Set<Id>{ent.Id,ent2.Id}, new Set<String> {CON_CSM.S_ID, CON_CSM.S_NAME});
        
        
    }

}