public class CNT_OWF_InvestigatorGrant
{

	public Id recordId;
	public Investigator_Grant__c IG{get;set;}
	public String linkToInvestigatorGrant{get;set;}
	
	public Id getRecordId(){
		return recordId;
	}
	
	public void setRecordId(Id incomingId){
		if(incomingId!=null){
			recordId = incomingId;
			fetchfieldsAndInitializeObject(recordId);   
		}        
	}

	public Investigator_Grant__c fetchfieldsAndInitializeObject(Id recordId){
        Set<Id> recordIdsSet = new Set<Id>();
        recordIdsSet.add(recordId);
        Set<String> investigatorgrantFieldSet = new Set<String>{'Name','Investigator_Grants_Due_Date_to_PD__c',
        'Proposal_Due_date__c','Bid_Number__c','RFP_Ranking__c','Build_Type__c','Benchmark_Range__c',
        'Box_Link_to_RFP_Documents_Formula__c','Alt_Budget_required__c','Additional_Comments__c',
        'Assigned_Investigator_Grants_Developer__r.Name','Grants_Developer_Email__c','Bid_History__r.RFP_Folder_Link__c'};
        IG = new SLT_InvestigatorGrant(false,false).getInvestigatorGrantById(recordIdsSet,investigatorgrantFieldSet).values()[0];                      
        linkToInvestigatorGrant = URL.getOrgDomainUrl().toExternalForm()+'/'+recordId;
	return IG;
	}
}