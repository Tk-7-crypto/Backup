/*
*@Author  : C.P.Pandey
*@Purpose : Create a schedular a batch class(TPA_Batch_Send_AMA_Renewal_Notification)
*@Date    : 27 Sept 2016
*/
global class SCH_TPA_AMA_Renewal_Notification implements Schedulable {
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new BCH_TPA_AMA_Renewal_Notification(),1);
    }    
}