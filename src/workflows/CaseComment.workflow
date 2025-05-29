<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CAS_WEA21_AddNewComment</fullName>
        <description>CAS_WEA21_AddNewComment</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/CAS_ET19_CSM_NewCaseComment</template>
    </alerts>
    <fieldUpdates>
        <fullName>CAS_WFU17_CSM_CaseStatusInProgress</fullName>
        <description>CSM - ACN - S-0006 - Status In progress when comment is added</description>
        <field>Status</field>
        <literalValue>In Progress</literalValue>
        <name>CAS_WFU17_CSM_CaseStatusInProgress</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CAS_WFU30_NewCaseComment</fullName>
        <field>NewCaseComment__c</field>
        <literalValue>1</literalValue>
        <name>CAS_WFU30_NewCaseComment</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Status</fullName>
        <description>Set status to in progress</description>
        <field>Status</field>
        <literalValue>In Progress</literalValue>
        <name>Set_Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Substatus</fullName>
        <field>SubStatus__c</field>
        <name>Set_Substatus</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>CAS_CSH_StatusChangeOnComment</fullName>
        <actions>
            <name>Set_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Substatus</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Awaiting</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>TechnologyCase</value>
        </criteriaItems>
        <criteriaItems>
            <field>CaseComment.CreatedDate</field>
            <operation>lessOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>equals</operation>
            <value>CSM Customer Community Plus Login User</value>
        </criteriaItems>
        <description>when the status is awaiting and added the comments status would be change</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CAS_WR32_CSM_StatusInProgressWhenCommentAdded</fullName>
        <actions>
            <name>CAS_WFU17_CSM_CaseStatusInProgress</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>CSM - ACN - S-0006 - Status change to in progress when a comment is added.</description>
        <formula>AND( NOT( ISBLANK( CommentBody ) ), LEFT( Parent.OwnerId , 3) &lt;&gt; &apos;005&apos;, Parent.RecordType.DeveloperName = &apos;TechnologyCase&apos;, ISPICKVAL(Parent.Status, &apos;New&apos;), $Profile.Name = &apos;Service User&apos;, OR( ISPICKVAL(Parent.Origin, &apos;Email&apos;), ISPICKVAL(Parent.Origin, &apos;Customer Portal&apos;)) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CAS_WR46_CSM_newCommentPublish</fullName>
        <actions>
            <name>CAS_WFU30_NewCaseComment</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>CSM - ACN - IF new comment added and publish is checked then new comment checked in case is true.</description>
        <formula>AND( NOT( ISBLANK( CommentBody ) ), IsPublished = true, ISNEW(),ISPICKVAL(Parent.Origin, &apos;Customer Portal&apos;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
