@isTest(seeAllData = false)
public class TST_SCH_TPA_Agreement_UpdateStatus { 
    public static testMethod void testSCH_TPA_Agreement_UpdateStatus(){
        TPA_TP_Processor__c tpProcessor = new TPA_TP_Processor__c(TP_Processor_Name__c = 'US TP Proccessor',
                                                                  TP_Processor_Email__c = 'test@test.com'); 
        insert tpProcessor;
        
        TPA_Region_Country__c tpaRegionCountry = new TPA_Region_Country__c(Country__c = 'United States', TP_Processor__c = tpProcessor.id);
        insert tpaRegionCountry;

        TPA_Country_Codes__c tpaCountryCode = new TPA_Country_Codes__c();
        tpaCountryCode.Name = 'United states';
        tpaCountryCode.Country_Possible_Codes__c = 'US,u.s.';
        tpaCountryCode.Name = 'C';
        insert tpaCountryCode;
        
        UTL_TPA_SetupTestData.createMultilingualTemplateSettingData();
        UTL_TPA_SetupTestData.createTpaTestEditorData('Pending TPA Req Report Frequency', 'Mon;Tue;Wed;Thu;Fri;Sat;Sun', 'Pending TPA Req Report Frequency', 'Report Frequency');
        UTL_TPA_SetupTestData.createTpaTestEditorData('Country Offering workbook Report', 'Mon;Tue;Wed;Thu;Fri;Sat;Sun', 'Country Offering workbook Report', 'Report Frequency');

        SCH_TPA_Agreement_UpdateStatus.sendPendingTPARequestsReport();
        SCH_TPA_Agreement_UpdateStatus.sendCountryOfferingWorkbookReport();
        
        SCH_TPA_Agreement_UpdateStatus.start();
    }
}