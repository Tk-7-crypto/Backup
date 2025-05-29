public class EXT_CSM_CheckboxDetails {
    public EXT_CSM_CheckboxDetails(String value,String label){
        this.value = value;
        this.label = label;
    }
    public EXT_CSM_CheckboxDetails(String value,String label,Boolean checked){
        this.value = value;
        this.label = label;
        this.checked = checked;
    }
    @AuraEnabled
    public String label{set; get;}
    @AuraEnabled
    public String value{set;get;}
    @AuraEnabled
    public Boolean checked{set;get;}
    @AuraEnabled
    public Boolean enableSubtype_1_2_3{get;set;}
    @AuraEnabled
    public Boolean subtypeMandatory{get;set;}
    @AuraEnabled
    public Boolean disableCSHP1CaseCreation{get;set;}
    @AuraEnabled
    public Boolean enableEscalationForm{get;set;}
    @AuraEnabled
    public Boolean attachmentMandatory{get;set;}
}