/**
Created By : Himanshu Parashar
Date : 4 Dec 2012

 */
@isTest
private class TST_Rejection_Reasons_Split {

    static testMethod void RejectionReasonStringTest() {
        Rejection_Reasons_Split rs=new Rejection_Reasons_Split();
        rs.setRejectionstring('Test1|Test2|Test3');
        rs.setRejection_SD_Message('SD Message \n with Line \n Break');
        rs.getRejection_SD_Message();
        system.assertequals(rs.getRejectionstring(),'Test1|Test2|Test3');
        String[] Rejectionreasons=rs.getRejection_Reasons();
        system.assertequals(Rejectionreasons[0],'Test1');
        system.assertequals(rs.getRejection_SD_Error_Message().contains('<br/>'),TRUE);
        rs.Rejectionstring=null;
        rs.Rejection_SD_Message=null;
        rs.getRejection_SD_Error_Message();
        rs.getRejection_Reasons();
             
        
    }
}