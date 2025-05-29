/**
* This is Report Country trigger handler class.
* version : 1.0
*/
public class DAOH_Report_Country {
   
    /**
    * This method will insert record in Audit Log on Inserting/Updating Report Country
    **/
    public static void insertAuditLogOnUpdate(List<Report_Country__c> updatedList,Map<Id,Report_Country__c> existingRecords){
        SRV_PSA_AuditLog.setAuditOnInsertUpdate(updatedList,existingRecords);
    }

    /**
    * This method will insert record in Audit Log on Deleting/UnDeleting Report Country
    **/
    public static void insertAuditLog(List<Report_Country__c> insertList,String operation){
        SRV_PSA_AuditLog.setAuditLogOnDeleteUnDelete(insertList,operation);
    } 
    
    public static void fieldValidations(List<Report_Country__c> updatedList,Map<Id,Report_Country__c> existingRecords){
        Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
        Map<Id, Id> rprtCntryToAggtRprtMap = new Map<Id, Id>();
        List<Id> aggtRprtList = new List<Id>();
        Map<Id,Id> aggrtRptToRecTypeMap = new Map<Id,Id>();
        for(Report_Country__c rprtCntry : updatedList){
            if(!mulesoftSetting.Ignore_Validation_Rules__c) {
                rprtCntryToAggtRprtMap.put(rprtCntry.Id, rprtCntry.Aggregate_Report__c);
                aggtRprtList.add(rprtCntry.Aggregate_Report__c);
            }
        }
        for(Aggregate_Report__c aggRpt : [Select ag.Id, ag.RecordTypeId From Aggregate_Report__c ag where Id IN :aggtRprtList]){
            aggrtRptToRecTypeMap.put(aggRpt.Id, aggRpt.RecordTypeId);
        }
        
        for(Report_Country__c rprtCntry : updatedList){
            if(aggrtRptToRecTypeMap.size()>0){
                String recordTypeName = Schema.SObjectType.Aggregate_Report__c.getRecordTypeInfosById().get(aggrtRptToRecTypeMap.get(rprtCntry.Aggregate_Report__c)).getDeveloperName();
                if(recordTypeName == CON_PSA.AGG_REPORT_REC_TYPE_GENERAL){
                    if(rprtCntry.Actual_Submission_Date__c > Date.today()){
                        rprtCntry.addError('You may not enter future dates in the \'Actual Submission Date field\'.');
                    }
                    if(rprtCntry.Report_Due_to_Reg_Agency__c != null && (rprtCntry.Actual_Submission_Date__c > rprtCntry.Report_Due_to_Reg_Agency__c
                                                                        &&(rprtCntry.Submitted_to_Reg_Late_Reason__c == null || rprtCntry.Submitted_to_Reg_Late_Responsibility__c == null))){
                        rprtCntry.addError('The \'Submitted to Reg Late Responsibility\' and \'Submitted to Reg Late Reason\' fields cannot be empty as the \'Actual Submission Date\' is after \'Report due to Reg Agency\'.');
                    }
                }
                if(recordTypeName == CON_PSA.AGG_REPORT_REC_TYPE_SANDOZ && rprtCntry.License_Partner__c == true && rprtCntry.License_partner_PVAs__c == null){
                    if(Trigger.isUpdate){
                    	rprtCntry.addError('\'License partner PVAs\' should have some value apart from \'None\'.');
                    }
                    else if(Trigger.isInsert){
                        rprtCntry.addError('Save the record and then add License partner details.');
                    }
                }
                if(Trigger.isInsert 
                   && rprtCntry.License_partner_PVAs__c != null){
                       rprtCntry.addError('License Partner PVAs will be selected only for Sandoz aggregate report.');
                }
            }
        }
    }
}
