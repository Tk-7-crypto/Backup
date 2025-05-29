/**
 *   @author    : Vikram Singh Fartyal
 *   This class supoorts VFP_CDA_CustomLandingPage. (created under ER-3556 on 29/03/2017)
 */
public with sharing class CNT_CDA_CustomLandingPage {

    //Public variable
    public CDA_Request__c searchRequest {get; set;}
    public Integer size {get;set;}  //How many records to display on page at a time.
    Public Integer noOfRecords {get; set;}  //number of records searched
    public Integer MAX_RECORDLIMIT {get;set;}  //maximum number of records retrieved
    public String idToView {get;set;}
    public String idToUpdate {get;set;}
    public String dateFormatString {
        get {
            return UTL_CDAUtility.DATE_FORMAT_STRING;
        }
        set;
    }

    public String sortDir {
        get  { if (sortDir == null) {  sortDir = 'desc'; } return sortDir; }
        set;
    }

    public String sortField {
        get  { if (sortField == null) { sortField = 'CreatedDate'; } return sortField; }
        set;
    }

    public Boolean isNegotiator {
        get {
            return (SRV_CDA_CDARequest.getUserPermission() == UTL_CDAUtility.NEGOTIATOR || SRV_CDA_CDARequest.getUserPermission() == UTL_CDAUtility.SYS_ADMIN);
        }
        set;
    }

    public ApexPages.StandardSetController setCon {
        get {
            if(setCon == null) {
                if(size == null) {
                     size = 10;
                }
                setCon = SRV_CDA_CDARequest.setCon(sortField, sortDir);
                setCon.setPageSize(size);
                noOfRecords = setCon.getResultSize();
            }
            return setCon;
        }set;
    }

    public String qiLegalEntityName {get; set;}
    public String recipientLegalEntityName {get; set;}
    public String cdaRequestorName {get; set;}
    public Boolean isQaTesting {get;set;}   //Added by Vikram Singh under CR-11526

    //Constructor
    public CNT_CDA_CustomLandingPage() {
        searchRequest = new CDA_Request__c();
        MAX_RECORDLIMIT = UTL_CDAUtility.MAX_RECORDLIMIT;
        isQaTesting = ApexPages.currentPage().getparameters().get(UTL_CDAUtility.QATESTING_STR) == null ? false : Boolean.valueOf(ApexPages.currentPage().getparameters().get(UTL_CDAUtility.QATESTING_STR));    //Added by Vikrm Singh under CR-11526
    }

    //Public methods

    public List<CDA_Request__c> getRequestList() {
        return setCon.getRecords();
    }

    public PageReference goToNewRequest() {
        return SRV_CDA_CDARequest.goToNewRequest();
    }

    public PageReference goToViewRequest() {
        return SRV_CDA_CDARequest.goToViewRequest(idToView);
    }

    public PageReference goToEditRequest() {
        return SRV_CDA_CDARequest.goToEditRequest(idToUpdate);
    }

    /**
     * Retrive list of record sizes/page to display on the page.
     */
    public List<SelectOption> getRecordsPerPage() {
        return SRV_CDA_CDARequest.getRecordsPerPage();
    }

    public PageReference refreshPageSize() {
        setCon.setPageSize(size);
        return null;
    }

    /**
     * Refreshes ApexPages.StandardSetController setCon and retrives records from very beginning
     */
    public pageReference refresh() {
        setCon = null;
        setCon.setPageNumber(1);
        return null;
    }

    /**
     * Toggles the sorting of query from asc<-->desc
     */
    public void toggleSort() {
        sortDir = sortDir.equals('asc') ? 'desc' : 'asc';
        setCon = null;
    }

    /**
     * Handles search feature
     */
    public void runSearch(){
        Integer pageNumber = setCon.getPageNumber();
        setCon = SRV_CDA_CDARequest.runSearch(searchRequest, qiLegalEntityName, recipientLegalEntityName, sortField, sortDir, cdaRequestorName);
        setCon.setPageSize(size);
        setCon.setPageNumber(pageNumber);
        noOfRecords = setCon.getResultSize();
    }

    // Added by C.P.Pandey under Day-2 Item-225 start
    /**
     * Toggles the sorting of query from asc<-->desc
     */
    public void toggleSortForCustomReport() {
        sortDir = sortDir.equals('asc') ? 'desc' : 'asc';
        runSearchForCustomReport();
    }
    // Added by C.P.Pandey under Day-2 Item-225 end

    /**
     * Handles the search feature for CDA custom report
     */
    public void runSearchForCustomReport(){
        Integer pageNumber = setCon.getPageNumber();
        setCon = SRV_CDA_CDARequest.runSearchForReport(searchRequest, cdaRequestorName, sortField, sortDir); // Modified by C.P.Pandey under Day-2 Item-225
        setCon.setPageSize(size);
        setCon.setPageNumber(pageNumber);
        noOfRecords = setCon.getResultSize();
    }
}