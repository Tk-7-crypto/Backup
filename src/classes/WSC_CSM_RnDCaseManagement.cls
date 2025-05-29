global with sharing class WSC_CSM_RnDCaseManagement {
    global class MessageResponse {
        webservice String sObjectName;
        webservice String status;
        webservice String message;
        webservice String caseNumber;
        webservice String caseId;
        webservice List<SObjectDetails> sObjDetails;
    }
    
    global class SObjectDetails {
        webservice String sId;
        webservice String sSponsorName;
        webservice String sSponsorId;
        webservice String sName;
        webservice String sConEmail;
        webservice String sConAccountId;
        webservice String sProjectCode;
        webservice String sExtStudyId;
        webservice String sExtStudySystem;
    }
    webservice static MessageResponse getSponsorAccountDetails(String searchSponsor, String countryCode){
        MessageResponse response = new MessageResponse();
        SObjectDetails sod = null;
        List<SObjectDetails> sObjDetails = new List<SObjectDetails>();
        List<Account> sponsorList = new SLT_Account().selectSponsorAccBySearchString(searchSponsor, countryCode,new Set<String> {'Id','Name'});
        response.sObjectName = 'SponsorAccount';
        for(Account s : sponsorList){
            sod = new SObjectDetails();
            sod.sId = s.Id;
            sod.sSponsorId = s.Id;
            sod.sSponsorName = s.Name;
            sObjDetails.add(sod);
        }
        if(sObjDetails.isEmpty()){
            response.message = 'No Sponsor record found in with searchSponsor : '+searchSponsor +' countryCode : '+countryCode;
        }
        response.sObjDetails = sObjDetails;
        response.status = 'success';
        return response;
    }
    
    webservice static MessageResponse getSiteAccountDetails(String searchSite, String countryCode){
        MessageResponse response = new MessageResponse();
        SObjectDetails sod = null;
        List<SObjectDetails> sObjDetails = new List<SObjectDetails>();
        List<Account> siteList = new SLT_Account().selectSiteAccBySearchString(searchSite, countryCode,new Set<String> {'Id','Name'});
        response.sObjectName = 'Site';
        for(Account s : siteList){
            sod = new SObjectDetails();
            sod.sId = s.Id;
            sod.sName = s.Name;
            sObjDetails.add(sod);
            
        }
        if(sObjDetails.isEmpty()){
            response.message = 'No Site record found in with searchSite : '+searchSite +' countryCode : '+countryCode;
        }
        response.status = 'success';
        response.sObjDetails = sObjDetails;
        return response;
    }
    webservice static MessageResponse createContact(String contactFirstName,String contactLastName,String accountId,String email,String preferredLanguage,String mailingCountry){
        MessageResponse response = new MessageResponse();
        SObjectDetails sod = null;
        List<SObjectDetails> sObjDetails = new List<SObjectDetails>();
        List<Contact> contList = null;
        response.sObjectName = 'Contact';
        if(mailingCountry == null){
            response.status = 'MailingCountry is Mandatory to create a contact.';
        }else if(accountId == null){
            response.status = 'Account Id is Mandatory to create a contact.';
        }else if(accountId != null){
            contList = new SLT_Contact().selectByEmailAndAccount(email,accountId);
            if(contList != null && !contList.isEmpty()){
                for(Contact cont : contList){
                    sod = new SObjectDetails();
                    sod.sId = cont.Id;
                    sod.sName = cont.Name;
                    sod.sConEmail = cont.Email;
                    sod.sConAccountId = cont.AccountId;
                    sObjDetails.add(sod);
                    response.sObjDetails = sObjDetails;
                    response.status = 'Contact '+email+'already avalibale under the '+accountId+' Account.';
                }    
            }else{
                Contact contact = new Contact(FirstName = contactFirstName, LastName = contactLastName, AccountId = accountId, Email = email, PreferredLanguage__c = preferredLanguage,MailingCountry = mailingCountry);
                insert contact;
                contList = new SLT_Contact().selectByEmailAndAccount(email,accountId);
                for(Contact cont : contList){
                    sod = new SObjectDetails();
                    sod.sId = cont.Id;
                    sod.sName = cont.Name;
                    sod.sConEmail = cont.Email;
                    sod.sConAccountId = cont.AccountId;
                    sObjDetails.add(sod);
                    response.sObjDetails = sObjDetails;
                    response.status = 'success';
                }    
            }
            
        }
        return response;
    }
    webservice static MessageResponse getContactDetails(String email){
        MessageResponse response = new MessageResponse();
        SObjectDetails sod = null;
        List<SObjectDetails> sObjDetails = new List<SObjectDetails>();
        List<Contact> contList = Database.query('select Id,Name,Email,AccountId from Contact Where Email =:email and Inactive__c = false LIMIT 1');
        response.sObjectName = 'Contact';
        for(Contact cont : contList){
            sod = new SObjectDetails();
            sod.sId = cont.Id;
            sod.sName = cont.Name;
            sod.sConEmail = cont.Email;
            sod.sConAccountId = cont.AccountId;
            sObjDetails.add(sod);
        }
        if(sObjDetails.isEmpty()){
            response.message = 'No Contact record found in with email : '+email;
        }
        response.status = 'success';
        response.sObjDetails = sObjDetails;
        
        return response;
    }
    
    webservice static MessageResponse getStudyDetails(String protocol){
        MessageResponse response = new MessageResponse();
        SObjectDetails sod = null;
        List<SObjectDetails> sObjDetails = new List<SObjectDetails>();
        List<Study__c> studyList = new SLT_StudyC().selectStudyBasedOnProtocol(new Set<String>{protocol});
        response.sObjectName = 'Study';
        for(Study__c s : studyList){
            sod = new SObjectDetails();
            sod.sId = s.Id;
            sod.sName = s.Name;
            sod.sSponsorId = s.Sponsor__c;
            sod.sSponsorName = s.Sponsor__r.Name;
            sod.sProjectCode = s.StudyID__c;
            sod.sExtStudyId = s.ExtStudyId__c;
            sod.sExtStudySystem = s.ExtStudySystem__c;
            sObjDetails.add(sod);
        }
        if(sObjDetails.isEmpty()){
            response.message = 'No Study record found in with protocol : '+protocol;
        }
        response.status = 'success';
        response.sObjDetails = sObjDetails;
        return response;
    }
    
    webservice static MessageResponse createStudy(String protocol, String sponsorId, String status, String studyType,String projectCode, String extStudyId,String extStudySystem){
        MessageResponse response = new MessageResponse();
        SObjectDetails sod = null;
        List<SObjectDetails> sObjDetails = new List<SObjectDetails>();
        try{
            Study__c study = new Study__c(Name = protocol, Sponsor__c = sponsorId, Status__c = status, StudyTypeORDCOnly__c = studyType,StudyID__c = projectCode, ExtStudyId__c = extStudyId, ExtStudySystem__c = extStudySystem);
            insert study;
            List<Study__c> studyList = new SLT_StudyC().selectAccountByStudyId(new Set<ID>{study.Id},new Set<String>{'Id','Name','Sponsor__c','Sponsor__r.Name','Protocol__c','StudyID__c','ExtStudyId__c','ExtStudySystem__c'});
            response.sObjectName = 'Study';
            for(Study__c s : studyList){
                sod = new SObjectDetails();
                sod.sId = s.Id;
                sod.sSponsorId = s.Sponsor__c;
                sod.sSponsorName = s.Sponsor__r.Name;
                sod.sProjectCode = s.StudyID__c;
                sod.sExtStudyId = s.ExtStudyId__c;
                sod.sExtStudySystem = s.ExtStudySystem__c;
                sObjDetails.add(sod);
            }
            response.status = 'success';
            response.sObjDetails = sObjDetails;    
        }catch(Exception e){
            response.status = 'falied';
            response.message = e.getMessage();
        }
        
        return response;
    }
    
    webservice static MessageResponse updateStudy(String protocol, String projectCode, String extStudyId,String extStudySystem){
        MessageResponse response = new MessageResponse();
        SObjectDetails sod = null;
        List<SObjectDetails> sObjDetails = new List<SObjectDetails>();
        try{
            List<Study__c> studyList = new SLT_StudyC().selectAccountByStudyName(protocol,new Set<String>{'Id','StudyID__c','ExtStudyId__c','ExtStudySystem__c'});
            response.sObjectName = 'Study';
            for(Study__c s : studyList){
                if(extStudyId != null) {
                    s.ExtStudyId__c = extStudyId;
                }
                if(extStudySystem != null) {
                    s.ExtStudySystem__c = extStudySystem;
                }
                if(projectCode != null) {
                    s.StudyID__c = projectCode;
                }
            }
            if(studyList != null && !studyList.isEmpty()){
                update studyList;
            }
            response.sObjectName = 'Study';
            for(Study__c s : studyList){
                sod = new SObjectDetails();
                sod.sId = s.Id;
                sod.sProjectCode = s.StudyID__c;
                sod.sExtStudyId = s.ExtStudyId__c;
                sod.sExtStudySystem = s.ExtStudySystem__c;
                sObjDetails.add(sod);
            }
            response.status = 'success';
            response.sObjDetails = sObjDetails;    
        }catch(Exception e){
            response.status = 'falied';
            response.message = e.getMessage();
        }
        
        return response;
    }
    
   webservice static MessageResponse createCase(String contactId,String accountId,String clientName,String clientEmail,String subject,String description, String los,String subType,String priority,String mailCCList,String currentQueue,String studyId,String recordTypeName,String contractNumber,String invoiceId,String site,String investigatorName,String vendorCode,String extSystem,String subType1,String subType2,String subType3) {
       MessageResponse response = new MessageResponse();
        Contact cont = null;
        Case thisCase = null;
        List<Case> caseList = null;
        //R&D - Clinical Trial Payment --> 'ClinicalTrialPayment'
        response.sObjectName = 'Case';
        if(clientEmail != null){
           List<Contact> conList = Database.query('Select Id, AccountId From Contact where Email =:clientEmail limit 1');
           if(conList != null){
               for(Contact con : conList){
                   contactId = con.Id;
                   accountId = con.AccountId;
               }
           }
        }
        if(recordTypeName == null){
            response.status = 'falied';
            response.message = 'RecordTypeName is mandatory to create a ticket.Please contact you usual helpdesk center.';
        }else if(los != null){
            Map<String,Schema.RecordTypeInfo> rt_Map = Case.sObjectType.getDescribe().getRecordTypeInfosByName();
            
            List<CSM_QI_Case_Categorization__c> categorizations= null;
            List<Queue_User_Relationship__c> caseQueue = new SLT_QueueUserRelationshipC().selectByQueueName(currentQueue,new Set<String>{'Id','Name','Group_ID__c'},UserInfo.getUserId());
            if(caseQueue.isEmpty()){
                response.status = 'falied';
                response.message = 'Current Queue : '+ currentQueue +' is not found in our Customer Service Management system. Please contact you usual helpdesk center.';
            }
            String filter = '';
            if(subType1 != null && subType2 != null && subType3 != null){
               filter = 'Los__c=\''+los+'\' and SubType1__c=\''+subType1+'\' and SubType2__c=\''+subType2+'\' and SubType3__c=\''+subType3+'\''; 
            }else if(subType != null){
                filter = 'Los__c=\''+los+'\' and SubType1__c=\'Request\' and SubType2__c=\''+subType+'\'';
            }
            categorizations = new SLT_CaseCategorization().getCaseCategorizationByFilter(filter);
            if(categorizations.isEmpty()){
                response.status = 'falied';
                response.message = 'Study : '+studyId+' los : '+ los +' is not avalialbe in the system.Please contact you usual helpdesk center.';
            }
            thisCase = new Case(AccountId = accountId,ContactId = contactId,Study__c = studyId,Subject = subject,Description = description,Status = 'New',Origin = 'External Service', Device__c='Laptop' ,recordTypeId = rt_map.get(recordTypeName).getRecordTypeId());
            if(clientEmail != null){
                thisCase.SuppliedEmail = clientEmail;
                thisCase.Web_Email__c = clientEmail;
                thisCase.ClientEmail__c = clientEmail;
            }
            thisCase.Client_Name__c = clientName;
            thisCase.Contract_Number__c = contractNumber;
            thisCase.InvoiceID__c = invoiceId;
            thisCase.Site__c = site;
            thisCase.CRC_Investigator_Name__c = investigatorName;
            thisCase.VendorCode__c = vendorCode;
            thisCase.External_System_Type__c = extSystem;//'InSite';
            if(caseQueue != null && !caseQueue.isEmpty()){
                thisCase.CurrentQueue__c = caseQueue[0].Id;
                thisCase.OwnerId = caseQueue[0].Group_ID__c;
            }
            thisCase.Mail_CC_List__c = mailCCList;
            if(priority != null){
                thisCase.Priority = priority;
            }
            if (!categorizations.isEmpty()) {
                thisCase.Case_CategorizationId__c = categorizations[0].Id;
                thisCase.Los__c = categorizations[0].Los__c;
                thisCase.SubType1__c = categorizations[0].SubType1__c;
                thisCase.SubType2__c = categorizations[0].SubType2__c;
                thisCase.SubType3__c = categorizations[0].SubType3__c;
            }
            
            try{
                insert thisCase;
                caseList = new SLT_Case().selectByCaseIdList(new Set<Id>{thisCase.Id} ,new Set<String>{'Id','CaseNumber'}); 
                if(!caseList.isEmpty()){
                    response.caseNumber = caseList[0].CaseNumber;
                    response.caseId = caseList[0].Id;
                    response.status = 'success';
                }    
            }catch(Exception e){
                response.message = e.getMessage()+' Please contact you usual helpdesk center.';
                response.status = 'falied';
            }
            
        }else{
            response.status = 'falied';
            response.message = 'Please provide the los.Please contact you usual helpdesk center.';
        }
        return response;
    }

}