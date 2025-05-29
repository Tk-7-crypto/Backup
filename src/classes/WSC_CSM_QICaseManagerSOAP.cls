global with sharing class WSC_CSM_QICaseManagerSOAP {
    
    global class CaseInfo {
        webservice String CaseNumber;
        webservice String Subject;
        webservice String Description;
        webservice String Status;
        webservice String resolution;
        webservice String Priority;
        webservice String lastUpdatedBy;
        
    }
    
    global class MessageResponse {
        webservice String status;
        webservice String message;
        webservice String caseNumber;
        webservice String caseId;
    }
    
    global class attachments_element {
        webservice WSC_CSM_QICaseManagerSOAP.attachment_element[] attachment;
    }
    global class attachment_element {
        webservice String reference;
        webservice String filename;
        webservice String description;
        webservice DateTime created;
        webservice DateTime updated;
        webservice Integer size;
        webservice String data;
    }
    
    webservice static MessageResponse createCasewithAccountId(String contactEmail,String subject,String description, String productName,String subtype1,String subtype2,String priority,String currentQueue,String caseSource,String AccountId,String ContactId) {
        MessageResponse messageResponse = new MessageResponse();
        Contact cont = null;
        Case thisCase = null;
        List<Case> caseList = null;
        try{
            cont = new SLT_Contact().selectByAccContactId(AccountId,ContactId);
            
        }catch(System.QueryException e){
            messageResponse.status = 'Error';
            messageResponse.message = 'The contact '+ contactEmail +' is not found in our Customer Service Management system. Please contact you usual helpdesk center.';  
        }
        if(cont != null){
            Map<String,Schema.RecordTypeInfo> rt_Map = Case.sObjectType.getDescribe().getRecordTypeInfosByName();
            
            List<CSM_QI_Case_Categorization__c> categorizations= null;
            List<Asset> assets=null;
            List<Queue_User_Relationship__c> caseQueue = new SLT_QueueUserRelationshipC().selectByQueueName(currentQueue,new Set<String>{'Id','Name'},UserInfo.getUserId());
            if(caseQueue.isEmpty()){
                throw new System.ListException('Current Queue : '+ currentQueue +' is not found in our Customer Service Management system. Please contact you usual helpdesk center.');  
            }
            categorizations = new SLT_CaseCategorization().getCaseCategorizationByFilter('Product__r.Name=\''+productName+'\' and SubType1__c=\''+subtype1+'\' and SubType2__c=\''+subtype2+'\'');
            if (categorizations.isEmpty() == false) {
                assets = new SLT_Asset().selectByAccountIdAndProductId(new Set<Id> {cont.AccountId},new Set<Id>{categorizations[0].Product__c});
                thisCase = new Case(AccountId = cont.AccountId,ContactId = cont.Id,Subject = subject,Description = description,Status = 'New',Origin = 'External Service', Device__c='Laptop' ,recordTypeID = rt_map.get('TechnologyCase').getRecordTypeId(), CaseSource__c = caseSource);
                if(!assets.isEmpty()){
                    thisCase.AssetId = assets[0].Id;    
                }
                if(!categorizations.isEmpty()){
                    thisCase.Case_CategorizationId__c = categorizations[0].Id;
                    thisCase.ProductName__c = categorizations[0].ProductName__c;
                    thisCase.SubType1__c = categorizations[0].SubType1__c;
                    thisCase.SubType2__c = categorizations[0].SubType2__c;
                    thisCase.SubType3__c = '--none--';
                }
                
                thisCase.CurrentQueue__c = caseQueue[0].Id;
                if(priority != null && CON_CSM.PL_TECHNO_UI_CASE_PRIORITY.get(priority.capitalize()) != null){
                    List<String> pList = CON_CSM.PL_TECHNO_UI_CASE_PRIORITY.get(priority.capitalize()).split('~');
                    if(pList != null && !pList.isEmpty()){
                        thisCase.Urgency__c = pList[0];
                        thisCase.Techno_Impact__c = pList[1];
                    }
                }
                insert thisCase;
                caseList = new SLT_Case().selectByCaseIdList(new Set<Id>{thisCase.Id} ,new Set<String>{'Id','CaseNumber'}); 
                messageResponse.status = 'Success';
                messageResponse.message = 'Success';
                messageResponse.caseNumber = caseList[0].CaseNumber;
                
            }else{
                messageResponse.status = 'Error';
                messageResponse.message = 'productName : '+ productName +' subtype1 : '+ subtype1 +' subtype2 : '+ subtype2 +' is not found in our Customer Service Management system. Please contact you usual helpdesk center.';  
            }
            
        }
        return messageResponse;  
    }
    
    webservice static String createCase(String contactEmail,String subject,String description, String productName,String subtype1,String subtype2,String priority,String currentQueue,String caseSource) {
        
        Contact cont = null;
        Case thisCase = null;
        List<Case> caseList = null;
        try{
            cont = new SLT_Contact().selectByEmail(contactEmail);
            
        }catch(System.QueryException e){
            throw new System.QueryException('The contact '+ contactEmail +' is not found in our Customer Service Management system. Please contact you usual helpdesk center.');  
        }
        if(cont != null){
            Map<String,Schema.RecordTypeInfo> rt_Map = Case.sObjectType.getDescribe().getRecordTypeInfosByName();
            
            List<CSM_QI_Case_Categorization__c> categorizations= null;
            List<Asset> assets=null;
            List<Queue_User_Relationship__c> caseQueue = new SLT_QueueUserRelationshipC().selectByQueueName(currentQueue,new Set<String>{'Id','Name'},UserInfo.getUserId());
            if(caseQueue.isEmpty()){
               throw new System.ListException('Current Queue : '+ currentQueue +' is not found in our Customer Service Management system. Please contact you usual helpdesk center.');  
            }
            categorizations = new SLT_CaseCategorization().getCaseCategorizationByFilter('Product__r.Name=\''+productName+'\' and SubType1__c=\''+subtype1+'\' and SubType2__c=\''+subtype2+'\'');
            if (categorizations.isEmpty() == false) {
                assets = new SLT_Asset().selectByAccountIdAndProductId(new Set<Id> {cont.AccountId},new Set<Id>{categorizations[0].Product__c});
                thisCase = new Case(AccountId = cont.AccountId,ContactId = cont.Id,Subject = subject,Description = description,Status = 'New',Origin = 'External Service', Device__c='Laptop' ,recordTypeID = rt_map.get('TechnologyCase').getRecordTypeId(), CaseSource__c = caseSource);
                thisCase.AssetId=assets[0].Id;
                thisCase.Case_CategorizationId__c = categorizations[0].Id;
                thisCase.ProductName__c = categorizations[0].ProductName__c;
                thisCase.SubType1__c = categorizations[0].SubType1__c;
                thisCase.SubType2__c = categorizations[0].SubType2__c;
                thisCase.CurrentQueue__c = caseQueue[0].Id;
                if(priority != null && CON_CSM.PL_TECHNO_UI_CASE_PRIORITY.get(priority.capitalize()) != null){
                    List<String> pList = CON_CSM.PL_TECHNO_UI_CASE_PRIORITY.get(priority.capitalize()).split('~');
                    if(pList != null && !pList.isEmpty()){
                        thisCase.Urgency__c = pList[0];
                        thisCase.Techno_Impact__c = pList[1];
                    }
                }
                insert thisCase;
                caseList = new SLT_Case().selectByCaseIdList(new Set<Id>{thisCase.Id} ,new Set<String>{'Id','CaseNumber'}); 
               
                return caseList[0].CaseNumber;
                
            }else{
             throw new System.QueryException('productName : '+ productName +' subtype1 : '+ subtype1 +' subtype2 : '+ subtype2 +' is not found in our Customer Service Management system. Please contact you usual helpdesk center.');  
            }
            
        }else{
            return null;  
        }
    }
    
    webservice static MessageResponse createCaseSmartIT(String contactEmail,String contactId,String accountId,String mailCC,String acknowledgmentEmail,String subject,String description,String status,String subStatus, String productName,String subtype1,String subtype2,String subtype3,String priority,String currentQueue,String caseSource,String resolution,String techResolution,String rootCause,String rootCauseReason,String envType,attachments_element attachments) {
        Contact cont = null;
        Case thisCase = null;
        List<Case> caseList = null;
        MessageResponse mr = new MessageResponse();
        try{
            if(contactEmail != null){
                cont = new SLT_Contact().selectByEmailId(contactEmail);
                accountId = cont.AccountId;
            }
        }catch(System.QueryException e){
        }
            Map<String,Schema.RecordTypeInfo> rt_Map = Case.sObjectType.getDescribe().getRecordTypeInfosByName();
            List<CSM_QI_Case_Categorization__c> categorizations= null;
            List<Asset> assets=null;
            List<Queue_User_Relationship__c> caseQueue = new SLT_QueueUserRelationshipC().selectByQueueName(currentQueue,new Set<String>{'Id','Name'},UserInfo.getUserId());
            if(caseQueue.isEmpty()){
               throw new System.ListException('Current Queue : '+ currentQueue +' is not found in our Customer Service Management system. Please contact you usual helpdesk center.');  
            }
            if(subtype3 == null){
                subtype3 = '-none-';
            }
            thisCase = new Case(Subject = subject,Description = description.stripHtmlTags(),Status = 'New',SendAutomaticAcknowledgmentEmail__c = 'No',Origin = 'External Service', Device__c='Laptop' ,recordTypeID = rt_map.get('TechnologyCase').getRecordTypeId(), CaseSource__c = caseSource);
            categorizations = new SLT_CaseCategorization().getCaseCategorizationByFilter('ProductName__c=\''+productName+'\' and SubType1__c=\''+subtype1+'\' and SubType2__c=\''+subtype2+'\' and SubType3__c in (\''+subtype3+'\','+'\'--none--\')');
            if (accountId != null && !categorizations.isEmpty()) {
                thisCase.Case_CategorizationId__c = categorizations[0].Id;
                thisCase.ProductName__c = categorizations[0].ProductName__c;
                thisCase.SubType1__c = categorizations[0].SubType1__c;
                thisCase.SubType2__c = categorizations[0].SubType2__c;
                thisCase.SubType3__c = categorizations[0].SubType3__c;
                assets = new SLT_Asset().selectByAccountIdAndProductId(new Set<Id> {accountId},new Set<Id>{categorizations[0].Product__c});
            }
        if(envType != null){
            thisCase.EnvironmentType__c = envType;
        }
        if(status == 'Resolved with Customer'){            
            thisCase.RootCause__c = 'Other';
            thisCase.Root_Cause_Reason__c = 'Other Service';
            thisCase.Resolution__c = 'Auto closed by SmartIT';
        }
        if(rootCause != null){
            thisCase.RootCause__c = rootCause;
        }
        if(techResolution != null){
            thisCase.Technical_Resolution_Internal_Use_only__c = techResolution;
        }
        if(resolution != null){
           thisCase.Resolution__c = resolution;
        }
        if(rootCauseReason != null){
            thisCase.Root_Cause_Reason__c = rootCauseReason;
        }
        if(contactEmail != null){
            thisCase.SuppliedEmail = contactEmail;
        }
        
            if(status != null){
                thisCase.Status = status;
            }
            if(subStatus != null){
                thisCase.Substatus__c = subStatus;
            }
            if(accountId != null){
                thisCase.AccountId = accountId;
            }
            if(cont != null){
                thisCase.ContactId = cont.Id;
            }else{
                thisCase.NoContactKnown__c = true;
            }
            if(assets != null && !assets.isEmpty()){
                thisCase.AssetId = assets[0].Id;
            }
            if(caseQueue != null && !caseQueue.isEmpty()){
              thisCase.CurrentQueue__c = caseQueue[0].Id;  
            }
            if(acknowledgmentEmail != null){
                thisCase.SendAutomaticAcknowledgmentEmail__c = acknowledgmentEmail;
            }
            if(mailCC != null){
                thisCase.Mail_CC_List__c = mailCC;
            }
            if(priority != null && CON_CSM.PL_TECHNO_UI_CASE_PRIORITY.get(priority.capitalize()) != null){
                List<String> pList = CON_CSM.PL_TECHNO_UI_CASE_PRIORITY.get(priority.capitalize()).split('~');
                if(pList != null && !pList.isEmpty()){
                    thisCase.Urgency__c = pList[0];
                    thisCase.Techno_Impact__c = pList[1];
                }
            }
        insert thisCase;
        caseList = new SLT_Case().selectByCaseIdList(new Set<Id>{thisCase.Id} ,new Set<String>{'Id','CaseNumber'});
        if(caseList != null && !caseList.isEmpty()){
            mr.caseNumber= caseList[0].CaseNumber;
            mr.caseId= caseList[0].Id;
            mr.status = 'Success';
            mr.message = 'Success';
        }
        List<ContentDocumentLink> cdl = new List<ContentDocumentLink>();
        List<String> newfiles = new List<String>();
        list<ContentVersion> docToInsert = new list<ContentVersion>();
        if(attachments != null)
        {
            String caseId = thisCase.Id;
            for(WSC_CSM_QICaseManagerSOAP.attachment_element att : attachments.attachment) {
                List<String> parts = new List<String>();
                if(att.filename != null && att.filename.length()>0){
                    if(att.filename != null){ parts = att.filename.split('\\.'); }
                    ContentVersion conVI = new ContentVersion(FirstPublishLocationId = thisCase.Id, Title = parts.size() > 0 ? parts[0] : att.filename,
                                                              PathOnClient = att.filename, VersionData = EncodingUtil.base64Decode(att.data),IsMajorVersion = false);
                    docToInsert.add(conVI);
                    newfiles.add(parts.size() > 0 ? parts[0] : att.filename);   
                }
                
            }
            try{
                if(docToInsert != null && !docToInsert.isEmpty()){
                    insert docToInsert;
                    cdl = Database.query('SELECT ContentDocumentId,ContentDocument.Title, ContentDocument.LastModifiedDate, ContentDocument.CreatedBy.Id, ContentDocument.CreatedBy.Name, ContentDocument.FileExtension, ContentDocument.ContentSize, LinkedEntityId, Visibility , LinkedEntity.Name , LinkedEntity.Type FROM ContentDocumentLink where LinkedEntityId =: caseId and ContentDocument.Title in :newfiles and Visibility = \'InternalUsers\'');
                    for(ContentDocumentLink cd : cdl){
                        cd.Visibility = CON_CSM.S_ALL_USERS;
                    }
                    if(cdl != null && !cdl.isEmpty()){
                        update cdl;
                    }                    
                }
            }catch(Exception e){
                mr.status = 'Error';
                mr.message = 'Attachment insertion failure.';
            }
        }
        return mr;
    }
    
    webservice static CaseInfo getCaseById(String caseId) {
        Case result = null;
        CaseInfo caseIn = null;
        try{
            result =  new SLT_Case().selectByCaseNumberList(caseId, new Set<String>{'CaseNumber','Subject','Status','Description','Priority','LastModifiedById'});
        }catch(System.QueryException e){
            throw new System.QueryException('Case Number : '+ caseId +' is not found in our Customer Service Management system. Please contact you usual helpdesk center.');  
        }
        
        if(result != null){
            caseIn = new CaseInfo();
            caseIn.CaseNumber = result.CaseNumber;
            caseIn.Subject = result.Subject;
            caseIn.Description = result.Description;
            caseIn.Status = result.Status;
            caseIn.Priority = result.Priority;
            Map<Id,User> userData = new SLT_User().selectByUserId(new Set<Id>{result.LastModifiedById}, new Set<String>{'Id','Name'});
            if(userData.isEmpty() == false){
                caseIn.lastUpdatedBy = userData.get(result.LastModifiedById).Name;                            
            }
        }
        return caseIn;
        
    }
    
    webservice static CaseInfo closeCase(String caseId,String resolution,String accountId) {
        Case result = null;
        CaseInfo caseIn = null;
        try{
            result =  new SLT_Case().selectByCaseNumberList(caseId, new Set<String>{'CaseNumber','AccountId','Subject','Status','Description','Priority','LastModifiedById','Technical_Resolution_Internal_Use_only__c','ResolvedDatetime__c','Root_Cause_Reason__c','Resolution__c','RootCause__c'});
        }catch(System.QueryException e){
            throw new System.QueryException('Case Number : '+ caseId +' is not found in our Customer Service Management system. Please contact you usual helpdesk center.');  
        }
        
        if(result != null ){
            if(accountId != null){
                result.AccountId = accountId;
            }
            result.Status = 'Closed';
            result.RootCause__c = 'Other';
            result.Resolution__c = resolution;
            result.Technical_Resolution_Internal_Use_only__c = resolution;
            result.Root_Cause_Reason__c = 'Other Service';
            try{
            update result;    
            }catch(System.QueryException exe){
                throw new QueryException('Resolution, Subtype 1 and Subtype 2 are mandatory to close the case');
            }
            
            
            caseIn = new CaseInfo();
            caseIn.CaseNumber = result.CaseNumber;
            caseIn.Subject = result.Subject;
            caseIn.Status = result.Status;
            caseIn.resolution  = result.Resolution__c;
            caseIn.Priority = result.Priority;
            Map<Id,User> userData = new SLT_User().selectByUserId(new Set<Id>{result.LastModifiedById}, new Set<String>{'Id','Name'});
            if(userData.isEmpty() == false){
                caseIn.lastUpdatedBy = userData.get(result.LastModifiedById).Name;                            
            }
            
        }
        
        return caseIn;
    }
    /** Get the Case Details based on Queue Name
     * 
     * */
    webservice static List<CaseInfo> getCaseListByQueueName(String queueName) {
        CaseInfo caseIn = null;
        List<CaseInfo> caseList=null;
        List<Case> cases=null;
        try{
            cases =  new SLT_Case().selectByCaseQueueList(queueName, new Set<String>{'CaseNumber','Subject','Status','Description','Priority','LastModifiedById'});
        }catch(System.QueryException e){
            throw new System.QueryException('Queue : '+ queueName +' is not found in our Customer Service Management system. Please contact you usual helpdesk center.');  
        }
        
        if(cases.isEmpty() == False){
            caseList = new List<CaseInfo>();
            for(Case result : cases){
                caseIn = new CaseInfo();
                caseIn.CaseNumber = result.CaseNumber;
                caseIn.Subject = result.Subject;
                caseIn.Status = result.Status;
                caseIn.Priority = result.Priority;
                caseList.add(caseIn);
            }
        }else{
            throw new System.QueryException('No cases are found under \''+ queueName +'\' Queue' );     
        }
        return caseList;
        
    }
    
    webservice static MessageResponse updateCase(String caseId,String productName,String subtype1,String subtype2,String status,String resolution) {
        MessageResponse messageResponse = new MessageResponse();
        Case thisCase = null;
        thisCase =  new SLT_Case().selectByCaseNumberList(caseId, new Set<String>{'CaseNumber','AccountId','Subject','Status','Description','Priority','LastModifiedById','ResolvedDatetime__c','Root_Cause_Reason__c','Resolution__c','RootCause__c','ProductName__c','Case_CategorizationId__c','SubType1__c','SubType2__c','SubType3__c'});
        if(thisCase != null){
            List<CSM_QI_Case_Categorization__c> categorizations= null;
            List<Asset> assets=null;
            if(productName != null && subtype1 != null && subtype2 != null){
                categorizations = new SLT_CaseCategorization().getCaseCategorizationByFilter('Product__r.Name=\''+productName+'\' and SubType1__c=\''+subtype1+'\' and SubType2__c=\''+subtype2+'\'');
                if (categorizations.isEmpty() == false) {
                    assets = new SLT_Asset().selectByAccountIdAndProductId(new Set<Id> {thisCase.AccountId},new Set<Id>{categorizations[0].Product__c});
                    
                    if(!assets.isEmpty()){
                        thisCase.AssetId = assets[0].Id;    
                    }
                    if(!categorizations.isEmpty()){
                        thisCase.Case_CategorizationId__c = categorizations[0].Id;
                        thisCase.ProductName__c = categorizations[0].ProductName__c;
                        thisCase.SubType1__c = categorizations[0].SubType1__c;
                        thisCase.SubType2__c = categorizations[0].SubType2__c;
                        thisCase.SubType3__c = '--none--';
                    }
                }else{
                    messageResponse.status = 'Error';
                    messageResponse.message = 'productName : '+ productName +' subtype1 : '+ subtype1 +' subtype2 : '+ subtype2 +' is not found in our Customer Service Management system. Please contact you usual helpdesk center.';  
                }
            }
            if(status != null){
                thisCase.Status = status;
            }
            thisCase.RootCause__c = 'Other';
            thisCase.Resolution__c = resolution != null ?  resolution : 'Auto closed by Tiger';
            thisCase.Root_Cause_Reason__c = 'Other Service';
            messageResponse.caseNumber = caseId;
            try{
                update thisCase;
                messageResponse.status = 'Success';
                messageResponse.message = caseId+' Case Updated Successfully';
            }catch(Exception e){
                messageResponse.status = 'Error';
                messageResponse.message = e.getMessage();
            }
            
        }
        return messageResponse;  
    }

    webservice static MessageResponse updateCaseSmartIT(String caseId,String contactId,String accountId,String productName,String subtype1,String subtype2,String subtype3,String status,String subStatus,String resolution,String techResolution,String rootCause,String rootCauseReason,String envType) {
        MessageResponse messageResponse = new MessageResponse();
        Case thisCase = null;
        thisCase =  new SLT_Case().selectByCaseNumberList(caseId, new Set<String>{'CaseNumber','AccountId','Subject','Status','SubStatus__c','Description','Priority','LastModifiedById','ResolvedDatetime__c','Root_Cause_Reason__c','Resolution__c','RootCause__c','ProductName__c','Case_CategorizationId__c','SubType1__c','SubType2__c','SubType3__c'});
        if(thisCase != null){
            if(accountId != null){
                thisCase.AccountId = accountId;
            }
            if(contactId != null){
                thisCase.ContactId = contactId;
                thisCase.NoContactKnown__c = false;
            }
            List<CSM_QI_Case_Categorization__c> categorizations= null;
            List<Asset> assets=null;
            if(productName != null && subtype1 != null && subtype2 != null){
                categorizations = new SLT_CaseCategorization().getCaseCategorizationByFilter('Product__r.Name=\''+productName+'\' and SubType1__c=\''+subtype1+'\' and SubType2__c=\''+subtype2+'\' and SubType3__c=\''+subtype3+'\'');
                if (categorizations.isEmpty() == false) {
                    assets = new SLT_Asset().selectByAccountIdAndProductId(new Set<Id> {thisCase.AccountId},new Set<Id>{categorizations[0].Product__c});
                    
                    if(!assets.isEmpty()){
                        thisCase.AssetId = assets[0].Id;    
                    }
                    if(!categorizations.isEmpty()){
                        thisCase.Case_CategorizationId__c = categorizations[0].Id;
                        thisCase.ProductName__c = categorizations[0].ProductName__c;
                        thisCase.SubType1__c = categorizations[0].SubType1__c;
                        thisCase.SubType2__c = categorizations[0].SubType2__c;
                        thisCase.SubType3__c = categorizations[0].SubType3__c;
                    }
                }else{
                    messageResponse.status = 'Error';
                    messageResponse.message = 'productName : '+ productName +' subtype1 : '+ subtype1 +' subtype2 : '+ subtype2 +' and  subtype3 : '+ subtype3+' is not found in our Customer Service Management system. Please contact you usual helpdesk center.';  
                }
            }
            if(envType != null){
                thisCase.EnvironmentType__c = envType;
            }
            if(status != null){
                thisCase.Status = status;
            }
            if(subStatus != null){
               thisCase.SubStatus__c = subStatus; 
            }
            if(status == 'Resolved with Customer'){            
                thisCase.RootCause__c = 'Other';
                thisCase.Root_Cause_Reason__c = 'Other Service';
                thisCase.Resolution__c = 'Auto closed by SmartIT';
            }
            if(rootCause != null){
               thisCase.RootCause__c = rootCause;
            }
            if(techResolution != null){
                thisCase.Technical_Resolution_Internal_Use_only__c = techResolution;
            }
            if(resolution != null){
                thisCase.Resolution__c = resolution;
            }
            if(rootCauseReason != null){
                thisCase.Root_Cause_Reason__c = rootCauseReason;
            }
            messageResponse.caseNumber = caseId;
            try{
                update thisCase;
                messageResponse.status = 'Success';
                messageResponse.message = caseId+' Case Updated Successfully';
            }catch(Exception e){
                messageResponse.status = 'Error';
                messageResponse.message = e.getMessage();
            }
            
        }
        return messageResponse;  
    }
    
     /** Get the Case Details based on Queue Name
     * 
     * */
    webservice static String createCaseComment(String caseNumber,String comment,boolean IsExternal) {
        List<Case> cases = null;
        String response = 'Comment sucessfully added to case';
        try{
            cases =  new SLT_Case().getCaseByCaseNumber(caseNumber);
            if(!cases.isEmpty()){
                CaseComment cc = new CaseComment(ParentId = cases[0].Id,CommentBody = comment.stripHtmlTags(), IsPublished = IsExternal);
                insert cc;
            }
        }catch(System.QueryException e){
            response = 'Comment not added to case';
        }
        
        return response;
        
    }
   
}
