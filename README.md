# SFCloneUser 

SFCloneUser is a Salesforce project that provides functionality to clone a user record and create duplicates with assigned permission sets. The project consists of both an Apex class (`CloneUserController`) and a Visualforce page (`CloneUserPage`).

## Apex Class: `CloneUserController`

The `CloneUserController` class is responsible for handling the logic behind cloning user records and creating duplicates. It provides methods to clone users, create new user records, assign permission sets, and manage error handling. Key properties and methods include:

### Properties
- `numberOfDuplicates`: An integer representing the desired number of user duplicates to be created.
- `clonedUsers`: A list of `User` objects that stores the cloned user records.
- `assignedPermissionSets`: A list of `PermissionSetAssignment` objects representing the assigned permission sets for the main user.
- `cloneMessage`: A string that holds the status message for the cloning operation.
- `showClonedUsers`, `showCreateUsersButton`, `showCloneUserButton`: Boolean flags indicating the visibility of UI elements on the Visualforce page.

### Methods
- `CloneUserController()`: Constructor method that initializes the object and retrieves the main user record and associated permission set licenses.
- `cloneUsers()`: Clones the main user record based on the specified `numberOfDuplicates` and populates the necessary fields.
- `createUsers()`: Inserts the cloned user records into the database, assigns permission set licenses, and assigns permission sets to the duplicated users.

## Visualforce Page: `CloneUserPage`

The `CloneUserPage` Visualforce page provides a user interface for interacting with the cloning functionality. It allows users to view the main user details, specify the number of duplicates to create, enter details for each cloned user, and initiate the cloning process. Key elements and functionality include:

### Markup Elements
- `apex:pageBlock`, `apex:pageBlockSection`: Visual containers to organize the page layout.
- `apex:outputField`, `apex:outputLabel`: Displays field values and labels for the main user details.
- `apex:inputText`, `apex:inputField`: Input fields for specifying the number of duplicates and entering details for each cloned user.
- `apex:commandButton`: Buttons to trigger the cloning and creation processes.
- `apex:outputText`: Displays the cloning status message.
- `apex:repeat`: Iterates over the `assignedPermissionSets` and `clonedUsers` lists to display assigned permission sets and input fields for each cloned user.

### Functionality
- Displays main user details such as name, profile, role, and assigned permission sets.
- Allows users to specify the number of duplicates to create and initiate the cloning process.
- Provides input fields for entering details (first name, last name, username, email, manager, employee number) for each cloned user.
- Shows the cloning status message and any error messages encountered during the process.
- Renders UI elements dynamically based on the cloning process state.


## Usage

To integrate the SFCloneUser project into your Salesforce organization and add it to the User page layout, follow these steps:

1. Install the Apex class `CloneUserController`:
   - Open the Salesforce Developer Console.
   - Create a new Apex class.
   - Copy and paste the code from the `CloneUserController` provided in the project.
   - Save the Apex class with the name `CloneUserController`.

2. Install the Visualforce page `CloneUserPage`:
   - Open the Salesforce Developer Console.
   - Create a new Visualforce page.
   - Copy and paste the code from the `CloneUserPage` provided in the project.
   - Save the Visualforce page with the name `CloneUserPage`.

3. Create a custom link on the user object

4. Add the custom link to the user page layout.

By following these steps, you will be able to leverage the SFCloneUser project and its functionality within your Salesforce org.

Please refer to the documentation and comments within the code for more detailed information on customizations and additional functionality.
