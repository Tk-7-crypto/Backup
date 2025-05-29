public class BCH_PSA_SendEmailsForAR implements Database.Batchable<sObject>, Database.Stateful{
    @TestVisible List<String> errorMessageList = new List <String>();
    private Date next3DayDate = System.today()+3;
    private Date tommorrowDate = System.today()+1;
    private String sandozRecordTypeId = CON_PSA.AGG_REPORT_TYPE_ID_SANDOZ;
    private static String accountName = '';
    private static String serviceMileStoneName = '';
    private static String reportType = '';
    private static String projectCode = '';
    private static String productName = '';
    private static String dataLockPoint = '';
    private static String staticContent = '';
    private static List<String> emailList;
    private static Workflow_Email_Record__c objWorkFlowEmail;
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'select Id, name, Project_Code__c, Planned_starting_date__c, Planned_Date_for_QC_Sent__c, '
            + 'Planned_Date_for_BRM_Sent__c, Planned_Date_for_Medical_Review_Sent__c, Plnnd_Date_for_Medical_Review_Cmpltn__c, '
            + 'Report_Due_to_IQVIA_or_Client_Reg__c, Planned_Date_to_Request_Draft_LL__c, Plnnd_Date_Draft_LL_to_Author_Client__c, '
            + 'PreStrategy_Planned_Date__c, Strategy_Planning_Mtg_Planned_Date__c, Pre_draft_QC_Review_Planned_date__c, '
            + 'Pre_draft_QC_due_date__c, Pre_draft_Client_Review_Planned_date__c, Planned_Date_for_QC_Completion__c, '
            + 'Pre_draft_Client_Review_due_date__c, Plnnd_Date_Final_LL_to_Author_Client__c, LL_Review_Due__c, Product_Name_Active_Ingredient_Name__c, '
            + 'LL_QC_Due_Date__c, Client_First_Draft_Due__c, Planned_First_Draft_Comments_Due__c, Account_Name__c, '
            + 'First_RTR_Planned_Date__c, Client_Final_Draft_Due__c, Planned_Final_Draft_Comments_Due__c, Report_Due_to_Reg_Agency__c, '
            + 'Second_RTR_Planned_Date__c, Planned_Independent_QC_Planned_date__c, Independent_QC_due_date__c, '
            + 'EU_QPPV_designee_review_Planned_date__c, EU_QPPV_designee_review_due_date__c, IQVIA_Planned_Date_for_Sign_Approval__c, ' 
            + 'Primary_Author__r.Email, Secondary_Author__r.Email, Primary_QC_Reviewer__r.Email, Secondary_QC_Reviewer__r.Email, '
            + 'Primary_BRM_Analyst__r.Email, Secondary_BRM_Analyst__r.Email, Primary_Medical_Reviewer__r.Email,Report_Type__c, '
            + 'Secondary_Medical_Reviewer__r.Email, Data_Lock_Point__c, Planned_Date_for_BRM_Completion__c,Service_Milestone__r.Name  '
            + 'FROM Aggregate_Report__c '
            + 'WHERE ( Planned_starting_date__c = NEXT_N_DAYS:3 '
            +' OR Planned_Date_for_QC_Sent__c = NEXT_N_DAYS:3 '
            +' OR Planned_Date_for_QC_Completion__c = NEXT_N_DAYS:3 '
            +' OR Planned_Date_for_BRM_Sent__c = NEXT_N_DAYS:3 '
            +' OR Planned_Date_for_Medical_Review_Sent__c = NEXT_N_DAYS:3 '
            +' OR Plnnd_Date_for_Medical_Review_Cmpltn__c = NEXT_N_DAYS:3 '
            +' OR Report_Due_to_IQVIA_or_Client_Reg__c = NEXT_N_DAYS:3 '
            +' OR Planned_Date_to_Request_Draft_LL__c = NEXT_N_DAYS:3 '
            +' OR Plnnd_Date_Draft_LL_to_Author_Client__c = NEXT_N_DAYS:3 '
            +' OR PreStrategy_Planned_Date__c = NEXT_N_DAYS:3 '
            +' OR Strategy_Planning_Mtg_Planned_Date__c = NEXT_N_DAYS:3 '
            +' OR Pre_draft_QC_Review_Planned_date__c = NEXT_N_DAYS:3 '
            +' OR Pre_draft_QC_due_date__c = NEXT_N_DAYS:3 '
            +' OR Pre_draft_Client_Review_Planned_date__c = NEXT_N_DAYS:3 '
            +' OR Pre_draft_Client_Review_due_date__c = NEXT_N_DAYS:3 '
            +' OR Plnnd_Date_Final_LL_to_Author_Client__c = NEXT_N_DAYS:3 '
            +' OR LL_Review_Due__c = NEXT_N_DAYS:3 '
            +' OR LL_QC_Due_Date__c = NEXT_N_DAYS:3 '
            +' OR Client_First_Draft_Due__c = NEXT_N_DAYS:3 '
            +' OR Planned_First_Draft_Comments_Due__c = NEXT_N_DAYS:3 '
            +' OR First_RTR_Planned_Date__c = NEXT_N_DAYS:3 '
            +' OR Client_Final_Draft_Due__c = NEXT_N_DAYS:3 '
            +' OR Planned_Final_Draft_Comments_Due__c = NEXT_N_DAYS:3 '
            +' OR Second_RTR_Planned_Date__c = NEXT_N_DAYS:3 '
            +' OR Planned_Independent_QC_Planned_date__c = NEXT_N_DAYS:3 '
            +' OR Independent_QC_due_date__c = NEXT_N_DAYS:3 '
            +' OR EU_QPPV_designee_review_Planned_date__c = NEXT_N_DAYS:3 '
            +' OR EU_QPPV_designee_review_due_date__c = NEXT_N_DAYS:3 '
            +' OR IQVIA_Planned_Date_for_Sign_Approval__c = NEXT_N_DAYS:3 '
            +' OR Report_Due_to_Reg_Agency__c = NEXT_N_DAYS:3'
            + ' ) '
            + ' AND ( Primary_Author__c != null '
            + ' OR Secondary_Author__c != null '
            + ' OR Primary_QC_Reviewer__c != null '
            + ' OR Secondary_QC_Reviewer__c != null '
            + ' OR Primary_BRM_Analyst__c != null '
            + ' OR Secondary_BRM_Analyst__c != null '
            + ' OR Primary_Medical_Reviewer__c != null '
            + ' OR Secondary_Medical_Reviewer__c != null) '
            + ' AND recordTypeId =: sandozRecordTypeId'
            + ' AND Status__c !=\'Completed\' ';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Aggregate_Report__c> records) {
        Set<Id> agReportIdSet = new Set<Id>();
        Set<String> objectNameAndFieldNameKeySet = new Set<String>();
        for(Aggregate_Report__c agReport : records){
            agReportIdSet.add(agReport.Id);
        }
        if(!agReportIdSet.isEmpty()){
            for(Workflow_Email_Record__c workflowRecord : [SELECT id, Related_To_Object_Id__c, Module_Name__c, Related_To_Object_Api__c
                                                           FROM Workflow_Email_Record__c
                                                           WHERE Module_Name__c = 'PSA'
                                                           AND Related_To_Object_Id__c IN :agReportIdSet
                                                           AND Related_To_Object_Api__c != null
                                                           AND createdDate = LAST_N_DAYS:2
                                                           AND Email_Action__c = :CON_PSA.AGGREGATE_REPORT_SEND_EMAIL_NOTIFICATION
                                                          ])
            {
                objectNameAndFieldNameKeySet.add(workflowRecord.Related_To_Object_Id__c+'-'+workflowRecord.Related_To_Object_Api__c);
            }
        }
        List<Workflow_Email_Record__c> workflowEmailRecordList = new List<Workflow_Email_Record__c>();
        Set<String> emailSet = new Set<String>();
        Set<String> primaryAndSecondaryEmailSet = new Set<String>();
        for(Aggregate_Report__c agReport : records){
            primaryAndSecondaryEmailSet.clear();
            if(agReport.Primary_Author__r.Email != null){
                primaryAndSecondaryEmailSet.add(agReport.Primary_Author__r.Email); 
            }
            if(agReport.Secondary_Author__r.Email != null){
                primaryAndSecondaryEmailSet.add(agReport.Secondary_Author__r.Email); 
            }
            if(!objectNameAndFieldNameKeySet.contains(agReport.Id+'-'+CON_PSA.PLANNED_STARTING_DATE)
               && agReport.Planned_starting_date__c != null 
               && agReport.Planned_starting_date__c <= next3DayDate 
               && agReport.Planned_starting_date__c >= tommorrowDate){
                   emailSet.clear();
                   if(!primaryAndSecondaryEmailSet.isEmpty()){
                       emailSet.addAll(primaryAndSecondaryEmailSet);
                   }
                   if(!emailSet.isEmpty()){
                       workflowEmailRecordList.add(createWorkflowEmailRecord(agReport, CON_PSA.PLANNED_STARTING_DATE, agReport.Planned_starting_date__c, emailSet));
                   }
               }
            if(!objectNameAndFieldNameKeySet.contains(agReport.Id+'-'+CON_PSA.PLANNED_DATE_FOR_QC_SENT)
               && agReport.Planned_Date_for_QC_Sent__c != null 
               && agReport.Planned_Date_for_QC_Sent__c <= next3DayDate 
               && agReport.Planned_Date_for_QC_Sent__c >= tommorrowDate){
                   emailSet.clear();
                   if(!primaryAndSecondaryEmailSet.isEmpty()){
                       emailSet.addAll(primaryAndSecondaryEmailSet);
                   }
                   if(agReport.Primary_QC_Reviewer__r.Email != null){
                       emailSet.add(agReport.Primary_QC_Reviewer__r.Email); 
                   }
                   if(agReport.Secondary_QC_Reviewer__r.Email != null){
                       emailSet.add(agReport.Secondary_QC_Reviewer__r.Email); 
                   }
                   if(!emailSet.isEmpty()){
                       workflowEmailRecordList.add(createWorkflowEmailRecord(agReport, CON_PSA.PLANNED_DATE_FOR_QC_SENT, agReport.Planned_Date_for_QC_Sent__c, emailSet));
                   }
               }
            if(!objectNameAndFieldNameKeySet.contains(agReport.Id+'-'+CON_PSA.PLANNED_DATE_FOR_QC_COMPLETION) 
               && agReport.Planned_Date_for_QC_Completion__c != null 
               && agReport.Planned_Date_for_QC_Completion__c <= next3DayDate 
               && agReport.Planned_Date_for_QC_Completion__c >= tommorrowDate){
                   emailSet.clear();
                   if(!primaryAndSecondaryEmailSet.isEmpty()){
                       emailSet.addAll(primaryAndSecondaryEmailSet);
                   }
                   if(agReport.Primary_QC_Reviewer__r.Email != null){
                       emailSet.add(agReport.Primary_QC_Reviewer__r.Email); 
                   }
                   if(agReport.Secondary_QC_Reviewer__r.Email != null){
                       emailSet.add(agReport.Secondary_QC_Reviewer__r.Email); 
                   }
                   if(!emailSet.isEmpty()){
                       workflowEmailRecordList.add(createWorkflowEmailRecord(agReport, CON_PSA.PLANNED_DATE_FOR_QC_COMPLETION, agReport.Planned_Date_for_QC_Completion__c, emailSet));
                   }
               }
            if(!objectNameAndFieldNameKeySet.contains(agReport.Id+'-'+CON_PSA.PLANNED_DATE_FOR_BRM_SENT)
               && agReport.Planned_Date_for_BRM_Sent__c != null 
               && agReport.Planned_Date_for_BRM_Sent__c <= next3DayDate 
               && agReport.Planned_Date_for_BRM_Sent__c >= tommorrowDate ){
                   emailSet.clear();
                   if(!primaryAndSecondaryEmailSet.isEmpty()){
                       emailSet.addAll(primaryAndSecondaryEmailSet);
                   }
                   if(agReport.Primary_BRM_Analyst__r.Email != null){
                       emailSet.add(agReport.Primary_BRM_Analyst__r.Email); 
                   }
                   if(agReport.Secondary_BRM_Analyst__r.Email != null){
                       emailSet.add(agReport.Secondary_BRM_Analyst__r.Email); 
                   }
                   if(!emailSet.isEmpty()){
                       workflowEmailRecordList.add(createWorkflowEmailRecord(agReport, CON_PSA.PLANNED_DATE_FOR_BRM_SENT, agReport.Planned_Date_for_BRM_Sent__c, emailSet));
                   }
               }
            if(!objectNameAndFieldNameKeySet.contains(agReport.Id+'-'+CON_PSA.PLANNED_DATE_FOR_BRM_COMPLETION)
               && agReport.Planned_Date_for_BRM_Completion__c != null 
               && agReport.Planned_Date_for_BRM_Completion__c <= next3DayDate 
               && agReport.Planned_Date_for_BRM_Completion__c >= tommorrowDate){
                   emailSet.clear();
                   if(!primaryAndSecondaryEmailSet.isEmpty()){
                       emailSet.addAll(primaryAndSecondaryEmailSet);
                   }
                   if(agReport.Primary_BRM_Analyst__r.Email != null){
                       emailSet.add(agReport.Primary_BRM_Analyst__r.Email); 
                   }
                   if(agReport.Secondary_BRM_Analyst__r.Email != null){
                       emailSet.add(agReport.Secondary_BRM_Analyst__r.Email); 
                   }
                   if(!emailSet.isEmpty()){
                       workflowEmailRecordList.add(createWorkflowEmailRecord(agReport, CON_PSA.PLANNED_DATE_FOR_BRM_COMPLETION, agReport.Planned_Date_for_BRM_Completion__c, emailSet));
                   }
               }
            if(!objectNameAndFieldNameKeySet.contains(agReport.Id+'-'+CON_PSA.PLANNED_DATE_FOR_MEDICAL_REVIEW_SENT)
               && agReport.Planned_Date_for_Medical_Review_Sent__c != null 
               && agReport.Planned_Date_for_Medical_Review_Sent__c <= next3DayDate 
               && agReport.Planned_Date_for_Medical_Review_Sent__c >= tommorrowDate){
                   emailSet.clear();
                   if(!primaryAndSecondaryEmailSet.isEmpty()){
                       emailSet.addAll(primaryAndSecondaryEmailSet);
                   }
                   if(agReport.Primary_Medical_Reviewer__r.Email != null){
                       emailSet.add(agReport.Primary_Medical_Reviewer__r.Email); 
                   }
                   if(agReport.Secondary_Medical_Reviewer__r.Email != null){
                       emailSet.add(agReport.Secondary_Medical_Reviewer__r.Email); 
                   }
                   if(!emailSet.isEmpty()){
                       workflowEmailRecordList.add(createWorkflowEmailRecord(agReport, CON_PSA.PLANNED_DATE_FOR_MEDICAL_REVIEW_SENT, agReport.Planned_Date_for_Medical_Review_Sent__c, emailSet));
                   }
               }
            if(!objectNameAndFieldNameKeySet.contains(agReport.Id+'-'+CON_PSA.PLANNED_DATE_FOR_MEDICAL_REVIEW_COMPLETION)
               && agReport.Plnnd_Date_for_Medical_Review_Cmpltn__c != null 
               && agReport.Plnnd_Date_for_Medical_Review_Cmpltn__c <= next3DayDate 
               && agReport.Plnnd_Date_for_Medical_Review_Cmpltn__c >= tommorrowDate){
                   emailSet.clear();
                   if(!primaryAndSecondaryEmailSet.isEmpty()){
                       emailSet.addAll(primaryAndSecondaryEmailSet);
                   }
                   if(!emailSet.isEmpty()){   
                       workflowEmailRecordList.add(createWorkflowEmailRecord(agReport, CON_PSA.PLANNED_DATE_FOR_MEDICAL_REVIEW_COMPLETION, agReport.Plnnd_Date_for_Medical_Review_Cmpltn__c, emailSet));
                   }
               }
            if(!objectNameAndFieldNameKeySet.contains(agReport.Id+'-'+CON_PSA.REPORT_DUE_TO_IQVIA_OR_CLIENT_REG)
               && agReport.Report_Due_to_IQVIA_or_Client_Reg__c != null 
               && agReport.Report_Due_to_IQVIA_or_Client_Reg__c <= next3DayDate 
               && agReport.Report_Due_to_IQVIA_or_Client_Reg__c >= tommorrowDate){
                   emailSet.clear();
                   if(!primaryAndSecondaryEmailSet.isEmpty()){
                       emailSet.addAll(primaryAndSecondaryEmailSet);
                   }
                   if(!emailSet.isEmpty()){
                       workflowEmailRecordList.add(createWorkflowEmailRecord(agReport, CON_PSA.REPORT_DUE_TO_IQVIA_OR_CLIENT_REG, agReport.Report_Due_to_IQVIA_or_Client_Reg__c, emailSet));
                   }
               }
            if(!objectNameAndFieldNameKeySet.contains(agReport.Id+'-'+CON_PSA.PLANNED_DATE_TO_REQUEST_DRAFT_LL)
               && agReport.Planned_Date_to_Request_Draft_LL__c != null 
               && agReport.Planned_Date_to_Request_Draft_LL__c <= next3DayDate 
               && agReport.Planned_Date_to_Request_Draft_LL__c >= tommorrowDate){
                   emailSet.clear();
                   if(!primaryAndSecondaryEmailSet.isEmpty()){
                       emailSet.addAll(primaryAndSecondaryEmailSet);
                   }
                   if(!emailSet.isEmpty()){
                       workflowEmailRecordList.add(createWorkflowEmailRecord(agReport, CON_PSA.PLANNED_DATE_TO_REQUEST_DRAFT_LL, agReport.Planned_Date_to_Request_Draft_LL__c, emailSet));
                   }
               }
            if(!objectNameAndFieldNameKeySet.contains(agReport.Id+'-'+CON_PSA.PLANNED_DATE_DRAFT_LL_TO_AUTHOR_CLIENT)
               && agReport.Plnnd_Date_Draft_LL_to_Author_Client__c != null 
               && agReport.Plnnd_Date_Draft_LL_to_Author_Client__c <= next3DayDate 
               && agReport.Plnnd_Date_Draft_LL_to_Author_Client__c >= tommorrowDate){
                   emailSet.clear();
                   if(!primaryAndSecondaryEmailSet.isEmpty()){
                       emailSet.addAll(primaryAndSecondaryEmailSet);
                   }
                   if(!emailSet.isEmpty()){
                       workflowEmailRecordList.add(createWorkflowEmailRecord(agReport, CON_PSA.PLANNED_DATE_DRAFT_LL_TO_AUTHOR_CLIENT, agReport.Plnnd_Date_Draft_LL_to_Author_Client__c, emailSet));
                   }
               }
            if(!objectNameAndFieldNameKeySet.contains(agReport.Id+'-'+CON_PSA.PRE_STRATRGY_PLANNED_DATE)
               && agReport.PreStrategy_Planned_Date__c != null 
               && agReport.PreStrategy_Planned_Date__c <= next3DayDate 
               && agReport.PreStrategy_Planned_Date__c >= tommorrowDate){
                   emailSet.clear();
                   if(!primaryAndSecondaryEmailSet.isEmpty()){
                       emailSet.addAll(primaryAndSecondaryEmailSet);
                   }
                   if(!emailSet.isEmpty()){
                       workflowEmailRecordList.add(createWorkflowEmailRecord(agReport, CON_PSA.PRE_STRATRGY_PLANNED_DATE, agReport.PreStrategy_Planned_Date__c, emailSet));
                   }
               }
            if(!objectNameAndFieldNameKeySet.contains(agReport.Id+'-'+CON_PSA.STRATRGY_PLANNING_MTG_PLANNED_DATE)
               && agReport.Strategy_Planning_Mtg_Planned_Date__c != null 
               && agReport.Strategy_Planning_Mtg_Planned_Date__c <= next3DayDate 
               && agReport.Strategy_Planning_Mtg_Planned_Date__c >= tommorrowDate){
                   emailSet.clear();
                   if(!primaryAndSecondaryEmailSet.isEmpty()){
                       emailSet.addAll(primaryAndSecondaryEmailSet);
                   }
                   if(!emailSet.isEmpty()){
                       workflowEmailRecordList.add(createWorkflowEmailRecord(agReport, CON_PSA.STRATRGY_PLANNING_MTG_PLANNED_DATE, agReport.Strategy_Planning_Mtg_Planned_Date__c, emailSet));
                   }
               }
            if(!objectNameAndFieldNameKeySet.contains(agReport.Id+'-'+CON_PSA.PRE_DRAFT_QC_REVIEW_PLANNED_DATE)
               && agReport.Pre_draft_QC_Review_Planned_date__c != null 
               && agReport.Pre_draft_QC_Review_Planned_date__c <= next3DayDate 
               && agReport.Pre_draft_QC_Review_Planned_date__c >= tommorrowDate){
                   emailSet.clear();
                   if(!primaryAndSecondaryEmailSet.isEmpty()){
                       emailSet.addAll(primaryAndSecondaryEmailSet);
                   }
                   if(agReport.Primary_QC_Reviewer__r.Email != null){
                       emailSet.add(agReport.Primary_QC_Reviewer__r.Email); 
                   }
                   if(agReport.Secondary_QC_Reviewer__r.Email != null){
                       emailSet.add(agReport.Secondary_QC_Reviewer__r.Email); 
                   }
                   if(!emailSet.isEmpty()){
                       workflowEmailRecordList.add(createWorkflowEmailRecord(agReport, CON_PSA.PRE_DRAFT_QC_REVIEW_PLANNED_DATE, agReport.Pre_draft_QC_Review_Planned_date__c, emailSet));
                   }
               }
            if(!objectNameAndFieldNameKeySet.contains(agReport.Id+'-'+CON_PSA.PRE_DRAFT_QC_DUE_DATE)
               && agReport.Pre_draft_QC_due_date__c != null 
               && agReport.Pre_draft_QC_due_date__c <= next3DayDate 
               && agReport.Pre_draft_QC_due_date__c >= tommorrowDate){
                   emailSet.clear();
                   if(!primaryAndSecondaryEmailSet.isEmpty()){
                       emailSet.addAll(primaryAndSecondaryEmailSet);
                   }
                   if(agReport.Primary_QC_Reviewer__r.Email != null){
                       emailSet.add(agReport.Primary_QC_Reviewer__r.Email); 
                   }
                   if(agReport.Secondary_QC_Reviewer__r.Email != null){
                       emailSet.add(agReport.Secondary_QC_Reviewer__r.Email); 
                   }
                   if(!emailSet.isEmpty()){
                       workflowEmailRecordList.add(createWorkflowEmailRecord(agReport, CON_PSA.PRE_DRAFT_QC_DUE_DATE, agReport.Pre_draft_QC_due_date__c, emailSet));
                   }
               }
            if(!objectNameAndFieldNameKeySet.contains(agReport.Id+'-'+CON_PSA.PRE_DRAFT_CLIENT_REVIEW_PLANNED_DATE)
               && agReport.Pre_draft_Client_Review_Planned_date__c != null 
               && agReport.Pre_draft_Client_Review_Planned_date__c <= next3DayDate 
               && agReport.Pre_draft_Client_Review_Planned_date__c >= tommorrowDate){
                   emailSet.clear();
                   if(!primaryAndSecondaryEmailSet.isEmpty()){
                       emailSet.addAll(primaryAndSecondaryEmailSet);
                   }
                   if(!emailSet.isEmpty()){
                       workflowEmailRecordList.add(createWorkflowEmailRecord(agReport, CON_PSA.PRE_DRAFT_CLIENT_REVIEW_PLANNED_DATE, agReport.Pre_draft_Client_Review_Planned_date__c, emailSet));
                   }
               }
            if(!objectNameAndFieldNameKeySet.contains(agReport.Id+'-'+CON_PSA.PRE_DRAFT_CLIENT_REVIEW_DUE_DATE)
               && agReport.Pre_draft_Client_Review_due_date__c != null 
               && agReport.Pre_draft_Client_Review_due_date__c <= next3DayDate 
               && agReport.Pre_draft_Client_Review_due_date__c >= tommorrowDate){
                   emailSet.clear();
                   if(!primaryAndSecondaryEmailSet.isEmpty()){
                       emailSet.addAll(primaryAndSecondaryEmailSet);
                   }
                   if(!emailSet.isEmpty()){
                       workflowEmailRecordList.add(createWorkflowEmailRecord(agReport, CON_PSA.PRE_DRAFT_CLIENT_REVIEW_DUE_DATE, agReport.Pre_draft_Client_Review_due_date__c, emailSet));
                   }
               }
            if(!objectNameAndFieldNameKeySet.contains(agReport.Id+'-'+CON_PSA.PLANNED_DATE_FINAL_LL_TO_AUTHOR_CLIENT)
               && agReport.Plnnd_Date_Final_LL_to_Author_Client__c != null 
               && agReport.Plnnd_Date_Final_LL_to_Author_Client__c <= next3DayDate 
               && agReport.Plnnd_Date_Final_LL_to_Author_Client__c >= tommorrowDate){
                   emailSet.clear();
                   if(!primaryAndSecondaryEmailSet.isEmpty()){
                       emailSet.addAll(primaryAndSecondaryEmailSet);
                   }
                   if(!emailSet.isEmpty()){
                       workflowEmailRecordList.add(createWorkflowEmailRecord(agReport, CON_PSA.PLANNED_DATE_FINAL_LL_TO_AUTHOR_CLIENT, agReport.Plnnd_Date_Final_LL_to_Author_Client__c, emailSet));
                   }
               }
            if(!objectNameAndFieldNameKeySet.contains(agReport.Id+'-'+CON_PSA.LL_REVIEW_DUE) 
               && agReport.LL_Review_Due__c != null 
               && agReport.LL_Review_Due__c <= next3DayDate 
               && agReport.LL_Review_Due__c >= tommorrowDate){
                   emailSet.clear();
                   if(!primaryAndSecondaryEmailSet.isEmpty()){
                       emailSet.addAll(primaryAndSecondaryEmailSet);
                   }
                   if(!emailSet.isEmpty()){
                       workflowEmailRecordList.add(createWorkflowEmailRecord(agReport, CON_PSA.LL_REVIEW_DUE, agReport.LL_Review_Due__c, emailSet));
                   }
               }
            if(!objectNameAndFieldNameKeySet.contains(agReport.Id+'-'+CON_PSA.LL_QC_DUE_DATE)
               && agReport.LL_QC_Due_Date__c != null 
               && agReport.LL_QC_Due_Date__c <= next3DayDate 
               && agReport.LL_QC_Due_Date__c >= tommorrowDate){
                   emailSet.clear();
                   if(!primaryAndSecondaryEmailSet.isEmpty()){
                       emailSet.addAll(primaryAndSecondaryEmailSet);
                   }
                   if(!emailSet.isEmpty()){
                       workflowEmailRecordList.add(createWorkflowEmailRecord(agReport, CON_PSA.LL_QC_DUE_DATE, agReport.LL_QC_Due_Date__c, emailSet));
                   }
               }
            if(!objectNameAndFieldNameKeySet.contains(agReport.Id+'-'+CON_PSA.CLIENT_FIRST_DRAFT_DUE)
               && agReport.Client_First_Draft_Due__c != null 
               && agReport.Client_First_Draft_Due__c <= next3DayDate 
               && agReport.Client_First_Draft_Due__c >= tommorrowDate){
                   emailSet.clear();
                   if(!primaryAndSecondaryEmailSet.isEmpty()){
                       emailSet.addAll(primaryAndSecondaryEmailSet);
                   }
                   if(!emailSet.isEmpty()){
                       workflowEmailRecordList.add(createWorkflowEmailRecord(agReport, CON_PSA.CLIENT_FIRST_DRAFT_DUE, agReport.Client_First_Draft_Due__c, emailSet));
                   }
               }
            if(!objectNameAndFieldNameKeySet.contains(agReport.Id+'-'+CON_PSA.PLANNED_FIRST_DRAFT_COMMENTS_DUE)
               && agReport.Planned_First_Draft_Comments_Due__c != null 
               && agReport.Planned_First_Draft_Comments_Due__c <= next3DayDate 
               && agReport.Planned_First_Draft_Comments_Due__c >= tommorrowDate){
                   emailSet.clear();
                   if(!primaryAndSecondaryEmailSet.isEmpty()){
                       emailSet.addAll(primaryAndSecondaryEmailSet);
                   }
                   if(!emailSet.isEmpty()){
                       workflowEmailRecordList.add(createWorkflowEmailRecord(agReport, CON_PSA.PLANNED_FIRST_DRAFT_COMMENTS_DUE, agReport.Planned_First_Draft_Comments_Due__c, emailSet));
                   }
               }
            if(!objectNameAndFieldNameKeySet.contains(agReport.Id+'-'+CON_PSA.FIRST_RTR_PLANNED_DATE)
               && agReport.First_RTR_Planned_Date__c != null 
               && agReport.First_RTR_Planned_Date__c <= next3DayDate 
               && agReport.First_RTR_Planned_Date__c >= tommorrowDate){
                   emailSet.clear();
                   if(!primaryAndSecondaryEmailSet.isEmpty()){
                       emailSet.addAll(primaryAndSecondaryEmailSet);
                   }
                   if(!emailSet.isEmpty()){
                       workflowEmailRecordList.add(createWorkflowEmailRecord(agReport, CON_PSA.FIRST_RTR_PLANNED_DATE, agReport.First_RTR_Planned_Date__c, emailSet));
                   }
               }
            if(!objectNameAndFieldNameKeySet.contains(agReport.Id+'-'+CON_PSA.CLIENT_FINAL_DRAFT_DUE)
               && agReport.Client_Final_Draft_Due__c != null 
               && agReport.Client_Final_Draft_Due__c <= next3DayDate
               && agReport.Client_Final_Draft_Due__c >= tommorrowDate){
                   emailSet.clear();
                   if(!primaryAndSecondaryEmailSet.isEmpty()){
                       emailSet.addAll(primaryAndSecondaryEmailSet);
                   }
                   if(!emailSet.isEmpty()){
                       workflowEmailRecordList.add(createWorkflowEmailRecord(agReport, CON_PSA.CLIENT_FINAL_DRAFT_DUE, agReport.Client_Final_Draft_Due__c, emailSet));
                   }
               }
            if(!objectNameAndFieldNameKeySet.contains(agReport.Id+'-'+CON_PSA.PLANNED_FINAL_DRAFT_COMMENTS_DUE)
               && agReport.Planned_Final_Draft_Comments_Due__c != null 
               && agReport.Planned_Final_Draft_Comments_Due__c <= next3DayDate 
               && agReport.Planned_Final_Draft_Comments_Due__c >= tommorrowDate){
                   emailSet.clear();
                   if(!primaryAndSecondaryEmailSet.isEmpty()){
                       emailSet.addAll(primaryAndSecondaryEmailSet);
                   }
                   if(!emailSet.isEmpty()){
                       workflowEmailRecordList.add(createWorkflowEmailRecord(agReport, CON_PSA.PLANNED_FINAL_DRAFT_COMMENTS_DUE, agReport.Planned_Final_Draft_Comments_Due__c, emailSet));
                   }
               }
            if(!objectNameAndFieldNameKeySet.contains(agReport.Id+'-'+CON_PSA.SECOND_RTR_PLANNED_DATE)
               && agReport.Second_RTR_Planned_Date__c != null 
               && agReport.Second_RTR_Planned_Date__c <= next3DayDate 
               && agReport.Second_RTR_Planned_Date__c >= tommorrowDate){
                   emailSet.clear();
                   if(!primaryAndSecondaryEmailSet.isEmpty()){
                       emailSet.addAll(primaryAndSecondaryEmailSet);
                   }
                   if(!emailSet.isEmpty()){
                       workflowEmailRecordList.add(createWorkflowEmailRecord(agReport, CON_PSA.SECOND_RTR_PLANNED_DATE, agReport.Second_RTR_Planned_Date__c, emailSet));
                   }
               }
            if(!objectNameAndFieldNameKeySet.contains(agReport.Id+'-'+CON_PSA.INDEPENDENT_QC_PLANNED_DATE)
               && agReport.Planned_Independent_QC_Planned_date__c != null 
               && agReport.Planned_Independent_QC_Planned_date__c <= next3DayDate 
               && agReport.Planned_Independent_QC_Planned_date__c >= tommorrowDate){
                   emailSet.clear();
                   if(!primaryAndSecondaryEmailSet.isEmpty()){
                       emailSet.addAll(primaryAndSecondaryEmailSet);
                   }
                   if(!emailSet.isEmpty()){
                       workflowEmailRecordList.add(createWorkflowEmailRecord(agReport, CON_PSA.INDEPENDENT_QC_PLANNED_DATE, agReport.Planned_Independent_QC_Planned_date__c, emailSet));
                   }
               }
            if(!objectNameAndFieldNameKeySet.contains(agReport.Id+'-'+CON_PSA.INDEPENDENT_QC_DUE_DATE)
               && agReport.Independent_QC_due_date__c != null 
               && agReport.Independent_QC_due_date__c <= next3DayDate 
               && agReport.Independent_QC_due_date__c >= tommorrowDate){
                   emailSet.clear();
                   if(!primaryAndSecondaryEmailSet.isEmpty()){
                       emailSet.addAll(primaryAndSecondaryEmailSet);
                   }
                   if(!emailSet.isEmpty()){
                       workflowEmailRecordList.add(createWorkflowEmailRecord(agReport, CON_PSA.INDEPENDENT_QC_DUE_DATE, agReport.Independent_QC_due_date__c, emailSet));
                   }
               }
            if(!objectNameAndFieldNameKeySet.contains(agReport.Id+'-'+CON_PSA.EU_QPPV_DESIGNEE_REVIEW_PLANNED_DATE)
               && agReport.EU_QPPV_designee_review_Planned_date__c != null 
               && agReport.EU_QPPV_designee_review_Planned_date__c <= next3DayDate 
               && agReport.EU_QPPV_designee_review_Planned_date__c >= tommorrowDate){
                   emailSet.clear();
                   if(!primaryAndSecondaryEmailSet.isEmpty()){
                       emailSet.addAll(primaryAndSecondaryEmailSet);
                   }
                   if(!emailSet.isEmpty()){
                       workflowEmailRecordList.add(createWorkflowEmailRecord(agReport, CON_PSA.EU_QPPV_DESIGNEE_REVIEW_PLANNED_DATE, agReport.EU_QPPV_designee_review_Planned_date__c, emailSet));
                   }
               }
            if(!objectNameAndFieldNameKeySet.contains(agReport.Id+'-'+CON_PSA.EU_QPPV_DESIGNEE_REVIEW_DUE_DATE)
               && agReport.EU_QPPV_designee_review_due_date__c != null 
               && agReport.EU_QPPV_designee_review_due_date__c <= next3DayDate 
               && agReport.EU_QPPV_designee_review_due_date__c >= tommorrowDate){
                   emailSet.clear();
                   if(!primaryAndSecondaryEmailSet.isEmpty()){
                       emailSet.addAll(primaryAndSecondaryEmailSet);
                   }
                   if(!emailSet.isEmpty()){
                       workflowEmailRecordList.add(createWorkflowEmailRecord(agReport, CON_PSA.EU_QPPV_DESIGNEE_REVIEW_DUE_DATE, agReport.EU_QPPV_designee_review_due_date__c, emailSet));
                   }
               }
            if(!objectNameAndFieldNameKeySet.contains(agReport.Id+'-'+CON_PSA.IQVIA_PLANNED_DATE_FOR_SIGN_APPROVAL) 
               && agReport.IQVIA_Planned_Date_for_Sign_Approval__c != null 
               && agReport.IQVIA_Planned_Date_for_Sign_Approval__c <= next3DayDate 
               && agReport.IQVIA_Planned_Date_for_Sign_Approval__c >= tommorrowDate){
                   emailSet.clear();
                   if(!primaryAndSecondaryEmailSet.isEmpty()){
                       emailSet.addAll(primaryAndSecondaryEmailSet);
                   }
                   if(!emailSet.isEmpty()){
                       workflowEmailRecordList.add(createWorkflowEmailRecord(agReport, CON_PSA.IQVIA_PLANNED_DATE_FOR_SIGN_APPROVAL, agReport.IQVIA_Planned_Date_for_Sign_Approval__c, emailSet));
                   }
               }
            if(!objectNameAndFieldNameKeySet.contains(agReport.Id+'-'+CON_PSA.REPORT_DUE_TO_REG_AGENCY)
               && agReport.Report_Due_to_Reg_Agency__c != null 
               && agReport.Report_Due_to_Reg_Agency__c <= next3DayDate 
               && agReport.Report_Due_to_Reg_Agency__c >= tommorrowDate){
                   emailSet.clear();
                   if(!primaryAndSecondaryEmailSet.isEmpty()){
                       emailSet.addAll(primaryAndSecondaryEmailSet);
                   }
                   if(!emailSet.isEmpty()){
                       workflowEmailRecordList.add(createWorkflowEmailRecord(agReport, CON_PSA.REPORT_DUE_TO_REG_AGENCY, agReport.Report_Due_to_Reg_Agency__c, emailSet)); 
                   }
               }
        }
        if(!workflowEmailRecordList.isEmpty()){
            Database.SaveResult[] results = Database.insert(workflowEmailRecordList, false);
            if (results.size() > 0){
                for (Integer i = 0 ; i < results.size(); i ++){
                    if (!results[i].isSuccess()){
                        errorMessageList.add('Errors : ' + results[i].getErrors()[0].getMessage());
                    }
                }
            }
        }
    }
    public static Workflow_Email_Record__c createWorkflowEmailRecord(Aggregate_Report__c agReport, String fieldLabelName, Date dueDate, Set<String> emailSet){
        staticContent = '';
        emailList = new List<String>(emailSet);
        objWorkFlowEmail = new Workflow_Email_Record__c();
        objWorkFlowEmail.Email_Action__c = CON_PSA.AGGREGATE_REPORT_SEND_EMAIL_NOTIFICATION;
        objWorkFlowEmail.Module_Name__c = CON_PSA.PSA_MODULE_NAME;
        objWorkFlowEmail.Related_To_Object_Id__c = agReport.Id;
        objWorkFlowEmail.Related_To_Object_Api__c = fieldLabelName;
        accountName = agReport.Account_Name__c != null ? agReport.Account_Name__c : '';
        projectCode = agReport.Project_Code__c != null ? agReport.Project_Code__c : '';
        serviceMileStoneName = agReport.Service_Milestone__r.Name != null ? agReport.Service_Milestone__r.Name : '';
        reportType = agReport.Report_Type__c != null ? agReport.Report_Type__c : '';
        productName = agReport.Product_Name_Active_Ingredient_Name__c != null ? agReport.Product_Name_Active_Ingredient_Name__c : '';
        dataLockPoint = agReport.Data_Lock_Point__c != null ? String.valueOf(agReport.Data_Lock_Point__c) : '';
        objWorkFlowEmail.Email_Subject__c = 'Upcoming DUE DATE ALERT: '+accountName +' - '+projectCode+' - Report: ' + agReport.Name + ' - ' + fieldLabelName;
        staticContent = '<div style="background-color=white;text-align=left;font-size:12pt;font-family:arial"><p>This is a notification for the upcoming activity as per the details below:</p>';                    
        staticContent += '<B> Client: </B>' + accountName + '<br>';
        staticContent += '<B> Project Code: </B>' + projectCode + '<br>';
        staticContent += '<B> Report Type : </B>' + reportType + '<br>';
        staticContent += '<B> Service milestone : </B>' + serviceMileStoneName + '<br>';
        staticContent += '<B> Report: </B><a href = ' + System.URL.getOrgDomainURL().toExternalForm() + '/' + agReport.Id + '><B>' + agReport.Name + '</B></a><br>';
        staticContent += '<B> Event Name: </B>' + fieldLabelName + '<br>';
        staticContent += '<B> Due Date: </B>' + dueDate + '<br>';
        staticContent += '<B> Data Lock point: </B>' + dataLockPoint + '<br>';
        staticContent += '<B> Product Name: </B>' + productName + '<br>';
        staticContent += '</div>';
        objWorkFlowEmail.content_1__c = staticContent;
        for(Integer i = 1 ; i <= emailList.size() ; i++){
            objWorkFlowEmail.put('To_Email_' + i + '__c', emailList[i - 1]);
        }
        return objWorkFlowEmail;
    }
    
    public void finish(Database.BatchableContext BContext){
        String errorList = '';
        Integer counter = 0;
        if (errorMessageList.size() > 0 || Test.isRunningTest()){
            for(String errMsg : errorMessageList){
                UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, errMsg, 'PSA', 'Exception', 'ERROR', ':::BCH_PSA_SendEmailsForAR:::objWorkFlowEmail Insert Exception', null));
                UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), False);
                errorList += ++counter+'. '+ 'Error'+'----> ';
                errorList += errMsg+'<br><br>  ';
            }
            
            PSA_RDS_Settings__c rdsSettings= PSA_RDS_Settings__c.getOrgDefaults();
            if(rdsSettings.LR_failed_batches_email_ids__c != null){                    
                String userName = System.UserInfo.getName();
                List<String> toAddr = rdsSettings.AR_Failed_Batches_Email_Ids__c.split(';');
                if(!toAddr.isEmpty()){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(toAddr);
                    mail.setSubject('BATCH FAILURE: Salesforce PSA(DSSR) Setup Email Notification template for Sandoz record type functionality Batch execution error.  - '+System.today());
                    String emailBody = 'Dear User, <br><br>';
                    emailBody += 'This is to notify you that a batch execution has failed. Please find the details regarding this below:<br><br>';
                    emailBody += '<b>Batch Name:</b> BCH_PSA_SendEmailsForAR <br>';
                    emailBody += '<b>Time of execution:</b> ' + System.now() + '<br>';
                    emailBody += '<b>Execution user:</b> ' + userName + '<br>';
                    emailBody += '<b>Completion status:</b> Failed <br>';
                    emailBody += '<b>Error Description:</b> ' + errorList;
                    emailBody += 'Thank you.';
                    mail.setHtmlBody(emailBody);
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                }
            }  
        }
    } 
}
