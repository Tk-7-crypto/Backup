<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>PSA_Timecard_Rejection_Alert</fullName>
        <description>PSA Timecard Rejection Alert</description>
        <protected>false</protected>
        <recipients>
            <field>pse__Resource__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PSA_Templates/PSA_Timecard_Rejected</template>
    </alerts>
    <fieldUpdates>
        <fullName>PSA_Timecard_Clear_Date_Approved</fullName>
        <field>Approved_Date__c</field>
        <name>PSA Timecard Clear Date Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PSA_Timecard_Clear_Date_Submitted</fullName>
        <field>Submitted_Date__c</field>
        <name>PSA Timecard Clear Date Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PSA_Timecard_Date_Approved_Set_to_Today</fullName>
        <field>Approved_Date__c</field>
        <formula>TODAY()</formula>
        <name>PSA Timecard Date Approved Set to Today</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PSA_Timecard_Date_Submitted_Set_to_Today</fullName>
        <field>Submitted_Date__c</field>
        <formula>TODAY()</formula>
        <name>PSA Timecard Date Submitted Set to Today</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PSA_Timecard_Set_Approved_Flag</fullName>
        <field>pse__Approved__c</field>
        <literalValue>1</literalValue>
        <name>PSA Timecard Set Approved Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PSA_Timecard_Set_IIF_Flag</fullName>
        <field>pse__Include_In_Financials__c</field>
        <literalValue>1</literalValue>
        <name>PSA Timecard Set IIF Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PSA_Timecard_Set_Submitted_Flag</fullName>
        <field>pse__Submitted__c</field>
        <literalValue>1</literalValue>
        <name>PSA Timecard Set Submitted Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PSA_Timecard_Status_Approved</fullName>
        <field>pse__Status__c</field>
        <literalValue>Approved</literalValue>
        <name>PSA Timecard Status Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PSA_Timecard_Status_Rejected</fullName>
        <field>pse__Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>PSA Timecard Status Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PSA_Timecard_Status_Saved</fullName>
        <field>pse__Status__c</field>
        <literalValue>Saved</literalValue>
        <name>PSA Timecard Status Saved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PSA_Timecard_Status_Submitted</fullName>
        <description>Sets the Status on the Timecard to Submitted.</description>
        <field>pse__Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>PSA Timecard Status Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PSA_Timecard_Unset_Approved_Flag</fullName>
        <field>pse__Approved__c</field>
        <literalValue>0</literalValue>
        <name>PSA Timecard Unset Approved Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PSA_Timecard_Unset_IIF_Flag</fullName>
        <description>Unsets the IIF flag on the timecard record.</description>
        <field>pse__Include_In_Financials__c</field>
        <literalValue>0</literalValue>
        <name>PSA Timecard Unset IIF Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PSA_Timecard_Unset_Submitted_Flag</fullName>
        <field>pse__Submitted__c</field>
        <literalValue>0</literalValue>
        <name>PSA Timecard Unset Submitted Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>PSA Timecard Status Draft%2C Rejected</fullName>
        <actions>
            <name>PSA_Timecard_Clear_Date_Approved</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>PSA_Timecard_Clear_Date_Submitted</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>PSA_Timecard_Unset_Approved_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>PSA_Timecard_Unset_IIF_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>PSA_Timecard_Unset_Submitted_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>pse__Timecard_Header__c.pse__Status__c</field>
            <operation>equals</operation>
            <value>Saved,Rejected</value>
        </criteriaItems>
        <criteriaItems>
            <field>pse__Timecard_Header__c.pse__Submitted__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>This will unset the submitted, IIF and approved flags and remove submitted and approved dates on the timecard when the status is set to a value corresponding to not submitted or approved. Customers may choose to change the values in the status drop down.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PSA Timecard Status Set to Approved</fullName>
        <actions>
            <name>PSA_Timecard_Date_Approved_Set_to_Today</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>PSA_Timecard_Set_Approved_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>PSA_Timecard_Set_IIF_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>PSA_Timecard_Set_Submitted_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>pse__Timecard_Header__c.pse__Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <description>This workflow will mimic the approval process. When the timecard status is set to Approved the approved flag will get set along with the include in financials checkbox and sets the approved date.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PSA Timecard Status Set to Submitted</fullName>
        <actions>
            <name>PSA_Timecard_Clear_Date_Approved</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>PSA_Timecard_Date_Submitted_Set_to_Today</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>PSA_Timecard_Set_Submitted_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>PSA_Timecard_Unset_Approved_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>PSA_Timecard_Unset_IIF_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>pse__Timecard_Header__c.pse__Status__c</field>
            <operation>equals</operation>
            <value>Submitted</value>
        </criteriaItems>
        <description>This will set the submitted check box and the submitted date on the timecard when the status is set to a value corresponding to submitted. Customers may choose to change the values in the status drop down</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
