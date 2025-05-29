public class CNT_CDA_CDALookupTool { 
	public String sortBy{get;set;}
    public String searchString{get;set;}
    public String query;
    public String sortOrder{get{
    	if(sortOrder == null){
    		sortOrder = 'ASC';
    	}
    	return sortOrder;
    } set;}
    
    public ApexPages.StandardSetController setCDARequest {
        get;
        set;
    }
    
    public Integer noOfRecords;
    
    public Integer totalNoOfRec{
    	get{
            if(setCDARequest != null){
                totalNoOfRec = setCDARequest.getResultSize();
                return totalNoOfRec;
            }
            return 0;
    	}
    	set;
    }
    
    public Integer pageSize {
    	get {
    		if(pageSize == null){
    			pageSize = 15;
    		}
    		return pageSize;
    	}
    	set;
	}
    
    public Integer currentPageNo{
    	get{
            if(setCDARequest != null){
                currentPageNo = setCDARequest.getPageNumber();
                return currentPageNo;
            }
            return 1;
    	}
    	set;
    }
    
    public CNT_CDA_CDALookupTool(){
        
    }
    
    public PageReference settableSize(){
    	setCDARequest.setPageSize(pageSize);
    	return null;
    }
    
    private String getCDAQuery(){
        Set<String> setCDAType = new Set<String>{'Customer', 'Vendor'};
    	String query = 'Select Id, Name, Recipient_Account__r.CDA_Account_Name__c, Recipient_Account__r.Country__c, Recipient_Account_Name_Other__c, Recipient_Account_Country_Other_PL__c, QuintilesIMS_Business__c, CDA_Type__c, Project_Specific_Indicator__c, CDA_Source__c, CDA_Effective_Date__c, Disclosure_Period__c, Project_Description_Long_Textarea__c, QI_Legal_Entity_Name__r.Name, QI_Legal_Entity_Name__r.Location_of_Governing_Law__r.Name from CDA_Request__c ';
        query += ' where Status__c = \'Contract Executed\' AND IsTodayBtwnEffectiveDateDisclosurePeriod__c = true AND Individual_Indicator__c = \'No\' AND CDA_Type__c in (\'Customer\', \'Vendor\') AND (Recipient_Account__r.CDA_Account_Name__c Like \'%' + searchString + '%\' OR Recipient_Account_Name_Other__c Like \'%' + searchString + '%\')';
    	if(sortBy != null && sortOrder != null){
	    	query += 'ORDER BY ' + sortBy + ' ' + sortOrder;
    	}
    	return query;
    }
    
    public PageReference searchCDARequests(){
        String query;
        if(searchString == null){
            query = getCDAQuery() + 'ORDER BY Name Desc';
        }else{
            query = getCDAQuery();
        }
        setCDARequest = new ApexPages.StandardSetController(database.query(query));
        setCDARequest.setPageSize(pageSize);  
        noOfRecords = setCDARequest.getResultSize();
        return null;
    }
    
    public List<CDA_Request__c> getcdaRequests(){
        if(setCDARequest != null){
            return setCDARequest.getRecords();
        }
        return new List<CDA_Request__c>();
    }
    
    public PageReference sortData(){
    	
    	query = getCDAQuery();
    	setCDARequest = new ApexPages.StandardSetController(database.query(query));
        setCDARequest.setPageSize(pageSize);
        return null;
    }
}