public with sharing class CNT_OWF_CreateReourseRequest {
    
    @AuraEnabled
    public static void saveMultipleAnalyticsRequests(List<pse__Resource_Request__c> resourceRequests) {
        try {
            for(pse__Resource_Request__c rr : resourceRequests) {
                rr.recordTypeId = CON_OWF.OWF_RR_RECORD_TYPE_ID;
            }
            if (resourceRequests.size() > 0) {
                insert resourceRequests;
            }
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled //Save Resource Request Data
    Public static void saveResourceRequest(pse__Resource_Request__c objRR,List<string> selectedCountriesList, Boolean selectedAll,Integer noOfRRToBeCreated){
        try{
            pse__Resource_Request__c rrObject=new pse__Resource_Request__c();
            List<pse__Resource_Request__c> rrList= new List<pse__Resource_Request__c>();
            objRR.recordTypeId = CON_OWF.OWF_RR_RECORD_TYPE_ID;							  
            if(objRR.SubGroup__c == CON_OWF.RES_REQ_TYPE_GLOBAL_ANALYTICS){
                if(selectedAll == true){
                    for(string countryName:getPiklistValues())
                    {
                        for(Integer rrIterator = 1;rrIterator <= noOfRRToBeCreated; rrIterator++){
                        rrObject=objRR.clone(false,true,true,true);
                        rrObject.Regional_Analytics_Country__c = countryName;	
                        rrList.add(rrObject);
                        }
                    }
                }
                else{
                    for(string countryName:selectedCountriesList)
                    {   
                        for(Integer rrIterator = 1; rrIterator <= noOfRRToBeCreated; rrIterator++){
                            rrObject=objRR.clone(false,true,true,true);
                            rrObject.Regional_Analytics_Country__c = countryName;	
                            rrList.add(rrObject);
                        }
                       
                    }
                }
            }
            
            //Insert Resource Request Record
            if(rrList.size() > 0){
                insert rrList;
            }				
            else if(objRR != null){
               for(Integer rrIterator = 1; rrIterator <= noOfRRToBeCreated; rrIterator++)
                    { 
                        rrObject=objRR.clone(false,true,true,true);
                        rrList.add(rrObject);
                    }
                if(rrList.size() > 0){
                    insert rrList;
                }
            }
                        
        }catch(Exception e){
            //throw exception message
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled //get RR Picklist Values
    public static Map<String, String> getSubgroup(){
        Map<String, String> options = new Map<String, String>();
        //get Resource Request Subgroup Field Describe
        Schema.DescribeFieldResult fieldResult = pse__Resource_Request__c.SubGroup__c.getDescribe();
        //get Resource Request Subgroup Picklist Values
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            //Put Picklist Value & Label in Map
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }
    
    @AuraEnabled
    public static List <String> getPiklistValues() {
        List<String> plValues = new List<String>();
        
        //Get the object type from object name. Here I've used custom object Resource Request.
        Schema.SObjectType objType = Schema.getGlobalDescribe().get('pse__Resource_Request__c');
        
        //Describe the sObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        
        //Get the specific field information from field name. Here I've used custom field Genre__c of Resource Request .
        Schema.DescribeFieldResult objFieldInfo = objDescribe.fields.getMap().get('Regional_Analytics_Country__c').getDescribe();
        
        //Get the picklist field values.
        List<Schema.PicklistEntry> picklistvalues = objFieldInfo.getPicklistValues();
        
        //Add the picklist values to list.
        for(Schema.PicklistEntry plv: picklistvalues) {
            plValues.add(plv.getValue());
        }
        plValues.sort();
        return plValues;
    }
    
    @AuraEnabled
    public static pse__Resource_Request__c getRecordType()
    {
        return new pse__Resource_Request__c(RecordTypeId = CON_OWF.OWF_RR_RECORD_TYPE_ID);
    }
    
    @AuraEnabled
    public static List<String> getResourceRequestTypesForMultipleRR() {
        OWF_Config__c owfConfig = OWF_Config__c.getOrgDefaults();
        if (owfConfig != null) {
            return owfConfig.OWF_Multiple_RR_Compatible_Subgroups__c.split(';');
        }
        return new List<String>();
    }
    
}