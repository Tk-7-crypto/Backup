public with sharing class CNT_CRM_AnnualPerformanceChart {
    
    @AuraEnabled
    public static Map<String, Object> getMetaData(){
        Map<String, Object> returnMap = new Map<String, Object>();
        Annual_Performance_Chart__c ac = Annual_Performance_Chart__c.getInstance();
        List<String> stages =(List<String>) JSON.deserialize(ac.Opportunity_Stage_Selectced__c,List<String>.class);
        returnMap.put('goal', (Decimal)ac.Goal__c);
        returnMap.put('quater', (String)ac.Quater_Selected__c);
        returnMap.put('stages', stages);
        returnMap.put('CurrencyIsoCode', CON_CRM.USD);
        returnMap.put('label', ac.Opportunity_Stage_Selectced_Label__c);
        return returnMap;
    }

    @AuraEnabled
    public static void setMetaData(Decimal goal,String quater,String oppstageV,String oppstagel){
        Annual_Performance_Chart__c ac = Annual_Performance_Chart__c.getInstance(UserInfo.getUserId());
        ac.Opportunity_Stage_Selectced__c = oppstageV;
        ac.Opportunity_Stage_Selectced_Label__c= oppstagel;
        ac.Quater_Selected__c=quater;
        ac.Goal__c = goal;
        upsert ac;
    }
    
    @AuraEnabled
    public static Map<String, Object> getAllData(){
        Annual_Performance_Chart__c ac = Annual_Performance_Chart__c.getInstance();
        String QuaterSelected = ac.Quater_Selected__c;
        List<String> StagesSelected = (List<String>) JSON.deserialize(ac.Opportunity_Stage_Selectced__c,List<String>.class);
        List<String> openStages = StagesSelected;
        Decimal goal = ac.Goal__c;
        List<String> closeStages = new List<String>{'7a. Closed Won','In-Hand'};
        Map<String,Object> returnMap = new Map<String,Object>();
        List<chartData> openOppdata = new List<chartData>();
        List<chartData> closeOppdata = new List<chartData>();
        List<chartData> goalOppdata = new List<chartData>();
        Decimal totalClosedAmount = 0;
        Decimal totalOpenAmount = 0;
        Integer Year = System.Today().year();
        Date startDate;
        Date endDate;
        if(QuaterSelected == 'All' || QuaterSelected == null){
            startDate = Date.valueOf(year+'-01-01');
            endDate = Date.valueOf(year+'-12-31');
        }else  if(QuaterSelected == 'Q1'){
            startDate = Date.valueOf(year+'-01-01');
            endDate = Date.valueOf(year+'-03-31');
        }else  if(QuaterSelected == 'Q2'){
            startDate = Date.valueOf(year+'-04-01');
            endDate = Date.valueOf(year+'-06-30');
        }else  if(QuaterSelected == 'Q3'){
            startDate = Date.valueOf(year+'-07-01');
            endDate = Date.valueOf(year+'-09-30');
        }else  if(QuaterSelected == 'Q4'){
            startDate = Date.valueOf(year+'-10-01');
            endDate = Date.valueOf(year+'-12-31');
        }
        openOppdata.add(new chartData(startDate,0));
        String currentUserCurrency  = UserInfo.getDefaultCurrency();
        Map<String,CurrencyType> isoCodeToCurrencyType = new SLT_CurrencyType().getSelectedCurrencyTypeByIsoCodeAndActive(new Set<String>{currentUserCurrency});
        for(Opportunity opp:[SELECT Id,StageName,CloseDate, Amount FROM Opportunity WHERE Amount != null and OwnerId = :UserInfo.getUserId() and StageName IN :openStages and CloseDate >= :startDate and CloseDate <= :endDate Order by CloseDate]){
            if(isoCodeToCurrencyType.containsKey(currentUserCurrency)){
                totalOpenAmount = totalOpenAmount + (opp.Amount / (isoCodeToCurrencyType.get(currentUserCurrency).ConversionRate));
            }else{
                totalOpenAmount = totalOpenAmount + opp.Amount;
            }
            openOppdata.add(new chartData(opp.CloseDate,totalOpenAmount));
        }
        for(Opportunity opp:[SELECT Id,StageName,CloseDate, Amount FROM Opportunity WHERE Amount != null and OwnerId = :UserInfo.getUserId() and StageName IN :closeStages and Actual_Close_Date__c >= :startDate and Actual_Close_Date__c <= :endDate Order by CloseDate]){
            if(isoCodeToCurrencyType.containsKey(currentUserCurrency)){
                totalClosedAmount = totalClosedAmount + (opp.Amount / (isoCodeToCurrencyType.get(currentUserCurrency).ConversionRate));
            }else{
                totalClosedAmount = totalClosedAmount + opp.Amount;
            }
        }
        totalOpenAmount = totalOpenAmount.setScale(2);
        totalClosedAmount = totalClosedAmount.setScale(2);
        openOppdata.add(new chartData(endDate,totalOpenAmount));
        closeOppdata.add(new chartData(endDate,totalClosedAmount));
        closeOppdata.add(new chartData(startDate,totalClosedAmount));
        goalOppdata.add(new chartData(startDate,goal));
        goalOppdata.add(new chartData(endDate,goal));
        returnMap.put('totalClosedAmount',totalClosedAmount);
        returnMap.put('totalOpenAmount',totalOpenAmount);
        returnMap.put('openOppdata',openOppdata);
        returnMap.put('closeOppdata',closeOppdata);
        returnMap.put('goalOppdata',goalOppdata);
        returnMap.put('stageslabel',ac.Opportunity_Stage_Selectced_Label__c);
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