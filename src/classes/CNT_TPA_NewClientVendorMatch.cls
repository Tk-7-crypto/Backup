global class CNT_TPA_NewClientVendorMatch {

    global static TPA_AMA_Client_Vendor_Match__c clientVendorMatch{ get; set;}
    private static List<TPA_AMA_Client_Vendor_Match__c> existingClientVendors;
    Transient public String amaNewClientsAndVendorsLists{ get; set;}
    private static TPA_AMA_Client_Vendor_Search_Map__c searchMapObj{ get; set;}
    public static List<Address__c> existingSuggestedAccounts;
    Transient public String serializedSuggestedAccounts{ get; set;}
    public static List<TPA_AMA_Settings__c> amaSetting;
    
    public static Boolean isBatchProcessing { 
        get{
            if(amaSetting == null) {
                amaSetting = TPA_AMA_Settings__c.getall().values();
            }
            List<String> statusList = new List<String>{'Queued','Preparing','Processing','Holding'};
            List<AsyncApexJob> jobList = new List<AsyncApexjob>();
            isBatchProcessing = false;
            if(amaSetting != null && !amaSetting.isEmpty()) {
                jobList = [SELECT Id, Status, ApexClassID FROM AsyncApexJob  WHERE ApexClassID =: amaSetting.get(0).Client_Vendor_Match_Batch_Class_Id__c and Status IN :statusList  ];
                if(jobList != null && !jobList.isEmpty()){
                    isBatchProcessing = true;
                    system.debug('job list'+jobList);
                } else {
                    isBatchProcessing = false;
                }
            }
            return isBatchProcessing;
        }
        set;
    }
    
    public CNT_TPA_NewClientVendorMatch() {
        clientVendorMatch = new TPA_AMA_Client_Vendor_Match__c();
                   
        existingClientVendors = SLT_TPAAMAClientVendorMatch.instance.getTPAAMAClientVendorMatchData('Client_Name__c');
        Set<Id> accountIds = new Set<ID>();
        List<String> dataList;
        Id accountId;
        for(TPA_AMA_Client_Vendor_Match__c obj:existingClientVendors) {
            dataList = new List<String>();
            if(String.isNotBlank(obj.IMS_Total_Clients__c)) {
                dataList = obj.IMS_Total_Clients__c.split(';');
                for(String str:dataList) {
                    if((str.split('"').get(1).length() == 15 || str.split('"').get(1).length() == 18) && Pattern.matches('^[a-zA-Z0-9]*$', str.split('"').get(1))) {
                        accountId = str.split('"').get(1);
                        accountIds.add(accountId);
                    }
                    
                }
            }
        }
        SLT_Address accSelector = new SLT_Address();
        existingSuggestedAccounts = accSelector.selectByAddressId(accountIds, new Set<String>{'Is_AMA_Account__c', 'Is_TPA_Account__c', 'Country__c'}).values();
        amaNewClientsAndVendorsLists = JSON.serialize(existingClientVendors);
        serializedSuggestedAccounts = JSON.serialize(existingSuggestedAccounts);
    }

    public TPA_AMA_Client_Vendor_Match__c getClientVendorMatch() {
        return clientVendorMatch;
    }

    public PageReference save() {
        update clientVendorMatch;
        return null;
    }
    
    @remoteAction
    global static String saveMapping(string searchMapRecord) { 
        
        searchMapObj = (TPA_AMA_Client_Vendor_Search_Map__c)JSON.deserialize(searchMapRecord, TPA_AMA_Client_Vendor_Search_Map__c.class);
        
        String condition = 'Client_Name__c = \'' + searchMapObj.AMA_Account_Search_Text__c + '\'';
        List<TPA_AMA_Client_Vendor_Match__c> existedNewClientVendors = SLT_TPAAMAClientVendorMatch.instance.getTPAAMAClientVendorMatchDataByCondition(condition);
        
        condition = 'AMA_Account_Search_Text__c = \'' + searchMapObj.AMA_Account_Search_Text__c + '\'';
        List<TPA_AMA_Client_Vendor_Search_Map__c> templatesList = SLT_TPAAMAClientVendorSearchMap.instance.getTPAAMAClientVendorSearchMapDataByCondition(condition);
        String resultMessage = '';
        
        if(existedNewClientVendors.size() > 0) {
            resultMessage = 'alreadyExistAsNewClient';
        } else if(templatesList.size() > 0) {
            resultMessage = 'duplicate';
        } else {
            try {
                if(String.isBlank(searchMapObj.TPA_Account_Address__c)){
                    searchMapObj.Business_Remarks_Notes__c = 'Kickout For Manual Review';
                }
                insert searchMapObj;
                resultMessage = 'success';
            }
            catch(Exception ex) {
                System.debug('Exception:'+ex.getMessage());
                if(ex.getMessage().containsIgnoreCase('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                    resultMessage = 'FIELD_CUSTOM_VALIDATION_EXCEPTION';
                } else {
                    resultMessage = 'error';
                }
            }
        }
        
        return resultMessage;
    }
    
    @remoteAction
    public static String updateRecord(String amaMatchRecord) {
        
        try {
            clientVendorMatch = (TPA_AMA_Client_Vendor_Match__c)JSON.deserialize(amaMatchRecord, TPA_AMA_Client_Vendor_Match__c.class);
            TPA_AMA_Client_Vendor_Search_Map__c searchMapObj = new TPA_AMA_Client_Vendor_Search_Map__c();
        
            searchMapObj.AMA_Account_Search_Text__c = clientVendorMatch.Client_Name__c ;
            if(String.isBlank(clientVendorMatch.TPA_Account_Address__c)){
                searchMapObj.Business_Remarks_Notes__c  = 'KickOut For Manual Review';
            }
            else {
                searchMapObj.TPA_Account_Address__c = clientVendorMatch.TPA_Account_Address__c;
            }
            
            Schema.SObjectField extrnalField = TPA_AMA_Client_Vendor_Search_Map__c.Fields.AMA_Account_Search_Text__c;
            Database.UpsertResult result = Database.upsert(searchMapObj, extrnalField ,false);
            
            if(result.isSuccess()){
                system.debug('record updated in crosswalk for '+ searchMapObj);
            }
            existingClientVendors = SLT_TPAAMAClientVendorMatch.instance.getTPAAMAClientVendorMatchData('Client_Name__c');
            
        } catch(Exception ex) {
        
            System.debug('Exception:'+ex.getMessage());
            if(ex.getMessage().containsIgnoreCase('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                return 'FIELD_CUSTOM_VALIDATION_EXCEPTION';
            } else {
                return 'error';
            }
        }
        
        return JSON.serialize(existingClientVendors);
    }
     
    @remoteAction
    public static String updateMultipleRecord(String amaMatchRecord) {
        List<TPA_AMA_Client_Vendor_Match__c> existingClientVendorsList = new List<TPA_AMA_Client_Vendor_Match__c>();
        List<TPA_AMA_Client_Vendor_Search_Map__c> searchMapRecords = new List<TPA_AMA_Client_Vendor_Search_Map__c>();
        try {
                  
            List<TPA_AMA_Client_Vendor_Match__c> recordsToUpdate = (List<TPA_AMA_Client_Vendor_Match__c>)JSON.deserializeStrict(amaMatchRecord, List<TPA_AMA_Client_Vendor_Match__c>.class);
            TPA_AMA_Client_Vendor_Search_Map__c searchMapObj;
             
         
            for(TPA_AMA_Client_Vendor_Match__c matchObj: recordsToUpdate) {
                searchMapObj = new TPA_AMA_Client_Vendor_Search_Map__c();
                searchMapObj.AMA_Account_Search_Text__c = matchObj.Client_Name__c ;
                searchMapObj.TPA_Account_Address__c = matchObj.Mapped_Account_Id__c;
                searchMapObj.Business_Remarks_Notes__c = 'Confirmed mapping by '+UserInfo.getUserName();
                searchMapRecords.add(searchMapObj);
            }
            
            Schema.SObjectField extrnalField = TPA_AMA_Client_Vendor_Search_Map__c.Fields.AMA_Account_Search_Text__c;
            Database.UpsertResult[] resultList = Database.upsert(searchMapRecords, extrnalField ,false);
            
            for(integer i=0; i<resultList.size(); i++) {
                if(resultList[i].isSuccess()){
                     system.debug('record updated in crosswalk for '+ searchMapRecords.get(i).AMA_Account_Search_Text__c); // added by Supriya Johari under Issue-11508
                }
            }
            existingClientVendorsList = SLT_TPAAMAClientVendorMatch.instance.getTPAAMAClientVendorMatchData('Client_Name__c');
            
            
        } catch(Exception ex) {
        
            System.debug('Exception:'+ex.getMessage());
            if(ex.getMessage().containsIgnoreCase('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                return 'FIELD_CUSTOM_VALIDATION_EXCEPTION';
            } else {
                return 'error';
            }
        }
        return JSON.serialize(existingClientVendorsList);
    }
}