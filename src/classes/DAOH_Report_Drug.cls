public class DAOH_Report_Drug {
    private static Set<String> sanofiRecordTypeNames = new Set<String>{CON_PSA.AGG_REPORT_REC_TYPE_SANOFI_GSO, CON_PSA.AGG_REPORT_REC_TYPE_SANOFI_PVS};
    private static Integer SANOFI_PRODUCTS_MAX_LENGTH = 80;
        
        
        public static void updateAggregateReportSanofiProducts(List<Report_Drug__c> updatedList, Map<Id,Report_Drug__c> existingRecords){
            List<Aggregate_Report__c> updatedARList = new List<Aggregate_Report__c>();
            
            Set<Id> aggRepSetToBeUpdated = new Set<Id>();
            
            for(Report_Drug__c rd : updatedList){
                aggRepSetToBeUpdated.add(rd.Aggregate_Report__c);
            }
             
            Map<Id,List<Report_Drug__c>> agReportIDToExistingReportDrugMap = new Map<Id,List<Report_Drug__c>>();
            List<Report_Drug__c> relatedReportDrugsExist = new SLT_Report_Drug(false).getReportDrugList(aggRepSetToBeUpdated, new Set<String>{'Id','Aggregate_Report__c','Drug__r.Name'}, 'Aggregate_Report__c' );
            List<Report_Drug__c> drugList;
            for(Report_Drug__c drug : relatedReportDrugsExist){
                drugList = agReportIDToExistingReportDrugMap.get(drug.Aggregate_Report__c);
                if(drugList == null){
                    drugList = new List<Report_Drug__c>();
                    agReportIDToExistingReportDrugMap.put(drug.Aggregate_Report__c,drugList);
                }
                drugList.add(drug);
            }
            for(Id agg : agReportIDToExistingReportDrugMap.keyset()){
                Aggregate_Report__c relatedAggReport = new Aggregate_Report__c(Id = agg);
                
                List<Report_Drug__c> repDgList = agReportIDToExistingReportDrugMap.get(agg);
                String sanofiProd = '';
                for(Report_Drug__c rdg : repDgList){
                    if(rdg.Drug__r.Name != null && rdg.Drug__r.Name != ''){
                        if(sanofiProd != null || sanofiProd != ''){
                            sanofiProd = sanofiProd + ',';
                        }
                        sanofiProd += rdg.Drug__r.Name;
                    }
                }
                sanofiProd = sanofiProd.trim().replaceAll(',,', ',').removeEnd(',').removeStart(',');
                if(sanofiProd!=null || sanofiProd!= ''){
                relatedAggReport.Sanofi_Products__c = sanofiProd.abbreviate(SANOFI_PRODUCTS_MAX_LENGTH);
            }
                updatedARList.add(relatedAggReport);
            }
            if(updatedARList.size() > 0){
                update updatedARList;
            }
        }
    
        public static void deleteFromSanofiProducts(List<Report_Drug__c> deletedList){
            Set<Id> aggRepSetToBeUpdated = new Set<Id>();
            List<Aggregate_Report__c> updatedARList = new List<Aggregate_Report__c>();
            for(Report_Drug__c rd : deletedList){
                aggRepSetToBeUpdated.add(rd.Aggregate_Report__c);
            }
            Map<Id,List<Report_Drug__c>> agReportIDToExistingReportDrugMap = new Map<Id,List<Report_Drug__c>>();
            List<Report_Drug__c> relatedReportDrugsExist = new SLT_Report_Drug(false).getReportDrugList(aggRepSetToBeUpdated, new Set<String>{'Id','Aggregate_Report__c','Drug__r.Name'}, 'Aggregate_Report__c' );
            List<Report_Drug__c> drugList;
            for(Report_Drug__c drug : relatedReportDrugsExist){
                drugList = agReportIDToExistingReportDrugMap.get(drug.Aggregate_Report__c);
                if(drugList == null){
                    drugList = new List<Report_Drug__c>();
                    agReportIDToExistingReportDrugMap.put(drug.Aggregate_Report__c,drugList);
                }
                drugList.add(drug);
            }
            for(Id agg : agReportIDToExistingReportDrugMap.keyset()){
                Aggregate_Report__c relatedAggReport = new Aggregate_Report__c(Id = agg);
                List<Report_Drug__c> repDgList = agReportIDToExistingReportDrugMap.get(agg);
                String sanofiProd = '';
                for(Report_Drug__c rdg : repDgList){
                    if(rdg.Drug__r.Name != null && rdg.Drug__r.Name != ''){
                        if(sanofiProd != null && sanofiProd != ''){
                            sanofiProd = sanofiProd + ',';
                        }
                        sanofiProd += rdg.Drug__r.Name;
                    }
                }
                if(sanofiProd != null && sanofiProd != ''){
                sanofiProd = sanofiProd.trim().replaceAll(',,', ',').removeEnd(',').removeStart(',');
                }
                relatedAggReport.Sanofi_Products__c = sanofiProd.abbreviate(SANOFI_PRODUCTS_MAX_LENGTH);
            
                updatedARList.add(relatedAggReport);
            }
            for(Id agId : aggRepSetToBeUpdated){
                if(!agReportIDToExistingReportDrugMap.containsKey(agId)){
                    Aggregate_Report__c relatedAggReportInAggSet = new Aggregate_Report__c(Id = agId);
                    relatedAggReportInAggSet.Sanofi_Products__c = '';
                    updatedARList.add(relatedAggReportInAggSet);
                }
            }
            if(updatedARList.size() > 0){
                update updatedARList;
            }
        }
    
    public static void validateFields(List<Report_Drug__c> updatedList, Map<Id,Report_Drug__c> existingRecords) {
        Set<Id> aggregateReportIdSet = new Set<Id>();
        Set<Id> drugIdSet = new Set<Id>();
        List<Aggregate_Report__c> arList = new List<Aggregate_Report__c>();
        Set<String> arFieldSet = new Set<String>{'Id','Project__r.Service_Line__r.Name'};
        Map<Id,String> arToServiceLineMap = new Map<Id,String>();
        Map<Id,Drug__c> drugsMap = new Map<Id,Drug__c>();
        
        for(Report_Drug__c reportDrug : updatedList) {
            if(reportDrug.Aggregate_Report__c != null && reportDrug.Drug__c != null) {
                aggregateReportIdSet.add(reportDrug.Aggregate_Report__c);
                drugIdSet.add(reportDrug.Drug__c);
            }
        }
        if(aggregateReportIdSet.size() > 0 && drugIdSet.size() > 0) {
           
            Map<Id,Aggregate_Report__c> arMap = new Map<Id,Aggregate_Report__c>([Select Id, Project__r.Service_Line__r.Name
                                                                                 From Aggregate_Report__c
                                                                                 Where Id in: aggregateReportIdSet]);
            drugsMap = new SLT_Drug(false,false).getDrugById(drugIdSet,new Set<String>{'Id','Service_Lines__c'});
                
            for(Report_Drug__c reportDrug : updatedList) {
                if(arMap.containsKey(reportDrug.Aggregate_Report__c) && drugsMap.containsKey(reportDrug.Drug__c)
                && drugsMap.get(reportDrug.Drug__c).Service_Lines__c != null
                && !drugsMap.get(reportDrug.Drug__c).Service_Lines__c.contains(arMap.get(reportDrug.Aggregate_Report__c).Project__r.Service_Line__r.Name)) {
                
                	reportDrug.addError('The selected Drug is not associated with the related Project\'s Service Line. Please select another Drug.');
            	}
            }
        }        
    }
}
