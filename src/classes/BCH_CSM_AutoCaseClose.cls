global class BCH_CSM_AutoCaseClose implements Database.Batchable<sObject>{
    global String[] errors = new List<String>();
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query='select Id,CaseNumber,Status,RecordTypeName__c,LastModifiedDate,Los__c,SubType1__c,SubStatus__c,CaseSource__c,CurrentQueue__r.Name,(Select Id, ParentId,CaseNumber, Status from Cases where ((Status not in (\'Waiting for\',\'Resolved\',\'Closed\',\'Abandoned\',\'Canceled\') and RecordTypeName__c in (\'RandDCase\',\'ActivityPlan\',\'VirtualTrialsCase\')) OR (Status not in (\'Closed\',\'Abandoned\',\'Canceled\') and SubStatus__c != \'Root Cause Analysis\' and RecordTypeName__c = \'TechnologyCase\'))) From Case Where ((RecordTypeName__c = \'TechnologyCase\' AND Last_Modified_by_Agent_Date__c != null AND Last_Modified_by_Agent_Date__c < LAST_N_DAYS:30 AND IsClosed = false AND CurrentQueue__r.Name =\'' + CON_CSM.S_Q_TECHCA_TS + '\') or (ResolvedDatetime__c != null AND ResolvedDatetime__c < LAST_N_DAYS:5 and (( (Status = \'Resolved with Customer\' or (Status = \'Resolved with Customer\' and SubStatus__c = \'Pending Resolution Confirmation\'))  and AFU_TECH__c = false and RecordTypeName__c = \'TechnologyCase\') or (Status = \'Resolved\' and SubStatus__c != \'Automated FU\' and RecordTypeName__c in (\'RandDCase\',\'ActivityPlan\',\'VirtualTrialsCase\')) or (Status = \'Resolved\' and CurrentQueue__c != null and CurrentQueue__r.Name =\'' + CON_CSM.S_DATA_ESQ + '\' and RecordTypeName__c =\'DATACase\'))))';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Case> cases){
        Set<Case> updateCaseist = new Set<Case>();
        List<Id> uParentCases = new List<Id>();
        
        for(Case cas : cases){
            if(cas.cases.isEmpty()) {
                if(cas.RecordTypeName__c == 'TechnologyCase' && cas.CurrentQueue__r.Name == CON_CSM.S_Q_TECHCA_TS){
                    cas.Status = CON_CSM.S_CASE_ABANDONED;
                    updateCaseist.add(cas);
                }else if(cas.RecordTypeName__c == 'ActivityPlan' && cas.Los__c == 'Account Management' && cas.SubType1__c == 'Inform' && !(cas.CaseSource__c == 'GDN/CAS' || cas.CaseSource__c == 'Study Team') ){

                }else if(cas.RecordTypeName__c == 'TechnologyCase' && cas.SubStatus__c  == 'Root Cause Analysis'){

                }else if(cas.RecordTypeName__c != 'DATACase'){
                    cas.Status = 'Closed';
                    cas.AutoClosed__c = true;
                    if(cas.RecordTypeName__c == 'TechnologyCase'){
                        cas.SubStatus__c = 'Closed by Automation';
                        if(cas.SubStatus__c  == 'Pending Resolution Confirmation'){
                            cas.SubStatus__c = 'Unconfirmed';
                        }
                    }
                    updateCaseist.add(cas);
                }else{
                    if(cas.CurrentQueue__c != null){
                        if(cas.CurrentQueue__r.Name.equalsIgnoreCase(CON_CSM.S_DATA_ESQ)){
                            cas.Status = 'Closed';
                            cas.AutoClosed__c = true;
                            updateCaseist.add(cas);
                        }
                    }
                }
                
            }else if(cas.RecordTypeName__c == 'TechnologyCase'){
                for(Case ch : cas.cases){
                    if(ch.Status != 'Resolved with Customer'){
                        cas.Status = 'In Progress';
                        cas.Owner__c = 'Child Open';
                        updateCaseist.add(cas);
                    }
                }
                
            }
        }
        try {
            if(!updateCaseist.isEmpty()){
                List<Case> cList = new List<Case>();
                clist.addAll(updateCaseist);
                update cList;  
            }
            
        } catch(Exception e) {
            errors.add(e.getLineNumber()+' - ' + e.getMessage());
        }
    }
    
    global void finish(Database.BatchableContext BC){
        if(!errors.isEmpty()) {
            string allstring = string.join(errors,',');
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSubject('Errors occurred during BCH_CSM_AutoCaseClose batch process.');
            mail.setTargetObjectId(UserInfo.getUserId());
            mail.setSaveAsActivity(false);
            mail.setPlainTextBody(allstring);

            try{
                Messaging.sendEmail(new Messaging.Email[] { mail });
            } catch(Exception e) {
                
            }
        }

    }
    
}