/*
* Version       : 1.0
* Description   : Test class for UTL_PEPs
*/
@IsTest
public class TST_UTL_PEP {
    
    @testSetup
    static void dataSetup() {
        Account ac = new Account(name ='Acme1',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE') ;
        ac.AccountCountry__c = 'BM' ;
        insert ac; 
        
        Contact con = new Contact(FirstName ='testCon',LastName ='testCon',AccountId = ac.Id,Email='partneruser@iqvia.partner.com');
        con.Partner_Type__c = 'Integrator Partner; Data Partner';
        insert con;
        
        List<Product2> prodList = new List<Product2>();
        List<Contract> contractList = new List<Contract>();
        
        Product2 prod = TST_PEP_TestDataFactory.createProduct('Oce Sales');
        prodList.add(prod);
        insert prodList;
        
        Contract ctr = TST_PEP_TestDataFactory.createContract('Ctr000125', ac.Id, prod.Id);
        contractList.add(ctr);
        insert contractList;
        
    }
    
    @isTest
    public static void testSendMail(){
        Contract ctr = [SELECT Id, Product__c, Name FROM Contract WHERE Name = 'Ctr000125'];
        String[] toAddresses= new String[]{'abc1234@xy.com'};
        String[] toCC= new String[]{'abc1234@xy.com'};
        String developerName='PRM_Non_Standard_ContractRenewal';
        Test.startTest();
            UTL_PEP.sendMail(ctr.Id,developerName,toAddresses,toCC);
        Test.stopTest();
    }
    
}