/**
 * Author: Vikram Singh Fartyal (on March 09, 2018)
 * Description: Test class of controller class TPA_MultilingualController
**/
@isTest
public class TST_CNT_TPA_MultilingualController {
    @testSetup
    static void setupData() {
        UTL_TPA_SetupTestData.createCrossWalkData();
    }

    public static testMethod void testMultilingualControllerMethod() {
        Test.startTest();

        TPA_Language_Cross_Walk__c crossWalkObj3 = [SELECT id, Name, Object_Type__c, Control_Type__c, Default_Value__c, English_Translation__c, Japanese_Translation__c FROM TPA_Language_Cross_Walk__c LIMIT 1];

        CNT_TPA_MultilingualController objCtrl = new CNT_TPA_MultilingualController();
        objCtrl.getRecordId();
        objCtrl.getAllData();
        objCtrl.languageFieldApi = 'test1';
        objCtrl.isSorteable = true;
        objCtrl.isSearchAllowed = true;
        CNT_TPA_MultilingualController.getTPA_MultilingualEditorData('Japanese');
        CNT_TPA_MultilingualController.saveRecord(JSON.serialize(crossWalkObj3), JSON.serialize(crossWalkObj3));

        Test.stopTest();
    }
}