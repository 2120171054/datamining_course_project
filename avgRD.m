%Author: Shebuti Rayana
%Feature Description: Average rating deviation avg(|d_{i*}|) of user
%(product) i's reviews, where |d_{ij}| is absolute rating deviation of i's
%rating from j's average rating

%Input:
%user: user id 
%prod: product id
%rating: the rating given by "user" to "prod" 

%output
%avgRD_user: average rating deviation for users
%avgRD_prod: average rating deviation for products

function [avgRD_user,avgRD_prod] = avgRD(user, prod, rating)
    uniqueUser = unique(user);
    uniqueProd = unique(prod);
    
    N = length(uniqueUser);
    M = length(uniqueProd);
    [~,userID] = ismember(user,uniqueUser);
    [~,prodID] = ismember(prod,uniqueProd);
    
    avgRating = zeros(length(rating),1);

    for i = 1:M
        index = find(prodID == i);
        s = rating(index);
        if(~isempty(s))
            avgRating(index,1) = sum(s)/length(s);
        end 
    end

    RD = abs(double(rating) - avgRating); % calculating rating deviation

    % user feature
    avgRD_user = zeros(N,1);

    for i = 1:N
        r = RD(userID == i);
        if(~isempty(r))
            avgRD_user(i,1) = sum(r)/length(r);
        end 
    end

    % product feature
    avgRD_prod = zeros(M,1);

    for i = 1:M
        r = RD(prodID == i);
        if(~isempty(r))
            avgRD_prod(i,1) = sum(r)/length(r);
        end 
    end
end