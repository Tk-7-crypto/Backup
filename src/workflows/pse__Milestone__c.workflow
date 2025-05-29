<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>PSA_Milestone_Nearing_Completion_Alert</fullName>
        <description>PSA Milestone Nearing Completion Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Service_Line_Lead__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PSA_Templates/PSA_Milestone_Units_Nearing_Completion</template>
    </alerts>
    <fieldUpdates>
        <fullName>MLS_WFU01_PSA_SetExclueFromBilling</fullName>
        <description>PSA-CLD-USNONE- Set Exclude from Billing to true</description>
        <field>pse__Exclude_from_Billing__c</field>
        <literalValue>1</literalValue>
        <name>MLS_WFU01_PSA_SetExcludeFromBilling</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MLS_WFU02_PSA_SetIIFFlag</fullName>
        <description>PSA-CLD-USNONE- Set IIF Flag on PSA Milestone</description>
        <field>pse__Include_In_Financials__c</field>
        <literalValue>1</literalValue>
        <name>MLS_WFU02_PSA_SetIIFFlag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MLS_WFU03_PSA_UnsetApprovedFlag</fullName>
        <description>PSA-CLD-USNONE- Unset approved Flag</description>
        <field>pse__Approved__c</field>
        <literalValue>0</literalValue>
        <name>MLS_WFU03_PSA_UnsetApprovedFlag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MLS_WFU05_PSA_UnsetExcludeFromBilling</fullName>
        <description>PSA-CLD-USNONE- Set Exclude from Billing to false</description>
        <field>pse__Exclude_from_Billing__c</field>
        <literalValue>0</literalValue>
        <name>MLS_WFU05_PSA_UnsetExcludeFromBilling</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MLS_WFU06_PSA_UnsetIIFFlag</fullName>
        <description>PSA-CLD-USNONE- Unset IIF Flag</description>
        <field>pse__Include_In_Financials__c</field>
        <literalValue>0</literalValue>
        <name>MLS_WFU06_PSA_UnsetIIFFlag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PSA_Milestone_Set_Approved_Flag</fullName>
        <description>PSA-CLD-USNONE- Set the Approved Flag to true.</description>
        <field>pse__Approved__c</field>
        <literalValue>1</literalValue>
        <name>MLS_WFU04_PSA_SetApprovedFlag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>MLS_WR01_PSA_CLD_MilestoneAmtIsZero</fullName>
        <actions>
            <name>MLS_WFU01_PSA_SetExclueFromBilling</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>PSA-CLD-USNONE-If Milestone Amount is zero, set Exclude from Billing to true.</description>
        <formula>pse__Milestone_Amount__c = 0 &amp;&amp; RecordType.DeveloperName = &apos;RDS_Billing&apos;</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>MLS_WR02_PSA_CLD_MilestoneAmtNotEqualsZero</fullName>
        <actions>
            <name>MLS_WFU05_PSA_UnsetExcludeFromBilling</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>PSA-CLD-USNONE-If Milestone Amount is Not Equal to zero, set Exclude from Billing to false.</description>
        <formula>AND( RecordType.DeveloperName = &apos;RDS_Billing&apos;, pse__Milestone_Amount__c &lt;&gt; 0 )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>MLS_WR03_PSA_CLD_StatusApproved</fullName>
        <actions>
            <name>MLS_WFU02_PSA_SetIIFFlag</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>PSA_Milestone_Set_Approved_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>pse__Milestone__c.pse__Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>pse__Milestone__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>RDS Billing</value>
        </criteriaItems>
        <description>PSA-CLD-USNONE-When the milestones status is set to Approved, the approved flag and the IIF flag will get set.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>MLS_WR04_PSA_CLD_StatusNotApproved</fullName>
        <actions>
            <name>MLS_WFU03_PSA_UnsetApprovedFlag</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>MLS_WFU06_PSA_UnsetIIFFlag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>pse__Milestone__c.pse__Status__c</field>
            <operation>notEqual</operation>
            <value>Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>pse__Milestone__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>RDS Billing</value>
        </criteriaItems>
        <description>PSA-CLD-USNONE-When the milestones status is set to Not Approved, the approved flag and the IIF flag will get unset.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>MLS_WR05_PSA_CLD_MilestoneUnitsNearingCompletion</fullName>
        <actions>
            <name>PSA_Milestone_Nearing_Completion_Alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>If a Service Milestone is greater than 80% complete then sends an email alert</description>
        <formula>RecordType.DeveloperName = &apos;RDS_Service&apos; &amp;&amp; (Actual_Quantity__c / Budget_Quantity__c &gt; 0.8) &amp;&amp; Budget_Quantity__c != 1</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
