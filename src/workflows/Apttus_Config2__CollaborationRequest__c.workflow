<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CPQ_Collaboration_Request_Assigned</fullName>
        <description>CPQ Collaboration Request Assigned</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CPQ/CPQ_Collaboration_Task_Assigned</template>
    </alerts>
    <alerts>
        <fullName>CPQ_Collaboration_Request_Cancelled</fullName>
        <description>CPQ Collaboration Request Cancelled</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CPQ/CPQ_Collaboration_Request_Cancelled</template>
    </alerts>
    <alerts>
        <fullName>CPQ_Collaboration_Request_Completed</fullName>
        <description>CPQ Collaboration Request Completed</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CPQ/CPQ_Collaboration_Task_Completed</template>
    </alerts>
    <alerts>
        <fullName>CPQ_Collaboration_Request_Merged</fullName>
        <description>CPQ Collaboration Request Merged</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CPQ/CPQ_Collaboration_Task_Merged</template>
    </alerts>
    <alerts>
        <fullName>CPQ_Collaboration_Request_Updated</fullName>
        <description>CPQ Collaboration Request Updated</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CPQ/CPQ_Collaboration_Task_Updated</template>
    </alerts>
</Workflow>
