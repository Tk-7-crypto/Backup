/*
*@Author  : Supriya Johari
*@Purpose : 1. Test class for Controller  CNT_TPA_AMA_Fee_Master_Rules_Config
               to check the process of Fee master rule configuration.
*/
@isTest(seeAllData = false)
public class TST_CNT_TPA_AMA_Fee_Master_Rules_Config {

    private static AMA_Fee_Master__c feeMaster;
    private static AMA_Fee_Master__c feeMaster2;
    private static CNT_TPA_AMA_Fee_Master_Rules_Config amaFeeMasterRuleConfigController ;
    private static String feeMasterString ;
    private static String feeMasterString2 ;
    private static String existingRulesString;
    private static String newRuleString;
    private static AMA_Fee_Master__c newRuleRecord;
    private static  List<AMA_Fee_Master__c> existingRulesList;



    /**
    * Setup test data required to run tests in a data independent fashion
    */

    static void setupTestDataForAMASB1() {
       feeMaster = new AMA_Fee_Master__c();
       amaFeeMasterRuleConfigController = new CNT_TPA_AMA_Fee_Master_Rules_Config(new ApexPages.StandardController(feeMaster));
       feeMasterString = '{"Id":"","Year__c":"2015","Contract_Type__c":"Service Bureau I","Vendor_has_Licence__c":"has no existing License with AMA","Fee_Calculated__c":"Calculate Fee","Fee__c":"45"}'; //"Template__c":"AMA 2015 SB1",
       feeMasterString2 = '{"Id":"","Year__c":"2016","Contract_Type__c":"Service Bureau II","Vendor_has_Licence__c":"--None--","Fee_Calculated__c":"--None--","Fee__c":"67"}';// "Template__c":"2015 LS-v2013 1006"
    }


    static void setupTestDataForLettershop() {
       feeMaster = new AMA_Fee_Master__c();
       amaFeeMasterRuleConfigController = new CNT_TPA_AMA_Fee_Master_Rules_Config(new ApexPages.StandardController(feeMaster));
       feeMasterString = '{"Id":"","Year__c":"2015","Contract_Type__c":"Lettershop","Vendor_has_Licence__c":"--None--","Fee_Calculated__c":"--None--","Fee__c":""}'; //"Template__c":"2015 LS-v2013 1006"
       feeMasterString2 = '{"Id":"","Year__c":"2016","Contract_Type__c":"Service Bureau II","Vendor_has_Licence__c":"--None--","Fee_Calculated__c":"--None--","Fee__c":"67"}';// "Template__c":"2015 LS-v2013 1006"
    }


    static void setupTestDataForLettershopWOTemplateType() {
       feeMaster = new AMA_Fee_Master__c();
       amaFeeMasterRuleConfigController = new CNT_TPA_AMA_Fee_Master_Rules_Config(new ApexPages.StandardController(feeMaster));
       feeMasterString = '{"Id":"","Year__c":"2016","Contract_Type__c":"Lettershop","Vendor_has_Licence__c":"--None--","Fee_Calculated__c":"--None--","Fee__c":"67"}';// "Template__c":"2015 LS-v2013 1006"
       feeMasterString2 = '{"Id":"","Year__c":"2016","Contract_Type__c":"Service Bureau I","Vendor_has_Licence__c":"--None--","Fee_Calculated__c":"--None--","Fee__c":"67"}';// "Template__c":"2015 LS-v2013 1006"
    }

    public static testMethod void testcases_ForSB1(){
        PageReference pageRef = Page.VFP_TPA_AMA_Fee_Master_Rules_Config;
        Test.setCurrentPage(pageRef);

        test.startTest();
        setupTestDataForAMASB1();
        amaFeeMasterRuleConfigController.getYearsList();
        amaFeeMasterRuleConfigController.getContractTypeList();
        amaFeeMasterRuleConfigController.getVendorHasLicenseValuesList();
        amaFeeMasterRuleConfigController.getFeeCalculatedValuesList();
        CNT_TPA_AMA_Fee_Master_Rules_Config.saveRule(feeMasterString,'2015');
        //Assert if record is inerted
        List<AMA_Fee_Master__c> amaFeeMasterList = [Select id from AMA_Fee_Master__c];
        System.assertEquals(true, amaFeeMasterList.size() == 1);
        feeMasterString = '{"Id":"","Year__c":"2016","Contract_Type__c":"Lettershop","Vendor_has_Licence__c":"--None--","Fee_Calculated__c":"--None--","Fee__c":"45"}';
        CNT_TPA_AMA_Fee_Master_Rules_Config.showExistingRules('2015');

        newRuleRecord = [Select id, Contract_Type__c, Vendor_has_Licence__c, Fee_Calculated__c, Fee__c , Year__c from AMA_Fee_Master__c Where year__c = '2015' LIMIT 1]; // Template__c, Template__r.Name,

        //newRuleString = JSON.serialize(newRuleRecord);
        //AMA_Fee_Master__c savedRecord  = new AMA_Fee_Master__c(id=newRuleRecord.id, Contract_Type__c = newRuleRecord.Contract_Type__c,Vendor_has_Licence__c =newRuleRecord.Vendor_has_Licence__c , Template__c = 'AMA 2015 SB1',Fee_Calculated__c ='Calculate Fee',Fee__c= 78);
        //newRuleString = JSON.serialize(savedRecord);

        feeMasterString = feeMasterString.replace('"Id":""','"Id":"'+newRuleRecord.id+'"');
        feeMasterString = feeMasterString.replace('"Fee__c":"45"','"Fee__c":"95"');
        CNT_TPA_AMA_Fee_Master_Rules_Config.updateRule(feeMasterString,'2015');
        //Assert if record is updated
        newRuleRecord = [Select id, Contract_Type__c, Vendor_has_Licence__c, Fee_Calculated__c, Fee__c , Year__c from AMA_Fee_Master__c Where year__c = '2016' LIMIT 1];//Template__c, Template__r.Name,
        system.assertEquals(95.0,newRuleRecord.Fee__c);
        test.stopTest();

    }

    public static testMethod void testcases_ForLettershop(){
        PageReference pageRef = Page.VFP_TPA_AMA_Fee_Master_Rules_Config;
        Test.setCurrentPage(pageRef);

        test.startTest();
            setupTestDataForLettershop();
            amaFeeMasterRuleConfigController.getYearsList();
            amaFeeMasterRuleConfigController.getContractTypeList();
            amaFeeMasterRuleConfigController.getVendorHasLicenseValuesList();
            amaFeeMasterRuleConfigController.getFeeCalculatedValuesList();
            CNT_TPA_AMA_Fee_Master_Rules_Config.saveRule(feeMasterString,'2015');
            CNT_TPA_AMA_Fee_Master_Rules_Config.saveRule(feeMasterString2,'2015');
            newRuleRecord = [Select id, Contract_Type__c, Vendor_has_Licence__c, Fee_Calculated__c, Fee__c , Year__c from AMA_Fee_Master__c Where year__c = '2015' LIMIT 1]; // Template__c, Template__r.Name,
            newRuleString = JSON.serialize(newRuleRecord);
            CNT_TPA_AMA_Fee_Master_Rules_Config.deleteRule(newRuleString);
            CNT_TPA_AMA_Fee_Master_Rules_Config.showExistingRules('2015');
            List<AMA_Fee_Master__c> amaFeeMasterList = [Select id from AMA_Fee_Master__c];
            System.assertEquals(true, amaFeeMasterList.size() > 0);
        test.stopTest();

    }


      public static testMethod void testcases_ForLettershopWOTempType(){
        String currentYear = String.valueOf(date.today().year());
        PageReference pageRef = Page.VFP_TPA_AMA_Fee_Master_Rules_Config;
        Test.setCurrentPage(pageRef);

        test.startTest();
            setupTestDataForLettershopWOTemplateType();
            amaFeeMasterRuleConfigController.getYearsList();
            amaFeeMasterRuleConfigController.getContractTypeList();
            amaFeeMasterRuleConfigController.getVendorHasLicenseValuesList();
            amaFeeMasterRuleConfigController.getFeeCalculatedValuesList();
            CNT_TPA_AMA_Fee_Master_Rules_Config.saveRule(feeMasterString,'2016');
            CNT_TPA_AMA_Fee_Master_Rules_Config.saveRule(feeMasterString2,'2015');
            CNT_TPA_AMA_Fee_Master_Rules_Config.showExistingRules('2016');
        	CNT_TPA_AMA_Fee_Master_Rules_Config.cloneExistingRules(currentYear);
            CNT_TPA_AMA_Fee_Master_Rules_Config.deleteRule('');
            List<AMA_Fee_Master__c> amaFeeMasterList = [Select id from AMA_Fee_Master__c];
            System.assertEquals(true, amaFeeMasterList.size() > 0);
        test.stopTest();

    }

    public static testMethod void testcases_ForLettershopWOTempType2(){
        PageReference pageRef = Page.VFP_TPA_AMA_Fee_Master_Rules_Config;
        Test.setCurrentPage(pageRef);
        test.startTest();
            setupTestDataForLettershopWOTemplateType();
            amaFeeMasterRuleConfigController.getYearsList();
            amaFeeMasterRuleConfigController.getContractTypeList();
            amaFeeMasterRuleConfigController.getVendorHasLicenseValuesList();
            amaFeeMasterRuleConfigController.getFeeCalculatedValuesList();
            CNT_TPA_AMA_Fee_Master_Rules_Config.saveRule(feeMasterString,'2016');
            CNT_TPA_AMA_Fee_Master_Rules_Config.saveRule(feeMasterString2,'2015');
            CNT_TPA_AMA_Fee_Master_Rules_Config.updateRule(feeMasterString,'2016');
            CNT_TPA_AMA_Fee_Master_Rules_Config.showExistingRules('2016');
            CNT_TPA_AMA_Fee_Master_Rules_Config.deleteRule('');
            List<AMA_Fee_Master__c> amaFeeMasterList = [Select id from AMA_Fee_Master__c];
            System.assertEquals(true, amaFeeMasterList.size() > 0);
        test.stopTest();
    }

    public static testMethod void testcases_ForLettershopWOTempType3(){
        PageReference pageRef = Page.VFP_TPA_AMA_Fee_Master_Rules_Config;
        Test.setCurrentPage(pageRef);
        test.startTest();
            setupTestDataForLettershopWOTemplateType();
            amaFeeMasterRuleConfigController.getYearsList();
            amaFeeMasterRuleConfigController.getContractTypeList();
            amaFeeMasterRuleConfigController.getVendorHasLicenseValuesList();
            amaFeeMasterRuleConfigController.getFeeCalculatedValuesList();
            feeMasterString = '{"Id":"","Year__c":"2016","Contract_Type__c":"--None--","Vendor_has_Licence__c":"--None--","Fee_Calculated__c":"--None--","Fee__c":"67"}';
            CNT_TPA_AMA_Fee_Master_Rules_Config.saveRule(feeMasterString,'2016');
            CNT_TPA_AMA_Fee_Master_Rules_Config.updateRule(feeMasterString,'2016');
            List<AMA_Fee_Master__c> amaFeeMasterList = [Select id from AMA_Fee_Master__c];
            System.assertEquals(true, amaFeeMasterList.size() > 0);
        test.stopTest();
    }

    /**
     * Name: testcases_ForSavingDuplicateRule
     * Description: To save duplicate rule
    **/

    public static testMethod void testcases_ForSavingDuplicateRule(){
        PageReference pageRef = Page.VFP_TPA_AMA_Fee_Master_Rules_Config;
        Test.setCurrentPage(pageRef);
        feeMaster = new AMA_Fee_Master__c();
        test.startTest();
            setupTestDataForLettershopWOTemplateType();
            amaFeeMasterRuleConfigController.getYearsList();
            amaFeeMasterRuleConfigController.getContractTypeList();
            amaFeeMasterRuleConfigController.getVendorHasLicenseValuesList();
            amaFeeMasterRuleConfigController.getFeeCalculatedValuesList();
            CNT_TPA_AMA_Fee_Master_Rules_Config.saveRule(feeMasterString,'2016');
            //Inserting duplicate record
            CNT_TPA_AMA_Fee_Master_Rules_Config.saveRule(feeMasterString,'2016');
            List<AMA_Fee_Master__c> amaFeeMasterList = [Select id from AMA_Fee_Master__c];
            System.assertEquals(true, amaFeeMasterList.size() > 0);
        test.stopTest();

    }

    /**
     * Name: testcases_ForUpdatingDuplicateRule
     * Description: To update duplicate rule
    **/

    public static testMethod void testcases_ForUpdatingDuplicateRule(){
        PageReference pageRef = Page.VFP_TPA_AMA_Fee_Master_Rules_Config;
        Test.setCurrentPage(pageRef);
        feeMasterString = '{"Id":"","Year__c":"2016","Contract_Type__c":"Lettershop","Vendor_has_Licence__c":"","Fee_Calculated__c":"","Fee__c":""}';
        feeMaster = new AMA_Fee_Master__c();
        amaFeeMasterRuleConfigController = new CNT_TPA_AMA_Fee_Master_Rules_Config(new ApexPages.StandardController(feeMaster));
        test.startTest();
            //setupTestDataForLettershopWOTemplateType();
            amaFeeMasterRuleConfigController.getYearsList();
            amaFeeMasterRuleConfigController.getContractTypeList();
            amaFeeMasterRuleConfigController.getVendorHasLicenseValuesList();
            amaFeeMasterRuleConfigController.getFeeCalculatedValuesList();
            CNT_TPA_AMA_Fee_Master_Rules_Config.saveRule(feeMasterString,'2016');
            feeMasterString = feeMasterString.replace('"Contract_Type__c":"Lettershop"','"Contract_Type__c":"Contract Salesforce"');
            CNT_TPA_AMA_Fee_Master_Rules_Config.saveRule(feeMasterString,'2016');
            List<AMA_Fee_Master__c> amaFeeMasterList = [Select id, Contract_Type__c, Vendor_has_Licence__c, Fee_Calculated__c, Fee__c , Year__c, Proration_Rules_Applied__c, LastModifiedDate, CreatedDate  from AMA_Fee_Master__c where Contract_Type__c = 'Contract Salesforce'];
            feeMasterString = feeMasterString.replace('"Id":""','"Id":"'+amaFeeMasterList[0].id+'"');
            feeMasterString = feeMasterString.replace('"Contract_Type__c":"Contract Salesforce"','"Contract_Type__c":"Lettershop"');
            //Updating duplicate record
            CNT_TPA_AMA_Fee_Master_Rules_Config.updateRule(feeMasterString,'2016');
            amaFeeMasterList = [Select id from AMA_Fee_Master__c];
            System.assertEquals(true, amaFeeMasterList.size() > 0);
        test.stopTest();

    }
}