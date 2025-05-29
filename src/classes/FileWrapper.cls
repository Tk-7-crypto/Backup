public class FileWrapper {
    @AuraEnabled
    public String title {get; set;}
    @AuraEnabled
    public String id {get;set;}
    @AuraEnabled
    public String conVerId {get;set;}
    
    public FileWrapper() {
        
    }
    
    public FileWrapper(String title, String id, String conVerId) {
        this.title = title;
        this.id = id;
        this.conVerId = conVerId;
    }
}