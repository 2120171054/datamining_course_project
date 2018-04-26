%Author: Shebuti Rayana
%Feature Description: Burstiness of reviews by users. Spammers are often short term
%members of the site: so BST(i) = 0, if L(i) - F(i) > tau else BST(i) = 1 -
%(L(i) - F(i))/tau, where, L(i) - F(i) are number of days between first and
%last review of i, tau = 28 days

%Input:
%user: user ID
%date: the date "user" writes a review 
%dateFormat: format of the date (e.g. dd-mmm-yyyy)

%output
%BST_user: burstiness of reviews by users

function BST_user = BST(user, date, dateFormat)
    uniqueUser = unique(user);
    N = length(uniqueUser);
    [~,userID] = ismember(user,uniqueUser);

    % user feature
    tau = 28;
    BST_user = ones(N,1);

    for i = 1:N
        index = find(userID == i);
        d = date(index);
        if(length(index) > 1)
            %sort dates
            [Y,M,D] = datevec(d, dateFormat); %this date format might be different for different datasets
            temp = [Y,M,D,zeros(length(Y),1),zeros(length(Y),1),zeros(length(Y),1)];
            tempDate = sortrows(temp,[1 2 3]);
            d = cellstr(datestr(tempDate, dateFormat));
            NumDays = datenum(datevec(d(length(d)))) - datenum(datevec(d(1)));
            if(NumDays > tau)
                BST_user(i,1) = 0;
            else
                BST_user(i,1) = 1 - (NumDays/tau);
            end
        end

    end
end