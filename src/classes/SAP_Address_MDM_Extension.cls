public with sharing class SAP_Address_MDM_Extension {

    public Address__c Address {get; set;}
    public SAP_Contact__c SAP_Contact {get; set;}
    
    public List<SAP_Contact__c> SAPContactList{get;set;}
    public Account Account {get; private set;}
    private BNF2__c BNF;
    private MIBNF_Component__c MIBNF_Comp;  // MIBNF : Added By Himanshu Parashar :: 23 nov 2011
    public Boolean RequestSubmitted {get; private set;}
    public Boolean ShowHeader {get; private set;}
    public Boolean ShowSidebar {get; private set;}
    public String Debug {get; private set;}
    public Boolean RequestSent{get;private set;}
    public User U {get; private set;}
    public Boolean LocalLanguageRendered {get;private set;}

    public List<SelectOption> getpaymentTerm() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('ZGR1','On Credit'));
        options.add(new SelectOption('ZB15','15 days'));
        options.add(new SelectOption('ZB20','20 days'));
        options.add(new SelectOption('ZB30','30 days'));
        options.add(new SelectOption('ZB45','45 days'));
        options.add(new SelectOption('ZB60','60 days'));
        options.add(new SelectOption('ZB63','63 days'));
        options.add(new SelectOption('ZB90','90 days'));
        options.add(new SelectOption('Z120','120 days'));
        options.add(new SelectOption('ZB97','Immediately Pay'));
        return options;
    }


    private Set<String> VAT_Mandatory_Countries = new Set<String>{'Austria','Belgium','Bulgaria','Cyprus','Czech Republic',
                'Denmark','Estonia','Finland','France','Germany','Greece','Hungary','Ireland',
                'Italy','Latvia','Lithuania','Luxembourg','Malta','Netherlands','Poland',
                'Portugal','Romania','Slovakia','Slovenia','Spain','Sweden','UK','Korea','Turkey'};          
                
    private Set<String> Addressline1_Mandatory_Countries = new Set<String>{'Turkey'};
    
    public SAP_Address_MDM_Extension()
    {
        SAPContactList=new List<SAP_Contact__c>();
        User U=new User();
        this.RequestSubmitted = false;
        this.ShowHeader = false;
        this.ShowSidebar = false;
        this.RequestSent=false;
        this.Debug = 'YYY';
        this.U = [select Id, Sales_Org__c, Sales_Org_Code__c,User_Country__c from User where Id = :userInfo.getUserId()];
        if (Apexpages.currentPage().getParameters().get('popup') == '0')
        {
            this.ShowHeader = true;
            this.ShowSidebar = true;
        }
        if (Apexpages.currentPage().getParameters().get('ApprovalRequest') != null)
        {
            this.ShowHeader = true;
            this.ShowSidebar = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'There are currently no addresses available for this account.  Please use the form below to submit a request for the creation of a new address in SAP.');
            ApexPages.addMessage(myMsg);
        }
        if ((Id)(Apexpages.currentPage().getParameters().get('Id')) == null)
        {
            this.Account = [select Id,Name,Region_Territory__c from Account where Id = :Apexpages.currentPage().getParameters().get('AccountId')];
            if(Apexpages.currentPage().getParameters().get('compId')!=null)
                this.MIBNF_Comp = [select Id, MIBNF__r.IMS_Sales_Org__c, MIBNF__r.Sales_Org_Code__c, MIBNF__r.Revenue_Analyst__r.User__r.Email,MIBNF__r.Revenue_Analyst__r.User__r.Id from MIBNF_Component__c where Id = :Apexpages.currentPage().getParameters().get('compId')];
            
            if (Apexpages.currentPage().getParameters().get('BnfAccountId') != null)
               this.BNF = [select Id, IMS_Sales_Org__c, Sales_Org_Code__c, Revenue_Analyst__r.User__r.Email,Revenue_Analyst__r.User__r.Id from BNF2__c where Id = :Apexpages.currentPage().getParameters().get('BnfId')];
        }
        else
        {
            this.Account = [select Id,Name from Account where Id = :this.Address.Account__c];
        } 
    
         Address = new Address__c();
         this.Address.Country__c = this.Account.Region_Territory__c;
         this.Address.Payment_Terms__c = 'ZB30';
         if(CON_GLOBAL.RELEASE_MAY_2021 > UTL_GLOBAL.getCurrentReleaseVersion()) {
            this.Address.RecordTypeId = Schema.SObjectType.Address__c.getRecordTypeInfosByDeveloperName().get('MDM_Validated').getRecordTypeId();
         }
         if(Apexpages.currentPage().getParameters().get('compId')!=null)
             this.Address.Sales_Org__c = this.MIBNF_Comp.MIBNF__r.IMS_Sales_Org__c + ' ['+ this.MIBNF_Comp.MIBNF__r.Sales_Org_Code__c +']';
         if (Apexpages.currentPage().getParameters().get('BnfAccountId') != null)
             this.Address.Sales_Org__c = this.BNF.IMS_Sales_Org__c + ' ['+ this.BNF.Sales_Org_Code__c +']';
        else
            this.Address.Sales_Org__c = U.Sales_Org__c + ' ['+ U.Sales_Org_Code__c +']';
    }
    
    
      public SAP_Contact__c getSAP_Contact()
      {
            if(SAP_Contact == null)
            {
                 SAP_Contact = new SAP_Contact__c();
                 SAP_Contact.Address__c=this.Address.id;
            }
            if(this.Address.Language__c != null) {
                SAP_Contact.Language__c = this.Address.Language__c;                  
            }
            
            return SAP_Contact;
       }
    
    //Called from Cancel Action   
    public pageReference ReturnToBnf()
    {
        pageReference retUrl;
        if (Apexpages.currentPage().getParameters().get('BnfAccountId') != null)
        {
            retUrl = new pageReference('/' + this.BNF.Id);
        }
        else if (Apexpages.currentPage().getParameters().get('retURL') != null)
        {
            retUrl = new pageReference('/' + Apexpages.currentPage().getParameters().get('retURL').replace('/',''));
        }
        else
        {
            retUrl = new pageReference('/' + this.Account.Id);
        }
        retUrl.setRedirect(true);
        return retUrl;
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
    
    //Send mail and 
    public PageReference SendNewRequestNotificationEmail() 
    {
            // If No Contact added already
            if(SAP_Contact.Last_Name__c==null && SAPContactList.size()==0)
            {
                 ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Last Name Required.');
                 ApexPages.addMessage(myMsg);
                 return null;
            }
            else if (SAP_Contact.Language__c != null && SAP_Contact.Last_Name_Local__c == null && SAPContactList.size()==0){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Last Name (Local) is required when Language is selected.');
                ApexPages.addMessage(myMsg);
                return null;
            }
            else
            {
                // Send Mail Request when user finish sending request
                this.RequestSent=true;
                if(SAP_Contact.Last_Name__c!=null)
                    AddSAPContact();
                SaveAddress();
                for(SAP_Contact__c  sapcontact: this.SAPContactList){
                    sapcontact.Address__c = this.address.Id;
                }
                if(this.SAPContactList.size() > 0){
                    insert SAPContactList;
                }
                if(CON_GLOBAL.RELEASE_MAY_2021 > UTL_GLOBAL.getCurrentReleaseVersion()) {
                    User Requestor = [select Id,Name,Email from User where Id = :UserInfo.getUserId()];
                    
                    UTL_CRM_SendEmail.MessageWrapper message = new UTL_CRM_SendEmail.MessageWrapper();
                    message.toEmails = new List<String>{MDM_Defines.MdmApprovalEmailAddress};
                    message.toUserIds = new List<Id>{Requestor.Id};
                    message.targetObjectId = Requestor.Id;
                    message.whatId = this.Address.Id;
                    List<EmailTemplate> emailTemplateList = new SLT_EmailTemplate().selectEmailDTemplateByDeveloperName(MDM_Defines.Email_Template_DevName_MDM_New_Address_Request_Wizard, new Set<String>{'Id'});
                    message.templateId = emailTemplateList[0].Id;
                    
                    
                    if(!(!Mulesoft_Integration_Control__c.getInstance().Is_Mulesoft_User__c && Mulesoft_Integration_Control__c.getInstance().Ignore_Validation_Rules__c)){
                       UTL_CRM_SendEmail.sendEmailThroughWorkflow(new List<UTL_CRM_SendEmail.MessageWrapper>{message});
                    }
                    //*****************************************************************************************
                    // Delete Temp Data after sending Mail
                    delete this.SAPContactList;
                    delete this.Address;
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'New contact request has been sent to MDM Helpdesk. You will be notified once the contact has been created in SAP.');
                    ApexPages.addMessage(myMsg);
                    this.RequestSubmitted = true; 
                }
                if(CON_GLOBAL.RELEASE_MAY_2021 <= UTL_GLOBAL.getCurrentReleaseVersion()) {
                    pageReference retUrl;
                    if (Apexpages.currentPage().getParameters().get('BnfAccountId') != null) {
                        retUrl = new pageReference('/' + this.BNF.Id);
                    } else if (Apexpages.currentPage().getParameters().get('retURL') != null) {
                        retUrl = new pageReference('/' + Apexpages.currentPage().getParameters().get('retURL').replace('/',''));
                    } else {
                        retUrl = new pageReference('/' + this.Address.Id);
                    }
                    retUrl.setRedirect(true);
                    return retUrl;
                }
                
            }
        return null;
        
        
    }
    
    public PageReference AddSAPContact()
    {
        // Insert SAP Contact Details
        if(SAP_Contact.Last_Name__c==null)
        {
             ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Last Name Required.');
             ApexPages.addMessage(myMsg);
             return null;
        }
        try
        {
            //insert SAP Contact;
            // Skip account null for Temp insertion of Address
            // Date : 13 March 2012
            Global_Variables.RunAddressRequestTrigger=false;
            if(CON_GLOBAL.RELEASE_MAY_2021 > UTL_GLOBAL.getCurrentReleaseVersion()) {
                SAP_Contact.Marked_For_Deletion__c=true;
            }
            
            //insert SAP_Contact;
            if(CON_GLOBAL.RELEASE_MAY_2021 > UTL_GLOBAL.getCurrentReleaseVersion()) {
                if(!this.RequestSent) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'New Contact request has been added. You can add more contact or you can click finish to submit your request to MDM Help desk.');
                    ApexPages.addMessage(myMsg);
                }
            }
            this.RequestSubmitted = true;
            SAPContactList.add(SAP_Contact.clone());
            SAP_Contact=null;
            getSAP_Contact(); 
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
    
    // Save Address Details
    public PageReference SaveAddress()
    {
        Boolean deleteAddress = false;
        string param = ApexPages.currentPage().getParameters().get('deleteAddress');
        if (param != null) {  
            deleteAddress =Boolean.valueOf(param);
        }
        Boolean hasError = false;
        if (this.Address.Address_Line_1__c == null && this.Address.PO_Box__c == null){
            this.Address.Address_Line_1__c.addError('Address Line 1 is Mandatory when the PO Box is blank.');
            hasError = true;
        }
        if (Address.Language__c != null && this.Address.Address_Line_1_Local__c == null && this.Address.PO_Box__c == null){
            this.Address.Address_Line_1_Local__c.addError('Address Line 1 (Local) is Mandatory when the PO Box is blank and Language is selected.');
            hasError = true;
        }
        if (this.Address.Name.length() > 70)
        {
            this.Address.Name.addError('Customer Name must be less than 70 characters');
            hasError = true;
        }
        if (VAT_Mandatory_Countries.contains(this.Address.Country__c) && 
            (this.Address.VAT_Registration_Number__c == null || this.Address.VAT_Registration_Number__c.length() == 0))
        {
            this.Address.VAT_Registration_Number__c.addError('VAT Registration Number is mandatory for addresses in ' + this.Address.Country__c);
            hasError = true;
        }
        
        if (Addressline1_Mandatory_Countries.contains(this.Address.Country__c) && 
            (this.Address.Address_Line_1__c == null || this.Address.Address_Line_1__c.length() == 0))
        {
            this.Address.Address_Line_1__c.addError('Address Line 1 is mandatory for addresses in ' + this.Address.Country__c);
            hasError = true;
        }
        Set<String> countryListForState = new Set<String>{'India','Australia','Brazil','Canada','New Zealand','USA'};
        if(this.Address.State__c == null && countryListForState.contains(this.Address.Country__c)){
            this.Address.State__c.addError('State/Region is required when Country = India, Australia, Brazil, Canada, New Zealand, or USA.');
            hasError = true;
        }
        
        Set<String> countryListForEmail = new Set<String>{'Malaysia','Mexico'};
        if(this.Address.Email__c == null && countryListForEmail.contains(this.Address.Country__c)){
            this.Address.Email__c.addError('Email is required when Country = Malaysia or Mexico.');
            hasError = true;
        }
        
        if(this.Address.Tax_Type__c == null && this.Address.Country__c == 'Argentina'){
            this.Address.Tax_Type__c.addError('Tax Type is required when Country is Argentina.');
            hasError = true;
        }
        Set<String> countryListForTaxNumber = new Set<String>{'Argentina','Bolivia','Brazil','Chile','Colombia','Ecuador','Guatemala','Mexico','Peru','Paraguay','Turkey','Uruguay','Venezuela'};
        if(this.Address.Tax_Number_1__c == null && countryListForTaxNumber.contains(this.Address.Country__c)){
            this.Address.Tax_Number_1__c.addError('Tax Number 1 is required when Country is Argentina, Bolivia, Brazil, Chile, Colombia, Ecuador, Guatemala, Mexico, Peru, Paraguay, Turkey, Uruguay, or Venezuela.');
            hasError = true;

        }
        if(this.Address.New_Sales_Org__c == '[SA01] IMS Saudi Arabia Limited' && this.Address.Language__c != 'AR'){
            this.Address.Language__c.addError(' Language should be Arabic [ar] when Sales Org = [SA01] IMS Saudi Arabia Limited.');
            hasError = true;
        }
        if (this.Address.International_Name__c != null && this.Address.International_Name__c.length() > 70)
        {
            this.Address.International_Name__c.addError('Customer Name (Local) must be less than 70 characters');
            hasError = true;
        }
        
        if(hasError){
            return null;
        }
        
        try
        {
            // Skip account null for Temp insertion of Address
            // Date : 13 March 2012
            Global_Variables.RunAddressRequestTrigger=false;
            this.Address.Account__c = this.Account.Id;
            if(CON_GLOBAL.RELEASE_MAY_2021 > UTL_GLOBAL.getCurrentReleaseVersion()) {
                this.Address.Marked_For_Deletion__c=true;
            }

            if(deleteAddress){
                Savepoint sp = Database.setSavepoint();
                //Address__c validateAddress =(Address__c)JSON.deserialize(JSON.serialize(this.address),Address__c.class);
                Address__c validateAddress = this.address.clone();
                upsert validateAddress;
                Database.rollback(sp);
            }
            else{
                upsert this.Address;
            }
            
            getSAP_Contact();
            RequestSubmitted=true;
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
    
    public PageReference SendNewAddressRequestNotificationEmail() 
    {
        SaveAddress();
        if(ApexPages.getMessages().size()==0)
        {
            this.RequestSent=true;
            if(CON_GLOBAL.RELEASE_MAY_2021 > UTL_GLOBAL.getCurrentReleaseVersion()) {
                User Requestor = [select Id,Name,Email from User where Id = :UserInfo.getUserId()];
                UTL_CRM_SendEmail.MessageWrapper message = new UTL_CRM_SendEmail.MessageWrapper();
                message.toEmails = new String[] {MDM_Defines.MdmApprovalEmailAddress};
                message.toUserIds = new List<Id>{Requestor.Id};
                message.targetObjectId = Requestor.Id;
                message.whatId = this.Address.Id;
                List<EmailTemplate> emailTemplateList = new SLT_EmailTemplate().selectEmailDTemplateByDeveloperName(MDM_Defines.Email_Template_DevName_MDM_New_Address_Request, new Set<String>{'Id'});
                message.templateId = emailTemplateList[0].Id;
                
                if(!(!Mulesoft_Integration_Control__c.getInstance().Is_Mulesoft_User__c && Mulesoft_Integration_Control__c.getInstance().Ignore_Validation_Rules__c)){
                    UTL_CRM_SendEmail.sendEmailThroughWorkflow(new List<UTL_CRM_SendEmail.MessageWrapper>{message});
                }
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'New address request has been sent to MDM Helpdesk. You will be notified once the address has been created in SAP.');
                ApexPages.addMessage(myMsg);
                
                this.RequestSubmitted = true;
                try
                {
                    delete this.Address;
                }
                catch(Exception e)
                {
                    // return null;   
                    ApexPages.Message myMsg2 = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
                    ApexPages.addMessage(myMsg2);
                    System.debug(e.getMessage());
                    return null;
                }
            }
            if(CON_GLOBAL.RELEASE_MAY_2021 <= UTL_GLOBAL.getCurrentReleaseVersion()) {
                    pageReference retUrl;
                    if (Apexpages.currentPage().getParameters().get('BnfAccountId') != null) {
                        retUrl = new pageReference('/' + this.BNF.Id);
                    } else if (Apexpages.currentPage().getParameters().get('retURL') != null) {
                        retUrl = new pageReference('/' + Apexpages.currentPage().getParameters().get('retURL').replace('/',''));
                    } else {
                        retUrl = new pageReference('/' + this.Address.Id);
                    }
                    retUrl.setRedirect(true);
                    return retUrl;
                }
        }
        
        
        return null;
    }
     
    public void DoNothing()
    {
        this.Debug += 'XXXXX';
    }   
   
    public pageReference GoBack()
    {
        return ReturnToBnf();
        /*pageReference retUrl = new pageReference('/' + this.Address.Id);
        retUrl.setRedirect(true);
        return retUrl;*/
    }
   
}