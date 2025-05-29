public without sharing class CNT_CSM_SNOWChatGPT {
    //Close Note : 18d798881b1056d0eec5ddb9ec4bcb9c
    public class CaseDetails{
        public String fromAddressName;
        public String toAddressName;
        public String los;
        public String productName;
        public String subject;
        public String description;
        public String inpactedDevice;
        public String closeNote;
        public String articleType;
        public String resolution;
        public String technicalResolution;
        public String language;
        public List<String> emailMessages;
        public List<String> caseComments;
        public List<String> workNotes;
        public List<String> logCalls;
        public List<String> feedItems;
        public List<String> activities;
        public List<KnowledgeArticle> knowledgeArticles;
    }
    public class KnowledgeArticle{
        public String articleNumber;
        public String question;
        public String answer;
        public String title;
        public String content;
    }
    
    @AuraEnabled
    public static List<IQVIACopilot_ChatGPT__c> callSNOWGenAIChatGPT(String searchString, String sys_id){
        WSC_CSM_SNOWGenAICallOut.GenAIResponse apResPost = WSC_CSM_SNOWGenAICallOut.callSNOWGenAIPost(searchString,sys_id);
        String sysId;
        if(apResPost != null){
            sysId = apResPost.result.sys_id;
        }
        IQVIACopilot_ChatGPT__c gptPost = new IQVIACopilot_ChatGPT__c( Content__c = searchString,Order__c = 1,Role__c='System',Type__c='Chat', Sys_Id__C = sysId);
        
        try{
            if(sys_id == null){
                insert gptPost;
            }
        }Catch(Exception e){
            new DmlException(e.getMessage());
        }
        String userId = UserInfo.getUserId();
        return [SELECT Id,Content__c,Order__c,Sys_Id__C,Role__c FROM IQVIACopilot_ChatGPT__c where Sys_Id__C =:sysId and CreatedById =:userId];
        //return [SELECT Id,Content__c,Order__c,Sys_Id__C,Role__c FROM IQVIACopilot_ChatGPT__c where Sys_Id__C ='4b6f24f71b1f8e50eec5ddb9ec4bcba0' Order by CreatedDate desc LIMIT 1];
    }
    
    @AuraEnabled
    public static List<IQVIACopilot_ChatGPT__c> callGetSNOWGenAIChatGPT(String sys_id){
        String userId = UserInfo.getUserId();
        WSC_CSM_SNOWGenAICallOut.GenAIGetResponse apResGet = WSC_CSM_SNOWGenAICallOut.callSNOWGenAIGet(sys_id);
        List<IQVIACopilot_ChatGPT__c> gptGetList = new List<IQVIACopilot_ChatGPT__c>();
        IQVIACopilot_ChatGPT__c gptGet = null;
        List<String> orderList = new List<String>();
        List<IQVIACopilot_ChatGPT__c> gptList = Database.query('SELECT Id,Content__c,Order__c,Sys_Id__C,Role__c FROM IQVIACopilot_ChatGPT__c where Role__c != \'System\' and Sys_Id__C =:sys_id and CreatedById =:userId order by Order__c desc');
        for(IQVIACopilot_ChatGPT__c g : gptList){
            orderList.add(g.Order__c+'');
        }
        if(apResGet != null){
            for(WSC_CSM_SNOWGenAICallOut.GenAIResult r : apResGet.result){
                if(r.u_role != 'System' && !orderList.contains(r.u_order)){
                    if(r.u_content.contains('---  --- ')){
                        r.u_content = r.u_content.replace('---  --- ','');
                    }else if(r.u_content.contains('[code]') || r.u_content.contains('[/code]')){
                        r.u_content = r.u_content.replace('[code]','');
                        r.u_content = r.u_content.replace('[/code]','');
                    }
                    gptGet = new IQVIACopilot_ChatGPT__c( Content__c = r.u_content,Order__c = Decimal.valueOf(r.u_order),Type__c='Chat',Role__c=r.u_role/*'Assistant'*/, Sys_Id__C = sys_id);
                    gptGetList.add(gptGet);    
                }
                
            }
        }
        try{
            if(!gptGetList.isEmpty()){
                insert gptGetList;    
            }
        }Catch(Exception e){
            new DmlException(e.getMessage());
        }
        return [SELECT Id,Content__c,Order__c,Sys_Id__C,Role__c FROM IQVIACopilot_ChatGPT__c where Role__c != 'System' and Sys_Id__C =:sys_id and CreatedById =:userId order by Order__c asc];
    }
    
    @AuraEnabled
    public static List<IQVIACopilot_ChatGPT__c> getSummaryDetails(String recordId){
        String userId = UserInfo.getUserId();
        /*List<IQVIACopilot_ChatGPT__c> summaryList = new List<IQVIACopilot_ChatGPT__c>();
        for(IQVIACopilot_ChatGPT__c gpt : [SELECT Id,Content__c,Order__c,Sys_Id__C,Role__c,Type__c FROM IQVIACopilot_ChatGPT__c WHERE Role__c = 'Assistant' AND Case__c =:recordId order BY CreatedDate DESC,Order__c ASC]){
            
        }*/
        
        return [SELECT Id,Content__c,Order__c,Sys_Id__C,Role__c,Case__c,Case__r.Resolution__c,Type__c,Knowledge__c,Knowledge__r.KnowledgeArticleId, Knowledge__r.ArticleNumber FROM IQVIACopilot_ChatGPT__c WHERE Role__c = 'Assistant' AND Case__c =:recordId order BY CreatedDate DESC,Order__c ASC LIMIT 1];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> getCopilotCustomSettings(String recordId){
        String recordType = null;
        List<case> caseList = Database.query('Select Id,RecordTypeId,Los__c,ProductName__c, Subject,Description,Resolution__c,CloseNotes__c From Case where id =:recordId');
        for(case c : caseList){
            recordType = c.RecordTypeId;
        }
        String copilotName = 'IQVIACopilot%';
        List<String> copilotList = new List<String>();
        CSM_Case_Details_Global_Setting__c email = CSM_Case_Details_Global_Setting__c.getValues('IQVIACopilotEmailGenerator');
        CSM_Case_Details_Global_Setting__c draftKBInfo = CSM_Case_Details_Global_Setting__c.getValues('IQVIACopilotDraftKBInfo');
        CSM_Case_Details_Global_Setting__c draftKBQuestion = CSM_Case_Details_Global_Setting__c.getValues('IQVIACopilotDraftKBQuestion');
        CSM_Case_Details_Global_Setting__c draftResolution = CSM_Case_Details_Global_Setting__c.getValues('IQVIACopilotCaseResolution');
        String userId = UserInfo.getUserId();
        Map<String,String> groupMap = null;  
        List<GroupMember> groupList;
        Map<string,string> pgMap = new Map<string,string>();
        if(email != null && email.Origin__c != null){
          pgMap.put(email.Origin__c,email.Name);
        }
        if(draftKBInfo != null && draftKBInfo.Origin__c != null){
           pgMap.put(draftKBInfo.Origin__c,draftKBInfo.Name); 
        }
        if(draftKBQuestion != null && draftKBQuestion.Origin__c != null){
            pgMap.put(draftKBQuestion.Origin__c,draftKBQuestion.Name);
        }
        if(draftResolution != null && draftResolution.Origin__c != null){
            pgMap.put(draftResolution.Origin__c,draftResolution.Name);
        }
        if(pgMap != null && !pgMap.isEmpty()){
            Set<String> pg = pgMap.keySet();
            groupList = Database.query('select Id, GroupId, UserOrGroupId, SystemModstamp from GroupMember where GroupId in :pg and UserOrGroupId =:userId');
            if(groupList != null && groupList.size() > 0){
                groupMap = new Map<String,String>();
                for(GroupMember gm : groupList){
                    if(pgMap.containsKey(gm.GroupId)){
                        groupMap.put(gm.GroupId,pgMap.get(gm.GroupId));
                    }
                }
            }
        }
        copilotList.add('Please Select');
        List<CSM_Case_Details_Global_Setting__c> globalList = Database.query('SELECT Id,Name,Component_Id__c,Setting_Type__c,Other_Details__c,Origin__c From CSM_Case_Details_Global_Setting__c Where Name Like :copilotName OR (Name =\'RnDCopilotActivityAudit\' AND RecordTypeId__c = :recordType) order by CreatedDate');
        for(CSM_Case_Details_Global_Setting__c c : globalList){
            if(c.Origin__c != null && groupMap != null && groupMap.containsKey(c.Origin__c) && groupMap.get(c.Origin__c) == c.Name){
                copilotList.add(c.Component_Id__c);
            }else if(c.Origin__c == null){
                copilotList.add(c.Component_Id__c);
            }
        }
        return copilotList;
    }
    
    @AuraEnabled
    public static List<IQVIACopilot_ChatGPT__c> askCaseAssistance(String caseId, String askType, String language,String langCode,String kaId){
        String billingType,sys_id,jsonStr;
        List<String> copilotList = new List<String>();
        List<CSM_Case_Details_Global_Setting__c> globalList = Database.query('SELECT Id,Name,Component_Id__c,Setting_Type__c,Other_Details__c From CSM_Case_Details_Global_Setting__c Where Component_Id__c =:askType');
        for(CSM_Case_Details_Global_Setting__c c : globalList){
            billingType = c.Other_Details__c;
        }
        if(caseId != null && billingType != null){
            CaseDetails cd = new CaseDetails();
            List<String> ems = new List<String>();
            List<String> cms = new List<String>();
            List<String> wns = new List<String>();
            List<String> logCalls = new List<String>();
            boolean isRnd = false;
            String searchText;
            List<case> caseList = Database.query('Select Id,ProductName__c,Device__c,RecordTypeName__c,LOS__c,ContactId,Contact.Name, Subject,Description,Resolution__c,CloseNotes__c,Technical_Resolution_Internal_Use_only__c From Case where id =:caseId');
            cd.language = language;
            for(case c : caseList){
                if(askType != 'Draft Article Email' && askType != 'Draft Article Information' && askType != 'Draft Article Question-Answer'){
                    if((c.RecordTypeName__c == CON_CSM.S_R_D_CTP || c.RecordTypeName__c == CON_CSM.S_R_D_CDP || c.RecordTypeName__c == CON_CSM.S_R_D_V_T || c.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T || c.RecordTypeName__c == CON_CSM.S_RDCASE)){
                        cd.los = c.LOS__c;
                        isRnd = true;
                    }else{
                        isRnd = false;
                        cd.productName = c.ProductName__c;
                    }
                }
                cd.subject =  c.Subject;
                searchText = c.Subject;
                if(c.ContactId != null && askType == 'Draft Article Email'){
                    cd.fromAddressName = UserInfo.getUserName();
                    cd.toAddressName = c.Contact.Name;
                }
                if(c.Description.contains('IMPORTANT - PLEASE READ:')){
                    List<String> splList =  c.Description.split('IMPORTANT - PLEASE READ:');
                    cd.description = splList[0]; 
                }else{
                    cd.description =  c.Description;   
                }
                if((askType == 'Draft Article Information' || askType == 'Draft Article Question-Answer') ){
                    if(askType == 'Draft Article Information'){
                        cd.articleType = 'Information';
                    }else{
                        cd.articleType = 'Question and Answer';
                    }
                    if(c.Device__c != null){
                        cd.inpactedDevice = c.Device__c;
                    }
                    if(c.Resolution__c != null){
                       cd.resolution = c.Resolution__c;
                    }
                    if(c.Technical_Resolution_Internal_Use_only__c != null){
                       cd.technicalResolution = c.Technical_Resolution_Internal_Use_only__c; 
                    }
                    
                }
                if((askType == 'Case Close Note' || askType == 'Draft Email') && c.Resolution__c != null){
                    cd.closeNote = c.Resolution__c+' - '+c.Technical_Resolution_Internal_Use_only__c;
                }
            }
            
            if(askType == 'Draft Article Email' || askType == 'Draft Close Resolution'){
                List<SObject> kas = null;
                if(searchText != null && askType == 'Draft Close Resolution'){
                    kas = CNT_CSM_AttachArticle.searchArticles(searchText, caseId, 5, 0);
                }else if(kaId != null && askType == 'Draft Article Email'){
                    kas = Database.query('SELECT Id, RecordTypeId, ArticleNumber, Content__c, L1Content__c, L2L3Content__c, Question__c, Answer__c, L1Answer__c, L2L3Answer__c, Title, knowledgeArticleId, ProductName__c, SubType1__c, SubType2__c, SubType3__c, IsVisibleInCsp, LastPublishedDate FROM Knowledge__kav WHERE knowledgeArticleId =:kaId AND PublishStatus =\'Online\'');
                }
                
                List<KnowledgeArticle> kaL;
                if(kas != null){
                    kaL = new List<KnowledgeArticle>();
                    KnowledgeArticle k = null;
                    for(SObject o : kas){
                        Knowledge__kav a = (Knowledge__kav)o;
                        k = new KnowledgeArticle();
                        k.articleNumber = a.ArticleNumber;
                        k.question = a.Question__c;
                        k.answer = (a.Answer__c != null ? a.Answer__c.stripHtmlTags() : '') + (a.L1Answer__c != null ? a.L1Answer__c.stripHtmlTags() : '') + (a.L2L3Answer__c != null ? a.L2L3Answer__c.stripHtmlTags(): '');
                        k.title = a.Title;
                        k.content = (a.Content__c != null ? a.Content__c.stripHtmlTags() : '') + (a.L1Content__c != null ? a.L1Content__c.stripHtmlTags() : '');
                        kaL.add(k);
                    }
                    cd.knowledgeArticles = kaL;
                }
            }
            if(askType == 'Draft Email'){
                List<EmailMessage> emailList = Database.query('Select Id,Incoming,FromName,FromAddress,ToAddress,CreatedDate, CreatedBy.Name,Subject,TextBody From EmailMessage where ParentId =:caseId and Incoming = true order by MessageDate Desc LIMIT 10');
                for(EmailMessage c : emailList){
                    if(c.Incoming){
                        ems.add(c.textBody);
                    }
                }
                cd.emailMessages = ems;
            }
            if(askType == 'Case Summary' || askType == 'Draft Article Information' || askType == 'Draft Article Question-Answer'){
                List<EmailMessage> emailList = Database.query('Select Id,Incoming,FromName,FromAddress,ToAddress,CreatedDate, CreatedBy.Name,Subject,TextBody From EmailMessage where ParentId =:caseId and Status !=\'5\' order by CreatedDate Desc Limit 20');
                for(EmailMessage c : emailList){
                    if(askType == 'Case Summary'){
                        if(c.Incoming){
                            ems.add('Email coming FromAddress:'+c.FromAddress +' and ToAddress:'+ c.ToAddress +' Created Time stamp:'+c.CreatedDate+' email body in '+c.textBody); 
                        }else{
                            ems.add('Email is sent by '+c.FromName+', FromAddress:'+c.FromAddress +' and ToAddress:'+ c.ToAddress +' Created Time stamp:'+c.CreatedDate+' email body in '+c.textBody); 
                        }
                    }else{
                        ems.add(c.textBody);
                    }
                }
                cd.emailMessages= ems;
                if(isRnd){
                    List<String> activities = new List<String>();
                    List<Activity__c> actList = Database.query('Select Id,Name,Description__c,CreatedDate,CreatedBy.Name,StartDatetime__c,Status__c,Case__c,PassFail__c,LOS__c,Type__c,EscalationType__c,RandD_Location__c,Email_Categorization__c,Comments__c,Attachments__c From Activity__c  where Case__c = :caseId  order by CreatedDate desc');
                    if(actList != null && !actList.isEmpty()){
                        for(Activity__c at : actList){
                            if(at.Type__c == 'Call - Inbound' || at.Type__c == 'Call - Outbound' || at.Type__c == 'Email - Inbound' || at.Type__c == 'Email - Outbound'){
                                activities.add('Activity : '+ at.Name +' type: '+at.Type__c+' was created by '+at.CreatedBy.Name +' on '+at.CreatedDate+' Escalation Type is '+at.EscalationType__c+' Email Categorization is '+at.Email_Categorization__c+' Status is '+at.Status__c+' and PassFail is '+at.PassFail__c);
                            }
                        }
                        cd.activities = activities;
                    }
                    
                }
            }
            if(askType == 'Case Close Note' || askType == 'Case Summary' || askType == 'Draft Article Information' || askType == 'Draft Article Question-Answer'){
                List<CaseComment> caseComments = new SLT_CaseComment().selectByParentId(new Set<ID> {caseId});
                for(CaseComment c : caseComments){
                    if(askType == 'Case Close Note' || askType == 'Case Summary'){
                        if(c.IsPublished){
                            cms.add('External: CreatedBy '+c.CreatedBy.Name +' On '+c.CreatedDate+' CaseComment is '+c.CommentBody);
                        }else{
                            wns.add('Internal: CreatedBy '+c.CreatedBy.Name +' On '+c.CreatedDate+' worknote is '+c.CommentBody);
                        }    
                    }else{
                        cms.add(c.CommentBody);
                    }
                }
                if(askType == 'Case Close Note' || askType == 'Case Summary'){
                    List<FeedItem> posts = Database.query('select Id, ParentId, Type, CreatedBy.Name, CreatedDate, Revision, Title, Body, LinkUrl, IsRichText, RelatedRecordId, InsertedById, NetworkScope, Visibility, BestCommentId, Status from FeedItem where Type =\'TextPost\' and ParentId =:caseId');
                    for(FeedItem c : posts){
                        if(c.Visibility == 'AllUsers'){
                            cms.add('External: CreatedBy '+c.CreatedBy.Name +' On '+c.CreatedDate+' CaseComment is '+c.Body.stripHtmlTags());
                        }else if(c.Visibility == 'InternalUsers'){
                            cms.add('Internal: CreatedBy '+c.CreatedBy.Name +' On '+c.CreatedDate+' CaseComment is '+c.Body.stripHtmlTags());
                        }
                    }    
                }
                cd.caseComments= cms;
                cd.workNotes = wns;
            }
            if(askType == 'Case Summary'){
                List<Task> lc = Database.query('select Id, Subject, Description, type, CreatedDate,Task_Owner_Name__c from Task where Type in (\'Acknowledgement\',\'Call\',\'Outbound Call\',\'Voice Mail\') and WhatId =:caseId');
                for(Task c : lc){
                    logCalls.add('Task:'+c.type+' type '+'CreatedBy '+c.Task_Owner_Name__c+' On '+c.CreatedDate + ' Call subject is ' +c.Subject+' and Call Description is '+ c.Description);
                }
                cd.logCalls = logCalls;
            }
            jsonStr = Json.serialize(cd);
            if(jsonStr != null){
                WSC_CSM_SNOWGenAICallOut.GenAIResponse apResPost = WSC_CSM_SNOWGenAICallOut.callSNOWCaseSummary(jsonStr,billingType,null);
                IQVIACopilot_ChatGPT__c gptPost = new IQVIACopilot_ChatGPT__c( Content__c = askType,Order__c = 1,Role__c='System',Type__c = askType, Case__c = caseId,Sys_Id__C = apResPost.result.sys_id);
                try{
                    sys_id = apResPost.result.sys_id;
                    insert gptPost;
                }Catch(Exception e){
                    new DmlException(e.getMessage());
                }
            }
        }
        String userId = UserInfo.getUserId();
        return [SELECT Id,Content__c,Order__c,Sys_Id__C,Role__c,Knowledge__c,Knowledge__r.KnowledgeArticleId, Knowledge__r.ArticleNumber FROM IQVIACopilot_ChatGPT__c WHERE Sys_Id__C =:sys_id AND Type__c =:askType AND Case__c =:caseId AND CreatedById =:userId LIMIT 1];
        //return [SELECT Id,Content__c,Order__c,Sys_Id__C,Role__c FROM IQVIACopilot_ChatGPT__c WHERE Sys_Id__C ='7b7e191bdbc09ed0596acf5e13961908' AND Case__c =:caseId AND CreatedById =:userId];
    }
    
    @AuraEnabled
    public static List<IQVIACopilot_ChatGPT__c> getCaseAssistance(String caseId, String sys_id,String askType){
        WSC_CSM_SNOWGenAICallOut.GenAIGetResponse apResGet = null;
        String userId = UserInfo.getUserId();
        if(caseId != null && sys_id != null){
           apResGet = WSC_CSM_SNOWGenAICallOut.callSNOWSummaryGet(sys_id);
        }
        List<IQVIACopilot_ChatGPT__c> gptGetList = new List<IQVIACopilot_ChatGPT__c>();
        IQVIACopilot_ChatGPT__c gptGet = null;
        List<String> orderList = new List<String>();
        List<IQVIACopilot_ChatGPT__c> gptList = Database.query('SELECT Id,Content__c,Order__c,Sys_Id__C,Role__c FROM IQVIACopilot_ChatGPT__c WHERE Role__c = \'System\' AND  Case__c =:caseId AND Sys_Id__C =:sys_id order by Order__c desc');
        for(IQVIACopilot_ChatGPT__c g : gptList){
            orderList.add(g.Order__c+'');
        }
        if(apResGet != null){
            for(WSC_CSM_SNOWGenAICallOut.GenAIResult r : apResGet.result){
                //if(r.u_role != 'System' && !orderList.contains(r.u_order)){
                if(r.u_role != 'System' && r.u_role != 'User'){
                    if(r.u_content.contains('---  --- ')){
                        r.u_content = r.u_content.replace('---  --- ','');
                    }else if(r.u_content.contains('[code]') || r.u_content.contains('[/code]')){
                        r.u_content = r.u_content.replace('[code]','');
                        r.u_content = r.u_content.replace('[/code]','');
                    }
                    for(IQVIACopilot_ChatGPT__c g : gptList){
                        g.Content__c = r.u_content;
                        g.Type__c = askType;
                        g.Role__c=r.u_role;
                    }
                    //gptGet = new IQVIACopilot_ChatGPT__c( Content__c = r.u_content,Order__c = Decimal.valueOf(r.u_order),Type__c = askType,Role__c=r.u_role/*'Assistant'*/, Case__c = caseId, Sys_Id__C = sys_id);
                    //gptGetList.add(gptGet);    
                }
                
            }    
        }
        
        
        try{
            if(!gptList.isEmpty()){
                update gptList;
            }
        }Catch(Exception e){
           new DmlException(e.getMessage());
        }
        return [SELECT Id,Content__c,Order__c,Sys_Id__C,Role__c,Type__c,Knowledge__c,Knowledge__r.KnowledgeArticleId, Knowledge__r.ArticleNumber FROM IQVIACopilot_ChatGPT__c WHERE Role__c = 'Assistant' AND Type__c = :askType AND Case__c =:caseId AND Sys_Id__C =:sys_id order by Order__c asc];
    }
    
    
    @AuraEnabled
    public static List<IQVIACopilot_ChatGPT__c> saveKBDraft(String caseId, String contentId,String langCode){
        String content,typeC,message = null;
        String userId = UserInfo.getUserId();
        List<EmailMessage> emList = null;
        boolean isUpdate = false,isNoEmail=false;
        List<Knowledge__kav> kids = null;
        if(caseId != null && contentId != null) {
            List<Case> caseList = Database.query('SELECT Id,Account_Name_Article__c,CaseNumber,Subject,RecordTypeName__c,AccountCountry__c,Los__c,AssetId,Asset.Product2Id,Asset.Product2.Pillar__c, SubType1__c, SubType2__c, SubType3__c,Case_CategorizationId__c,Case_CategorizationId__r.Pillar__c, ProductName__c FROM Case WHERE Id =:caseId');
            List<IQVIACopilot_ChatGPT__c> gptList = Database.query('SELECT Id,Message__c,Content__c,Order__c,Sys_Id__C,Role__c,Type__c,Knowledge__c FROM IQVIACopilot_ChatGPT__c WHERE Id =:contentId AND Case__c =:caseId');
            for(IQVIACopilot_ChatGPT__c g : gptList){
                content = g.Content__c;
                typeC = g.Type__c;
            }
            if(content != null){
                String regExp = '</h[1-6]{1}>';
                String title,resolution,que,answer;
                Id kbtype;
                if(typeC == 'Draft Article Information'){
                   kbtype = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('Information').getRecordTypeId();
                   List<string> res = content.split('::BEG_RES::');
                    if(res[0].trim().containsIgnoreCase('Title:')){
                        title = res[0].trim().replace('Title:','').stripHtmlTags();
                    }else{
                        List<String> titles = res[0].split(':');
                        title = titles[1].trim().stripHtmlTags();
                    }
                    resolution = res[1].trim();
                }else if(typeC == 'Draft Article Question-Answer'){
                    kbtype = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('Question / Answer').getRecordTypeId();
                    List<string> res = content.split('::BEG_QUST::');
                    if(res[0].trim().containsIgnoreCase('Title:')){
                        title = res[0].trim().replace('Title:','').stripHtmlTags();
                    }else{
                        List<String> titles = res[0].split(':');
                        title = titles[1].trim().stripHtmlTags();
                    }
                    System.debug('res[1] : '+res[1]);
                    if(res[1].containsIgnoreCase('::BEG_ANS::')){
                        List<string> ans = res[1].split('::BEG_ANS::');
                        que = ans[0].trim().replace('Question:','').stripHtmlTags();
                        answer = ans[1].replace('Answer:','').trim();
                    }
                    
                }
                if(title != null && (resolution != null || (que != null && answer != null))){
                    Case c = caseList[0];
                    Knowledge__kav kav = new Knowledge__kav();
                    kav.Language = langCode;
                    kav.Title = title;
                    title = title.replaceAll('[^\\w\\s]', '');
                    kav.UrlName = title.replace(' ','-');
                    if(resolution != null){
                        kav.Content__c = resolution;
                    }
                    if(que != null){
                        kav.Question__c = que;
                    }
                    if(answer != null){
                        kav.Answer__c = answer;
                    }
                    kav.ProductName__c = (c.ProductName__c != null) ? c.ProductName__c : c.Los__c;
                    if(c.AssetId != null){
                        kav.Product__c = c.Asset.Product2Id;
                        kav.Pillar__c = c.Asset.Product2.Pillar__c;
                    }
                    if(c.Case_CategorizationId__c != null){
                        kav.Pillar__c = c.Case_CategorizationId__r.Pillar__c;
                    }
                    /*if((c.RecordTypeName__c == CON_CSM.S_R_D_CTP || c.RecordTypeName__c == CON_CSM.S_R_D_CDP || c.RecordTypeName__c == CON_CSM.S_R_D_V_T || c.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T || c.RecordTypeName__c == CON_CSM.S_RDCASE)){
                        kav.Pillar__c = 'R&D';
                    }*/
                    kav.SubType1__c = c.SubType1__c;
                    kav.SubType2__c = c.SubType2__c;
                    kav.SubType3__c = c.SubType3__c;
                    kav.RecordTypeId = kbtype;
                    try{
                    insert kav;    
                    }Catch(Exception e){
                        message = e.getMessage();
                    }
                    if(kav != null && kav.Id != null){
                        string kId = kav.Id;
                        kids = Database.query('SELECT Id,KnowledgeArticleId,ArticleNumber FROM Knowledge__kav WHERE Id = :kId');
                        for(IQVIACopilot_ChatGPT__c g : gptList){
                            g.Knowledge__c = kav.Id;
                        }
                        update gptList;
                        FeedItem fi = new FeedItem(ParentId = kids[0].KnowledgeArticleId, Body ='This Knowledge Article generated from Case :'+c.CaseNumber+' by '+ Userinfo.getUserName()+'. Note: Please be aware that the content has been generated by an AI system and may contain errors, inconsistencies, or outdated information. It is provided as-is without any warranties or guarantees of accuracy. We strongly recommend using this content as a starting point for further research and investigation.' ,Type = 'TextPost' , Visibility ='AllUsers');
                        insert fi;
                    }else if(message != null){
                        for(IQVIACopilot_ChatGPT__c g : gptList){
                            g.Message__c = message;
                        }
                        update gptList;
                    }
                }           
            }
        }
        return [SELECT Id,Content__c,Order__c,Sys_Id__C,Role__c,Type__c,Message__c,Knowledge__c,Knowledge__r.KnowledgeArticleId, Knowledge__r.ArticleNumber FROM IQVIACopilot_ChatGPT__c WHERE Id = :contentId AND Case__c =:caseId order by Order__c asc]; 
    }
    
    @AuraEnabled
    public static List<EmailMessage> saveEmailasDraft(String caseId, String contentId){
        String content;
        String userId = UserInfo.getUserId();
        List<EmailMessage> emList = null;
        boolean isUpdate = false,isNoEmail=false;
        EmailMessage email = null,me = null;
        if(caseId != null && contentId != null) {
            List<Case> caseList = Database.query('SELECT Id,ContactEmail,InitialQueue__c,Account_Name_Article__c,CaseNumber,Subject,Case_ThreadToken__c,Mail_CC_List__c,RecordTypeName__c,CurrentQueue__c, CurrentQueue__r.SenderAddress__c,From_EmailToCase__c,AccountCountry__c FROM Case WHERE Id =:caseId');
            List<IQVIACopilot_ChatGPT__c> gptList = Database.query('SELECT Id,Content__c,Order__c,Sys_Id__C,Role__c,Type__c FROM IQVIACopilot_ChatGPT__c WHERE Id =:contentId AND Case__c =:caseId');
            for(IQVIACopilot_ChatGPT__c g : gptList){
                content = g.Content__c; 
            }
            if(content != null){
                emList = Database.query('select Id, ParentId, ActivityId, TextBody, HtmlBody, Headers, Subject, Name, MessageDate,FromName, FromAddress, ToAddress, CcAddress, BccAddress, Incoming, HasAttachment, Status, ReplyToEmailMessageId, IsPrivateDraft, IsExternallyVisible, MessageIdentifier, ThreadIdentifier, ClientThreadIdentifier, FromId, IsClientManaged, AttachmentIds, RelatedToId from EmailMessage where ParentId =:caseId and ((Status =\'5\' and CreatedById =:userId and Incoming =false)  or Incoming =true) order by CreatedDate desc limit 2');  
                if(emList != null && !emList.isEmpty()){
                    for(EmailMessage e : emList){
                        if(e.Incoming){
                            content= content+'--------------- Original Message ---------------<br clear="none" />'+
                                '<b>From:</b> '+e.FromName +' ['+e.FromAddress+']<br clear="none" />'+
                                '<b>Sent:</b> '+e.MessageDate+'<br clear="none" />'+
                                '<b>To:</b> '+e.ToAddress+'<br clear="none" />'+
                                '<b>Subject:</b> '+e.Subject+'<br clear="none" />'+
                                '<br clear="none" />';
                            if(e.TextBody != null){
                                e.TextBody = content.stripHtmlTags()+e.TextBody;
                            }else{
                                e.TextBody = content.stripHtmlTags();
                            }
                            if(e.HtmlBody != null && e.HtmlBody.contains('</head>')){
                                e.HtmlBody = e.HtmlBody.replaceFirst('<body[^>]*>','<body>');
                                List<String> body = e.HtmlBody.split('<body>');
                                e.HtmlBody = '<html><head><title></title></head><body>'+content+body[1];
                            }
                            email = e;
                            break;
                        }else if(e.IsPrivateDraft){
                            isUpdate = true;
                            if(e.HtmlBody != null && e.HtmlBody.contains('<body>')){
                                List<String> body = e.HtmlBody.split('<body>');
                                e.HtmlBody = body[0]+'<body>'+content+body[1];
                            }else if(e.HtmlBody != null && e.HtmlBody.contains('<br clear="none"')){
                                e.HtmlBody = e.HtmlBody.replaceFirst('<br clear="none" />',content);
                            }else{
                                e.HtmlBody = '<html><head><title></title></head><body>'+content+'</body></html>';
                            }
                            if(e.TextBody != null){
                                e.TextBody = content.stripHtmlTags()+e.TextBody;
                            }else{
                                e.TextBody = content.stripHtmlTags();
                            }  
                        }
                        email = e;
                        break;
                    }
                }else{
                    email = new EmailMessage();
                    email.HtmlBody = '<html><head><title></title></head><body>'+content+'</body></html>';
                    email.TextBody = content.stripHtmlTags();
                    isNoEmail = true;
                }
                
                if(isUpdate && email != null && !emList.isEmpty()){
                    update email;
                }else if(email != null){
                    me = email.clone();
                    if(isNoEmail){
                        me.ParentId = caseId;
                        me.RelatedToId = caseId;
                    }
                    for(Case c : caseList){
                        
                        me.ToAddress = c.ContactEmail;
                        if((c.RecordTypeName__c == 'TechnologyCase' || c.RecordTypeName__c == 'ActivityPlan' || c.RecordTypeName__c == 'RandDCase' || c.RecordTypeName__c == 'VirtualTrialsCase') && c.CurrentQueue__c != null && c.CurrentQueue__r.SenderAddress__c != null){
                            me.FromAddress = c.CurrentQueue__r.SenderAddress__c;
                        }else if(c.From_EmailToCase__c != null ){
                            me.FromAddress = c.From_EmailToCase__c;
                        }else if(c.RecordTypeName__c == 'DATACase' && c.AccountCountry__c == 'FR'){
                            me.FromAddress = Userinfo.getUserEmail();
                            me.CcAddress = 'replytocsm@iqvia.com,'+c.Mail_CC_List__c;
                        }else if((c.RecordTypeName__c == 'TechnologyCase' || c.RecordTypeName__c == 'DATACase' || c.RecordTypeName__c == 'DATACreateService' || c.RecordTypeName__c == 'ClinicalTrialPayment' || c.RecordTypeName__c == 'ConnectedDevicePatient')){
                            me.FromAddress = 'replytocsm@iqvia.com';
                        }
                        if((c.RecordTypeName__c == 'ActivityPlan' || c.RecordTypeName__c == 'RandDCase' || c.RecordTypeName__c == 'VirtualTrialsCase') ){
                            me.Subject = 'Case#: '+c.CaseNumber+' - ';
                            me.FromAddress = 'replytocsm@iqvia.com';
                        }else if(c.RecordTypeName__c == 'TechnologyCase'){
                            me.Subject = 'Case#: '+c.CaseNumber+' - '+c.Subject+' - '+c.Account_Name_Article__c+' ';
                            me.CcAddress = c.Mail_CC_List__c;
                        }else if(c.RecordTypeName__c == 'DATACase' && c.InitialQueue__c == 'Data UK SECURNET SUPPORT'){
                            me.Subject = 'RE: Case#: '+c.CaseNumber+' - '+c.Subject+' - '+c.Case_ThreadToken__c+' ';
                        }else if((c.RecordTypeName__c == 'DATACase' || c.RecordTypeName__c == 'DATACreateService' || c.RecordTypeName__c == 'ClinicalTrialPayment' || c.RecordTypeName__c == 'ConnectedDevicePatient')){
                            me.Subject = 'RE: Case#: '+c.CaseNumber+' - '+c.Subject+' ';
                        }
                        if(c.RecordTypeName__c == 'DATACase'){
                            me.CcAddress = c.Mail_CC_List__c;
                        }
                    }
                    me.Incoming = false;
                    me.Status = '5';
                    if(email.id != null){
                        me.ReplyToEmailMessageId = email.id;  
                    }
                    me.IsPrivateDraft = true;
                    me.MessageIdentifier = null;
                    insert me;
                    
                }
            }
        }
        return emList;
    }
    
    
    @AuraEnabled
    public static List<IQVIACopilot_ChatGPT__c> saveCaseResolution(String caseId, String contentId){
        String content;
        String userId = UserInfo.getUserId();
        List<IQVIACopilot_ChatGPT__c> gptList = null;
        if(caseId != null && contentId != null) {
            List<Case> caseList = Database.query('SELECT Id,Resolution__c,ContactEmail,Account_Name_Article__c,CaseNumber,Subject,Case_ThreadToken__c,Mail_CC_List__c,RecordTypeName__c,CurrentQueue__c, CurrentQueue__r.SenderAddress__c,From_EmailToCase__c,AccountCountry__c FROM Case WHERE Id =:caseId');
            gptList = Database.query('SELECT Id,Content__c,Order__c,Sys_Id__C,Role__c,Type__c FROM IQVIACopilot_ChatGPT__c WHERE Id =:contentId AND Case__c =:caseId');
            for(IQVIACopilot_ChatGPT__c g : gptList){
                content = g.Content__c; 
            }
            if(content != null){
                for(Case c : caseList){
                    /*if(content.containsIgnoteCase('Note:')){
                        List<String> resol= content.split('Note:');
                        c.Resolution__c =resol[0];
                    }*/
                    c.Resolution__c = content;
                }
                try{
                    update caseList;
                }catch(Exception ex){
                    for(IQVIACopilot_ChatGPT__c g : gptList){
                        g.Message__c = ex.getMessage(); 
                    }
                    update gptList;
                }
                
            }
        }
        return gptList;
    }
}