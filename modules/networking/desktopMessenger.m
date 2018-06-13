%% desktopMessenger: Send a notification to the user
%
% desktopMessenger(M) will send a notification using message M.
%
%%% Remarks
%
% This uses the JCommunique library to send platform-independent
% notifications.
%
function desktopMessenger(message)
    % Import JCommunique
    javaaddpath([fileparts(mfilename('fullpath')) filesep 'JCommunique.jar']);
    cleaner = onCleanup(@()(javarmpath([fileparts(mfilename('fullpath')) ...
        filesep 'JCommunique.jar'])));
    import com.notification.*;
    import com.notification.manager.*;
    import com.notification.types.*;
    import com.theme.*;
    import com.utils.*;
    import javax.swing.ImageIcon;
    
    % Get the icon necessary for the notification
    p = [fileparts(fileparts(mfilename('fullpath'))) ...
        'docs' filesep 'resources' filesep 'images' filesep 'icon_48.png'];
    img = ImageIcon(p);
    
    % Create notification factory; use default dark theme
    factory = NotificationFactory(ThemePackagePresets.cleanDark());
    manager = SimpleManager();
    notification = factory.buildIconNotification('Autograder', message, img);
    notification.setCloseOnClick(true);
    manager.addNotification(notification, Time.seconds(100));
    clear factory;
    clear manager;
    clear notification;