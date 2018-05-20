function [exists,separation] = waldoy(person)
%Start helper function with a separation of 0
[exists,separation] = waldoExists(person,0);
end

function [out,separation] = waldoExists(person,degrees)
%Get all the field names for the current person
fields = fieldnames(person);
%Initialize found Waldo logical to false - assume we don't find him
out = false;
%Loop through all fields for one person
for i = 1:length(fields)
    %Make sure the current field has a char or else strcmp will fail
    if ischar(class(person.(fields{i})))
        %Check if the field contains Waldo
        if strcmpi('Waldo',person.(fields{i}))
            %Found Waldo
            out = true;
            %Set separation as current degrees of separation
            separation = degrees;
        end 
    end
end

if ~out
    %If we haven't found him, we need to check all of the current friends
    %The following vectors will keep track of the outputs for all of the
    %friends
    friendsExists = [];
    friendsDegreesOfSeparation = [];
    %Loop through all friends
    for i = 1:length(person.Friends)
        %Test the current friend (recursively)
        [foundInFriend, degree] = waldoExists(person.Friends(i),degrees+1);
        %Collect the logical with all the other friends
        friendsExists = [friendsExists foundInFriend];
        %Collect the degrees with all the other friends
        friendsDegreesOfSeparation = [friendsDegreesOfSeparation degree];
    end
    %Determine if Waldo is friends with any of the current friends
    out = any(friendsExists);
    if out
        %If we found Waldo, the degree of separation will be the only
        %non-zero value
        separation = max(friendsDegreesOfSeparation);
    else
        %We didn't find Waldo - assign 0 degrees of separation
        separation = 0;
    end
end
end