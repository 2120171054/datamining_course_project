%Author: Shebuti Rayana
%Feature Description: Absolute rating deviation from the products average
%rating

%Input:
%prod: product id
%rating: the rating given by the users to "prod" 

%output
%RD_reviews: rating deviation for reviews

function [RD_reviews] = RD(prod, rating)
    uniqueProd = unique(prod);
    M = length(uniqueProd);
    [~,prodID] = ismember(prod,uniqueProd);
    
    avgRating = zeros(length(rating),1);

    for i = 1:M
        index = find(prodID == i);
        s = rating(index);
        if(~isempty(s))
            avgRating(index,1) = sum(s)/length(s);
        end 
    end

    RD_reviews = abs(double(rating) - avgRating); % calculating rating deviation
end