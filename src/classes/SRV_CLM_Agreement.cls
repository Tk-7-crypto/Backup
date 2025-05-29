/**
* Service class for Agreement - CLM Module
*/
public class SRV_CLM_Agreement {
    
    public SRV_CLM_Agreement(){
        
    }

    /**
    * This method use to create agreement record
    * @param Apttus__APTS_Agreement__c agreement
    * @return  Apttus__APTS_Agreement__c
    */
    public static Apttus__APTS_Agreement__c createAgreement(Apttus__APTS_Agreement__c agreement){
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Apttus__APTS_Agreement__c.SObjectType
            }
        );
        try {
            uow.registerNew(agreement);
            uow.commitWork();
        }catch(Exception ex) {
            Set<String> errorMsgList = new Set<String>();   
            if(ex.getTypeName() == 'System.DmlException') {
                for(Integer i = 0; i < ex.getNumDml(); i++) {
                   errorMsgList.add(ex.getDmlMessage(i));
                }
            }
            else {
            	errorMsgList.add(ex.getMessage() + ' ' + ex.getStackTraceString());
            }
            throw new SRV_CLM_Agreement_Exception(new List<String>(errorMsgList));
        } 
        return agreement;
    }

    /**
    * This method get agreement details based on agreement id
    * @param Id agreementId
    * @param fieldSet is the set which contains the fields
    * @return  Apttus__APTS_Agreement__c
    */
    public static Apttus__APTS_Agreement__c getAgreementDetailById(Id agreementId, Set<String> fieldSet){
        Apttus__APTS_Agreement__c agreement = new SLT_Agreement().getAgreementDetails(agreementId, fieldSet);
        return agreement;
    }
    
    /**
    * This method get map of field name and label
    * 
    * @return  Map<String,String>
    */
	public static Map<String,String> getAgreementFieldMap(){
        return UTL_CLM.getFieldAPINameLabelMap('Apttus__APTS_Agreement__c');
    }

    /**
    * This method use to update agreement record
    * @param Apttus__APTS_Agreement__c
    * @return  Apttus__APTS_Agreement__c
    */
    public static Apttus__APTS_Agreement__c updateAgreement(Apttus__APTS_Agreement__c agreement){
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Apttus__APTS_Agreement__c.SObjectType
            }
        );
        try {
            uow.registerDirty(agreement);
            uow.commitWork();
        }catch(Exception ex) {
            Set<String> errorMsgList = new Set<String>();   
            if(ex.getTypeName() == 'System.DmlException') {
                for(Integer i = 0; i < ex.getNumDml(); i++) {
                   errorMsgList.add(ex.getDmlMessage(i));
                }
            }
            else {
            	errorMsgList.add(ex.getMessage() + ' ' + ex.getStackTraceString());
            }
            throw new SRV_CLM_Agreement_Exception(new List<String>(errorMsgList));
        } 
        return agreement;
    }
    
    /**
    * This method use to update iqvia agreement record
    * @param IQVIA_Agreement__c
    * @return  IQVIA_Agreement__c
    */
    public static IQVIA_Agreement__c updateIQVIAAgreement(IQVIA_Agreement__c agreement) {
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                IQVIA_Agreement__c.SObjectType
            }
        );
        try {
            uow.registerDirty(agreement);
            uow.commitWork();
        }catch(Exception ex) {
            Set<String> errorMsgList = new Set<String>();   
            if(ex.getTypeName() == 'System.DmlException') {
                for(Integer i = 0; i < ex.getNumDml(); i++) {
                   errorMsgList.add(ex.getDmlMessage(i));
                }
            }
            else {
            	errorMsgList.add(ex.getMessage() + ' ' + ex.getStackTraceString());
            }
            throw new SRV_CLM_Agreement_Exception(new List<String>(errorMsgList));
        } 
        return agreement;
    }    
    
    /**
    * This method use to delete agreement record
    * @param Id
    * @return Boolean
    */
    public static Boolean deleteAgreement(Id agreementId){
        Boolean isDeleted = false;
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Apttus__APTS_Agreement__c.SObjectType
            }
        );
        Apttus__APTS_Agreement__c agreement = new Apttus__APTS_Agreement__c(Id = agreementId);

        try {
            uow.registerDeleted(agreement);
            uow.commitWork();
            isDeleted = true;
        }catch(Exception ex) {
            isDeleted = false;
            Set<String> errorMsgList = new Set<String>();   
            if(ex.getTypeName() == 'System.DmlException') {
                for(Integer i = 0; i < ex.getNumDml(); i++) {
                   errorMsgList.add(ex.getDmlMessage(i));
                }
            }
            else {
            	errorMsgList.add(ex.getMessage() + ' ' + ex.getStackTraceString());
            }
            throw new SRV_CLM_Agreement_Exception(new List<String>(errorMsgList));
        } 
        return isDeleted;
    }
    
    /**
    * Exception class for SRV_CRL_Agreement
    */
    public class SRV_CLM_Agreement_Exception extends Exception {
        List<String> errorList = new List<String>();
        
        /**
        * constructor of SRV_CLM_Agreement_Exception
        */
        public SRV_CLM_Agreement_Exception (List<String> errorList) {
            this.errorList = errorList;
        }
    }
    
}