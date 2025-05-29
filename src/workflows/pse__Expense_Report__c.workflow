<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>PSA_Expense_Report_Approval_Email</fullName>
        <description>PSA Expense Report Approval Email</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PSA_Templates/PSA_Expense_Report_Approved</template>
    </alerts>
    <alerts>
        <fullName>PSA_Expense_Report_Rejected_Email</fullName>
        <description>PSA Expense Report Rejected Email</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PSA_Templates/PSA_Expense_Report_Rejected</template>
    </alerts>
    <fieldUpdates>
        <fullName>PSA_Expense_Report_Approved_Date_Today</fullName>
        <description>Sets the Approved Date to Today().</description>
        <field>Approved_Date__c</field>
        <formula>TODAY()</formula>
        <name>PSA Expense Report Approved Date Today</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PSA_Expense_Report_Clear_Approved_Date</fullName>
        <description>Clears the approve date.</description>
        <field>Approved_Date__c</field>
        <name>PSA Expense Report Clear Approved Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PSA_Expense_Report_Clear_Submitted_Date</fullName>
        <field>Submitted_Date__c</field>
        <name>PSA Expense Report Clear Submitted Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PSA_Expense_Report_Set_Action_IIF_Flag</fullName>
        <field>pse__Action_Check_Include_In_Financials__c</field>
        <literalValue>1</literalValue>
        <name>PSA Expense Report Set Action: IIF Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PSA_Expense_Report_Set_Approved_Flag</fullName>
        <field>pse__Approved__c</field>
        <literalValue>1</literalValue>
        <name>PSA Expense Report Set Approved Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PSA_Expense_Report_Set_Status_Approved</fullName>
        <description>Updates the Status field to &quot;Approved&quot;</description>
        <field>pse__Status__c</field>
        <literalValue>Approved</literalValue>
        <name>PSA Expense Report Set Status Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PSA_Expense_Report_Set_Status_Draft</fullName>
        <description>Sets the Status field to &quot;Draft.&quot;</description>
        <field>pse__Status__c</field>
        <literalValue>Draft</literalValue>
        <name>PSA Expense Report Set Status Draft</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PSA_Expense_Report_Set_Status_Rejected</fullName>
        <description>Updates the Status field to &quot;Rejected.&quot;</description>
        <field>pse__Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>PSA Expense Report Set Status Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PSA_Expense_Report_Set_Status_Submitted</fullName>
        <description>Updates the Status field to &quot;Submitted.&quot;</description>
        <field>pse__Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>PSA Expense Report Set Status Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PSA_Expense_Report_Set_Submitted_Flag</fullName>
        <field>pse__Submitted__c</field>
        <literalValue>1</literalValue>
        <name>PSA Expense Report Set Submitted Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PSA_Expense_Report_Submitted_Date_Today</fullName>
        <description>Sets the submitted date to TODAY().</description>
        <field>Submitted_Date__c</field>
        <formula>TODAY()</formula>
        <name>PSA Expense Report Submitted Date Today</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PSA_Expense_Report_Unset_Action_IIF_Flag</fullName>
        <field>pse__Action_Check_Include_In_Financials__c</field>
        <literalValue>0</literalValue>
        <name>PSA Expense Report Unset Action:IIF Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PSA_Expense_Report_Unset_Approved_Flag</fullName>
        <field>pse__Approved__c</field>
        <literalValue>0</literalValue>
        <name>PSA Expense Report Unset Approved Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PSA_Expense_Report_Unset_Submitted_Flag</fullName>
        <description>Unsets the Submitted flag.</description>
        <field>pse__Submitted__c</field>
        <literalValue>0</literalValue>
        <name>PSA Expense Report Unset Submitted Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PSE_Exp_Report_Set_Approved_Flag</fullName>
        <field>pse__Approved__c</field>
        <literalValue>1</literalValue>
        <name>PSE Exp Report Set Approved Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PSE_Expense_Report_Set_Submitted_Flag1</fullName>
        <description>This action will update the submitted field  when the expense report has been submitted (status is submitted).</description>
        <field>pse__Submitted__c</field>
        <literalValue>1</literalValue>
        <name>PSE Expense Report Set Submitted Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>PSA Expense Report Status Draft%2C Rejected</fullName>
        <actions>
            <name>PSA_Expense_Report_Clear_Approved_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>PSA_Expense_Report_Clear_Submitted_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>PSA_Expense_Report_Unset_Action_IIF_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>PSA_Expense_Report_Unset_Approved_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>PSA_Expense_Report_Unset_Submitted_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>pse__Expense_Report__c.pse__Status__c</field>
            <operation>equals</operation>
            <value>Draft,Rejected</value>
        </criteriaItems>
        <description>This mimics the rejection process when the Exp Report status is set to Rejected it will unset the approve/submit flags and dates &amp; the Action: Include Flag. Note: you should not un-check the Include in financials flag directly. It will hit governor limits</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PSA Expense Report Status Set to Approved</fullName>
        <actions>
            <name>PSA_Expense_Report_Approved_Date_Today</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>PSA_Expense_Report_Set_Action_IIF_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>PSA_Expense_Report_Set_Approved_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>PSA_Expense_Report_Set_Submitted_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>pse__Expense_Report__c.pse__Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <description>This mimics the approval process when the Exp Report status is set to Approved it will check the submitted &amp; approved flags &amp; check the Action: Include Flag. Note: you should not check the Include in financials flag directly. It will hit governor limits</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PSA Expense Report Status Submitted</fullName>
        <actions>
            <name>PSA_Expense_Report_Clear_Approved_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>PSA_Expense_Report_Set_Submitted_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>PSA_Expense_Report_Submitted_Date_Today</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>PSA_Expense_Report_Unset_Action_IIF_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>PSA_Expense_Report_Unset_Approved_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>pse__Expense_Report__c.pse__Status__c</field>
            <operation>equals</operation>
            <value>Submitted</value>
        </criteriaItems>
        <description>When Expense Report Status is set to Submitted it will clear approved date, unset approved flag, set the submitted flag, set the submitted date to today and unset the Action: IIF flag.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
