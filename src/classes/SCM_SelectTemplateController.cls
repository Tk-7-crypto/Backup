public class SCM_SelectTemplateController{

    //public Contract_Management_Setting__c contractSetting;
    public Contract_Management_Setting__c contractSetting{get; set;}
    public String selectedFormat{get;set;}
    public List<templateWrapper> templateWrpList{get;set;}
    public String tempId{get;set;}
    public String sessionId{get;set;}
    public String serverUrl{get;set;}
    public integer docSize {get; set;}
    public Attachment atch{get; set;}
    public Boolean hasDocGenerated{get; set;}
    
    //Added by dhruv : Issue - 09826 : Date 28-10-2016 
    public Attachment atchAddendum{get; set;}
    //Ended by dhruv : Issue - 09826 : date 28-10-2016
    Public Id docId;
    //Added By sweta Details:ER-2884 Date:04/07/2016
    public Boolean isForOpportunity {get;set;}
    //It is boolean variable to store is it for preview action
    public Boolean isPreview{get; set;} 
    //Document to only show to user in case of preview 
    public Document document {
        get {
          if (document == null)
            document = new Document();
          return document;
        }
        set;
    }
    public boolean hasError {get; set;}
    public Agreement__c agreement{get;set;}
    public Opportunity Opportunity {get;set;}
    public String AgreementType;
    public User objUser;
    public Boolean isSalesuser{get;set;}
    Boolean isContractUser;
    Boolean isSystemAdmin;
    Id OpportunityId,AggreementId;
    public String userPermission='';
	public boolean isRapidSOWUsedBySales{get;set;}
	
    public List<SelectOption> getOutputFormatList(){
            List<SelectOption> options = new List<SelectOption>();
            if(isSystemAdmin || isContractUser)
                options.add(new SelectOption('DOC','DOC'));
            if(isSystemAdmin)
                options.add(new SelectOption('RTF','RTF'));
            options.add(new SelectOption('PDF','PDF'));
            return options;
    }

    public SCM_SelectTemplateController() {
        contractSetting = Contract_Management_Setting__c.getInstance();
        hasError=false ;
        isSalesuser = false;
        isContractUser = false;
        isSystemAdmin = false;
        userPermission = ''; 
        AgreementType = '';
        this.objUser = ConstantClass.getUserDetails().get(0);
        if(objUser != Null)   
            userPermission = ConstantClass.permissionSetUser(ObjUser.Profile.Name , objUser.PermissionSetAssignments);
        if( ObjUser.Profile.Name != Null && ObjUser.Profile.Name.toLowerCase().contains('system admin'))
            isSystemAdmin = true;
        else if(userPermission == 'author')
            isContractUser = true;
        else if(userPermission  == 'sales')
            isSalesuser = true;
        if(isSalesuser || ObjUser.Profile.UserLicense.Name == 'Salesforce Platform' )
            selectedFormat ='PDF';
        else
            selectedFormat ='DOC';
        //Ended By sweta Details:7145 Date:19/05/2015
        hasDocGenerated = false;
        if(ApexPages.currentPage().getParameters().get('AgreementType') != Null)
            AgreementType = ApexPages.currentPage().getParameters().get('AgreementType');
        //Added  By sweta Details:ER-2884 Date:04/07/2016 
        /*********************Start ER-2884*********************************/
        if(ApexPages.currentPage().getParameters().get('Id') != null &&  AgreementType == 'OpportunityDocument') {
            OpportunityId = ApexPages.currentPage().getParameters().get('Id');
            isForOpportunity = true;
            Opportunity = [Select id,name from Opportunity where id =: OpportunityId ];
        
        }
        templateWrpList = new List<templateWrapper>();
        //added by dhruv : Issue-09348: ER 2834 : date 19-08-2015
        //Updated by dhruv : Issue 09352 : Date 22-08-2016 : Added opportunity check
        //if(agreement!=null && agreement.recordTypeID!=null &&  (agreement.recordTypeID !=contractSetting.Rapid_SOW__c || !isSalesuser))
        if(Opportunity!=null || (agreement!=null && agreement.recordTypeID!=null &&  (agreement.recordTypeID != contractSetting.Rapid_SOW__c || !isSalesuser)))
            searchTemp();
    }
    
    //ended by dhruv : Issue-09348 : ER 2834 : date 19-08-2015
    public void searchTemp()
    {
        try{
            //Added  By sweta Details:ER-2884 Date:04/07/2016 
            /*********************Start*********************************/
            if(AgreementType != null && AgreementType == 'OpportunityDocument') {
                List<Apttus__APTS_Template__c> templateList = new List<Apttus__APTS_Template__c>();
                //Updated By sweta Details:ER - 3174 Date:28/10/2016 :: added order by clause 
                templateList = [Select Name from Apttus__APTS_Template__c where Apttus__IsActive__c = true and Apttus__Type__c = 'Agreement' and Apttus__BusinessObject__c ='Opportunity' ORDER BY Display_Order__c]; 
                Apttus__APTS_Template__c template1 ;
                for(Apttus__APTS_Template__c s : templateList  ) {
                    template1 = (Apttus__APTS_Template__c)s;
                    templateWrpList.add(new templateWrapper(template1.Name,template1.Id));
                }
                return;
            }
        } catch(Exception e) {
             hasDocGenerated = false;
             //Added By Dhruv : Issue-07824 : Added Field to check error 
             hasError=true ;
             ApexPages.addMessages(e) ; 
        }
        
    }
    
    public void generate()
    {
         try {    
            //added By sweta Details:ER-2834 Date:26/07/2016
            Id templateId = tempId; 
            String templateName ;
            //Added by Dhruv: Issue 7824 : Date 17-6-2015 : field to store whether to update agreement or not
            Boolean isAggToUpdate=false ;  
            //Id docId;
            hasDocGenerated = true;
            if(AgreementType == 'OpportunityDocument') {
                docId = null;
                Opportunity opp = new Opportunity();
                opp = [SELECT Id FROM Opportunity WHERE id=:OpportunityId LIMIT 1];
                Apttus__APTS_Template__c templates = new Apttus__APTS_Template__c();
                //Added By sweta Issue-11277 
                if(!Test.isRunningTest()) {
                    docId = Apttus.MergeWebService.generateCustomDoc(templateId,OpportunityId,'Opportunity','Full access', 'Doc',false,sessionId,serverUrl);   
                    //Added By sweta Issue-11277 
                }
                List<Attachment> lstAtt = new List<Attachment>();
                if(docId != Null) {
                    //Get attachment we got from webservice   
                    lstAtt = [Select Id,Body,Name,ContentType,BodyLength from Attachment where id =:docId]; 
                    if(lstAtt != Null && lstAtt.size() != 0) {
                        atch = lstAtt[0];
                    }
                }
                if(lstAtt == Null || lstAtt.size() == 0) {
                    Set<String> fieldSet = new Set<String>{'Title', 'PathOnClient', 'VersionData', 'ContentDocumentId', 
                        'FileExtension'};
                    List<ContentVersion> cVersionList = new SLT_ContentVersion().getContentVersionByDocumentIds(new Set<Id>
                        {docId}, fieldSet);
                    if(cVersionList != null && cVersionList.size() > 0) {
                        blob fileBody = cVersionList[0].versiondata;
                        Attachment attach = new Attachment();
                        attach.Body = fileBody;
                        attach.IsPrivate = false;
                        attach.ParentId = OpportunityId;
                        attach.Name = cVersionList[0].title;
                        try {  
                            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType>{
                                Attachment.SObjectType, ContentDocument.SObjectType});
                            uow.registerNew(attach);
                            uow.registerDeleted(new ContentDocument(Id = docId));
                            uow.commitWork();
                        } 
                        catch(DMLException dmlExp) {
                            System.debug(System.LoggingLevel.ERROR, dmlExp.getMessage() + ' \n ' + dmlExp.getStackTraceString());
                        }     
                        atch = attach;
                    }
                }
                return ;
            }
            //Global_Variables.RenewalCloneFlag = true;
            List<Task> taskList = [SELECT Id, Subject FROM Task WHERE whatid = :agreement.Id order by CreatedDate desc limit 1];
            
            if(taskList.size() > 0 && taskList[0] != null  ) {
                if(isPreview!=null && isPreview) {
                    taskList[0].Subject = 'Previewed Agreement';
                    update taskList ;
                }
                else if(agreement.Is_Document_Generated__c == true && AgreementType == 'Agreement') {
                    taskList[0].Subject = 'Regenerated Agreement';
                    update taskList ;
                }
            }
            
            if(agreement.Is_Document_Generated__c && agreement.RecordTypeId != contractSetting.Rapid_SOW__c && atch != null) { 
                   atch.Name = atch.Name.replace('_Original_','_Regenerated_') ;
                   update atch ;
            }
            if(agreement.Is_Document_Generated__c == false && AgreementType == 'Agreement') {
                agreement.Is_Document_Generated__c = true;
                isAggToUpdate=true ;
            }
            //Added By Dhruv : Issue-07824 : 16-9-2015: If flag is true and external global client SOW generated then set flag false
            if(agreement!=NULL && agreement.RenerateSOWDocAfterChangeMasterAgg__c && AgreementType == 'Agreement' && atch!=NULL &&  atch.Name.contains(System.Label.SCM_Template_For_ER459)) {
                agreement.RenerateSOWDocAfterChangeMasterAgg__c = false;
                isAggToUpdate=true ;
            }
        if(isAggToUpdate)
            update agreement;
        //Ended By Dhruv : Issue-07824 : 16-9-2015: 
        //Global_Variables.RenewalCloneFlag = false;
        } catch(Exception e) {
            //Added By Dhruv : Issue-07824 : Added Field to check error 
            hasError=true ;
            if(e.getMessage().contains('Attachment creation failed.'))
                e.setMessage('You have not permission to preview/generate on this agreement');
            //Ended By Dhruv : Issue-07824 : Added Field to check error 
            hasDocGenerated = false;
            ApexPages.addMessages(e) ; 
        }
    }
    
    public void deleteDocument()
    {
        if(document !=null && document.ID !=null){
            delete document ;
        }
    } 

    public class templateWrapper{
    
        public String tempName{get;set;}
        public String guidance{get;set;}
        public String category{get;set;}
        public String subcategory{get;set;}
        public String Id{get;set;}
        public templateWrapper(){}

        public templateWrapper(String Name,String temId) {
            this.tempName = Name;
            this.Id = temId;
            guidance = '';
            category = '';
            subcategory = '';
        }
    }
}