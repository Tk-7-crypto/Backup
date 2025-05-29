<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>PJE_WEA01_PSA_NS_Upcoming_Planned_Due_Date_Alert</fullName>
        <description>PJE WEA01 PSA NS Upcoming Planned Due Date Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Other_Resource__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Primary_Resource__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Secondary_Resource__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>no.reply.support@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PSA_Templates/PJE_ET01_PSA_NS_Upcoming_Planned</template>
    </alerts>
    <alerts>
        <fullName>PJE_WEA02_PSA_SG_Upcoming_Planned_Due_Date_Alert</fullName>
        <description>PJE WEA02 PSA SG Upcoming Planned Due Date Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Other_Resource__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Primary_Resource__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Secondary_Resource__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>no.reply.support@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PSA_Templates/PJE_ET02_PSA_SG_Upcoming_Planned_Due_Date_Alert</template>
    </alerts>
    <alerts>
        <fullName>PJE_WEA03_PSA_NS_Missed_Compliance_Deadlines_Escalation_Alert</fullName>
        <description>PJE WEA03 PSA NS Missed Compliance Deadlines Escalation Alert</description>
        <protected>false</protected>
        <recipients>
            <field>LastModifiedById</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>no.reply.support@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PSA_Templates/PJE_ET03_PSA_NS_Compliance_Deadlines</template>
    </alerts>
    <alerts>
        <fullName>PJE_WEA04_PSA_SG_Missed_Compliance_Deadlines_Escalation_Alert</fullName>
        <description>PJE WEA04 PSA SG Missed Compliance Deadlines Escalation Alert</description>
        <protected>false</protected>
        <recipients>
            <field>LastModifiedById</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PSA_Templates/PJE_ET04_PSA_SG_Compliance_Deadlines_Escalation_Alert</template>
    </alerts>
    <alerts>
        <fullName>PJE_WEA09_PSA_SD_Run_Missed_Due_Date_Alert</fullName>
        <description>PJE WEA09 PSA SD Run Missed Due Date Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Other_Resource__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Primary_Resource__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Secondary_Resource__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PSA_Templates/PJE_ET09_SD_Run_Missed_Due_Date_Alert</template>
    </alerts>
    <alerts>
        <fullName>PJE_WEA10_PSA_Signal_Validation_Missed_Due_Date_Alert</fullName>
        <description>PJE WEA10 PSA Signal Validation Missed Due Date Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Other_Resource__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Primary_Resource__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Secondary_Resource__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PSA_Templates/PJE_ET11_PSA_Signal_Validation_Missed_Due_Date_Alert</template>
    </alerts>
    <alerts>
        <fullName>PJE_WEA11_PSA_Signal_Evaluation_Missed_Due_Date_Alert</fullName>
        <description>PJE WEA11 PSA Signal Evaluation Missed Due Date Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Other_Resource__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Primary_Resource__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Secondary_Resource__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PSA_Templates/PJE_ET10_PSA_Signal_Evaluation_Missed_Due_Date_Alert</template>
    </alerts>
    <alerts>
        <fullName>PJE_WR05_PSA_Signal_Evaluation_Due_Date_Alert</fullName>
        <description>PJE WR05 PSA Signal Evaluation Due Date Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Other_Resource__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Primary_Resource__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Secondary_Resource__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>no.reply.support@iqvia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PSA_Templates/PJE_ET05_PSA_Signal_Evaluation_Due_Date_Alert</template>
    </alerts>
    <alerts>
        <fullName>PJE_WR06_PSA_PSSF_Effective_Date_Alert</fullName>
        <description>PJE WR06 PSA PSSF Effective Date Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Other_Resource__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Primary_Resource__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Secondary_Resource__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PSA_Templates/PJE_ET06_PSA_PSSF_Effective_Date_Alert</template>
    </alerts>
    <alerts>
        <fullName>PJE_WR07_SD_Run_Due_Date_Alert</fullName>
        <description>PJE WR07 SD Run Due Date Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Other_Resource__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Primary_Resource__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Secondary_Resource__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PSA_Templates/PJE_ET07_SD_Run_Due_Date_Alert</template>
    </alerts>
    <alerts>
        <fullName>PJE_WR08_PSA_Signal_Validation_Due_Date_Alert</fullName>
        <description>PJE WR08 PSA Signal Validation Due Date Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Other_Resource__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Primary_Resource__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Secondary_Resource__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PSA_Templates/PJE_ET08_PSA_Signal_Validation_Due_Date_Alert</template>
    </alerts>
    <rules>
        <fullName>PJE WR01 PSA NS Upcoming Planned Due Date Alert</fullName>
        <active>false</active>
        <description>PSA-CLD-IQVIAPSA-1227- Non-Sanofi Upcoming Planned Due Date Alert</description>
        <formula>AND(Report__r.RecordType.Name &lt;&gt; &apos;Sanofi PVS Report&apos;, Report__r.RecordType.Name &lt;&gt; &apos;Sanofi GSO Report&apos;, Event_Due_Date__c &gt;= TODAY(), ISBLANK(Event_Actual_Date__c) = True ,  Report__c &lt;&gt; null )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>PJE_WEA01_PSA_NS_Upcoming_Planned_Due_Date_Alert</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Project_Event__c.Notification_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>PJE WR02 PSA SG Upcoming Planned Due Date Alert</fullName>
        <active>false</active>
        <description>PSA-CLD-IQVIAPSA-1226- Sanofi-Galen Upcoming Planned Due Date Alert</description>
        <formula>AND(OR(Report__r.RecordType.Name  = &apos;Sanofi PVS Report&apos;,  Report__r.RecordType.Name = &apos;Sanofi GSO Report&apos;),  Event_Due_Date__c  &gt;= TODAY(),   ISBLANK(Event_Actual_Date__c) = True )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>PJE_WEA02_PSA_SG_Upcoming_Planned_Due_Date_Alert</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Project_Event__c.Notification_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>PJE WR03 PSA NS Missed Compliance Deadlines Escalation Alert</fullName>
        <actions>
            <name>PJE_WEA03_PSA_NS_Missed_Compliance_Deadlines_Escalation_Alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>PSA-CLD-IQVIAPSA-1227- Non-Sanofi Compliance Deadlines Escalation Alert</description>
        <formula>AND( $Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c == FALSE, Report__r.RecordType.Name &lt;&gt; &apos;Sanofi PVS Report&apos;, Report__r.RecordType.Name &lt;&gt; &apos;Sanofi GSO Report&apos;, Event_Due_Date__c &lt; TODAY(), ISBLANK(Event_Actual_Date__c) = True, PSA_Event__r.Send_Missed_Due_Date_Notification__c = True, Report__c &lt;&gt; null )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PJE WR04 PSA SG Missed Compliance Deadlines Escalation Alert</fullName>
        <actions>
            <name>PJE_WEA04_PSA_SG_Missed_Compliance_Deadlines_Escalation_Alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>PSA-CLD-IQVIAPSA-1226- Sanofi-Galen Compliance Deadlines Escalation Alert</description>
        <formula>AND( $Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c == FALSE, OR(Report__r.RecordType.Name  = &apos;Sanofi PVS Report&apos;,  Report__r.RecordType.Name = &apos;Sanofi GSO Report&apos;),  Event_Due_Date__c &lt; TODAY(),  ISBLANK(Event_Actual_Date__c) = True,  PSA_Event__r.Send_Missed_Due_Date_Notification__c = True )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PJE WR05 PSA Signal Evaluation Due Date Alert</fullName>
        <active>false</active>
        <description>IQVIAPSA-MC-3202</description>
        <formula>AND( $Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c == FALSE, Event_Due_Date__c &gt;= TODAY(), ISBLANK(Event_Actual_Date__c) = True, Signal__c &lt;&gt; null , Event_Name__c = &apos;Evaluation Due Date&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>PJE_WR05_PSA_Signal_Evaluation_Due_Date_Alert</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Project_Event__c.Notification_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>PJE WR06 PSA PSSF Effective Date Alert</fullName>
        <active>false</active>
        <description>IQVIAPSA-MC-3202</description>
        <formula>AND( $Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c == FALSE, Event_Due_Date__c &gt;= TODAY(), ISBLANK(Event_Actual_Date__c) = True , PSSF__c &lt;&gt; null )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>PJE_WR06_PSA_PSSF_Effective_Date_Alert</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Project_Event__c.Notification_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>PJE WR07 SD Run Due Date Alert</fullName>
        <active>true</active>
        <description>IQVIAPSA-MC-4080</description>
        <formula>AND( $Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c == FALSE, Event_Due_Date__c &gt;= TODAY(), ISBLANK(Event_Actual_Date__c) = True , SD_Runs__c &lt;&gt; null )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>PJE_WR07_SD_Run_Due_Date_Alert</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Project_Event__c.Notification_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>PJE WR08 PSA Signal Validation Due Date Alert</fullName>
        <active>false</active>
        <description>IQVIAPSA-MC-4080</description>
        <formula>AND( $Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c == FALSE, Event_Due_Date__c &gt;= TODAY(), ISBLANK(Event_Actual_Date__c) = True , Signal__c &lt;&gt; null, Event_Name__c = &apos;Validation Due Date&apos; )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>PJE_WR08_PSA_Signal_Validation_Due_Date_Alert</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Project_Event__c.Notification_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>PJE_WR09_PSA_SDRunMissedDueDateAlert</fullName>
        <active>false</active>
        <description>IQVIAPSA-4225</description>
        <formula>AND( $Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c == FALSE, Event_Due_Date__c &lt; TODAY(), ISBLANK(Event_Actual_Date__c) = True, PSA_Event__r.Send_Missed_Due_Date_Notification__c = True, SD_Runs__c &lt;&gt; null)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>PJE_WEA09_PSA_SD_Run_Missed_Due_Date_Alert</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Project_Event__c.Event_Due_Date__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>PJE_WR10_PSA_SignalValidationMissedDueDateAlert</fullName>
        <active>false</active>
        <description>IQVIAPSA-4225</description>
        <formula>AND( $Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c == FALSE, Event_Due_Date__c &lt; TODAY(), ISBLANK(Event_Actual_Date__c) = True, PSA_Event__r.Send_Missed_Due_Date_Notification__c = True, Signal__c &lt;&gt; null, Event_Name__c = &apos;Validation Due Date&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>PJE_WEA10_PSA_Signal_Validation_Missed_Due_Date_Alert</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Project_Event__c.Event_Due_Date__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>PJE_WR11_PSA_SignalEvaluationMissedDueDateAlert</fullName>
        <active>false</active>
        <description>IQVIAPSA-4225</description>
        <formula>AND( $Setup.Mulesoft_Integration_Control__c.Ignore_Validation_Rules__c == FALSE, Event_Due_Date__c &lt; TODAY(), ISBLANK(Event_Actual_Date__c) = True, PSA_Event__r.Send_Missed_Due_Date_Notification__c = True, Signal__c &lt;&gt; null, Event_Name__c = &apos;Evaluation Due Date&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>PJE_WEA11_PSA_Signal_Evaluation_Missed_Due_Date_Alert</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Project_Event__c.Event_Due_Date__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
