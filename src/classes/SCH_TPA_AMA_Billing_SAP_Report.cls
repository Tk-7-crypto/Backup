/*
*@Author  : Supriya Johari
*@Purpose : Create a schedular a batch class(TPA_Batch_AMA_Billing_SAP_Report )
*@Date    : 19 august 2016 ER-2916
*/

global class SCH_TPA_AMA_Billing_SAP_Report implements Schedulable {
    global void execute(SchedulableContext sc) {
        BCH_TPA_AMA_Billing_SAP_Report agrmntsUpdate= new BCH_TPA_AMA_Billing_SAP_Report();
        agrmntsUpdate.includebusinessDataOnly = true;
        Database.executebatch(agrmntsUpdate,200);
    } 
}
