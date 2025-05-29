public class CNT_CLM_AgreementPayerController {
    
    /*
    * this method is used to get Agreement Special Terms Included Picklist Values
    * @param String recordId
    * @return List<SpecialTermsWrapper>
    */
    @AuraEnabled
    public static List<SpecialTermsWrapper> getSpecialTerms(String recordId){
        Set<String> agreementFieldSet = new Set<String>{CON_CLM.ID, CON_CLM.SPECIAL_TERMS_INCLUDED};
        List<Apttus__APTS_Agreement__c> aggList = new SLT_Agreement().getAgreementFieldsById(new Set<ID>{recordId}, agreementFieldSet);
        List<String> specialTermsIncluded = new List<String>();
        if(aggList.size()>0){ 
            specialTermsIncluded =  aggList[0].Special_Terms_Included__c != null?aggList[0].Special_Terms_Included__c.split(';'):new List<String>();
        }
        
        List<SpecialTermsWrapper> specialTermsList = new List<SpecialTermsWrapper>(); 
        Schema.DescribeFieldResult fieldResult = Apttus__APTS_Agreement__c.Special_Terms_Included__c.getDescribe(); 
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        Integer rowIndex = 0; 
        for (Schema.PicklistEntry p: pList) { 
            if(p.getLabel() != CON_CLM.OWNER_CHANGED && p.getLabel() != CON_CLM.SUBMITTED_AGREEMENT && 
                p.getLabel() != CON_CLM.QUOTE_UPDATED && p.getLabel() != CON_CLM.QUOTE_ACCEPTED 
                && p.getLabel() != CON_CLM.MIGRATION_COMPLETED && p.getLabel() != CON_CLM.MIGRATION_COMPLETED_NO_FOLDER
                && p.getLabel() != CON_CLM.RESTRICT_CO_AGREEMENT) {
                SpecialTermsWrapper wrp = new SpecialTermsWrapper();
                wrp.label = p.getLabel();
                wrp.Value = p.getValue();
                wrp.rowIndex = rowIndex;
                wrp.isYes = false;
                wrp.isNo = false;
                if(specialTermsIncluded.contains(wrp.Value)){
                    wrp.isYes = true;
                }else if(!specialTermsIncluded.isEmpty()){
                    wrp.isNo = true;
                }
                
                specialTermsList.add(wrp); 
                rowIndex ++; 
            }
        }
        return specialTermsList;
    }
    
    /*
    * this method is used to get Agreement Payer Custom setting data
    * @return List<String>
    */
    @AuraEnabled
    public static List<String> showCustomSettingData(){
        List<String> noticeList = new List<string>();
        try{
            Agreement_Payer__c agreementPayer = Agreement_Payer__c.getValues(CON_CLM.AGREEMENT_PAYER_DATA);  
            noticeList.add(agreementPayer.Notice1__c);
            noticeList.add(agreementPayer.Notice_2__c); 
        }catch(Exception e){}
            return noticeList;
    }
    
    /*
    * this method is used to update Special Term field of agreement object
    * @param String recordId
    * @param String objString
    * @return String
    */
    
    @AuraEnabled  
    public static String updateSpecialTerms(String recordId, String objString){ 
        try{
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Apttus__APTS_Agreement__c.SobjectType
            }
            );
            List<SpecialTermsWrapper> SpecialTermsList = (List<SpecialTermsWrapper>)system.JSON.deserializeStrict(objString, List<SpecialTermsWrapper>.class);
            string specialTerms='';
            Apttus__APTS_Agreement__c agreement = new Apttus__APTS_Agreement__c();
            agreement.ID = recordId;
            for(SpecialTermsWrapper sw: SpecialTermsList){ 
                if(sw.isYes ==true){ 
                    specialTerms +=  sw.Value + ';';
                }
            } 
            agreement.Special_Terms_Included__c = null; 
            if(specialTerms != ''){
                specialTerms = specialTerms.removeEnd(';');
                agreement.Special_Terms_Included__c = specialTerms;
            }
            uow.registerDirty(agreement);
            uow.commitWork(); 
            return CON_CLM.SUCCESSFUL_UPDATE_MESSAGE;
        }catch(Exception ex){
            return ex.getMessage();
        } 
    }
    
    /**
    * This class used as a wrapper.
    */
    public class SpecialTermsWrapper{
        @AuraEnabled
        public Integer rowIndex; 
        @AuraEnabled
        public boolean isYes;
        @AuraEnabled
        public boolean isNo;  
        @AuraEnabled
        public string label;
        @AuraEnabled
        public string Value;
        public SpecialTermsWrapper(){ 
            isYes =false;
            isNo=false;
            label ='';
            Value ='';
        }
    } 
}