%Author: Shebuti Rayana
%Feature Description: Entropy of temporal gaps delta_{t}. Given the temporal 
%line-up of user's (product's) reviews each gap delta_{t} denotes the temporal gap
%in days between consecutive pairs

%Input:
%user: user ID
%prod: product ID
%date: the date "user" writes a review for "prod" 
%dateFormat: format of the date (e.g. dd-mmm-yyyy)

%output
%ETG_user: Entropy of temporal gaps for users
%ETG_prod: Entropy of temporal gaps for products 

function [ETG_user, ETG_prod] = ETG(user, prod, date, dateFormat)
    uniqueUser = unique(user);
    uniqueProd = unique(prod);
    
    N = length(uniqueUser);
    P = length(uniqueProd);
    [~,userID] = ismember(user,uniqueUser);
    [~,prodID] = ismember(prod,uniqueProd);
    
    ETG_user = zeros(N,1);

    for i = 1:N
        d = date(userID == i);
        % sort dates
        [Y,M,D] = datevec(d, dateFormat); 
        temp = [Y,M,D,zeros(length(Y),1),zeros(length(Y),1),zeros(length(Y),1)];
        tempDate = sortrows(temp,[1 2 3]);
        d = cellstr(datestr(tempDate, dateFormat));
        deltaT = datenum(datevec(d(2:end))) - datenum(datevec(d(1:end-1))); 
        %distribution
    %     1- 0 days
    %     2- [1-2] days
    %     3- [3-4] days
    %     4- [5-8] days
    %     5- [9-16] days
    %     6- [17-32] days
    %     Throw away any gaps for >=33 days
         deltaT(deltaT >= 33) = [];
         edges = [0 1 3 5 9 17];
         [f,~] = hist(deltaT,edges);
         f = f(f>0);
         if(~isempty(f))
            p = f./length(deltaT);
            ETG_user(i,1) = sum(-p.*log2(p));
         end
    end

    % product feature

    ETG_prod = zeros(P,1);

    for i = 1:P
        d = date(prodID == i);
        % sort days
        [Y,M,D] = datevec(d, dateFormat); % dates can be in different format for different datasets
        temp = [Y,M,D,zeros(length(Y),1),zeros(length(Y),1),zeros(length(Y),1)];
        tempDate = sortrows(temp,[1 2 3]);
        d = cellstr(datestr(tempDate,dateFormat));
        deltaT = datenum(datevec(d(2:end))) - datenum(datevec(d(1:end-1))); 
        %distribution
    %     1- 0 days
    %     2- [1-2] days
    %     3- [3-4] days
    %     4- [5-8] days
    %     5- [9-16] days
    %     6- [17-32] days
    %     Throw away any gaps for >=33 days
         deltaT(deltaT >= 33) = [];
         edges = [0 1 3 5 9 17];
         [f,~] = hist(deltaT,edges);
         f = f(f>0);
         if(~isempty(f))
            p = f./length(deltaT);
            ETG_prod(i,1) = sum(-p.*log2(p)); 
         end
    end

end