/*
 * Version       : 1.0
 * Description   : Apex Utility class for CRM. 
 */ 
public class UTL_CRM {
    
    Static String currentUserProfile;
    private static Blob cryptoKey = EncodingUtil.base64Decode('MGpu+ZQa1mHJg0qq2YyFGwnUM2GCoR8ZS5PA8YuLPnU=');
    private static String ALGORITHM_NAME = 'AES256';
    private static Map<Id, Profile> systemAdminProfiles;
    private static Boolean isSandboxOrg;
    private static final Map<String,String> localeToDateFormateMap = New Map<String,String>{
            'ar' => 'dd/MM/yyyy',
            'ar_AE' => 'dd/MM/yyyy',
            'ar_BH' => 'dd/MM/yyyy',
            'ar_JO' => 'dd/MM/yyyy',
            'ar_KW' => 'dd/MM/yyyy',
            'ar_LB' => 'dd/MM/yyyy',
            'ar_SA' => 'dd/MM/yyyy',
            'bg_BG' => 'yyyy-M-d',
            'ca' => 'dd/MM/yyyy',
            'ca_ES' => 'dd/MM/yyyy',
            'ca_ES_EURO' => 'dd/MM/yyyy',
            'cs' => 'd.M.yyyy',
            'cs_CZ' => 'd.M.yyyy',
            'da' => 'dd-MM-yyyy',
            'da_DK' => 'dd-MM-yyyy',
            'de' => 'dd.MM.yyyy',
            'de_AT' => 'dd.MM.yyyy',
            'de_AT' => 'dd.mm.yyyy',
            'de_AT_EURO' => 'dd.MM.yyyy',
            'de_CH' => 'dd.MM.yyyy',
            'de_DE' => 'dd.MM.yyyy',
            'de_DE_EURO' => 'dd.MM.yyyy',
            'de_LU' => 'dd.MM.yyyy',
            'de_LU_EURO' => 'dd.MM.yyyy',
            'el_GR' => 'd/M/yyyy',
            'en_AE' => 'dd-mm-yyyy',
            'en_AU' => 'd/MM/yyyy',
            'en_B' => 'M/d/yyyy',
            'en_BM' => 'M/d/yyyy',
            'en_CA' => 'dd/MM/yyyy',
            'en_DE' => 'dd/MM/yyyy',
            'en_GB' => 'dd/MM/yyyy',
            'en_GH' => 'M/d/yyyy',
            'en_ID' => 'M/d/yyyy',
            'en_IE' => 'dd/MM/yyyy',
            'en_IE_EURO' => 'dd/MM/yyyy',
            'en_IN' => 'dd/M/yyyy',
            'en_NZ' => 'd/MM/yyyy',
            'en_SG' => 'M/d/yyyy',
            'en_US' => 'M/d/yyyy',
            'en_ZA' => 'yyyy/MM/dd',
            'es' => 'd/MM/yyyy',
            'es_AR' => 'dd/MM/yyyy',
            'es_BO' => 'dd-MM-yyyy',
            'es_CL' => 'dd-MM-yyyy',
            'es_CO' => 'd/MM/yyyy',
            'es_CR' => 'dd/MM/yyyy',
            'es_EC' => 'dd/MM/yyyy',
            'es_ES' => 'd/MM/yyyy',
            'es_ES_EURO' => 'd/MM/yyyy',
            'es_GT' => 'd/MM/yyyy',
            'es_HN' => 'MM-dd-yyyy',
            'es_MX' => 'd/MM/yyyy',
            'es_PE' => 'dd/MM/yyyy',
            'es_PR' => 'MM-dd-yyyy',
            'es_PY' => 'dd/MM/yyyy',
            'es_SV' => 'MM-dd-yyyy',
            'es_UY' => 'dd/MM/yyyy',
            'es_VE' => 'dd/MM/yyyy',
            'et_EE' => 'd.MM.yyyy',
            'fi' => 'd.M.yyyy',
            'fi_FI' => 'd.M.yyyy',
            'fi_FI_EURO' => 'd.M.yyyy',
            'fr' => 'dd/MM/yyyy',
            'fr_BE' => 'd/MM/yyyy',
            'fr_CA' => 'yyyy-MM-dd',
            'fr_CH' => 'dd.MM.yyyy',
            'fr_FR' => 'dd/MM/yyyy',
            'fr_FR_EURO' => 'dd/MM/yyyy',
            'fr_LU' => 'dd/MM/yyyy',
            'fr_MC' => 'dd/MM/yyyy',
            'hr_HR' => 'yyyy.MM.dd',
            'hu' => 'yyyy.MM.dd',
            'hu_HU' => 'yyyy.mm.dd',
            'hy_AM' => 'M/d/yyyy',
            'is_IS' => 'd.M.yyyy',
            'it' => 'dd/MM/yyyy',
            'it_CH' => 'dd.MM.yyyy',
            'it_IT' => 'dd/MM/yyyy',
            'iw' => 'dd/MM/yyyy',
            'iw_IL' => 'dd/MM/yyyy',
            'ja' => 'yyyy/MM/dd',
            'ja_JP' => 'yyyy/MM/dd',
            'kk_KZ' => 'M/d/yyyy',
            'km_KH' => 'M/d/yyyy',
            'ko' => 'yyyy. M. d',
            'ko_KR' => 'yyyy. M. d',
            'lt_LT' => 'yyyy.M.d',
            'lv_LV' => 'yyyy.d.M',
            'mk_MK' => 'dd.M.yyyy',
            'ms_MY' => 'dd/MM/yyyy',
            'nl' => 'd-M-yyyy',
            'nl_BE' => 'd/MM/yyyy',
            'nl_NL' => 'd-M-yyyy',
            'nl_SR' => 'd-M-yyyy',
            'no' => 'dd.MM.yyyy',
            'no_NO' => 'dd.MM.yyyy',
            'pl' => 'yyyy-MM-dd',
            'pl_PL' => 'yyyy-mm-dd',
            'pt' => 'dd-MM-yyyy',
            'pt_AO' => 'dd-MM-yyyy',
            'pt_BR' => 'dd/MM/yyyy',
            'pt_PT' => 'dd-MM-yyyy',
            'ro_RO' => 'dd.MM.yyyy',
            'ru' => 'dd.MM.yyyy',
            'ru_RU' => 'dd.mm.yyyy',
            'sk' => 'dd.M.yyyy',
            'sk_SK' => 'd.M.yyyy',
            'sl_SI' => 'd.M.y',
            'sv' => 'yyyy-MM-dd',
            'sv_SE' => 'yyyy-MM-dd',
            'th' => 'M/d/yyyy',
            'th_TH' => 'd/M/yyyy',
            'tr' => 'dd.MM.yyyy',
            'tr_TR' => 'dd.mm.yyyy',
            'uk' => 'dd.mm.yyyy',
            'ur_PK' => 'M/d/yyyy',
            'vi_VN' => 'dd/MM/yyyy',
            'zh' => 'yyyy-M-d',
            'zh_CN' => 'yyyy-M-d',
            'zh_HK' => 'yyyy-M-d',
            'zh_TW' => 'yyyy/M/d'
    };
    
    /**
     * This function will return profile name of current loged in user.
     */
    public static String getCurrentUserProfileName(){
        if(String.isBlank(currentUserProfile)){
            Set<Id> idSet = new Set<Id>{UserInfo.getUserId()};
            Set<String> fieldSet = new Set<String>{'Profile.Name'};
            Map<Id, User> idUserMap = new SLT_User().selectByUserId(idSet, fieldSet);
            currentUserProfile = idUserMap.get(UserInfo.getUserId()).Profile.Name;
        }
        return currentUserProfile;
    }
    
    /**
     * method used to encrypt the password
     * @param : String : password to be encrypt
     * @return : String : encrypted String
     */
    public static string encryptPassword(string password) {
        String encryptedPassword = '';
        if(password != null && password != '') {
            Blob data = Blob.valueOf(password);
            // Encrypt the data 
            Blob encryptedData = Crypto.encryptWithManagedIV(ALGORITHM_NAME, cryptoKey, data);
            encryptedPassword = EncodingUtil.base64Encode(encryptedData);
        }
        return encryptedPassword;
    }
    
    /**
     * method used to decrypt the password
     * @param : String : password to be decrypt
     * @return : String : decrypted String
     */
    public static string decryptPassword(String encryptedPassword) {
        String decryptedPassword = '';
        if(encryptedPassword != null && encryptedPassword != '') {
            Blob data = EncodingUtil.base64Decode(encryptedPassword);
            // Decrypt the data 
            Blob decryptedData = Crypto.decryptWithManagedIV(ALGORITHM_NAME, cryptoKey, data);
            decryptedPassword = decryptedData.toString();
        }
        return decryptedPassword;
    } 
    
    public static Map<Id, Profile> getSystemAdminstratorProfiles(){
        if(systemAdminProfiles == null){
            Set<String> profileNames = new Set<String>{CON_CRM.IQVIA_SF_PLATFORM_PROFILE, CON_CRM.SYS_ADMIN_INTEGRATION_PROFILE , CON_CRM.SYS_ADMIN_MODULE_PROFILE, CON_CRM.SYS_ADMIN_PKG_SUPPORT_PROFILE, CON_CRM.SYSTEM_ADMIN_PROFILE};
            systemAdminProfiles = new Map<Id, Profile>(new SLT_Profile().selectProfileByName(profileNames, new Set<String>{'Id', 'Name'}));
        }
        return systemAdminProfiles;
    }
    
    public static boolean isSandboxOrg(){
        if(isSandboxOrg == null){
            Organization org = [SELECT Id, IsSandbox FROM Organization LIMIT 1];
            isSandboxOrg = org.IsSandbox;
        }
        return isSandboxOrg;
    }
    
    public static String getDateFormatFromLocale(String localeSidKey){
        String dateFormate = '';
        if(localeToDateFormateMap.containsKey(localeSidKey)){
            dateFormate = localeToDateFormateMap.get(localeSidKey);
        }
        
        return dateFormate;
    }
}