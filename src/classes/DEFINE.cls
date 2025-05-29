public class DEFINE {

    public static String default_pricebook2 = '標準価格表';
    
    //案件：フェーズ
    public static final String StNameIn = 'In-Hand';
    public static final String StName1 = '1. Identifying Opportunity';
    public static final String StName2 = '2. Qualifying Opportunity';
    public static final String StName3 = '3 - Understand Pre Proposal';
    public static final String StName4 = '4. Delivering Proposal';
    public static final String StName5 = '5. Finalizing Deal';
    public static final String StName6a = '7a. Closed Won';
    public static final String StName6b = '7b. Closed Lost';
    // Added by Dheeraj Kumar Issue-10661 
    public static final String stageBudget = 'Budget';
    
    //案件:上司のコミット
    public static final String JF01 = '01. Budget'; // @add 2009/01/09 Bridge R.Ueda
    public static final String JF02 = '02. Closed';
    public static final String JF03  = '03. Commit';
    public static final String JF04  = '04. Best Case';
    public static final String JF05  = '05. Pipeline';
    public static final String JFOM  = 'Omitted';
    
    // 案件:Accuracy__c @add 2009/01/09 Bridge R.Ueda
    public static final String ACCURACY_0 = 'Omit';
    public static final String ACCURACY_01 = '01.Budget';
    public static final String ACCURACY_01FDS = '01.Budget-FDS';
    public static final String ACCURACY_01OCL = '01.Budget-OCL';
    public static final String ACCURACY_01BL = '01.Budget-BL';
    public static final String ACCURACY_01JK = '01.Budget-JK';
    public static final String ACCURACY_01SMS = '01.Budget-SMS'; // @add 2011/04/01 R.Kutsuzawa
    public static final String ACCURACY_02 = '02.In Hand';
    public static final String ACCURACY_03 = '03.Secured';
    public static final String ACCURACY_04 = '04.Commit';
    public static final String ACCURACY_05 = '05.BestCase';
    public static final String ACCURACY_06 = '06.Pipeline';

    // 案件:BudgetType__c @add 2009/01/09 Bridge R.Ueda
    public static final String BUDGET_TYPE_FDS = 'FDS';
    public static final String BUDGET_TYPE_OCL = 'OCL';
    public static final String BUDGET_TYPE_BL = 'BL';
    public static final String BUDGET_TYPE_JKAM = 'JKAM';
    public static final String BUDGET_TYPE_SMS = 'SMS';

    
    public static boolean defineAction() {
        return true;
    }
    
  
}