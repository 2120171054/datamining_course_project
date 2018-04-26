%Author: Shebuti Rayana
%Feature Description: ratio of negative reviews (1-2 stars) for both
%user and product

%Input:
%user: user id 
%prod: product id
%rating: the rating given by "user" to "prod" 

%output
%rNR_user: ratio of negative reviews for users
%rNR_prod: ration of negative reviews for products

function [rNR_user,rNR_prod] = NR(user,prod,rating)
    uniqueUser = unique(user);
    uniqueProd = unique(prod);
    
    N = length(uniqueUser);
    M = length(uniqueProd);
    [~,userID] = ismember(user,uniqueUser);
    [~,prodID] = ismember(prod,uniqueProd);
    
    % user
    U = [1:N]';
    [totalReviewCount_user,~] = hist(userID,U); % counting total number of reviews per user
    
    userID_N = userID(rating < 3); % users with negative rating (4-5*) 
    [negativeCount,~] = hist(userID_N,U);

    rNR_user = (negativeCount'./totalReviewCount_user');

    % product 
    P = [1:M]';
    [totalReviewCount_prod,~] = hist(prodID,P); % counting total number of reviews per prod

    prodID_N = prodID(rating < 3); % prod with negative rating (4-5*)
    [negativeCount,~] = hist(prodID_N,P);

    rNR_prod = (negativeCount'./totalReviewCount_prod');
end