%Author: Shebuti Rayana
%Feature Description: Weighted rating deviation, where reviews are weighted
%with recency. Weight is calculated as w_{ij} = 1/t_{ij}^alpha, where,
%alpha = 1.5 (decay rate)

%Input:
%user: user id 
%prod: product id
%rating: the rating given by "user" to "prod" 
%date: the date "user" writes a review for "prod" 
%dateFormat: format of the date (e.g. dd-mmm-yyyy)

%output
%WRD_user: weighted rating deviation for users
%WRD_prod: weighted rating deviation for products

function [WRD_user,WRD_prod] = WRD(user, prod, rating, date, dateFormat)
    uniqueDate = unique(date);
    [Y,M,D] = datevec(uniqueDate, dateFormat); %this date format might be different for different datasets
    temp = [Y,M,D,zeros(length(Y),1),zeros(length(Y),1),zeros(length(Y),1)];
    tempDate = sortrows(temp,[1 2 3]);
    uniqueDate = cellstr(datestr(tempDate, dateFormat));
    D = length(uniqueDate);
    
    uniqueUser = unique(user);
    uniqueProd = unique(prod);
    
    N = length(uniqueUser);
    M = length(uniqueProd);
    [~,userID] = ismember(user,uniqueUser);
    [~,prodID] = ismember(prod,uniqueProd);
    [~,dateID] = ismember(date,uniqueDate);
    
    avgRating = zeros(length(rating),1);

    for i = 1:M
        index = find(prodID == i);
        s = rating(index);
        if(~isempty(s))
            avgRating(index,1) = sum(s)/length(s);
        end 
    end

    RD = abs(double(rating) - avgRating); % calculating rating deviation of all reviews

    alpha = 1.5;
    %calculating weights of reviews
    W = zeros(length(rating),1);
    
    for i = 1:M
        index = find(prodID == i);
        d = dateID(index);
        if(~isempty(d) && length(d) > 1)
            ud = unique(d);
            [f,~] = hist(d,ud);
            numD = length(ud);
            m = 0;
            r = [];
            for j = 1:numD
               r(d == ud(j)) = m + 1; 
               m = m + f(j);
            end 
            W(index,1) = 1./(r.^alpha);
        else
            r = 1;
            W(index,1) = 1./(r.^alpha);
        end 
    end

    % reviewer feature

    WRD_user = zeros(N,1);

    for i = 1:N
        index = find(userID == i);
        r = RD(index);
        w = W(index);
        if(~isempty(r))
            WRD_user(i,1) = sum(r.*w)/sum(w);
        end 
    end

    % product feature
    WRD_prod = zeros(M,1);

    for i = 1:M
        index = find(prodID == i);
        r = RD(index);
        w = W(index);
        if(~isempty(r))
            WRD_prod(i,1) = sum(r.*w)/sum(w);
        end 
    end
end