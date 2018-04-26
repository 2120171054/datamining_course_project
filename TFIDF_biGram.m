%Author: Shebuti Rayana

% calculating TFIDF of reviews using bigrams

function [TFIDF,binaryBG,uniqueRID] = TFIDF_biGram(review_id,bigram_file)
    fid = fopen(bigram_file);
    C = textscan(fid, '%s %s','Delimiter', ' ');
    reviewID = C{1};
    Shingles = C{2};
    clear C;
    fclose(fid);

    uniqueShingles = unique(Shingles);
    [~,sID] = ismember(Shingles,uniqueShingles);
    uniqueRID = unique(reviewID);
    [~,rID] = ismember(reviewID,uniqueRID);
    N = length(review_id);

    %freq of a bigram in a review
    freqMat = sparse(double(sID),double(rID),1,double(length(uniqueShingles)),double(length(uniqueRID)));

    %some reviews have one word for which no bigram is generated to balance
    %this issue put all zero columns for those reviews
    if(length(review_id) > length(uniqueRID))
        temp = sparse(double(length(uniqueShingles)),double(length(review_id)));
        [loc,ind] = ismember(review_id,uniqueRID);
        ind(ind == 0) = [];
        temp(:,loc == 1) = freqMat(:,ind);
        freqMat = temp;
    end

    binaryBG = freqMat;
    binaryBG(binaryBG>1) = 1;

    %freq of documents containing the bigram
    freqDoc = sum(freqMat~=0,2);
    IDF = log2(N./freqDoc);

    TFIDF = bsxfun(@times,freqMat,IDF);
end