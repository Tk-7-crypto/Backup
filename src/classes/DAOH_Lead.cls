/**
 * This is Lead trigger handler class.
 * version : 1.0
 */ 
 public class DAOH_Lead {
     
    /**
     * This method is used to set DispositionDate.
     * @params  newList List<Lead>
     * @params  oldMap Map<Id, Lead>
     * @return  void
     */
    public static void setDispositionDate(List<Lead> newList, Map<Id, Lead> oldMap) {
        for(Lead ld : newList){
            if(ld.Disposition__c != null && (Trigger.isInsert || oldMap.get(ld.id).Disposition__c != ld.Disposition__c)) {
                ld.Disposition_Date__c = Date.today();
            }
        }
    }
    
    /**
     * This method is used to set null values for various fields.
     * @params  newList List<Lead>
     * @return  void
     */
    public static void setFieldNullValues(List<Lead> newList) {
        Set<String> nurtureDetailFieldValuesSet = new Set<String> {
            CON_CRM.THREE_MONTHS,
            CON_CRM.SIX_MONTHS,
            CON_CRM.NINE_MONTHS,
            CON_CRM.TWELVE_MONTHS,
            CON_CRM.FIFTEEN_MONTHS,
            CON_CRM.EIGHTEEN_MONTHS
        };
        
        for(Lead ld : newList){
            if(ld.Disposition__c == CON_CRM.MARKETING_TO_NURTURE && nurtureDetailFieldValuesSet.contains(ld.Nurture_Detail__c)){
                ld.Disposition__c = null;
                ld.Disposition_Date__c = null;
                ld.Nurture_Area__c = null;
                ld.Nurture_Detail__c = null;
                ld.Nurture_Detail_Other__c = null;
            }
        }
    }
    
    /**
     * This method is used to set previous lead score when lead score is updated.
     * @params  newList List<Lead>
     * @params  oldMap Map<Id, Lead>
     * @return  void
     */
    public static void setPreviousLeadScore(List<Lead> newList, Map<Id, Lead> oldMap) {
        for(Lead ld : newList){
            if(ld.Lead_Score__c != oldMap.get(ld.id).Lead_Score__c) {
                ld.Previous_Lead_Score__c = oldMap.get(ld.id).Lead_Score__c;
            }
        }
    }

    /**
    * PEP-ACN Lead Registration logic
    * 
    * @Desc   To set the userId with role 'Alliance Manager' to field in lead record being created
              and setting lead owner to queue
    * @params List<Lead> newList
    * @return void
    */
    public static void setUserIdForAllianceManager(List<Lead> newList, Map<Id, Lead> oldMap) { 
        
        // using the list of lead being created: List<Lead> Records
        Map<Id,Id> mapAccTeam = new map<Id,Id>();
        Set<Id> accountId = new Set<Id>();
        Id prmLeadRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(CON_PEP.S_PEP_LED_RECORDTYPE).getRecordTypeId();
       
        // iterate for each lead record pull the accountid 
        for(Lead leadRecord : newList){
           system.debug('leadRecord:' + leadRecord);
            // Assert the lead record have a partner account id
            if(leadRecord.PartnerAccountId != null && leadRecord.recordTypeID == prmLeadRecTypeId){
                // To set the TECH Partner Account field since standard field is not accessible via formula, workflow criteria
                leadRecord.TECH_Partner_Account__c = leadRecord.PartnerAccountId;
                accountId.add(leadRecord.PartnerAccountId);
            }
            else if(leadRecord.TECH_Partner_Account__c != null && leadRecord.recordTypeID == prmLeadRecTypeId){
                accountId.add(leadRecord.TECH_Partner_Account__c);
            }
              
        }
        
        if(accountId.size() > 0){            
            // For each account id, fetch the userid with role 'Alliance Manager'
            for(AccountTeamMember member: new SLT_AccountTeamMember().selectByAccountId(accountId, CON_PEP.ALLIANCE_MANAGER)){
                mapAccTeam.put(member.AccountId,member.userId);
            }
            
            //iterate over the Records and set the field alliance manager with user Id
            for(Lead leadRecord : newList){
                if(mapAccTeam.containsKey(leadRecord.TECH_Partner_Account__c)){
                    // Get the user Id from the custom map which contains key for the partner account id
                    leadRecord.TECH_Alliance_Manager__c = mapAccTeam.get(leadRecord.TECH_Partner_Account__c);   
                }
            }
        }
        
       
    }//end method setUserIdForAllianceManager
     

    
    /**
    * PEP-ACN Lead Registration notification to partner manager
    * 
    * @Desc   create mail notification to partner manager upon lead creation 
    *         since a related partner manager cannot be retrieved via workflow/process builder
    * @params List<Lead> newList , Map<Id, Lead> oldMap
    * @return void
    */
    public static void sendNotifToManager(List<Lead> newList, Map<Id, Lead> oldMap){

        List<Lead> registeredLeadList = new  List<Lead>();
        List<Lead> convertedLeadList = new  List<Lead>();
        List<Lead> rejectedLeadList = new  List<Lead>();
        Map<Id,List<string>> pimUsrMap= new Map<Id,List<string>>();
        Set<Id> partnerAccSet = new Set<Id>();
        Set<String> emailFieldSet = new Set<String>{'Id', 'Name', 'DeveloperName', 'Subject', 'HtmlValue', 'Body'};
        Set<String> orgWideAddFieldSet = new Set<String> {'Id'};
        Id prmLeadRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(CON_PEP.S_PEP_LED_RECORDTYPE).getRecordTypeId();
        Set<Id> createdBy = new Set<Id>();
        
        for(Lead lead : newList){
            //send notif only if lead is created by partner user
            if(lead.recordTypeID == prmLeadRecTypeId && CON_PEP.S_P_PEP_COMMUNITY.equalsIgnoreCase(lead.Created_By_Profile__c)){
                if(lead.PartnerAccountId != null){
                    partnerAccSet.add(lead.PartnerAccountId);
                }

                if (oldMap == null && lead.Status == CON_PEP.S_PEP_LD_STATUS_NOT_STARTED){
                    registeredLeadList.add(lead); 
                }

                if(lead.TECH_Partner_Account__c != null && oldMap != null){
                     partnerAccSet.add(lead.TECH_Partner_Account__c);

                    if(!oldMap.get(lead.id).IsConverted && lead.IsConverted ){    
                      convertedLeadList.add(lead);
                      createdBy.add(lead.CreatedById);  
                    }
                    else if (oldMap.get(lead.Id).Status != lead.Status
                        && lead.Status == CON_PEP.S_PEP_LD_STATUS_REJECTED){
                        rejectedLeadList.add(lead);
                        createdBy.add(lead.CreatedById);
                    }
                }
            }
        }
        
        Set<String> createdByFieldSet=new Set<String>{'Id','Email','AccountId'};                  
        List<User> createdByEmailId=new SLT_User().selectActiveUserByUserId(createdBy,createdByFieldSet);
        if(createdByEmailId.size()>0){
            if(pimUsrMap.containsKey(createdByEmailId[0].accountId)){
                pimUsrMap.get(createdByEmailId[0].accountId).add(createdByEmailId[0].Email);
            }
            else{
                pimUsrMap.put(createdByEmailId[0].accountId, new List<string> {createdByEmailId[0].Email});
            }
        }
        
        Map<Id,String> idEmail=new Map<Id,String>();
        Set<Id> acmId=new Set<Id>();       

        List<AccountTeamMember> recips = new SLT_AccountTeamMember().selectByAccountId(partnerAccSet, CON_PEP.ALLIANCE_MANAGER);
        for(AccountTeamMember acm:recips)
        {
            acmId.add(acm.UserId);
            idEmail.put(acm.UserId,acm.AccountId);
        }
        Set<String> usFieldSet=new Set<String>{'Id','Email'};
        List<User> usEmail=new SLT_User().selectActiveUserByUserId(acmId,usFieldSet);
        for(User us: usEmail)
        {
            if(pimUsrMap.containsKey(idEmail.get(us.Id))){
                pimUsrMap.get(idEmail.get(us.Id)).add(us.Email);
            } else{
                pimUsrMap.put(idEmail.get(us.Id), new List<string> {us.Email});
            }
        }

        String uId=UserInfo.getUserId();
        Set<Id> userId=new Set<Id>{uId};
        String userEmail=UserInfo.getUserEmail();
        Set<String> fieldSet=new Set<String>{'Id','Email'};                 
        List<User> userAccount=new SLT_User().selectContactDetailByUser(userId,fieldSet);        
        if(userAccount.size()>0){
            if(pimUsrMap.containsKey(userAccount[0].accountId)){
                pimUsrMap.get(userAccount[0].accountId).add(userEmail);
            }
            else{
                pimUsrMap.put(userAccount[0].accountId, new List<string> {userEmail});
            }
        }
        
         //get org-wide email address
        List<OrgWideEmailAddress> senderEmail = new SLT_OrgWideEmailAddress().selectOrgWideEmailAddressByAdress(CON_PEP.S_PEP_ORG_WIDE_ADD_NO_REPLY, orgWideAddFieldSet);
        
        if(registeredLeadList.size() >0){
            List<EmailTemplate> templateList = new SLT_EmailTemplate().selectEmailDTemplateByDeveloperName(CON_PEP.S_PEP_LD_DEV_NAME_CREATION, emailFieldSet);
            sendEmailsToPartnerManager(registeredLeadList, templateList[0].Id,senderEmail[0].Id,pimUsrMap);
        }
        
        if(convertedLeadList.size() >0){
            List<EmailTemplate> templateList = new SLT_EmailTemplate().selectEmailDTemplateByDeveloperName(CON_PEP.S_PEP_LD_DEV_NAME_CONVERTED, emailFieldSet);
            sendEmailsToPartnerManager(convertedLeadList, templateList[0].Id,senderEmail[0].Id, pimUsrMap);
        }
        
        if(rejectedLeadList.size() >0){
            List<EmailTemplate> templateList = new SLT_EmailTemplate().selectEmailDTemplateByDeveloperName(CON_PEP.S_PEP_LD_DEV_NAME_REJECTED, emailFieldSet);
            sendEmailsToPartnerManager(rejectedLeadList, templateList[0].Id,senderEmail[0].Id, pimUsrMap);
        }

    }//end method sendNotifToManager
     
     
    /**
    * PEP-ACN Lead Registration notification to partner manager
    * 
    * @Desc   send mail notification to partner manager upon lead creation
    * @params List<Lead> newList , Map<Id, Lead> oldMap
    * @return void
    */
     public static void sendEmailsToPartnerManager(List<Lead> aLeadList, Id aEmailTemplateId, 
                                                   Id aSenderEmailId, Map<Id,List<string>> aPimUsrMap){
         
         List<Messaging.SingleEmailMessage> sendMailNotif = new List<Messaging.SingleEmailMessage>();
         
         if(aLeadList.size()>0 && aPimUsrMap.size() > 0){             
             for (Lead updatedLead : aLeadList){
                /* Now create a new single email message object that will send out a single email to the addresses in the To, CC & BCC list. */
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setOrgWideEmailAddressId(aSenderEmailId);
                // Assign the addresses for the To and CC lists to the mail object.
                if(updatedLead.PartnerAccountId != null){
                    mail.setToAddresses(aPimUsrMap.get(updatedLead.PartnerAccountId));
                }
                else{
                    mail.setToAddresses(aPimUsrMap.get(updatedLead.TECH_Partner_Account__c));
                }
                 
                mail.setTargetObjectId(updatedLead.Id);
                mail.setTreatTargetObjectAsRecipient(false);
                //Specify Template used
                mail.setTemplateId(aEmailTemplateId);
                sendMailNotif.add(mail);
             
             }
             
              if(sendMailNotif.size() > 0) {
                  List<Messaging.sendEmailResult> sendEmailResults=new List<Messaging.sendEmailResult>();
                  try{
                      sendEmailResults = Messaging.sendEmail(sendMailNotif);
                  } catch(Exception e) {
                      System.debug('Email Failed: ' + e.getMessage());
                  }
                  if(sendEmailResults.size() > 0){
                      
                      for(integer i; i< sendEmailResults.size(); i++){
                          if(!sendEmailResults[i].isSuccess()){
                              Messaging.SendEmailError[] errArr = sendEmailResults[i].getErrors();
                              aLeadList[i].addError(errArr[0].getTargetObjectId()+ 'Error sending mail: Status Code-'
                                                    + errArr[0].getStatusCode() + 'Error Message-'+ errArr[0].getMessage());
                          }

                      }

                  }
              }
          }
      }

    /**
    * PEP-ACN Lead Share logic
    * 
    * @Desc   define visibility and access rights of lead within partner account users
    * @params List<Lead> newList
    * @return void
    */
      public static void defineSharingRuleForPartner (List<Lead> newList , Map<Id, Lead> oldMap){

        UTL_PEP_LeadSharing.shareLeadWithPartner(newList , oldMap);

      }
     public static void setLeadCountry (List<Lead> newList , Map<Id, Lead> oldMap){
         Schema.DescribeFieldResult fieldResult = Lead.Country__c.getDescribe();
         List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
         Map<String,String> picklistOptions = new Map<String,String>();
         Map<String,String> leadCountryMappingOptions = new Map<String,String>();
         List<Lead_Country_Exception_Mapping__c> leadCountryMapping = Lead_Country_Exception_Mapping__c.getall().values();
         for(Lead_Country_Exception_Mapping__c lce : leadCountryMapping){
             String piclistLabel = (lce.Name).replaceAll('\\(','').replaceAll('\\)','').toLowerCase().trim();
             leadCountryMappingOptions.put(piclistLabel,lce.ISO_Code__c);
         }
         for( Schema.PicklistEntry f : pickListValues){
             String piclistLabel = String.valueOf(f.getLabel()).replaceAll('\\(','').replaceAll('\\)','').toLowerCase().trim();
                 picklistOptions.put(piclistLabel, f.getValue());
         }   
         for(Lead currentLead : newList){
             boolean isCountryFoundinPicklist = false;
             if((Trigger.isInsert && currentLead.Country != null && currentLead.Country != '' && currentLead.Country__c == null) || (oldMap!= null && currentLead.Country != (oldMap.get(currentLead.Id).Country))){
                 if(currentLead.Country != null && currentLead.Country != ''){
                     String currentCountry = String.valueOf((currentLead.Country)).replaceAll('\\(','').replaceAll('\\)','').toLowerCase().trim();
                     boolean isCountryFound = false;
                     if(picklistOptions.containsKey(currentCountry)){
                         currentLead.Country__c = picklistOptions.get(currentCountry);
                         isCountryFoundinPicklist = true;
                         isCountryFound = true;
                     }
                     if(!isCountryFoundinPicklist){
                         if(leadCountryMappingOptions.containsKey(currentCountry)){
                             currentLead.Country__c = leadCountryMappingOptions.get(currentCountry);
                             isCountryFound = true;
                         }
                     }
                     if(!isCountryFound){
                         currentLead.Country__c = '';
                     }
                 }else{
                     currentLead.Country__c = '';
                 }
                 
             }
         }
     }
	 
	public static void updateInvalidEmailAndHardBouncebackDate(List<Lead> newList, Map<Id, Lead> oldMap){
         for(Lead currentLead : newList){
            if(currentLead.Email != oldMap.get(currentLead.id).Email && currentLead.Email != null){
                currentLead.Invalid_Email_Address__c = false;
                currentLead.Hard_Bounceback_Date__c = null;
                currentLead.Email_Status__c = CON_CRM.Email_Status_Pending;
            }
        }        
    }
     
     public static void setValidateWebsite(List<Lead> newList , Map<Id, Lead> oldMap) {
         for (Lead lead : newList) {
             if(String.isBlank(lead.website)) {
                 lead.Is_valid_website__c = false;
             } else if(!String.isBlank(lead.website) && (Trigger.isInsert || Trigger.isUpdate && lead.Website != oldMap.get(lead.id).Website)) {
                 if(Pattern.matches('^((http|https)://)??(www[.])([a-zA-Z0-9]|-)+?([.][a-zA-Z0-9(-|/|=|?)??]+?)+?$', lead.Website)) {
                     lead.Is_valid_website__c = true;
                 } else {
                     lead.Is_valid_website__c = false;
                 }
             }
         }
     }
     
     /**
     * ESPSFDCQI-17947 - Set Lead source orginial detail - Linkedin Sales Navigator when Lead is created by LSN
     * @params List<Lead> newList
     * @return void
     */
     public static void setDefaultValuesforLSN(List<Lead> newList) {
         for(Lead leadRecord : newList) {
             if(Trigger.isInsert && leadRecord.LeadSource == 'Sales Presentation & Prospecting') {
                 leadRecord.Lead_Source_Original_Detail__c = 'LinkedIn Sales Navigator';
             }
         }
     }
 }