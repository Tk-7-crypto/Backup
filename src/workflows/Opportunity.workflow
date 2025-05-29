<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CRM_ESPSFDCQI2036_Email_Principle_in_Charge</fullName>
        <description>CRM-ESPSFDCQI2036 - Email Principle in Charge</description>
        <protected>false</protected>
        <recipients>
            <field>Principle_inCharge__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/OPP_ET09_CRM_Principle_in_Charge_Notification</template>
    </alerts>
    <alerts>
        <fullName>Deal_Desk_Request_Approved</fullName>
        <ccEmails>techdealdesk@iqvia.com</ccEmails>
        <description>Deal Desk Request Approved</description>
        <protected>false</protected>
        <recipients>
            <field>Deal_Desk_Submitter__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Deal_Desk_Approval_Workflow/Deal_Desk_Request_Approved</template>
    </alerts>
    <alerts>
        <fullName>Deal_Desk_Request_Approved_Final</fullName>
        <ccEmails>techdealdesk@iqvia.com</ccEmails>
        <description>Deal Desk Request Approved</description>
        <protected>false</protected>
        <recipients>
            <field>Deal_Desk_Submitter__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Deal_Desk_Approval_Workflow/Deal_Desk_Request_Approved</template>
    </alerts>
    <alerts>
        <fullName>Deal_Desk_Request_Received</fullName>
        <description>Deal Desk Request Received</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Deal_Desk_Approval_Workflow/Deal_Desk_Request_Received</template>
    </alerts>
    <alerts>
        <fullName>Deal_Desk_Request_Received_Final</fullName>
        <description>Deal Desk Request Received</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Deal_Desk_Approval_Workflow/Deal_Desk_Request_Received</template>
    </alerts>
    <alerts>
        <fullName>Deal_Desk_Request_Rejected</fullName>
        <description>Deal Desk Request Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Deal_Desk_Approval_Workflow/Deal_Desk_Request_Rejected</template>
    </alerts>
    <alerts>
        <fullName>Deal_Desk_Request_Rejected1</fullName>
        <ccEmails>techdealdesk@iqvia.com</ccEmails>
        <description>Deal Desk Request Rejected</description>
        <protected>false</protected>
        <recipients>
            <field>Deal_Desk_Submitter__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Deal_Desk_Approval_Workflow/Deal_Desk_Request_Rejected</template>
    </alerts>
    <alerts>
        <fullName>Deal_Desk_Request_Rejected_Final</fullName>
        <description>Deal Desk Request Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Deal_Desk_Approval_Workflow/Deal_Desk_Request_Rejected</template>
    </alerts>
    <alerts>
        <fullName>Deal_Desk_Request_Rejected_Final1</fullName>
        <ccEmails>techdealdesk@iqvia.com</ccEmails>
        <description>Deal Desk Request Rejected</description>
        <protected>false</protected>
        <recipients>
            <field>Deal_Desk_Submitter__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Deal_Desk_Approval_Workflow/Deal_Desk_Request_Rejected</template>
    </alerts>
    <alerts>
        <fullName>If_Novel_Trial_Design_is_External_Comparator</fullName>
        <ccEmails>TrialDesignSupport@iqvia.com</ccEmails>
        <description>If Novel Trial Design is External Comparator</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/OPP_ET11_CRM_Opportunity_NTD_Value_Changed</template>
    </alerts>
    <alerts>
        <fullName>If_Novel_Trial_Design_is_External_Comparator_and_Stage_is_changed</fullName>
        <ccEmails>TrialDesignSupport@iqvia.com</ccEmails>
        <description>If Novel Trial Design is External Comparator and Stage is changed</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/OPP_ET12_CRM_Opportunity_NTD_Value_Changed_With_Stage_Changed</template>
    </alerts>
    <alerts>
        <fullName>If_Novel_Trial_Design_is_not_equal_External_Comparator</fullName>
        <ccEmails>TrialDesignSupport@iqvia.com</ccEmails>
        <description>If Novel Trial Design is not equal External Comparator</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/OPP_ET11_CRM_Opportunity_NTD_Value_Changed</template>
    </alerts>
    <alerts>
        <fullName>If_Novel_Trial_Design_is_not_equal_External_Comparator_and_stage_is_changed</fullName>
        <ccEmails>TrialDesignSupport@iqvia.com</ccEmails>
        <description>If Novel Trial Design is not equal External Comparator and stage is changed</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/OPP_ET12_CRM_Opportunity_NTD_Value_Changed_With_Stage_Changed</template>
    </alerts>
    <alerts>
        <fullName>OPP_EA08_CRM_CRM_R_D_Reopen_Awarded_Opp_Approval</fullName>
        <description>OPP_EA08_CRM_CRM_R&amp;D_Reopen_Awarded_Opp_Approval</description>
        <protected>false</protected>
        <recipients>
            <recipient>dennis.golmitz@iqvia.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>polina.emilovapavlova@q2labsolutions.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/OPP_ET08_CRM_R_D_Reopen_Awarded_Opp_Approval</template>
    </alerts>
    <alerts>
        <fullName>OPP_EA09_CRM_R_D_Opp_Loss_Approval_LOB_Lab</fullName>
        <description>OPP_EA09_CRM_R&amp;D_Opp_Loss_Approval(LOB = Lab)</description>
        <protected>false</protected>
        <recipients>
            <recipient>dennis.golmitz@iqvia.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>polina.emilovapavlova@q2labsolutions.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/OPP_ET06_CRM_R_D_Opportunity_Moved_to_7b</template>
    </alerts>
    <alerts>
        <fullName>OPP_EA10_CRM_R_D_Opp_Win_Alert_50k</fullName>
        <ccEmails>CRMWinLossAlert_Germany@iqvia.com</ccEmails>
        <description>OPP_EA10_CRM_R&amp;D_Opp_Win_Alert_&gt;_50k</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/Opportunity_Win_Loss_Alert</template>
    </alerts>
    <alerts>
        <fullName>OPP_WEA01_CRM_Bid_Defense_7_day_reminder</fullName>
        <description>CRM-MC-ESPSFDCQI-2874 - Bid Defense 7 day reminder</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/OPP_ET03_CRM_Bid_defense_presentation_date_more_than_30_days</template>
    </alerts>
    <alerts>
        <fullName>OPP_WEA02_CRM_Bid_Defense_14_day_reminder</fullName>
        <description>CRM-MC-ESPSFDCQI-2874 - Bid Defense 14 day reminder</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/OPP_ET04_CRM_Bid_defense_presentation_date_past_7_and_14_days</template>
    </alerts>
    <alerts>
        <fullName>OPP_WEA03_CRM_Bid_Defense_30_day_reminder</fullName>
        <description>CRM-MC-ESPSFDCQI-2874 - Bid Defense 30 day reminder</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/OPP_ET03_CRM_Bid_defense_presentation_date_more_than_30_days</template>
    </alerts>
    <alerts>
        <fullName>RD_S_Opportunity_5_Finalizing_Deal_Alert</fullName>
        <ccEmails>SHR-SD-WinLossNotificationRWLPR@iqvia.com</ccEmails>
        <ccEmails>RDSCRMGlobalWinLoss@iqvia.com</ccEmails>
        <description>RD&amp;S Opportunity 5-Finalizing Deal Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>Opportunity Owner</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/RD_S_Opportunity_5_Finalizing_Deal_Alert</template>
    </alerts>
    <alerts>
        <fullName>RD_S_Opportunity_Closed_Lost_Alert</fullName>
        <ccEmails>SHR-SD-WinLossNotificationRWLPR@iqvia.com</ccEmails>
        <ccEmails>RDSCRMGlobalWinLoss@iqvia.com</ccEmails>
        <description>RD&amp;S Opportunity Closed Lost Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>Opportunity Owner</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/RD_S_Opportunity_Closed_Lost_Alert</template>
    </alerts>
    <alerts>
        <fullName>TAKEDA_Account_Opportunity_5_Finalizing_Deal_Alert</fullName>
        <ccEmails>Anne.Oesterbo@quintiles.com</ccEmails>
        <ccEmails>Jacob.Sutherland@quintiles.com</ccEmails>
        <ccEmails>TAK_Acct-LevelFxLeads@quintiles.com</ccEmails>
        <ccEmails>Jack.Bradley@quintiles.com</ccEmails>
        <description>TAKEDA Account Opportunity 5-Finalizing Deal Alert</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/TAKEDA_Account_Opp_Win_Notification</template>
    </alerts>
    <alerts>
        <fullName>TAKEDA_Account_Opportunity_7b_Closed_Lost_Alert</fullName>
        <ccEmails>Anne.Oesterbo@quintiles.com</ccEmails>
        <ccEmails>Jacob.Sutherland@quintiles.com</ccEmails>
        <ccEmails>TAK_Acct-LevelFxLeads@quintiles.com</ccEmails>
        <ccEmails>Jack.Bradley@quintiles.com</ccEmails>
        <description>TAKEDA Account Opportunity 7b Closed Lost Alert</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/TAKEDA_Account_Opp_Loss_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>Deal_Desk_Final_Approval_Date</fullName>
        <field>Deal_Desk_Final_Approval_Date__c</field>
        <formula>TODAY()</formula>
        <name>Deal Desk Final Approval Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Deal_Desk_Initial_Approval_Date</fullName>
        <field>Deal_Desk_Initial_Approval_Date__c</field>
        <formula>TODAY()</formula>
        <name>Deal Desk Initial Approval Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Deal_Desk_Status_Approved</fullName>
        <field>Deal_Desk_Status__c</field>
        <literalValue>Approved Pricing</literalValue>
        <name>Deal Desk Status Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Deal_Desk_Status_Approved_Final</fullName>
        <field>Deal_Desk_Status__c</field>
        <literalValue>Approved SOW</literalValue>
        <name>Deal Desk Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Deal_Desk_Status_Rejected</fullName>
        <field>Deal_Desk_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Deal Desk Status Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Deal_Desk_Status_Rejected1</fullName>
        <field>Deal_Desk_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Deal Desk Status Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Deal_Desk_Status_Rejected_Final</fullName>
        <field>Deal_Desk_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Deal Desk Status Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Final_Submitter</fullName>
        <description>ESPSFDCQI-13242</description>
        <field>Deal_Desk_Submitter__c</field>
        <formula>$User.Email</formula>
        <name>Update Final Submitter</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Initial_Submitter</fullName>
        <description>ESPSFDCQI-13242</description>
        <field>Deal_Desk_Submitter__c</field>
        <formula>$User.Email</formula>
        <name>Update Initial Submitter</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>OPP_WR01_CRM_InsertUpdate_Outbound</fullName>
        <actions>
            <name>OPP_OB01_CRM_InsertUpdate</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <description>CRM-QI-ESPSFDCQI-314 Workflow to send outbound message when opportunity is inserted or updated.</description>
        <formula>$Setup.Mulesoft_Integration_Control__c.Suppress_Outbound_Messages__c == false  &amp;&amp; Send_Mulesoft_Outbound_Msg__c == true &amp;&amp;  IsCurrencyChanged__c  == false &amp;&amp;  NOT(ISPICKVAL(Line_of_Business__c, &apos;Avacare&apos;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>OPP_WR02_CRM_Bid_Defense_Presentation_Reminders</fullName>
        <active>false</active>
        <booleanFilter>1</booleanFilter>
        <criteriaItems>
            <field>Opportunity.Presentation_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>CRM-QI-ESPSFDCQI-2874 / ESPSFDCQI-16123</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>OPP_WEA01_CRM_Bid_Defense_7_day_reminder</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Opportunity.Presentation_Date__c</offsetFromField>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>OPP_WEA03_CRM_Bid_Defense_30_day_reminder</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Opportunity.Presentation_Date__c</offsetFromField>
            <timeLength>30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>OPP_WEA02_CRM_Bid_Defense_14_day_reminder</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Opportunity.Presentation_Date__c</offsetFromField>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>OPP_WR03_CRM_R%26D _Opp_Loss_Approval</fullName>
        <actions>
            <name>OPP_WEA04_CRM_MC_R_D_Opportunity_Moved_to_7b_Loss</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND (2 OR 3) AND 4 AND 5</booleanFilter>
        <criteriaItems>
            <field>Opportunity.Lost_Opportunity_Approval__c</field>
            <operation>equals</operation>
            <value>Submitted</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>5. Finalizing Deal</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6. Received ATP/LOI</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RD_Product_Count__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Line_of_Business__c</field>
            <operation>equals</operation>
            <value>Clinical,Clinical Technology,Connected Devices,Data Sciences,Early Clinical Development,Patient &amp; DCT Solutions,Regulatory &amp; Drug Development Solutions,Safety &amp; Med Info</value>
        </criteriaItems>
        <description>CRM-QI-ESPSFDCQI-3210</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>OPP_WR04_CRM_R%26D _Reopen_Awarded_Opp_Approval</fullName>
        <actions>
            <name>OPP_EA04_CRM_R_D_Reopen_Awarded_Opp_Approval</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>CRM-MC-ESPSFDCQI-4401</description>
        <formula>AND( ISPICKVAL(Reopen_Awarded_Opp_Approval__c, &apos;Submitted&apos;),  OR(ISPICKVAL(StageName, &apos;5. Finalizing Deal&apos;),ISPICKVAL(StageName, &apos;6. Received ATP/LOI&apos;), ISPICKVAL(StageName, &apos;7a. Closed Won&apos;)), OR( ISPICKVAL(Line_of_Business__c, &apos;Clinical&apos;), ISPICKVAL(Line_of_Business__c, &apos;Data Sciences&apos;), ISPICKVAL(Line_of_Business__c, &apos;Connected Devices&apos;), ISPICKVAL(Line_of_Business__c, &apos;Early Clinical Development&apos;), ISPICKVAL(Line_of_Business__c, &apos;Safety &amp; Med Info&apos;), ISPICKVAL(Line_of_Business__c, &apos;Clinical Technology&apos;), ISPICKVAL(Line_of_Business__c, &apos;Patient &amp; DCT Solutions&apos;), ISPICKVAL(Line_of_Business__c, &apos;Regulatory &amp; Drug Development Solutions&apos;)) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>OPP_WR05_CRM_Opportunity_creation_PIC_Notification</fullName>
        <actions>
            <name>CRM_ESPSFDCQI2036_Email_Principle_in_Charge</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>CRM-ESPSFDCQI2036 - Email Principle in Charge</description>
        <formula>IF( 	ISNEW(),  NOT( ISBLANK(Principle_inCharge__c )), ISCHANGED( Principle_inCharge__c )  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>OPP_WR06_CRM_RD%26S Opportunity 5-Finalizing Deal Alert</fullName>
        <actions>
            <name>RD_S_Opportunity_5_Finalizing_Deal_Alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>CRM-MC-ESPSFDCQI-7236 - Converted to Process Builder ESPSFDCQI-7235</description>
        <formula>AND(NOT(ISNEW()),ISCHANGED(StageName),ISPICKVAL( StageName , &apos;5. Finalizing Deal&apos;),OR(  ISPICKVAL(Line_of_Business__c , &apos;Clinical&apos;), ISPICKVAL(Line_of_Business__c , &apos;Data Sciences&apos;), ISPICKVAL(Line_of_Business__c , &apos;Early Clinical Development&apos;), ISPICKVAL(Line_of_Business__c , &apos;Clinical Technology&apos;), ISPICKVAL(Line_of_Business__c , &apos;Connected Devices&apos;), ISPICKVAL(Line_of_Business__c , &apos;Regulatory &amp; Drug Development Solutions&apos;), ISPICKVAL(Line_of_Business__c , &apos;Patient &amp; DCT Solutions&apos;), ISPICKVAL(Line_of_Business__c , &apos;Evidence Based Medicine (EBM)&apos;), ISPICKVAL(Line_of_Business__c , &apos;Safety &amp; Med Info&apos;), ISPICKVAL(Line_of_Business__c , &apos;Outcome&apos;)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>OPP_WR07_CRM_RD%26S Opportunity Closed Lost Alert</fullName>
        <actions>
            <name>RD_S_Opportunity_Closed_Lost_Alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>CRM-MC-ESPSFDCQI-7236 -  Converted to Process Builder ESPSFDCQI-7235</description>
        <formula>AND( NOT(ISNEW()),ISCHANGED(StageName),ISPICKVAL( StageName , &apos;7b. Closed Lost&apos;),OR( ISPICKVAL(Line_of_Business__c , &apos;Clinical&apos;), ISPICKVAL(Line_of_Business__c , &apos;Data Sciences&apos;), ISPICKVAL(Line_of_Business__c , &apos;Early Clinical Development&apos;), ISPICKVAL(Line_of_Business__c , &apos;Clinical Technology&apos;), ISPICKVAL(Line_of_Business__c , &apos;Connected Devices&apos;),ISPICKVAL(Line_of_Business__c , &apos;Evidence Based Medicine (EBM)&apos;), ISPICKVAL(Line_of_Business__c , &apos;Safety &amp; Med Info&apos;), ISPICKVAL(Line_of_Business__c , &apos;Outcome&apos;), ISPICKVAL(Line_of_Business__c , &apos;Regulatory &amp; Drug Development Solutions&apos;), ISPICKVAL(Line_of_Business__c , &apos;Patient &amp; DCT Solutions&apos;) ),NOT(OR(ISPICKVAL(Loss_Type__c, &apos;Stopped&apos;),ISPICKVAL(Loss_Type__c, &apos;Duplicate Opportunity&apos;))))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>OPP_WR08_CRM_R%26D_Reopen_Awarded_Opp_Approval%28LOB %3D Lab%29</fullName>
        <actions>
            <name>OPP_EA08_CRM_CRM_R_D_Reopen_Awarded_Opp_Approval</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>CRM-MC-ESPSFDCQI-7234</description>
        <formula>AND( ISPICKVAL(Line_of_Business__c, &apos;Q2 Solutions&apos;), ISPICKVAL(Reopen_Awarded_Opp_Approval__c, &apos;Submitted&apos;), OR(ISPICKVAL(StageName, &apos;5. Finalizing Deal&apos;),ISPICKVAL(StageName, &apos;6. Received ATP/LOI&apos;), ISPICKVAL(StageName, &apos;7a. Closed Won&apos;)) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>OPP_WR09_CRM_R%26D_Opp_Loss_Approval%28LOB %3D %C2%A0IT Services%29</fullName>
        <active>false</active>
        <booleanFilter>1 AND (2 OR 3) AND 4 AND 5</booleanFilter>
        <criteriaItems>
            <field>Opportunity.Lost_Opportunity_Approval__c</field>
            <operation>equals</operation>
            <value>Submitted</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>5. Finalizing Deal</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6. Received ATP/LOI</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Line_of_Business__c</field>
            <operation>equals</operation>
            <value>IT Services</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RD_Product_Count__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <description>ESPSFDCQI-8377</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>OPP_WR09_CRM_R%26D_Opp_Loss_Approval%28LOB %3D Lab%29</fullName>
        <actions>
            <name>OPP_EA09_CRM_R_D_Opp_Loss_Approval_LOB_Lab</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>CRM-MC-ESPSFDCQI-7234</description>
        <formula>AND( ISPICKVAL(Line_of_Business__c, &apos;Q2 Solutions&apos;), ISPICKVAL(Lost_Opportunity_Approval__c, &apos;Submitted&apos;), OR(ISPICKVAL(StageName, &apos;5. Finalizing Deal&apos;),ISPICKVAL(StageName, &apos;6. Received ATP/LOI&apos;)), (RD_Product_Count__c &gt; 0) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>OPP_WR10_CRM_R%26D_Opp_Win_Alert_%3E_50k</fullName>
        <actions>
            <name>OPP_EA10_CRM_R_D_Opp_Win_Alert_50k</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>CRM-MC-ESPSFDCQI-8211 -  Converted to Process Builder ESPSFDCQI-7235</description>
        <formula>AND(ISPICKVAL(StageName, &apos;7a. Closed Won&apos;),ISNULL(PRIORVALUE(Actual_Close_Date__c)),NOT(ISNULL(Actual_Close_Date__c)),ISPICKVAL( Main_Delivery_Country__c ,&quot;Germany&quot; ),( Amount_In_USD__c &gt;= 50000))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>OPP_WR11_CRM_R%26D_Opp_Loss_Alert_%3E_50k</fullName>
        <actions>
            <name>OPP_EA10_CRM_R_D_Opp_Win_Alert_50k</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>CRM-MC-ESPSFDCQI-8211 - Converted to Process Builder ESPSFDCQI-7235</description>
        <formula>AND(ISPICKVAL(StageName, &apos;7b. Closed Lost&apos;),ISPICKVAL(Main_Delivery_Country__c ,&quot;Germany&quot;),(Amount_In_USD__c &gt;= 50000),ISNULL(PRIORVALUE(Actual_Close_Date__c)),NOT(ISNULL(Actual_Close_Date__c)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>OPP_WR12_CRM_Clinical_Technology_35Day_After_Close_Alert</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>contains</operation>
            <value>7a. Closed Won,7b. Closed Lost</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Line_of_Business__c</field>
            <operation>equals</operation>
            <value>Clinical Technology</value>
        </criteriaItems>
        <description>ESPSFDCQI-12621</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Clinical_Technology_35_day_after_close_alert</name>
                <type>Task</type>
            </actions>
            <timeLength>35</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <tasks>
        <fullName>Clinical_Technology_35_day_after_close_alert</fullName>
        <assignedToType>owner</assignedToType>
        <description>Please follow-up on this won / lost opportunity to see what information you can obtain relative to the decision</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>High</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Clinical Technology 35 day after close alert</subject>
    </tasks>
</Workflow>
