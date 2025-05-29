public class DAOH_LiveChatTranscript {
    
    public static void searchOrCreateContactLead(List<LiveChatTranscript> newList){
        Set<String> chatEmail = new Set<String>();
        Set<String> chatName = new Set<String>();
        Set<String> caseSubject = new Set<String>();
        List<Contact> contactList = new List<Contact>();
        Set<Id> caseIds = new Set<Id>();
        Map<String,Lead> leadMap = new Map<String,Lead>();
        List<Lead> leadList = new List<Lead>();
        for(LiveChatTranscript chat : newList){
            if(chat.Email__c != null){
                chatEmail.add(chat.Email__c);    
            }
            if(chat.FirstName__c != null && chat.LastName__c != null){
                chatName.add(chat.FirstName__c +' '+ chat.LastName__c);    
            }
            if(chat.Status == CON_CSM.S_COMPLETED && chat.OwnerId == CON_CSM.U_AUTOPROCESS_ID && chat.CaseId != null){
                caseIds.add(chat.CaseId);
            }
        }
        if(caseIds != null && !caseIds.isEmpty()){
            List<Case> caseList = new SLT_Case().selectById(caseIds);
            if(caseList != null && !caseList.isEmpty()){
                for(Case caseRecord : caseList){
                    if(caseRecord.OwnerId == CON_CSM.U_AUTOPROCESS_ID && caseRecord.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T){
                        caseRecord.Status = CON_CSM.S_CLOSED;
                    }
                }
                try{
                    update caseList;
                }
                catch(Exception ex){
                    ex.getStackTraceString();
                }
            }
        }
        if(!chatEmail.isEmpty() && chatEmail.size() > 0){
            System.debug('--If Contact Check--');
            try{
                contactList = new SLT_Contact().selectByEmailIdList(chatEmail);
            }catch(DmlException e){
                System.debug('Error Occured while saving'+e);
            }
            if(contactList != null && !contactList.isEmpty() && contactList.size() >0){
                System.debug('--Contact--');
                for(LiveChatTranscript chat : newList){
                    for(Contact con : contactList){
                        if(chat.Email__c.equalsIgnoreCase(con.Email) && chat.ContactId == null){
                            chat.ContactId = con.Id;
                        }
                    }
                }
                        
            }else{
                System.debug('--Else Lead Check--');
                try{
                    leadList = Database.query('select Id,Email,Name,FirstName from Lead Where (Name in :chatName or Email in :chatEmail) LIMIT 1');
                    System.debug('--leadList-- '+leadList.size());
                }catch(DmlException e){
                    System.debug('Error Occured while saving'+e);
                }
                if(leadList != null && !leadList.isEmpty()){
                    for(LiveChatTranscript chat : newList){
                        for(Lead ld : leadList){
                            if((ld.Name.equalsIgnoreCase(chat.FirstName__c +' '+ chat.LastName__c) || chat.Email__c.equalsIgnoreCase(ld.Email)) && chat.LeadId == null){
                                chat.LeadId = ld.Id;
                            }
                        }
                    }
                    
                }
            }
            if(contactList.isEmpty() && leadList.isEmpty()){
                System.debug('--Lead Create--');
                Lead led = null;
                for(LiveChatTranscript chat : newList){
                    if(chat.LeadId == null && chat.LastName__c !=null && (Test.isRunningTest() || chat.LiveChatDeploymentId == '5726A000000hBPlQAM')){
                        led = new Lead(FirstName = chat.FirstName__c, LastName = chat.LastName__c, Email = chat.Email__c, Title = 'Live Chat', Company = chat.VisitorNetwork, OwnerId = UserInfo.getUserId());
                        leadMap.put(chat.Id,led);    
                    }
                    
                }
                try{
                    if(!leadMap.isEmpty() && !leadMap.values().isEmpty() && leadMap.values().size() > 0){
                        insert leadMap.values();   
                    }
                    
                }catch(DmlException e){
                    System.debug('Error Occured while saving'+e);
                }
                
                for(LiveChatTranscript chat : newList){
                    if(leadMap.containsKey(chat.Id)){
                        chat.LeadId = leadMap.get(chat.Id).Id;
                    }
                }
            }
        }
        
    }
    
    
    /*public static void createTasktoContactOrLead(List<LiveChatTranscript> newList,Map<Id, LiveChatTranscript> oldMap){
       Map<String,LiveChatTranscript> contactIds = new Map<String,LiveChatTranscript>();
       Map<String,LiveChatTranscript> leadIds = new Map<String,LiveChatTranscript>();
       List<Task> taskList = new List<Task>();
       Task task = null;
        for(LiveChatTranscript chat : newList){
            if((Test.isRunningTest() || chat.LiveChatDeploymentId == '5726A000000hBPlQAM') && chat.Email__c != null && !chat.Status.equalsIgnoreCase(oldMap.get(chat.Id).Status) && CON_CSM.S_COMPLETED.equalsIgnoreCase(chat.Status)){
                if(chat.LeadId != null){
                    leadIds.put(chat.LeadId,chat);
                }else if(chat.ContactId != null){
                    contactIds.put(chat.ContactId,chat);
                }
            }
        }
        Schema.DescribeSObjectResult d = Schema.SObjectType.Task; 
        Map<String,Schema.RecordTypeInfo> rtMapByName = d.getRecordTypeInfosByName();
        Schema.RecordTypeInfo rtByName =  rtMapByName.get('MQL Task');
        if(!leadIds.isEmpty()){
            for(String lead : leadIds.keySet()){
                System.debug('Case Id : '+leadIds.get(lead).CaseId);
                task = new Task(RecordTypeId = rtByName.getRecordTypeId(),Subject = 'Chat', WhoId = lead, ActivityDate= System.today(), Type = 'Other', OwnerId = UserInfo.getUserId(), Description = leadIds.get(lead).Body );
                taskList.add(task);
            }
            
        }else if(!contactIds.isEmpty()){
            for(String contact : contactIds.keySet()){
                System.debug('Case Id : '+contactIds.get(contact).CaseId);
                task = new Task(RecordTypeId = rtByName.getRecordTypeId(),Subject = 'Chat', WhoId = contact, ActivityDate= System.today(), Type = 'Other', OwnerId = UserInfo.getUserId(), Description = contactIds.get(contact).Body );
                taskList.add(task);
            }
        }
        
        if(!taskList.isEmpty()){
            try{
                insert taskList; 
                System.debug('taskList : '+taskList);
            }catch(DmlException e){
                System.debug('Error Occured while saving: '+e);
            }
        }
    }*/
    
    /**
    * This method is used for changing the case owner from Automated Process to Current User 
    * @params  newList List<LiveChatTranscript>
    * @return  void
    */
    public static void changeCaseOwner(List<LiveChatTranscript> newList){
        Set<Id> caseIds = new Set<Id>();
        List<Case> caseList = new List<Case>();
        List<Case> updateList = new List<Case>();
        for(LiveChatTranscript chat : newList){
            if(chat.CaseId != null){
                caseIds.add(chat.CaseId);
            }
        }
        
        if(!caseIds.isEmpty()){
            caseList = new SLT_Case().selectByCaseIdList(caseIds, new Set<String>{'Id','Owner__c'});
            for(Case cs : caseList){
               cs.Owner__c = UserInfo.getUserId(); 
                updateList.add(cs);
            }
        }
            
        if(!updateList.isEmpty()){
            try{
                Update updateList;   
            }catch(DmlException e){
                System.debug('Error Occured while saving: '+e);
            }
        }
    }
    
}