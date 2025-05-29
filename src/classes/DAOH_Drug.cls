public class DAOH_Drug {
    private static Integer SANOFI_PRODUCTS_MAX_LENGTH = 80;

    public static void updateSanofiProductsOnDrugUpdate(List<Drug__c> updatedList, Map<Id,Drug__c> existingRecords){
        List<Id> drugIdList = new List<Id>();
        Set<Id> aggRprtIdSetToBeUpdated = new Set<Id>(); 
        List<Aggregate_Report__c> aggRprtListToBeUpdated = new List<Aggregate_Report__c>();
        for(Drug__c drug : updatedList){
            if(existingRecords.get(drug.id).Name != null && existingRecords.get(drug.id).Name != drug.Name){
            drugIdList.add(drug.Id);
            }
        }
        for(Report_Drug__c rep : [Select rd.Id, rd.Aggregate_Report__c, rd.Drug__c from Report_Drug__c rd where rd.Drug__c in: drugIdList]){
            aggRprtIdSetToBeUpdated.add(rep.Aggregate_Report__c);
        }
        Map<Id,List<Report_Drug__c>> agReportIDToExistingReportDrugMap = new Map<Id,List<Report_Drug__c>>();
        List<Report_Drug__c> relatedReportDrugsExist = new SLT_Report_Drug(false).getReportDrugList(aggRprtIdSetToBeUpdated, new Set<String>{'Id','Aggregate_Report__c','Drug__r.Name'}, 'Aggregate_Report__c' );
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
                aggRprtListToBeUpdated.add(relatedAggReport);
            }
            
        if(aggRprtListToBeUpdated.size()>0){
            update aggRprtListToBeUpdated;
        }
    }
    
    public static void deleteFromSanofiProducts(List<Drug__c> deletedList){
        List<Id> drugIdList = new List<Id>();
        List<Id> aggRprtIdListToBeUpdated = new List<Id>(); 
        Set<Id> aggRepSetToBeUpdated = new Set<Id>();
        List<Aggregate_Report__c> aggRprtListToBeUpdated = new List<Aggregate_Report__c>();
        for(Drug__c drug : deletedList){
            drugIdList.add(drug.Id);            
        }
        for(Report_Drug__c rep : [Select rd.Id, rd.Aggregate_Report__c, rd.Drug__c from Report_Drug__c rd where rd.Drug__c in: drugIdList]){
            aggRepSetToBeUpdated.add(rep.Aggregate_Report__c);
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
                    if(!drugIdList.contains(rdg.Drug__c)){
                        if(rdg.Drug__r.Name != null && rdg.Drug__r.Name != ''){
                        sanofiProd += rdg.Drug__r.Name + ',';
                    	}
                    }
                    
                }
                sanofiProd = sanofiProd.trim().replaceAll(',,', ',').removeEnd(',').removeStart(',');
                if(sanofiProd!=null || sanofiProd!= ''){
                relatedAggReport.Sanofi_Products__c = sanofiProd.abbreviate(SANOFI_PRODUCTS_MAX_LENGTH);
            }
                aggRprtListToBeUpdated.add(relatedAggReport);
            }
        
        if(aggRprtListToBeUpdated.size()>0){
            update aggRprtListToBeUpdated;
        }
    }
    
    /**
    * This method will insert record in Audit Log on Inserting/Updating Drug
    **/
    public static void insertAuditLogOnUpdate(List<Drug__c> updatedList,Map<Id,Drug__c> existingRecords){
        SRV_PSA_AuditLog.setAuditOnInsertUpdate(updatedList,existingRecords);
    }

    /**
    * This method will insert record in Audit Log on Deleting/UnDeleting Drug
    **/
    public static void insertAuditLog(List<Drug__c> insertList,String operation){
        SRV_PSA_AuditLog.setAuditLogOnDeleteUnDelete(insertList,operation);
    }
    
    /**
    * This method will prevent creation of duplicate drug
    **/
    public static void preventDuplicateRecords(List<Drug__c> newList,Map<Id,Drug__c> existingRecords){
        Set<Id> programIds = new Set<Id>();
        Map<String, Drug__c > mapOfDrug = new  Map<String, Drug__c >();
        for( Drug__c drug : newList ){
            if( ( Trigger.isInsert 
                  && drug.Program__c != null )
               || ( Trigger.isUpdate 
                    && drug.Program__c != null  
                    && ( drug.Service_Lines__c != existingRecords.get( drug.Id ).Service_Lines__c 
                         || drug.Name != existingRecords.get( drug.Id ).Name 
                         || drug.Therapeutic_Area__c != existingRecords.get( drug.Id ).Therapeutic_Area__c 
                         || drug.Indication__c != existingRecords.get( drug.Id ).Indication__c 
                        ) 
                   )
              ){
                programIds.add( drug.Program__c );
                mapOfDrug.put( drug.Service_Lines__c +'*'+ drug.Name +'*'+ drug.Therapeutic_Area__c +'*'+ drug.Indication__c ,drug  );
            }
        }
        for( Drug__c drug : [ SELECT Id, Program__c, Service_Lines__c, Name, Therapeutic_Area__c, Indication__c 
                             FROM Drug__c
                             WHERE Program__c IN : programIds
                            ] )
        {
            if( mapOfDrug.containsKey( drug.Service_Lines__c +'*'+ drug.Name +'*'+ drug.Therapeutic_Area__c +'*'+ drug.Indication__c ) && mapOfDrug.get( drug.Service_Lines__c +'*'+ drug.Name +'*'+ drug.Therapeutic_Area__c +'*'+ drug.Indication__c ) != null ){
                if( drug.Service_Lines__c == mapOfDrug.get( drug.Service_Lines__c +'*'+ drug.Name +'*'+ drug.Therapeutic_Area__c +'*'+ drug.Indication__c ).Service_Lines__c && drug.Name == mapOfDrug.get( drug.Service_Lines__c +'*'+ drug.Name +'*'+ drug.Therapeutic_Area__c +'*'+ drug.Indication__c ).Name
                   && drug.Therapeutic_Area__c == mapOfDrug.get( drug.Service_Lines__c +'*'+ drug.Name +'*'+ drug.Therapeutic_Area__c +'*'+ drug.Indication__c ).Therapeutic_Area__c && drug.Indication__c == mapOfDrug.get( drug.Service_Lines__c +'*'+ drug.Name +'*'+ drug.Therapeutic_Area__c +'*'+ drug.Indication__c ).Indication__c){
                    mapOfDrug.get( drug.Service_Lines__c +'*'+ drug.Name +'*'+ drug.Therapeutic_Area__c +'*'+ drug.Indication__c ).addError( 'The Drug Name and Service Line combination already exists on the Program' );
                    break;
                }
            }            
        }
    }
    public static void preventDeactiveDrug( List<Drug__c> newList,Map<Id,Drug__c> existingRecords ){
        Boolean hasAccess = false;
        List<PermissionSetAssignment> PermissionList = [SELECT AssigneeId 
                                                        FROM PermissionSetAssignment 
                                                        WHERE PermissionSet.Name = 'RDS_Admin' 
                                                        AND AssigneeId = :userInfo.getUserId() 
                                                        LIMIT 1];
        if( PermissionList.size() > 0) {
            hasAccess  = true;  
        }
        for( Drug__c drug : newList ){
            if( ( Trigger.isUpdate 
                 &&  drug.Active__c != existingRecords.get( drug.Id ).Active__c ) 
               && hasAccess == FALSE ){
                   drug.addError('You are not authorize to set active/inactive this drug.');
               }
        }
    }
}
