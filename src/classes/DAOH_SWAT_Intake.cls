public class DAOH_SWAT_Intake {
    /**
    * This method is used to check swat reocrds
    * @params  newList List<SWAT_Intake__c>
    * @params  oldMap Map<Id, SWAT_Intake__c>
    * @return  void
    */
    public static void checkPreviousSwatRecord(List<SWAT_Intake__c> newList, Map<Id, SWAT_Intake__c> oldMap) {
        Map<Id,SWAT_Intake__c> oppIdsMap = new Map<Id,SWAT_Intake__c>();
        for(SWAT_Intake__c swat : newList){
            if(swat.Opportunity__c != null || swat.Prior_Opportunity__c != null){
                oppIdsMap.put(swat.Opportunity__c,swat);
            }
        }
        List<SWAT_Intake__c> swatList = new SLT_SWAT_Intake().selectByOppId(oppIdsMap.keySet());
        for(SWAT_Intake__c swat : swatList){
            if(oppIdsMap.containsKey(swat.Opportunity__c)){
                oppIdsMap.get(swat.Opportunity__c).addError('SWAT record is already created for this Opportunity.');
            }
        }
    }
    /**
    * This method is used to Send email
    * @params  newList List<SWAT_Intake__c>
    * @params  oldMap Map<Id, SWAT_Intake__c>
    * @return  void
    */
    public static void sendEmailToSwat(List<SWAT_Intake__c> newList, Map<Id, SWAT_Intake__c> oldMap) {
        List<SWAT_Intake__c> filteredSwatList = new List<SWAT_Intake__c>();
        Set<Id> filteredSwatIdsSet = new Set<Id>();
        Set<Id> oppIdsList = new Set<Id>();
        Set<Id> accountIdsSet = new Set<Id>();
        Set<Id> contractIdsSet = new Set<Id>();
        for(SWAT_Intake__c swat : newList){
            if(swat.Submit_Form_To_SWAT_Team__c){
                filteredSwatList.add(swat);
                if(swat.Opportunity__c != null || swat.Prior_Opportunity__c != null){
                    oppIdsList.add(swat.Opportunity__c);
                }else{
                    swat.addError('Opportunity is required.');
                }
                if(swat.Prior_Opportunity__c != null){
                    oppIdsList.add(swat.Prior_Opportunity__c);
                }
                if(swat.Client_Account__c != null){
                    accountIdsSet.add(swat.Client_Account__c);
                }
                if(swat.Existing_Contract__c != null){
                    contractIdsSet.add(swat.Existing_Contract__c);
                }
                if(Trigger.isUpdate){
                    swat.Submit_Form_To_SWAT_Team__c = false;
                    swat.Last_Submitted_Date__c = String.valueOf(Date.today());
                }
                
            }
        }
        if(filteredSwatList.size() > 0){
            Map<Id, Account> accountMap = new SLT_Account().selectByAccountId(accountIdsSet, new Set<String>{'Id','Name'});
            Map<Id, Opportunity> oppMap = new SLT_Opportunity().getOpportunityById(oppIdsList, new Set<String>{'Id','Name','Parent_Opportunity__c','AccountId','OwnerId','Owner.Email'});
            Map<Id, Contract> contractMap = new SLT_Contract().selectByContractId(contractIdsSet, new Set<String>{'Id','Name','ContractNumber'});
            List<Messaging.SingleEmailMessage> emailslist = new List<Messaging.SingleEmailMessage>();
            SWAT_Intake_alert__c usersEmailFromSetting = SWAT_Intake_alert__c.getInstance();
            if(usersEmailFromSetting != null){
                List<String> recipientUsersIds = new List<String>();
                if(usersEmailFromSetting.Users_Email__c != null && usersEmailFromSetting.Users_Email__c != ''){
                    recipientUsersIds = (usersEmailFromSetting.Users_Email__c).split(',');
                }
                for(SWAT_Intake__c swat : filteredSwatList){
                    filteredSwatIdsSet.add(swat.Id);
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setSubject('SWAT Intake Form Submission');
                    String emailBody = '<b>Details:</b><br/>';
                    emailBody += 'SWAT Intake Link: <a href="'+URL.getOrgDomainUrl().toExternalForm() + '/' + swat.Id+'" >'+swat.Name+'</a><br/>';
                    if(accountMap.get(swat.Client_Account__c) != null){
                        emailBody += 'Client Account: <a href="'+URL.getOrgDomainUrl().toExternalForm() + '/' + accountMap.get(swat.Client_Account__c).Id+'" >'+accountMap.get(swat.Client_Account__c).Name+'</a><br/>';
                    }else{
                        emailBody += 'Client Account: <br/>';
                    }
                    emailBody += 'Contract Value:'+CON_CRM.USD+' '+fetchNullValue(String.valueOf(swat.Contract_Value__c))+  '<br/>';
                    emailBody += 'Geographic Scope: ' +fetchNullValue(swat.Geographic_Scope__c)+  '<br/>';
                    emailBody += 'Service Start Date: ' +fetchNullValue(String.valueOf(swat.Service_Start_Date__c))+  '<br/>';
                    emailBody += 'Hybrid Study?: ' +fetchNullValue(swat.Hybrid_Study__c)+  '<br/>';
                    emailBody += 'US Gov Subcontract?: ' +fetchNullValue(swat.US_Gov_Subcontract__c)+  '<br/><br/>';
                    emailBody += '<b>Opportunity/Contact:</b><br/>';
                    if(oppMap.get(swat.Opportunity__c) != null){
                        emailBody += 'Opportunity: <a href="'+URL.getOrgDomainUrl().toExternalForm() + '/' + oppMap.get(swat.Opportunity__c).Id+'" >'+oppMap.get(swat.Opportunity__c).Name+'</a><br/>';
                    }else{
                        emailBody += 'Opportunity: <br/>';
                    }
                    emailBody += 'Opportunity Number: ' +fetchNullValue(swat.Opportunity_Number__c)+  '<br/>';
                    if(swat.Opportunity_Account__c != null){
                        emailBody += 'Opportunity Account: <a href="'+URL.getOrgDomainUrl().toExternalForm() + '/' + oppMap.get(swat.Opportunity__c).AccountId+'" >'+swat.Opportunity_Account__c+'</a><br/>';
                    }else{
                        emailBody += 'Opportunity Account: <br/>';
                    }
                    emailBody += 'Opportunity Stage: ' +fetchNullValue(swat.Opportunity_Stage__c)+  '<br/>';
                    if(swat.Parent_Opportunity__c != null){
                        emailBody += 'Parent Opportunity: <a href="'+URL.getOrgDomainUrl().toExternalForm() + '/' + oppMap.get(swat.Opportunity__c).Parent_Opportunity__c+'" >'+swat.Parent_Opportunity__c+'</a><br/>';
                    }else{
                        emailBody += 'Parent Opportunity: <br/>';
                    }
                    emailBody += 'Parent Opportunity Number: ' +fetchNullValue(swat.Parent_Opportunity_Number__c)+  '<br/>';
                    if(oppMap.get(swat.Prior_Opportunity__c) != null){
                        emailBody += 'Prior Opportunity: <a href="'+URL.getOrgDomainUrl().toExternalForm() + '/' + oppMap.get(swat.Prior_Opportunity__c).Id+'" >'+oppMap.get(swat.Prior_Opportunity__c).Name+'</a><br/>';
                    }else{
                        emailBody += 'Prior Opportunity: <br/>';
                    }
                    emailBody += 'Prior Opportunity Number: ' +fetchNullValue(swat.Prior_Opportunity_Number__c)+  '<br/>';
                    if(contractMap.get(swat.Existing_Contract__c) != null){
                        emailBody += 'Existing Contract: <a href="'+URL.getOrgDomainUrl().toExternalForm() + '/' + contractMap.get(swat.Existing_Contract__c).Id+'" >'+contractMap.get(swat.Existing_Contract__c).ContractNumber+'</a><br/>';
                    }else{
                        emailBody += 'Existing Contract: <br/>';
                    }
                    emailBody += '<b>Deliverables:</b><br/>';
                    emailBody += 'Products: ' +fetchNullValue(swat.Products__c)+  '<br/>';
                    emailBody += 'Delivery Resource Location: ' +fetchNullValue(swat.Delivery_Resource_Location__c)+  '<br/>';
                    emailBody += 'Site-based Study?: ' +fetchNullValue(swat.Site_based_Study__c)+  '<br/>';
                    emailBody += 'Software Included: ' +fetchNullValue(swat.Software_Included__c)+  '<br/>';
                    emailBody += 'Third Party Vendors Involved?: ' +fetchNullValue(swat.Third_Party_Vendors_Involved__c)+  '<br/><br/>';
                    emailBody += '<b>Data:</b><br/>';
                    emailBody += 'Data Used: ' +fetchNullValue(swat.Data_Used__c)+  '<br/>';
                    emailBody += 'Dataset Used: ' +fetchNullValue(swat.Dataset_Used__c)+  '<br/>';
                    emailBody += 'Data Access Location: ' +fetchNullValue(swat.Data_Access_Location__c)+  '<br/>';
                    emailBody += 'Data Delivery To Client: ' +fetchNullValue(swat.Data_Delivery_To_Client__c)+  '<br/><br/>';
                    emailBody += '<b>RWE:</b><br/>';
                    emailBody += 'Real World Category Offering: ' +fetchNullValue(swat.Real_World_Categories__c)+  '<br/>';
                    emailBody += 'Real-World Data Source: ' +fetchNullValue(swat.Real_World_Data_Source__c)+  '<br/>';
                    emailBody += 'Real-World Primary Data Source: ' +fetchNullValue(swat.Real_World_Primary_Data_Source__c)+  '<br/>';
                    emailBody += 'Real-World Secondary Data Source: ' +fetchNullValue(swat.Real_World_Secondary_Data_Source__c)+  '<br/>';
                    emailBody += 'Real-World Study Direction: ' +fetchNullValue(swat.Real_World_Study_Direction__c)+  '<br/>';
                    email.setTargetObjectId(UserInfo.getUserId());
                    recipientUsersIds.add(oppMap.get(swat.Opportunity__c).Owner.Email);
                    //email.setTreatTargetObjectAsRecipient(false);
                    email.setSaveAsActivity(false);
                    email.setToAddresses(recipientUsersIds);
                    email.setHtmlBody(emailBody); 
                    emailslist.add(email);
                }
                if (emailslist.size() > 0) {
                    Messaging.SendEmailResult[] results;
                    try{
                        results = Messaging.sendEmail(emailslist);
                    } catch(Exception e) {
                        System.debug('Email Failed: ' + e.getMessage());
                    }
                    if (results[0].success) {
                        System.debug('The email was sent successfully.');
                    } else {
                        System.debug('The email failed to send: ' + results[0].errors[0].message);
                    }
                }
            }
        }
        if(Trigger.isInsert){
            List<SWAT_Intake__c> swatNewList = new SLT_SWAT_Intake().selectBySwatId(filteredSwatIdsSet);
            for(SWAT_Intake__c swt : swatNewList){
                swt.Submit_Form_To_SWAT_Team__c = false;
                swt.Last_Submitted_Date__c = String.valueOf(Date.today());
            }
            UTL_ExecutionControl.stopTriggerExecution = true;
            update swatNewList;
            UTL_ExecutionControl.stopTriggerExecution = false;
        }
    }
    /*
    Method is used to raplace null with blank
    */
    public static String fetchNullValue(String param){
        String returnVal = '';
        if(param != null){
            returnVal = param;
        }
        return returnVal;
    }
}