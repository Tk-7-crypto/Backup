public without sharing class DAOH_Account {
    /**
    * This method is used for create a new Data Audit Trail when the new case record is created.
    * @params  newList List<Account>
    * @return  void
    */
    public static void saveAuditLogAfterInsertAccount(List<Account> newList){
        CSM_QI_Data_Audit_Trail__c auditTrail = null;
        Map<ID,Schema.RecordTypeInfo> rt_Map = Case.sObjectType.getDescribe().getRecordTypeInfosById();
        List<CSM_QI_Data_Audit_Trail__c> auditTrailList = new List<CSM_QI_Data_Audit_Trail__c>();
        if(newList!=null && newList.size()>0){
            for(Account acc : newList) {
                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_CREATED,Name = CON_CSM.S_ACCOUNT,Account__c = acc.Id);
                auditTrailList.add(auditTrail);
            }  
        } 
        
        
        try {
            if(auditTrailList!=null && auditTrailList.size()>0){
                insert auditTrailList;
            }
        } catch (DmlException e) {
            System.debug('Failed due to : '+e);
        }
        
    }
    /**
    * This method is used for create a new Data Audit Trail when the case record fields are updated.
    * @params  newList List<Account>,oldMap Map<Id, Account> 
    * @return  void
    */
    public static void saveAuditLogAfterUpdateAccountFields(List<Account> newList, Map<Id, Account> oldMap,List<FieldDefinition> fields) {
        CSM_QI_Data_Audit_Trail__c auditTrail=null;
        List<CSM_QI_Data_Audit_Trail__c> auditTrailList = new List<CSM_QI_Data_Audit_Trail__c>();
        Map<ID,Schema.RecordTypeInfo> rt_Map = Case.sObjectType.getDescribe().getRecordTypeInfosById();
        EXT_CSM_CaseRelatedToObject accRelatedTo=null;
        List<EXT_CSM_CaseRelatedToObject> accRelatedToList=new List<EXT_CSM_CaseRelatedToObject>(); 
        if(fields!=null && fields.size()>0){
            for(Account acc : newList) {
                if(fields != null && fields.size() > 0 ) 
                {
                    for( FieldDefinition fd : fields){
                        
                        if(String.isBlank(fd.ExtraTypeInfo) && ((fd.DataType.contains(CON_CSM.S_TEXT) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_STRING)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_PICKLIST) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_STRING)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_NUMBER) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_DOUBLE)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_URL) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_STRING)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_PHONE) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_STRING)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_EMAIL) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_STRING)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_CHECKBOX) && fd.ValueTypeId.equalsIgnoreCase(CON_CSM.S_BOOLEAN)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_FORMULA) && fd.ValueTypeId.equalsIgnoreCase(CON_CSM.S_TEXT)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_DATE) && fd.ValueTypeId.equalsIgnoreCase(CON_CSM.S_DATETIME)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_DATE) && fd.ValueTypeId.equalsIgnoreCase(CON_CSM.S_DATE)))){
                            if(acc.get(fd.QualifiedApiName) == null && oldMap.get(acc.Id).get(fd.QualifiedApiName) != null){
                                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_DELETED,Name = fd.MasterLabel,Old_Value__c = String.valueOf(oldMap.get(acc.Id).get(fd.QualifiedApiName)),New_Value__c = String.valueOf(acc.get(fd.QualifiedApiName)),Account__c = acc.Id);
                                auditTrailList.add(auditTrail);
                            }else if(acc.get(fd.QualifiedApiName) != null && oldMap.get(acc.Id).get(fd.QualifiedApiName)==null){
                                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c=CON_CSM.S_ADDED,Name = fd.MasterLabel,Old_Value__c = String.valueOf(oldMap.get(acc.Id).get(fd.QualifiedApiName)),New_Value__c = String.valueOf(acc.get(fd.QualifiedApiName)),Account__c = acc.Id);
                                auditTrailList.add(auditTrail);
                            }else if(acc.get(fd.QualifiedApiName)!=null && !acc.get(fd.QualifiedApiName).equals(oldMap.get(acc.Id).get(fd.QualifiedApiName))){
                                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c=CON_CSM.S_CHANGED,Name = fd.MasterLabel,Old_Value__c = String.valueOf(oldMap.get(acc.Id).get(fd.QualifiedApiName)),New_Value__c = String.valueOf(acc.get(fd.QualifiedApiName)),Account__c = acc.Id);
                                auditTrailList.add(auditTrail);
                            }
                        }else if(String.isBlank(fd.ExtraTypeInfo) && (fd.DataType.contains(CON_CSM.S_LOOKUP) || fd.DataType.contains(CON_CSM.S_HIERARCHY)) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_ID)){
                            if(acc.get(fd.QualifiedApiName) == null && oldMap.get(acc.Id).get(fd.QualifiedApiName) != null){
                                accRelatedTo = new EXT_CSM_CaseRelatedToObject(CON_CSM.S_DELETED,fd.RelationshipName,CON_CSM.S_ACCOUNT,fd.MasterLabel,(Id)oldMap.get(acc.Id).get(fd.QualifiedApiName),null,acc.Id);
                                accRelatedToList.add(accRelatedTo);
                            }else if(acc.get(fd.QualifiedApiName) != null && oldMap.get(acc.Id).get(fd.QualifiedApiName) == null){
                                accRelatedTo=new EXT_CSM_CaseRelatedToObject(CON_CSM.S_ADDED,fd.RelationshipName,CON_CSM.S_ACCOUNT,fd.MasterLabel,null,(Id)acc.get(fd.QualifiedApiName),acc.Id);
                                accRelatedToList.add(accRelatedTo);    
                            }else if(acc.get(fd.QualifiedApiName) != null && oldMap.get(acc.Id).get(fd.QualifiedApiName) != null && !acc.get(fd.QualifiedApiName).equals(oldMap.get(acc.Id).get(fd.QualifiedApiName))){
                                accRelatedTo = new EXT_CSM_CaseRelatedToObject(CON_CSM.S_CHANGED,fd.RelationshipName,CON_CSM.S_ACCOUNT,fd.MasterLabel,(Id)oldMap.get(acc.Id).get(fd.QualifiedApiName),(Id)acc.get(fd.QualifiedApiName),acc.Id);
                                accRelatedToList.add(accRelatedTo);
                            }
                        }else if(String.isNotBlank(fd.ExtraTypeInfo) && fd.DataType.contains(CON_CSM.S_TEXT) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_STRING)){
                            if(acc.get(fd.QualifiedApiName) != null && !acc.get(fd.QualifiedApiName).equals(oldMap.get(acc.Id).get(fd.QualifiedApiName))){
                                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_EDITED,Name = fd.MasterLabel,Old_Text_Value__c = String.valueOf(oldMap.get(acc.Id).get(fd.QualifiedApiName)),Account__c = acc.Id);
                                auditTrailList.add(auditTrail);
                            }
                        }else if(String.isBlank(fd.ExtraTypeInfo) && fd.QualifiedApiName.equals(CON_CSM.S_BILLINGADDRESS) && fd.DataType.contains(CON_CSM.S_ADDRESS)){
                            
                            if(acc.BillingStreet==null && oldMap.get(acc.Id).BillingStreet!=null){
                                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_EDITED,Name = CON_CSM.S_A_BSTREET,Account__c = acc.Id);
                                auditTrailList.add(auditTrail);
                            }else if(acc.BillingStreet!=null && oldMap.get(acc.Id).BillingStreet==null){
                                auditTrail=new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_EDITED,Name = CON_CSM.S_A_BSTREET,Account__c = acc.Id);
                                auditTrailList.add(auditTrail);
                            }else if(acc.BillingStreet!=null && oldMap.get(acc.Id).BillingStreet!=null && !acc.BillingStreet.equalsIgnoreCase(oldMap.get(acc.Id).BillingStreet)){
                                auditTrail=new CSM_QI_Data_Audit_Trail__c(Action__c=CON_CSM.S_EDITED,Name=CON_CSM.S_A_BSTREET,Account__c = acc.Id);
                                auditTrailList.add(auditTrail);    
                            }
                            if(acc.BillingCity == null && oldMap.get(acc.Id).BillingCity != null){
                                auditTrail=new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_DELETED,Name = CON_CSM.S_A_BCITY,Old_Value__c = oldMap.get(acc.Id).BillingCity,New_Value__c = acc.BillingCity,Account__c = acc.Id);
                                auditTrailList.add(auditTrail);
                            }else if(acc.BillingCity!=null && oldMap.get(acc.Id).BillingCity==null){
                                auditTrail=new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_ADDED,Name = CON_CSM.S_A_BCITY,Old_Value__c = oldMap.get(acc.Id).BillingCity,New_Value__c = acc.BillingCity,Account__c = acc.Id);
                                auditTrailList.add(auditTrail);
                            }else if(acc.BillingCity != null && oldMap.get(acc.Id).BillingCity != null && !acc.BillingCity.equalsIgnoreCase(oldMap.get(acc.Id).BillingCity)){
                                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_CHANGED,Name = CON_CSM.S_A_BCITY,Old_Value__c = oldMap.get(acc.Id).BillingCity,New_Value__c = acc.BillingCity,Account__c = acc.Id);
                                auditTrailList.add(auditTrail);
                            }
                            
                            if(acc.BillingState == null && oldMap.get(acc.Id).BillingState != null){
                                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_DELETED,Name = CON_CSM.S_A_BSTATE,Old_Value__c = oldMap.get(acc.Id).BillingState,New_Value__c = acc.BillingState,Account__c = acc.Id);
                                auditTrailList.add(auditTrail);
                            }else if(acc.BillingState != null && oldMap.get(acc.Id).BillingState == null){
                                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_ADDED,Name = CON_CSM.S_A_BSTATE,Old_Value__c = oldMap.get(acc.Id).BillingState,New_Value__c = acc.BillingState,Account__c = acc.Id);
                                auditTrailList.add(auditTrail);
                            }else if(acc.BillingState != null && oldMap.get(acc.Id).BillingState != null && !acc.BillingState.equalsIgnoreCase(oldMap.get(acc.Id).BillingState)){
                                auditTrail=new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_CHANGED,Name = CON_CSM.S_A_BSTATE,Old_Value__c = oldMap.get(acc.Id).BillingState,New_Value__c = acc.BillingState,Account__c = acc.Id);
                                auditTrailList.add(auditTrail); 
                            }
                            if(acc.BillingPostalCode == null && oldMap.get(acc.Id).BillingPostalCode != null){
                                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_DELETED,Name = CON_CSM.S_A_BPOSTALCODE,Old_Value__c = oldMap.get(acc.Id).BillingPostalCode,New_Value__c = acc.BillingPostalCode,Account__c = acc.Id);
                                auditTrailList.add(auditTrail);
                            }else if(acc.BillingPostalCode != null && oldMap.get(acc.Id).BillingPostalCode == null){
                                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_ADDED,Name = CON_CSM.S_A_BPOSTALCODE,Old_Value__c = oldMap.get(acc.Id).BillingPostalCode,New_Value__c = acc.BillingPostalCode,Account__c = acc.Id);
                                auditTrailList.add(auditTrail);
                            }else if(acc.BillingPostalCode != null && oldMap.get(acc.Id).BillingPostalCode != null && !acc.BillingPostalCode.equalsIgnoreCase(oldMap.get(acc.Id).BillingPostalCode)){
                                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_CHANGED,Name = CON_CSM.S_A_BPOSTALCODE,Old_Value__c = oldMap.get(acc.Id).BillingPostalCode,New_Value__c = acc.BillingPostalCode,Account__c = acc.Id);
                                auditTrailList.add(auditTrail);
                            }
                            if(acc.BillingCountry == null && oldMap.get(acc.Id).BillingCountry != null){
                                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_DELETED,Name = CON_CSM.S_A_BCOUNTRY,Old_Value__c = oldMap.get(acc.Id).BillingCountry,New_Value__c = acc.BillingCountry,Account__c = acc.Id);
                                auditTrailList.add(auditTrail);
                            }else if(acc.BillingCountry != null && oldMap.get(acc.Id).BillingCountry == null){
                                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c=CON_CSM.S_ADDED,Name=CON_CSM.S_A_BCOUNTRY,Old_Value__c = oldMap.get(acc.Id).BillingCountry,New_Value__c = acc.BillingCountry,Account__c = acc.Id);
                                auditTrailList.add(auditTrail);
                            }else if(acc.BillingCountry != null && oldMap.get(acc.Id).BillingCountry != null && !acc.BillingCountry.equalsIgnoreCase(oldMap.get(acc.Id).BillingCountry)){
                                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_CHANGED,Name = CON_CSM.S_A_BCOUNTRY,Old_Value__c = oldMap.get(acc.Id).BillingCountry,New_Value__c = acc.BillingCountry,Account__c = acc.Id);
                                auditTrailList.add(auditTrail);
                            }
                        }
                    }
                }
            }
            
            if(accRelatedToList!=null && accRelatedToList.size()>0)
            {
                Set<Id> pAccSet = new Set<Id>(),usrSet = new Set<Id>();
                
                for(EXT_CSM_CaseRelatedToObject obj:accRelatedToList){
                    if(CON_CSM.S_ACCOUNT.equals(obj.objRelName)){
                        pAccSet.add(obj.oldId);
                        pAccSet.add(obj.newId);
                    }else if(CON_CSM.S_USER.equals(obj.objRelName)){
                        usrSet.add(obj.oldId);
                        usrSet.add(obj.newId);
                    }
                }
                Set<String> fieldSet = new Set<String> {CON_CSM.s_id, CON_CSM.s_name};
                Map<Id, Account> parntaccountMap =null;
                Map<Id, User> usrMap=null;
                if(pAccSet.size() > 0) parntaccountMap = new SLT_Account().selectByAccountId(pAccSet, fieldSet);
                if(usrSet.size() > 0) usrMap = new SLT_User().selectByUserId(usrSet, fieldSet);
                for(EXT_CSM_CaseRelatedToObject obj : accRelatedToList){
                    if(parntaccountMap != null && parntaccountMap.size() > 0 && CON_CSM.S_ACCOUNT.equals(obj.objRelName)){
                        auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = obj.action,Name = obj.fieldName,Account__c = obj.objectId,Old_Value__c = parntaccountMap.containsKey(obj.oldId) ? parntaccountMap.get(obj.oldId).Name : '',New_Value__c = parntaccountMap.containsKey(obj.newId) ? parntaccountMap.get(obj.newId).Name : '');
                        auditTrailList.add(auditTrail);
                    }else if(usrMap != null && usrMap.size()>0 && CON_CSM.S_USER.equals(obj.objRelName)){
                        auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = obj.action,Name = obj.fieldName,Account__c = obj.objectId,Old_Value__c = usrMap.containsKey(obj.oldId) ? usrMap.get(obj.oldId).Name : '',New_Value__c = usrMap.containsKey(obj.newId) ? usrMap.get(obj.newId).Name : ''); 
                        auditTrailList.add(auditTrail);
                    } 
                    
                }
            }
            
            
            try {
                if(auditTrailList != null && auditTrailList.size()>0){
                    insert auditTrailList;     
                }
                
            } catch (DmlException e) {
                System.debug('Failed due to : '+e);
            }
        }
    }
    
    /**
     * This method is used to prevent deleteion of accounts by Non-Admin users
     * @params  List<Account> deleteList
     * @return  void
     */
    public static void preventDeletionOfAccounts(List<Account> deleteList) {
        Set<Id> idSet = new Set<Id>{UserInfo.getUserId()};
        Set<String> fieldSet = new Set<String>{'Profile.Name'};
        Map<Id, User> idUserMap = new SLT_User().selectByUserId(idSet, fieldSet);
        String profileName = idUserMap.get(UserInfo.getUserId()).Profile.Name;
        for (Account acc : deleteList) {
            if(acc.RecordTypeId == CON_CRM.GLOBAL_CUSTOMER_ACCOUNT_RECORD_TYPE_ID && !profileName.containsIgnoreCase(CON_CRM.SYSTEM_ADMIN_PROFILE)) {
                acc.addError(SYSTEM.LABEL.CRM_CL0020_GLOBAL_CUSTOMER_ACCOUNT_DELETION_ERROR);
            }
            if(acc.RecordTypeId == CON_CRM.MDM_VALIDATED_ACCOUNT_RECORD_TYPE_ID && !profileName.containsIgnoreCase(CON_CRM.SYSTEM_ADMIN_PROFILE)) {
                acc.addError(SYSTEM.LABEL.CRM_CL0021_MDM_VALIDATED_DELETION_ERROR);
            }
        }
    }
    
    /**
     * This method is used to change aaccount feilds.
     * @params  newList List<Account>
     * @params  oldMap Map<Id, Account>
     * @return  void
     */
    public static void setAccountFields(List<Account> newList, Map<Id, Account> oldMap) {
        Map<String,IQVIA_Account_Country_Region_Mapping__mdt> accountCountryRegionMap = new Map<String,IQVIA_Account_Country_Region_Mapping__mdt>();
        accountCountryRegionMap = new SLT_IQVIAAccountCountryRegionMapping().getaccountCountryToRegionMetadataMap();
        Set<String> billingFields = new Set<String>{'BillingCountry', 'BillingPostalCode', 'BillingState', 'BillingCity', 'BillingStreet'};
        Set<String> accountFieldSet =new Set<String>{'Id','Name'};
        Map<Id,Account> avacareAccountMap  = new SLT_Account().getAccounts(accountFieldSet,'Name = \'Avacare\'');  
        ID avacareAccID;
        if(!avacareAccountMap.isEmpty()){
            avacareAccID =  avacareAccountMap.values()[0].id;
        }
        
        for (Account acc : newList) {  
            if (Trigger.isInsert || (Trigger.isUpdate && oldMap.get(acc.id).AccountCountry__c != acc.AccountCountry__c)) {
                if(!String.isBlank(acc.AccountCountry__c) && accountCountryRegionMap.containsKey(acc.AccountCountry__c)) {
                    acc.Region__c = accountCountryRegionMap.get(acc.AccountCountry__c).Region__c;
                }
                else if(String.isBlank(acc.AccountCountry__c) && !String.isBlank(acc.Region__c)) {
                    acc.Region__c = null;
                }   
            }
            if(String.isBlank(acc.website)) {
                acc.Is_valid_website__c = false;
            }
            if(!String.isBlank(acc.website) && (Trigger.isInsert || Trigger.isUpdate && acc.Website != oldMap.get(acc.id).Website)) {
                if(Pattern.matches('^((http|https)://)??(www[.])([a-zA-Z0-9]|-)+?([.][a-zA-Z0-9(-|/|=|?)??]+?)+?$', acc.Website)) {
                    acc.Is_valid_website__c = true;
                } else {
                    acc.Is_valid_website__c = false;
                }
            }
            if(Trigger.isUpdate && oldMap.get(acc.id).Risk_Rating__c != acc.Risk_Rating__c){
                acc.Date_Time_Risk_Assessed__c = System.now();
                if(acc.Risk_Rating__c == null){
                    acc.Date_Risk_Assessed__c = null;
                }else{
                    acc.Date_Risk_Assessed__c = Date.today();
                }
            }
            if(acc.ParentId == avacareAccID && acc.MDM_Validation_Status__c == CON_CRM.MDM_UNVALIDATION_STATUS_VALIDATED && acc.Type2__c != null && (acc.Type2__c.contains('Clinical Site') || acc.Type2__c.contains('Investigator'))){
                //ESPSFDCQI-17089 - do not blank billing address 
            }
            else{	 
                for(String billingfield : billingFields){
                    if(!String.isBlank(String.valueOf(acc.get(billingfield)))){
                        acc.put(billingfield, '');
                    }
                }
            }
        }
    }
    
    /**
     * This method is used to merge duplicate accounts
     * @params  newMap Map<Id, Account>
     * @params  oldMap Map<Id, Account>
     * @return  void
     */
    public static void mergeAccounts(Map<Id, Account> newMap, Map<Id, Account> oldMap) {
        //Set<Id> sfdcGoldenRecordIdSet = new Set<Id>();
        Map<Id, List<Account>> sfdcGoldenIdToDupeAccountListMap = new Map<Id, List<Account>>();
        Set<String> excludeFieldSet = new Set<String>{'LQ_Account_Id__c', 'LI_Account_Id__c', 'MDM_SFDC_Golden_Record_Id__c', 'Legacy_Id__c'};
        for (Account dupeAccount : newMap.values()) {
            if(dupeAccount.MDM_Validation_Status__c != oldMap.get(dupeAccount.Id).MDM_Validation_Status__c && dupeAccount.MDM_Validation_Status__c == 'Rejected' && !String.isBlank(dupeAccount.MDM_SFDC_Golden_Record_Id__c) && dupeAccount.RecordTypeId != CON_CRM.GLOBAL_ACCOUNT_RECORD_TYPE_ID) {
                //Check that SurvivorAccount has valid LI_account_id__C and Valid LQ_Account_id__C
                // Check SurvivorAccount is not Global Customer
                //  Check that MDM_SFDC_Golden_Record_Id__c is a valid account id
                //sfdcGoldenRecordIdSet.add(dupeAccount.MDM_SFDC_Golden_Record_Id__c);
                if(sfdcGoldenIdToDupeAccountListMap.containsKey(dupeAccount.MDM_SFDC_Golden_Record_Id__c)) {
                    sfdcGoldenIdToDupeAccountListMap.get(dupeAccount.MDM_SFDC_Golden_Record_Id__c).add(dupeAccount);
                }
                else {
                    sfdcGoldenIdToDupeAccountListMap.put(dupeAccount.MDM_SFDC_Golden_Record_Id__c, new List<Account>{dupeAccount});
                }
                
            }
        }
        if(sfdcGoldenIdToDupeAccountListMap.size() > 0) {
            Map <String, Schema.SObjectField> fieldMap = Schema.SObjectType.Account.fields.getMap();
            Set<String> accountFieldSet = new Set<String>();
            for(Schema.SObjectField sfield : fieldMap.values()) {
                if(sfield.getDescribe().isUpdateable()) {
                    accountFieldSet.add(sfield.getDescribe().getName());
                }
            }
            System.debug('accountFieldSet---' + accountFieldSet);
            String whereCondition = 'LI_Account_Id__c != \'\'' +  ' and LQ_Account_id__c != \'\'' + ' and Recordtype.name != \'' + CON_CRM.GLOBAL_ACCOUNT_RECORD_TYPE_ID + '\' and Id IN  ( ';
            for(Id sfdcId : sfdcGoldenIdToDupeAccountListMap.keySet()) {
                whereCondition +=  '\'' + sfdcId + '\' , ';
            }
            whereCondition = whereCondition.removeEnd(', ');
            whereCondition += ' )';
            System.debug('whereCondition  ' + whereCondition);
            Map<Id, Account> accountMap = new SLT_Account().getAccounts(accountFieldSet, whereCondition);
            List<Account> survivorAccountList = accountMap.values();
            List<Account> dupeAccountList = new List<Account>();
            for(List<Account> dupeAccounts : sfdcGoldenIdToDupeAccountListMap.values()) {
                dupeAccountList.addAll(dupeAccounts);
            }
            List<AccountContactRelation> accContactRelList = new SLT_AccountContactRelation().getAccountContactRelations(dupeAccountList, survivorAccountList);
            if(accContactRelList.size() > 0) {
                delete accContactRelList;
            }
            if(survivorAccountList.size() > 0) {
                //  Check all fields of dupe account.  If dupe account has a value in the field and survivor has null value, update survivor to keep value of the dupe.
                //  Do not do this for LI_Account_Id__c and LQ_Account_Id__c fields as it will cause issues for mulesoft
                
                Map<Id, Set<Id>> surviAcTodupeAcccMap = new Map<Id, Set<Id>>();
                for(Account survivorAcc : survivorAccountList) {
                    for(String fieldName : accountFieldSet) {
                        if(!excludeFieldSet.contains(fieldName) && survivorAcc.get(fieldName) == NULL && sfdcGoldenIdToDupeAccountListMap.containsKey(survivorAcc.Id)) {
                            List<Account> dupeAccounts = sfdcGoldenIdToDupeAccountListMap.get(survivorAcc.Id);
                            for(Account dupeAccount : dupeAccounts) {
                                if(dupeAccount.get(fieldName) != NULL) {
                                    survivorAcc.put(fieldName, dupeAccount.get(fieldName));
                                    break;
                                }
                            }
                        } 
                    }
                    List<Account> dupeAccounts  = sfdcGoldenIdToDupeAccountListMap.get(survivorAcc.Id);
                    Set<Id> dupeAccSet = new Set<Id>();
                    for(Account dupeAcc : dupeAccounts) {
                        dupeAccSet.add(dupeAcc.Id);
                    }
                    surviAcTodupeAcccMap.put(survivorAcc.Id, dupeAccSet);
                }
                update survivorAccountList;
                if(surviAcTodupeAcccMap.size() > 0) {
                    mergeAccountsFuture(JSON.serialize(surviAcTodupeAcccMap));
                }
            }
        }
    }
    
    /**
     * This method is used to merge duplicate accounts
     * @params  newMap Map<Id, Account>
     * @params  oldMap Map<Id, Account>
     * @return  void
     */
    @future
    public static void mergeAccountsFuture(String surviAcTodupeAcccMapJson) {
        Map<Id, Set<Id>> surviAcTodupeAcccMap = (Map<Id, Set<Id>>)JSON.deserialize(surviAcTodupeAcccMapJson, Map<Id, Set<Id>>.Class);
        Set<Id> allAccountSet = new Set<Id>();
        allAccountSet.addAll(surviAcTodupeAcccMap.keySet());
        for(Id surId : surviAcTodupeAcccMap.keySet()) {
            allAccountSet.addAll(surviAcTodupeAcccMap.get(surId));
        }
        Map<Id, Account> accountMap = new Map<Id, Account>([Select Id from Account where Id IN :allAccountSet]);
        List<Merge_Queue__c> mergeQueueList = new List<Merge_Queue__c>();
        for(Id servivorAccountId : surviAcTodupeAcccMap.keySet()) {
            List<Account> dupeAccounts = new List<Account>();
            for(Id dupeId : surviAcTodupeAcccMap.get(servivorAccountId)) {
                Account dupeAccount = accountMap.get(dupeId);
                try {
                    merge accountMap.get(servivorAccountId) dupeAccount;
                } catch(Exception ex) {
                    Merge_Queue__c mq = new Merge_Queue__c();
                    mq.SobjectType__c = 'Account';
                    mq.Merge_Status__c = 'Failed';
                    mq.Merge_Error_Message__c = ex.getMessage();
                    mq.MasterRecordId__c = servivorAccountId;
                    mq.Dupe_Id_1__c = dupeAccount.Id;
                    mergeQueueList.add(mq);
                }
            }
        }
        if(mergeQueueList.size() > 0) {
            insert mergeQueueList;
        }
    }

    public static void checkIfCSHSelfRegistration(List<Account> listOfAccount) {
        Boolean hasCustomPermission = FeatureManagement.checkPermission('CSM_Bypass_CSM_Validation_Rules');
        if(listOfAccount != null && !listOfAccount.isEmpty()){
            for(Account newAccount : listOfAccount){
                if(!newAccount.IsCustomerPortal && !String.isEmpty(newAccount.CSH_Self_Registration__c) && hasCustomPermission == false){
                    newAccount.addError('Account should be customer portal enabled for self registration');
                }
            }
        }
    }    
    /*ESPSFDCQI-4267
     *This method is used to send email to opp owner
     * @params  List<Account> listOfAccount
     * @params  map<Id,Account> oldMap
     * @return  void
    */
    public static void sendEmailToOppOwner(List<Account> listOfAccount, map<Id,Account> oldMap){
        List<Id> accIds = new List<Id>();
       
        for(Account acc : listOfAccount){
            if(acc.Global_Risk_Rating__c != oldMap.get(acc.Id).Global_Risk_Rating__c  && acc.Global_Risk_Rating__c == CON_CRM.ACCOUNT_RISK_RATING_6_DO_NOT_SELL ){
                accIds.add(acc.Id);   
            }
        }
        
        if(accIds.size() > 0){
            User_Permissions__c userPermission = User_Permissions__c.getInstance();
            if(!userPermission.Stop_Risk_Rating_Account_Notifications__c){
                sendEmailToOppOwnerFuture(accIds);
            }
        }
    }
    
    /*ESPSFDCQI-4267
     *This future method is used to send email to opp owner
     * List<Id> parentAccIds
     * @return  void
    */
    //@future commented facing issue in Descartes approval - ESPSFDCQI-12068
    public static void sendEmailToOppOwnerFuture(List<Id> parentAccIds){
        Map<Id,String> accIdToNameMap = new Map<Id,String>();
        List<String> oppStageNameList = new List<String>{CON_CRM.IDENTIFYING_OPP_STAGE,
            CON_CRM.QUALIFYING_OPP_STAGE,CON_CRM.DEVELOPING_PROP_STAGE,
            CON_CRM.DELIVERING_PROP_STAGE,CON_CRM.FINALIZING_DEAL_STAGE,
            CON_CRM.RECEIVED_ATP_STAGE};
        List<Id> mailAccountList = new List<Id>();
        mailAccountList.addAll(parentAccIds);
        List<Account> childAccountsList = new SLT_Account().getAccountsList(new Set<String>{'Id','Global_Risk_Rating__c','Risk_Rating__c','ParentId','Parent.Name'}, parentAccIds);
        
        for(Account childAcc : childAccountsList){
            String parentName = childAcc.Parent.Name;
            if(childAcc.Risk_Rating__c == null && !parentName.startsWith('LOCAL') && childAcc.Global_Risk_Rating__c == CON_CRM.ACCOUNT_RISK_RATING_6_DO_NOT_SELL ){
                mailAccountList.add(childAcc.Id);
                accIdToNameMap.put(childAcc.Id,childAcc.Parent.Name);
            }
        }
        
        Map<Id,Opportunity> accIdtoOpp  = new Map<Id,Opportunity>(new SLT_Opportunity().getOpportunityByCondition(new Set<String>{'Id','OwnerId','Owner.Email','Account.Name','AccountId','Name','Account.ParentId','Account.Parent.Name'},mailAccountList, oppStageNameList));

        Map<Id,List<Opportunity>> ownerIdToOppMap = new Map<Id,List<Opportunity>>();
        for(Opportunity currentOpp : accIdtoOpp.values()){
            if(ownerIdToOppMap.containsKey(currentOpp.OwnerId)){
                ownerIdToOppMap.get(currentOpp.OwnerId).add(currentOpp);
            }else{
                ownerIdToOppMap.put(currentOpp.OwnerId, new List<Opportunity>{currentOpp});
            }
        }
        sendEmails(ownerIdToOppMap,accIdToNameMap);
    }
    
    public static void sendEmails(Map<Id,List<Opportunity>> ownerIdToOppMap, Map<Id,String> accIdToNameMap){
		List<UTL_CRM_SendEmail.MessageWrapper> messageList = new List<UTL_CRM_SendEmail.MessageWrapper>();
        String baseUrl = URL.getOrgDomainUrl().toExternalForm();
        String fileId = Account_Setting__c.getInstance().Account_Credit_Check_Form__c;
        for(Id ownerId : ownerIdToOppMap.keySet()){

            String htmlTable = '<Table style="border-collapse: collapse;border: 0.1px solid black;width:100%"><thead><tr><th style="border-collapse: collapse;border: 0.1px solid black;" >S.No</th><th style="border-collapse: collapse;border: 0.1px solid black;">Opportunity Name</th><th style="border-collapse: collapse;border: 0.1px solid black;">Account Name</th></tr></thead><tbody>';
            Integer i = 1;
            List<Opportunity> oppsListToMail = ownerIdToOppMap.get(ownerId);
            String accName = '';
            String accId = '';
            for(Opportunity opps1 : oppsListToMail){
                if(accIdToNameMap.get(opps1.AccountId) != null){
                    accName = opps1.Account.Parent.Name;
                    accId = opps1.Account.Parent.Id;
                    break;
                }else{
                    accName = opps1.Account.Name;
                    accId = opps1.Account.Id;
                }
            }
            
            for(Opportunity opps1 : oppsListToMail){
                htmlTable = htmlTable +'<tr><td style="border: 1px solid black;text-align: center;">'+(i++)+'</td><td style="border: 1px solid black;text-align: center;"><a href="'+baseUrl+'/'+opps1.Id+'">'+opps1.Name+'</a></td><td style="border: 1px solid black;text-align: center;"> <a href="'+baseUrl+'/'+opps1.AccountId+'">'+opps1.Account.Name+'</a></td></tr>';
            }
            String documentLink = '<a href="'+fileId+'">Download Credit Check Form</a>';
            String emailTextBody = 'The Account is closed to new business by Finance and cannot be advanced nor contracted with at this time.  Please find below affected open opportunities. You cannot progress these. Please contact your local BU Credit Control/Finance lead for information on this account.';
            htmlTable = htmlTable + '</tbody></Table>';
            
            String subject = 'The Account '+ accName +'\'s Global Risk Rating is set to "Do Not Sell". Please review affected opportunities.';
            String content = emailTextBody+'<br/><br/>'+htmlTable+ '<br/><br/>'+documentLink;
            
            UTL_CRM_SendEmail.MessageWrapper message = new UTL_CRM_SendEmail.MessageWrapper();
            message.toUserIds = new List<String>{ownerId};
            message.whatId = accId;
            message.subject = subject;
            message.staticContent = content;
            messageList.add(message);
        }
        if(messageList.size()>0)
            UTL_CRM_SendEmail.sendEmailThroughWorkflow(messageList);
    }
    
    /**
     * This method is used to set Risk Rating For Global Customer Account type and to reset it if the Record type 
     * changes from Global Customer Account to any other type as well as if MDM category changes.
     * @params  newList List<Account>
     * @return  void
     */
    //User Story - ESPSFDCQI-4268
    public static void setRiskRatingForGlobalCustomerAccount(List<Account> newList, Map<Id, Account> oldMap){
        for(Account acc : newList){
            /*ESPSFDCQI-13217: Allow Super Credit Control Users to update Risk Rating field on Large Pharma Accounts
            if(acc.recordtypeId == CON_CRM.GLOBAL_CUSTOMER_ACCOUNT_RECORD_TYPE_ID && acc.MDM_Category__c == CON_CRM.ACCOUNT_MDM_CATEGORY_LARGE_PHARMA && acc.Risk_Rating__c != CON_CRM.ACCOUNT_RISK_RATING_1_VERY_LOW){
                acc.Risk_Rating__c = CON_CRM.ACCOUNT_RISK_RATING_1_VERY_LOW;
                acc.Date_Time_Risk_Assessed__c = System.now();
            }*/
            if(Trigger.isUpdate){
                Account oldAccount = oldMap.get(acc.id);
                if((oldAccount.recordtypeId == CON_CRM.GLOBAL_CUSTOMER_ACCOUNT_RECORD_TYPE_ID && acc.recordtypeId != CON_CRM.GLOBAL_CUSTOMER_ACCOUNT_RECORD_TYPE_ID)||(oldAccount.MDM_Category__c == CON_CRM.ACCOUNT_MDM_CATEGORY_LARGE_PHARMA && acc.MDM_Category__c != CON_CRM.ACCOUNT_MDM_CATEGORY_LARGE_PHARMA)){
                    acc.Risk_Rating__c = '';
                    acc.Date_Risk_Assessed__c = null;
                    acc.Date_Time_Risk_Assessed__c = System.now();
                } 
            }      
        }
    }
    
    public static void setLastSharingCalculationTimestamp(List<Account> newRecordList, Map<Id, Account> oldMap) {
        for (Account acc :newRecordList) {
            if (Trigger.isInsert || (Trigger.isUpdate && acc.AccountCountry__c != oldMap.get(acc.Id).AccountCountry__c)) {
                acc.Last_Sharing_Calculation_Timestamp__c = System.now();
            }
        }
    }
    
    /**
     * This method is used to check whether the user can edit Risk Rating or not
     * @params newRecordList List<Account>
     * @params oldMap Map<Id, Account>
     * @return void
     */
    public static void validateRiskRating(List<Account> newRecordList, Map<Id, Account> oldMap) {
        Boolean isSuperUser = false;
        Credit_Control_Groups__c cs = Credit_Control_Groups__c.getOrgDefaults();
        if (cs.Group_Names__c != null) {
            Set<String> groupNameSet = new Set<String>(cs.Group_Names__c.split(','));
            Id userId = UserInfo.getUserId();
            List<GroupMember> groupMemberList = new List<GroupMember>();
            groupMemberList = new SLT_GroupMember().getGroupMembersByUserAndGroupNameSet(userId, groupNameSet);
            for (GroupMember gm : groupMemberList) {
                if(gm.Group.Name == CON_CRM.SUPER_CREDIT_CONTROL_ADMIN_GROUP) {
                    isSuperUser = true;
                    break;
                }
            }
            for (Account acc : newRecordList) {
                if (!isSuperUser && (Trigger.isInsert || Trigger.isUpdate && acc.DPS_Status__c == oldMap.get(acc.Id).DPS_Status__c)) {
                    acc.Is_Super_Credit_Group_User__c = false;
                    if ((Trigger.isInsert && acc.Risk_Rating__c != null) || (Trigger.isUpdate && acc.Risk_Rating__c != oldMap.get(acc.Id).Risk_Rating__c)) {
                        if (groupMemberList.size() == 0) {
                            acc.addError(System.Label.CRM_CL0034_Account_Risk_Rating_Update_Error);
                        } else if ((Trigger.isInsert && acc.Risk_Rating__c == CON_CRM.ACCOUNT_RISK_RATING_6_DO_NOT_SELL) || (Trigger.isUpdate && (oldmap.get(acc.Id).Risk_Rating__c == CON_CRM.ACCOUNT_RISK_RATING_6_DO_NOT_SELL || acc.Risk_Rating__c == CON_CRM.ACCOUNT_RISK_RATING_6_DO_NOT_SELL || acc.Global_Risk_Rating__c == CON_CRM.ACCOUNT_RISK_RATING_6_DO_NOT_SELL))) {
                            acc.addError(System.Label.CRM_CL0035_Account_Risk_Rating_Update_Error_2);
                        }
                    }
                } else {
                    acc.Is_Super_Credit_Group_User__c = true;
                }
            }
        }
    }
    
    /**
    * This method is used to send the email alerts on credit Assessment.
    * @params List<Account> newList
    * @params Map<Id, Account> oldMap
    * @return  void
    */ 
    public static void creditAssessmentCheck(List<Account> newList, Map<Id, Account> oldMap){
        
        Set<String> accFieldSet = new Set<String> {'Id','Name','Parent.Category__c','Date_Risk_Expiry_Date__c','Global_Date_Risk_Assessed__c', 'AccountCountry__c','Name'};
        Set<String> oppFieldSet = new Set<String> {'Id','AccountId','Name','StageName','Line_of_Business__c','Amount_In_USD__c', 'Owner_Email__c','Amount','CSMS_Product__c','CSMS_Product_Amount__c',
            'GMI_Product_Count__c','GMI_Product_Amount__c','Q2_Product_Count__c','Q2_Product_Amount__c','RD_Product_Count__c',
            'RD_Product_Amount__c','RWAS_Product_Count__c','RWAS_Product_Amount__c','Commercial_Tech_Product_Count__c',
            'Tech_Analytic_Product_Amount__c'};
            
        Set<Id> accIdSet = new Set<Id>();
        Set<String> accCountrySet = new Set<String>();
        
        Map<Id, Account> accMap = new Map<Id, Account>();
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();        
        
        List<credit_control_Threshold__c> creditControlThresholdList = new List<credit_control_Threshold__c>();
        
        for(Account acc: newList){
            if((acc.Date_Risk_Expiry_Date__c < DATE.today() && oldMap.get(acc.Id).Date_Risk_Expiry_Date__c != acc.Date_Risk_Expiry_Date__c)  
                || (acc.Global_Date_Risk_Assessed__c == null && oldMap.get(acc.Id).Global_Date_Risk_Assessed__c != acc.Global_Date_Risk_Assessed__c)){
                accIdSet.add(acc.Id);                       
            }              
        }
        
        if(accIdSet.size() > 0){
            accMap = new SLT_Account().getAccountsWithAccountIdAndParentCategoryNotLargePharma(accIdSet, accFieldSet, CON_CRM.ACCOUNT_MDM_CATEGORY_LARGE_PHARMA);
            if(accMap.size() > 0){
                Set<String> stageNameSet = new Set<String>{CON_CRM.DEVELOPING_PROP_STAGE, CON_CRM.FINALIZING_DEAL_STAGE};
                oppMap = new SLT_Opportunity().getOpportunityByAccountIdANDStage(accMap.keySet(), oppFieldSet, stageNameSet);
                accIdSet = new Set<Id>();
                for(Opportunity opp : oppMap.values()){
                    accIdSet.add(opp.AccountId);
                    accCountrySet.add(accMap.get(opp.AccountId).AccountCountry__c);
                }
                if(accIdSet.size() > 0){
                    creditControlThresholdList = new SLT_Credit_Control_Threshold().getCreditControlThresholdByAccountId(accIdSet, accCountrySet);
                    if (creditControlThresholdList.size() > 0) {
                        SRV_CRM_Opportunity.sendCreditAssessmentCheckEmail(oppMap, creditControlThresholdList, accMap);    
                    }                    
                }
            }
        }
    }

    	/**********************************************************************************************
    * @Author:      Razia Khan
    * @Date:        11/03/2022
    * @Description: IQVIACBEX-1804:This method is responsible for sending the new and old field values for further
    *               implementation of sync logic between Salesforce and Unity using mulesoft as 
    *               middleware.
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
    ***********************************************************************************************/ 
    public static void setUnityFlagSyncMechanism(Map<Id, Account> newMap, Map<Id, Account> oldMap) {
        CNT_RFP_IntakeUnityFlagSync.processSyncLogic(CON_CBEx.ACCOUNT_OBJECT, newMap, oldMap);
    }

    /**
    * This method is used to run account territory assignment rule when country changed
    * @params List<Account> newList
    * @params Map<Id, Account> oldMap
    * @return  void
    */ 
    public static void updateAccountTerritory(List<Account> newList, Map<Id, Account> oldMap){
        Set<Id> accountIdSet = new Set<Id>();
        for(Account acc : newList) {
            if(acc.AccountCountry__c != oldMap.get(acc.Id).AccountCountry__c) {
                accountIdSet.add(acc.Id);
            }
        }
        if(accountIdSet.size() > 0){
            AccountTerritoryUpdate.updateAccountTerritory(accountIdSet);
        }
    }

    /**
    * This method is used to validate the account record with descartes approval
    * @params List<Account> newList
    * @params Map<Id, Account> oldMap
    * @return  void
    */
    public static void validateDescartesApproval(Map<Id, Account> newMap, Map<Id, Account> oldMap){
        Account newAccount = newMap.values()[0];
        Account oldAccount;
        if(Trigger.isUpdate) {
            oldAccount = oldMap.get(newAccount.Id);
        }
        Descartes_Approval_Setting__c dSetting = Descartes_Approval_Setting__c.getInstance();
        List<Approval.ProcessWorkitemRequest> requestList = new List<Approval.ProcessWorkitemRequest>();
        if(dSetting != null && dSetting.Account_Enabled__c && newAccount.RecordTypeId != CON_CRM.GLOBAL_CUSTOMER_ACCOUNT_RECORD_TYPE_ID) {
            if((Trigger.isInsert || (Trigger.isUpdate && descartesdps.DescartesDPSTriggerManager.ProceedWithScreening(newAccount.Id, oldMap, newMap))) && newAccount.RDCategorization__c != 'Site' ) {
                descartesdps.DescartesDPSTriggerManager.triggerOnDemandSearchDPS(newAccount.Id);
            }else if(Trigger.isUpdate && oldAccount.DPS_Force_Update__c	 != newAccount.DPS_Force_Update__c && newAccount.DPS_Force_Update__c){
                descartesdps.DescartesDPSTriggerManager.triggerOnDemandSearchDPS(newAccount.Id);
                newAccount.DPS_Force_Update__c = false;
            }
            if(Trigger.isUpdate) {
                if(newAccount.MDM_Validation_Status__c == 'Pending for Descartes' && newAccount.MDM_Validation_Status__c != oldAccount.MDM_Validation_Status__c) {
                    if(newAccount.DPS_Status__c == 'Not Screened') {
                        System.enqueueJob(new QUE_CRM_UnlockAccount(newAccount.Id));
                    } else if(newAccount.DPS_Status__c == 'Pending') {
                        newAccount.MDM_Validation_Status__c = 'Rejected by Descartes';
                    } else if(newAccount.DPS_Status__c == 'Cleared') {
                        newAccount.MDM_Validation_Status__c = 'Pending Validation';
                    }
                } 
                Set<Id> accountIdSet = new Set<Id>();
                for(Account acc : newMap.values()) {
                    if(oldMap.get(acc.Id).DPS_Status__c != acc.DPS_Status__c)
                        accountIdSet.add(acc.Id);
                }
                if(accountIdSet.size() > 0) {
                    List<ProcessInstanceWorkitem> workItemList = new SLT_ProcessInstanceWorkitem().getAllPendingWorkItems(accountIdSet);
                    Map<Id, Id> accountIdToWorkItemIdMap = new Map<Id, Id>();
                    for(ProcessInstanceWorkitem workItem : workItemList) {
                        accountIdToWorkItemIdMap.put(workItem.ProcessInstance.TargetObjectId, workItem.Id);
                    }
                    for(Id accountId : accountIdSet) {
                        Account newAcc = newMap.get(accountId);
                        if(newAcc.DPS_Status__c == 'Cleared') {
                            // Approve the Descartes approval step 
                            newAcc.Risk_Rating__c = NULL;
                            newAcc.MDM_Validation_Status__c = 'Unvalidated';
                            if(accountIdToWorkItemIdMap.containsKey(accountId)) {
                                newAcc.MDM_Validation_Status__c = 'Pending Validation';
                                Approval.ProcessWorkitemRequest itemRequest = new Approval.ProcessWorkitemRequest();
                                itemRequest.setAction('Approve');
                                itemRequest.setComments('Approved by Descartes');
                                itemRequest.setWorkitemId(accountIdToWorkItemIdMap.get(accountId));
                                requestList.add(itemRequest);
                                System.enqueueJob(new QUE_CRM_LockAccount(newAcc.Id));
                            }
                        } else if(newAcc.DPS_Status__c == 'Pending') {
                            // Reject the Descartes approval step
                            newAcc.Risk_Rating__c = CON_CRM.ACCOUNT_RISK_RATING_6_DO_NOT_SELL;
                            newAcc.MDM_Validation_Status__c = 'Rejected by Descartes';
                            if(accountIdToWorkItemIdMap.containsKey(accountId)) {
                                Approval.ProcessWorkitemRequest itemRequest = new Approval.ProcessWorkitemRequest();
                                itemRequest.setAction('Reject');
                                itemRequest.setComments('Rejected by Descartes');
                                itemRequest.setWorkitemId(accountIdToWorkItemIdMap.get(accountId));
                                requestList.add(itemRequest);
                            }
                        }
                    }
                }
            }
        } else {
            
        }
        if(requestList.size() > 0){
            List<Approval.ProcessResult> result1 = Approval.process(requestList);
        }
    }
    
    /**
     * method to update OpportunityShare record if AccountCountry__c or ParentId changed
     * @param List<Account> newList
     * @param Map<Id, Account> oldMap
     */
    public Static void updateOpportunitySharing(List<Account> newList, Map<Id, Account> oldMap){
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> parentAccountIdSet = new Set<Id>();
        for(Account acc: newList){
            // if Account Country or parent account change re calculate Opportunity Sharing
            if(acc.AccountCountry__c != oldMap.get(Acc.Id).AccountCountry__c ||acc.ParentId != oldMap.get(Acc.Id).ParentId){
                accountIdSet.add(acc.Id);
            }
            // if MDMID__c changes re-calculate Child Account's Opportunity(opp.Account_MDM_Parent_Customer_Code__c)
            if(acc.MDMID__c != oldMap.get(Acc.Id).MDMID__c){
                parentAccountIdSet.add(acc.Id);
            }
        }
        if(parentAccountIdSet.size() > 0){
            for(Account acc: new SLT_Account().getAccountsByParentAccount(parentAccountIdSet).values()){
                accountIdSet.add(acc.Id);
            }
        }
        if(accountIdSet.size() > 0){
            if(UTL_Validate.isFutureCallAllowed()){
                runOpportunitySharingFuture(accountIdSet);
            } else{
                runOpportunitySharing(accountIdSet);
            }
        }
    }
    
    /**
     * future method to update Opportunity to run apex Sharing
     * @param Set<Id> accountIdSet
     */
    @future
    public Static void runOpportunitySharingFuture(Set<Id> accountIdSet){
        runOpportunitySharing(accountIdSet);
    }
    
    /**
     * method to update Opportunity to run apex Sharing
     * @param Set<Id> accountIdSet
     */
    public Static void runOpportunitySharing(Set<Id> accountIdSet){
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new Schema.SObjectType[] { Opportunity.SobjectType } );
        Boolean toCommit = false;
        for(Opportunity opp: new SLT_Opportunity().getOppByAccountId(new Set<String>{'Id'}, accountIdSet)){
            opp.Run_Sharing__c = true;
            toCommit = true;
            uow.registerDirty(opp);
        }
        if(toCommit){
            uow.commitWork();
        }
    }

/**
    * This method is used to update the CSH Assets in CSH Assets field from Assets object
    * @params List<Account> newList
    * @params Map<Id, Account> oldMap
    * @return  void
    */
    public static void updateCSHAccountAssets(List<Account> newList, Map<Id, Account> oldMap){
        Set<Id> accIds = new Set<Id>();
        Map<Id,String> accAssetMap = new Map<Id,String>();
        List<String> aNames = null;
        for(Account a : newList){
            if(a.IsCustomerPortal){
                accIds.add(a.Id);
            }
        }
        if(!accIds.isEmpty()){
            CSM_Case_Details_Global_Setting__c m = CSM_Case_Details_Global_Setting__c.getValues('CSHMessageAssets');
            if(m != null && m.Other_Details__c != null){
                List<String> assetN = m.Other_Details__c.split(';');
                List<Asset> assets = new SLT_Asset().selectCSHByAccounts(accIds,assetN);
                for(Account a : newList){
                    if(a.IsCustomerPortal && accIds.contains(a.Id)){
                        aNames = new List<String>();
                        for(Asset ast: assets){
                            if(ast.AccountId == a.Id){
                                aNames.add(ast.Name);
                            }
                        }
                        if(!aNames.isEmpty()){
                            a.CSH_Assets__c = String.join(aNames, ',');
                        }
                    }
                }
            }
        }    
    }
}