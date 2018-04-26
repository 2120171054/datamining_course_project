%Author: Shebuti Rayana
% Feature Description: Thresholded rating deviation of reviews e_{ij},
% x_{DEV}(i) = 1, if |r_{ij} - avg(r(e))|/4 > beta1, 0 otherwise
% here, beta1 = 0.63 and it is learned by recursive minimum entropy partitioning

% A. Mukherjee, A. Kumar, B. Liu, J. Wang, M. Hsu, M. Castellanos, and R. Ghosh. 
% Spotting opinion spammers using behavioral footprints. In KDD, pages 632-640. ACM,2013.

% input:
%prod: product id
%rating: the rating given by the users to "prod" 

% output:
% DEV_reviews: Thresholded rating deviation of reviews


function DEV_reviews = DEV(prod, rating)
    RD_reviews = RD(prod, rating);
    beta1 = 0.63;
    
    DEV_reviews = zeros(length(rating),1);
    normRD = RD_reviews./4;
    DEV_reviews(normRD > beta1) = 1;
end