%Author: Shebuti Rayana

% for speed up run the individual feature extraction code parallely

%output
%userFeatures : each column is a user feature
%prodFeatures: each column is a product feature
%reviewFeatures: each column is a review feature
%adjlist: adjacency list of the review network
%label: label of the reviews (if exist)
    file1='metadata';
    file2='reviewContent';
% function [userFeatures, prodFeatures, reviewFeatures, adjlist, label] = featureExtraction(file1, file2)
    fid = fopen(file1);
    C = textscan(fid, '%s %s %s %s %s');
    %review_id = C{1};
    user_id = C{1};
    prod_id = C{2};
    rating = str2double(C{3});
    label = str2double(C{4});
    date = cellstr(datestr(datevec(C{5}),'dd-mmm-yyyy'));
    clear C;
    fclose(fid);
    
    dateFormat = 'dd-mmm-yyyy';
    fid=fopen('review_id');
    C_review_id=textscan(fid,'%s');
    review_id=C_review_id{1};
    fclose(fid);
    % adjacency list of the review network
    [~,userID] = ismember(user_id,unique(user_id));
    [~,prodID] = ismember(prod_id,unique(prod_id));
    adjlist = [userID,prodID,rating];
    
    userFeatures = [];
    prodFeatures = [];
    reviewFeatures = [];
    %% user and product features
    
    % MNR feature for both user and product
    [MNR_user,MNR_prod] = MNR(user_id, prod_id, date, dateFormat);
    userFeatures = [userFeatures,double(MNR_user)];
    prodFeatures = [prodFeatures,double(MNR_prod)];
    disp('MNR')
    
    % PR feature for both user and product
    [PR_user,PR_prod] = PR(user_id,prod_id,rating);
    userFeatures = [userFeatures,double(PR_user)];
    prodFeatures = [prodFeatures,double(PR_prod)];
    disp('PR')

    % NR feature for both user and product
    [NR_user,NR_prod] = NR(user_id,prod_id,rating);
    userFeatures = [userFeatures,double(NR_user)];
    prodFeatures = [prodFeatures,double(NR_prod)];
    disp('NR')
    
    % avgRD feature for both user and product
    [avgRD_user,avgRD_prod] = avgRD(user_id, prod_id, rating);  
    userFeatures = [userFeatures,double(avgRD_user)];
    prodFeatures = [prodFeatures,double(avgRD_prod)];
    disp('RD')
    
    % WRD feature for both user and product
    [WRD_user,WRD_prod] = WRD(user_id, prod_id, rating, date, dateFormat);
    userFeatures = [userFeatures,double(WRD_user)];
    prodFeatures = [prodFeatures,double(WRD_prod)];
    disp('WRD')

    % ERD feature for both user and product
    [ERD_user,ERD_prod] = ERD(user_id, prod_id, rating);
    userFeatures = [userFeatures,double(ERD_user)];
    prodFeatures = [prodFeatures,double(ERD_prod)];
    disp('ERD')

    % BST feature for user 
    BST_user = BST(user_id, date, dateFormat);
    userFeatures = [userFeatures,double(BST_user)];
    disp('BST')

    % ETG feature for both user and product
%     [ETG_user, ETG_prod] = ETG(user_id, prod_id, date, dateFormat);
%     userFeatures = [userFeatures,double(ETG_user)];
%     prodFeatures = [prodFeatures,double(ETG_prod)];
    
    % RL feature for both user and product
    
    % calling python script WordCount_reviews.py for counting words in
    % review text and save in output_wordcount.txt (change the python path according to your settings)
    % here, emoticons.txt is a dictionary of emoticons
    if ~exist('output_wordcount.txt')
        !C:\Python27\python.exe WordCount_reviews.py file2 output_wordcount.txt
    end
    filename = 'output_wordcount.txt';
    fid = fopen(filename);
    C = textscan(fid, '%s %s','Delimiter', ' ');
    wordcount = str2double(C{2});
    clear C;
    fclose(fid);

    [RL_user,RL_prod] = RL(user_id,prod_id,wordcount);
    userFeatures = [userFeatures,double(RL_user)];
    prodFeatures = [prodFeatures,double(RL_prod)];
     disp('RL')
   
    % extract bigrams from reviews
    % run bigram.py
    % suggestion: run the python codes separately
    if ~exist('output_biGram.txt')
        !C:\Python27\python.exe biGram.py file2 output_biGram.txt
    end
    % calculate TFIDF of reviews for bigrams
    [TFIDF,binaryBG,uniqueRID] = TFIDF_biGram(review_id,'output_biGram.txt');
    
    save('TFIDF','TFIDF','-v7.3');
    
    % ACS and MCS features for users
    [ACS_user, MCS_user] = ACS_MCS_user(user_id,TFIDF);
    userFeatures = [userFeatures,double(ACS_user)];
    userFeatures = [userFeatures,double(MCS_user)];
    disp('ACS')
    
    % ACS and MCS features for products
    [ACS_prod, MCS_prod] = ACS_MCS_prod(prod_id,TFIDF);
    prodFeatures = [prodFeatures,double(ACS_prod)];
    prodFeatures = [prodFeatures,double(MCS_prod)];
    disp('MCS')

    
    %% review features
    %  Rank feature for reviews
    rank = Rank(prod_id,date, dateFormat);
    reviewFeatures = [reviewFeatures,double(rank)];
    disp('Rank')

    
    % RD feature for reviews
    RD_reviews = RD(prod_id, rating);
    reviewFeatures = [reviewFeatures,double(RD_reviews)];
    disp('RD')

    % EXT feature for reviews
    EXT_reviews = EXT(rating);
    reviewFeatures = [reviewFeatures,double(EXT_reviews)];
    disp('EXT')
    
    % DEV feature for reviews
    DEV_reviews = DEV(prod_id, rating);
    reviewFeatures = [reviewFeatures,double(DEV_reviews)];
    disp('DEV')
    
    % ETF feature for reviews
    ETF_reviews = ETF(user_id, prod_id, date , dateFormat);
    reviewFeatures = [reviewFeatures,double(ETF_reviews)];
    disp('ETF')

    % ISR feature for reviews
    ISR_reviews = ISR(user_id);
    reviewFeatures = [reviewFeatures,double(ISR_reviews)];
    disp('ISR')

    % review text feature extraction
    
    % PCW feature for reviews
    if ~exist('output_AllCapital.csv')
     !C:\Python27\python.exe allCapitalCount.py file2 output_AllCapital.csv
    end
    filename = 'output_AllCapital.csv';
    fid = fopen(filename);
    C = textscan(fid, '%s %f', 'Delimiter', ',');
    PCW_reviews = C{2};
    clear C;
    fclose(fid);
    
    reviewFeatures = [reviewFeatures,double(PCW_reviews)];
    disp('PCW')
    
    % PC feature for reviews
    if ~exist('output_PC.csv')
        !C:\Python27\python.exe countCapital.py file2 output_PC.csv
    end
    filename = 'output_PC.csv';
    fid = fopen(filename);
    C = textscan(fid, '%s %f', 'Delimiter', ',');
    PC_reviews = C{2};
    clear C;
    fclose(fid);
    reviewFeatures = [reviewFeatures,double(PC_reviews)];
    disp('PC')

    % L feature for reviews
    
    L_reviews = wordcount./max(wordcount);
    
    reviewFeatures = [reviewFeatures,double(L_reviews)];
    disp('L')
    
    % PP1 feature for reviews
    if ~exist('output_PP1.csv')
        !C:\Python27\python.exe ratioPPwordCount.py file2 output_PP1.csv
    end
    filename = 'output_PP1.csv';
    fid = fopen(filename);
    C = textscan(fid, '%s %f %f', 'Delimiter', ',');
    PP1_reviews = C{2};
    clear C;
    fclose(fid);
    
    reviewFeatures = [reviewFeatures,double(PP1_reviews)];
    disp('PP1')
    
    % RES feature for reviews
    if ~exist('output_RES.csv')
        !C:\Python27\python.exe excSentenceCount.py file2 output_RES.csv
    end
    filename = 'output_RES.csv';
    fid = fopen(filename);
    C = textscan(fid, '%s %f', 'Delimiter', ',');
    RES_reviews = C{2};
    clear C;
    fclose(fid);
    
    reviewFeatures = [reviewFeatures,double(RES_reviews)];
    disp('RES')
    
    % SW and OW features for reviews
%     if ~exist('output_SW+OW.csv')
%         !C:\Python27\python.exe sentimentAnalysis.py file2 output_SW+OW.csv
%     end
%     filename = 'output_SW+OW.csv';
%     fid = fopen(filename);
%     C = textscan(fid, '%s %f %f', 'Delimiter', ',');
%     SW_reviews = C{3};
%     OW_reviews = C{2};
%     clear C;
%     fclose(fid);
%     
%     reviewFeatures = [reviewFeatures,double(SW_reviews),double(OW_reviews)];
%     
    % F feature for reviews
    r = 20;
    b = 50;
    candidategroups = jac_doc_hash(binaryBG,r,b); % LSH
    
    F_reviews = zeros(length(review_id),1);

    for i = 1:length(review_id)
        [loca,locb] = ismember(review_id(i),uniqueRID);
        if(loca)
            F_reviews(i) = sum(candidategroups == candidategroups(locb));
        else
            F_reviews(i) = 1;
        end
    end

    reviewFeatures = [reviewFeatures,double(F_reviews)];
     disp('F2')

    % DL_u and DL_b features
    if ~exist('output_uniGram.txt')
        !C:\Python27\python.exe uniGram.py file2 output_uniGram.txt
    end
    if ~exist('output_DL_u.csv ')
        !C:\Python27\python.exe codeTable.py output_uniGram.txt output_DL_u.csv dict_uniGram.csv
    end
    DL_u = zeros(length(review_id),1);
    filename = 'output_DL_u.csv';
    fid = fopen(filename);
    C = textscan(fid, '%s %f','Delimiter', ',');
    temp = C{2};
    [loc,ind] = ismember(review_id,C{1});
    ind(ind == 0) = [];
    DL_u(loc == 1) = temp(ind);
    clear C;
    fclose(fid);
    
    reviewFeatures = [reviewFeatures,double(DL_u)];
    disp('DLu')
    
    if ~exist('output_DL_b.csv')
        !C:\Python27\python.exe codeTable.py output_biGram.txt output_DL_b.csv dict_biGram.csv
    end
    DL_b = zeros(length(review_id),1);
    filename = 'output_DL_b.csv';
    fid = fopen(filename);
    C = textscan(fid, '%s %f','Delimiter', ',');
    temp = C{2};
    [loc,ind] = ismember(review_id,C{1});
    ind(ind == 0) = [];
    DL_b(loc == 1) = temp(ind);
    clear C;
    fclose(fid);
    
    reviewFeatures = [reviewFeatures,double(DL_b)];
    disp('DLb')

% end
save('reviewFeatures.mat','reviewFeatures');
save('userFeatures.mat','userFeatures');
save('prodFeatures.mat','prodFeatures');
save('adjlist.mat','adjlist');
save('label.mat','label');


[num,w1]=size(reviewFeatures);
[~,w2]=size(userFeatures);
[~,w3]=size(prodFeatures);
total_feature=zeros(num,w1+w2+w3+1);
total_feature(:,1:w1)=reviewFeatures;
savelabel=label;
savelabel(savelabel==-1)=0;
total_feature(:,end)=savelabel;
user_index=adjlist(:,1);
prod_index=adjlist(:,2);
for i=1:length(label)
    total_feature(i,w1+1:w1+w2)=userFeatures(user_index(i),:);
    total_feature(i,w1+w2+1:w1+w2+w3)=prodFeatures(prod_index(i),:);
end
save('total_feature.mat','total_feature');

%normalization
total_normalized_data=normalize(total_feature,1);

[nt,~]=size(total_normalized_data);
perm=randperm(nt);
total_feature_perm = total_normalized_data(perm,:);
true_data=total_feature_perm;
false_data=total_feature_perm;
true_data(total_feature_perm(:,end)==0,:)=[];
false_data(total_feature_perm(:,end)==1,:)=[];

raw_train_data=true_data(1:floor(nt/2),:);
test_data=[true_data(floor(nt/2)+1:end,:);false_data];

dlmwrite('train.txt',raw_train_data,'precision','%f','delimiter','\t');
dlmwrite('test.txt',test_data,'precision','%f','delimiter','\t');