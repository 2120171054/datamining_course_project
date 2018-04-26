function  candidategroups = jac_doc_hash( A, r, b )
% Compute minimum hash, hash columns into buckets. 
%   A: binary (!) data matrix, rows: shingles (n of them), columns: docs/reviews (m of them)
% r,b LSH parameters
% candidategroups: output vector of size m, where documents with the same group id are in the same cluster (i.e. ith high probability, their similarity is above your threshold dictated by the specific choice of r,b)

[n,m] = size(A);
s=r*b;

% signature matrix S (s signatures per document)
S = zeros(s,m);


% generate permutations one by one
M = zeros(s,n);
for i=1:s
    M(i,:) = randperm(n);    
end

%generate signatures
for i=1:m % iterate over documents
    if(sum(A(:,i)>0)>0) %document has non-zero shingles
        S(:,i) = min(M(:,(A(:,i)>0)),[],2);    
    end
end

clear M;
clear A;

% generate hash tables
% S matrix dimensions: (r*b) x m


maps = cell(b,1); % holds b "hashtables"

for j = 1:b
    from = 1 + r*(j-1);
    to = from + (r-1);

    c=containers.Map; % c's are the buckets
    
    % hash all columns to hash-table j
    for i = 1:m   
        t = S(from:to,i)';   
        t = num2str(t);  
        
        if(isKey(c,t))
            c(t) = [c(t) i];
        else
            c(t) = i;
        end
    end
    
    maps{j} = c;
    
end % end of hashing "sub-"signatures 

clear S;



% now find out union of documents that map to the same bucket in "at least one" (!) hash table

candidategroups = 1:m; % every document in its own individual group

% process hash-tables 1 by 1
for i=1:b
    c = maps{i};
    k=c.keys; % k contains the list of keys of buckets, one key per bucket
    for j=1:length(k) %iterates over buckets of hash table i
       candidategroups(c(k{j})) = min(candidategroups(c(k{j})));  % c(k{j}) contains all document id's in bucket with key k{j}
    end
end

ucg=unique(candidategroups);

% ucg contains the unique group ids, length of ucg is the number of (document) clusters
num_clusters = length(ucg)



end












