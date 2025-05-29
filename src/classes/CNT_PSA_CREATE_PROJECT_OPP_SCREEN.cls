/***********************************************
   Name      :     CNT_PSA_CREATE_PROJECT_OPP_SCREEN 
   Date      :     8-April-2019
   Usage     :     Validate Opportunity for create project before redirecting to LI org 
   Author    :     Anju Kumari
***********************************************/

public class CNT_PSA_CREATE_PROJECT_OPP_SCREEN {
    
    public static Boolean isZQUIProduct = false;
    @AuraEnabled 
    public static Map<String, String>  validateOppForProjectCreation(Id opportunityId) {
        Boolean passedValidation = true;
        Id selectedComponentId;
        //Added for RWAS changes
        Map<String,String> result = new Map<String,String>();
        List<String> errorMessages = new List<String>();
        Opportunity currentOpportunity = new Opportunity();
        List <OpportunityLineItem> opportunityLineItemList;
        Boolean onDemandCompOnly = false;
        String tempSalesOrg;
        try {
            List<Opportunity> lstOpportunity = new List<Opportunity>([ SELECT Principle_inCharge__c,LI_Opportunity_Id__c,Name,Opportunity_Number__c,StageName,Legacy_Quintiles_Opportunity_Number__c,AccountId,Sales_Org__c,
                                                                      (SELECT id  FROM OpportunityLineItems where PricebookEntry.Product2.Material_Type__c = 'ZREP' ) FROM Opportunity WHERE id =:opportunityId ]);
            currentOpportunity = lstOpportunity[0];
            // ensure oppty stage it at least stage 4
            if(currentOpportunity == null ||
               currentOpportunity.StageName == null ||
               currentOpportunity.StageName == '' ||
               currentOpportunity.StageName.substring(0,1) == '1') 
            {                   
                passedValidation = false;
                errorMessages.add('Opportunity stage is not valid for creating both Billable Projects or Planned projects.');
            }  
            
            //Principal Incharge Validation
            if(currentOpportunity.OpportunityLineItems.size()>0 && currentOpportunity.Principle_inCharge__c == null && (currentOpportunity.StageName.substring(0,1) == '5' || 
                                                                                                                        currentOpportunity.StageName.substring(0,1) == '6' ||
                                                                                                                        currentOpportunity.StageName.substring(0,1) == '7'))
            {                         
                errorMessages.add('Principal In charge on the opportunity can not be blank when ZREP material type products are added on the Opportunity for creating project.');
                passedValidation = false;           
            }
            else if(currentOpportunity.OpportunityLineItems.size()>0 && currentOpportunity.Principle_inCharge__c == null && (currentOpportunity.StageName.substring(0,1) == '2' || 
                                                                                                                             currentOpportunity.StageName.substring(0,1) == '3' ||
                                                                                                                             currentOpportunity.StageName.substring(0,1) == '4') )
            {
                errorMessages.add('Principal In charge on the opportunity can not be blank when ZREP material type products are added on the Opportunity for creating Planned project.');
                passedValidation = false;
            }
            
            //Address Validation
            SLT_Address accSelector = new SLT_Address();
            List<Address__c> address = accSelector.getSAPValidatedAddress(currentOpportunity.AccountId, new Set<String>{'id','name', 'RecordType.name', 'MDM_Validation_Status__c', 'SAP_Reference__c'});
            if((address.size() == 0 || address == null) && (currentOpportunity.StageName.substring(0,1) == '5' || 
                                                            currentOpportunity.StageName.substring(0,1) == '6' ||
                                                            currentOpportunity.StageName.substring(0,1) == '7') ) 
            {
                passedValidation = false;
                errorMessages.add('At least one MDM validated address is required to create a project. Please click here to contact the MDM team: <a> https://quintiles.service-now.com/via/?id=sc_cat_item&amp;sys_id=4b0859dddb28c8107cf37e77f4961900 </a>');
            }
            else if((address.size() == 0 || address == null) && (currentOpportunity.StageName.substring(0,1) == '2' || 
                                                                 currentOpportunity.StageName.substring(0,1) == '3' ||
                                                                 currentOpportunity.StageName.substring(0,1) == '4') )
            {
                passedValidation = false;
                errorMessages.add('At least one MDM validated address is required to create a Planned project. Please click here to contact the MDM team: <a> https://quintiles.service-now.com/via/?id=sc_cat_item&amp;sys_id=4b0859dddb28c8107cf37e77f4961900 </a>');
            }
            
           opportunityLineItemList = new SLT_OpportunityLineItems(false,false).getComponentData(opportunityId);
            
            //check for on demand products and fire validation accordingly
            if(opportunityLineItemList != null && opportunityLineItemList.size() >0){
                onDemandCompOnly = checkForOnDemandProducts(opportunityLineItemList);
                if(onDemandCompOnly && (currentOpportunity == null ||
                   currentOpportunity.StageName == null ||
                   currentOpportunity.StageName == '' ||
                   currentOpportunity.StageName.substring(0,1) == '1' || 
                   currentOpportunity.StageName.substring(0,1) == '2' || 
                   currentOpportunity.StageName.substring(0,1) == '3' ||
                   currentOpportunity.StageName.substring(0,1) == '4' )){
                    passedValidation = false;
                    errorMessages.add('Opportunity stage <5 is not valid for creating On Demand Project.');
                }
            }
            
            selectedComponentId = getComponentListData(opportunityLineItemList);
            // check for selected component
            if(selectedComponentId == null && (currentOpportunity.StageName.substring(0,1) == '5' || 
                                               currentOpportunity.StageName.substring(0,1) == '6' ||
                                               currentOpportunity.StageName.substring(0,1) == '7') ) 
            {               
                             
                passedValidation = false;
                errorMessages.add('Component is required to create projects.');
            }
            else if(selectedComponentId == null && (currentOpportunity.StageName.substring(0,1) == '2' || 
                                                    currentOpportunity.StageName.substring(0,1) == '3' ||
                                                    currentOpportunity.StageName.substring(0,1) == '4') )
            {
                             
                passedValidation = false;
                errorMessages.add('There are no eligible Services (ZREP) components on the opportunity for which to create a new Planned project.');
            }
            
            List<OpportunityHistory> MaxStageHistory = [ select StageName FROM OpportunityHistory WHERE OpportunityId =:opportunityId order by StageName desc];
            if(!MaxStageHistory.isEmpty()){
                if((MaxStageHistory[0].stageName.substring(0,1) == '5' || MaxStageHistory[0].stageName.substring(0,1) == '6' || MaxStageHistory[0].stageName.substring(0,1) == '7') && (currentOpportunity.StageName.substring(0,1) == '2' || 
																																									   currentOpportunity.StageName.substring(0,1) == '3' ||
																																									   currentOpportunity.StageName.substring(0,1) == '4')) 
                {
                    passedValidation = false;
                    errorMessages.add('This opportunity was already marked as closed won (stage 5 or higher). It is no longer eligible for creation of a planned project.');
                }
            }
            
            result.put('errorMessages',JSON.serialize(errorMessages));
            result.put('legacyOrgOppId', currentOpportunity.LI_Opportunity_Id__c);
            result.put('legacyOrgLink', Legacy_Org_Link__c.getInstance().Legacy_IMS_URL__c);
            if(isZQUIProduct){
                result.put('IsZQUIProduct','ZQUI');
            	result.put('legacyQuintilesOppNumber', currentOpportunity.Legacy_Quintiles_Opportunity_Number__c);
            }
            if(currentOpportunity.Sales_Org__c != '' && currentOpportunity.Sales_Org__c != null){
                tempSalesOrg = EncodingUtil.urlEncode(currentOpportunity.Sales_Org__c,'UTF-8');
                result.put('SalesOrg',tempSalesOrg);
            }
            else{
                tempSalesOrg = 'None';
                result.put('SalesOrg',tempSalesOrg);
            }
            return result;
        } catch(Exception e) {
            return result;
        }
        
        //return passedValidation;
    }
    @AuraEnabled
    public static Id getComponentListData(List <OpportunityLineItem> opportunityLineItemList) {
        if(opportunityLineItemList != null && opportunityLineItemList.size() > 0){ 
            for(OpportunityLineItem oli:opportunityLineItemList) {
                if(('ZQUI').equals(oli.PricebookEntry.Product2.Material_Type__c) 
                   && oli.PricebookEntry.Product2.ZQUI_Product__c) {
                       isZQUIProduct=true;
                       break;
                   }
            }
            return opportunityLineItemList[0].Id;
            
        }
        return null;
    }
    
    public static boolean checkForOnDemandProducts(List <OpportunityLineItem> opportunityLineItemList){
        boolean containsOnlyOndemandComp = true;
        if(opportunityLineItemList != null && opportunityLineItemList.size() > 0){ 
            for(OpportunityLineItem oli:opportunityLineItemList) {
                if(!(CON_PSA.NOVASYTE_CRM).equals(oli.PricebookEntry.Product2.Product_Group__c)) {
                       containsOnlyOndemandComp = false;
                       break;
                   }
            }            
        }
        return containsOnlyOndemandComp;
    }
    
    @AuraEnabled
    public static Legacy_Org_Link__c getLegacyOrgLink(){
        return Legacy_Org_Link__c.getInstance();
    }
}
