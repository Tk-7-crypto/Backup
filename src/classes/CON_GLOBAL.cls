/**
 * This class used for constants used in IQVIA project.
 * version : 1.0
 */
public class CON_GLOBAL {
    public static Double RELEASE_NOV_2018 = 2018.11;
    public static Double RELEASE_DEC_2018 = 2018.12;
    public static Double RELEASE_JAN_2019 = 2019.01;
    public static Double RELEASE_FEB_2019 = 2019.02;
    public static Double RELEASE_MAR_2019 = 2019.03;
    public static Double RELEASE_APR_2019 = 2019.04;
    public static Double RELEASE_MAY_2019 = 2019.05;
    public static Double RELEASE_JUN_2019 = 2019.06;
    public static Double RELEASE_JUL_2019 = 2019.07;
    public static Double RELEASE_AUG_2019 = 2019.08;
    public static Double RELEASE_SEP_2019 = 2019.09;
    public static Double RELEASE_OCT_2019 = 2019.10;
    public static Double RELEASE_NOV_2019 = 2019.11;
    public static Double RELEASE_DEC_2019 = 2019.12;
    public static Double RELEASE_SEP_2020 = 2020.09;
    public static Double RELEASE_OCT_2020 = 2020.10;
    public static Double RELEASE_MAY_2021 = UTL_GLOBAL.getCrmConfigReleaseVersion();
    public static Double RELEASE_AUG_2021 = 2021.08;
    public static Double RELEASE_OCT_2023 = 2023.10;
    public static Double RELEASE_NOV_2023 = 2023.11;
    public static Double RELEASE_DEC_2023 = 2023.12;
    public static Double RELEASE_APR_2025 = 2025.04;
    public static Double RELEASE_May_2025 = 2025.05;
    public static final String DEVOPS = 'Devops';
    public static Map<String, Integer> userToScheduleIntervalMap = new Map<String, Integer>{
        'OWF Notification User' => -60,
        'PSA Notification User' => -60,
        'CSM Admin' => -60,
        'CPQ Migration User' => -60,
        'Integration User' => -60
    };
}
