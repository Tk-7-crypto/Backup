/*
* Version       : 1.0
* Description   : Apex Controller for LXC_PEP_ManagementAnnouncement
*/
public class CNT_PEP_ManageAnnouncement {
    @AuraEnabled
    public static Id createAnnouncement(String subject, String status, String description, String parttype, String partRoles, Id productId, Date expDate, List<Account> accs, String recId){
        Savepoint sp = Database.setSavepoint();
        Announcement__c a = new Announcement__c();
        a.id = recId;
        a.Subject__c = subject;
        a.Description__c = description;
        a.Partner_type__c = parttype;
        a.Partner_roles__c = partRoles;
        a.Product2ID__c = productId; 
        a.Expiry_Date__c = expDate;
        
        if(String.isNotBlank(recId) && String.isNotBlank(a.Status__c)) {
            a.Status__c = status;
        }
        
        Id getAnnoucementId = null;
        
        try {
            upsert a;
            
             getAnnoucementId = a.Id;
            
            delete [SELECT Id,AnnouncementID__c FROM Targeted_Account_Announcement__c where AnnouncementID__c =: getAnnoucementId];
            
            if(getAnnoucementId != null) {
                for(Account ac : accs) {
                    Targeted_Account_Announcement__c taa = new Targeted_Account_Announcement__c();
                    taa.AccountID__c = ac.Id;
                    taa.AnnouncementID__c = getAnnoucementId;
                    Database.insert(taa);
                }
            }
        }
        catch(Exception e) {
            Database.rollback(sp);
            System.debug('An exception occured: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        
        return getAnnoucementId;
    }
    
    @AuraEnabled
    public static List<Targeted_Account_Announcement__c> getAccounts(String recId){
        List<Targeted_Account_Announcement__c> acc = [SELECT AccountId__r.Id, AccountID__r.Name from Targeted_Account_Announcement__c where AnnouncementID__c =:recId];
        return acc;
    }
    
    @AuraEnabled
    public static List<Targeted_User_Announcement__c> publishAnnouncements(String announcementId){
        boolean filteredbyRole = false;
        boolean filteredbyType = false;
        boolean filteredbyProduct = false;
        boolean filteredbyaccount = false;
        
        Savepoint sp = Database.setSavepoint();
        
        List<User> u = new List<User>();
        List<Targeted_User_Announcement__c> ltu = new List<Targeted_User_Announcement__c>();
        List<Announcement__Share> ans = new List<Announcement__Share>();
        
        List<Announcement__c> a = [Select id,Status__c,Published_date__c,Partner_roles__c,Partner_type__c,Product2ID__r.name, (SELECT AccountID__c FROM Targetted_Account_Announcements__r)
                                   from Announcement__c 
                                   where id=:announcementId Limit 1];
        
        
        String rol = a[0].Partner_roles__c;
        String typ = a[0].Partner_type__c;
        String prod = a[0].Product2ID__c;
        String partnerTypes='';
        List<String> roles = new List<String>();
        
        if(String.isNotBlank(rol)) {
            rol = rol.replace('Consultant','Worker');
            filteredbyRole = true;
            roles = rol.split(';');
        }
        
        if(String.isNotBlank(typ)) {
            filteredbyType = true;
            partnerTypes = '\''+typ.replace(';','\',\'')+'\'';
        }
        
        if(String.isNotBlank(prod)) {
            filteredbyProduct = true;
        }
        
        if(a[0].Targetted_Account_Announcements__r.size() >0){
            filteredbyaccount = true;
        }
        
        String userProfile = CON_PEP.S_P_PEP_COMMUNITY;
        String query = 'Select User.id, User.ProfileId, User.AccountId, User.Full_User_Name__c, User.userRole.portalRole, User.Contact.Partner_Type__c from User where User.IsActive = true AND User.Contact.id != null AND User.Profile.name = :userProfile';
        //String query = 'Select User.id, User.ProfileId, User.AccountId, User.Full_User_Name__c, User.userRole.portalRole, User.Contact.Partner_Type__c from User where User.Contact.id != null AND User.Profile.name = :userProfile';
        if(filteredbyRole) {
            query += ' And User.userRole.portalRole IN: roles';
        }
        
        if(filteredbyProduct) {
            query += ' And User.AccountId in (SELECT AccountId FROM Asset Where Product2Id =: prod AND Status!= \'Obsolete\' )';
        }
        
        
        if(filteredbyType) {
            query += ' And User.Contact.Partner_Type__c INCLUDES ('+partnerTypes+')';
        }
        
        if(filteredbyaccount){
            query += ' And User.AccountId in (SELECT AccountID__c FROM Targeted_Account_Announcement__c where AnnouncementID__c=:announcementId)';
        }
        
        u = Database.query(query);
        
        ltu = createTargetedUserAnnoucement(u, announcementId);
        ans = createAnnoucementShare(u, announcementId);
        
        try {
            if(ltu.size() > 0 && a[0].Status__c != 'Online') {
                a[0].Status__c = 'Online';
                a[0].Published_date__c = System.now();
                Database.update(a);
                Database.insert(ltu);
                Database.insert(ans);               
            }
        }
        catch(Exception e) {
            Database.rollback(sp);
            System.debug('An exception occured: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage()); 
        }
        
        return ltu;
    }
    
    @AuraEnabled
    public static boolean unPublishAnnouncements(String announcementId){
        List<Announcement__c> a = [Select id,Status__c
                                   from Announcement__c
                                   where id=:announcementId Limit 1];
        List<Announcement__Share> lstDelAnnShare = new List<Announcement__Share>();
        
        if(a[0].Status__c != 'Obsolete') {
            a[0].Status__c = 'Obsolete';
            update(a);
            
            for(Announcement__Share tu : [select id from Announcement__Share where ParentId =:announcementId 
                                          AND UserOrGroupId IN (Select UserID__c from Targeted_User_Announcement__c 
                                                                where AnnouncementID__c =:announcementId)]) {
                                                                    lstDelAnnShare.add(tu);                
                                                                }
            
            if(lstDelAnnShare.size()>0){
                delete lstDelAnnShare;
            }
            
            delete [Select id from Targeted_User_Announcement__c where AnnouncementID__c =:announcementId];
        }
        return true;
    }
    
    public static List<Announcement__Share> createAnnoucementShare(List<User> userList, Id announcementId){
        List<Announcement__Share> announcementShareList = new List<Announcement__Share>();
        if(!userList.isEmpty() 
           && announcementId != null){
               for(User myUser : userList){
                   Announcement__Share AnnShr  = new Announcement__Share();
                   AnnShr.ParentId = announcementId;
                   AnnShr.UserOrGroupId = myUser.id;
                   AnnShr.AccessLevel = 'Read';
                   AnnShr.RowCause = Schema.Announcement__Share.RowCause.Manual;
                   announcementShareList.add(AnnShr);
               }
           }
        return announcementShareList;
    }
    
    
    public static List<Targeted_User_Announcement__c> createTargetedUserAnnoucement(List<User> userList, Id announcementId){
        List<Targeted_User_Announcement__c> targetedUserList = new List<Targeted_User_Announcement__c>();
        if(!userList.isEmpty() 
           && announcementId != null){
               for(User myUser : userList){
                   Targeted_User_Announcement__c tu = new Targeted_User_Announcement__c();
                   tu.AnnouncementID__c = announcementId;
                   tu.UserID__c = myUser.id;
                   targetedUserList.add(tu);
               }
           }
        return targetedUserList;
    }
}