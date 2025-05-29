public class EXT_CSM_Message {
    public EXT_CSM_Message(String title,String severity,String message){
        this.title=title;
        this.severity=severity;
        this.message=message;
    }
    @AuraEnabled
    public String title {set;get;}
    @AuraEnabled
    public String severity {set;get;}
    @AuraEnabled
    public String message {set;get;}
}