public with sharing class CNT_PSA_LanguageCapability {
    public static List<WPR_PSA_ResourceDetails> getResourceRatingInfoForPDFExport{get;set;}
    public String medicalProjectId = '';
    public String clientName = '';
    public String projectCode = '';
    public Boolean isActive;
    public String isActiveString = '';
    public Static Boolean isMedicalProject{get;set;}
    public CNT_PSA_LanguageCapability(){
        medicalProjectId = Apexpages.currentPage().getParameters().get('c__serviceline');
        if(medicalProjectId != null && medicalProjectId != ''){
            isMedicalProject = true;
        }else{
            isMedicalProject = false;
        }
        clientName = Apexpages.currentPage().getParameters().get('c__clientName');
        projectCode = Apexpages.currentPage().getParameters().get('c__projectCode');
        isActiveString = Apexpages.currentPage().getParameters().get('c__isActive');
        if(isActiveString != null && isActiveString.equalsIgnoreCase('true')){
            isActive = true;
        }else{
            isActive = false;
        }
        getResourceRatingInfoForPDFExport = getResourceData(medicalProjectId, clientName, projectCode, isActive);
    }
    
    @AuraEnabled(cacheable=true)
    public static List<WPR_PSA_ResourceDetails> getResourceInfo(String medicalProjectId, double refresh, String clientName, String projectCode, Boolean isActive){
        return getResourceData(medicalProjectId, clientName, projectCode, isActive);
    }
    
    public static List<WPR_PSA_ResourceDetails> getResourceData(String medicalProjectId, String clientName, String projectCode, Boolean isActive){
        String conditon = '';
        String clientNameString = '%' + clientName + '%';
        String accountCountryStr = '';
        Set<String> clientNameStringList = new Set<String>{clientNameString};
        Set<Id> resourceIdSet = new Set<Id>();
        Set<String> uniqueKeySet = new Set<String>();
        Set<String> languageAndRatingSet = new Set<String>();
        List<pse__Assignment__c> assignmentList = new List<pse__Assignment__c>();
        List<WPR_PSA_ResourceDetails> resourceDetailsList = new  List<WPR_PSA_ResourceDetails>();
        Map<String, String> picklistValueToApiNameOfAccountCountryMap = new Map<String, String>();
        Map<String, List<WPR_PSA_LanguageSkillSet>> resourceToLanguageSkillSetListMap = new Map<String, List<WPR_PSA_LanguageSkillSet>>();
        List<Schema.PicklistEntry> accountCountryValuesList = Account.AccountCountry__c.getDescribe().getPicklistValues();
        Map<String, String> picklistValueToApiNameOfLanguageMap = new Map<String, String>();
        Map<String, String> picklistApiNameToValueOfLanguageMap = new Map<String, String>();
        List<Schema.PicklistEntry> languageValuesList = pse__Skill_Certification_Rating__c.Language__c.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry lv : languageValuesList){
            picklistValueToApiNameOfLanguageMap.put(lv.getValue(), lv.getLabel());
            picklistApiNameToValueOfLanguageMap.put(lv.getLabel(), lv.getValue());
        }
        
        for(Schema.PicklistEntry acv : accountCountryValuesList){
            picklistValueToApiNameOfAccountCountryMap.put(acv.getValue(), acv.getLabel());
        }
        List<String> resourceLanguageSkillSetList= new List<String>();
        List<String> languageRatingList= new List<String>();
        String languageString ='';
        String unikey ='';
        Set<String> projectCodeSet = new Set<String>{projectCode};
        if(medicalProjectId != null){
            conditon = 'pse__Project__c in :sObjectIdset AND pse__Resource__c != null';
            if(clientName != null && clientName !=''){
                conditon += ' AND pse__Project__r.pse__Account__r.name like : clientNameString';
            }
            if(projectCode != null && projectCode !=''){
                conditon += ' AND pse__Project__r.pse__Parent_Project__r.Project_Code__c like : projectCodeString';
            }
        }else{
            conditon = 'pse__Project__r.Service_Line__r.Name = \''+ CON_PSA.MEDICAL_INFORMATION_SERVICE_LINE +'\' AND pse__Resource__c != null ';
            if(clientName != null && clientName !=''){
                conditon+= ' AND pse__Project__r.pse__Account__r.name like : clientNameStringList';
            }
            if(projectCode != null && projectCode !=''){
                conditon += ' AND pse__Project__r.pse__Parent_Project__r.Project_Code__c in :projectCodeSet';
            }
            if(isActive == true){
                conditon += ' AND Active__c = true';
            }else{
                conditon += ' AND Active__c = false';
            }
            
        }
        Set<Id> sObjectIdset = new Set<Id>{medicalProjectId};
        Set<String> skillCertificationRatingFieldsSet = new Set<String>{'Id', 'pse__Resource__c', 'pse__Rating__c', 'Language__c', 'pse__Skill_Certification__r.pse__Type__c'}; 
        Set<String> assignmentFieldsSet = new Set<String>{'Id', 'Name', 'pse__Project__r.Program__r.Name',
            'pse__Project__r.pse__Account__r.name', 'pse__Resource__c',
            'pse__Resource__r.Name', 'pse__Project__r.Service_Line__r.name',
            'pse__Project__r.Service_Line_Lead__r.Name',
            'pse__Project__r.pse__Parent_Project__r.Project_Code__c',
            'pse__Project__r.pse__Region__r.Name',
            'pse__Project__r.pse__Account__r.AccountCountry__c',
            'Preferred_Language__c', 'pse__Scheduled_Hours__c',
            'Resource_Language_Skill_Set__c'};
        Map<Id, pse__Assignment__c> getAssignmentIdToRecordMap = new SLT_Assignment(false, false).selectAssignmentsByFilter(sObjectIdset, conditon, clientNameStringList, projectCodeSet, assignmentFieldsSet);
        
        for(pse__Assignment__c assignment :  getAssignmentIdToRecordMap.values()){
            if(assignment.pse__Resource__c != null){
                resourceIdSet.add(assignment.pse__Resource__c);
                assignmentList.add(assignment);
                if(assignment.Resource_Language_Skill_Set__c != null){
                     resourceLanguageSkillSetList = assignment.Resource_Language_Skill_Set__c.split('<br>');
                    if(resourceLanguageSkillSetList.size() > 0){
                        for(String rating : resourceLanguageSkillSetList){
                            languageRatingList = rating.split(': ');
                            if(picklistApiNameToValueOfLanguageMap.containsKey(languageRatingList[0])){
                               languageString =  picklistApiNameToValueOfLanguageMap.get(languageRatingList[0]);
                            }
                            
                            unikey = assignment.pse__Resource__c + '*' + languageString + '*' + languageRatingList[1];
                            if(languageString !='' && !uniqueKeySet.contains(unikey)){
                                uniqueKeySet.add(unikey);
                                WPR_PSA_LanguageSkillSet resourceSkillRecord = new WPR_PSA_LanguageSkillSet();
                                resourceSkillRecord.language = languageString;
                                resourceSkillRecord.rating = languageRatingList[1];
                                if(resourceToLanguageSkillSetListMap.containsKey(assignment.pse__Resource__c)){
                                    resourceToLanguageSkillSetListMap.get(assignment.pse__Resource__c).add(resourceSkillRecord);
                                }else{
                                    resourceToLanguageSkillSetListMap.put(assignment.pse__Resource__c, new List<WPR_PSA_LanguageSkillSet>{resourceSkillRecord});  
                                }
                            }
                        }
                    }
                }
            }
        }
        if(resourceIdSet.size() > 0){
            String conditionString = 'pse__Resource__c IN : resourceIdSet AND pse__Skill_Certification__r.pse__Type__c = \'' + CON_PSA.SKILL_TYPE_LANGUAGE + '\' AND Language__c != null '
                + 'AND pse__Resource__c != null AND pse__Rating__c != null'; 
            List<pse__Skill_Certification_Rating__c> resourceSkillRatingList = new SLT_Skill_Certification_Rating().getSkillCertificationRatingsByResourceIds(resourceIdSet, conditionString, skillCertificationRatingFieldsSet, false);
            for(pse__Skill_Certification_Rating__c skillSet : resourceSkillRatingList){
                unikey = skillSet.pse__Resource__c + '*' + skillSet.Language__c + '*' + skillSet.pse__Rating__c;
                if(!uniqueKeySet.contains(unikey)){
                    WPR_PSA_LanguageSkillSet resourceSkillRecord = new WPR_PSA_LanguageSkillSet();
                    resourceSkillRecord.language = skillSet.Language__c;
                    resourceSkillRecord.rating = skillSet.pse__Rating__c;
                    if(resourceToLanguageSkillSetListMap.containsKey(skillSet.pse__Resource__c)){
                        resourceToLanguageSkillSetListMap.get(skillSet.pse__Resource__c).add(resourceSkillRecord);
                    }else{
                        resourceToLanguageSkillSetListMap.put(skillSet.pse__Resource__c, new List<WPR_PSA_LanguageSkillSet>{resourceSkillRecord});  
                    }
                }
                
            }
            for(pse__Assignment__c assignment : assignmentList){
                if(picklistValueToApiNameOfAccountCountryMap.containsKey(assignment.pse__Project__r.pse__Account__r.AccountCountry__c)){
                    accountCountryStr = picklistValueToApiNameOfAccountCountryMap.get(assignment.pse__Project__r.pse__Account__r.AccountCountry__c);
                }
                if(assignment.Resource_Language_Skill_Set__c != null){
                    resourceLanguageSkillSetList = assignment.Resource_Language_Skill_Set__c.split('<br>');
                    if(resourceLanguageSkillSetList.size() > 0){
                        for(String rating : resourceLanguageSkillSetList){
                            languageRatingList = rating.split(': ');
                            if(picklistApiNameToValueOfLanguageMap.containsKey(languageRatingList[0])){
                                languageString =  picklistApiNameToValueOfLanguageMap.get(languageRatingList[0])+'*'+languageRatingList[1];
                                languageAndRatingSet.add(languageString);
                            }
                        }
                    } 
                }
                if(resourceToLanguageSkillSetListMap != null 
                   && resourceToLanguageSkillSetListMap.containsKey(assignment.pse__Resource__c) 
                   && resourceToLanguageSkillSetListMap.get(assignment.pse__Resource__c) != null){
                       for(WPR_PSA_LanguageSkillSet skillRecord : resourceToLanguageSkillSetListMap.get(assignment.pse__Resource__c)){
                           WPR_PSA_ResourceDetails resourceDetailRecord = new WPR_PSA_ResourceDetails();
                           resourceDetailRecord.resourceName = assignment.pse__Resource__r.Name;
                           resourceDetailRecord.programName = assignment.pse__Project__r.Program__r.Name;
                           resourceDetailRecord.clientName = assignment.pse__Project__r.pse__Account__r.Name;
                           resourceDetailRecord.serviceLineName = assignment.pse__Project__r.Service_Line__r.Name;
                           resourceDetailRecord.projectCodeName = assignment.pse__Project__r.pse__Parent_Project__r.Project_Code__c;
                           resourceDetailRecord.assignmentName = assignment.Name;
                           resourceDetailRecord.serviceLineLead = assignment.pse__Project__r.Service_Line_Lead__r.Name;
                           resourceDetailRecord.region = assignment.pse__Project__r.pse__Region__r.Name;
                           resourceDetailRecord.accountCountry = accountCountryStr;
                           resourceDetailRecord.scheduleHours = assignment.pse__Scheduled_Hours__c;
                           if(picklistValueToApiNameOfLanguageMap.containsKey(skillRecord.language)){
                               resourceDetailRecord.language = picklistValueToApiNameOfLanguageMap.get(skillRecord.language);
                           }
                           resourceDetailRecord.skill = skillRecord.rating;
                           if(languageAndRatingSet != null && languageAndRatingSet.size() > 0 && languageAndRatingSet.contains(skillRecord.language+'*'+skillRecord.rating)){
                               resourceDetailRecord.utilized = true;
                           }else{
                               resourceDetailRecord.utilized = false;
                           }
                           resourceDetailsList.add(resourceDetailRecord); 
                       }
                   }
                languageAndRatingSet.clear();
            }
        }
        return resourceDetailsList;
    }
    
    @AuraEnabled(cacheable=true)
    public static WPR_PSA_LanguageDetails getLanguageOptions(String assignmentId){
        String conditon = '';
        WPR_PSA_LanguageDetails languageDetails = new WPR_PSA_LanguageDetails();
        List<WPR_PSA_LanguageSkillSet> skilSetList = new List<WPR_PSA_LanguageSkillSet>();
        List<WPR_PSA_LanguageSkillSet> allSkilSetList = new List<WPR_PSA_LanguageSkillSet>();
        Map<String, String> picklistValueToApiNameOfLanguageMap = new Map<String, String>();
        List<Schema.PicklistEntry> languagevalues = pse__Skill_Certification_Rating__c.Language__c.getDescribe().getPicklistValues();
        Set<Id> resourceIdSet = new Set<Id>();
        Set<String> selectOptionsList = new Set<String>();
        Set<String> languageOptionsList = new Set<String>();
        
        for(Schema.PicklistEntry lv : languagevalues){
            picklistValueToApiNameOfLanguageMap.put(lv.getValue(), lv.getLabel());
        }
        Set<Id> sObjectIdset = new Set<Id>{assignmentId};
        Set<String> assignmentFieldsSet = new Set<String>{'Id','pse__Resource__c', 'Resource_Language_Skill_Set__c', 'Preferred_Language__c'};
        if(assignmentId != null){
            conditon = 'Id IN : sObjectIdset AND pse__Resource__c != null AND pse__Project__r.Service_Line__r.Name = \''+CON_PSA.MEDICAL_INFORMATION_SERVICE_LINE+'\' ';
        }
        Set<String> skillCertificationRatingFieldsSet = new Set<String>{'Id', 'pse__Resource__c', 'pse__Rating__c', 'Language__c', 'pse__Skill_Certification__r.pse__Type__c'}; 
        Map<Id,pse__Assignment__c> getAssignmentIdToRecordMap = new SLT_Assignment(false, false).selectAssignmentsByIdSet(sObjectIdset, conditon, assignmentFieldsSet);
        
        for(pse__Assignment__c assignment : getAssignmentIdToRecordMap.values()){
            resourceIdSet.add(assignment.pse__Resource__c);
            languageDetails.resourceSkillSet = assignment.Resource_Language_Skill_Set__c;
            if(assignment.Preferred_Language__c != null){
                for(String selectLanguageOption : assignment.Preferred_Language__c.split(';')){
                    if(picklistValueToApiNameOfLanguageMap.containsKey(selectLanguageOption)){
                        selectOptionsList.add(picklistValueToApiNameOfLanguageMap.get(selectLanguageOption));
                    }
                }
                languageDetails.selectedOptions = selectOptionsList; 
            }
        }
        String conditionString = 'pse__Resource__c IN : resourceIdSet AND pse__Skill_Certification__r.pse__Type__c = \'Language\' AND Language__c != null AND pse__Resource__c != null AND pse__Rating__c != null'; 
        List<pse__Skill_Certification_Rating__c> getSkillCertificationRating = new SLT_Skill_Certification_Rating().getSkillCertificationRatingsByResourceIds(resourceIdSet, conditionString, skillCertificationRatingFieldsSet, false);
        
        for(pse__Skill_Certification_Rating__c skillSet : getSkillCertificationRating){
            WPR_PSA_LanguageSkillSet record = new WPR_PSA_LanguageSkillSet();
            if(picklistValueToApiNameOfLanguageMap.containsKey(skillSet.Language__c)){
                record.language = picklistValueToApiNameOfLanguageMap.get(skillSet.Language__c);
                record.rating = skillSet.pse__Rating__c;
                if(languageOptionsList.size() < 8){
                    languageOptionsList.add(picklistValueToApiNameOfLanguageMap.get(skillSet.Language__c));
                    skilSetList.add(record);
                }
                allSkilSetList.add(record);
            }
        }
        if(selectOptionsList.size() > 0){
            languageOptionsList.addAll(selectOptionsList);  
        }
        languageDetails.options = languageOptionsList;
        languageDetails.skillSets = skilSetList;
        languageDetails.allSkillSets = allSkilSetList;
        return languageDetails;
    }
    
    @AuraEnabled
    public static String saveOptions(String assignmentId, List<String> selectedValues, List<WPR_PSA_LanguageSkillSet> skillSetList){
        String returnString ='Success';
        List<String> preferredLanguageList = new List<String>();
        List<String> preferredLanguageWithRatingList = new List<String>();
        Map<String, String> picklistValueToApiNameOfLanguageMap = new Map<String, String>();
        List<Schema.PicklistEntry> languagevalues = pse__Skill_Certification_Rating__c.Language__c.getDescribe().getPicklistValues();
        
        for(Schema.PicklistEntry lv : languagevalues){
            picklistValueToApiNameOfLanguageMap.put(lv.getLabel(), lv.getValue());
        }
        
        for(String language : selectedValues){
            if(picklistValueToApiNameOfLanguageMap.containsKey(language)){
                preferredLanguageList.add(picklistValueToApiNameOfLanguageMap.get(language));
            }
        }
        
        for(WPR_PSA_LanguageSkillSet skillSet : skillSetList){
            if(selectedValues.contains(skillSet.language)){
                preferredLanguageWithRatingList.add(skillSet.language+': '+skillSet.rating);
            }
        }
        try{
            pse__Assignment__c assignment = new pse__Assignment__c(id=assignmentId);
            assignment.Preferred_Language__c = String.join( preferredLanguageList, ';');
            assignment.Resource_Language_Skill_Set__c = String.join( preferredLanguageWithRatingList, '<br/>');
            update assignment;
        }catch(Exception e){
            returnString = e.getMessage();
        }
        return returnString;
    }
    
    @AuraEnabled
    public static List<String> getPDFprint(String medicalProjectId, string clientName, String projectCode, Boolean isActive){
        List<String> pageStringList = new List<String>();
        Pagereference pdfPage = page.VFP_PSA_GeneratePDF;
        pdfPage.getParameters().put('c__serviceline', medicalProjectId);
        pdfPage.getParameters().put('c__clientName', clientName);
        pdfPage.getParameters().put('c__projectCode', projectCode);
        pdfPage.getParameters().put('c__isActive', String.valueOf(isActive));
        Blob pdfBlob = pdfPage.getContent();
        String downloadUrl = EncodingUtil.base64Encode(pdfBlob);
        pageStringList.add(downloadUrl);
        // get Url for Window.open 
        pageStringList.add(pdfPage.getUrl());
        return pageStringList;
    }
    
    public with sharing class WPR_PSA_ResourceDetails{
        @AuraEnabled public String resourceName{get;set;}
        @AuraEnabled public String programName{get;set;}
        @AuraEnabled public String clientName{get;set;}
        @AuraEnabled public String serviceLineName{get;set;}
        @AuraEnabled public String projectCodeName{get;set;}
        @AuraEnabled public String assignmentName{get;set;}
        @AuraEnabled public String serviceLineLead{get;set;}
        @AuraEnabled public String region{get;set;}
        @AuraEnabled public String accountCountry{get;set;}
        @AuraEnabled public String language{get;set;}
        @AuraEnabled public String skill{get;set;}
        @AuraEnabled public Boolean utilized{get;set;}
        @AuraEnabled public Decimal scheduleHours{get;set;}
        
    }
    
    public with sharing class WPR_PSA_LanguageDetails{                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
        @AuraEnabled public String resourceSkillSet{get;set;}
        @AuraEnabled public Set<String> options{get;set;}
        @AuraEnabled public Set<String> selectedOptions{get;set;}
        @AuraEnabled public List<WPR_PSA_LanguageSkillSet> skillSets{get;set;}
        @AuraEnabled public List<WPR_PSA_LanguageSkillSet> allSkillSets{get;set;}
        
    }
    
    public with sharing class WPR_PSA_LanguageSkillSet{
        @AuraEnabled public String language{get;set;}
        @AuraEnabled public String rating{get;set;}
        
    }
}