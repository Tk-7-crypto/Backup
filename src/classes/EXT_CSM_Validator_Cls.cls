global class EXT_CSM_Validator_Cls {
    public static boolean blnAlreadyDone = false;
    public static boolean isSNowCallFirstTime = true;
    public static boolean isCloseChildDone = false;
    public static boolean isFromTimesheet = true;
    public static boolean isMir3Notification = true;
    public static boolean hasAlreadyDone(){
        return blnAlreadyDone;
    }

    public static void setAlreadyDone() {
        blnAlreadyDone = true;
    }
    
    public static boolean hasSNowCallFirstTime(){
        return isSNowCallFirstTime;
    }

    public static void setSNowCallFirstTime() {
        isSNowCallFirstTime = false;
    }
    
    public static void setCloseChildDone() {
        isCloseChildDone = true;
    }
    
    public static boolean hasCloseChildDone(){
        return isCloseChildDone;
    }
    
    public static void setFromTimesheet() {
        isFromTimesheet = false;
    }
    
    public static boolean hasFromTimesheet(){
        return isFromTimesheet;
    }
    
    public static void setMir3Notification() {
        isMir3Notification = false;
    }
    
    public static boolean hasMir3Notification(){
        return isMir3Notification;
    }
}