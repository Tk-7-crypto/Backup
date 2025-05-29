/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for AccountTeamMember
 * Author        : PEP_ACN
 */
public class SLT_AccountTeamMember extends fflib_SObjectSelector {
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            AccountTeamMember.Id,
            AccountTeamMember.UserId,
            AccountTeamMember.AccountId
        };
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return AccountTeamMember.sObjectType;
    }
    
    public List<AccountTeamMember> selectByAccountId(Set<ID> idSet, String role) {
          return (List<AccountTeamMember>)Database.query(newQueryFactory().setCondition('accountid IN: idSet AND TeamMemberRole=: role').toSOQL());
   }

        
}