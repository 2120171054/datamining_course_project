%Author: Shebuti Rayana
%Feature Description: Is singleton? If review is users sole review then 1
%otherwise 0

%input:
%user: user ID

%output:
%ISR_reviews: is singleton?

function ISR_reviews = ISR(user)
    uniqueUser = unique(user);
    N = length(uniqueUser);
    [~,userID] = ismember(user,uniqueUser);
    ISR_reviews = zeros(length(user),1);

    for i = 1:N
        index = find(userID == i);
        if(length(index) == 1)
            ISR_reviews(index,1) = 1;
        end
    end
end