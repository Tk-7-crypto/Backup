public class BNFAttachmentController {
    
    public transient blob fileContent{get; set;}
    public transient String fileName {get; set;}
    public transient String fileContentType {get; set;}
    public transient Integer fileSize {get; set;}
    
    public transient String selDocType {get; set;}
    
    public List<SelectOption> docTypeOptions {get; private set;}
    public List<UploadFileWrapper> fileList {get; private set;}
    
    public Id bnfId{get; private set;}
    public String retUrl {get; private set;}
    
    Map<String, BNF_Attachment_Type__c> docTypeMap = BNF_Attachment_Type__c.getAll();
    
    public BNFAttachmentController () {
        docTypeOptions = new List<SelectOption> ();
        
        List<String> docTypeListTemp = new List<String>();
        docTypeListTemp.addAll(docTypeMap.keySet());
        docTypeListTemp.sort();
        
        for(String v : docTypeListTemp) {
            docTypeOptions.add(new SelectOption(v,docTypeMap.get(v).label__c));
        }        
        docTypeOptions.add(new SelectOption('', ''));
        selDocType = '';
        
        bnfId = ApexPages.CurrentPage().getParameters().get('id');//controller.getId();
        retUrl = ApexPages.CurrentPage().getParameters().get('returl');
    }
    
    public PageReference Save(){
        
        Boolean isError = false;
        
        //START - check input 
        if(fileSize == null && fileName == null && fileContentType == null ) {
            isError = true;           
        }
        
        /* No need to check file size, vf component checks this and returns error
        */
        
        if(fileName == null || fileName  == '') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please select a file.'));
            isError = true;          
        }
        
        
        if(selDocType == null || selDocType == '' ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please select doucment type for file.'));
            isError = true;            
        }
        
        if(isError) {
            selDocType = '';
            return null;
        }              
        
        //END - check input 
        
        Attachment doc = new Attachment(
                ParentId = bnfId,
                Body = fileContent,
                Name = selDocType + FileName,
                ContentType = fileContentType );  
        try {
            insert doc; 
        } catch(Exception ex) {
            selDocType = ''; 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ex.getMessage()));
            return null;
        }       
        
        if(fileList == null) fileList = new List<UploadFileWrapper>();        
        fileList.add(new UploadFileWrapper(FileName,docTypeMap.get(selDocType).label__c  ) );  
        selDocType = '';
        return null;
    }
   
   class UploadFileWrapper {
       public String fileName {get; set;}
       public string fileType {get; set;}
       
       public UploadFileWrapper (String fName, String fType){
           fileName = fName;
           fileType = fType;
       }
       
       
   }  
}