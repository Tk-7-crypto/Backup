public class EXT_CSM_CheckboxGroupDetails {
    public EXT_CSM_CheckboxGroupDetails(List<EXT_CSM_CheckboxDetails> checkboxList,String value){
        this.value=value;
        this.checkboxList=checkboxList;
    }
    @AuraEnabled
    public String value{set; get;}
    @AuraEnabled
    public List<EXT_CSM_CheckboxDetails> checkboxList{set;get;}
}