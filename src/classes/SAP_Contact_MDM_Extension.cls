public class SAP_Contact_MDM_Extension 
{
        public Address__c Address {get; private set;}
        public BNF2__c purchaseBNF {get; set;}
        public MIBNF_Component__c bnf {get; set;}
        public SAP_Contact__c SAP_Contact {get; set;}
        private ApexPages.StandardController StandardController;
        public Boolean RequestSubmitted {get; private set;}
        public Boolean ShowHeaderAndSidebar {get; private set;}
        public User CurrentUser {get;private set;}
        public boolean LocalLanguageRendered {get; private set;}
        public string SelectedLanguage {get; private set;}
        
        public SAP_Contact_MDM_Extension(ApexPages.StandardController controller)
        {
                this.StandardController = controller;
                this.Address = [select Id,Name,SAP_Reference__c,International_Name__c,Country__c, Language__c from Address__c where Id = :Apexpages.currentPage().getParameters().get('AddressId')];
            	ID bnfId = Apexpages.currentPage().getParameters().get('BnfId');
                ID cmpId = Apexpages.currentPage().getParameters().get('compId');
                if(bnfId != null){
                	this.purchaseBNF = [SELECT Id, IMS_Sales_Org__c FROM BNF2__c WHERE Id =: bnfId];
                } 
            	if(cmpId != null){
                	this.bnf = [SELECT Id, IMS_Sales_Org__c FROM MIBNF_Component__c WHERE Id =: cmpId];						  
                }
                this.SAP_Contact = (SAP_Contact__c)StandardController.getRecord();
                this.SAP_Contact.Language__c = Address.Language__c;
                if(purchaseBNF != null){
                	this.SAP_Contact.Sales_Org__c = purchaseBNF.IMS_Sales_Org__c;
            	} 
            	if(bnf != null){
                    this.SAP_Contact.Sales_Org__c = bnf.IMS_Sales_Org__c;
                }
                this.RequestSubmitted = false;
                this.ShowHeaderAndSidebar = false;
                if (Apexpages.currentPage().getParameters().get('popup') == '0')
                {
                        this.ShowHeaderAndSidebar = true;
                }
                this.CurrentUser = [select Id,User_Country__c from User where Id = :userInfo.getUserId()];
                if (this.Address.Language__c != null || this.Address.International_Name__c != null)
                {
                    this.SelectedLanguage = this.Address.Language__c;
                    this.LocalLanguageRendered = true;
                }
                else
                {
                    this.LocalLanguageRendered = false;
                }
        }
        
        public List<SelectOption> getTitles()
        {
            List<SelectOption> Titles = new List<SelectOption>();
            Schema.DescribeFieldResult fieldResult = SAP_Contact__c.Title__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            Titles.add(new SelectOption('',''));
            for( Schema.PicklistEntry f : ple)
            {
                Titles.add(new SelectOption(f.getLabel(), f.getValue()));
            } 
            return Titles;      
    }
        
    public PageReference SendNewContactRequestNotificationEmail() 
    {
        try
        {
            this.SAP_Contact.Address__c = this.Address.Id;
            upsert this.SAP_Contact;
            if(CON_GLOBAL.RELEASE_MAY_2021 > UTL_GLOBAL.getCurrentReleaseVersion()) {
                User Requestor = [select Id,Name,Email from User where Id = :UserInfo.getUserId()];
                
                UTL_CRM_SendEmail.MessageWrapper message = new UTL_CRM_SendEmail.MessageWrapper();
                message.toEmails = new List<String>{MDM_Defines.MdmApprovalEmailAddress};
                    message.toUserIds = new List<Id>{UserInfo.getUserId()};
                        message.targetObjectId = UserInfo.getUserId();
                message.whatId = this.SAP_Contact.Id;
                List<EmailTemplate> emailTemplateList = new SLT_EmailTemplate().selectEmailDTemplateByDeveloperName(MDM_Defines.Email_Template_DevName_MDM_New_SAP_Contact_Request, new Set<String>{'Id'});
                message.templateId = emailTemplateList[0].Id;
                
                
                if(!(!Mulesoft_Integration_Control__c.getInstance().Is_Mulesoft_User__c && Mulesoft_Integration_Control__c.getInstance().Ignore_Validation_Rules__c)){
                    UTL_CRM_SendEmail.sendEmailThroughWorkflow(new List<UTL_CRM_SendEmail.MessageWrapper>{message});
                }
                
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'New contact request has been sent to MDM Helpdesk. You will be notified once the contact has been created in SAP.');
                ApexPages.addMessage(myMsg);
                this.RequestSubmitted = true;
                delete this.SAP_Contact;
            }
            if(CON_GLOBAL.RELEASE_MAY_2021 <= UTL_GLOBAL.getCurrentReleaseVersion()) {
                pageReference retUrl = new pageReference('/' + this.Address.Id);
                retUrl.setRedirect(true);
                return retUrl;
            }
            return null;
        }
        catch(Exception e) 
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
            ApexPages.addMessage(myMsg);
            System.debug(e.getMessage());
            return null;
        }
    }
    
    public pageReference GoBack()
    {
                pageReference retUrl = new pageReference('/' + this.Address.Id);
                retUrl.setRedirect(true);
                return retUrl;
    }
}