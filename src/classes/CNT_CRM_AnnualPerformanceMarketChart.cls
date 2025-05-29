public with sharing class CNT_CRM_AnnualPerformanceMarketChart {
    
    @AuraEnabled
    public static Map<String, Object> getMetaData(){
        Map<String, Object> returnMap = new Map<String, Object>();
        Annual_Performance_Chart__c ac = Annual_Performance_Chart__c.getInstance();
        List<String> stages =(List<String>) JSON.deserialize(ac.Opportunity_Stage_Selectced__c,List<String>.class);
        returnMap.put('goal', (Decimal)ac.Goal_Marketing__c);
        returnMap.put('CurrencyIsoCode', CON_CRM.USD);
        return returnMap;
    }

    @AuraEnabled
    public static void setMetaData(Decimal goal,String quater,String oppstageV,String oppstagel){
        Annual_Performance_Chart__c ac = Annual_Performance_Chart__c.getInstance(UserInfo.getUserId());
        ac.Goal_Marketing__c = goal;
        upsert ac;
    }
    
    @AuraEnabled
    public static Map<String, Object> getAllData(){
        Annual_Performance_Chart__c ac = Annual_Performance_Chart__c.getInstance();
        String QuaterSelected = ac.Quater_Selected__c;
        Decimal goal = ac.Goal_Marketing__c;
        List<String> closeStages = new List<String>{'7a. Closed Won','In-Hand'};
        Map<String,Object> returnMap = new Map<String,Object>();
        List<chartData> closeOppdata = new List<chartData>();
        List<chartData> goalOppdata = new List<chartData>();
        Decimal totalClosedAmount = 0;
        Integer Year = System.Today().year();
        Date startDate;
        Date endDate;
        if(QuaterSelected == 'All' || QuaterSelected == null){
            startDate = Date.valueOf(year+'-01-01');
            endDate = Date.valueOf(year+'-12-31');
        }
        closeOppdata.add(new chartData(startDate,0));
        String currentUserCurrency  = UserInfo.getDefaultCurrency();
        Map<String,CurrencyType> isoCodeToCurrencyType = new SLT_CurrencyType().getSelectedCurrencyTypeByIsoCodeAndActive(new Set<String>{currentUserCurrency});
        for(Opportunity opp:[SELECT Id, StageName, CloseDate, Amount FROM Opportunity WHERE Amount != null and Inside_Sales_Transfer_Date__c != null and Inside_Sales__c = :UserInfo.getUserId() and StageName IN :closeStages and CloseDate >= :startDate and CloseDate <= :endDate Order by CloseDate]){
            if(isoCodeToCurrencyType.containsKey(currentUserCurrency)){
                totalClosedAmount = totalClosedAmount + (opp.Amount / (isoCodeToCurrencyType.get(currentUserCurrency).ConversionRate));
            }else{
                totalClosedAmount = totalClosedAmount + opp.Amount;
            }
            closeOppdata.add(new chartData(opp.CloseDate,totalClosedAmount));
        }

        totalClosedAmount = totalClosedAmount.setScale(2);
        closeOppdata.add(new chartData(endDate,totalClosedAmount));
        goalOppdata.add(new chartData(startDate,goal));
        goalOppdata.add(new chartData(endDate,goal));
        returnMap.put('totalClosedAmount',totalClosedAmount);
        returnMap.put('closeOppdata',closeOppdata);
        returnMap.put('goalOppdata',goalOppdata);
        return returnMap;
    }

    public class chartData{
        @AuraEnabled public Date t;
        @AuraEnabled public Decimal y;

        public chartData(Date dt,Decimal amt){
            this.y = amt;
            this.t = dt;
        }
    }
}