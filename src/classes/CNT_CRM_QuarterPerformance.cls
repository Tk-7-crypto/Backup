public with sharing class CNT_CRM_QuarterPerformance {

    @AuraEnabled
    public static Map<String, Object> getCurrentQuarterData() {
        Decimal totalCommitAmount = 0;
        Decimal totalCallAmount = 0;
        Decimal totalBestAmount = 0;
        Map<String,Object> returnCurrentQuarterMap = new Map<String,Object>();
        List<opportunity> lstopportunity = processCurrentQuarter();
        for(Opportunity opp : lstopportunity) {
            if(opp.Amount != null && (opp.StageName == '5. Finalizing Deal' || opp.StageName == '6. Received ATP/LOI' || opp.StageName == '7a. Closed Won' || opp.StageName == 'In-Hand')) {
                totalCommitAmount = totalCommitAmount + opp.Amount_In_USD__c;
            } else if(opp.Amount != null && (opp.StageName == '3. Developing Proposal' || opp.StageName == '4. Delivering Proposal')) {
                totalCallAmount = totalCallAmount + opp.Amount_In_USD__c;
            } else if(opp.Amount != null && (opp.StageName == '1. Identifying Opportunity' || opp.StageName == '2. Qualifying Opportunity')) {
                totalBestAmount = totalBestAmount + opp.Amount_In_USD__c;
            }
        }
        returnCurrentQuarterMap.put('totalCommitAmount', totalCommitAmount);
        returnCurrentQuarterMap.put('totalCallAmount', totalCallAmount);
        returnCurrentQuarterMap.put('totalBestAmount', totalBestAmount);
        return returnCurrentQuarterMap;
    }

    public static List<opportunity> processCurrentQuarter() {
        List<String> exceptStages = new List<String>{'7b. Closed Lost'};
        Integer Year = System.Today().Year();
        Integer quarter = (Integer)Math.Ceil((System.Today().Month() - 0.5) / 3);
        Date startDate;
        Date endDate;
        if(quarter == 1) {
            startDate = Date.valueOf(year+'-01-01');
            endDate = Date.valueOf(year+'-03-31');
        } else if(quarter == 2) {
            startDate = Date.valueOf(year+'-04-01');
            endDate = Date.valueOf(year+'-06-30');
        } else if(quarter == 3) {
            startDate = Date.valueOf(year+'-07-01');
            endDate = Date.valueOf(year+'-09-30');
        } else {
            startDate = Date.valueOf(year+'-10-01');
            endDate = Date.valueOf(year+'-12-31');
        }
        List<opportunity> lstOpportunity = [SELECT Id, OwnerId, Owner.Full_User_Name__c, Inside_Sales__c, Inside_Sales__r.Full_User_Name__c, 
            Opportunity_Auto_Number__c, Name, AccountId, Account.Name, Amount, Inside_Sales_Transfer_Date__c, CloseDate,
            Advanced_Plan__c, StageName, Amount_In_USD__c, CurrencyIsoCode FROM Opportunity 
            WHERE Inside_Sales_Transfer_Date__c != null and Inside_Sales__c = :UserInfo.getUserId() and 
            StageName NOT IN :exceptStages and CloseDate >= :startDate and CloseDate <= :endDate Order by StageName];
        for(opportunity opp : lstOpportunity) {
            if(String.isNotBlank(opp.Advanced_Plan__c)) {
                if((opp.Advanced_Plan__c).length() > 300) {
                    opp.Advanced_Plan__c = opp.Advanced_Plan__c.substring( 0, 297 ) + '…' ;
                }
            }
        }
        return lstOpportunity;    
    }

    @AuraEnabled(cacheable=true)
    public static List<opportunity> generateCurrentQuarterReport(String reportName) {
        List<opportunity> lstOpptyReport = new List<opportunity>();
        List<opportunity> lstOpportunity = processCurrentQuarter();
        for(Opportunity opp : lstOpportunity) {
            if(reportName == 'ISOpsCommit' && (opp.StageName == '5. Finalizing Deal' || opp.StageName == '6. Received ATP/LOI' || opp.StageName == '7a. Closed Won' || opp.StageName == 'In-Hand')) {
                lstOpptyReport.add(opp);
            } else if(reportName == 'ISOpsCall' && (opp.StageName == '3. Developing Proposal' || opp.StageName == '4. Delivering Proposal')) {
                lstOpptyReport.add(opp);
            } else if(reportName == 'ISOpsBest' && (opp.StageName == '1. Identifying Opportunity' || opp.StageName == '2. Qualifying Opportunity')) {
                lstOpptyReport.add(opp);
            }
        }
        return lstOpptyReport;
    }
}