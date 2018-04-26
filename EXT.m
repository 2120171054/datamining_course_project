%Author: Shebuti Rayana
% Feature Description: Extrimity of rating, EXT_review = 1 for rating
% {1,5*}, 0 otherwise {2,3,4*}

% input:
% rating: rating of all reviews (1-5*)

% output:
% EXT_review: Extrimity of rating for reviews


function EXT_review = EXT(rating)
    EXT_review = zeros(length(rating),1);
    EXT_review((rating == 5) | (rating == 1)) = 1;
end