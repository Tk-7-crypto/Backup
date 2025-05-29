global class CNT_PEP_ContractRenewalNotification Implements Schedulable{
    
    global void execute(SchedulableContext sc)
    {
        sendContractRenewalNotifications();
    }

    public void sendContractRenewalNotifications()
    {
        List<Contract> contractsForRenewal=new List<Contract>(); 
        //Date dateToday=Date.newInstance(2019, 04, 29); 
        Date dateToday=Date.Today();
        Datetime dt = (DateTime)dateToday;
        String dayOfWeek = dt.formatGMT('EEEE');
        Date dateOnSaturday=dateToday.addDays(-2); 
        Date dateOnSunday=dateToday.addDays(-1);
        String contractType='PRM Contract';		
        
        if(dayOfWeek=='Monday')
        {
            contractsForRenewal=[SELECT Id,Name,EndDate,Owner.Email,Notification_Counter__c,First_Notification_Date__c,
                                 Second_Notification_Date__c,Third_Notification_Date__c,AccountId,Agency_Program__r.Name
                                 FROM Contract 
                                 WHERE RecordType.Name= : contractType AND New_Contract_Number__c=NULL AND
                                 Notification_Counter__c<5 AND SOW_status__c='Signed' AND Non_Standard_Contract__c=false AND
                                 (First_Notification_Date__c= : dateOnSaturday OR Second_Notification_Date__c= : dateOnSaturday
                                 OR Third_Notification_Date__c= : dateOnSaturday OR First_Notification_Date__c= : dateOnSunday
                                 OR Second_Notification_Date__c= : dateOnSunday OR Third_Notification_Date__c= : dateOnSunday OR
                                 First_Notification_Date__c= : dateToday OR Second_Notification_Date__c= : dateToday OR
                                 Third_Notification_Date__c= : dateToday OR EndDate <: dateToday)];
            
        }
        else
        {            
            contractsForRenewal = [SELECT Id,Name,EndDate,Owner.Email,Notification_Counter__c,First_Notification_Date__c,
                                   Second_Notification_Date__c,Third_Notification_Date__c,AccountId,Agency_Program__r.Name FROM Contract
                                   WHERE RecordType.Name= : contractType AND New_Contract_Number__c=NULL AND
                                   Notification_Counter__c <5 AND SOW_status__c='Signed' AND Non_Standard_Contract__c=false AND
                                   (First_Notification_Date__c =:dateToday OR Second_Notification_Date__c =:dateToday OR
                                   Third_Notification_Date__c =:dateToday OR EndDate<:dateToday)];
        }
        
        String response='';
        Contact c = new Contact();
        String[] toCC=new String[]{'agency@iqvia.com'};
        List<Contract> updateContractCounter=new List<Contract>();
        CSM_Case_Details_Global_Setting__c noReply = CSM_Case_Details_Global_Setting__c.getValues('Org Wide No-Reply');
        List<Contract> newContracts=new List<Contract>();
        Messaging.SingleEmailMessage mailMessage = null;
        mailMessage = new Messaging.SingleEmailMessage();
        Map<String, String> templateIdNameMap = new Map<String, String>();
        
        if(contractsForRenewal.size()>0){
            for(Contract con : contractsForRenewal)
            {
                if(con.Notification_Counter__c==1 && (con.First_Notification_Date__c==dateToday || con.First_Notification_Date__c==dateOnSaturday || con.First_Notification_Date__c==dateOnSunday))
                {
                    newContracts.add(con);
                }
                else if(con.Notification_Counter__c==2 && (con.Second_Notification_Date__c==dateToday || con.Second_Notification_Date__c==dateOnSaturday || con.Second_Notification_Date__c==dateOnSunday))
                {
                    newContracts.add(con);
                }
                else if(con.Notification_Counter__c==3 && (con.Third_Notification_Date__c==dateToday || con.Third_Notification_Date__c==dateOnSaturday || con.Third_Notification_Date__c==dateOnSunday))
                {
                    
                    newContracts.add(con);
                }
                else if(con.Notification_Counter__c==4 && con.EndDate<dateToday)
                {
                    newContracts.add(con);
                    
                }
            }
        }
        Set<String> templateNameSet = new Set<String>{CON_PEP.S_PEP_CONTRACT_FIRSTNOTIFICATION,CON_PEP.S_PEP_CONTRACT_SECONDNOTIFICATION,CON_PEP.S_PEP_CONTRACT_THIRDNOTIFICATION,CON_PEP.S_PEP_CONTRACT_EXPIREDNOTIFICATION};
        List<EmailTemplate> emailTemplateList  = [SELECT Id, Name FROM EmailTemplate WHERE Name In :templateNameSet];
        if(emailTemplateList != null && !emailTemplateList.isEmpty()){
            for(EmailTemplate templateRecord : emailTemplateList){
                templateIdNameMap.put(templateRecord.Name, templateRecord.Id);
            }
        }
        if(newContracts.size()>0 && !templateIdNameMap.isEmpty()){
            
            for(Contract con: newContracts)
            {
    
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
                List<User> us=[SELECT Id,Username,UserRole.Name,Email,FirstName,Contact.Id,Contact.Email,UserRole.PortalRole FROM user where AccountId=:con.AccountId and Contact.PRM_Contract_Renewal_Notification__c = True and IsActive = true];
                
                if(us.size()>0){ 
                    Integer flag;
                    for(User usrs:us)
                    {
                        flag = 0;
                        mailMessage = new Messaging.SingleEmailMessage();
                        if(con.Notification_Counter__c==1 && templateIdNameMap.containsKey(CON_PEP.S_PEP_CONTRACT_FIRSTNOTIFICATION) && (con.First_Notification_Date__c==dateToday || con.First_Notification_Date__c==dateOnSaturday || con.First_Notification_Date__c==dateOnSunday))
                        {
                            mailMessage.setTemplateId(templateIdNameMap.get(CON_PEP.S_PEP_CONTRACT_FIRSTNOTIFICATION));
                            flag = 1;
                        }
                        else if(con.Notification_Counter__c==2 && templateIdNameMap.containsKey(CON_PEP.S_PEP_CONTRACT_SECONDNOTIFICATION) && (con.Second_Notification_Date__c==dateToday || con.Second_Notification_Date__c==dateOnSaturday || con.Second_Notification_Date__c==dateOnSunday))
                        {
                            mailMessage.setTemplateId(templateIdNameMap.get(CON_PEP.S_PEP_CONTRACT_SECONDNOTIFICATION));
                            flag = 1;
                        }
                        else if(con.Notification_Counter__c==3 && templateIdNameMap.containsKey(CON_PEP.S_PEP_CONTRACT_THIRDNOTIFICATION) && (con.Third_Notification_Date__c==dateToday || con.Third_Notification_Date__c==dateOnSaturday || con.Third_Notification_Date__c==dateOnSunday))
                        {
                            mailMessage.setTemplateId(templateIdNameMap.get(CON_PEP.S_PEP_CONTRACT_THIRDNOTIFICATION));
                            flag = 1;
                        }
                        else if(con.Notification_Counter__c==4 && templateIdNameMap.containsKey(CON_PEP.S_PEP_CONTRACT_EXPIREDNOTIFICATION) && con.EndDate<dateToday)
                        {
                            mailMessage.setTemplateId(templateIdNameMap.get(CON_PEP.S_PEP_CONTRACT_EXPIREDNOTIFICATION));
                            flag = 1;
                        }
                        List<String> toAddresses = new List<String>();
                        toAddresses.add(usrs.Contact.Email); 
                        mailMessage.setToAddresses(toAddresses);
                        mailMessage.setCCAddresses(toCC);
                        mailMessage.setTreatTargetObjectAsRecipient(false);
                        mailMessage.setTargetObjectId(usrs.Contact.Id);
                        mailMessage.setWhatId(con.Id);
                        mailMessage.setSaveAsActivity(false);
                        if(noReply != null && noReply.Component_Id__c != null && noReply.Component_Id__c.length() > 0) {
                            mailMessage.setOrgWideEmailAddressId(noReply.Component_Id__c);
                        }
                        allmsg.add(mailMessage); 
                        
                    }
                    if(flag > 0)
                    {
                        Messaging.sendEmail(allmsg,false);
                        con.Notification_Counter__c +=1;
                    }
                    
                    
                }
                updateContractCounter.add(con);
        }  
        if(updateContractCounter != null && !updateContractCounter.isEmpty()){
            update updateContractCounter;
        }
    }
  }
}