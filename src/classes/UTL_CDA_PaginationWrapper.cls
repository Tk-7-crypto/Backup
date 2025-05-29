public class UTL_CDA_PaginationWrapper {
    @AuraEnabled
    public Integer currentPageNumber {get;set;}
    
    @AuraEnabled
    public Integer totalPages {get;set;}
    
    @AuraEnabled
    public List<Integer> pageCounter {get;set;}
    
    @AuraEnabled
    public Integer totalRecords {get;set;}
}