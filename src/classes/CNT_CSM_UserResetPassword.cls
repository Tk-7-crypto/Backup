public class CNT_CSM_UserResetPassword {
    @InvocableMethod
    public static void sendEmailToUser(List<User> request){ 
            System.resetPassword(request[0].id, true);
        }
}