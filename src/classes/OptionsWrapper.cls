/**
 * class stores the label and value combination
 */
public class OptionsWrapper {
    @AuraEnabled public String label {get; set;}
    @AuraEnabled public String value {get; set;}

    public OptionsWrapper(String label, String value) {
        this.label = label;
        this.value = value;
    }
}