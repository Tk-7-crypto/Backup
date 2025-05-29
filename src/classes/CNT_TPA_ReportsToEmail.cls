public with sharing class CNT_TPA_ReportsToEmail {
    public Id rptId { get; set; }
    public String rptFilter1 { get; set; }
    private transient Reports.ReportResults results;
    public transient List<List<Reports.ReportDetailRow>> reportMasterRows;
    
    /* 
    * @Name : getReportResult
    * @Description : Here we will get the data of a report and send to the VF Component
    */
    public Reports.ReportResults getReportResult() {
        Reports.ReportDescribeResult describe = Reports.ReportManager.describeReport(rptId);
        Reports.ReportMetadata reportMd = describe.getReportMetadata();
        Reports.ReportFilter filter; 
        
        if(reportMd.getReportFilters() != null && reportMd.getReportFilters().size()>0){
            filter = reportMd.getReportFilters()[0];
            filter.setValue(rptFilter1);
        }
        
        Reports.ReportResults results = Reports.ReportManager.runReport(rptId, reportMd, true);
        system.debug('results.size():::'+results);
        return results;
    }

    public List<List<Reports.ReportDetailRow>> getReportMasterRows() {
        Reports.ReportResults results = getReportResult();
        reportMasterRows = new List<List<Reports.ReportDetailRow>>();
        Reports.ReportFactWithDetails factDetails;
        List<Reports.ReportDetailRow> reportRows;
        Reports.Dimension dim = results.getGroupingsDown();
        Reports.GroupingValue groupingVal;
        String factMapKey = ''; 
        
        if(dim.getGroupings() != null && dim.getGroupings().size() > 0){
            groupingVal = dim.getGroupings()[0];
            factMapKey = groupingVal.getKey() + '!T';
        }
        if(factMapKey == ''){
            factMapKey = '0!T';
        }
        
        
        if(results.getFactMap().get('T!T') != null) {
            factDetails = (Reports.ReportFactWithDetails)results.getFactMap().get('T!T');
            reportRows = factDetails.getRows();
            system.debug('reportRows.size():::'+reportRows.size());
        } 
        if(reportRows.size() == 0 && results.getFactMap().get(factMapKey) != null ) {
            factDetails = (Reports.ReportFactWithDetails)results.getFactMap().get(factMapKey);
            reportRows = factDetails.getRows();
            system.debug('reportRows.size():::'+reportRows.size());
        }
        
        
        if(reportRows.size() > 0) {
            system.debug('reportRows.size():::'+reportRows.size());
            Integer counter = 0;
            List<Reports.ReportDetailRow> tempRowlist = new List<Reports.ReportDetailRow>();
            for(Reports.ReportDetailRow detailRow: reportRows ) {
                tempRowlist.add(detailRow);
                counter++;
                if(counter>=999) {
                    reportMasterRows.add(tempRowlist );
                    counter = 0;
                    tempRowlist = new List<Reports.ReportDetailRow>();
                }            
            }
            if(tempRowlist.size() > 0) {
                reportMasterRows.add(tempRowlist );
            }
        }        
        
        return reportMasterRows;
    }
}
