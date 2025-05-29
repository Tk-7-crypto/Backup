public without sharing class CNT_PSA_CreateDrugReport {
    @AuraEnabled
    public static WPR_PSA_DetailsWrapper getRecordDetils(String recordId){
        WPR_PSA_DetailsWrapper response = new WPR_PSA_DetailsWrapper();
        List<WPR_PSA_OptionsWrapper> optionWrapperList = new List<WPR_PSA_OptionsWrapper>();
        Map<String,String> reportDrugIdToReportDrugIdMap = new Map<String,String>();
        String programId = '';
        String serviceLineName = '';
        Set<String> requestedReportDrugFields = new Set<String>{'Id','Drug__c','Drug__r.Name','Aggregate_Report__r.ProgramID__c'};
        Set<String> requestedDrugFields = new Set<String>{'Id','Name','Service_Lines__c'};
        Set<String> requestedAggregateReportFields = new Set<String>{'Id','Name','ProgramID__c','Project__r.Service_Line__r.name'};
        List<Aggregate_Report__c> aggregateReportList = new SLT_Aggregate_Report().selectAggregateReportsById(new Set<Id>{recordId},requestedAggregateReportFields);
        if(!aggregateReportList.isEmpty()){
            programId = aggregateReportList[0].ProgramID__c;
            if(aggregateReportList[0].Project__r.Service_Line__r.name != null){
               serviceLineName = aggregateReportList[0].Project__r.Service_Line__r.name; 
            }
        }
        if(programId != ''){
            List<Report_Drug__c> reportDrugList = new SLT_PSA_Report_Drug().getReportDrugsByAggregateReportId(new Set<Id>{recordId},requestedReportDrugFields);
            if(!reportDrugList.isEmpty()){
                for(Report_Drug__c reportDrug : reportDrugList){
                    reportDrugIdToReportDrugIdMap.put(reportDrug.Drug__c,reportDrug.Id);
                }
            }
            List<Drug__c> drugList = new SLT_Drug().getActiveDrugByProgramId(new Set<Id>{programId},requestedDrugFields);
            if(!drugList.isEmpty()){
                for(Drug__c drug : drugList){
                    WPR_PSA_OptionsWrapper optionWrapper = new WPR_PSA_OptionsWrapper();
                    if(drug.Service_Lines__c != null 
                       && ((serviceLineName != '' && drug.Service_Lines__c.contains(serviceLineName)) || reportDrugIdToReportDrugIdMap.containsKey(drug.Id))){
                           optionWrapper.label = drug.Name;
                           optionWrapper.value = drug.Id;
                           optionWrapper.reportDrugId = reportDrugIdToReportDrugIdMap.containsKey(drug.Id) ? reportDrugIdToReportDrugIdMap.get(drug.Id) : '';
                           optionWrapper.checked = reportDrugIdToReportDrugIdMap.containsKey(drug.Id);
                           optionWrapper.isOperation = false;
                           optionWrapperList.add(optionWrapper);
                       }
                }
            }
            response.aggregateReportId = recordId;
            response.programId = programId;
            response.serviceLineName = serviceLineName;
            if(!optionWrapperList.isEmpty()){
                response.options = optionWrapperList;
            }
        }
        return response;
    }
    
    @AuraEnabled(cacheable=true)
    public static WPR_PSA_ReportDrugs getReportDrugs(String recordId){
        WPR_PSA_ReportDrugs response = new WPR_PSA_ReportDrugs();
        List<WPR_PSA_DrugLinkWrapper> drugUrlList = new List<WPR_PSA_DrugLinkWrapper>();
        Set<String> requestedReportDrugFields = new Set<String>{'Id','Drug__r.Name', 'Drug__c', 'Program__r.Name','Program__c'};
        List<Report_Drug__c> reportDrugList = new SLT_PSA_Report_Drug().getReportDrugsByAggregateReportId(new Set<Id>{recordId},requestedReportDrugFields);
        if(!reportDrugList.isEmpty()){
            for(Report_Drug__c rd : reportDrugList){
                drugUrlList.add(new WPR_PSA_DrugLinkWrapper(rd.Drug__r.Name,'/lightning/r/Drug__c/'+rd.Drug__c+'/view'));
            }
            response.programName = reportDrugList[0].Program__r.Name;
            response.programLink = '/lightning/r/Drug__c/'+reportDrugList[0].Program__c+'/view';
        }
        if(!drugUrlList.isEmpty()){
            response.reportDrugs = drugUrlList;
        }
        return response;
    }
    
    @AuraEnabled
    public static String saveReportDrugs(List<CNT_PSA_CreateDrugReport.WPR_PSA_OptionsWrapper> records, String aggregateReportId, String programId){
        List<Report_Drug__c> insertToList = new List<Report_Drug__c>();
        List<Report_Drug__c> deleteToList = new List<Report_Drug__c>();
        for(CNT_PSA_CreateDrugReport.WPR_PSA_OptionsWrapper wrapper : records){
            if(wrapper.reportDrugId == '' && wrapper.checked){
                insertToList.add(new Report_Drug__c(Drug__c = wrapper.value, Aggregate_Report__c = aggregateReportId, Program__c = programId));
            }else if(wrapper.reportDrugId != '' && !wrapper.checked){
                deleteToList.add(new Report_Drug__c(Id = wrapper.reportDrugId));
            }
        }
        String returnString ='Success';
        try{
            if(!insertToList.isEmpty()){
                insert insertToList;
            }
            if(!deleteToList.isEmpty()){
                delete deleteToList;
            }
        }catch(Exception e){
            returnString = e.getMessage();
        }
        return returnString;
    }
    public class WPR_PSA_ReportDrugs{
        @AuraEnabled
        public List<WPR_PSA_DrugLinkWrapper> reportDrugs{get;set;}
        @AuraEnabled
        public String programName{get;set;}
        @AuraEnabled
        public String programLink{get;set;}
    } 
    public class WPR_PSA_DrugLinkWrapper{
        @AuraEnabled
        public String drugName{get;set;}
        @AuraEnabled
        public String drugLink{get;set;}
        public WPR_PSA_DrugLinkWrapper(String drugName, String drugLink){
            this.drugName = drugName;
            this.drugLink = drugLink;
        }
    }
    
    public class WPR_PSA_DetailsWrapper{
        @AuraEnabled
        public String aggregateReportId{get;set;}
        @AuraEnabled
        public String programId{get;set;}
        @AuraEnabled
        public String serviceLineName{get;set;}
        @AuraEnabled
        public List<WPR_PSA_OptionsWrapper> options{get;set;}
    }
    
    public class WPR_PSA_OptionsWrapper{
        @AuraEnabled
        public String label{get;set;}
        @AuraEnabled
        public String value{get;set;}
        @AuraEnabled
        public Boolean checked{get;set;}
        @AuraEnabled
        public Boolean isOperation{get;set;}
        @AuraEnabled
        public String reportDrugId{get;set;}
        
    }
}
