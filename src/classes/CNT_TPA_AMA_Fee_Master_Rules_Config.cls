global class CNT_TPA_AMA_Fee_Master_Rules_Config {

    private static List<AMA_Fee_Master__c> existingRules;
    public String amaFeeMasterRulesLists { get; set;}
    public static AMA_Fee_Master__c amaFeeMasterObj { get; set;}
    private String currentYear;
    private static boolean duplicateRuleExists;


    public CNT_TPA_AMA_Fee_Master_Rules_Config(ApexPages.StandardController con) {
        duplicateRuleExists = false;
        currentYear = String.valueOf(date.today().year());
        amaFeeMasterObj = new AMA_Fee_Master__c();
        existingRules = SLT_TPAAMAFeeMaster.instance.selectByFilter(new Set<String>(), 'year__c = \'' + currentYear + '\' ', 'CreatedDate');
        amaFeeMasterRulesLists = JSON.serialize(existingRules);
    }

    public string getYearsList() {
        List<String> years = new List<String>();
        Integer year = date.today().year() - 4;//date.today().year();
        // Add option for current year by default
        years.add(String.valueOf(year));

        //Populating next five years
        for(Integer i=0; i<5; i++) {
            year = year+1;
            years.add(String.valueOf(year));
        }
        return JSON.serialize(years);
    }

    public string getContractTypeList()
    {
        List<string> requestedData = new List<string>();
        requestedData.add('--None--');
        Schema.DescribeFieldResult fieldResult = AMA_Fee_Master__c.Contract_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple)
        {
            requestedData.add(f.getLabel());
        }
        return JSON.serialize(requestedData);
    }

    public string getVendorHasLicenseValuesList()
    {
        List<string> requestedData = new List<string>();
        Schema.DescribeFieldResult fieldResult = AMA_Fee_Master__c.Vendor_has_Licence__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple)
        {
            requestedData.add(f.getLabel());
        }
        return JSON.serialize(requestedData);
    }

    public string getFeeCalculatedValuesList()
    {
        List<string> requestedData = new List<string>();
        requestedData.add('--None--');
        Schema.DescribeFieldResult fieldResult = AMA_Fee_Master__c.Fee_Calculated__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple)
        {
            requestedData.add(f.getLabel());
        }
        return JSON.serialize(requestedData);
    }

    @remoteAction
    global static String saveRule(string feeMasterDetail, String selctedYearValue) {
        system.debug('******'+feeMasterDetail+'*****');
        amaFeeMasterObj = (AMA_Fee_Master__c)JSON.deserialize(feeMasterDetail, AMA_Fee_Master__c.class);
        amaFeeMasterObj.Id = null;
        amaFeeMasterObj.CreatedDate = null;
        amaFeeMasterObj.LastModifiedDate = null;
        try{
            if(amaFeeMasterObj.Contract_Type__c == '--None--'){
                amaFeeMasterObj.Contract_Type__c = null;
            } 
            if(amaFeeMasterObj.Fee_Calculated__c == '--None--'){
                amaFeeMasterObj.Fee_Calculated__c = null;
            }
            // Check if duplicate rule exists
            if(numberOfSameRuleExists('insert') > 0){
                duplicateRuleExists = true;
            }
            else{
                duplicateRuleExists = false;
            }
            if(duplicateRuleExists) {
                return 'duplicate';
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Same rule already exists with same values of \'Contract Type\', \'Vendor Has License\' and \'Calculate Fee\' fields'));
            } else {
                insert amaFeeMasterObj;
                 existingRules = SLT_TPAAMAFeeMaster.instance.selectByFilter(new Set<String>(), 'year__c = \'' + selctedYearValue + '\' ', 'CreatedDate');
            }
        } catch(Exception ex) {
            UTL_LogFactory.generateAndCommitLog(TRUE, FALSE, UTL_LogFactory.GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::CNT_TPA_AMA_Fee_Master_Rules_Config.saveRule:::in saving Fee Master Rule', '');
            return 'error';
        }
        return JSON.serialize(existingRules);
    }

    @remoteAction
    public static String updateRule(String amaContract, String selctedYearValue) {
        amaFeeMasterObj = (AMA_Fee_Master__c)JSON.deserialize(amaContract, AMA_Fee_Master__c.class);

        try {
            if(amaFeeMasterObj.Contract_Type__c == '--None--'){
                amaFeeMasterObj.Contract_Type__c = null;
            }
            if(amaFeeMasterObj.Vendor_has_Licence__c == '--None--'){
                amaFeeMasterObj.Vendor_has_Licence__c = null;
            }
            if(amaFeeMasterObj.Fee_Calculated__c == '--None--'){
                amaFeeMasterObj.Fee_Calculated__c = null;
            }
            // Check if duplicate rule exists
            if(numberOfSameRuleExists('update') > 0){
                duplicateRuleExists = true;
            }
            else{
                duplicateRuleExists = false;
            } 
            if(duplicateRuleExists) {
                return 'duplicate';
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Same rule already exists with same values of \'Contract Type\', \'Vendor Has License\' and \'Calculate Fee\' fields'));
            } else {
                update amaFeeMasterObj;
                existingRules = SLT_TPAAMAFeeMaster.instance.selectByFilter(new Set<String>(), 'year__c = \'' + selctedYearValue + '\' ', 'CreatedDate' );
            }
        } catch(Exception ex) {
            UTL_LogFactory.generateAndCommitLog(TRUE, FALSE, UTL_LogFactory.GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::CNT_TPA_AMA_Fee_Master_Rules_Config.updateRule:::in updating AMA Fee Master records', amaFeeMasterObj.id != null ? amaFeeMasterObj.id : '');
            return 'error';
        }
        return JSON.serialize(existingRules);
    }

    private static Integer numberOfSameRuleExists(String operationType) {
        String ruleId = amaFeeMasterObj.id;
        String ruleYear = amaFeeMasterObj.year__c;
        String ruleContractType = amaFeeMasterObj.Contract_Type__c;
        String ruleVendorHasLicense = amaFeeMasterObj.Vendor_has_Licence__c;

        String filterCondition = 'year__c = \'' + ruleYear + '\' and Contract_Type__c = \'' + ruleContractType + '\'and Vendor_has_Licence__c = \'' + ruleVendorHasLicense + '\' ';
        if(operationType == 'update') {
           filterCondition = filterCondition + 'and id != ' + '\'' + ruleId + '\'';
        }
        List<AMA_Fee_Master__c> allExistingRulesList = SLT_TPAAMAFeeMaster.instance.selectByFilter(new Set<String>(), filterCondition, 'CreatedDate');
        return allExistingRulesList.size();
    }

    @remoteAction
    public static String deleteRule(String amaContract) {
        try {
            amaFeeMasterObj = (AMA_Fee_Master__c)JSON.deserialize(amaContract, AMA_Fee_Master__c.class);
            String yearValue = amaFeeMasterObj.Year__c;
            delete amaFeeMasterObj;
            system.debug('******'+ amaFeeMasterObj + '*****');
            existingRules = SLT_TPAAMAFeeMaster.instance.selectByFilter(new Set<String>(), 'year__c = \'' + yearValue + '\' ', 'CreatedDate');
            system.debug('******'+ existingRules + '*****');
        } catch(Exception ex) {
            UTL_LogFactory.generateAndCommitLog(TRUE, FALSE, UTL_LogFactory.GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::CNT_TPA_AMA_Fee_Master_Rules_Config.deleteRule:::in Deleting records', '');
            return 'error';
        }
        return JSON.serialize(existingRules);
    }

    @remoteAction
    public static String showExistingRules(String yearValue) {
        existingRules = SLT_TPAAMAFeeMaster.instance.selectByFilter(new Set<String>(), 'year__c = \'' + yearValue + '\' ', 'CreatedDate');
        if(existingRules.size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'No Rule exists for this year'));
        }
        return JSON.serialize(existingRules);
    }
    
    @remoteAction
    public static String cloneExistingRules(String yearValue) {
        Boolean duplicateExists = false;
        List<AMA_Fee_Master__c> clonedRulestoUpdate = new List<AMA_Fee_Master__c>();
        List<AMA_Fee_Master__c> nextYearRules = new List<AMA_Fee_Master__c>();
        Map<String, AMA_Fee_Master__c> mapNextYearRules = new Map<String, AMA_Fee_Master__c>();
        String currentYear = String.valueOf(date.today().year());
        String nextYear = String.valueOf(date.today().year() + 1);
        existingRules = SLT_TPAAMAFeeMaster.instance.selectByFilter(new Set<String>(), 'year__c = \'' + yearValue + '\' ', 'CreatedDate');
        nextYearRules = SLT_TPAAMAFeeMaster.instance.selectByFilter(new Set<String>(), 'year__c = \'' + nextYear + '\' ', 'CreatedDate');
        if(existingRules.size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'No Rule exists for this year'));
        }
        if(nextYearRules.size() > 0) {
            for(AMA_Fee_Master__c amaFeeMasterObj : nextYearRules){
                if(amaFeeMasterObj.Year__c == String.valueOf((date.today().year()) + 1)){
                    String key = amaFeeMasterObj.Year__c + amaFeeMasterObj.Contract_Type__c + amaFeeMasterObj.Vendor_has_Licence__c;
                    mapNextYearRules.put(key, amaFeeMasterObj);
                }
            }
        }
        if(existingRules.size() > 0) {
            for(AMA_Fee_Master__c amaFeeMasterObj : existingRules){
                String keyCheck = (Integer.valueOf(amaFeeMasterObj.Year__c))+1 + amaFeeMasterObj.Contract_Type__c + amaFeeMasterObj.Vendor_has_Licence__c;
                if(amaFeeMasterObj.Year__c == currentYear && !mapNextYearRules.containsKey(keyCheck)){
                    amaFeeMasterObj.Year__c = String.valueOf((date.today().year()) + 1);
                    amaFeeMasterObj.Id = null;
                    amaFeeMasterObj.CreatedDate = null;
                    amaFeeMasterObj.LastModifiedDate = null;
                    clonedRulestoUpdate.add(amaFeeMasterObj);
                    system.debug('duplicate does not exists');
                }
                else if(mapNextYearRules.containsKey(keyCheck)) {
                    clonedRulestoUpdate.add(mapNextYearRules.get(keyCheck));
                    duplicateExists = true;
                    system.debug('duplicate exists');
                }
            }
        }
        if(duplicateExists){
            return 'duplicate'+JSON.serialize(clonedRulestoUpdate);
        }
        else if(!duplicateExists && clonedRulestoUpdate.size() > 0){
            insert clonedRulestoUpdate;
            return 'success';
        }
        return JSON.serialize(clonedRulestoUpdate);
    }
    
    @remoteAction
    public static String upsertSameRuleExistsinNextYear(String amaFeeRules) {
        List<AMA_Fee_Master__c> listAMAFeeRules = (List<AMA_Fee_Master__c>)JSON.deserialize(amaFeeRules, List<AMA_Fee_Master__c>.class);
        if(listAMAFeeRules.size() > 0) {
            upsert listAMAFeeRules;
        }
        return 'success';
    }
}
