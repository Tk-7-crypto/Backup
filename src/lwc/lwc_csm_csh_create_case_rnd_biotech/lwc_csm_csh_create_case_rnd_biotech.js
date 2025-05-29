import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import createCase from '@salesforce/apex/CNT_CSM_PortalCreateCase.createCase';
import getUserContact from '@salesforce/apex/CNT_CSM_PortalCreateCase.getUserContact';
import getAllowedStories from '@salesforce/apex/CNT_CSM_PortalCreateCase.getAllowedStories';
import getStaticResourceUrl from '@salesforce/apex/CNT_CSM_PortalCreateCase.getStaticResourceUrl';
import getCategorizationId from '@salesforce/apex/CNT_CSM_PortalCreateCase.getCategorizationIdByLos';
import createContentDocumentLink from '@salesforce/apex/CNT_CSM_PortalCreateCase.createContentDocumentLink';


const OTHER = 'Other';
const SUBTYPE1__C = 'SubType1__c';
const SUBTYPE2__C = 'SubType2__c';
const SUBTYPE3__C = 'SubType3__c';
const LOS__C = 'LOS__c';

export default class LwcCsmCshCreateCaseRndBiotech extends NavigationMixin(LightningElement) {
    countryOptions = [
        { label: 'Afghanistan', value: 'AF' },
        { label: 'Albania', value: 'AL' },
        { label: 'Algeria', value: 'DZ' },
        { label: 'Andorra', value: 'AD' },
        { label: 'Angola', value: 'AO' },
        { label: 'Antigua and Barbuda', value: 'AG' },
        { label: 'Argentina', value: 'AR' },
        { label: 'Armenia', value: 'AM' },
        { label: 'Australia', value: 'AU' },
        { label: 'Austria', value: 'AT' },
        { label: 'Azerbaijan', value: 'AZ' },
        { label: 'Bahamas', value: 'BS' },
        { label: 'Bahrain', value: 'BH' },
        { label: 'Bangladesh', value: 'BD' },
        { label: 'Barbados', value: 'BB' },
        { label: 'Belarus', value: 'BY' },
        { label: 'Belgium', value: 'BE' },
        { label: 'Belize', value: 'BZ' },
        { label: 'Benin', value: 'BJ' },
        { label: 'Bhutan', value: 'BT' },
        { label: 'Bolivia', value: 'BO' },
        { label: 'Bosnia and Herzegovina', value: 'BA' },
        { label: 'Botswana', value: 'BW' },
        { label: 'Brazil', value: 'BR' },
        { label: 'Brunei', value: 'BN' },
        { label: 'Bulgaria', value: 'BG' },
        { label: 'Burkina Faso', value: 'BF' },
        { label: 'Burundi', value: 'BI' },
        { label: 'Cabo Verde', value: 'CV' },
        { label: 'Cambodia', value: 'KH' },
        { label: 'Cameroon', value: 'CM' },
        { label: 'Canada', value: 'CA' },
        { label: 'Central African Republic', value: 'CF' },
        { label: 'Chad', value: 'TD' },
        { label: 'Chile', value: 'CL' },
        { label: 'China', value: 'CN' },
        { label: 'Colombia', value: 'CO' },
        { label: 'Comoros', value: 'KM' },
        { label: 'Congo, Democratic Republic of the', value: 'CD' },
        { label: 'Congo, Republic of the', value: 'CG' },
        { label: 'Costa Rica', value: 'CR' },
        { label: 'Croatia', value: 'HR' },
        { label: 'Cuba', value: 'CU' },
        { label: 'Cyprus', value: 'CY' },
        { label: 'Czech Republic', value: 'CZ' },
        { label: 'Denmark', value: 'DK' },
        { label: 'Djibouti', value: 'DJ' },
        { label: 'Dominica', value: 'DM' },
        { label: 'Dominican Republic', value: 'DO' },
        { label: 'Ecuador', value: 'EC' },
        { label: 'Egypt', value: 'EG' },
        { label: 'El Salvador', value: 'SV' },
        { label: 'Equatorial Guinea', value: 'GQ' },
        { label: 'Eritrea', value: 'ER' },
        { label: 'Estonia', value: 'EE' },
        { label: 'Eswatini', value: 'SZ' },
        { label: 'Ethiopia', value: 'ET' },
        { label: 'Fiji', value: 'FJ' },
        { label: 'Finland', value: 'FI' },
        { label: 'France', value: 'FR' },
        { label: 'Gabon', value: 'GA' },
        { label: 'Gambia', value: 'GM' },
        { label: 'Georgia', value: 'GE' },
        { label: 'Germany', value: 'DE' },
        { label: 'Ghana', value: 'GH' },
        { label: 'Greece', value: 'GR' },
        { label: 'Grenada', value: 'GD' },
        { label: 'Guatemala', value: 'GT' },
        { label: 'Guinea', value: 'GN' },
        { label: 'Guinea-Bissau', value: 'GW' },
        { label: 'Guyana', value: 'GY' },
        { label: 'Haiti', value: 'HT' },
        { label: 'Honduras', value: 'HN' },
        { label: 'Hungary', value: 'HU' },
        { label: 'Iceland', value: 'IS' },
        { label: 'India', value: 'IN' },
        { label: 'Indonesia', value: 'ID' },
        { label: 'Iran', value: 'IR' },
        { label: 'Iraq', value: 'IQ' },
        { label: 'Ireland', value: 'IE' },
        { label: 'Israel', value: 'IL' },
        { label: 'Italy', value: 'IT' },
        { label: 'Jamaica', value: 'JM' },
        { label: 'Japan', value: 'JP' },
        { label: 'Jordan', value: 'JO' },
        { label: 'Kazakhstan', value: 'KZ' },
        { label: 'Kenya', value: 'KE' },
        { label: 'Kiribati', value: 'KI' },
        { label: 'Korea, North', value: 'KP' },
        { label: 'Korea, South', value: 'KR' },
        { label: 'Kosovo', value: 'XK' },
        { label: 'Kuwait', value: 'KW' },
        { label: 'Kyrgyzstan', value: 'KG' },
        { label: 'Laos', value: 'LA' },
        { label: 'Latvia', value: 'LV' },
        { label: 'Lebanon', value: 'LB' },
        { label: 'Lesotho', value: 'LS' },
        { label: 'Liberia', value: 'LR' },
        { label: 'Libya', value: 'LY' },
        { label: 'Liechtenstein', value: 'LI' },
        { label: 'Lithuania', value: 'LT' },
        { label: 'Luxembourg', value: 'LU' },
        { label: 'Madagascar', value: 'MG' },
        { label: 'Malawi', value: 'MW' },
        { label: 'Malaysia', value: 'MY' },
        { label: 'Maldives', value: 'MV' },
        { label: 'Mali', value: 'ML' },
        { label: 'Malta', value: 'MT' },
        { label: 'Marshall Islands', value: 'MH' },
        { label: 'Mauritania', value: 'MR' },
        { label: 'Mauritius', value: 'MU' },
        { label: 'Mexico', value: 'MX' },
        { label: 'Micronesia', value: 'FM' },
        { label: 'Moldova', value: 'MD' },
        { label: 'Monaco', value: 'MC' },
        { label: 'Mongolia', value: 'MN' },
        { label: 'Montenegro', value: 'ME' },
        { label: 'Morocco', value: 'MA' },
        { label: 'Mozambique', value: 'MZ' },
        { label: 'Myanmar', value: 'MM' },
        { label: 'Namibia', value: 'NA' },
        { label: 'Nauru', value: 'NR' },
        { label: 'Nepal', value: 'NP' },
        { label: 'Netherlands', value: 'NL' },
        { label: 'New Zealand', value: 'NZ' },
        { label: 'Nicaragua', value: 'NI' },
        { label: 'Niger', value: 'NE' },
        { label: 'Nigeria', value: 'NG' },
        { label: 'North Macedonia', value: 'MK' },
        { label: 'Norway', value: 'NO' },
        { label: 'Oman', value: 'OM' },
        { label: 'Pakistan', value: 'PK' },
        { label: 'Palau', value: 'PW' },
        { label: 'Palestine', value: 'PS' },
        { label: 'Panama', value: 'PA' },
        { label: 'Papua New Guinea', value: 'PG' },
        { label: 'Paraguay', value: 'PY' },
        { label: 'Peru', value: 'PE' },
        { label: 'Philippines', value: 'PH' },
        { label: 'Poland', value: 'PL' },
        { label: 'Portugal', value: 'PT' },
        { label: 'Qatar', value: 'QA' },
        { label: 'Romania', value: 'RO' },
        { label: 'Russia', value: 'RU' },
        { label: 'Rwanda', value: 'RW' },
        { label: 'Saint Kitts and Nevis', value: 'KN' },
        { label: 'Saint Lucia', value: 'LC' },
        { label: 'Saint Vincent and the Grenadines', value: 'VC' },
        { label: 'Samoa', value: 'WS' },
        { label: 'San Marino', value: 'SM' },
        { label: 'Sao Tome and Principe', value: 'ST' },
        { label: 'Saudi Arabia', value: 'SA' },
        { label: 'Senegal', value: 'SN' },
        { label: 'Serbia', value: 'RS' },
        { label: 'Seychelles', value: 'SC' },
        { label: 'Sierra Leone', value: 'SL' },
        { label: 'Singapore', value: 'SG' },
        { label: 'Slovakia', value: 'SK' },
        { label: 'Slovenia', value: 'SI' },
        { label: 'Solomon Islands', value: 'SB' },
        { label: 'Somalia', value: 'SO' },
        { label: 'South Africa', value: 'ZA' },
        { label: 'South Sudan', value: 'SS' },
        { label: 'Spain', value: 'ES' },
        { label: 'Sri Lanka', value: 'LK' },
        { label: 'Sudan', value: 'SD' },
        { label: 'Suriname', value: 'SR' },
        { label: 'Sweden', value: 'SE' },
        { label: 'Switzerland', value: 'CH' },
        { label: 'Syria', value: 'SY' },
        { label: 'Taiwan', value: 'TW' },
        { label: 'Tajikistan', value: 'TJ' },
        { label: 'Tanzania', value: 'TZ' },
        { label: 'Thailand', value: 'TH' },
        { label: 'Timor-Leste', value: 'TL' },
        { label: 'Turkey', value: 'TR' },
        { label: 'Turkmenistan', value: 'TM' },
        { label: 'Tuvalu', value: 'TV' },
        { label: 'Uganda', value: 'UG' },
        { label: 'Ukraine', value: 'UA' },
        { label: 'United Arab Emirates', value: 'AE' },
        { label: 'United Kingdom', value: 'GB' },
        { label: 'United States', value: 'US' },
        { label: 'Uruguay', value: 'UY' },
        { label: 'Uzbekistan', value: 'UZ' },
        { label: 'Vanuatu', value: 'VU' },
        { label: 'Vatican City', value: 'VA' },
        { label: 'Venezuela', value: 'VE' },
        { label: 'Vietnam', value: 'VN' },
        { label: 'Yemen', value: 'YE' },
        { label: 'Zambia', value: 'ZM' },
        { label: 'Zimbabwe', value: 'ZW' }
    ];

    timeZoneOptions = [
        { label: '(UTC-12:00) International Date Line West', value: '(UTC-12:00) International Date Line West' },
        { label: '(UTC-11:00) Coordinated Universal Time-11', value: '(UTC-11:00) Coordinated Universal Time-11' },
        { label: '(UTC-10:00) Hawaii', value: '(UTC-10:00) Hawaii' },
        { label: '(UTC-09:00) Alaska', value: '(UTC-09:00) Alaska' },
        { label: '(UTC-08:00) Baja California', value: '(UTC-08:00) Baja California' },
        { label: '(UTC-08:00) Pacific Time (US & Canada)', value: '(UTC-08:00) Pacific Time (US & Canada)' },
        { label: '(UTC-07:00) Arizona', value: '(UTC-07:00) Arizona' },
        { label: '(UTC-07:00) Chihuahua, La Paz, Mazatlan', value: '(UTC-07:00) Chihuahua, La Paz, Mazatlan' },
        { label: '(UTC-07:00) Mountain Time (US & Canada)', value: '(UTC-07:00) Mountain Time (US & Canada)' },
        { label: '(UTC-06:00) Central America', value: '(UTC-06:00) Central America' },
        { label: '(UTC-06:00) Central Time (US & Canada)', value: '(UTC-06:00) Central Time (US & Canada)' },
        { label: '(UTC-06:00) Guadalajara, Mexico City, Monterrey', value: '(UTC-06:00) Guadalajara, Mexico City, Monterrey' },
        { label: '(UTC-06:00) Saskatchewan', value: '(UTC-06:00) Saskatchewan' },
        { label: '(UTC-05:00) Bogota, Lima, Quito', value: '(UTC-05:00) Bogota, Lima, Quito' },
        { label: '(UTC-05:00) Eastern Time (US & Canada)', value: '(UTC-05:00) Eastern Time (US & Canada)' },
        { label: '(UTC-05:00) Indiana (East)', value: '(UTC-05:00) Indiana (East)' },
        { label: '(UTC-04:30) Caracas', value: '(UTC-04:30) Caracas' },
        { label: '(UTC-04:00) Asuncion', value: '(UTC-04:00) Asuncion' },
        { label: '(UTC-04:00) Atlantic Time (Canada)', value: '(UTC-04:00) Atlantic Time (Canada)' },
        { label: '(UTC-04:00) Cuiaba', value: '(UTC-04:00) Cuiaba' },
        { label: '(UTC-04:00) Georgetown, La Paz, Manaus, San Juan', value: '(UTC-04:00) Georgetown, La Paz, Manaus, San Juan' },
        { label: '(UTC-04:00) Santiago', value: '(UTC-04:00) Santiago' },
        { label: '(UTC-03:30) Newfoundland', value: '(UTC-03:30) Newfoundland' },
        { label: '(UTC-03:00) Brasilia', value: '(UTC-03:00) Brasilia' },
        { label: '(UTC-03:00) Buenos Aires', value: '(UTC-03:00) Buenos Aires' },
        { label: '(UTC-03:00) Cayenne, Fortaleza', value: '(UTC-03:00) Cayenne, Fortaleza' },
        { label: '(UTC-03:00) Greenland', value: '(UTC-03:00) Greenland' },
        { label: '(UTC-03:00) Montevideo', value: '(UTC-03:00) Montevideo' },
        { label: '(UTC-03:00) Salvador', value: '(UTC-03:00) Salvador' },
        { label: '(UTC-02:00) Coordinated Universal Time-02', value: '(UTC-02:00) Coordinated Universal Time-02' },
        { label: '(UTC-02:00) Mid-Atlantic - Old', value: '(UTC-02:00) Mid-Atlantic - Old' },
        { label: '(UTC-01:00) Azores', value: '(UTC-01:00) Azores' },
        { label: '(UTC-01:00) Cape Verde Is.', value: '(UTC-01:00) Cape Verde Is.' },
        { label: '(UTC) Casablanca', value: '(UTC) Casablanca' },
        { label: '(UTC) Coordinated Universal Time', value: '(UTC) Coordinated Universal Time' },
        { label: '(UTC) Dublin, Edinburgh, Lisbon, London', value: '(UTC) Dublin, Edinburgh, Lisbon, London' },
        { label: '(UTC) Monrovia, Reykjavik', value: '(UTC) Monrovia, Reykjavik' },
        { label: '(UTC+01:00) Amsterdam, Berlin, Bern, Rome, Stockholm, Vienna', value: '(UTC+01:00) Amsterdam, Berlin, Bern, Rome, Stockholm, Vienna' },
        { label: '(UTC+01:00) Belgrade, Bratislava, Budapest, Ljubljana, Prague', value: '(UTC+01:00) Belgrade, Bratislava, Budapest, Ljubljana, Prague' },
        { label: '(UTC+01:00) Brussels, Copenhagen, Madrid, Paris', value: '(UTC+01:00) Brussels, Copenhagen, Madrid, Paris' },
        { label: '(UTC+01:00) Sarajevo, Skopje, Warsaw, Zagreb', value: '(UTC+01:00) Sarajevo, Skopje, Warsaw, Zagreb' },
        { label: '(UTC+01:00) West Central Africa', value: '(UTC+01:00) West Central Africa' },
        { label: '(UTC+01:00) Windhoek', value: '(UTC+01:00) Windhoek' },
        { label: '(UTC+02:00) Athens, Bucharest', value: '(UTC+02:00) Athens, Bucharest' },
        { label: '(UTC+02:00) Beirut', value: '(UTC+02:00) Beirut' },
        { label: '(UTC+02:00) Cairo', value: '(UTC+02:00) Cairo' },
        { label: '(UTC+02:00) Damascus', value: '(UTC+02:00) Damascus' },
        { label: '(UTC+02:00) E. Europe', value: '(UTC+02:00) E. Europe' },
        { label: '(UTC+02:00) Harare, Pretoria', value: '(UTC+02:00) Harare, Pretoria' },
        { label: '(UTC+02:00) Helsinki, Kyiv, Riga, Sofia, Tallinn, Vilnius', value: '(UTC+02:00) Helsinki, Kyiv, Riga, Sofia, Tallinn, Vilnius' },
        { label: '(UTC+02:00) Istanbul', value: '(UTC+02:00) Istanbul' },
        { label: '(UTC+02:00) Jerusalem', value: '(UTC+02:00) Jerusalem' },
        { label: '(UTC+02:00) Tripoli', value: '(UTC+02:00) Tripoli' },
        { label: '(UTC+03:00) Amman', value: '(UTC+03:00) Amman' },
        { label: '(UTC+03:00) Baghdad', value: '(UTC+03:00) Baghdad' },
        { label: '(UTC+03:00) Kaliningrad, Minsk', value: '(UTC+03:00) Kaliningrad, Minsk' },
        { label: '(UTC+03:00) Kuwait, Riyadh', value: '(UTC+03:00) Kuwait, Riyadh' },
        { label: '(UTC+03:00) Nairobi', value: '(UTC+03:00) Nairobi' },
        { label: '(UTC+03:30) Tehran', value: '(UTC+03:30) Tehran' },
        { label: '(UTC+04:00) Abu Dhabi, Muscat', value: '(UTC+04:00) Abu Dhabi, Muscat' },
        { label: '(UTC+04:00) Baku', value: '(UTC+04:00) Baku' },
        { label: '(UTC+04:00) Moscow, St. Petersburg, Volgograd', value: '(UTC+04:00) Moscow, St. Petersburg, Volgograd' },
        { label: '(UTC+04:00) Samara', value: '(UTC+04:00) Samara' },
        { label: '(UTC+04:00) Tbilisi', value: '(UTC+04:00) Tbilisi' },
        { label: '(UTC+04:30) Kabul', value: '(UTC+04:30) Kabul' },
        { label: '(UTC+05:00) Ashgabat, Tashkent', value: '(UTC+05:00) Ashgabat, Tashkent' },
        { label: '(UTC+05:00) Ekaterinburg', value: '(UTC+05:00) Ekaterinburg' },
        { label: '(UTC+05:30) Chennai, Kolkata, Mumbai, New Delhi', value: '(UTC+05:30) Chennai, Kolkata, Mumbai, New Delhi' },
        { label: '(UTC+05:30) Sri Jayawardenepura', value: '(UTC+05:30) Sri Jayawardenepura' },
        { label: '(UTC+05:45) Kathmandu', value: '(UTC+05:45) Kathmandu' },
        { label: '(UTC+06:00) Almaty, Novosibirsk', value: '(UTC+06:00) Almaty, Novosibirsk' },
        { label: '(UTC+06:00) Astana', value: '(UTC+06:00) Astana' },
        { label: '(UTC+06:00) Dhaka', value: '(UTC+06:00) Dhaka' },
        { label: '(UTC+06:00) Omsk', value: '(UTC+06:00) Omsk' },
        { label: '(UTC+07:00) Bangkok, Hanoi, Jakarta', value: '(UTC+07:00) Bangkok, Hanoi, Jakarta' },
        { label: '(UTC+07:00) Krasnoyarsk', value: '(UTC+07:00) Krasnoyarsk' },
        { label: '(UTC+08:00) Beijing, Chongqing, Hong Kong, Urumqi', value: '(UTC+08:00) Beijing, Chongqing, Hong Kong, Urumqi' },
        { label: '(UTC+08:00) Irkutsk, Ulaanbaatar', value: '(UTC+08:00) Irkutsk, Ulaanbaatar' },
        { label: '(UTC+08:00) Perth', value: '(UTC+08:00) Perth' },
        { label: '(UTC+08:00) Singapore', value: '(UTC+08:00) Singapore' },
        { label: '(UTC+09:00) Osaka, Sapporo, Tokyo', value: '(UTC+09:00) Osaka, Sapporo, Tokyo' },
        { label: '(UTC+09:00) Seoul', value: '(UTC+09:00) Seoul' },
        { label: '(UTC+09:00) Yakutsk', value: '(UTC+09:00) Yakutsk' },
        { label: '(UTC+09:30) Adelaide', value: '(UTC+09:30) Adelaide' },
        { label: '(UTC+09:30) Darwin', value: '(UTC+09:30) Darwin' },
        { label: '(UTC+10:00) Brisbane', value: '(UTC+10:00) Brisbane' },
        { label: '(UTC+10:00) Canberra, Melbourne, Sydney', value: '(UTC+10:00) Canberra, Melbourne, Sydney' },
        { label: '(UTC+10:00) Guam, Port Moresby', value: '(UTC+10:00) Guam, Port Moresby' },
        { label: '(UTC+10:00) Hobart', value: '(UTC+10:00) Hobart' },
        { label: '(UTC+10:00) Vladivostok', value: '(UTC+10:00) Vladivostok' },
        { label: '(UTC+11:00) Bougainville Island', value: '(UTC+11:00) Bougainville Island' },
        { label: '(UTC+11:00) Solomon Is., New Caledonia', value: '(UTC+11:00) Solomon Is., New Caledonia' },
        { label: '(UTC+12:00) Fiji, Kamchatka, Marshall Is.', value: '(UTC+12:00) Fiji, Kamchatka, Marshall Is.' },
        { label: '(UTC+12:00) Auckland, Wellington', value: '(UTC+12:00) Auckland, Wellington' }
    ];

    userTypeOptions = [
        { label: 'Site User', value: 'Site User' },
        { label: 'Sponsor User', value: 'Sponsor User' }
    ];

    rightsGroupOptions = [
        { label: 'User Admin - Site Support', value: 'User Admin - Site Support' },
        { label: 'Developer', value: 'Developer' },
        { label: 'Sign - PI', value: 'Sign - PI' },
        { label: 'Entry - Study Coordinator', value: 'Entry - Study Coordinator' },
        { label: 'Query and Verify - CRA', value: 'Query and Verify - CRA' },
        { label: 'Query and Verify and Unlock - CTM', value: 'Query and Verify and Unlock - CTM' },
        { label: 'Query and Verify and Unfreeze - DM', value: 'Query and Verify and Unfreeze - DM' },
        { label: 'Query and Safety Review - Safety', value: 'Query and Safety Review - Safety' },
        { label: 'View - Sponsor and PM', value: 'View - Sponsor and PM' },
        { label: 'Subject Transfer - LDM', value: 'Subject Transfer - LDM' },
        { label: 'Report Administrator - IT', value: 'Report Administrator - IT' },
        { label: 'Deployment - IT', value: 'Deployment - IT' },
        { label: OTHER, value: OTHER }
    ];

    trainingLocationOptions = [
        { label: 'Biotech LMS Record', value: 'Biotech LMS Record' },
        { label: 'eLearning', value: 'eLearning' },
        { label: 'Project Site Support Training Certificate Folder', value: 'Project Site Support Training Certificate Folder' }
    ];

    raveModule1Options = [
        { label: 'iMedidata EDC', value: 'iMedidata EDC' },
        { label: 'Batch Upload', value: 'Batch Upload' },
        { label: 'Coder Import Group', value: 'Coder Import Group' },
        { label: 'All Modules', value: 'All Modules' },
        { label: 'Developer', value: 'Developer' },
        { label: 'Configuration Developer', value: 'Configuration Developer' },
        { label: 'EDC Non-Site', value: 'EDC Non-Site' },
        { label: 'EDC Only', value: 'EDC Only' },
        { label: 'Help Desk Tier 1', value: 'Help Desk Tier 1' },
        { label: 'Help Desk Tier 2', value: 'Help Desk Tier 2' },
        { label: 'PDF Generator', value: 'PDF Generator' },
        { label: 'Lab Administrator', value: 'Lab Administrator' },
        { label: 'QC Auditor', value: 'QC Auditor' },
        { label: OTHER, value: OTHER }
    ];

    raveModule2Options = [
        { label: 'iMedidata EDC', value: 'iMedidata EDC' },
        { label: 'Batch Upload', value: 'Batch Upload' },
        { label: 'Coder Import Group', value: 'Coder Import Group' },
        { label: 'All Modules', value: 'All Modules' },
        { label: 'Developer', value: 'Developer' },
        { label: 'Configuration Developer', value: 'Configuration Developer' },
        { label: 'EDC Non-Site', value: 'EDC Non-Site' },
        { label: 'EDC Only', value: 'EDC Only' },
        { label: 'Help Desk Tier 1', value: 'Help Desk Tier 1' },
        { label: 'Help Desk Tier 2', value: 'Help Desk Tier 2' },
        { label: 'PDF Generator', value: 'PDF Generator' },
        { label: 'Lab Administrator', value: 'Lab Administrator' },
        { label: 'QC Auditor', value: 'QC Auditor' },
        { label: OTHER, value: OTHER }
    ];

    raveRole1Options = [
        { label: 'Batch Upload', value: 'Batch Upload' },
        { label: 'Coder Import Role', value: 'Coder Import Role' },
        { label: 'Developer (non-production only)', value: 'Developer (non-production only)' },
        { label: 'Export (automated exports & SAS on Demand)', value: 'Export (automated exports & SAS on Demand)' },
        { label: 'Import (automated Imports)', value: 'Import (automated Imports)' },
        { label: 'Entry and Sign (PI)', value: 'Entry and Sign (PI)' },
        { label: 'Entry and Sign without Enroll (PI)', value: 'Entry and Sign without Enroll (PI)' },
        { label: 'Sign (PI)', value: 'Sign (PI)' },
        { label: 'Entry (Study Coordinator)', value: 'Entry (Study Coordinator)' },
        { label: 'Entry without Enroll (Study Coordinator)', value: 'Entry without Enroll (Study Coordinator)' },
        { label: 'Medical Data Reviewer (MDR)', value: 'Medical Data Reviewer (MDR)' },
        { label: 'Query and Verify (CRA)', value: 'Query and Verify (CRA)' },
        { label: 'Query and Verify and Unlock (CTM)', value: 'Query and Verify and Unlock (CTM)' },
        { label: 'CTM with tSDV (CTM)', value: 'CTM with tSDV (CTM)' },
        { label: 'Query and Inhouse Review (CSA)', value: 'Query and Inhouse Review (CSA)' },
        { label: 'Query and Lock (DM)', value: 'Query and Lock (DM)' },
        { label: 'Query and Lock and Unfreeze (LDM)', value: 'Query and Lock and Unfreeze (LDM)' },
        { label: 'Query and Safety Review (Safety)', value: 'Query and Safety Review (Safety)' },
        { label: 'View (Site User)', value: 'View (Site User)' },
        { label: 'View All Sites (Sponsor, PM)', value: 'View All Sites (Sponsor, PM)' },
        { label: 'View Only with tSDV (Data Analyst)', value: 'View Only with tSDV (Data Analyst)' },
        { label: OTHER, value: OTHER }
    ];

    raveRole2Options = [
        { label: 'Batch Upload', value: 'Batch Upload' },
        { label: 'Coder Import Role', value: 'Coder Import Role' },
        { label: 'Developer (non-production only)', value: 'Developer (non-production only)' },
        { label: 'Export (automated exports & SAS on Demand)', value: 'Export (automated exports & SAS on Demand)' },
        { label: 'Import (automated Imports)', value: 'Import (automated Imports)' },
        { label: 'Entry and Sign (PI)', value: 'Entry and Sign (PI)' },
        { label: 'Entry and Sign without Enroll (PI)', value: 'Entry and Sign without Enroll (PI)' },
        { label: 'Sign (PI)', value: 'Sign (PI)' },
        { label: 'Entry (Study Coordinator)', value: 'Entry (Study Coordinator)' },
        { label: 'Entry without Enroll (Study Coordinator)', value: 'Entry without Enroll (Study Coordinator)' },
        { label: 'Medical Data Reviewer (MDR)', value: 'Medical Data Reviewer (MDR)' },
        { label: 'Query and Verify (CRA)', value: 'Query and Verify (CRA)' },
        { label: 'Query and Verify and Unlock (CTM)', value: 'Query and Verify and Unlock (CTM)' },
        { label: 'CTM with tSDV (CTM)', value: 'CTM with tSDV (CTM)' },
        { label: 'Query and Inhouse Review (CSA)', value: 'Query and Inhouse Review (CSA)' },
        { label: 'Query and Lock (DM)', value: 'Query and Lock (DM)' },
        { label: 'Query and Lock and Unfreeze (LDM)', value: 'Query and Lock and Unfreeze (LDM)' },
        { label: 'Query and Safety Review (Safety)', value: 'Query and Safety Review (Safety)' },
        { label: 'View (Site User)', value: 'View (Site User)' },
        { label: 'View All Sites (Sponsor, PM)', value: 'View All Sites (Sponsor, PM)' },
        { label: 'View Only with tSDV (Data Analyst)', value: 'View Only with tSDV (Data Analyst)' },
        { label: OTHER, value: OTHER }
    ];

    rtsmOptions = [
        { label: 'RTSM - Assistant Project Manager (blinded)', value: 'RTSM - Assistant Project Manager (blinded)' },
        { label: 'RTSM - Biostatistician (blinded)', value: 'RTSM - Biostatistician (blinded)' },
        { label: 'RTSM - Biostatistician (unblinded)', value: 'RTSM - Biostatistician (unblinded)' },
        { label: 'RTSM - CRA (blinded)', value: 'RTSM - CRA (blinded)' },
        { label: 'RTSM - CRA (unblinded)', value: 'RTSM - CRA (unblinded)' },
        { label: 'RTSM - CRC (blinded - report physical inventory)', value: 'RTSM - CRC (blinded - report physical inventory)' },
        { label: 'RTSM - CRC (blinded)', value: 'RTSM - CRC (blinded)' },
        { label: 'RTSM - Pharmacist (blinded)', value: 'RTSM - Pharmacist (blinded)' },
        { label: 'RTSM - Pharmacist (unblinded)', value: 'RTSM - Pharmacist (unblinded)' },
        { label: 'RTSM - PI (blinded, can unblind)', value: 'RTSM - PI (blinded, can unblind)' },
        { label: 'RTSM - PI (blinded)', value: 'RTSM - PI (blinded)' },
        { label: 'RTSM - PM (blinded, can unblind)', value: 'RTSM - PM (blinded, can unblind)' },
        { label: 'RTSM - PM (blinded)', value: 'RTSM - PM (blinded)' },
        { label: 'RTSM - Read Only (blinded)', value: 'RTSM - Read Only (blinded)' },
        { label: 'RTSM - Read Only (unblinded)', value: 'RTSM - Read Only (unblinded)' },
        { label: 'RTSM - Safety Monitor (blinded, can unblind)', value: 'RTSM - Safety Monitor (blinded, can unblind)' },
        { label: 'RTSM - Safety Monitor (unblinded)', value: 'RTSM - Safety Monitor (unblinded)' },
        { label: 'RTSM - Shipper Manager (blinded)', value: 'RTSM - Shipper Manager (blinded)' },
        { label: 'RTSM - Shipper Manager (unblinded)', value: 'RTSM - Shipper Manager (unblinded)' },
        { label: 'RTSM - Study Manager (blinded, can unblind)', value: 'RTSM - Study Manager (blinded, can unblind)' },
        { label: 'RTSM - Study Manager (blinded)', value: 'RTSM - Study Manager (blinded)' },
        { label: 'RTSM - Study Manager (unblinded)', value: 'RTSM - Study Manager (unblinded)' },
        { label: 'RTSM - Supply Manager (blinded)', value: 'RTSM - Supply Manager (blinded)' },
        { label: 'RTSM - Supply Manager (unblinded)', value: 'RTSM - Supply Manager (unblinded)' },
        { label: 'RTSM - System Admin (unblinded, can unblind)', value: 'RTSM - System Admin (unblinded, can unblind)' },
        { label: 'RTSM - Trial Manager (blinded)', value: 'RTSM - Trial Manager (blinded)' },
        { label: 'RTSM - Trial Manager (unblinded)', value: 'RTSM - Trial Manager (unblinded)' }
    ];

    coderOptions = [
        { label: 'Query and Lock (DM)', value: 'Query and Lock (DM)' },
        { label: 'Coder', value: 'Coder' },
        { label: OTHER, value: OTHER }
    ];

    eCOAOptions = [
        { label: 'ClinRo User', value: 'ClinRo User' },
        { label: 'PC Registration User', value: 'PC Registration User' },
        { label: 'Site Mode User', value: 'Site Mode User' }
    ]




    @track fields = [
        {
            label: 'RecordTypeId', name: 'RecordTypeId', required: true, value: '0126A000000hC32QAE', visible: false
        },
        {
            label: 'Subject', name: 'Subject', required: true, value: '', visible: false
        },
        {
            label: 'LOS',
            name: LOS__C,
            required: true,
            placeholder: 'Select a LOS',
            allowedValues: [
                { label: 'Account Management', value: 'Account Management' }
            ],
            type: 'select',
            value: 'Account Management',
            visible: false
        },
        {
            label: 'Contact', name: 'ContactId', required: true, value: '', visible: false
        },
        {
            label: 'Account', name: 'AccountId', required: true, value: '', visible: false
        },
        {
            label: 'CategorizationId', name: 'Case_CategorizationId__c', required: true, value: '', visible: false
        },
        {
            label: 'Application',
            name: SUBTYPE1__C,
            required: true,
            placeholder: 'Select an Application',
            allowedValues: [
                { label: 'Biotech InForm', value: 'Biotech InForm' },
                { label: 'Biotech Rave', value: 'Biotech Rave' }
            ],
            type: 'select',
            value: ''
        },
        {
            label: 'Study',
            name: 'Study__c',
            required: true,
            placeholder: 'Select a Study',
            allowedValues: [],
            type: 'select',
            value: '',
            visible: true
        },
        {
            label: 'Request Type',
            name: SUBTYPE2__C,
            required: true,
            placeholder: 'Select a Request Type',
            allowedValues: [
                {
                    label: 'Create User',
                    value: 'Create User',
                    additionalFields: {
                        'Biotech InForm': [
                            { label: 'User Type', name: 'UserType', required: true, placeholder: 'Select a User Type', allowedValues: this.userTypeOptions, type: 'select', value: '' },
                            { label: 'First Name', name: 'FirstName', required: true, value: '' },
                            { label: 'Last Name', name: 'LastName', required: true, value: '' },
                            { label: 'Users unique email address (cannot be generic or shared)', name: 'UserEmail', required: true, type: 'email', value: '' },
                            { label: 'Site Number', name: 'SiteNumber', required: true, value: '' },
                            { label: 'Rights Group', name: 'RightsGroup', required: true, placeholder: 'Select a Rights Group', allowedValues: this.rightsGroupOptions, type: 'select', value: '' },
                            { label: 'Other Role', name: 'OtherRightsGroup', required: false, type: 'text', value: '', visible: false },
                            { label: 'Country', name: 'Country', required: true, type: 'select', placeholder: 'Select a Country', allowedValues: this.countryOptions, value: '' },
                            { label: 'Training Date', name: 'TrainingDate', required: true, type: 'date', value: '' },
                            { label: 'Training Location', name: 'TrainingLocation', required: false, placeholder: 'Select a Training Location', allowedValues: this.trainingLocationOptions, type: 'select', value: '' }
                        ],
                        'Biotech Rave': [
                            { label: 'First Name', name: 'FirstName', required: true, value: '' },
                            { label: 'Last Name', name: 'LastName', required: true, value: '' },
                            { label: 'Users unique email address (cannot be generic or shared)', name: 'UserEmail', required: true, type: 'email', value: '' },
                            { label: 'Site Number', name: 'SiteNumber', required: true, value: '' },
                            { label: 'Rave Module #1', name: 'RaveModule1', required: false, type: 'select', placeholder: 'Select a Rave Module #1', allowedValues: this.raveModule1Options, value: '' },
                            { label: 'Other Rave Module #1', name: 'OtherRaveModule1', required: false, type: 'text', value: '', visible: false },
                            { label: 'Rave Module #2', name: 'RaveModule2', required: false, type: 'select', placeholder: 'Select a Rave Module #2', allowedValues: this.raveModule2Options, value: '' },
                            { label: 'Other Rave Module #2', name: 'OtherRaveModule2', required: false, type: 'text', value: '', visible: false },
                            { label: 'Rave Role #1', name: 'RaveRole1', required: true, type: 'select', placeholder: 'Select a Rave Role #1', allowedValues: this.raveRole1Options, value: '' },
                            { label: 'Other Rave Role #1', name: 'OtherRaveRole1', required: false, type: 'text', value: '', visible: false },
                            { label: 'Rave Role #2', name: 'RaveRole2', required: false, type: 'select', placeholder: 'Select a Rave Role #2', allowedValues: this.raveRole2Options, value: '' },
                            { label: 'Other Rave Role #2', name: 'OtherRaveRole2', required: false, type: 'text', value: '', visible: false },
                            { label: 'RTSM (Balance)', name: 'RTSM', required: false, type: 'select', placeholder: 'Select a RTSM', allowedValues: this.rtsmOptions, value: '' },
                            { label: 'Coder', name: 'Coder', required: false, type: 'select', placeholder: 'Select a Coder', allowedValues: this.coderOptions, value: '' },
                            { label: 'Other Coder', name: 'OtherCoder', required: false, type: 'text', value: '', visible: false },
                            { label: 'Training Location', name: 'TrainingLocation', required: false, placeholder: 'Select a Training Location', allowedValues: this.trainingLocationOptions, type: 'select', value: '' },
                            { label: 'eCOA (Patient Cloud)', name: 'eCOA', required: false, placeholder: 'Select a eCOA', allowedValues: this.eCOAOptions, type: 'select', value: '' }
                        ]
                    }
                },
                {
                    label: 'Update User',
                    value: 'Update User',
                    additionalFields: {
                        'Biotech InForm': [
                            { label: 'User Type', name: 'UserType', required: false, placeholder: 'Select a User Type', allowedValues: this.userTypeOptions, type: 'select', value: '' },
                            { label: 'First Name', name: 'FirstName', required: true, value: '' },
                            { label: 'Last Name', name: 'LastName', required: true, value: '' },
                            { label: 'Users unique email address (cannot be generic or shared)', name: 'UserEmail', required: false, type: 'email', value: '' },
                            { label: 'Site Number', name: 'SiteNumber', required: false, value: '' },
                            { label: 'Rights Group', name: 'RightsGroup', required: false, placeholder: 'Select a Rights Group', allowedValues: this.rightsGroupOptions, type: 'select', value: '' },
                            { label: 'Other Role', name: 'OtherRightsGroup', required: false, type: 'text', value: '', visible: false },
                            { label: 'Country', name: 'Country', required: false, type: 'select', placeholder: 'Select a Country', allowedValues: this.countryOptions, value: '' }
                        ],
                        'Biotech Rave': [
                            { label: 'First Name', name: 'FirstName', required: true, value: '' },
                            { label: 'Last Name', name: 'LastName', required: true, value: '' },
                            { label: 'Users unique email address (cannot be generic or shared)', name: 'UserEmail', required: true, type: 'email', value: '' },
                            { label: 'Site Number', name: 'SiteNumber', required: false, value: '' },
                            { label: 'Rave Role #1', name: 'RaveRole1', required: false, type: 'select', placeholder: 'Select a Rave Role #1', allowedValues: this.raveRole1Options, value: '' },
                            { label: 'Other Rave Role #1', name: 'OtherRaveRole1', required: false, type: 'text', value: '', visible: false }

                        ]
                    }
                },
                {
                    label: 'Terminate User',
                    value: 'Terminate User',
                    additionalFields: {
                        'Biotech InForm': [
                            { label: 'First Name', name: 'FirstName', required: true, value: '' },
                            { label: 'Last Name', name: 'LastName', required: true, value: '' },
                            { label: 'Users unique email address (cannot be generic or shared)', name: 'UserEmail', required: false, type: 'email', value: '' }
                        ],
                        'Biotech Rave': [
                            { label: 'First Name', name: 'FirstName', required: false, value: '' },
                            { label: 'Last Name', name: 'LastName', required: false, value: '' },
                            { label: 'Users unique email address (cannot be generic or shared)', name: 'UserEmail', required: true, type: 'email', value: '' }

                        ]
                    }
                },
                {
                    label: 'Reinstate User',
                    value: 'Reinstate User',
                    additionalFields: {
                        'Biotech InForm': [
                            { label: 'First Name', name: 'FirstName', required: true, value: '' },
                            { label: 'Last Name', name: 'LastName', required: true, value: '' },
                            { label: 'Users unique email address (cannot be generic or shared)', name: 'UserEmail', required: false, type: 'email', value: '' },
                            { label: 'Rights Group', name: 'RightsGroup', required: false, placeholder: 'Select a Rights Group', allowedValues: this.rightsGroupOptions, type: 'select', value: '' },
                            { label: 'Other Role', name: 'OtherRightsGroup', required: false, type: 'text', value: '', visible: false }
                        ]
                    }
                },
                {
                    label: 'Create Site',
                    value: 'Create Site',
                    additionalFields: {
                        'Biotech InForm': [
                            { label: 'Site Number', name: 'SiteNumber', required: true, value: '' },
                            { label: 'Country', name: 'Country', required: true, type: 'select', placeholder: 'Select a Country', allowedValues: this.countryOptions, value: '' },
                            { label: 'Time Zone', name: 'TimeZone', required: true, type: 'select', placeholder: 'Select a Time Zone', allowedValues: this.timeZoneOptions, value: '' },
                            { label: 'Site Name', name: 'SiteName', required: true, value: '' },
                            { label: 'Street', name: 'Street', required: false, value: '' },
                            { label: 'City', name: 'City', required: false, value: '' },
                            { label: 'State/Province', name: 'State', required: false, value: '' },
                            { label: 'Zip/Post Code', name: 'Zip', required: false, value: '' }
                        ],
                        'Biotech Rave': [
                            { label: 'Site Number', name: 'SiteNumber', required: true, value: '' },
                            { label: 'Country', name: 'Country', required: true, type: 'select', placeholder: 'Select a Country', allowedValues: this.countryOptions, value: '' },
                            { label: 'Time Zone', name: 'TimeZone', required: true, type: 'select', placeholder: 'Select a Time Zone', allowedValues: this.timeZoneOptions, value: '' },
                            { label: 'Site Name', name: 'SiteName', required: true, value: '' },
                            { label: 'Street', name: 'Street', required: true, value: '' },
                            { label: 'City', name: 'City', required: true, value: '' },
                            { label: 'State/Province', name: 'State', required: true, value: '' },
                            { label: 'Zip/Post Code', name: 'Zip', required: true, value: '' },
                            { label: 'PI Email Address', name: 'PIEmailAddress', required: false, value: '' },
                            { label: 'PI First Name', name: 'PIFirstName', required: false, value: '' },
                            { label: 'PI Last Name', name: 'PILastName', required: false, value: '' },
                            { label: 'PI Start Date', name: 'PIStartDate', required: false, type: 'date', value: '' }
                        ]
                    }
                },
                {
                    label: 'Update Site',
                    value: 'Update Site',
                    additionalFields: {
                        'Biotech InForm': [
                            { label: 'Site Number', name: 'SiteNumber', required: true, value: '' },
                            { label: 'Country', name: 'Country', required: false, type: 'select', placeholder: 'Select a Country', allowedValues: this.countryOptions, value: '' },
                            { label: 'Time Zone', name: 'TimeZone', required: false, type: 'select', placeholder: 'Select a Time Zone', allowedValues: this.timeZoneOptions, value: '' },
                            { label: 'Site Name', name: 'SiteName', required: false, value: '' },
                            { label: 'Street', name: 'Street', required: false, value: '' },
                            { label: 'City', name: 'City', required: false, value: '' },
                            { label: 'State/Province', name: 'State', required: false, value: '' },
                            { label: 'Zip/Post Code', name: 'Zip', required: false, value: '' }
                        ],
                        'Biotech Rave': [
                            { label: 'Site Number', name: 'SiteNumber', required: true, value: '' },
                            { label: 'Country', name: 'Country', required: false, type: 'select', placeholder: 'Select a Country', allowedValues: this.countryOptions, value: '' },
                            { label: 'Time Zone', name: 'TimeZone', required: false, type: 'select', placeholder: 'Select a Time Zone', allowedValues: this.timeZoneOptions, value: '' },
                            { label: 'Site Name', name: 'SiteName', required: false, value: '' },
                            { label: 'Street', name: 'Street', required: true, value: '' },
                            { label: 'City', name: 'City', required: true, value: '' },
                            { label: 'State/Province', name: 'State', required: true, value: '' },
                            { label: 'Zip/Post Code', name: 'Zip', required: true, value: '' },
                            { label: 'PI Email Address', name: 'PIEmailAddress', required: false, value: '' },
                            { label: 'PI First Name', name: 'PIFirstName', required: false, value: '' },
                            { label: 'PI Last Name', name: 'PILastName', required: false, value: '' },
                            { label: 'PI Start Date', name: 'PIStartDate', required: false, type: 'date', value: '' }
                        ]
                    }
                },
                {
                    label: 'Terminate Site',
                    value: 'Terminate Site',
                    additionalFields: {
                        'Biotech InForm': [
                            { label: 'Site Number', name: 'SiteNumber', required: true, value: '' },
                            { label: 'Site Name', name: 'SiteName', required: false, value: '' }
                        ],
                        'Biotech Rave': [
                            { label: 'Site Number', name: 'SiteNumber', required: true, value: '' },
                            { label: 'Site Name', name: 'SiteName', required: false, value: '' }
                        ]
                    }
                },
                {
                    label: 'InForm Training',
                    value: 'Please Specify',
                    additionalFields: {
                        'Biotech InForm': [
                            { label: 'Please fill out this document and upload it as an attachment in this request, as it is mandatory to proceed:', href: '', value: 'InformTraining', name: 'DocToDownload', textLink: 'inform Training doc', type: 'link', isOptionalElement: true },
                            { label: 'Attachments', name: 'Attachments', required: true, type: 'upload' }
                        ]
                    }
                },
               /* {
                    label: 'Database Lock',
                    value: 'Database Lock',
                    additionalFields: {
                        'Biotech InForm': [
                            { label: 'I acknowledge all mandatory fields are filled in the attached DB lock form', name: 'FilledDBLockForm', required: true, type: 'checkbox', helpText: '"All users will be removed to the RO role" Please add any study specific role requirements in the comments', value: false }
                        ],
                        'Biotech Rave': [
                            { label: 'I acknowledge all mandatory fields are filled in the attached DB lock form', name: 'FilledDBLockForm', required: true, type: 'checkbox', helpText: '"All users will be removed to the RO role" Please add any study specific role requirements in the comments', value: false }
                        ]
                    }
                },*/
                {
                    label: 'Study Decommission',
                    value: 'Study Decommission',
                    additionalFields: {
                        'Biotech Rave': [
                            { label: 'Sudy Decomission', name: 'SudyDecomission', required: false, value: '', helpText: 'Study Decomission (this is selected if the request is to remove all users in EDC as part of the post DB lock activities)' }
                        ]
                    }
                },
                {
                    label: 'Create Depot',
                    value: 'Create Depot',
                    additionalFields: {
                        'Biotech Rave': [
                            { label: 'Name', name: 'Name', required: true, value: '' },
                            { label: 'Number', name: 'Number', required: false, value: '' },
                            { label: 'Address Line 1', name: 'AddressLine1', required: false, value: '' },
                            { label: 'Address Line 2', name: 'AddressLine2', required: false, value: '' },
                            { label: 'Address Line 3', name: 'AddressLine3', required: false, value: '' },
                            { label: 'Country', name: 'Country', required: false, value: '' },
                            { label: 'City', name: 'City', required: false, value: '' },
                            { label: 'Postal Code', name: 'PostalCode', required: false, value: '' },
                            { label: 'Contact Phone at the Depot', name: 'ContactPhoneDepot', required: false, value: '' },
                            { label: 'Fax', name: 'Fax', required: false, value: '' },
                            { label: 'Contact Name at the Depot', name: 'ContactNameDepot', required: false, value: '' },
                            { label: 'Preferred Carrier', name: 'Preferred Carrier', required: false, value: '' }
                        ]
                    }
                }
            ],
            type: 'select',
            value: ''
        },
        {
            label: 'Subtype 3',
            name: SUBTYPE3__C,
            required: true,
            placeholder: 'Select a Subtype 3',
            allowedValues: [
                { label: 'Please Specify', value: 'Please Specify' }
            ],
            type: 'select',
            value: 'Please Specify',
            visible: false
        },
        {
            label: 'Case Origin', name: 'Origin', required: true, value: 'Customer Portal', visible: false
        },
        {
            label: 'Current Queue', name: 'Current_Queue__c', required: true, value: 'a0KDf00000A6AtFMAV', visible: false
        },
        {
            label: 'Case Source', name: 'CaseSource__c', required: true, value: 'Customer', visible: false
        },
        {
            label: 'Additional Information',
            name: 'Description',
            required: false,
            placeholder: 'Enter Additional Information',
            type: 'textArea',
            value: ''
        },
        {
            type: 'infoMessage',
            name: 'important',
            isOptionalElement: true,
            value: '<p><b>Important:</b><br>By completing this form, I confirm that any new user has been trained on the EDC application and relevant processes, and training was documented, as per study requirements.</p>'
        }
    ];

    @track isLoading = false;
    @track additionalFields = [];
    @track contentDocumentIds = [];
    originalSubType2Options = [];
    contact;

    connectedCallback() { 
        this.initializeComponent();
    }

    async initializeComponent() {
        try {
            this.isLoading = true;
            this.fields = this.fields.map(field => this.getFieldProperties(field));
            const subType2Field = this.getField(SUBTYPE2__C);
            if (subType2Field) {
                this.originalSubType2Options = [...subType2Field.allowedValues];
            }
            await this.getCurrentUserContact();
            await this.getAllowedStories();
        } catch (error) {
            console.error('Error initializing component:', error);
        } finally {
            this.isLoading = false;
        }
    }

    async getAllowedStories() {
        try {
            const result = await getAllowedStories();
            const studyField = this.getField('Study__c');
            if (studyField && result) {
                studyField.allowedValues = result.map(study => ({
                    label: study.Name,
                    value: study.Id
                }));
            }
        } catch (error) {
            console.error('Error fetching studies:', error);
        }
    }

    async getCurrentUserContact() {
        try {
            const data = await getUserContact();
            if (data && data.length > 0) {
                const contactField = this.getField('ContactId');
                const accountField = this.getField('AccountId');
                contactField.value = data[0].Id;
                accountField.value = data[0].AccountId;
                this.contact = data[0];
            } else {
                console.warn('No contact data returned.');
            }
        } catch (error) {
            console.error('Error fetching Contact ID:', error);
        }
    }

    async getStaticResourceUrl(fieldName, fileName) {
        try {
            this.isLoading = true;
            const result = await getStaticResourceUrl({ name: fileName });
            const doc = this.getAdditionalField(fieldName);
            if (doc) {
                doc.href = '/support' + result;
            }
        } catch (error) {
            console.error('Error fetching static resource URL:', error);
        } finally {
            this.isLoading = false;
        }
    }

    async getCategorizationId(los, subtype1, subtype2, subtype3) { 
        try {
            this.isLoading = true;
            const data = await getCategorizationId({ los, subtype1, subtype2, subtype3 });
            if (data && data.length > 0) {
                const categorizationIdField = this.getField('Case_CategorizationId__c');
                if (categorizationIdField) {
                    categorizationIdField.value = data[0].Id;
                } else {
                    console.warn('Case_CategorizationId__c field not found.');
                }
            } else {
                console.warn('No data returned for categorization ID.');
            }
            console.log('getCategorizationId response:', data);
        } catch (error) {
            console.error('Error fetching Case_Categorization ID:', error);
        } finally {
            this.isLoading = false;
        }
    }


    handleInputChange(event) {
        const fieldName = event.target.dataset.field;
        const value = event.target.type === 'checkbox' ? event.target.checked : event.target.value;

        const field = this.getField(fieldName);
        if (field) {
            field.value = value;
        }

        if (fieldName === SUBTYPE1__C) {
            this.updateSubType2Options();
        }

        if (fieldName === SUBTYPE2__C) {
            this.updateAdditionalFields();
        }

        if (fieldName === SUBTYPE1__C || fieldName === SUBTYPE2__C || fieldName === LOS__C) {
            this.handleCategorizationChange();
        }

        this.updateAdditionalFieldValue(fieldName, value);
    }

    // Function to handle changes to SubType1, SubType2, and Los
    handleCategorizationChange() {
        const selectedSubType1 = this.getFieldValue(SUBTYPE1__C);
        const selectedSubType2 = this.getFieldValue(SUBTYPE2__C);
        const selectedSubType3 = this.getFieldValue(SUBTYPE3__C);
        const selectedLos = this.getFieldValue(LOS__C);

        if (selectedLos && selectedSubType1 && selectedSubType2 && selectedSubType3) {
            this.getCategorizationId(selectedLos, selectedSubType1, selectedSubType2, selectedSubType3);
        }
    }

    // Function to update allowed values for SubType2 based on SubType1
    updateSubType2Options() {
        const selectedSubType1 = this.getFieldValue(SUBTYPE1__C);
        const subType2Field = this.getField(SUBTYPE2__C);

        subType2Field.allowedValues = this.originalSubType2Options.filter(option =>
            option.additionalFields && option.additionalFields[selectedSubType1]
        );
        subType2Field.value = '';
        this.additionalFields = [];
    }

    // Function to update additional fields based on SubType2 and SubType1
    updateAdditionalFields() {
        const selectedSubType1 = this.getFieldValue(SUBTYPE1__C);
        const selectedSubType2 = this.getFieldValue(SUBTYPE2__C);

        const subtype2Option = this.getField(SUBTYPE2__C).allowedValues.find(option => option.value === selectedSubType2);
        const additionalFields = subtype2Option ? subtype2Option.additionalFields[selectedSubType1] : [];

        this.additionalFields = additionalFields.map(f => this.getFieldProperties(f));

        this.additionalFields.forEach(field => {
            if (field.type === 'link') {
                this.getStaticResourceUrl(field.name, field.value);
            }
        });
    }

    // Helper to update the value of an additional field
    updateAdditionalFieldValue(fieldName, value) {
        const additionalField = this.getAdditionalField(fieldName);
        if (additionalField) {
            additionalField.value = value;

            // Handle visibility for 'Other' fields in case of a select input
            if (additionalField.type === 'select') {
                const otherFieldName = `${OTHER}${fieldName}`;
                const existingOtherField = this.getAdditionalField(otherFieldName);

                if (existingOtherField) {
                    existingOtherField.isVisible = value === OTHER;
                    existingOtherField.required = value === OTHER;
                }
            }
        }
    }

    // Utility to get a field value
    getFieldValue(fieldName) {
        const field = this.fields.find(f => f.name === fieldName);
        return field ? field.value : '';
    }

    // Utility to get a field by name
    getField(fieldName) {
        return this.fields.find(f => f.name === fieldName);
    }

    getAdditionalFieldValue(fieldName) {
        const additionalField = this.additionalFields.find(f => f.name === fieldName);
        return additionalField ? additionalField.value : '';
    }

    getAdditionalField(fieldName) {
        return this.additionalFields.find(f => f.name === fieldName);
    }


    get mergedFields() {
        let mergedFields = [];
        let additionalFieldsInserted = false;

        this.fields.forEach((field) => {
            mergedFields.push(field);
            if (field.name === SUBTYPE2__C && this.additionalFields.length && !additionalFieldsInserted) {
                mergedFields = [...mergedFields, ...this.additionalFields];
                additionalFieldsInserted = true;
            }
        });

        return mergedFields;
    }

    handleContentDocumentAdded(event) {
        const { data: contentDocumentIds, names: contentDocumentNames } = event.detail;
        const attachmentsField = this.getAdditionalField('Attachments');
        if (attachmentsField) {
            const existingAttachments = this.getAdditionalFieldValue('Attachments') ?? [];
            attachmentsField.value = [...existingAttachments, ...contentDocumentNames];
        }
        this.contentDocumentIds = [...this.contentDocumentIds, ...contentDocumentIds];
    }

    handleContentDocumentDeleted(event) {
        const { data: deletedId, documentName: contentDocumentName } = event.detail;
        const attachmentsField = this.getAdditionalField('Attachments');
        if (attachmentsField) {
            attachmentsField.value = (this.getAdditionalFieldValue('Attachments') ?? []).filter(name => name !== contentDocumentName);
        }
        this.contentDocumentIds = this.contentDocumentIds.filter(id => id !== deletedId);
    }

    handleSubmit() {
        const subjectField = this.getField('Subject');
        const los = this.getFieldValue(LOS__C);
        const subType1 = this.getFieldValue(SUBTYPE1__C);
        const subType2 = this.getFieldValue(SUBTYPE2__C);
        const contactName = this.contact.Name;
        subjectField.value = `${los} request - ${subType1} - ${subType2} - ${contactName}`;

        const fields = this.fields.reduce((acc, field) => {
            if (field.isOptionalElement === undefined || field.isOptionalElement !== true) {
                acc[field.name] = field.value;
            }
            return acc;
        }, {});

        let isValid = true;
        let errorMessage = '';
        this.fields.forEach(field => {
            if (field.required && !field.value) {
                isValid = false;
                errorMessage += `${field.label} is required.\n`;
            }
        });

        this.additionalFields.forEach(field => {
            if (field.required) {
                if (field.type !== 'upload' && !field.value) {
                    isValid = false;
                    errorMessage += `${field.label} is required.\n`;
                } else if (field.type === 'upload' && this.contentDocumentIds.length < 1) {
                    isValid = false;
                    errorMessage += `${field.label} is required.\n`;
                }
            }
        });

        if (!isValid) {
            this.showToast('Error', errorMessage, 'error');
            return;
        }

        let additionalInfo = '';
        this.additionalFields.forEach(field => {
            if (field.isOptionalElement === undefined || field.isOptionalElement !== true) {
                additionalInfo += `${field.label}: ${field.value}\n`;
            }
        });

        fields['Description'] = this.getFieldValue('Description') + '\n' + additionalInfo;

        console.log('Creating Case with fields:', fields);
        this.createCase(fields);

    }

    async createCase(fields) {
        this.isLoading = true;
        try {
            const caseId = await createCase({ fields, contentDocumentIds: this.contentDocumentIds });
            console.log('Case created successfully with Id: ', caseId);
            this.showToast('Success', 'Case created successfully!', 'success');
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: '/case/' + caseId
                }
            });
        } catch (error) {
            console.error('Error creating case: ', error);
            this.showToast('Error', 'Failed to create case: ' + error.body.message, 'error');
        } finally {
            this.isLoading = false;
        }
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }

    getFieldProperties(field) {
        return {
            ...field,
            isSelect: field.type === 'select',
            isDate: field.type === 'date',
            isEmail: field.type === 'email',
            isTextArea: field.type === 'textArea',
            isCheckbox: field.type === 'checkbox',
            isInfoMessage: field.type === 'infoMessage',
            isUpload: field.type === 'upload',
            isLink: field.type === 'link',
            isText: !field.type || field.type === 'text',
            isVisible: field.visible === undefined || field.visible === true
        };
    }
}