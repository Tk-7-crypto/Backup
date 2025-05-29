@isTest
private class TST_EXT_CSM_CheckboxDetails {

    @IsTest
    private static void createCheckboxDetails(){
        EXT_CSM_CheckboxDetails dtls = null;
        dtls = new EXT_CSM_CheckboxDetails('value1','label1',true);
        dtls = new EXT_CSM_CheckboxDetails('value2','label2',false);
        EXT_CSM_CheckboxDetails details = null;
        details = new EXT_CSM_CheckboxDetails('value1','label1');
        details.enableSubtype_1_2_3 = true;
        details.subtypeMandatory = true;
        details.disableCSHP1CaseCreation = true;
        details.attachmentMandatory = true;
        System.assertNotEquals(details, null, 'WRP_CSM_SearchResult is null');
    }
}