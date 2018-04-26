%Author: Shebuti Rayana
%Feature Description: Entropy of rating distribution of user's (product's)
%reviews

%Input:
%user: user id 
%prod: product id
%rating: the rating given by "user" to "prod" 

%output
%ERD_user: entropy of rating distribution for users
%ERD_prod: entropy of rating distribution for products

function [ERD_user, ERD_prod]= ERD(user, prod, rating)
    uniqueUser = unique(user);
    uniqueProd = unique(prod);
    
    N = length(uniqueUser);
    M = length(uniqueProd);
    [~,userID] = ismember(user,uniqueUser);
    [~,prodID] = ismember(prod,uniqueProd);
    
    Rating = [1:5]';
    
    % user feature
    ERD_user = zeros(N,1);

    for i = 1:N
        s = rating(userID == i);
        if(~isempty(s))
           [f,~] = hist(s,Rating);
           f = f(f>0);
           if(~isempty(f))
                p = f./length(s);
                ERD_user(i,1) = sum(-p.*log2(p));
           end
        end 
    end

    % product feature
    ERD_prod = zeros(M,1);

    for i = 1:M
        s = rating(prodID == i);
        if(~isempty(s))
           [f,~] = hist(s,Rating); 
           f = f(f>0);
           if(~isempty(f))
                p = f./length(s);
                ERD_prod(i,1) = sum(-p.*log2(p));
           end
        end 
    end
end