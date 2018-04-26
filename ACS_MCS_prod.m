%Author:Shebuti Rayana
%Feature Description: Average content similarity (ACS) and Maximum content similarity (MCS) - 
%pairwise cosine similarity of product's reviews where reviews are presented as bag of bigrams

%input:
%prod: product ID
%TFIDF: TFIDF of all reviews for all bigrams


%output:
%ACS_prod: Average content similarity (ACS) of products
%MCS_prod: Maximum content similarity (MCS) of products


function [ACS_prod, MCS_prod] = ACS_MCS_prod(prod,TFIDF)
    uniqueProd = unique(prod);
    N = length(uniqueProd);
    [~,prodID] = ismember(prod,uniqueProd);
    
%     % calculating TFIDF
%     uniqueShingles = unique(Shingles);
%     [~,sID] = ismember(Shingles,uniqueShingles);
%     uniqueRID = unique(reviewID);
%     [~,rID] = ismember(reviewID,uniqueRID);
% 
%     % bigram by review matrix
%     freqMat = sparse(double(sID),double(rID),1,double(length(uniqueShingles)),double(length(uniqueRID)));
%     
%     %some reviews have one word for which no bigram is generated to balance
%     %this issue put all zero columns for those reviews
%     if(length(rev_id) > length(uniqueRID))
%         temp = sprase(length(uniqueShingles),length(rev_id));
%         [loc,ind] = ismember(rev_id,uniqueRID);
%         ind(ind == 0) = [];
%         temp(:,loc == 1) = freqMat(:,ind);
%         freqMat = temp;
%     end
%     
%     %freq of reviews containing the bigram
%     freqDoc = sum(freqMat~=0,2);
%     IDF = log2(length(rev_id)./freqDoc);
% 
%     TFIDF = bsxfun(@times,freqMat,IDF);
    
    ACS_prod = -1 * ones(N,1);
    MCS_prod = -1 * ones(N,1);

    for i = 1:N
        index = find(prodID == i);
        if(length(index) > 1)
            T = TFIDF(:,index);  
            P = 1:size(T,2);
            pairs = nchoosek(P,2);
            Sim = zeros(size(T,2),1);
            for j = 1:size(pairs,1)
               x = T(:,pairs(j,1));
               y = T(:,pairs(j,2));
               if(dot(x,y) == 0)
                   Sim(j,1) = 0;
               else
                   Sim(j,1) = dot(x,y)/(norm(x,2)*norm(y,2));
               end
            end
            ACS_prod(i,1) = sum(Sim)/length(Sim);
            MCS_prod(i,1) = max(Sim);
        end
    end
end