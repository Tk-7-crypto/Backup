/**
 * Description: Utility class called via process builder 'CTR_PB01_PRM_Contract renewal expiry'
 * version : 1.0
 */
Public class UTL_PEP_SendCTRRenewalNotification {

    /**
    * 
    * @Desc   @invocablevariables as invocable method accept only one argument
    */
    public class contractDetails {
        @invocablevariable (required = True)
        public Contract aContract;

    }

      /**
    * PEP-ACN Contract Registration notification to partner manager
    * 
    * @Desc   create mail notification to partner manager upon Contract creation 
    *         since a related partner manager cannot be retrieved via workflow/process builder
    *         @invocablemethod: as this method is called via process builder
    * @params List<contractDetails> aContractDetailsList
    * @return void
    */
    @InvocableMethod
    public static void sendNotifToManager(List<contractDetails> aContractDetailsList ){

        Set<Id> partnerAccSet = new Set<Id>();
        List<String> toAddressesList = new List<String>();
        Contract contractRec =new Contract();
        Contact contactRec = new Contact();

        Set<String> emailFieldSet = new Set<String>{'Id', 'Name', 'DeveloperName', 'Subject', 'HtmlValue', 'Body'};
        Set<String> orgWideAddFieldSet = new Set<String> {'Id'};
        Id prmCtrRecTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get(CON_PEP.S_PEP_CTR_RECORDTYPE).getRecordTypeId();
       
       //invocable method accept only list as argument 
       //list contains only 1 record as no bulk transaction will be done via process builder
       if(aContractDetailsList.size()>0){
            contractRec = (aContractDetailsList[0].aContract);     
       
        if(contractRec.RecordTypeId == prmCtrRecTypeId && contractRec.AccountId != null){

            partnerAccSet.add(contractRec.AccountId);
            List<User> lstUsr = new SLT_User().selectManagerUserByAccountId(partnerAccSet);
            contactRec= lstUsr[0].Contact;
            for(User manager : lstUsr){
                toAddressesList.add(manager.contact.Email);
            }

             //get org-wide email address
            List<OrgWideEmailAddress> senderEmail = new SLT_OrgWideEmailAddress().selectOrgWideEmailAddressByAdress
                                                    (CON_PEP.S_PEP_ORG_WIDE_ADD_NO_REPLY, orgWideAddFieldSet);
            List<EmailTemplate> templateList = new SLT_EmailTemplate().selectEmailDTemplateByDeveloperName
                                                (CON_PEP.S_PEP_CTR_DEV_NAME_RENEWALNOTIF, emailFieldSet);
                                                
            if(templateList.size()>0 && senderEmail.size()>0){
                sendEmailsToPartnerManager(contractRec, templateList[0].Id,senderEmail[0].Id, toAddressesList,
                                           contactRec.Id);
            }
            
        }
        }
    }//end method sendNotifToManager
     
     
      /**
    * PEP-ACN Contract Registration notification to partner manager
    * 
    * @Desc   send mail notification to partner manager upon Contract creation
    * @params List<Contract> newList , Map<Id, Contract> oldMap
    * @return void
    */
     public static void sendEmailsToPartnerManager(Contract aContractRec, Id aEmailTemplateId, Id aSenderEmailId,
                                                     List<String> aToAddresses, 
                                                     Id aTargetObjectId){
         
         List<Messaging.SingleEmailMessage> sendMailNotif = new List<Messaging.SingleEmailMessage>();
                    
              /* Now create a new single email message object that will send out a single email to the addresses in the To, CC & BCC list. */
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setOrgWideEmailAddressId(aSenderEmailId);
                mail.setTemplateId(aEmailTemplateId);
                mail.setToAddresses(aToAddresses);
                mail.setTargetObjectId(aTargetObjectId);
                mail.setSaveAsActivity(false);
                mail.setWhatId(aContractRec.Id);
                sendMailNotif.add(mail);

                List<Messaging.sendEmailResult> sendEmailResults = Messaging.sendEmail(sendMailNotif);
                  
                if(sendEmailResults.Size() > 0){
                      
                    for(integer i; i< sendEmailResults.Size(); i++){
                        if(!sendEmailResults[i].isSuccess()){
                            Messaging.SendEmailError[] errArr = sendEmailResults[i].getErrors();
                            aContractRec.addError(errArr[0].getTargetObjectId()+ 'Error sending mail: Status Code-'
                                                    + errArr[0].getStatusCode() + 'Error Message-'+ errArr[0].getMessage());
                        }

                    }

                }
              }



}