/*
*@Author  : Supriya Johari
*@Purpose : Create a schedular a batch class(BCH_TPA_AMA_Send_Reminder_Mail)
*@Date    : 1 July 2016
*/

global class SCH_TPA_AMA_Send_Reminder_Mail implements Schedulable {
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new BCH_TPA_AMA_Send_Reminder_Mail(),1);
    } 
}