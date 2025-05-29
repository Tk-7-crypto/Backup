@IsTest
public class TST_SLT_Certification { 
    
    @testSetup
    public static void setup(){        
        User adminUser = TST_PEP_TestDataFactory.createAdminUser('admin','adminPartner@iqvia.com');
        insert adminUser;
        
        System.runAs(adminUser){
            Product2 prod = TST_PEP_TestDataFactory.createProduct('Product2');
            insert prod;
            List<Certification__c> lstCertif = new List<Certification__c>();        
            for(Integer i=1 ; i<=7;i++){
                lstCertif.add(TST_PEP_TestDataFactory.createCertification('Certif-00000'+i,'Certification'+i,
                                                                          system.today().addMonths(-3), 'pathname', 'http://www.url.com'+i, prod, adminUser, 'v'+i));
            }
            
            insert lstCertif;
        }
    }
    
    static testMethod void testSelectLMSCertifications() {
        List<Certification__c> certList = [SELECT ID FROM Certification__c];
        List<Certification__c> getList = new List<Certification__c>();
        Test.startTest();
        getList = new SLT_Certification().selectLMSCertifications(new Set<Id>{certList[0].Id});
        Test.stopTest();
    }

}