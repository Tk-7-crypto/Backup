public class EXT_CSM_DataTableResponse {
    @AuraEnabled
    public List<EXT_CSM_DataTableColumns> lstDataTableColumns {get;set;}
    @AuraEnabled
    public List<sObject> lstDataTableData {get;set;}                
    
    public EXT_CSM_DataTableResponse(){
        lstDataTableColumns = new List<EXT_CSM_DataTableColumns>();
        lstDataTableData = new List<sObject>();
    }
}