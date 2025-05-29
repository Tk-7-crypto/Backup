@isTest
public class TST_DAO_Certification {
    @testSetup
    public static void setup(){                
        User adminUser = TST_PEP_TestDataFactory.createAdminUser('admin','adminPartner@iqvia.com');
        insert adminUser;
        
        System.runAs(adminUser){
            Product2 prod = TST_PEP_TestDataFactory.createProduct('Product2');
            insert prod;
        }
    }
    
    static testMethod void testCertificationUpdate() {
        User adminUser = [SELECT id FROM User WHERE email='adminPartner@iqvia.com'];
        Product2 prod = [SELECT ID FROM Product2 WHERE Name = 'Product2'];
        System.runAs(adminUser){
            List<Certification__c> lstCertif = new List<Certification__c>();        
            for(Integer i=1 ; i<=7;i++){
                lstCertif.add(TST_PEP_TestDataFactory.createCertification('Certif-00000'+i,'Certification'+i,
                                                                          system.today().addMonths(-3), 'pathname', 'http://www.url.com'+i, prod, adminUser, 'v'+i));
            }
            
            insert lstCertif;
        }
    }   
}