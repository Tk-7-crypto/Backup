/**
* Created by Ronak Mehta on 19-Jun-2023
* Description : Contain common Methods to support LWC componet: lwcCrmRequestNewEinvoicing
*/
public with sharing class CNT_CRM_RequestNewEinvoicing {
    
    /**
     * This Method to return basic data to render lwc like address, available sales org, existing validated sap Contact
     * @params Id recordId
     * @return Map<String, Object>
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> fetchBaseData(Id recordId){
        Map<String, Object> returnMap = new Map<String, Object>();
        List<Map<String,String>> salesOrgOptions = new List<Map<String,String>>();
        salesOrgOptions.add(new Map<String,String> {'label' => '--None--', 'value'=> ''});
        List<Map<String,String>> sapContactOptions = new List<Map<String,String>>();
        sapContactOptions.add(new Map<String,String> {'label' => '--None--', 'value'=> ''});
        
        Set<String> addFieldSet = new Set<String>{'Id', 'Name', 'SAP_Reference__c', 'Enabled_Sales_Orgs__c'};
            String addCondition = ' Id = \''+ recordId + '\' ';
        Set<String> sapConFieldSet = new Set<String>{'Id', 'Name', 'SAP_Contact_Number__c'};
            String sapConCondition = ' Marked_For_Deletion__c = false AND SAP_Contact_Number__c != null AND Email__c != null AND RecordTypeId = \''+CON_CRM.Validated_SAP_Contact_RecordId + '\' ';
        Address__c address = new SLT_Address().getAddressWithValidateSapContact(addFieldSet, addCondition, sapConFieldSet, sapConCondition)[0];
        returnMap.put('address',address);
        
        if(address.Enabled_Sales_Orgs__c != null){
            Map<String,String> codeToSalesOrgMap = new Map<String,String>();
            for( Schema.PicklistEntry pickListVal : MDM_Invoicing_Transaction__c.Sales_Org__c.getDescribe().getPicklistValues()){
                codeToSalesOrgMap.put(pickListVal.getValue(), pickListVal.getLabel());
            }
            for(String eso : address.Enabled_Sales_Orgs__c.split(':')){
                if(codeToSalesOrgMap.containskey(eso)){
                    salesOrgOptions.add(new Map<String,String> {'label' => codeToSalesOrgMap.get(eso), 'value' => codeToSalesOrgMap.get(eso)});
                }
            }
        }
        returnMap.put('salesOrgOptions',salesOrgOptions);
        
        for(Sap_Contact__c sapContact: address.SAP_Contacts__r){
            sapContactOptions.add(new Map<String,String> {'label' => sapContact.Name, 'value' => sapContact.Id});
        }
        returnMap.put('sapContactOptions',sapContactOptions);
        
        Set<String> mdmFieldSet = new Set<String>{'SAP_Contact_1__c', 'SAP_Contact_2__c', 'SAP_Contact_3__c'};
            String mdmCondition = ' Marked_For_Deletion__c = false AND Address__c = \'' + recordId + '\'';
        Map<String,MDM_Invoicing_Transaction__c> salesOrgToInvoiceMap = new Map<String,MDM_Invoicing_Transaction__c>();
        for(MDM_Invoicing_Transaction__c mdt: new SLT_MDM_Invoicing_Transaction().getInvoiceByCondition(mdmFieldSet, mdmCondition)){
            salesOrgToInvoiceMap.put(mdt.Sales_Org__c,mdt);
        }
        returnMap.put('salesOrgToInvoiceMap',salesOrgToInvoiceMap);
        
        return returnMap;
    }
    
    /**
     * Method to submit request to EBEX system for Enable sap contacts for sales org.
     * @params MDM_Invoicing_Transaction__c invoiceRec
     * @params Address__c addressRec
     * @return Map<String, Object>
     */
    @AuraEnabled(cacheable=false)
    public static Map<String, Object> submitEinvoicingViaAPI(MDM_Invoicing_Transaction__c invoiceRec, Address__c addressRec){
        System.debug(invoiceRec);
        Map<String, Object> returnMap = new Map<String, Object>();
        Map<String,String> fieldValueMap = new Map<String,String>();
        Set<Id> selectedSapContact = new Set<Id>();
        if(String.isNotBlank(invoiceRec.SAP_Contact_1__c)) {
            fieldValueMap.put('SAP_Contact_1__c', invoiceRec.SAP_Contact_1__c);
            selectedSapContact.add(invoiceRec.SAP_Contact_1__c);
        }
        if(String.isNotBlank(invoiceRec.SAP_Contact_2__c)) {
            fieldValueMap.put('SAP_Contact_2__c', invoiceRec.SAP_Contact_2__c);
            selectedSapContact.add(invoiceRec.SAP_Contact_2__c);
        }
        if(String.isNotBlank(invoiceRec.SAP_Contact_3__c)) {
            fieldValueMap.put('SAP_Contact_3__c', invoiceRec.SAP_Contact_3__c);
            selectedSapContact.add(invoiceRec.SAP_Contact_3__c);
        }
        
        try {
            Set<String> sapConFieldSet = new Set<String>{'Id', 'SAP_Contact_Number__c'};
                List<Id > sapContactList = new List<Id>(selectedSapContact);
            Map<Id,SAP_Contact__c> sapConMap = new SLT_SAP_Contact().selectBySapContactId(selectedSapContact, sapConFieldSet);
            
            String SapNumber1 = fieldValueMap.containsKey('SAP_Contact_1__c') ? sapConMap.get(fieldValueMap.get('SAP_Contact_1__c')).SAP_Contact_Number__c : '';
            String SapNumber2 = fieldValueMap.containsKey('SAP_Contact_2__c') ? sapConMap.get(fieldValueMap.get('SAP_Contact_2__c')).SAP_Contact_Number__c : '';
            String SapNumber3 = fieldValueMap.containsKey('SAP_Contact_3__c') ? sapConMap.get(fieldValueMap.get('SAP_Contact_3__c')).SAP_Contact_Number__c : '';
            
            invoicingWrapper invoiceWrap = new invoicingWrapper(invoiceRec.Sales_Org__c, addressRec.SAP_Reference__c, SapNumber1, SapNumber2, SapNumber3);
            System.debug(invoiceWrap);
            
            String invoiceJSON = jsonGenerateEinvoicingAPI(invoiceWrap);
            System.debug('invoiceJSON: '+invoiceJSON);
            HTTPResponse response = SRV_CRM_E_InvoicingCallOuts.makePostCallout(invoiceJSON);
            
            if (response.getStatusCode() == 201) {
                returnMap.put('success', System.Label.CRM_CL0051_E_Invoicing_Success_Message);
            } else {
                returnMap.put('error', System.Label.CRM_CL0047_E_Invoicing_Error_API_Error);
                return returnMap;
            }
            return returnMap;
        } catch(Exception e) {
            returnMap.put('error', e.getMessage());
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            return returnMap;
        }
    }
    
    /**
     * Helper method to genrate Json for API call
     * @params invoicingWrapper invoice
     * @return string jsonString
     */
    private static string jsonGenerateEinvoicingAPI(invoicingWrapper invoice) {
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
        jsGen.writeStringField('content', invoice.SalesOrg);
        jsGen.writeEndObject();
        
        jsGen.writeFieldName('sapAddressId');
        jsGen.writeStartObject();
        jsGen.writeStringField('content', invoice.Address_SapCode);
        jsGen.writeEndObject();
        
        jsGen.writeFieldName('sapContactNo1');
        jsGen.writeStartObject();
        jsGen.writeStringField('content', invoice.SapContactNumber1);
        jsGen.writeEndObject();
        
        jsGen.writeFieldName('sapContactNo2');
        jsGen.writeStartObject();
        jsGen.writeStringField('content', invoice.SapContactNumber2);
        jsGen.writeEndObject();
        
        jsGen.writeFieldName('sapContactNo3');
        jsGen.writeStartObject();
        jsGen.writeStringField('content', invoice.SapContactNumber3);
        jsGen.writeEndObject();
        
        jsGen.writeFieldName('eInvoicingType');
        jsGen.writeStartObject();
        jsGen.writeStringField('content', '1');
        jsGen.writeEndObject();
        
        jsGen.writeFieldName('enabledForEmailInvoicing');
        jsGen.writeStartObject();
        jsGen.writeBooleanField('content', true);
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
    
    /**
     * Created by Ronak Mehta on 19-Jun-2023
     * Description : Wrapper class to pass fields value in JSON Method
     */
    public Class invoicingWrapper{
        @AuraEnabled public String SalesOrg = '';
        @AuraEnabled public String Address_SapCode = '';
        @AuraEnabled public String SapContactNumber1 = '';
        @AuraEnabled public String SapContactNumber2 = '';
        @AuraEnabled public String SapContactNumber3 = '';
        
        /**
         * constructor method to set value in Class Var
         * @params String SalesOrg
         * @params String SapCode
         * @params String SapNumber1
         * @params String SapNumber2
         * @params String SapNumber3
         */
        public invoicingWrapper(String SalesOrg, String SapCode, String SapNumber1, String SapNumber2, String SapNumber3){
            this.SalesOrg = String.isNotBlank(SalesOrg) ? SalesOrg : '';
            this.Address_SapCode = String.isNotBlank(SapCode) ? SapCode : '';
            this.SapContactNumber1 = String.isNotBlank(SapNumber1) ? SapNumber1 : '';
            this.SapContactNumber2 = String.isNotBlank(SapNumber2) ? SapNumber2 : '';
            this.SapContactNumber3 = String.isNotBlank(SapNumber3) ? SapNumber3 : '';
        }
        
    }
    
}