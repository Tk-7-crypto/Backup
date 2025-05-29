public class EXT_CSM_DataTableColumns {
    @AuraEnabled
    public String label {get;set;}
    @AuraEnabled       
    public String fieldName {get;set;}
    @AuraEnabled
    public String type {get;set;}
    @AuraEnabled
    public List<EXT_CSM_DataTableColumns> rowActions {get;set;}
    @AuraEnabled
    public EXT_CSM_DataTableColumns typeAttributes {get;set;}
    @AuraEnabled       
    public String name {get;set;}
    @AuraEnabled       
    public boolean sortable {get;set;}
    
    public EXT_CSM_DataTableColumns(){
        
    }
    //Create and set three variables label, fieldname and type as required by the lightning:datatable
    public EXT_CSM_DataTableColumns(String label, String fieldName, String type){
        this.label = label;
        this.fieldName = fieldName;
        this.type = type;            
    }
}