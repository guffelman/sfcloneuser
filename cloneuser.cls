public class CloneUserController {
    public Integer numberOfDuplicates { get; set; }
    public List<User> clonedUsers { get; set; }
    public List<PermissionSetAssignment> assignedPermissionSets { get; set; }
    public String cloneMessage { get; set; }
    public Boolean showClonedUsers { get; set; }
    public Boolean showCreateUsersButton { get; set; }
    public Boolean showCloneUserButton { get; set; }
    public Boolean cloneButtonLabel { get; set; }
    
    

    private ApexPages.StandardController standardController;
    private Boolean isFirstClick;
    private User mainUser;
    private List<PermissionSetLicenseAssign> mainUserPermissionSetLicenses;

    public CloneUserController(ApexPages.StandardController standardController) {
        this.standardController = standardController;
        numberOfDuplicates = 0;
        clonedUsers = new List<User>();
        assignedPermissionSets = new List<PermissionSetAssignment>();
        cloneMessage = '';
        showClonedUsers = false;
        showCreateUsersButton = false;
        showCloneUserButton = true;

        // Retrieve the main user record and associated permission set licenses
        mainUser = [SELECT Id, Alias, LocaleSidKey, TimeZoneSidKey, LanguageLocaleKey, EmailEncodingKey, ProfileId, ManagerId, EmployeeNumber, CallCenterId, UserRoleId, UserPermissionsInteractionUser, UserPermissionsKnowledgeUser, UserPermissionsMarketingUser, UserPermissionsOfflineUser, UserPermissionsSupportUser, IsActive, FederationIdentifier FROM User WHERE Id = :standardController.getId()];
        mainUserPermissionSetLicenses = [SELECT Id, AssigneeId, PermissionSetLicenseId FROM PermissionSetLicenseAssign WHERE AssigneeId = :mainUser.Id];
        // Retrieve assigned permission sets for the main user (excluding profile assignments)
        assignedPermissionSets = [SELECT AssigneeId, PermissionSetId, PermissionSet.Name, PermissionSet.Label FROM PermissionSetAssignment WHERE AssigneeId = :mainUser.Id AND PermissionSet.IsOwnedByProfile = false];

    }

    public void cloneUsers() {

        if (numberOfDuplicates <= 0) {
            cloneMessage = 'Please enter a valid number of duplicates.';
            return;
        }

        cloneMessage = '';
        showClonedUsers = true;
        showCreateUsersButton = true;
        showCloneUserButton = false;
        clonedUsers = new List<User>();
        for (Integer i = 0; i < numberOfDuplicates; i++) {
            clonedUsers.add(new User(
                Alias = '',
                UserPermissionsKnowledgeUser = mainUser.UserPermissionsKnowledgeUser,
                UserPermissionsMarketingUser = mainUser.UserPermissionsMarketingUser,
                UserPermissionsOfflineUser = mainUser.UserPermissionsOfflineUser,
                UserPermissionsInteractionUser = mainUser.UserPermissionsInteractionUser,
                UserPermissionsSupportUser = mainUser.UserPermissionsSupportUser,
                IsActive = mainUser.IsActive,
                UserRoleId = mainUser.UserRoleId,
                TimeZoneSidKey = mainUser.TimeZoneSidKey,
                LocaleSidKey = mainUser.LocaleSidKey,
                EmailEncodingKey = mainUser.EmailEncodingKey,
                ProfileId = mainUser.ProfileId,
                LanguageLocaleKey = mainUser.LanguageLocaleKey,
                ManagerId = mainUser.ManagerId,
                EmployeeNumber = '',
                CallCenterId = mainUser.CallCenterId,
                FederationIdentifier = ''
                ));
        }
    }

    public void createUsers() {
    try {
        List<User> usersToCreate = new List<User>();
        List<PermissionSetAssignment> permissionSetAssignments = new List<PermissionSetAssignment>();
        List<PermissionSetLicenseAssign> permissionSetLicenses = new List<PermissionSetLicenseAssign>();

        // Insert duplicated users and set Alias field, fedaration identifier
        for (User clonedUser : clonedUsers) {
            // Set Alias field and federation identifier
            clonedUser.Alias = clonedUser.FirstName.substring(0, 1) + clonedUser.LastName;
            if (clonedUser.Alias.length() > 8) {
                clonedUser.Alias = clonedUser.Alias.substring(0, 8);
            }
            if (clonedUser.FederationIdentifier != null) {
                clonedUser.FederationIdentifier = clonedUser.Email;
            }

            // Set DMLOptions to not trigger user email - remove 89 through 91 if you want to send the welcome email
            Database.DMLOptions dmlOptions = new Database.DMLOptions();
            dmlOptions.EmailHeader.triggerUserEmail = false;
            clonedUser.setOptions(dmlOptions);

            usersToCreate.add(clonedUser);
        }

        if (!usersToCreate.isEmpty()) {
            insert usersToCreate;
        }



        // Insert Permission Set Licenses
        if (!mainUserPermissionSetLicenses.isEmpty()) {
            for (User clonedUser : usersToCreate) {
                for (PermissionSetLicenseAssign mainUserLicense : mainUserPermissionSetLicenses) {
                    PermissionSetLicenseAssign clonedUserLicense = new PermissionSetLicenseAssign(
                        AssigneeId = clonedUser.Id,
                        PermissionSetLicenseId = mainUserLicense.PermissionSetLicenseId
                    );
                    permissionSetLicenses.add(clonedUserLicense);
                }
            }
            insert permissionSetLicenses;
        }

        // Assign Permission Sets to duplicated users
        for (User clonedUser : usersToCreate) {
            for (PermissionSetAssignment psa : assignedPermissionSets) {
                // Create a new PermissionSetAssignment instance for each cloned user
                PermissionSetAssignment clonedPsa = new PermissionSetAssignment(
                    AssigneeId = clonedUser.Id,
                    PermissionSetId = psa.PermissionSetId
                );
                permissionSetAssignments.add(clonedPsa);
            }
        }

        // Insert Permission Set Assignments
        if (!permissionSetAssignments.isEmpty()) {
            insert permissionSetAssignments;
        }

        cloneMessage = 'Users created successfully.';
        showCreateUsersButton = false;
    } catch (Exception e) {
        cloneMessage = 'Error creating users: ' + e.getMessage();
    }
}


}