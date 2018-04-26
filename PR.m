%Author: Shebuti Rayana
%Description: ratio of positive reviews (4-5 stars) for both
%user and product

%Input:
%user: user id 
%prod: product id
%rating: the rating given by "user" to "prod" 

%output
%rPR_user: ratio of positive reviews for users
%rPR_prod: ration of positive reviews for products

function [rPR_user,rPR_prod] = PR(user,prod,rating)
    uniqueUser = unique(user);
    uniqueProd = unique(prod);
    
    N = length(uniqueUser);
    M = length(uniqueProd);
    [~,userID] = ismember(user,uniqueUser);
    [~,prodID] = ismember(prod,uniqueProd);
    
    % user
    U = [1:N]';
    [totalReviewCount_user,~] = hist(userID,U); % counting total number of reviews per user
    
    userID_P = userID(rating > 3); % users with positive rating (4-5*) 
    [positiveCount,~] = hist(userID_P,U);

    rPR_user = (positiveCount'./totalReviewCount_user');

    % product 
    P = [1:M]';
    [totalReviewCount_prod,~] = hist(prodID,P); % counting total number of reviews per prod

    prodID_P = prodID(rating > 3); % prod with positive rating (4-5*)
    [positiveCount,~] = hist(prodID_P,P);

    rPR_prod = (positiveCount'./totalReviewCount_prod');
end