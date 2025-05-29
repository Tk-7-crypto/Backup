@isTest
private class TST_EXT_CSM_CheckboxGroupDetails {
    testmethod static void createEXT_CSM_CheckboxGroupDetails(){
        List<EXT_CSM_CheckboxDetails> listcheck = new List<EXT_CSM_CheckboxDetails>();
        listcheck.add(new EXT_CSM_CheckboxDetails('value1','label1',true));
        listcheck.add(new EXT_CSM_CheckboxDetails('value2','label2',false));
       EXT_CSM_CheckboxGroupDetails groupDtls = new EXT_CSM_CheckboxGroupDetails(listcheck,'value1,value2');
    }
}