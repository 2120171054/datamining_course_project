%Author: Shebuti Rayana
%Feature Description: normalized maximum number of reviews written in a day (normMNR) for both
%user and product

%Input:
%user: user ID
%prod: product ID
%date: the date "user" writes a review for "prod" 
%dateFormat: format of the date (e.g. dd-mmm-yyyy)

%output
%normMNR_user: normalized maximum number of reviews written in a day for
%users

%normMNR_prod: normalized maximum number of reviews written in a day for
%products 

function [normMNR_user, normMNR_prod] = MNR(user,prod,date,dateFormat)
    uniqueDate = unique(date);
    [Y,M,D] = datevec(uniqueDate, dateFormat); 
    temp = [Y,M,D,zeros(length(Y),1),zeros(length(Y),1),zeros(length(Y),1)];
    tempDate = sortrows(temp,[1 2 3]);
    uniqueDate = cellstr(datestr(tempDate, dateFormat));
    D = length(uniqueDate);
    
    uniqueUser = unique(user);
    uniqueProd = unique(prod);
    
    N = length(uniqueUser);
    P = length(uniqueProd);
    [~,userID] = ismember(user,uniqueUser);
    [~,prodID] = ismember(prod,uniqueProd);
    [~,dateID] = ismember(date,uniqueDate);
    
    %user
    Mat = sparse(dateID,userID,1,D,N);
    MNR = full(max(Mat,[],1));
    M = max(MNR);
    normMNR_user = MNR./M; % normalized MNR
    normMNR_user = normMNR_user';

    %product
    Mat = sparse(dateID,prodID,1,D,P);
    MNR = full(max(Mat,[],1));
    M = max(MNR);
    normMNR_prod = MNR./M; % normalized MNR
    normMNR_prod = normMNR_prod';
end