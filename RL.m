%Author: Shebuti Rayana
%Feature Description: average review length in number of words for both
%users and products

%Input:
%user: user id 
%prod: product id
%wordcount_reviews: number of words of a review written by "user" to "prod"
%for getting the "wordcount_reviews" run the python code WordCount.py

%output
%RL_user: average review langth for users
%RL_prod: average review length for products

function [RL_user,RL_prod] = RL(user,prod,wordcount_reviews)
    uniqueUser = unique(user);
    uniqueProd = unique(prod);
    
    N = length(uniqueUser);
    M = length(uniqueProd);
    [~,userID] = ismember(user,uniqueUser);
    [~,prodID] = ismember(prod,uniqueProd);

    % user feature
    RL_user = zeros(N,1); 

    for i = 1:N
        r = wordcount_reviews(userID == i);
        if(~isempty(r))
            RL_user(i,1) = sum(r)/length(r);
        end 
    end
    % hotel feature
    RL_prod = zeros(M,1); 

    for i = 1:M
        r = wordcount_reviews(prodID == i);
        if(~isempty(r))
            RL_prod(i,1) = sum(r)/length(r);
        end 
    end

end