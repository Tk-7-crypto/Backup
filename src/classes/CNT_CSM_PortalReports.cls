/*
 * Version       : 1.0
 * Description   : Apex Controller for PortalReports component.
 */
public with sharing class CNT_CSM_PortalReports {
    public class DashboardsReportsWrapper {
        @AuraEnabled
        public String name {get; set;}
        @AuraEnabled
        public List<Report> reports {get; set;}
        @AuraEnabled
        public List<Dashboard> dashboards {get; set;}
        @AuraEnabled
        public List<EinsteinWrapper> einsteins {get; set;}
        @AuraEnabled
        public String pillar {get; set;}
    }

    public class EinsteinWrapper {
        @AuraEnabled
        public String name {get; set;}
        @AuraEnabled
        public String description {get; set;}
        @AuraEnabled
        public String id {get; set;}
    }
    @AuraEnabled
    public static List<DashboardsReportsWrapper> getDashboardsAndReportsForCurrentUser(){
        List<DashboardsReportsWrapper> dashboards_reports_list = new List<DashboardsReportsWrapper>();
        List<User> users = new List<User>();
        if(UserInfo.getUserType().contains(CON_CSM.S_CUSTOMER_SUCCCESS)) {
            users = new SLT_User().selectContactDetailByUser(new Set<Id> {userInfo.getUserId()}, new Set<String> {'Contact.Portal_Case_Type__c','Contact.Contact_User_Type__c','AccountId'});
            if (users.size() > 0 && users[0].Contact != null && users[0].AccountId != null) {
                String pillar = users[0].Contact.Portal_Case_Type__c;
                pillar = '\''+pillar.replace(';','\',\'')+'\'';
                Map<Id,Account_Dashboards_Reports_Category_RS__c> adrcRSMap = new Map<Id,Account_Dashboards_Reports_Category_RS__c>();
                List<Account_Dashboards_Reports_Category_RS__c> adrcsList = Database.query('select Dashboards_Reports_Category__r.Name, Dashboards_Reports_Category__r.Pillar__c,  Dashboards_Reports_Category__c  from Account_Dashboards_Reports_Category_RS__c where Dashboards_Reports_Category__r.Pillar__c in ('+pillar+') and Account__c=\'' + users[0].AccountId + '\'');
                for (Account_Dashboards_Reports_Category_RS__c adrc : adrcsList) {
                    adrcRSMap.put(adrc.Dashboards_Reports_Category__c, adrc);
                }
                Set<Id> drcSet = adrcRSMap.keySet();
                List<Dashboards_Category_Relationship__c>  dcrList = Database.query('select Dashboards_Reports_Category__c,DashboardId__c from Dashboards_Category_Relationship__c where Dashboards_Reports_Category__c in :drcSet');
                Set<String> dashboardIds = new Set<String>();
                for(Dashboards_Category_Relationship__c dc: dcrList) {
                    dashboardIds.add(dc.DashboardId__c);
                }
                Map<String,Dashboard> allDashMap = new SLT_Dashboard().getDashboardById(dashboardIds, new Set<String>{'Id','Title','Description'});
                
                List<Reports_Category_Relationship__c> rcrList = Database.query('select Report_Id__c,Dashboards_Reports_Category__c from Reports_Category_Relationship__c where Dashboards_Reports_Category__c in :drcSet');
                Set<String> reportIds = new Set<String>();
                for(Reports_Category_Relationship__c rc: rcrList) {
                    reportIds.add(rc.Report_Id__c);
                }
                Map<String,Report> allRepMap = new SLT_Report().getReportById(reportIds, new Set<String>{'Id','Name','Description'});
                List<PermissionSetAssignment> pa = Database.query('select Id from PermissionSetAssignment where AssigneeId = \''+users[0].Id +'\' and  PermissionSet.Name = \'CSM_Einstein_Analytic_for_Community\'');
                List<Einstein_Analytics_Category_Relationship__c> eaacrList = null;
                List<Contact_Einstein_Category_Relationship__c> cecrList = null;
                String contactId = users[0].ContactId;
                if(pa != null && pa.size() >0) {
                    eaacrList = Database.query('select Einstein_Analytics_Id__c, Einstein_Analytics_Name__c, Einstein_Analytics_Description__c,Dashboards_Reports_Category__c from Einstein_Analytics_Category_Relationship__c where Dashboards_Reports_Category__c in :drcSet and Id not in (select Einstein_Analytics_Category__c from Contact_Einstein_Category_Relationship__c)');
                    if(contactId != null){
                        cecrList = Database.query('select Einstein_Analytics_Category__r.Dashboards_Reports_Category__c,Einstein_Analytics_Category__r.Einstein_Analytics_Id__c, Einstein_Analytics_Category__r.Einstein_Analytics_Name__c, Einstein_Analytics_Category__r.Einstein_Analytics_Description__c from Contact_Einstein_Category_Relationship__c where Contact__c =:contactId and Einstein_Analytics_Category__r.Dashboards_Reports_Category__c in : drcSet');
                    }
                }
                for (Account_Dashboards_Reports_Category_RS__c adrc : adrcsList) {
                    try{
                    DashboardsReportsWrapper dashboards_reports = new DashboardsReportsWrapper();
                    dashboards_reports.Name = adrc.Dashboards_Reports_Category__r.name;
                    dashboards_reports.pillar = adrc.Dashboards_Reports_Category__r.Pillar__c;
                    List<Dashboard> dashList = new List<Dashboard>();
                    for(Dashboards_Category_Relationship__c dc: dcrList) {
                        if(adrc.Dashboards_Reports_Category__c == dc.Dashboards_Reports_Category__c && allDashMap != null && allDashMap.containsKey(dc.DashboardId__c)){
                            dashList.add(allDashMap.get(dc.DashboardId__c));
                        }
                    }
                    dashboards_reports.dashboards = dashList;
                    
                    List<Report> repList = new List<Report>();
                    for(Reports_Category_Relationship__c rc: rcrList) {
                        if(adrc.Dashboards_Reports_Category__c == rc.Dashboards_Reports_Category__c && allRepMap != null && allRepMap.containsKey(rc.Report_Id__c)){
                            repList.add(allRepMap.get(rc.Report_Id__c));
                        }
                    }
                    dashboards_reports.reports = repList;
                    if(pa != null && pa.size() >0) {
                        dashboards_reports.einsteins = new List<EinsteinWrapper>();
                        for(Einstein_Analytics_Category_Relationship__c ec: eaacrList) {
                            if(adrc.Dashboards_Reports_Category__c == ec.Dashboards_Reports_Category__c){
                                EinsteinWrapper ew = new EinsteinWrapper();
                                ew.id = ec.Einstein_Analytics_Id__c;
                                ew.name = ec.Einstein_Analytics_Name__c;
                                ew.description = ec.Einstein_Analytics_Description__c;
                                dashboards_reports.einsteins.add(ew);    
                            }
                            
                        }
                        for(Contact_Einstein_Category_Relationship__c cec: cecrList) {
                            if(adrc.Dashboards_Reports_Category__c == cec.Einstein_Analytics_Category__r.Dashboards_Reports_Category__c){
                                EinsteinWrapper ew = new EinsteinWrapper();
                                ew.id = cec.Einstein_Analytics_Category__r.Einstein_Analytics_Id__c;
                                ew.name = cec.Einstein_Analytics_Category__r.Einstein_Analytics_Name__c;
                                ew.description = cec.Einstein_Analytics_Category__r.Einstein_Analytics_Description__c;
                                dashboards_reports.einsteins.add(ew);    
                            }
                        }
                    }
                    dashboards_reports_list.add(dashboards_reports);    
                    }catch(Exception e){
                        System.debug('error :'+ e.getMessage());
                    }
                    
                }
            }
        }
        return dashboards_reports_list;
    }
    
    /**@AuraEnabled
    public static List<DashboardsReportsWrapper> getDashboardsAndReportsForCurrentUser(){
        List<DashboardsReportsWrapper> dashboards_reports_list = new List<DashboardsReportsWrapper>();
        List<User> users = new List<User>();
        if(UserInfo.getUserType().contains(CON_CSM.S_CUSTOMER_SUCCCESS)) {
            users = new SLT_User().selectContactDetailByUser(new Set<Id> {userInfo.getUserId()}, new Set<String> {'Contact.Portal_Case_Type__c','Contact.Contact_User_Type__c','AccountId'});
            if (users.size() > 0 && users[0].Contact != null && users[0].AccountId != null) {
                String pillar = users[0].Contact.Portal_Case_Type__c;
                pillar = '\''+pillar.replace(';','\',\'')+'\'';
                for (Account_Dashboards_Reports_Category_RS__c adrc:Database.query('select Dashboards_Reports_Category__r.Name, Dashboards_Reports_Category__r.Pillar__c,  Dashboards_Reports_Category__c  from Account_Dashboards_Reports_Category_RS__c where Dashboards_Reports_Category__r.Pillar__c in ('+pillar+') and Account__c=\'' + users[0].AccountId + '\'')) {
                    DashboardsReportsWrapper dashboards_reports = new DashboardsReportsWrapper();
                    dashboards_reports.Name = adrc.Dashboards_Reports_Category__r.name;
                    dashboards_reports.pillar = adrc.Dashboards_Reports_Category__r.Pillar__c;
                    List<String> dashboardIds = new List<String>();
                    for(Dashboards_Category_Relationship__c dc: [select DashboardId__c from Dashboards_Category_Relationship__c where Dashboards_Reports_Category__c =: adrc.Dashboards_Reports_Category__c ]) {
                        dashboardIds.add(dc.DashboardId__c);
                    }
                    dashboards_reports.dashboards = new SLT_Dashboard().selectById(dashboardIds);
                    List<String> reportIds = new List<String>();
                    for(Reports_Category_Relationship__c rc: [select Report_Id__c from Reports_Category_Relationship__c where Dashboards_Reports_Category__c =: adrc.Dashboards_Reports_Category__c ]) {
                        reportIds.add(rc.Report_Id__c);
                    }
                    dashboards_reports.reports = new SLT_Report().selectById(reportIds);
                    List<PermissionSetAssignment> pa = Database.query('select Id from PermissionSetAssignment where AssigneeId = \''+users[0].Id +'\' and  PermissionSet.Name = \'CSM_Einstein_Analytic_for_Community\'');
                    if(pa != null && pa.size() >0) {
                        dashboards_reports.einsteins = new List<EinsteinWrapper>();
                        for(Einstein_Analytics_Category_Relationship__c ec: [select Einstein_Analytics_Id__c, Einstein_Analytics_Name__c, Einstein_Analytics_Description__c from Einstein_Analytics_Category_Relationship__c where Dashboards_Reports_Category__c =: adrc.Dashboards_Reports_Category__c and Id not in (select Einstein_Analytics_Category__c from Contact_Einstein_Category_Relationship__c)]) {
                            EinsteinWrapper ew = new EinsteinWrapper();
                            ew.id = ec.Einstein_Analytics_Id__c;
                            ew.name = ec.Einstein_Analytics_Name__c;
                            ew.description = ec.Einstein_Analytics_Description__c;
                            dashboards_reports.einsteins.add(ew);
                        }
                        for(Contact_Einstein_Category_Relationship__c cec: [select Einstein_Analytics_Category__r.Einstein_Analytics_Id__c, Einstein_Analytics_Category__r.Einstein_Analytics_Name__c, Einstein_Analytics_Category__r.Einstein_Analytics_Description__c from Contact_Einstein_Category_Relationship__c where Contact__c =:users[0].Contact.Id and Einstein_Analytics_Category__r.Dashboards_Reports_Category__c =: adrc.Dashboards_Reports_Category__c]) {
                            EinsteinWrapper ew = new EinsteinWrapper();
                            ew.id = cec.Einstein_Analytics_Category__r.Einstein_Analytics_Id__c;
                            ew.name = cec.Einstein_Analytics_Category__r.Einstein_Analytics_Name__c;
                            ew.description = cec.Einstein_Analytics_Category__r.Einstein_Analytics_Description__c;
                            dashboards_reports.einsteins.add(ew);
                        }
                    }
                    dashboards_reports_list.add(dashboards_reports);
                }
            }
        }
        return dashboards_reports_list;
    }*/

    /**
    * This method used to get  private Report
    * @return  List<Report>
    */
    @AuraEnabled
    public static List<Report> getPrivateReports(){
        List<Report> reports = new List<Report>();
        reports = new SLT_Report().selectPrivateReports(userInfo.getUserId());
        return reports;
    }
}
