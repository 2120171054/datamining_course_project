%Author: Shebuti Rayana
%Feature Description: Rank order of a review in all the reviews of a product

%input
%prod: product ID
%date: the date a review has been written for "prod" 
%dateFormat: format of the date (e.g. dd-mmm-yyyy)

%output
%rank: rank order of a review in all the reviews of a product

function rank = Rank(prod,date,dateFormat)
    uniqueDate = unique(date);
    [Y,M,D] = datevec(uniqueDate, dateFormat); %this date format might be different for different datasets
    temp = [Y,M,D,zeros(length(Y),1),zeros(length(Y),1),zeros(length(Y),1)];
    tempDate = sortrows(temp,[1 2 3]);
    uniqueDate = cellstr(datestr(tempDate, dateFormat));
    D = length(uniqueDate);
    [~,dateID] = ismember(date,uniqueDate);
    
    uniqueProd = unique(prod);
    M = length(uniqueProd);
    [~,prodID] = ismember(prod,uniqueProd);
    
    % rank of review among all reviews on the same product
    rank = zeros(length(prod),1);

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
            rank(index,1) = r;
        else
            r = 1;
            rank(index,1) = r;
        end 
    end

end