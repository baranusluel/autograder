%% updater: Update the autograder with a new build
%
% updater will update the autograder to the latest build
%
% updater(T) will use GitHub token T to update the autograder to the latest
% version.
%
%%% Remarks
%
% updater uninstalls the app, if it can find it - it looks for Autograder
% in the currently installed suite of apps
%
function updater(token)
% Steps:
%   1. Download Release
%   2. Save settings in memory (to write later)
%   3. Uninstall the app
%   4. Remove folder, if it exists
%   5. Install new release
%   6. Add back initial settings
%   7. Run new autograder
%
%% Download Release
% Downloading the release
% query GitHub for the latest release, using the token:
ENDPOINT = 'https://github.gatech.edu/api/v3/repos/CS1371/autograder/releases/latest';
opts = weboptions;
opts.HeaderFields = {'Authorization', ['Bearer ' token]};
latest = webread(ENDPOINT, opts);
asset = latest.assets;
asset = asset(endsWith({asset.name}, '.mlappinstall'));
p = fileparts(mfilename('fullpath'));
p = fullfile(p, '..', 'resources', 'addons_core.xml');
isAvailable = false;
if isfile(p)
    xml = xmlread(p);
    current = char(xml.getDocumentElement().getElementsByTagName('version').item(0).item(0).getData());
    % compare. first compare major, then minor, then patch
    current = strsplit(current, '.');
    latest = strsplit(latest.tag_name(2:end), '.');
    current = cellfun(@str2num, current);
    latest = cellfun(@str2num, latest);
    if latest(1) > current(1)
        isAvailable = true;
    elseif latest(1) == current(1) && latest(2) > current(2)
        isAvailable = true;
    elseif latest(1) == current(1) && latest(2) == current(2) && latest(3) > current(3)
        isAvailable = true;
    end
end

if isAvailable
    % download asset
    downloadLocation = [tempname '.mlappinstall'];
    fid = fopen(downloadLocation, 'wb');
    
    auth = matlab.net.http.HeaderField;
    auth.Name = 'Authorization';
    auth.Value = ['Bearer ' token];
    content = matlab.net.http.HeaderField;
    content.Name = 'Accept';
    content.Value = 'application/octet-stream';
    
    request = matlab.net.http.RequestMessage;
    request.Header = [auth, content];
    response = request.send(asset.url);
    
    if response.StatusCode == 200
        % data is in Data payload; just write
        fwrite(fid, response.Body.Data);
        fclose(fid);
    elseif response.StatusCode == 302
        location = resp.Header(strcmpi([resp.Header.Name], "location"));
        response = request.send(location.Value);
        if response.StatusCode == 200
            fwrite(fid, response.Body.Data);
            fclose(fid);
        else
            fclose(fid);
            delete(downloadLocation);
            e = MException('AUTOGRADER:updater:cannotDownloadRelease', ...
                'An error occurred while downloading the latest release');
            e.throw();
        end
    else
        % error; die
        fclose(fid);
        delete(downloadLocation);
        e = MException('AUTOGRADER:updater:cannotDownloadRelease', ...
            'An error occurred while downloading the latest release');
        e.throw();
    end
else
    return;
end

%% Save Settings in Memory
%
% settings will be in userInterface folder; read into memory
settingsPath = fileparts(fileparts(mfilename('fullpath')));
settingsPath = fullfile(settingsPath, 'userInterface', 'settings.autograde');

fid = fopen(settingsPath, 'rt');
userSettings = char(fread(fid)');
fclose(fid);

%% Uninstall the Autograder
%
apps = matlab.apputil.getInstalledAppInfo();
app = apps(strcmpi({apps.name}, 'Autograder'));
matlab.apputil.uninstall(app.id);

%% Delete folder
if isfolder(app.location)
    rmdir(app.location, 's');
end

%% Install New Release
matlab.apputil.install(downloadLocation);

%% Restore Settings
fid = fopen(settingsPath, 'wt');
fwrite(fid, userSettings);
fclose(fid);

%% Inform of Success
fprintf(1, 'The Autograder has been successfully updated\n');