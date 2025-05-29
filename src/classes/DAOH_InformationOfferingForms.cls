public class DAOH_InformationOfferingForms {
    public static void updateParentCaseFields(List<Information_Offering_Forms__c> newList, Map<Id, Information_Offering_Forms__c> oldMap) {
        Map<Id, Information_Offering_Forms__c> caseOfferingMap = new Map<Id, Information_Offering_Forms__c>();
        Map<Id, Information_Offering_Forms__c> dicaseOfferingMap = new Map<Id, Information_Offering_Forms__c>();
        for(Information_Offering_Forms__c offering: newList) {
            if(offering.Form_Request_Type__c == CON_CSM.S_PATIENT_OFF){
                caseOfferingMap.put(offering.Case__c, offering);
            }else{
                dicaseOfferingMap.put(offering.Case__c, offering);
            }
        }
        if(caseOfferingMap != null && caseOfferingMap.size() > 0) {
            //Set<String> caseFieldSet = getAllCustomFields(Information_Offering_Forms__c.sObjectType);
            //caseFieldSet.removeAll(new Set<String>{'Case__c', 'Form_Request_Type__c'});
            //Set<String> caseFieldSet = new Set<String>{'Illustration_of_issue_attached__c','AttachMarketDefinitionToTicket__c','DataWeekMonthofReportLifelink__c','FlexibleFields__c','InternalOrExternalDI__c','Internal_or_External_DI__c','LookBackPeriod__c','Monthly_Weekly_Time_Periods_in_Question__c','Product_Market_or_Other_Name__c','PRSNumber__c','TimingofReportChanges__c','MarketNameOnWeb__c'};
            Set<String> caseFieldSet = CON_CSM.DATA_IOF_CASEFIELD;
            caseFieldSet.add('InformationOfferingFormRequestType__c');
            List<Case> caseList = new SLT_Case().selectByCaseIdList(caseOfferingMap.keySet(), caseFieldSet );
            caseFieldSet.remove('InformationOfferingFormRequestType__c');
            if(caseList != null && caseList.size() > 0) {
                for(Case parentCase: caseList) {
                    for(String fieldName: caseFieldSet) {
                        if(caseOfferingMap.containsKey(parentCase.Id) && caseOfferingMap.get(parentCase.Id) != null) {
                            Information_Offering_Forms__c offering = caseOfferingMap.get(parentCase.Id);
                            if(Trigger.isInsert || (Trigger.isBefore && Trigger.isUpdate && oldMap != null && oldMap.containsKey(offering.Id) && oldMap.get(offering.Id) != null && oldMap.get(offering.Id).get(fieldName) != offering.get(fieldName))) {
                                if(fieldName == CON_CSM.S_ATTACH_MARKET_DEFINITION_TO_TICKET_C) {
                                    parentCase.AttachMarketDefinitionToTicket__c = offering.AttachMarketDefinitionToTicket__c ? CON_CSM.S_YES: CON_CSM.S_NO;
                                } 
                                else {
                                    parentCase.put(fieldName, offering.get(fieldName));
                                    parentCase.InformationOfferingFormId__c = offering.Id;
                                    List<String> formRequestTypeList = new List<String>();
                                    if(parentCase.InformationOfferingFormRequestType__c != null) {
                                        formRequestTypeList = parentCase.InformationOfferingFormRequestType__c.split(';');
                                    }
                                    if(! formRequestTypeList.contains(offering.Form_Request_Type__c)) {
                                        formRequestTypeList.add(offering.Form_Request_Type__c);
                                    }
                                    parentCase.InformationOfferingFormRequestType__c = String.join(formRequestTypeList,';');
                                }
                            }
                            else if(Trigger.isBefore && Trigger.isDelete) {
                                parentCase.put(fieldName, null);
                                parentCase.Illustration_of_issue_attached__c = false;
                                parentCase.InformationOfferingFormId__c = '';
                                List<String> formRequestTypeList = new List<String>();
                                formRequestTypeList = parentCase.InformationOfferingFormRequestType__c.split(';');
                                for(integer i = 0; i < formRequestTypeList.size(); i++) {     
                                    if(formRequestTypeList[i] == offering.Form_Request_Type__c){
                                        formRequestTypeList.remove(i);
                                        i--;
                                    }
                                }
                                parentCase.InformationOfferingFormRequestType__c = String.join(formRequestTypeList,';');
                            }
                        }
                        
                    }
                }
                update caseList;
            }
        }else if(dicaseOfferingMap != null && dicaseOfferingMap.size() > 0) {
            List<Case> caseList = new SLT_Case().selectByCaseIdList(dicaseOfferingMap.keySet(), new Set<String>{'Id','InformationOfferingFormId__c','InformationOfferingFormRequestType__c','Status'});
            List<Case> cases = new List<Case>();
            if(caseList != null && caseList.size() > 0) {
                for(Case parentCase: caseList) {
                        if(dicaseOfferingMap.containsKey(parentCase.Id) && dicaseOfferingMap.get(parentCase.Id) != null && parentCase.Status != CON_CSM.S_CLOSED ) {
                            Information_Offering_Forms__c offering = dicaseOfferingMap.get(parentCase.Id);
                            if(Trigger.isInsert || (Trigger.isBefore && Trigger.isUpdate && oldMap != null && oldMap.containsKey(offering.Id) && oldMap.get(offering.Id) != null && parentCase.InformationOfferingFormId__c != null)) {
                                parentCase.InformationOfferingFormId__c = offering.Id;
                                List<String> formRequestTypeList = new List<String>();
                                if(parentCase.InformationOfferingFormRequestType__c != null) {
                                    formRequestTypeList = parentCase.InformationOfferingFormRequestType__c.split(';');
                                }
                                if(! formRequestTypeList.contains(offering.Form_Request_Type__c)) {
                                    formRequestTypeList.add(offering.Form_Request_Type__c);
                                }
                                parentCase.InformationOfferingFormRequestType__c = String.join(formRequestTypeList,';');
                                cases.add(parentCase);
                            }else if(Trigger.isBefore && Trigger.isDelete) {
                                parentCase.InformationOfferingFormId__c = '';
                                List<String> formRequestTypeList = new List<String>();
                                formRequestTypeList = parentCase.InformationOfferingFormRequestType__c.split(';');
                                for(integer i = 0; i < formRequestTypeList.size(); i++) {     
                                    if(formRequestTypeList[i] == offering.Form_Request_Type__c){
                                        formRequestTypeList.remove(i);
                                        i--;
                                    }
                                }
                                parentCase.InformationOfferingFormRequestType__c = String.join(formRequestTypeList,';');
                                cases.add(parentCase);
                            }
                        }
                    }
                
                if(!cases.isEmpty()) {
                    update cases;
                }
            }
        }
    }
    
    public static void checkOfferingRecords(List<Information_Offering_Forms__c> newList) {
        Set<Id> cOSet = new Set<Id>();
        Set<String> strSet = new Set<String>();
        for(Information_Offering_Forms__c o : newList) {
            if(Trigger.isInsert){
                cOSet.add(o.Case__c);
                strSet.add(o.Form_Request_Type__c);
            }
        }
        if(cOSet != null && !cOSet.isEmpty()){
            AggregateResult[] grList = Database.query('select Count(Id)  NumCount ,Form_Request_Type__c from Information_Offering_Forms__c where Case__c  in :cOSet and Form_Request_Type__c in :strSet group by Form_Request_Type__c');
            if(grList != null && !grList.isEmpty()){
                for(Information_Offering_Forms__c o : newList) {
                    o.addError('Case can not have multiple offerings');
                }  
            }
        }
    }

    /**private static Set<String> getAllCustomFields(Schema.SObjectType objectType) {
        List<String> sObjectFields = new List<String>{};
        Map<String, SObjectField> fieldsByName;
        if(objectType != null) {
            sObjectFields.addAll(objectType.getDescribe().fields.getMap().keySet());
            fieldsByName = objectType.getDescribe().fields.getMap();
        }  
        Set<String> customFields = new Set<String>();
        if(fieldsByName != null && fieldsByName.size() > 0) {
            for (SObjectField field : fieldsByName.values()) {
                Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
                if (fieldDescribe.isCustom() && !fieldDescribe.isCalculated()) {
                    customFields.add(fieldDescribe.getName());
                }
            }
        }
        return customFields;
    }*/
}