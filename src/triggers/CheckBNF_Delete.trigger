trigger CheckBNF_Delete on BNF2__c (before delete) {
    Set<String> bnfStatusSet = new Set<String>();
    bnfStatusSet.add(CON_CRM.BNF_STATUS_ACCEPTED);
    bnfStatusSet.add(CON_CRM.SAP_CONTRACT_CONFIRMED);
    bnfStatusSet.add(CON_CRM.BNF_STATUS_LO_ACCEPTED);
    bnfStatusSet.add(CON_CRM.BNF_STATUS_RA_ACCEPTED);
    bnfStatusSet.add(CON_CRM.BNF_STATUS_SAP_CONTRACT_PENDING);
    bnfStatusSet.add(CON_CRM.BNF_STATUS_SAP_PENDING);
    if( Mulesoft_Integration_Control__c.getInstance() != null && !Mulesoft_Integration_Control__c.getInstance().Ignore_Validation_Rules__c) {
        for (BNF2__c bnf:trigger.old) {
            if( bnfStatusSet.contains(bnf.BNF_Status__c)){
                bnf.addError('BNF\'s cannot be deleted once they have been submitted/Accepted.');
            }
        }
    }     
}