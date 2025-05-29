public class SCM_BNFEditRedirectController 
{

    public String newRedirectionFullURL{get; private set;}
    public String orgDomainURL{get;private set;}
    public SCM_BNFEditRedirectController()
    {
        onLoadRedirection();
    } 

    public void onLoadRedirection()
    {
        Map<string, string> urlParameterMap = new MAp<string, string>();
        orgDomainURL = URL.getOrgDomainUrl().toExternalForm();
        urlParameterMap  = ApexPages.currentPage().getParameters();
        String newRedirectionURL = ApexPages.currentPage().getParameters().get('newURL');
        Boolean needDecoding = true;
        if(newRedirectionURL.containsIgnoreCase('BNF_Sales_Org_Selector')) {
            needDecoding = false;
            orgDomainURL = '';
        }  
        string baseURL = '';
        Map<String, String> fieldApiToIdmap = UTL_Sobject.getCustomFieldByIds('BNF2');
        Map<Id, Opportunity> oppMapWithAgreements = new map<id, Opportunity>(); 
        string oppId = ((!string.isBlank(newRedirectionURL)&& newRedirectionURL.contains('=') && newRedirectionURL.split('=').size()>1)?  (newRedirectionURL.split('=')[1].contains('/')? newRedirectionURL.split('=')[1].remove('/') : newRedirectionURL.split('=')[1]) : '' ); 
        Contract_Management_Setting__c contractSetting = Contract_Management_Setting__c.getInstance();
        
        if(!string.isBlank(OppId) && ConstantClass.allowSalesOrgUpdateOnBNF_FromSCM && contractSetting != null && contractSetting.Allow_SalesOrg_Update_In_BNF_From_SCM__c)
        {
            oppMapWithAgreements = new map<id, Opportunity>([SELECT Id, (SELECT Id,IMS_Legal_Entity__c FROM Proxy_SCM_Agreements__r where Record_Type_Name__c = : contractSetting.SOW__c and is_Amendment_Record__c = false ) FROM Opportunity where id = : oppId]);
            if(oppMapWithAgreements.size() > 0 )
            {
                map<string, string> salesCodetoSalesOrgNameInBNFMap = ConstantClass.getSalesOrgNameinBNFSystem1('Purchase BNF');
                string IMSSalesOrgCode = '';
                string legalEntity = '';
                
                //Get legal entity of agreement based on opportunity
                legalEntity =  ConstantClass.checkAgreementLegalEntityForOpportunity(oppId, oppMapWithAgreements);             
                //get sales org code based on legal entity
                IMSSalesOrgCode = ConstantClass.getSalesOrgCodeforAgreementLegalEntity(legalEntity);
                
                //set Sales org name and code on BNF   
                if( salesCodetoSalesOrgNameInBNFMap != null && !string.isblank(IMSSalesOrgCode) && salesCodetoSalesOrgNameInBNFMap.containsKey(IMSSalesOrgCode))
                {
                    urlParameterMap.put(fieldApiToIdmap.get('IMS_Sales_Org__c'), salesCodetoSalesOrgNameInBNFMap.get(IMSSalesOrgCode));
                }
            }
        }
        
        if(!string.isBlank(newRedirectionURL))
        {
            newRedirectionFullURL  = newRedirectionURL;
            //Boolean isIQVIAGB80 = false;
            String multiBillingCountry = '';
            for(string urlParam : urlParameterMap.keySet())
            {
                /*
                if(urlParam == 'isIQVIAGB80' && urlParameterMap.get(urlParam) == 'true') {
                    isIQVIAGB80 = true;
                }
                */
                if(urlParam == 'multiBillingCountry' && urlParameterMap.get(urlParam).length() > 0) {
                    multiBillingCountry = urlParameterMap.get(urlParam);
                }
                if(urlParam != 'newURL' && urlParameterMap.get(urlParam) != '' && urlParameterMap.get(urlParam) != 'undefined')
                {
                    if(needDecoding && urlParam.contains('__c')) {
                        newRedirectionFullURL += '&' + fieldApiToIdmap.get(urlParam) + '=' + EncodingUtil.urlEncode(urlParameterMap.get(urlParam), 'UTF-8'); 
                    } else {
                    	newRedirectionFullURL += '&' + urlParam + '=' + EncodingUtil.urlEncode(urlParameterMap.get(urlParam), 'UTF-8'); 
                	}
                }
            }
            /*
            if(isIQVIAGB80) {
                newRedirectionFullURL += '&' + fieldApiToIdmap.get('IMS_Sales_Org__c') + '=' + EncodingUtil.urlEncode('[GB80] IQVIA Ltd', 'UTF-8');
            } 
           */
            if(multiBillingCountry.length() > 0 && multiBillingCountry == 'IQVIA Operations France – FR12') {
                 newRedirectionFullURL += '&' + fieldApiToIdmap.get('IMS_Sales_Org__c') + '=' + EncodingUtil.urlEncode('[FR12] IQVIA Operations France SAS', 'UTF-8');
            }
            
            if(multiBillingCountry.length() > 0 && multiBillingCountry == 'IQVIA Ltd GB80 engagement') {
                 newRedirectionFullURL += '&' + fieldApiToIdmap.get('IMS_Sales_Org__c') + '=' + EncodingUtil.urlEncode('[GB80] IQVIA Ltd', 'UTF-8');
            }
        }
    }

}