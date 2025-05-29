public class DAOH_Contact {
   
   
    public static void checkUserContactRelationCSM(List<Contact> newList){
        Map<Id,User> userMap = new Map<Id,User>();
        Map<Id,Contact> contactMap = new Map<Id,Contact>();
        for (Contact c : newList) {
            if(c.AccessToAllCasesOfTheAccou__c == true) {
                contactMap.put(c.Id,c);
            }
        }
        if(contactMap.isEmpty() == false){
            for(User usr :  new SLT_User().selectByContactId(contactMap.keySet(), new Set<String>{CON_CSM.S_ID,CON_CSM.S_NAME,CON_CSM.S_CONTACTID_C})){
                userMap.put(usr.ContactId,usr);
            }
            for(Contact con : contactMap.values()){
                if(!userMap.containsKey(con.Id)){
                    con.AccessToAllCasesOfTheAccou__c = false;
                } 
            }
        }
    }
    /**
     * This method is used for add the permission set to the user based on AccessToAllCasesOfTheAccou__c field is true.
     * @params  newList List<Contact>,Map<Id,Contact> oldMap
     * @return  void
     */    
    public static void addPermissionSetAfterInsertCSM(List<Contact> newList){
        Boolean hasCustomPermission = FeatureManagement.checkPermission('CSM_Bypass_CSM_Validation_Rules');
        String[] sUsers = new List<String>();
        Set<Id> contactIdsSet = new Set<Id>();
        PermissionSet ps = null;
        for (Contact c : newList) {
            if(c.AccessToAllCasesOfTheAccou__c == true) {
                contactIdsSet.add(c.Id);
            }
        }
        
        if(contactIdsSet.isEmpty() == false){
            ps = Database.query('SELECT Id, Name FROM PermissionSet WHERE IsOwnedByProfile = False and Name=\''+CON_CSM.P_COMMUNITY_SUPER_USER+'\' Limit 1');
            
            for(User usr :  new SLT_User().selectByContactId(contactIdsSet, new Set<String>{CON_CSM.S_ID,CON_CSM.S_NAME,CON_CSM.S_CONTACTID_C})){
                sUsers.add(usr.Id);
            }
            
            if(sUsers.isEmpty() == false && ps != null){
                SRV_CSM_AssignPermissionSet.AssignPermissionSetToUsers(sUsers, ps.Id);
            }else if(hasCustomPermission == false){
                newList[0].adderror(label.CSM_CL0001_CONTACT_IS_NOT_ASSIGN_USER_MSG);
            }    
        }
        
    }
    /**
     * This method is used for add or delete the permission set to the user based on AccessToAllCasesOfTheAccou__c field.
     * @params  newList List<Contact>,Map<Id,Contact> oldMap
     * @return  void
     */
    public static void PermissionSetAfterUpdateCSM(List<Contact> newList,Map<Id,Contact> oldMap){
        Boolean hasCustomPermission = FeatureManagement.checkPermission('CSM_Bypass_CSM_Validation_Rules');
        String[] sUsers = new List<String>();
        String[] sDeleteUsers = new List<String>();
        Set<Id> contactIdsSet = new Set<Id>();
        Set<Id> deleteIdsSet = new Set<Id>();
        PermissionSetAssignment psa =null;
        List<PermissionSetAssignment> listPSAList = null;
        PermissionSet ps =null;
        for (Contact c : newList) {
            if(c.get(CON_CSM.S_ACCESS_TO_ALL_CASES_OF_ACCOUNT_C) != null && !c.get(CON_CSM.S_ACCESS_TO_ALL_CASES_OF_ACCOUNT_C).equals(oldMap.get(c.Id).get(CON_CSM.S_ACCESS_TO_ALL_CASES_OF_ACCOUNT_C))){
                if(c.AccessToAllCasesOfTheAccou__c == true) {
                    contactIdsSet.add(c.Id);
                }else if(c.AccessToAllCasesOfTheAccou__c == false) {
                    deleteIdsSet.add(c.Id);
                }    
            }
        }
        if(contactIdsSet.isEmpty() == false || deleteIdsSet.isEmpty() == false){
            ps = Database.query('SELECT Id, Name FROM PermissionSet WHERE IsOwnedByProfile = False and Name=\''+CON_CSM.P_COMMUNITY_SUPER_USER+'\' Limit 1');
        }
        
        if(contactIdsSet.isEmpty() == false  && ps!=null){
            for(User usr : new SLT_User().selectByContactId(contactIdsSet, new Set<String>{CON_CSM.S_ID,CON_CSM.S_NAME,CON_CSM.S_CONTACTID_C})){
                sUsers.add(usr.Id);
            }
            if(sUsers.isEmpty() == false){
                SRV_CSM_AssignPermissionSet.AssignPermissionSetToUsers(sUsers, ps.Id);
            }else if(hasCustomPermission == false){
                newList[0].adderror(label.CSM_CL0001_CONTACT_IS_NOT_ASSIGN_USER_MSG);
            }
        }
        if(deleteIdsSet.isEmpty() == false && ps!=null){
            for(User usr : new SLT_User().selectByContactId(deleteIdsSet, new Set<String>{CON_CSM.S_ID,CON_CSM.S_NAME,CON_CSM.S_CONTACTID_C})){
                sDeleteUsers.add(usr.Id);
            }
            if(sDeleteUsers.isEmpty() == false){
               SRV_CSM_AssignPermissionSet.DeletePermissionSetToUsers(sDeleteUsers, ps.Id); 
            }
        }
        
    }

    /**
    * This method is used for create a new Data Audit Trail when the new case record is created.
    * @params  newList List<Contact>
    * @return  void
    */
    public static void saveAuditLogAfterInsertContact(List<Contact> newList){
        CSM_QI_Data_Audit_Trail__c auditTrail = null;
        Map<ID,Schema.RecordTypeInfo> rt_Map  =  Contact.sObjectType.getDescribe().getRecordTypeInfosById();
        List<CSM_QI_Data_Audit_Trail__c> auditTrailList = new List<CSM_QI_Data_Audit_Trail__c>();
        for(Contact c : newList) {
            if(newList.size() > 0)
            {
                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_CREATED,Name = CON_CSM.S_CONTACT,Contact__c  =  c.Id);
                auditTrailList.add(auditTrail);
            }
            
        }
        
        try {
            if(auditTrailList != null && auditTrailList.size() > 0){
                insert auditTrailList;  
            }
        } catch (DmlException e) {
            System.debug('Failed due to : '+e);
        }
        
    }
    /**
    * This method is used for create a new Data Audit Trail when the case record fields are updated.
    * @params  newList List<Contact>,oldMap Map<Id, Contact> 
    * @return  void
    */
    public static void saveAuditLogAfterUpdateContactFields(List<Contact> newList, Map<Id, Contact> oldMap,List<FieldDefinition> fields) {
        
        if(fields != null && fields.size() > 0){
            
            CSM_QI_Data_Audit_Trail__c auditTrail = null;
            List<CSM_QI_Data_Audit_Trail__c> auditTrailList = new List<CSM_QI_Data_Audit_Trail__c>();
            Map<ID,Schema.RecordTypeInfo> rt_Map  =  Contact.sObjectType.getDescribe().getRecordTypeInfosById();
            EXT_CSM_CaseRelatedToObject contactRelatedTo = null;
            List<EXT_CSM_CaseRelatedToObject> contactRelatedToList = new List<EXT_CSM_CaseRelatedToObject>(); 
            
            for(Contact c : newList) {
                if(fields.size() > 0 ) 
                {
                    for( FieldDefinition fd: fields){
                        
                        if(String.isBlank(fd.ExtraTypeInfo) && ((fd.DataType.contains(CON_CSM.S_TEXT) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_STRING)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_PICKLIST) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_STRING)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_NUMBER) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_DOUBLE)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_URL) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_STRING)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_PHONE) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_STRING)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_EMAIL) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_STRING)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_CHECKBOX) && fd.ValueTypeId.equalsIgnoreCase(CON_CSM.S_BOOLEAN)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_FORMULA) && fd.ValueTypeId.equalsIgnoreCase(CON_CSM.S_TEXT)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_DATE) && fd.ValueTypeId.equalsIgnoreCase(CON_CSM.S_DATETIME)) || (fd.DataType.startsWithIgnoreCase(CON_CSM.S_DATE) && fd.ValueTypeId.equalsIgnoreCase(CON_CSM.S_DATE)))){
                            if(c.get(fd.QualifiedApiName) == null && oldMap.get(c.Id).get(fd.QualifiedApiName) != null){
                                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_DELETED,Name = fd.MasterLabel,Old_Value__c = String.valueOf(oldMap.get(c.Id).get(fd.QualifiedApiName)),New_Value__c = String.valueOf(c.get(fd.QualifiedApiName)),Contact__c =  c.Id);
                                auditTrailList.add(auditTrail);
                            }else if(c.get(fd.QualifiedApiName) != null && oldMap.get(c.Id).get(fd.QualifiedApiName) == null){
                                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_ADDED,Name = fd.MasterLabel,Old_Value__c = String.valueOf(oldMap.get(c.Id).get(fd.QualifiedApiName)),New_Value__c = String.valueOf(c.get(fd.QualifiedApiName)),Contact__c =  c.Id);
                                auditTrailList.add(auditTrail);
                            }else if(c.get(fd.QualifiedApiName) != null && !c.get(fd.QualifiedApiName).equals(oldMap.get(c.Id).get(fd.QualifiedApiName))){
                                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_CHANGED,Name = fd.MasterLabel,Old_Value__c = String.valueOf(oldMap.get(c.Id).get(fd.QualifiedApiName)),New_Value__c = String.valueOf(c.get(fd.QualifiedApiName)),Contact__c =  c.Id);
                                auditTrailList.add(auditTrail);
                            }
                        }else if(String.isBlank(fd.ExtraTypeInfo) && fd.DataType.contains(CON_CSM.S_LOOKUP) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_ID)){
                            if(c.get(fd.QualifiedApiName) == null && oldMap.get(c.Id).get(fd.QualifiedApiName) != null){
                                contactRelatedTo = new EXT_CSM_CaseRelatedToObject(CON_CSM.S_DELETED,fd.RelationshipName,CON_CSM.S_CONTACT,fd.MasterLabel,(Id)oldMap.get(c.Id).get(fd.QualifiedApiName),null,c.Id);
                                contactRelatedToList.add(contactRelatedTo);
                            }else if(c.get(fd.QualifiedApiName) != null && oldMap.get(c.Id).get(fd.QualifiedApiName) == null){
                                contactRelatedTo = new EXT_CSM_CaseRelatedToObject(CON_CSM.S_ADDED,fd.RelationshipName,CON_CSM.S_CONTACT,fd.MasterLabel,null,(Id)c.get(fd.QualifiedApiName),c.Id);
                                contactRelatedToList.add(contactRelatedTo);    
                            }else if(c.get(fd.QualifiedApiName) != null && oldMap.get(c.Id).get(fd.QualifiedApiName) != null && !c.get(fd.QualifiedApiName).equals(oldMap.get(c.Id).get(fd.QualifiedApiName))){
                                contactRelatedTo = new EXT_CSM_CaseRelatedToObject(CON_CSM.S_CHANGED,fd.RelationshipName,CON_CSM.S_CONTACT,fd.MasterLabel,(Id)oldMap.get(c.Id).get(fd.QualifiedApiName),(Id)c.get(fd.QualifiedApiName),c.Id);
                                contactRelatedToList.add(contactRelatedTo);
                            }
                        }else if(String.isNotBlank(fd.ExtraTypeInfo) && fd.DataType.contains(CON_CSM.S_TEXT) && fd.ValueTypeId.startsWithIgnoreCase(CON_CSM.S_STRING)){
                            if(c.get(fd.QualifiedApiName) != null && !c.get(fd.QualifiedApiName).equals(oldMap.get(c.Id).get(fd.QualifiedApiName))){
                                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_EDITED,Name = fd.MasterLabel,Old_Text_Value__c = String.valueOf(oldMap.get(c.Id).get(fd.QualifiedApiName)),Contact__c  =  c.Id);
                                auditTrailList.add(auditTrail);
                            }
                        }else if(String.isBlank(fd.ExtraTypeInfo) && fd.QualifiedApiName.equals(CON_CSM.s_mailingAddress) && fd.DataType.contains(CON_CSM.s_address)){
                            if(c.MailingStreet == null && oldMap.get(c.Id).MailingStreet != null){
                                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_EDITED,Name = CON_CSM.S_C_MSTREET,Contact__c  =  c.Id);
                                auditTrailList.add(auditTrail);
                            }else if(c.MailingStreet != null && oldMap.get(c.Id).MailingStreet == null){
                                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_EDITED,Name = CON_CSM.S_C_MSTREET,Contact__c  =  c.Id);
                                auditTrailList.add(auditTrail);
                            }else if(c.MailingStreet != null && oldMap.get(c.Id).MailingStreet != null && !c.MailingStreet.equalsIgnoreCase(oldMap.get(c.Id).MailingStreet)){
                                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_EDITED,Name = CON_CSM.S_C_MSTREET,Contact__c  =  c.Id);
                                auditTrailList.add(auditTrail);    
                            }
                            if(c.MailingCity == null && oldMap.get(c.Id).MailingCity != null){
                                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_DELETED,Name = CON_CSM.S_C_MCITY,Old_Value__c = oldMap.get(c.Id).MailingCity,New_Value__c = c.MailingCity,Contact__c  =  c.Id);
                                auditTrailList.add(auditTrail);
                            }else if(c.MailingCity != null && oldMap.get(c.Id).MailingCity == null){
                                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_ADDED,Name = CON_CSM.S_C_MCITY,Old_Value__c = oldMap.get(c.Id).MailingCity,New_Value__c = c.MailingCity,Contact__c  =  c.Id);
                                auditTrailList.add(auditTrail);
                            }else if(c.MailingCity != null && oldMap.get(c.Id).MailingCity != null && !c.MailingCity.equalsIgnoreCase(oldMap.get(c.Id).MailingCity)){
                                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_CHANGED,Name = CON_CSM.S_C_MCITY,Old_Value__c = oldMap.get(c.Id).MailingCity,New_Value__c = c.MailingCity,Contact__c  =  c.Id);
                                auditTrailList.add(auditTrail);
                            }
                            
                            if(c.MailingState == null && oldMap.get(c.Id).MailingState != null){
                                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_DELETED,Name = CON_CSM.S_C_MSTATE,Old_Value__c = oldMap.get(c.Id).MailingState,New_Value__c = c.MailingState,Contact__c  =  c.Id);
                                auditTrailList.add(auditTrail);
                            }else if(c.MailingState != null && oldMap.get(c.Id).MailingState == null){
                                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_ADDED,Name = CON_CSM.S_C_MSTATE,Old_Value__c = oldMap.get(c.Id).MailingState,New_Value__c = c.MailingState,Contact__c  =  c.Id);
                                auditTrailList.add(auditTrail);
                            }else if(c.MailingState != null && oldMap.get(c.Id).MailingState != null && !c.MailingState.equalsIgnoreCase(oldMap.get(c.Id).MailingState)){
                                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_CHANGED,Name = CON_CSM.S_C_MSTATE,Old_Value__c = oldMap.get(c.Id).MailingState,New_Value__c = c.MailingState,Contact__c  =  c.Id);
                                auditTrailList.add(auditTrail); 
                            }
                            if(c.MailingPostalCode == null && oldMap.get(c.Id).MailingPostalCode != null){
                                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_DELETED,Name = CON_CSM.S_C_MPOSTALCODE,Old_Value__c = oldMap.get(c.Id).MailingPostalCode,New_Value__c = c.MailingPostalCode,Contact__c  =  c.Id);
                                auditTrailList.add(auditTrail);
                            }else if(c.MailingPostalCode != null && oldMap.get(c.Id).MailingPostalCode == null){
                                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_ADDED,Name = CON_CSM.S_C_MPOSTALCODE,Old_Value__c = oldMap.get(c.Id).MailingPostalCode,New_Value__c = c.MailingPostalCode,Contact__c  =  c.Id);
                                auditTrailList.add(auditTrail);
                            }else if(c.MailingPostalCode != null && oldMap.get(c.Id).MailingPostalCode != null && !c.MailingPostalCode.equalsIgnoreCase(oldMap.get(c.Id).MailingPostalCode)){
                                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_CHANGED,Name = CON_CSM.S_C_MPOSTALCODE,Old_Value__c = oldMap.get(c.Id).MailingPostalCode,New_Value__c = c.MailingPostalCode,Contact__c  =  c.Id);
                                auditTrailList.add(auditTrail);
                            }
                            if(c.MailingCountry == null && oldMap.get(c.Id).MailingCountry != null){
                                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_DELETED,Name = CON_CSM.S_C_MCOUNTRY,Old_Value__c = oldMap.get(c.Id).MailingCountry,New_Value__c = c.MailingCountry,Contact__c  =  c.Id);
                                auditTrailList.add(auditTrail);
                            }else if(c.MailingCountry != null && oldMap.get(c.Id).MailingCountry == null){
                                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_ADDED,Name = CON_CSM.S_C_MCOUNTRY,Old_Value__c = oldMap.get(c.Id).MailingCountry,New_Value__c = c.MailingCountry,Contact__c  =  c.Id);
                                auditTrailList.add(auditTrail);
                            }else if(c.MailingCountry != null && oldMap.get(c.Id).MailingCountry != null && !c.MailingCountry.equalsIgnoreCase(oldMap.get(c.Id).MailingCountry)){
                                auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_CHANGED,Name = CON_CSM.S_C_MCOUNTRY,Old_Value__c = oldMap.get(c.Id).MailingCountry,New_Value__c = c.MailingCountry,Contact__c  =  c.Id);
                                auditTrailList.add(auditTrail);
                            }
                            
                            
                            
                        }
                        
                    }
                }
            }
            
            if(contactRelatedToList.size() > 0)
            {
                Set<Id> accSet = new Set<Id>(),cntSet = new Set<Id>(),pconSet = new Set<Id>(),usrSet = new Set<Id>(),bHoursSet = new Set<Id>();
                
                for(EXT_CSM_CaseRelatedToObject obj:contactRelatedToList){
                    if(CON_CSM.S_ACCOUNT.equals(obj.objRelName)){
                        accSet.add(obj.oldId);
                        accSet.add(obj.newId);
                    }else if(CON_CSM.S_CONTACT.equals(obj.objRelName)){
                        cntSet.add(obj.oldId);
                        cntSet.add(obj.newId);
                    }else if(CON_CSM.S_USER.equals(obj.objRelName)){
                        usrSet.add(obj.oldId);
                        usrSet.add(obj.newId);
                    }else if(CON_CSM.S_BHOUR.equals(obj.objRelName)){
                        bHoursSet.add(obj.oldId);
                        bHoursSet.add(obj.newId);
                    }
                }
                Set<String> fieldSet  =  new Set<String> {CON_CSM.s_id, CON_CSM.s_name};
                Map<Id, Account> accountMap  = null;
                Map<Id, Contact> contactMap  = null;
                Map<Id, User> usrMap = null;
                Map<Id, BusinessHours> bHoursMap = null;
                if(accSet.size() > 0) accountMap  =  new SLT_Account().selectByAccountId(accSet, fieldSet);
                if(cntSet.size() > 0) contactMap  =  new SLT_Contact().selectByContactId(cntSet, fieldSet);
                if(usrSet.size() > 0) usrMap  =  new SLT_User().selectByUserId(usrSet, fieldSet);
                if(bHoursSet.size() > 0) bHoursMap  =  new SLT_BusinessHours().selectByBusinessHoursId(bHoursSet, fieldSet);
                for(EXT_CSM_CaseRelatedToObject obj : contactRelatedToList){
                    
                    if(accountMap != null && accountMap.size() > 0 && CON_CSM.S_ACCOUNT.equals(obj.objRelName)){
                        auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = obj.action,Name = obj.fieldName,Contact__c  =  obj.objectId,Old_Value__c = accountMap.containsKey(obj.oldId)?accountMap.get(obj.oldId).Name :'',New_Value__c = accountMap.containsKey(obj.newId)?accountMap.get(obj.newId).Name:'');
                        auditTrailList.add(auditTrail);
                    }else if(contactMap != null && contactMap.size() > 0 && CON_CSM.S_CONTACT.equals(obj.objRelName)){
                        auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = obj.action,Name = obj.fieldName,Contact__c  =  obj.objectId,Old_Value__c = contactMap.containsKey(obj.oldId)?contactMap.get(obj.oldId).Name :'',New_Value__c = contactMap.containsKey(obj.newId)?contactMap.get(obj.newId).Name:'');
                        auditTrailList.add(auditTrail);
                    }else if(usrMap != null && usrMap.size() > 0 && CON_CSM.S_USER.equals(obj.objRelName)){
                        auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = obj.action,Name = obj.fieldName,Contact__c  =  obj.objectId,Old_Value__c = usrMap.containsKey(obj.oldId)?usrMap.get(obj.oldId).Name :'',New_Value__c = usrMap.containsKey(obj.newId)?usrMap.get(obj.newId).Name:''); 
                        auditTrailList.add(auditTrail);
                    }else if(bHoursMap != null && bHoursMap.size() > 0 && CON_CSM.S_BHOUR.equals(obj.objRelName)){
                        auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = obj.action,Name = obj.fieldName,Contact__c  =  obj.objectId,Old_Value__c = bHoursMap.containsKey(obj.oldId)?bHoursMap.get(obj.oldId).Name :'',New_Value__c = bHoursMap.containsKey(obj.newId)?bHoursMap.get(obj.newId).Name:''); 
                        auditTrailList.add(auditTrail);
                    }
                    
                }
            }
            
            
            try {
                if(auditTrailList != null && auditTrailList.size() > 0){
                    insert auditTrailList;
                }
                
            } catch (DmlException e) {
                System.debug('Failed due to : '+e);
            }
        }
        
    }
    
    /**
     * This method is used to set DispositionDate.
     * @params  newList List<Contact>
     * @params  oldMap Map<Id, Contact>
     * @return  void
     */
    public static void setDispositionDate(List<Contact> newList, Map<Id, Contact> oldMap) {
        for(Contact con : newList){
            if(con.Disposition__c != null && (Trigger.isInsert || oldMap.get(con.id).Disposition__c != con.Disposition__c)) {
                con.Disposition_Date__c = Date.today();
            }
        }
    }
    
    /**
     * This method is used to set null values for various fields.
     * @params  newList List<Contact>
     * @return  void
     */
    public static void setFieldNullValues(List<Contact> newList) {
        Set<String> nurtureDetailFieldValuesSet = new Set<String> {
            CON_CRM.THREE_MONTHS,
            CON_CRM.SIX_MONTHS,
            CON_CRM.NINE_MONTHS,
            CON_CRM.TWELVE_MONTHS,
            CON_CRM.FIFTEEN_MONTHS,
            CON_CRM.EIGHTEEN_MONTHS
        };
        
        for(Contact con : newList){
            if(con.Disposition__c == CON_CRM.MARKETING_TO_NURTURE && nurtureDetailFieldValuesSet.contains(con.Nurture_Detail__c)){
                con.Disposition__c = null;
                con.Disposition_Date__c = null;
                con.Nurture_Area__c = null;
                con.Nurture_Detail__c = null;
                con.Nurture_Detail_Other__c = null;
            }
        }
    }
    
    /**
     * This method is used to reset LI and LQ AccountId if account is updated.
     * @params  Map<Id, Contact> newMap
     * @params  Map<Id, Contact> oldMap
     * @return  void
     */
    public static void resetLegacyAccountId(Map<Id, Contact> newMap, Map<Id, Contact> oldMap) {    
        for(Contact cnt : newMap.values()) {
            if (cnt.AccountId != oldMap.get(cnt.Id).AccountId) {
                cnt.LI_Account_Id__c = null;
                cnt.LQ_Account_Id__c = null;
            }
        }
    }
    
    /**
     * This method is used to set Contact value.
     * @params  newList List<Contact>
     * @params  oldMap Map<Id, Contact>
     * @return  void
     */
    public static void setContactFields(List<Contact> newList, Map<Id, Contact> oldMap){
        List<Schema.PicklistEntry> locationPicklistValues = Contact.Location__c.getDescribe().getPicklistValues();
        Set<String> activeValueSet = new Set<String>();
        for(Schema.PicklistEntry pc : locationPicklistValues){
            if(pc.isActive()){
                activeValueSet.add(pc.getValue());
            }
        }
        for(Contact con : newList){
            if(con.recordTypeId == CON_CRM.CONTACT_RECORD_TYPE_IQVIA_USER_CONTACT){
                if( con.Location_Code_text__c != null && activeValueSet.contains(con.Location_Code_text__c)){
                    con.Location__c = con.Location_Code_text__c;
                }else{
                    con.Location__c = null;
                }
            }
        }
    }
    /**
     * This method is used to set previous lead score when lead score is updated.
     * @params  newList List<Contact>
     * @params  oldMap Map<Id, Contact>
     * @return  void
     */
    public static void setPreviousLeadScore(List<Contact> newList, Map<Id, Contact> oldMap) {
        for(Contact con : newList){
            if(con.Lead_Score__c != oldMap.get(con.id).Lead_Score__c) {
                con.Previous_Lead_Score__c = oldMap.get(con.id).Lead_Score__c;
            }
        }
    }
    
    /**
     * This method is used to update fields pse_Is_Resource_c,pse_Is_Resource_Active_c on Contact Object.
     * @params  newList List<Contact>
     * @params  oldMap Map<Id, Contact>
     * @return  void
     */
    public static void setPseResource(List<Contact> newList) {
        Org_Default_Setting__c orgdefaultsetting = Org_Default_Setting__c.getInstance();
        for(Contact con : newList) {
            if(con.pse__Last_Date__c < System.today() && con.Salesforce_User__c == NULL && con.AccountId == orgdefaultsetting.Default_Account_Id__c && con.pse__Is_Resource__c && con.pse__Is_Resource_Active__c) {
                con.pse__Is_Resource__c = false;
                con.pse__Is_Resource_Active__c = false;     
            }
        }
    }
    
    /**
    * This method is used to update user when a contact is updated
    * @params  newList List<Contact>,oldMap Map<Id, Contact> 
    * @return  void
    */
    public static void updateUserForContacts(List<Contact> newList, Map<Id, Contact> oldMap) {
        Set<Id> userIdSet = new Set<Id>();
        for(Contact con : newList){
            if(con.Salesforce_User__c != null) {
                userIdSet.add(con.Salesforce_User__c);
            }
        }
        if(userIdSet.size() > 0) {
            Set<String> fieldSet = new Set<String>();
            Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Map <String, Schema.SObjectField> fieldMap = schemaMap.get(CON_CRM.USER_CONTACT_SYNC).getDescribe().fields.getMap();
            SObject userContactSync = User_Contact_Sync__c.getInstance();
            for(Schema.SObjectField sfield : fieldMap.Values()) {
                Schema.describefieldresult dfield = sfield.getDescribe();
                if(dfield.getName().contains(CON_CRM.UNDERSCORE_C)) {
                    String synchField = String.valueOf(userContactSync.get(dfield.getName()));
                    if(synchField != null) {
                        fieldSet.add(synchField.split(CON_CRM.COMMA)[0]);
                    }
                }
            }
            Map<Id, User> userMap = new SLT_User().selectByUserId(userIdSet, fieldSet);
            
            SObject clonedNewContact;
            SObject clonedOldContact;
            SObject updateUser;
            Boolean isUserUpdated;
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                new Schema.SObjectType[] {
                    User.SobjectType
                }
            );
            Boolean toCommit = false;
            
            for(Contact con : newList) {
                if(userMap.containsKey(con.Salesforce_User__c)) {
                    isUserUpdated = false;
                    clonedNewContact = con.clone(false, true, false, false);
                    clonedOldContact = oldMap.get(con.id).clone(false, true, false, false);
                    updateUser = userMap.get(con.Salesforce_User__c).clone(true, true, false, false);
                    for(Schema.SObjectField sfield : fieldMap.Values()) {
                        Schema.describefieldresult dfield = sfield.getDescribe();
                        if(dfield.getName().contains(CON_CRM.UNDERSCORE_C)) {
                            String synchField = String.valueOf(userContactSync.get(dfield.getName()));
                            if(synchField != null) {
                                if((synchField.split(CON_CRM.COMMA)[2].equalsIgnoreCase(CON_CRM.BOTH) || synchField.split(CON_CRM.COMMA)[2].equalsIgnoreCase(CON_CRM.CONTACT_TO_USER)) && clonedNewContact.get(synchField.split(CON_CRM.COMMA)[1]) != clonedOldContact.get(synchField.split(CON_CRM.COMMA)[1])) {
                                    if(dfield.getName() == CON_CRM.RECORD_ACTIVE) {
                                        Boolean isActive = Boolean.valueOf(clonedNewContact.get(synchField.split(CON_CRM.COMMA)[1]));
                                        updateUser.put(synchField.split(CON_CRM.COMMA)[0], !isActive);
                                    } else {
                                        updateUser.put(synchField.split(CON_CRM.COMMA)[0], clonedNewContact.get(synchField.split(CON_CRM.COMMA)[1]));
                                    }
                                    isUserUpdated = true;
                                }
                            }
                        }
                    }
                    if(isUserUpdated) {
                        uow.registerDirty((User)updateUser);
                        toCommit = true;
                    }
                }
            }
            if(toCommit){
                CON_CRM.preventContactUpdate = true;
                uow.commitWork();
                CON_CRM.preventContactUpdate = false;
            }
        }
    }
    
    /**
     * This method is used to validate merge process of internal contacts
     * @params  newList List<Contact>
     * @return  void
     */
    public static void validateInternalContactsMerge(List<Contact> newList) {
        Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
        if(!mulesoftSetting.Ignore_Validation_Rules__c) {
            for(Contact con : newList) {
                if(con.RecordTypeId == CON_CRM.IQVIA_USER_CONTACT_RECORD_TYPE_ID && (con.Salesforce_User__c == null || con.QI_User_Id__c == null)) {
                    //con.addError(System.Label.CRM_CL0028_CONTACT_MERGE_ERROR);
                }
            }
        }
    }
    
    /**
     * This method is used to validate deletion of contacts based on the Record Type
     * @params  deleteList List<Contact>
     * @return  void
     */
    public static void validateDeletionOnRecordType(List<Contact> deleteList) {
        User_Permissions__c userPermissionSetting = User_Permissions__c.getInstance();
        if(userPermissionSetting != null && !userPermissionSetting.Allow_Internal_Contact_Deletion__c) {
            for(Contact con : deleteList) {
                if(con.RecordTypeId == CON_CRM.IQVIA_USER_CONTACT_RECORD_TYPE_ID) {
                    con.addError(System.Label.CRM_CL0027_CONTACT_DELETION_ERROR);
                }
            }
        }
    }
    
    /**
     * This method is used check Phone and Mobile Validation.
     * @params  newList List<Contact>
     * @params  oldMap Map<Id, Contact>
     * @return  void
     */
    public static void checkPhoneMobileValidation(List<Contact> newList) {
        String validation_msg;
        Pattern phonePattern = Pattern.compile('\\+[0-9]{7,15}'); 
        Boolean hasCustomPermission = FeatureManagement.checkPermission('CSM_Bypass_CSM_Validation_Rules');
        for(Contact con : newList){
            String phoneno = con.Phone;
            String mobileno = con.MobilePhone;
            
            if(con.Phone != null && phoneno.length() > 6 && phoneno.length() < 16 && hasCustomPermission == false){
                Matcher numericMatcher = phonePattern.matcher(phoneno);
                if(numericMatcher.matches()){
                    validation_msg = 'Phone OK -';
                }else{
                    validation_msg = 'Phone KO -';
                }
            }else{
                validation_msg = 'Phone KO -'; 
            }
            
            if(con.MobilePhone != null && mobileno.length() > 6 && mobileno.length() < 16 && hasCustomPermission == false){
                Matcher numericMatcher = phonePattern.matcher(mobileno);
                if(numericMatcher.matches()){
                    validation_msg += ' Mobile OK';
                }else{
                    validation_msg += ' Mobile KO';
                }
            }else{
                validation_msg += ' Mobile KO';
            }
            con.Phone_Mobile_Validation__c = validation_msg;
        }
    }

    public static void preventUpdateContactAccWithActiveUser(List<Contact> newList, Map<Id, Contact> oldMap){
        if(UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c || UTL_TPA.tpaFunctionalitySetting.Is_Contact_s_Account_Change_Allowed__c){
            return;
        }
        
        Set<Id> contactsWithAccChange = new Set<Id>();
        for(Contact con: newList){
            if(con.AccountId != oldMap.get(con.Id).AccountId){
                contactsWithAccChange.add(con.Id);
            }
        }

        Map<Id, User> activeUsrWithContact = new Map<Id, User>();
        if(!contactsWithAccChange.isEmpty() && UTL_TPA.tpaSetting != null && UTL_TPA.tpaSetting.New_CCP_Profile_Ids__c != null){
            for(User usr: [SELECT Id, ContactId, UserName FROM User where ContactId IN :contactsWithAccChange AND ProfileId IN :UTL_TPA.tpaSetting.New_CCP_Profile_Ids__c.split(';') AND IsActive = true AND IsPortalEnabled = true]){
                if(!activeUsrWithContact.containsKey(usr.Id)){
                    activeUsrWithContact.put(usr.ContactId, usr);
                }
            }

            for (Contact con: newList) {
                if (activeUsrWithContact.get(con.Id) != null) {
                    con.addError('Can\'t change Account of Contact as it is associated with active user with UserName: ' + activeUsrWithContact.get(con.Id).UserName);
                }
            }
        }
    }
    /*
    * Feature- 6259
    Employee number validation
    */
    public static void iqviaInternalContactValidations(List<Contact> newList, Map<Id, Contact> oldMap){
        List<Profile> profileList = new SLT_Profile().selectById(new Set<Id>{userinfo.getProfileId()});
        String currentProfile = '';
        if(profileList.size() > 0){
            if(profileList[0].Name != null){
                currentProfile = profileList[0].Name;
            }
        }
        Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
        for (Contact con: newList) {
            if(Trigger.isUpdate && currentProfile != '' && !currentProfile.contains(CON_CRM.SYS_ADMIN) && !mulesoftSetting.Ignore_Validation_Rules__c && con.RecordTypeId != CON_CRM.IQVIA_USER_CONTACT_RECORD_TYPE_ID && oldMap.get(con.Id).RecordTypeId == CON_CRM.IQVIA_USER_CONTACT_RECORD_TYPE_ID){
                con.addError(CON_CRM.DO_NOT_ALLOW_RECORDTYPE_CHANGE_IQVIA_INTERNAL_CON);
            }
            if (con.RecordTypeId == CON_CRM.IQVIA_USER_CONTACT_RECORD_TYPE_ID  && !mulesoftSetting.Ignore_Validation_Rules__c) {
                if(con.Salesforce_User__c == null){
                    if(String.isBlank(con.EmployeeNumber__c) || !(con.EmployeeNumber__c).isNumeric()){
                        con.addError(CON_CRM.IQVIA_INTERNAL_CONTACT_VALID_EMP_ERROR);
                    }
                }else if(con.Salesforce_User__c != null && (!String.isBlank(con.EmployeeNumber__c) && !(con.EmployeeNumber__c).isNumeric())){
                    con.addError(CON_CRM.IQVIA_INTERNAL_CONTACT_VALID_EMP_ERROR);
                }
            }else if(con.Create_Chatter_user__c && !mulesoftSetting.Ignore_Validation_Rules__c){
                con.addError(CON_CRM.CHATTER_USER_CAN_CREATE_BY_IQVIA_INTERNAL_CON_ERROR);
            }
        }
    }
    
    /*
    * Feature- 6259
    *Create user from contact if create chatter is true
    */
    public static void createChatterUsers(List<Contact> newList, Map<Id, Contact> oldMap){
        CNT_CRM_ContactToUser.checkValidEmployeeNumber(newList,oldMap);
    }
    
    
    public static void disablePortalAccess(List<Contact> newList, Map<Id, Contact> oldMap){
        Set<Id> contactId =  new Set<Id>();
        Boolean roleChange = false,activeUser = false, isMailingCountry = false;
        for(Contact con : newList)
        {
            if(con.Salesforce_Customer_User__c != null){
                if(con.Inactive__c != oldMap.get(con.id).Inactive__c)
                {
                    contactId.add(con.Id);
                    activeUser = true;
                }
                if(con.Portal_Role__c != oldMap.get(con.Id).Portal_Role__c)
                {
                    contactId.add(con.Id);
                    roleChange = true;
                }
                if((oldMap != null && oldMap.get(con.id).MailingCountry != con.MailingCountry)){
                    contactId.add(con.Id);
                    isMailingCountry = true;
                }    
            }
            
        }
        
        try{
            if(!System.isBatch() && !System.isFuture() && contactId.size()>0){
                deactivatePortalUser(contactId,roleChange,activeUser,isMailingCountry);
            }
        }
        catch(Exception e){
            e.getMessage();
        }
    }
    
    @future
    private static void deactivatePortalUser(Set<Id> contactId, Boolean roleChange, Boolean activeUser,Boolean isMailingCountry){
        CON_PEP.runFutureMethod = false;
        Set<String> profileNames = new Set<String>{CON_PEP.S_P_PEP_COMMUNITY, CON_PEP.S_P_CSM_COMMUNITY,CON_CSM.S_P_TPA_COMMUNITY,CON_CSM.S_P_TPA_COMM_PRO,CON_CSM.S_P_TPA_COMM_VENDOR,CON_CSM.S_P_TPA_COMM_US_PRO};
        List<User> userList = new SLT_User().getUserByProfileNames(contactId, profileNames);
        Set<Id> accId = new Set<Id>();
        String currentUserProfile = null;
        List<User> portUserList = new List<User>();
        for(User us : userList)
        {
            if(us.AccountId != null){
                accId.add(us.AccountId);
                portUserList.add(us);
            }else if(us.AccountId == null){
                currentUserProfile = us.Profile.Name;
            }
        }
        

        if(portUserList.size() > 0){
            
            Map<Id,String> consultantRole = new Map<Id,String>();
            Map<Id,String> managerRole = new Map<Id,String>();
            Map<String,Id> roleRole = new Map<String,Id>();
            if(roleChange){
                List<Account> accList = new SLT_Account().selectById(accId);
                if(accList != null && !accList.isEmpty()){
                    for(Account a : accList){
                        consultantRole.put(a.Id , a.Name + ' Partner User');
                        managerRole.put(a.Id , a.Name + ' Partner Manager');
                    }
                    List<String> roles = new List<String>(consultantRole.values());
                    roles.addAll(managerRole.values());
                    List<UserRole> roleList = new SLT_UserRole().getUserRolesByName(roles);
                    for(UserRole ur : roleList){
                        roleRole.put(ur.Name, ur.Id);
                    }
                }    
            }
            

            for(User us : portUserList)
            {
                if(activeUser && us.ContactId != null){
                    if(us.Contact.Inactive__c)
                    {
                        us.IsActive = false;
                    }else{
                        us.IsActive = true;
                    }
                }
                if(roleChange && us.Profile.Name == CON_PEP.S_P_PEP_COMMUNITY && roleRole != null && managerRole.containsKey(us.AccountId) && consultantRole.containsKey(us.AccountId)){
                    if(roleRole.containsKey(managerRole.get(us.AccountId)) && us.UserRole.Name == consultantRole.get(us.AccountId)){
                        us.UserRoleId = roleRole.get(managerRole.get(us.AccountId));
                    }else if(roleRole.containsKey(consultantRole.get(us.AccountId))){
                        us.UserRoleId = roleRole.get(consultantRole.get(us.AccountId));
                    }
                }
                if(isMailingCountry && us.Profile.Name == CON_PEP.S_P_PEP_COMMUNITY && us.Contact.MailingCountry != null){
                    us.Country = us.Contact.MailingCountry;
                }
            }   
            update portUserList;
        }
    }
    
    public static void updateorValidatePortalUserFieldsContact(List<Contact> newList, Map<Id, Contact> oldMap){
        Set<Id> portUsrIds = new Set<Id>();
        Id rtIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contact').getRecordTypeId();
        for(Contact con : newList){
            if(con.Salesforce_Customer_User__c != null && rtIdContact == con.RecordTypeId && con.Inactive__c != oldMap.get(con.id).Inactive__c){
                portUsrIds.add(con.Salesforce_Customer_User__c);
            }
        }
        if(!portUsrIds.isEmpty()){
            Boolean hasCustomPermission = FeatureManagement.checkPermission('CSM_Bypass_CSM_Validation_Rules');
            Date lstLoginDate = System.today().addMonths(-6);
            Set<String> profileNames = new Set<String>{CON_PEP.S_P_PEP_COMMUNITY, CON_PEP.S_P_CSM_COMMUNITY,CON_CSM.S_P_TPA_COMMUNITY,CON_CSM.S_P_TPA_COMM_PRO,CON_CSM.S_P_TPA_COMM_VENDOR,CON_CSM.S_P_TPA_COMM_US_PRO};
            Map<Id, User> userMap = new SLT_User().getUserByIdProfileNames(portUsrIds,profileNames);
            for(Contact con : newList){
                if(con.Salesforce_Customer_User__c != null && userMap != null && userMap.containsKey(con.Salesforce_Customer_User__c)){
                    if(userMap.get(con.Salesforce_Customer_User__c).Profile.Name == CON_PEP.S_P_PEP_COMMUNITY){
                        if(con.Inactive__c == false){
                            con.PRM_User__c = CON_PEP.S_Active;
                        }else{
                            con.PRM_User__c = CON_PEP.S_InActive;
                        }    
                    }else{
                        if(userMap.get(con.Salesforce_Customer_User__c).lastlogindate >= lstLoginDate && hasCustomPermission == false && con.Inactive__c){
                            con.Inactive__c = false;
                            con.addError('Community User Can Not Be Deactivated as User Logged in Within 6 Months');
                        }
                        if(con.Inactive__c == false){
                            con.CSH_User__c = CON_CSM.S_YES;
                        }else{
                            con.CSH_User__c = CON_CSM.S_INACTIVE;
                        }
                    }
                    
                }
            }
        }
        
    }
	
	public static void updateInvalidEmailAndHardBouncebackDate(List<Contact> newList, Map<Id, Contact> oldMap){        
        for(Contact con : newList){
            if(con.Email != oldMap.get(con.id).Email && con.Email != null){
                con.Invalid_Email_Address__c = false;
                con.Hard_Bounceback_Date__c = null;
                con.Email_Status__c = CON_CRM.Email_Status_Pending;
            }
        }
    }
    
    public static void CopyAccountAddressToMailingAddress(List<Contact> newList, Map<Id, Contact> oldMap){
        Id CONTACT_RECORD_TYPE_ID = CON_CRM.CONTACT_RECORD_TYPE_ID;
        Set<Id> accountAddressId = new Set<Id>();
        Set<Id> accountIdSet = new Set<Id>();
        Map<Id,Address__c> accountAddressMap = new Map<Id,Address__c>();
        Map<Id,Account> accountMap = new Map<Id,Account>();
        /*CSM-2514: check the contact account RDCategorization__c field as site then update mailing country from account country*/
        boolean checkRndSite = false;
        for(Contact con: newList){
            if(con.RecordTypeId == CONTACT_RECORD_TYPE_ID && con.Populate_Mailing_Address__c != null &&
                con.MailingStreet == null && con.MailingCity == null && con.MailingState == null && con.MailingPostalCode == null && con.MailingCountry == null){
                    if(con.Account_Address__c != null){
                        accountAddressId.add(con.Account_Address__c);
                    }
                    if(con.AccountId != null){
                        accountIdSet.add(con.AccountId);
                    }
                }else {
                    con.Populate_Mailing_Address__c = null;
                    if(con.AccountId != null){
                        accountIdSet.add(con.AccountId);
                        checkRndSite = true;
                    }
                }
        }
        
        if(accountAddressId.size() > 0 || accountIdSet.size() > 0){
            if(accountAddressId.size() > 0){
                accountAddressMap = new Map<Id,Address__c> ([SELECT Id,Street__c,City__c,State__c,PostalCode__c,Country__c FROM Address__c WHERE Id IN :accountAddressId]);
            }else if(accountIdSet.size() > 0){
                accountMap = new Map<Id,Account>([SELECT Id,Name,AccountCountry__c,RDCategorization__c FROM Account WHERE Id IN :accountIdSet]);    
            }
            
            for(Contact con: newList){
                if(con.RecordTypeId == CONTACT_RECORD_TYPE_ID && con.Populate_Mailing_Address__c!= null && 
                    con.MailingStreet == null && con.MailingCity == null && con.MailingState == null && con.MailingPostalCode == null && con.MailingCountry == null){
                    if(con.Populate_Mailing_Address__c == 'Copy Account Address to Mailing Address' && con.Account_Address__c != null){
                        con.MailingStreet = accountAddressMap.get(con.Account_Address__c).Street__c;
                        con.MailingCity = accountAddressMap.get(con.Account_Address__c).City__c;
                        con.MailingState= accountAddressMap.get(con.Account_Address__c).State__c;
                        con.MailingPostalCode = accountAddressMap.get(con.Account_Address__c).PostalCode__c;
                        con.MailingCountry = accountAddressMap.get(con.Account_Address__c).Country__c ;
                    }
                    else if(con.Populate_Mailing_Address__c == 'Copy Account Country to Mailing Country') {
                        con.MailingCountry = accountMap.get(con.AccountId).AccountCountry__c;
                    }
                }else if(oldMap == null && checkRndSite && con.RecordTypeId == CONTACT_RECORD_TYPE_ID && accountMap.containsKey(con.AccountId) && accountMap.get(con.AccountId).RDCategorization__c == 'Site'){
                    con.MailingCountry = accountMap.get(con.AccountId).AccountCountry__c;
                }
                con.Populate_Mailing_Address__c = null;
            }
        }        
    }
	
	/*public static void deactivateCommunityUser(List<Contact> newList, Map<Id,Contact> oldMap){
        Set<Id> contactId = new Set<Id>();
        Boolean hasCustomPermission = FeatureManagement.checkPermission('CSM_Bypass_CSM_Validation_Rules');
        for(Contact con : newList){
            if(con.Inactive__c && con.Inactive__c != oldMap.get(con.id).Inactive__c)
            {
                contactId.add(con.Id);
            }
        }
        if(contactId != null && !contactId.isEmpty()){
            List<User> userList = new SLT_User().selectUserByUserContactId(contactId);
            Date lstLoginDate = System.today().addMonths(-6);
            
            for(Contact con : newList){
                if(con.Inactive__c && con.Inactive__c != oldMap.get(con.id).Inactive__c)
                {
                    for(User us : userList)
                    {               
                        
                        if(contactId.Contains(us.ContactId) && us.lastlogindate >= lstLoginDate && hasCustomPermission == false ){
                            con.Inactive__c = false;
                            con.addError('Community User Can Not Be Deactivated as User Logged in Within 6 Months');
                        }
                    }
                }
            }
        }

    }*/
    public static void removeCSHUserAccess(List<Contact> newList, Map<Id, Contact> oldMap) {
        for (Contact con : newList) {
            if (con.Contact_User_Type__c == CON_CSM.S_REP_USER) {
                if (Trigger.isInsert || (Trigger.isUpdate && oldMap.containsKey(con.Id) && oldMap.get(con.Id).Contact_User_Type__c != con.Contact_User_Type__c && oldMap.get(con.Id).Remove_Dashboard_Access__c == con.Remove_Dashboard_Access__c)) {
                    con.Remove_Dashboard_Access__c = true;
                }
                if (Trigger.isInsert || (Trigger.isUpdate && oldMap.containsKey(con.Id) && oldMap.get(con.Id).Contact_User_Type__c != con.Contact_User_Type__c && oldMap.get(con.Id).Remove_Shared_Folder_Access__c == con.Remove_Shared_Folder_Access__c)) {
                    con.Remove_Shared_Folder_Access__c = true;
                }
            } else if (con.Contact_User_Type__c == CON_CSM.S_HO_USER) {
                if (Trigger.isInsert || (Trigger.isUpdate && oldMap.containsKey(con.Id) && oldMap.get(con.Id).Contact_User_Type__c != con.Contact_User_Type__c && oldMap.get(con.Id).Remove_Dashboard_Access__c == con.Remove_Dashboard_Access__c)) {
                    con.Remove_Dashboard_Access__c = false;
                }
                if (Trigger.isInsert || (Trigger.isUpdate && oldMap.containsKey(con.Id) && oldMap.get(con.Id).Contact_User_Type__c != con.Contact_User_Type__c && oldMap.get(con.Id).Remove_Shared_Folder_Access__c == con.Remove_Shared_Folder_Access__c)) {
                    con.Remove_Shared_Folder_Access__c = false;
                }
            }
        }
    }
	
}