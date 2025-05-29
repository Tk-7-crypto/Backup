@isTest
public class TST_UTL_PicklistEntryWrapper {
    static testmethod void testGetListOfRequiredFields() {
        Test.startTest(); 
        UTL_PicklistEntryWrapper upl = new UTL_PicklistEntryWrapper();
        upl.active = '';
        upl.defaultValue = '';
        upl.label = '';
        upl.value = '';
        upl.validFor = '';
        Test.stopTest();
    }
}