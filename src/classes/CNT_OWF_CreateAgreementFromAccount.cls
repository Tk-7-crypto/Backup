public class CNT_OWF_CreateAgreementFromAccount {
    
	public CNT_OWF_CreateAgreementFromAccount(ApexPages.StandardController controller) {
        
    }
    /**
     * This method is used to retrieve the eligible record types of Agreement that can be created
     * based on the current stage of Opportunity
     * @params  
     * @params  List<String> fieldList
     * @return  List<String> recordTypes
     */
    @AuraEnabled
    public static List<BidTypeWrapper> showAvailableAgrRecordTypeForAccount(Id accountId, List<String> accFields) {
        Map<Id, Account> idToAccountMap = new Map<Id, Account>();        
        Account accountRecord = new Account();
        Map<Id,String> agrRecordIdToRecordNameMap = new Map<Id,String>();
        List<BidTypeWrapper> bidTypeList = new List<BidTypeWrapper>();
        bidTypeList.add(new BidTypeWrapper(CON_OWF.OWF_NON_RFP_BID_AGREEMENT_RECORD_TYPE_ID,'',Label.OWF_CL0005_NON_RFP_BID_HEADER+','+Label.OWF_CL0006_NON_RFP_DESCRIPTION));    
        
        return bidTypeList;
    }
    
    public class BidTypeWrapper {
      @AuraEnabled public String name;
      @AuraEnabled public String typeId;
      @AuraEnabled public String bidHeader;
      @AuraEnabled public String bidDescription;        
      public BidTypeWrapper(String typeIdParam, String nameParam, String bidHeaderAndDesc ){            
            typeId = typeIdParam;
            name = nameParam;
          	String kept = bidHeaderAndDesc.substring( 0, bidHeaderAndDesc.indexOf(','));
			String remainder = bidHeaderAndDesc.substring(bidHeaderAndDesc.indexOf(',')+1, bidHeaderAndDesc.length()); 
            bidHeader = kept;
            bidDescription = remainder;
      }
        
    }
}