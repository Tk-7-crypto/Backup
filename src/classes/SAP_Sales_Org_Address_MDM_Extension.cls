public with sharing class SAP_Sales_Org_Address_MDM_Extension {
    
    public Address__c Address {get; private set;}
    private ApexPages.StandardController StandardController;
    public Boolean RequestSubmitted {get; private set;}
    public Boolean ShowHeaderAndSidebar {get; private set;}
    public String salesOrg;
    public Boolean RequestFailed {get; private set;}
    
    public SAP_Sales_Org_Address_MDM_Extension(ApexPages.StandardController controller) {
        this.StandardController = controller;
        this.Address = [select Id, Name, SAP_Reference__c, New_Sales_Org__c, Account__r.Name, CreatedBy.Name, CreatedBy.Email from Address__c where Id = :Apexpages.currentPage().getParameters().get('AddressId')];
        salesOrg = this.Address.New_Sales_Org__c;
        this.RequestSubmitted = false;
        this.RequestFailed = false;
        this.ShowHeaderAndSidebar = false;
        if (Apexpages.currentPage().getParameters().get('popup') == '0') {
            this.ShowHeaderAndSidebar = true;
        }
    }
    
    public PageReference sendNewSalesOrgRequestNotificationEmail() {
        try {
            BNF_Settings__c bnfSetting = BNF_Settings__c.getInstance();

            String strSaleOrgJson = jsonGenerateSaleOrgAPI();
            if(strSaleOrgJson != null) {
                HttpRequest req = new HttpRequest();
                req.setEndpoint('callout:Sale_Org_Ext');
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/json');
                req.setBody(strSaleOrgJson);
    
                Http http = new Http();
                HTTPResponse response = http.send(req);
    
                if (response.getStatusCode() == 201) {  
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'New Sales Org request has been sent to MDM Helpdesk.');
                    ApexPages.addMessage(myMsg);
                    this.RequestSubmitted = true;
                } else {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Dear user, we apologize for inconvenience. There was an unexpected error that prevents this extension to be requested from SFDC.'+
                        '<br/>Please raise a ticket to GFSS SAP CUSTOMER group on this link: <a href="https://quintiles.service-now.com/via?id=sc_cat_item&sys_id=4b0859dddb28c8107cf37e77f4961900">GFSS MDM VIA Request</a>'+
                        '<br/><br/>Please provide this information to ticket.'+
                        '<br/>Dataset – Customer, Category – Sap Customer, Sub Category – Address extension'+
                        '<br/>Description : Customer code, Sales org code, and any other additional info you need.');
                    ApexPages.addMessage(myMsg);
                    this.RequestFailed = true;
                }
            }
            return null;
        } catch(Exception e) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
            ApexPages.addMessage(myMsg);
            System.debug(e.getMessage());
            return null;
        }
    }
    
    public pageReference goBack(){
        pageReference retUrl = new pageReference('/' + this.Address.Id);
        retUrl.setRedirect(true);
        return retUrl;
    }

    public string jsonGenerateSaleOrgAPI() {
        String strJson = '';
        // Create a JSONGenerator object
        JSONGenerator jsGen = JSON.createGenerator(true);
        // start object ({)
        jsGen.writeStartObject();
        jsGen.writeFieldName('content');
        jsGen.writeStartObject();
        
        jsGen.writeFieldName('requestStatus');
        jsGen.writeStartObject();
        jsGen.writeStringField('content', 'READY');
        jsGen.writeEndObject();
        
        jsGen.writeFieldName('salesOrganization');
        jsGen.writeStartObject();
        jsGen.writeStringField('content', this.Address.New_Sales_Org__c);
        jsGen.writeEndObject();
        
        jsGen.writeFieldName('sapAddressId');
        jsGen.writeStartObject();
        jsGen.writeStringField('content', this.Address.SAP_Reference__c);
        jsGen.writeEndObject();
        
        jsGen.writeFieldName('enabledForEmailInvoicing');
        jsGen.writeStartObject();
        jsGen.writeBooleanField('content', false);
        jsGen.writeEndObject();
        // end object (})
        jsGen.writeEndObject();
        jsGen.writeEndObject();
        strJson = jsGen.getAsString();

        if(!String.isBlank(strJson)) {
            return strJson;
        }
        else {
            return null;
        }
    }
}
