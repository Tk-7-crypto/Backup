@isTest
public class TST_CNT_PSA_ImportJournalMainCtlg {
    
    @testSetup
    static void dataSetup() {
        Journals_Main_Catalogue__c jmc = UTL_PSA_TestData.createJournalMainCatalogue();
        insert jmc;
    } 
    
    @isTest
    static void testsaveFile() {  
        String abc = '\"Unique ID,Country,Journal name,URL,Periodicity,Regulatory Requirement,Subscription,Paper journal,Therapeutic area\\r\\nARG01,Argentina,Revista Flebología,http://www.sociedadflebologia.com/revista/,\\"3 publications per year (April, August and December)\\\",No,No,No,Medicinal Journal\\r\\nAUS01,Australia,Medical Devices Safety Update,https://www.tga.gov.au/publication/medical-devices-safety-update,Bi-Monthly,No,No,No,Medicinal Journal\\r\\nAST01,Austria,Jatros Orthopädie,https://www.oegout.at/jatros/,Monthly,No,No,No,Lumbar interbody fusion surgery & acute tibia fractures\\r\\n\"';
        Test.startTest();
        CNT_PSA_ImportJournalMainCtlg.saveFile(abc);
        Test.stopTest();      
        System.assertEquals(4, [select count() from Journals_Main_Catalogue__c], 'Tested');
    }
    
    @isTest
    static void testToUpdate(){
        String abc = '\"Unique ID,Country,Journal name,URL,Periodicity,Regulatory Requirement,Subscription,Paper journal,Therapeutic area\\r\\n123,Argentina,Revista Flebología,http://www.sociedadflebologia.com/revista/,\\"3 publications per year (April, August and December)\\\",No,No,No,Medicinal Journal\\r\\nAUS01,Australia,Medical Devices Safety Update,https://www.tga.gov.au/publication/medical-devices-safety-update,Bi-Monthly,No,No,No,Medicinal Journal\\r\\nAST01,Austria,Jatros Orthopädie,https://www.oegout.at/jatros/,Monthly,No,No,No,Lumbar interbody fusion surgery & acute tibia fractures\\r\\n\"';
        Test.startTest();
        CNT_PSA_ImportJournalMainCtlg.saveFile(abc);
        Test.stopTest();
        System.assertEquals(3, [select count() from Journals_Main_Catalogue__c], 'Tested');
    }
    
    @isTest
    static void testsaveXlsFile(){
        List<Journals_Main_Catalogue__c> listJMC = [SELECT Name, Country__c, Journal_Name__c, URL__c, Periodicity__c, Regulatory_requirement__c, Subscription__c, Paper_Journal__c, Therapeutic_Area__c from Journals_Main_Catalogue__c LIMIT 1];
        listJMC[0].Country__c = 'Algeria';
        Test.startTest();
        CNT_PSA_ImportJournalMainCtlg.saveXlsFile(listJMC);
        Test.stopTest();
        System.assertEquals(1, [select count() from Journals_Main_Catalogue__c], 'Tested');
    }
    
    @isTest
    static void testsaveInvalidXlsFile(){
        Boolean errorsAsExpected = false;
        List<Journals_Main_Catalogue__c> jmcList = [SELECT Name, Country__c, Journal_Name__c, URL__c, Periodicity__c, Regulatory_requirement__c, Subscription__c, Paper_Journal__c, Therapeutic_Area__c from Journals_Main_Catalogue__c LIMIT 1];
        jmcList[0].Country__c = 'Algerian';
        Test.startTest();
        try{
            CNT_PSA_ImportJournalMainCtlg.saveXlsFile(jmcList);
        }catch(Exception ex){
            errorsAsExpected = true;
        }
        Test.stopTest();
        system.assert (errorsAsExpected == true, 'Expected an error');
    }
}
