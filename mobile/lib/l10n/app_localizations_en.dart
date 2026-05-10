// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Kanban Board';

  @override
  String get login => 'Login';

  @override
  String get signup => 'Sign Up';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get fullName => 'Full Name';

  @override
  String get forgotPassword => 'Forgot Password';

  @override
  String get noAccount => 'Don\'t have an account? Sign up';

  @override
  String get alreadyHaveAccount => 'Already have an account? Login';

  @override
  String get boards => 'Boards';

  @override
  String get workspaces => 'Workspaces';

  @override
  String get activity => 'Activity';

  @override
  String get account => 'Account';

  @override
  String get settings => 'Settings';

  @override
  String get logout => 'Logout';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get changePassword => 'Change Password';

  @override
  String get notifications => 'Notifications';

  @override
  String get theme => 'Appearance';

  @override
  String get language => 'Language';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get appInfo => 'App Information';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get add => 'Add';

  @override
  String get appearanceAndLanguage => 'Appearance and Language';

  @override
  String get systemDefault => 'System Default';

  @override
  String get devicePreference => 'Based on device preference';

  @override
  String get lightTheme => 'Light Theme';

  @override
  String get darkTheme => 'Dark Theme';

  @override
  String get turkish => 'Turkish';

  @override
  String get english => 'English';

  @override
  String get accessibility => 'Accessibility';

  @override
  String get highContrast => 'High Contrast Colors';

  @override
  String get improveReadability => 'Improve readability';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmPassword => 'Confirm New Password';

  @override
  String get passwordChangedSuccessfully => 'Password changed successfully';

  @override
  String get changePasswordFailed => 'Failed to change password';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get passwordTooShort => 'Password must be at least 8 characters';

  @override
  String get passwordTooLong => 'Password must be at most 40 characters';

  @override
  String get passwordSameAsCurrent =>
      'New password cannot be the same as current password';

  @override
  String get resetYourPassword => 'Reset your password';

  @override
  String get enterEmailToReset =>
      'Enter your email address and we\'ll send you a password reset link.';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get emailSent => 'Email Sent!';

  @override
  String checkEmailForLink(String email) {
    return 'A password reset link has been sent to $email. Please check your email.';
  }

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get invalidEmail => 'Please enter a valid email address';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get notificationTypes => 'Notification Types';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get inAppAndDevice => 'In-app and device notifications';

  @override
  String get emailNotifications => 'Email Notifications';

  @override
  String get importantUpdatesEmail => 'Email for important updates';

  @override
  String get notificationCategories => 'Notification Categories';

  @override
  String get cardComments => 'Card Comments';

  @override
  String get notifyOnComments => 'Notify when someone comments on cards';

  @override
  String get cardAssignments => 'Card Assignments';

  @override
  String get notifyOnAssignments => 'Notify when a card is assigned to you';

  @override
  String get boardUpdates => 'Board Updates';

  @override
  String get importantBoardChanges => 'Important changes in your boards';

  @override
  String get mentions => 'Mentions';

  @override
  String get notifyOnMentions => 'Notify when someone mentions you';

  @override
  String get profileUpdatedSuccessfully => 'Profile updated successfully';

  @override
  String get fullNameRequired => 'Full name is required';

  @override
  String membersOf(String workspaceName) {
    return '$workspaceName Members';
  }

  @override
  String get noMembersFound => 'No members found.';

  @override
  String get unknownUser => 'Unknown User';

  @override
  String get me => 'Me';

  @override
  String get makeAdmin => 'Make Admin';

  @override
  String get makeMember => 'Make Member';

  @override
  String get makeObserver => 'Make Observer';

  @override
  String get removeMember => 'Remove Member';

  @override
  String get roleUpdateFailed => 'Failed to update role';

  @override
  String get removeMemberConfirm =>
      'Are you sure you want to remove this member from the workspace?';

  @override
  String get removeMemberFailed => 'Failed to remove member';

  @override
  String get remove => 'Remove';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get noWorkspacesYet => 'No workspaces yet';

  @override
  String get createFirstWorkspace => 'Create your first workspace';

  @override
  String get newWorkspace => 'New Workspace';

  @override
  String get createWorkspace => 'Create Workspace';

  @override
  String get workspaceName => 'Workspace Name';

  @override
  String get descriptionOptional => 'Description (optional)';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get createFailed => 'Failed to create';

  @override
  String get workspaceCreatedSuccessfully => 'Workspace created successfully';

  @override
  String get manageMembers => 'Manage Members';

  @override
  String get inviteMember => 'Invite Member';

  @override
  String get editWorkspace => 'Edit Workspace';

  @override
  String get deleteWorkspaceTitle => 'Delete Workspace';

  @override
  String deleteWorkspaceConfirm(String workspaceName) {
    return '$workspaceName will be deleted. This action cannot be undone.';
  }

  @override
  String get deleteFailed => 'Failed to delete';

  @override
  String inviteToWorkspace(String workspaceName) {
    return 'Invite a new member to $workspaceName.';
  }

  @override
  String get adminRole => 'Administrator (Admin)';

  @override
  String get memberRole => 'Member (Member)';

  @override
  String get observerRole => 'Observer (Observer)';

  @override
  String get invitationFailed => 'Failed to send invitation';

  @override
  String get invitationSentSuccessfully => 'Invitation sent successfully';

  @override
  String get send => 'Send';

  @override
  String lastUpdated(String date) {
    return 'Last Updated: $date';
  }

  @override
  String get profileInfo => 'Profile Info';

  @override
  String get profileInfoSubtitle => 'Name, email, profile photo';

  @override
  String get manageWorkspaces => 'Manage Workspaces';

  @override
  String get manageWorkspacesSubtitle => 'Create, edit, delete';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'System';

  @override
  String get about => 'About';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get appDescription =>
      'Kanban Board application is designed for you to easily manage your projects and tasks. It was developed using MVVM architecture and Flutter.';

  @override
  String developerLabel(String name) {
    return 'Developer: $name';
  }

  @override
  String licenseLabel(String license) {
    return 'License: $license';
  }

  @override
  String get termsContent1 =>
      '1. By using the application, you are deemed to have accepted these terms.';

  @override
  String get termsContent2 =>
      '2. The security of your data is important to us.';

  @override
  String get termsContent3 => '3. Misuse of the application is prohibited.';

  @override
  String get termsContent4 =>
      '4. The service provider reserves the right to make changes to the service.';

  @override
  String get termsFooter => 'These terms may be updated from time to time.';

  @override
  String get privacyContent =>
      'Your privacy is important to us. Your data is not shared with third parties. Data collected within the application is only used to improve your experience and ensure your account security.';

  @override
  String get whatDataCollect => 'What data do we collect?';

  @override
  String get dataEmail => '- Email address';

  @override
  String get dataFullName => '- Full Name';

  @override
  String get dataContent => '- Content you create';

  @override
  String get deleteAccountConfirm =>
      'Your account will be permanently deleted. This action cannot be undone. Do you want to continue?';

  @override
  String get deleteAccountFailed => 'Failed to delete account';

  @override
  String get card => 'Card';

  @override
  String get noActivity => 'No activity';

  @override
  String get noActivityFoundForSelection =>
      'No activity records found for this selection.';

  @override
  String get noWorkspacesFound => 'Workspaces not found.';

  @override
  String get noBoardsFound => 'Boards not found.';

  @override
  String get noCardsFound => 'Cards not found.';

  @override
  String get before => 'Before';

  @override
  String get after => 'After';

  @override
  String get inbox => 'Inbox';

  @override
  String get invitations => 'Invitations';

  @override
  String get markAllReadSuccess => 'All marked as read';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get noNotificationsSubtitle =>
      'You will see all updates here when you stay informed.';

  @override
  String get receivedInvitations => 'Received Invitations';

  @override
  String get noReceivedInvitations => 'You have no pending invitations.';

  @override
  String get sentInvitations => 'Sent Invitations';

  @override
  String get noSentInvitations => 'You have no pending sent invitations.';

  @override
  String invitedBy(String name) {
    return 'Invited by: $name';
  }

  @override
  String get reject => 'Reject';

  @override
  String get accept => 'Accept';

  @override
  String get invitationRejected => 'Invitation rejected';

  @override
  String get invitationAccepted => 'Invitation accepted';

  @override
  String get cancelInvitation => 'Cancel Invitation';

  @override
  String get cancelInvitationConfirm =>
      'Are you sure you want to cancel this invitation?';

  @override
  String get yesCancel => 'Yes, Cancel';

  @override
  String get invitationCancelled => 'Invitation cancelled';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int count) {
    return '$count minutes ago';
  }

  @override
  String hoursAgo(int count) {
    return '$count hours ago';
  }

  @override
  String daysAgo(int count) {
    return '$count days ago';
  }

  @override
  String get username => 'User';

  @override
  String get role => 'Role';

  @override
  String get editList => 'Edit List';

  @override
  String get cardMoveFailed => 'Failed to move card';

  @override
  String get allNotifications => 'All Notifications';

  @override
  String get notifyOnAllActivity =>
      'Get notifications for all activity in this board';

  @override
  String get notifyOnPersonal => 'Only for assignments and mentions';

  @override
  String get editBoard => 'Edit Board';

  @override
  String get boardName => 'Board Name';

  @override
  String get boardUpdated => 'Board updated';

  @override
  String get deleteBoardConfirm =>
      'Are you sure you want to delete this board? This action cannot be undone.';

  @override
  String get listName => 'List Name';

  @override
  String deleteListConfirm(String listName) {
    return 'Are you sure you want to delete the list $listName?';
  }

  @override
  String get cardTitle => 'Card Title';

  @override
  String get titleRequired => 'Title is required';

  @override
  String get boardBackground => 'Board Background';

  @override
  String get defaultOption => 'Default';

  @override
  String get green => 'Green';

  @override
  String get yellow => 'Yellow';

  @override
  String get backgroundUpdateFailed => 'Failed to update background';

  @override
  String get loginFailed => 'Login failed';

  @override
  String get emailNotFoundSignup => 'Email not found. Please sign up.';

  @override
  String get loginError => 'Login Error';

  @override
  String get loginWithGoogle => 'Login with Google';

  @override
  String get purple => 'Purple';

  @override
  String get blue => 'Blue';

  @override
  String get orange => 'Orange';

  @override
  String get pink => 'Pink';

  @override
  String get teal => 'Teal';

  @override
  String get colors => 'Colors';

  @override
  String get signupFailed => 'Signup failed';

  @override
  String get bySigningUp => 'By signing up, you accept our ';

  @override
  String get youAccept => '.';

  @override
  String get termsOfServiceContent =>
      'Terms of Service content will be here...';

  @override
  String get privacyPolicyContent => 'Privacy Policy content will be here...';

  @override
  String get ok => 'OK';

  @override
  String get and => 'and';

  @override
  String get error => 'Error';

  @override
  String get cards => 'Cards';

  @override
  String get createBoard => 'Create Board';

  @override
  String get newBoard => 'New Board';

  @override
  String createBoardToWorkspace(String workspaceName) {
    return 'Create Board for $workspaceName';
  }

  @override
  String get mustCreateWorkspaceFirst =>
      'You must create a workspace first to create a board.';

  @override
  String get boardCreatedSuccessfully => 'Board created';

  @override
  String get boardCreateFailed => 'Failed to create board';

  @override
  String get unknownWorkspace => 'Unknown Workspace';

  @override
  String get createBoardTitle => 'Create New Board';
}
