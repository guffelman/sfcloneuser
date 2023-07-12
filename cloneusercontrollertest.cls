@IsTest
public class CloneUserControllerTest {
    @IsTest
    public static void testCreateUsers() {
        // Get the executing user
        User executingUser = [SELECT Id, Alias, LocaleSidKey, TimeZoneSidKey, LanguageLocaleKey, EmailEncodingKey, ProfileId, ManagerId, EmployeeNumber, CallCenterId, UserRoleId, UserPermissionsInteractionUser, UserPermissionsKnowledgeUser, UserPermissionsMarketingUser, UserPermissionsOfflineUser, IsActive, FederationIdentifier FROM User WHERE Id = :UserInfo.getUserId()];

        // Create a new standard controller instance and pass the executing user record
        ApexPages.StandardController standardController = new ApexPages.StandardController(executingUser);

        // Create an instance of the CloneUserController using the standard controller
        CloneUserController controller = new CloneUserController(standardController);

        // Set the number of duplicates
        controller.numberOfDuplicates = 2;

        // Call the cloneUsers method
        controller.cloneUsers();

        // Assert that the clonedUsers list has the expected number of records
        System.assertEquals(2, controller.clonedUsers.size());

        // Set up necessary data for permission set assignments
 //       PermissionSetLicenseAssign mainUserLicense = new PermissionSetLicenseAssign(
 //           AssigneeId = executingUser.Id,
 //           PermissionSetLicenseId = 'YOUR_PERMISSION_SET_LICENSE_ID'
 //       );
 //       insert mainUserLicense;

        PermissionSet mainUserPermissionSet = [SELECT Id FROM PermissionSet WHERE IsOwnedByProfile = false LIMIT 1];

        PermissionSetAssignment mainUserPermissionSetAssignment = new PermissionSetAssignment(
            AssigneeId = executingUser.Id,
            PermissionSetId = mainUserPermissionSet.Id
        );
        insert mainUserPermissionSetAssignment;

        // Set the usernames, first names, last names, and email fields for the cloned users
        for (Integer i = 0; i < controller.clonedUsers.size(); i++) {
            User clonedUser = controller.clonedUsers[i];
            clonedUser.Username = 'testuser' + (i == 0 ? '' : String.valueOf(i)) + '@customtruck.com.testenv';
            clonedUser.FirstName = 'Test';
            clonedUser.LastName = 'User' + (i == 0 ? '' : ' ' + i);
            clonedUser.Email = clonedUser.Username;
        }

        // Call the createUsers method
        controller.createUsers();

        // Assert that the cloneMessage is set to 'Users created successfully.'
        System.assertEquals('Users created successfully.', controller.cloneMessage);

        // Assert that the showCreateUsersButton is set to false
        System.assertEquals(false, controller.showCreateUsersButton);

        // Assert that the assignedPermissionSets list is not empty
        System.assertNotEquals(0, controller.assignedPermissionSets.size());

        // Assert that the permission set assignments are created for each cloned user
        for (User clonedUser : controller.clonedUsers) {
            PermissionSetAssignment clonedPsa = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :clonedUser.Id AND PermissionSetId = :mainUserPermissionSet.Id];
            System.assertNotEquals(null, clonedPsa, 'Permission set assignment not found for cloned user: ' + clonedUser.Id);
        }
    }
}