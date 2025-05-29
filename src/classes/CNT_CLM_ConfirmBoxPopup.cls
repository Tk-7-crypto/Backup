public class CNT_CLM_ConfirmBoxPopup {
    
    @AuraEnabled
    public static Boolean deleteAgreementById(Id agreementId) {
        Boolean isDeleted = false;

        try{
            isDeleted = SRV_CLM_Agreement.deleteAgreement(agreementId);
        }catch(Exception ex){
            throw new AuraHandledException(JSON.serialize(ex));
        }
        return isDeleted;
    }

}