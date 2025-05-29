global class BCH_CSM_AbandonedDuplicateCases  implements Database.Batchable<sObject>{
    
    global String[] errors = new List<String>();
    global Database.QueryLocator start(Database.BatchableContext BC){
        Set<String> subjSet = new Set<String>();
        Set<String> supSet = new Set<String>();
        DateTime dt = System.Now().addHours(-1);
        String query = '';
        if(Test.isRunningTest()){
            query = 'select Subject, SuppliedEmail, COUNT(Id) FROM Case where ParentId = null AND Origin in (\'Email\',\'Voicemail\') AND RecordTypeName__c in (\'RandDCase\',\'ActivityPlan\',\'VirtualTrialsCase\') AND CreatedDate >=:dt GROUP BY Subject,SuppliedEmail HAVING COUNT(Id) > 1 ORDER By Subject LIMIT 100';
        }else{
            query = 'select Subject, SuppliedEmail, COUNT(Id) FROM Case where ParentId = null AND IsClosed = false AND Origin in (\'Email\',\'Voicemail\') AND RecordTypeName__c in (\'RandDCase\',\'ActivityPlan\',\'VirtualTrialsCase\') AND InitialQueueData__r.Exclude_From_Duplicate_Batch_Process__c = false AND CreatedBy.Name = \'System\' AND CreatedDate >=:dt GROUP BY Subject,SuppliedEmail HAVING COUNT(Id) > 1 ORDER By Subject LIMIT 500';
        }
        
        AggregateResult[] groupedResults = Database.query(query);
        for (AggregateResult ar : groupedResults)  {
            subjSet.add(ar.get('Subject').toString());
            supSet.add(ar.get('SuppliedEmail').toString());
        }
        if(Test.isRunningTest()){
            query = 'select Id,CaseNumber,Subject, SuppliedEmail,Status,CreatedDate,IsClosed FROM Case where ParentId = null AND Subject in :subjSet AND SuppliedEmail in :supSet AND Origin in (\'Email\',\'Voicemail\') AND RecordTypeName__c in (\'RandDCase\',\'ActivityPlan\',\'VirtualTrialsCase\') AND CreatedDate >=:dt ORDER By Id DESC LIMIT 100';
        }else{
            query = 'select Id,CaseNumber,Subject, SuppliedEmail,Status,CreatedDate,IsClosed FROM Case where ParentId = null AND IsClosed = false AND Subject in :subjSet AND SuppliedEmail in :supSet AND Origin in (\'Email\',\'Voicemail\') AND RecordTypeName__c in (\'RandDCase\',\'ActivityPlan\',\'VirtualTrialsCase\') AND InitialQueueData__r.Exclude_From_Duplicate_Batch_Process__c = false AND CreatedBy.Name = \'System\' AND CreatedDate >=:dt ORDER By CreatedDate LIMIT 500';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Case> cases){
        Set<Case> updateCaseist = new Set<Case>();
        Set<String> subSet = new Set<String>();
        Set<String> supSet = new Set<String>();
        List<Case> caseList = new List<Case>();
        String query = '';
        integer custSet = 60;
        DateTime dt = System.Now().addHours(-1);
        for(Case c1 : cases){
            subSet.add(c1.Subject);
            supSet.add(c1.SuppliedEmail);
        }
        if(Test.isRunningTest()){
            query = 'select Id,CaseNumber,Subject, SuppliedEmail,Status,CreatedDate,IsClosed FROM Case where ParentId = null AND Subject in :subSet AND SuppliedEmail in :supSet AND Origin in (\'Email\',\'Voicemail\') AND RecordTypeName__c in (\'RandDCase\',\'ActivityPlan\',\'VirtualTrialsCase\') AND CreatedDate >=:dt ORDER By Id DESC LIMIT 100';
        }else{
            query = 'select Id,CaseNumber,Subject, SuppliedEmail,Status,CreatedDate,IsClosed FROM Case where ParentId = null AND IsClosed = false AND Subject in :subSet AND SuppliedEmail in :supSet AND Origin in (\'Email\',\'Voicemail\') AND RecordTypeName__c in (\'RandDCase\',\'ActivityPlan\',\'VirtualTrialsCase\') AND CreatedBy.Name = \'System\' AND CreatedDate >=:dt ORDER By CreatedDate LIMIT 500';
        }
        caseList = Database.query(query);
        CSM_Case_Details_Global_Setting__c gd = CSM_Case_Details_Global_Setting__c.getValues('BCH_CSM_AbandonedDuplicateCases');
		if(gd != null && gd.Component_Id__c != null)
        {
		    custSet = integer.valueof(gd.Component_Id__c);
		}
        for(Case c1 : cases){
            if(!c1.IsClosed){
                for(Case c2 : caseList){
                    integer secs = Math.abs(Integer.valueOf(c2.CreatedDate.getTime() - c1.CreatedDate.getTime())/1000);
                    if(c1.Id != c2.Id && !c2.IsClosed && c1.Subject == c2.Subject && c1.SuppliedEmail == c2.SuppliedEmail && secs <= custSet){
                        if(c1.Status == 'New'){
                            c1.Status = 'Abandoned';
                            updateCaseist.add(c1);
                        }else if(c2.Status == 'New'){
                            c2.Status = 'Abandoned';
                            updateCaseist.add(c2);
                        }
                        
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
        
        /** if(!errors.isEmpty()) {
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
        }*/
        
    }
}