<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>OLI_EA01_CRM_Tech_Lead_Assign</fullName>
        <description>OLI_EA01_CRM_Tech Lead Assign</description>
        <protected>false</protected>
        <recipients>
            <field>Product_SalesLead__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/OLI_ET01_CRM_Tech_Lead_Assign</template>
    </alerts>
    <alerts>
        <fullName>OLI_EA02_CRM_Sales_Engineer_Assign</fullName>
        <description>OLI_EA02_CRM_Sales Engineer Assign</description>
        <protected>false</protected>
        <recipients>
            <field>SalesEngineer__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CRM_MC_Workflow_Templates/OLI_ET02_CRM_Sales_Engineer_Assign</template>
    </alerts>
    <rules>
        <fullName>OLI_WR01_CRM_InsertUpdate_Outbound</fullName>
        <actions>
            <name>OLI_OB01_CRM_InsertUpdate</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <description>CRM-QI-ESPSFDCQI-497 Workflow to send outbound message when opportunity line item is inserted or updated.</description>
        <formula>$Setup.Mulesoft_Integration_Control__c.Suppress_Outbound_Messages__c == false  &amp;&amp; Hierarchy_Level__c == &apos;Material&apos; &amp;&amp; ( Opportunity.Mulesoft_Opportunity_Sync__r.LI_Opportunity_Id__c  != null || Opportunity.Mulesoft_Opportunity_Sync__r.LQ_Opportunity_Id__c != null) &amp;&amp;  Send_Mulesoft_Outbound_Msg__c == TRUE &amp;&amp;  Opportunity.IsCurrencyChanged__c == false &amp;&amp;  NOT(ISPICKVAL(Opportunity.Line_of_Business__c, &apos;Avacare&apos;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>OLI_WR02_CRM_Tech_Lead_Assign</fullName>
        <actions>
            <name>OLI_EA01_CRM_Tech_Lead_Assign</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>CRM-MC-ESPSFDCQI-4656</description>
        <formula>AND( ISCHANGED( Product_SalesLead__c),  Product_SalesLead__r.Salesforce_User__r.Id !=  $User.Id )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>OLI_WR03_CRM_Sales_Engineer_Assign</fullName>
        <actions>
            <name>OLI_EA02_CRM_Sales_Engineer_Assign</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>CRM-MC-ESPSFDCQI-4656</description>
        <formula>IF(AND( ISCHANGED( SalesEngineer__c),  SalesEngineer__r.Salesforce_User__r.Id !=  $User.Id )  , true, false)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
