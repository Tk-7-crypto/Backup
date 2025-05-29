@isTest
private class TST_SCH_TPA_Send_AMA_Report_Annualy { 
    static testMethod void testScheduler() {
      
        TPA_AMA_Settings__c amaSettingObj = new TPA_AMA_Settings__c();
        amaSettingObj.Name = 'Custom Setting';
        amaSettingObj.TP_US_Email_Id__c = 'test@test.com';
        amaSettingObj.TPA_AMA_Annual_Report__c = 'TPA_AMA_Annual';
        insert amaSettingObj;
      
        String CRON_EXP = '0 0 0 3 9 ? ' + (Date.Today().year() + 1);
        Test.startTest();
        System.schedule('test Schedule', CRON_EXP, new SCH_TPA_Send_AMA_Report_Annualy());
        Test.stopTest();
    }

}