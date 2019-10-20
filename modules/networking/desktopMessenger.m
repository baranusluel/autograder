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
    if ispc
        % Use powershell:
        notifier = [fileparts(mfilename('fullpath')) filesep 'desktopMessenger.ps1'];
        ps = fileread(notifier);
        ps = strrep(ps, 'MESSAGE', message);
        ps = strrep(ps, '"', '\"');
        [~, ~] = system(['powershell.exe "' ps '"']);
    elseif ismac
        notifier = [fileparts(mfilename('fullpath')) filesep 'desktopMessenger.applescript'];
        as = fileread(notifier);
        as = strrep(as, 'MESSAGE', message);
        [~, ~] = system(['osascript -e ''' as '''']);
    else
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
    end