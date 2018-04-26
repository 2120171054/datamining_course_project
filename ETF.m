%Author: Shebuti Rayana
% Feature Description: Early Time Frame (ETF). Spammers often review to
% increase impact.
% f(i) = 0, if T(i) - F(i) > delta, 1 - ((T(i) - F(i))/delta), otherwise
% ETF(i) = 1, if f(i) > beta2 and 0 otherwise
% here, delta = 7 months and beta2 = 0.69 estimated by recursive minimal entropy
% partitioning

% A. Mukherjee, A. Kumar, B. Liu, J. Wang, M. Hsu, M. Castellanos, and R. Ghosh. 
% Spotting opinion spammers using behavioral footprints. In KDD, pages 632-640. ACM,2013.

% input:
%user: user ID
%prod: product ID
%date: the date "user" writes a review for "prod" 
%dateFormat: format of the date (e.g. dd-mmm-yyyy)

% output:
% ETF_reviews: Early time frame for each review

function ETF_reviews = ETF(user, prod, date , dateFormat)
    uniqueUser = unique(user);
    uniqueProd = unique(prod);
    N = length(uniqueUser);
    P = length(uniqueProd);
    [~,userID] = ismember(user,uniqueUser);
    [~,prodID] = ismember(prod,uniqueProd);
    
    HRMat = sparse(double(prodID),double(userID),1,double(P),double(N));
    [x, y] = find(HRMat > 0);
    
    firstReviewDate = [];
    for i = 1:P
        d = date(prodID == i);
        %sort dates
        [Y,M,D] = datevec(d, dateFormat);
        temp = [Y,M,D,zeros(length(Y),1),zeros(length(Y),1),zeros(length(Y),1)];
        tempDate = sortrows(temp,[1 2 3]);
        d = cellstr(datestr(tempDate,dateFormat));
        firstReviewDate = [firstReviewDate;d(1)];
    end

    delta = 7*30; % 7 motnhs in days
    beta2 = 0.69;
    
    F = zeros(length(prodID),1);

    for i = 1:length(x)
        ind1 = find(prodID == x(i));
        ind2 = find(userID == y(i));
        index = intersect(ind1,ind2);
        d = date(index);
        [Y,M,D] = datevec(d, dateFormat);
        temp = [Y,M,D,zeros(length(Y),1),zeros(length(Y),1),zeros(length(Y),1)];
        tempDate = sortrows(temp,[1 2 3]);
        d = cellstr(datestr(tempDate,dateFormat));  
        deltaD = datenum(datevec(d(length(d)))) - datenum(datevec(firstReviewDate(x(i))));
        if((deltaD <= delta))
            F(index,1) = 1 - (deltaD/delta);
        end
    end

    ETF_reviews = zeros(length(prodID),1);
    ETF_reviews(F > beta2) = 1; 
end