<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>AGG_ET11_PSA_Planned_Date_for_Medical_Review_Sent_Change_Notification</fullName>
        <description>AGG ET11 PSA Planned Date for Medical Review Sent Change Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Primary_Medical_Reviewer__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>no.reply.support@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PSA_Templates/AGG_ET13_Planned_Date_for_Medical_Review_Sent_Change_Notification</template>
    </alerts>
    <alerts>
        <fullName>AGG_ET12_PSA_New_Primary_Medical_Reviewer_Notification</fullName>
        <description>AGG ET12 PSA New Primary Medical Reviewer Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Primary_Medical_Reviewer__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>no.reply.support@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PSA_Templates/AGG_ET12_PSA_New_Primary_Medical_Reviewer_Notification</template>
    </alerts>
    <alerts>
        <fullName>AGG_WEA01_PSA_NS_Completed_Report_Notification</fullName>
        <description>AGG WEA01 PSA NS Completed Report Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Primary_Author__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>no.reply.support@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PSA_Templates/AGG_ET01_PSA_NS_Completed_Report_Notification</template>
    </alerts>
    <alerts>
        <fullName>AGG_WEA02_PSA_SG_Completed_Report_Notification</fullName>
        <description>AGG WEA02 PSA SG Completed Report Notification</description>
        <protected>false</protected>
        <recipients>
            <field>IQVIA_Primary_GSO__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>IQVIA_Primary_PV_Scientist__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>IQVIA_TAH__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>no.reply.support@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PSA_Templates/AGG_ET02_PSA_SG_Completed_Report_Notification</template>
    </alerts>
    <alerts>
        <fullName>AGG_WEA03_PSA_NS_Change_Primary_Author_Notification</fullName>
        <description>AGG WEA03 PSA NS Change Primary Author Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Primary_Author__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>no.reply.support@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PSA_Templates/AGG_ET03_PSA_NS_New_Author_Assignment_Notification</template>
    </alerts>
    <alerts>
        <fullName>AGG_WEA04_PSA_NS_Relieve_Primary_Author_Notification</fullName>
        <description>AGG WEA04 PSA NS Relieve Primary Author Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Prior_Author_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PSA_Templates/AGG_ET04_PSA_NS_Author_Relief_Notification</template>
    </alerts>
    <alerts>
        <fullName>AGG_WEA05_PSA_SG_Primary_Scientist_Assignment_Notification</fullName>
        <description>AGG WEA05 PSA SG Primary Scientist Assignment Notification</description>
        <protected>false</protected>
        <recipients>
            <field>IQVIA_Primary_PV_Scientist__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>no.reply.support@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PSA_Templates/AGG_ET05_PSA_SG_Primary_Scientist_Notification</template>
    </alerts>
    <alerts>
        <fullName>AGG_WEA06_PSA_SG_Backup_Scientist_Assignment_Notification</fullName>
        <description>AGG WEA06 PSA SG Backup Scientist Assignment Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Back_up_PV_Scientist__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>no.reply.support@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PSA_Templates/AGG_ET06_PSA_SG_Back_up_Scientist_Notification</template>
    </alerts>
    <alerts>
        <fullName>AGG_WEA07_PSA_SG_Primary_QC_Reviewer_Assignment_Notification</fullName>
        <description>AGG WEA07 PSA SG Primary QC Reviewer Assignment Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Primary_QC_Reviewer__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>no.reply.support@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PSA_Templates/AGG_ET07_PSA_SG_QC_Reviewer_Assignment_Notification</template>
    </alerts>
    <alerts>
        <fullName>AGG_WEA08_PSA_SG_Secondary_QC_Reviewer_Assignment_Notification</fullName>
        <description>AGG WEA08 PSA SG Secondary QC Reviewer Assignment Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Secondary_QC_Reviewer__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PSA_Templates/AGG_ET08_PSA_SG_QC_Reviewer_Assignment_Notification</template>
    </alerts>
    <alerts>
        <fullName>AGG_WEA09_PSA_SG_Primary_GSO_Assignment_Notification</fullName>
        <description>AGG WEA09 PSA SG Primary GSO Assignment Notification</description>
        <protected>false</protected>
        <recipients>
            <field>IQVIA_Primary_GSO__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>no.reply.support@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PSA_Templates/AGG_ET09_PSA_SG_Primary_GSO_Assignment_Notification</template>
    </alerts>
    <alerts>
        <fullName>AGG_WEA10_PSA_SG_Secondary_GSO_Assignment_Notification</fullName>
        <description>AGG WEA10 PSA SG Secondary GSO Assignment Notification</description>
        <protected>false</protected>
        <recipients>
            <field>IQVIA_Secondary_GSO__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>no.reply.support@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PSA_Templates/AGG_ET10_PSA_SG_Secondary_GSO_Assignment_Notification</template>
    </alerts>
    <alerts>
        <fullName>AGG_WEA11_PSA_SG_Primary_PV_Scientist_Reassignment</fullName>
        <description>AGG WEA11 PSA SG Primary PV Scientist Reassignment</description>
        <protected>false</protected>
        <recipients>
            <field>IQVIA_Primary_GSO__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>IQVIA_TAH__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>no.reply.support@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PSA_Templates/AGG_ET11_Primary_PV_Scientist_Replacement_Email</template>
    </alerts>
    <alerts>
        <fullName>AGG_WEA12_PSA_New_Primary_Medical_Reviewer_Notification</fullName>
        <description>AGG WEA12 PSA New Primary Medical Reviewer Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Primary_Medical_Reviewer__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>no.reply.support@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PSA_Templates/AGG_ET14_PSA_New_Primary_Medical_Reviewer_Notification</template>
    </alerts>
    <alerts>
        <fullName>AGG_WEA13_PSA_Relieve_Primary_Medical_Reviewer_Notification</fullName>
        <description>AGG WEA13 PSA Relieve Primary Medical Reviewer Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Prior_Primary_Medical_Reviewer_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>no.reply.support@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PSA_Templates/AGG_ET15_PSA_Primary_Medical_Reviewer</template>
    </alerts>
    <alerts>
        <fullName>AGG_WEA14_PSA_New_Secondary_Medical_Reviewer_Notification</fullName>
        <description>AGG WEA14 PSA New Secondary Medical Reviewer Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Secondary_Medical_Reviewer__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>no.reply.support@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PSA_Templates/AGG_ET16_PSA_New_Secondary_Medical_Reviewer_Notification</template>
    </alerts>
    <alerts>
        <fullName>AGG_WEA15_PSA_Relieve_Secondary_Medical_Reviewer_Notification</fullName>
        <description>AGG WEA15 PSA Relieve Secondary Medical Reviewer Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Prior_Secondary_Medical_Reviewer_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>no.reply.support@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PSA_Templates/AGG_ET17_PSA_Secondary_Medical_Reviewer</template>
    </alerts>
    <alerts>
        <fullName>AGG_WEA16_PSA_New_Primary_BRM_Analyst_Notification</fullName>
        <description>AGG WEA16 PSA New Primary BRM Analyst Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Primary_BRM_Analyst__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>no.reply.support@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PSA_Templates/AGG_ET18_PSA_New_Primary_BRM_Analyst_Notification</template>
    </alerts>
    <alerts>
        <fullName>AGG_WEA17_PSA_Relieve_Primary_BRM_Analyst_Notification</fullName>
        <description>AGG WEA17 PSA Relieve Primary BRM Analyst Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Prior_Primary_BRM_Analyst_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>no.reply.support@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PSA_Templates/AGG_ET19_PSA_Relieve_Primary_BRM_Analyst_Notification</template>
    </alerts>
    <alerts>
        <fullName>AGG_WEA18_PSA_New_Secondary_BRM_Analyst_Notification</fullName>
        <description>AGG WEA18 PSA New Secondary BRM Analyst Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Secondary_BRM_Analyst__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>no.reply.support@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PSA_Templates/AGG_ET20_PSA_New_Secondary_BRM_Analyst_Notification</template>
    </alerts>
    <alerts>
        <fullName>AGG_WEA19_PSA_Relieve_Secondary_BRM_Analyst_Notification</fullName>
        <description>AGG WEA19 PSA Relieve Secondary BRM Analyst Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Prior_Secondary_BRM_Analyst_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>no.reply.support@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PSA_Templates/AGG_ET21_PSA_Relieve_Secondary_BRM_Analyst_Notification</template>
    </alerts>
    <alerts>
        <fullName>AGG_WEA20_PSA_New_Primary_QC_Reviewer_Notification</fullName>
        <description>AGG WEA20 PSA New Primary QC Reviewer Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Primary_QC_Reviewer__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>no.reply.support@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PSA_Templates/AGG_ET22_PSA_New_Primary_QC_Reviewer_Notification</template>
    </alerts>
    <alerts>
        <fullName>AGG_WEA21_PSA_Relieve_Primary_QC_Reviewer_Notification</fullName>
        <description>AGG WEA21 PSA Relieve Primary QC Reviewer Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Prior_Primary_QC_Reviewer_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>no.reply.support@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PSA_Templates/AGG_ET23_PSA_Relieve_Primary_QC_Reviewer_Notification</template>
    </alerts>
    <alerts>
        <fullName>AGG_WEA22_PSA_New_Secondary_QC_Reviewer_Notification</fullName>
        <description>AGG WEA22 PSA New Secondary QC Reviewer Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Secondary_QC_Reviewer__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>no.reply.support@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PSA_Templates/AGG_ET24_PSA_New_Secondary_QC_Reviewer_Notification</template>
    </alerts>
    <alerts>
        <fullName>AGG_WEA23_PSA_Relieve_Secondary_QC_Reviewer_Notification</fullName>
        <description>AGG WEA23 PSA Relieve Secondary QC Reviewer Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Prior_Secondary_QC_Reviewer_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>no.reply.support@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PSA_Templates/AGG_ET25_PSA_Relieve_Secondary_QC_Reviewer_Notification</template>
    </alerts>
    <alerts>
        <fullName>AGG_WEA24_PSA_New_Coordinator_Notification</fullName>
        <description>AGG WEA24 PSA New Coordinator Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Coordinator__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>no.reply.support@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PSA_Templates/AGG_ET26_PSA_New_Coordinator_Notification</template>
    </alerts>
    <alerts>
        <fullName>AGG_WEA25_PSA_Relieve_Coordinator_Notification</fullName>
        <description>AGG WEA25 PSA Relieve Coordinator Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Prior_Coordinator_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>no.reply.support@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PSA_Templates/AGG_ET27_PSA_Relieve_Coordinator_Notification</template>
    </alerts>
    <alerts>
        <fullName>AGG_WEA26_PSA_New_Line_Listing_Reviewer_Notification</fullName>
        <description>AGG WEA26 PSA New Line Listing Reviewer Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Line_Listing_Reviewer__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>no.reply.support@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PSA_Templates/AGG_ET28_PSA_New_Line_Listing_Reviewer_Notification</template>
    </alerts>
    <alerts>
        <fullName>AGG_WEA27_PSA_Relieve_Line_Listing_Reviewer_Notification</fullName>
        <description>AGG WEA27 PSA Relieve Line Listing Reviewer Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Prior_Line_Listing_Reviewer_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>no.reply.support@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PSA_Templates/AGG_ET29_PSA_Relieve_Line_Listing_Reviewer_Notification</template>
    </alerts>
    <alerts>
        <fullName>AGG_WEA28_PSA_New_Line_Listing_Qcer_Notification</fullName>
        <description>AGG WEA28 PSA New Line Listing Qcer Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Line_Listing_QCer__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>no.reply.support@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PSA_Templates/AGG_ET30_PSA_New_Line_Listing_Qcer_Notification</template>
    </alerts>
    <alerts>
        <fullName>AGG_WEA29_PSA_Relieve_Line_Listing_Qcer_Notification</fullName>
        <description>AGG WEA29 PSA Relieve Line Listing Qcer Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Prior_Line_Listing_Qcer_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>no.reply.support@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PSA_Templates/AGG_ET31_PSA_Relieve_Line_Listing_Qcer_Notification</template>
    </alerts>
    <alerts>
        <fullName>AGG_WEA30_PSA_New_Secondary_Author_Notification</fullName>
        <description>AGG WEA30 PSA New Secondary Author Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Secondary_Author__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>no.reply.support@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PSA_Templates/AGG_ET32_PSA_New_Secondary_Author_Notification</template>
    </alerts>
    <alerts>
        <fullName>AGG_WEA31_PSA_Relieve_Secondary_Author_Notification</fullName>
        <description>AGG WEA31 PSA Relieve Secondary Author Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Prior_Secondary_Author_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>no.reply.support@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PSA_Templates/AGG_ET33_PSA_Relieve_Secondary_Author_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>AGG_WFU01_PSA_NS_Prior_Author_Email</fullName>
        <description>PSA-CLD-IQVIAPSA-1225- Non-Sanofi Store Prior Author Value</description>
        <field>Prior_Author_Email__c</field>
        <formula>Primary_Author__r.Email</formula>
        <name>AGG WFU01 PSA NS Prior Author Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AGG_WFU_SG_PSA_Update_Prior_PV_Scientist</fullName>
        <description>PSA-CLD-IQVIAPSA-1224</description>
        <field>Prior_PV_Scientist__c</field>
        <formula>IQVIA_Primary_PV_Scientist__r.psa_report__Resource_Name__c</formula>
        <name>AGG WFU SG PSA Update Prior PV Scientist</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>AGG ET13 Planned Date for Medical Review Sent Change Notification</fullName>
        <actions>
            <name>AGG_ET11_PSA_Planned_Date_for_Medical_Review_Sent_Change_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>PSA-MC-IQVIAPSA-2624- Planned Date for Medical Review Sent Change Notification</description>
        <formula>AND(OR( RecordType.DeveloperName = &apos;General_Report&apos;, RecordType.DeveloperName = &apos;RA_Response&apos;, RecordType.DeveloperName = &apos;Takeda_Report&apos;), ISCHANGED(Planned_Date_for_Medical_Review_Sent__c) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>AGG WR01 PSA NS Completed Report Notification</fullName>
        <actions>
            <name>AGG_WEA01_PSA_NS_Completed_Report_Notification</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>PSA-CLD-IQVIAPSA-1225- Non-Sanofi Aggregate Reporting Completion Email</description>
        <formula>AND(  RecordType.DeveloperName &lt;&gt; &apos;Sanofi_PVS_Report&apos;,  RecordType.DeveloperName &lt;&gt; &apos;Sanofi_GSO_Report&apos;,  ISPICKVAL( Status__c , &apos;Completed&apos;)  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AGG WR02 PSA SG Completed Report Notification</fullName>
        <actions>
            <name>AGG_WEA02_PSA_SG_Completed_Report_Notification</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>PSA-CLD-IQVIAPSA-1224- Sanofi-Galen Aggregate Reporting Completion Email</description>
        <formula>AND( OR( RecordType.Name = &apos;Sanofi PVS Report&apos;,  RecordType.Name = &apos;Sanofi GSO Report&apos;), ISPICKVAL( Status__c , &apos;Completed&apos;)  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AGG WR03 PSA NS Change Primary Author Notification</fullName>
        <actions>
            <name>AGG_WEA03_PSA_NS_Change_Primary_Author_Notification</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>AGG_WEA04_PSA_NS_Relieve_Primary_Author_Notification</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>PSA-CLD-IQVIAPSA-1225- Non-Sanofi Author Assignment Email</description>
        <formula>AND(  RecordType.DeveloperName &lt;&gt; &apos;Sanofi_PVS_Report&apos;,  RecordType.DeveloperName &lt;&gt; &apos;Sanofi_GSO_Report&apos;,  ISPICKVAL(Status__c, &apos;Completed&apos;) = False,  ISPICKVAL(Status__c, &apos;Cancelled&apos;) = False,    Primary_Author__r.Email &lt;&gt; Prior_Author_Email__c,   Primary_Author__c &lt;&gt; Null )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>AGG_WFU01_PSA_NS_Prior_Author_Email</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>AGG WR04 PSA SG Primary Scientist Assignment Notification</fullName>
        <actions>
            <name>AGG_WEA05_PSA_SG_Primary_Scientist_Assignment_Notification</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>PSA-CLD-IQVIAPSA-1224- Sanofi-Galen Primary Scientist Assignment Notification</description>
        <formula>AND( OR( RecordType.Name = &apos;Sanofi PVS Report&apos;, RecordType.Name = &apos;Sanofi GSO Report&apos;), OR( AND(ISNEW(),NOT(ISBLANK(IQVIA_Primary_PV_Scientist__c))), ISCHANGED( IQVIA_Primary_PV_Scientist__c ) = True), ISPICKVAL (Status__c, &apos;Completed&apos;) = False)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>AGG WR05 PSA SG Backup Scientist Assignment Notification</fullName>
        <actions>
            <name>AGG_WEA06_PSA_SG_Backup_Scientist_Assignment_Notification</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>PSA-CLD-IQVIAPSA-1224- Sanofi-Galen Back up Scientist Assignment Notification</description>
        <formula>AND( OR( RecordType.Name = &apos;Sanofi PVS Report&apos;, RecordType.Name = &apos;Sanofi GSO Report&apos;), ISCHANGED(  Back_up_PV_Scientist__c  ) = True, ISPICKVAL (Status__c, &apos;Completed&apos;) = False)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>AGG WR06 PSA SG Primary QC Reviewer Assignment Notification</fullName>
        <actions>
            <name>AGG_WEA07_PSA_SG_Primary_QC_Reviewer_Assignment_Notification</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>PSA-CLD-IQVIAPSA-1224- Sanofi-Galen Primary QC Reviewer Assignment Notification</description>
        <formula>AND( OR( RecordType.Name = &apos;Sanofi PVS Report&apos;, RecordType.Name = &apos;Sanofi GSO Report&apos;), ISCHANGED(  Primary_QC_Reviewer__c) = True, ISPICKVAL (Status__c, &apos;Completed&apos;) = False)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>AGG WR07 PSA SG Secondary QC Reviewer Assignment Notification</fullName>
        <actions>
            <name>AGG_WEA08_PSA_SG_Secondary_QC_Reviewer_Assignment_Notification</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>PSA-CLD-IQVIAPSA-1224- Sanofi-Galen Secondary QC Reviewer Assignment Notification</description>
        <formula>AND( OR( RecordType.Name = &apos;Sanofi PVS Report&apos;, RecordType.Name = &apos;Sanofi GSO Report&apos;), ISCHANGED( Secondary_QC_Reviewer__c ) = True, ISPICKVAL (Status__c, &apos;Completed&apos;) = False)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>AGG WR08 PSA SG Primary GSO Assignment Notification</fullName>
        <actions>
            <name>AGG_WEA09_PSA_SG_Primary_GSO_Assignment_Notification</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>PSA-CLD-IQVIAPSA-1224- Sanofi-Galen Primary GSO Assignment Notification</description>
        <formula>AND( OR( RecordType.Name = &apos;Sanofi PVS Report&apos;, RecordType.Name = &apos;Sanofi GSO Report&apos;), OR( AND(ISNEW(),NOT(ISBLANK(IQVIA_Primary_GSO__c))), ISCHANGED( IQVIA_Primary_GSO__c ) = True), ISPICKVAL (Status__c, &apos;Completed&apos;) = False)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>AGG WR09 PSA SG Primary PV Scientist Reassignment</fullName>
        <actions>
            <name>AGG_WEA11_PSA_SG_Primary_PV_Scientist_Reassignment</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>PSA-CLD-IQVIAPSA-1224</description>
        <formula>IQVIA_Primary_PV_Scientist__c &lt;&gt; Prior_PV_Scientist__c</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>AGG_WFU_SG_PSA_Update_Prior_PV_Scientist</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>AGG WR09 PSA SG Secondary GSO Assignment Notification</fullName>
        <actions>
            <name>AGG_WEA10_PSA_SG_Secondary_GSO_Assignment_Notification</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>PSA-CLD-IQVIAPSA-1224- Sanofi-Galen Secondary GSO Assignment Notification</description>
        <formula>AND( OR( RecordType.Name = &apos;Sanofi PVS Report&apos;, RecordType.Name = &apos;Sanofi GSO Report&apos;), OR( AND(ISNEW(),NOT(ISBLANK(IQVIA_Secondary_GSO__c))), ISCHANGED( IQVIA_Secondary_GSO__c ) = True), ISPICKVAL (Status__c, &apos;Completed&apos;) = False)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>AGG WR10 PSA SG Primary PV Scientist Reassignment</fullName>
        <actions>
            <name>AGG_WEA11_PSA_SG_Primary_PV_Scientist_Reassignment</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>PSA-CLD-IQVIAPSA-1224</description>
        <formula>AND(IQVIA_Primary_PV_Scientist__r.psa_report__Resource_Name__c != Prior_PV_Scientist__c, NOT(ISBLANK(Prior_PV_Scientist__c)))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>AGG_WFU_SG_PSA_Update_Prior_PV_Scientist</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>AGG WR12 PSA Assign Primary Medical Reviewer Notification</fullName>
        <actions>
            <name>AGG_ET12_PSA_New_Primary_Medical_Reviewer_Notification</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>PSA-MC-IQVIAPSA-2624- Primary Medical Reviewer Assigned Notification</description>
        <formula>AND(OR( RecordType.DeveloperName = &apos;General_Report&apos;, RecordType.DeveloperName = &apos;RA_Response&apos;, RecordType.DeveloperName = &apos;Takeda_Report&apos;), NOT(ISBLANK(Primary_Medical_Reviewer__c)), OR(ISNEW(), ISCHANGED(Primary_Medical_Reviewer__c)) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>AGG WR13 PSA SG Prior PV Scientist Update</fullName>
        <actions>
            <name>AGG_WFU_SG_PSA_Update_Prior_PV_Scientist</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>PSA-CLD-IQVIAPSA-1224</description>
        <formula>OR( AND( NOT(ISBLANK(IQVIA_Primary_PV_Scientist__c)),ISBLANK(Prior_PV_Scientist__c)), IQVIA_Primary_PV_Scientist__r.psa_report__Resource_Name__c != Prior_PV_Scientist__c)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>AGG_WR11_PSA_MC_InsertUpdate_Outbound</fullName>
        <active>true</active>
        <description>IQVIAPSA-MC-2666- Workflow to send Outbound message when Aggregate Report is inserted or updated.</description>
        <formula>$Setup.Mulesoft_Integration_Control__c.Suppress_Outbound_Messages__c == false &amp;&amp; Mulesoft_Sync_Status__c == &apos;Pending&apos;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
