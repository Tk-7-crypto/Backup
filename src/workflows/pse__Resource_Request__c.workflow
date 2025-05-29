<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>RRQ_WEA01_PSA_CLD_ResourceRequestHeld</fullName>
        <description>RRQ_WEA01_PSA_CLD-PSA Resource Request Held</description>
        <protected>false</protected>
        <recipients>
            <field>Service_Line_Lead__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PSA_Templates/PSA_Resource_Request_Held</template>
    </alerts>
    <fieldUpdates>
        <fullName>PSA_Resource_Request_Held</fullName>
        <description>Set Resource Request Status = &quot;Hold&quot;</description>
        <field>pse__Status__c</field>
        <literalValue>Hold</literalValue>
        <name>PSA Resource Request Held</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>RRQ_WR01_PSA_ResourceRequestHeld</fullName>
        <actions>
            <name>RRQ_WEA01_PSA_CLD_ResourceRequestHeld</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>(1 OR 2) AND 3</booleanFilter>
        <criteriaItems>
            <field>pse__Resource_Request__c.pse__Status__c</field>
            <operation>equals</operation>
            <value>Hold</value>
        </criteriaItems>
        <criteriaItems>
            <field>pse__Resource_Request__c.pse__Resource_Held__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>pse__Resource_Request__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>RDS Request</value>
        </criteriaItems>
        <description>PSA-CLD-USNONE-Fires when a resource request is held.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>RRQ_WR02_PSA_ResourceRequestHeldChecked</fullName>
        <actions>
            <name>PSA_Resource_Request_Held</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>pse__Resource_Request__c.pse__Resource_Held__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>pse__Resource_Request__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>RDS Request</value>
        </criteriaItems>
        <description>PSA-CLD-USNONE-Fires when a resource request &apos;s &quot;resource held&quot; checkbox is checked.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
