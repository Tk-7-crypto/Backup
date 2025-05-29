public class DAOH_CSMCreateForms {

    public static void updateTagOnCase(List<CSM_Create_Forms__c> newList) {
        Set<Id> caseIdSet = new Set<Id>();
        
        for(CSM_Create_Forms__c csmForm: newList) {
            caseIdSet.add(csmForm.Case__c);
        }
        List<Case> caseListToUpdate = new List<Case>();
        if(caseIdSet.size() > 0) {
            Map<Id, Set<String>> csmFormListByCaseIdMap = new Map<Id, Set<String>>();
            List<CSM_Create_Forms__c> csmFormList = [SELECT Id, Case__c, Form_Request_Type__c FROM CSM_Create_Forms__c WHERE Case__c IN: caseIdSet];
            for(CSM_Create_Forms__c csmForm: csmFormList) {
                if (!csmFormListByCaseIdMap.containsKey(csmForm.Case__c)) {
                    csmFormListByCaseIdMap.put(csmForm.Case__c, new Set<String>{csmForm.Form_Request_Type__c.left(1)});
                } 
                Set<String> temp = csmFormListByCaseIdMap.get(csmForm.Case__c);
                temp.add(csmForm.Form_Request_Type__c.left(1));
            }

            for(Id key: csmFormListByCaseIdMap.keySet()) {
                Case caseRecord = new Case(Id = key);
                caseRecord.Tag__c = csmFormListByCaseIdMap.get(key).toString();
                caseListToUpdate.add(caseRecord);
            }
        }
        if(caseListToUpdate.size() > 0) {
            update caseListToUpdate;
        }
    }

    public static void checkOfferingRecords(List<CSM_Create_Forms__c> newList) {
        Set<Id> cOSet = new Set<Id>();
        Set<String> strSet = new Set<String>();
        for(CSM_Create_Forms__c o : newList) {
            if(o.ReportNumber__c != null && (o.ReportClientNumber__c != null || o.ReportClientNumber2__c != null)){
                String clientReport = '';
                integer i = 0;
                if(o.ReportClientNumber__c != null && o.ReportNumber__c != null){
                    List<String> clients = o.ReportClientNumber__c.split(';');
                    List<String> reports = o.ReportNumber__c.split(';');
                    for(String  c: clients){
                        for(String  r: reports){
                            clientReport += c+'-'+r+',';
                            i++;
                        }
                    }
                    o.ClientNumber_ReportNumber__c = clientReport.removeEnd(',');
                    o.Count_of_Client_Report_Numbers__c = i;
                } 
                if(o.ReportClientNumber2__c != null && o.ReportNumber__c != null){
                    List<String> clients = o.ReportClientNumber2__c.split(';');
                    List<String> reports = o.ReportNumber__c.split(';');
                    for(String  c: clients){
                        for(String  r: reports){
                            clientReport += c+'-'+r+',';
                            i++;
                        }
                    }
                    o.ClientNumber_ReportNumber__c = clientReport.removeEnd(',');
                    o.Count_of_Client_Report_Numbers__c = i;
                }
            }else if(o.ReportClientNumber__c != null || o.ReportClientNumber2__c != null){
                String clientReport = o.ReportClientNumber__c != null ? o.ReportClientNumber__c.replace(';', ','):'';
                clientReport += o.ReportClientNumber2__c != null ? o.ReportClientNumber2__c.replace(';', ',') : '';
                o.ClientNumber_ReportNumber__c = clientReport;
            }else if(o.ReportNumber__c != null){
                o.ClientNumber_ReportNumber__c = o.ReportNumber__c != null ? o.ReportNumber__c.replace(';', ',') : '';
            }
        }
    }
    
}
