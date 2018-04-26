filename1='output_meta_yelpResData_NRYRcleaned.txt';
fid1=fopen(filename1);
C=textscan(fid1, '%s %s %s %s %s %d %d %d %f');
date=cellstr(datestr(datevec(C{1}),'yyyy-mm-dd'));
user_id=C{3};
prod_id=C{4};
label=C{5};
rating=C{9};
uuser_id=unique(user_id);
nuser_id=zeros(length(user_id),1);
for i=1:length(uuser_id)
    nuser_id(strcmp(user_id,uuser_id{i}))=i;
end
uprod_id=unique(prod_id);
nprod_id=zeros(length(prod_id),1);
for i=1:length(uprod_id)
    nprod_id(strcmp(prod_id,uprod_id{i}))=i;
end
fidw1=fopen('metadata','w');
label_id=zeros(length(label),1);
label_id(strcmp(label,'N'))=1;
label_id(strcmp(label,'Y'))=-1;
for i=1:length(nuser_id)
    fprintf(fidw1,'%d %d %f %d %s\n',nuser_id(i),nprod_id(i),rating(i),label_id(i),date{i});
end
fclose(fidw1);
fclose(fid1);
filename2='output_review_yelpResData_NRYRcleaned.txt';
Ct=importdata(filename2);
fidw2=fopen('reviewContent','w');
for i=1:length(Ct)
    fprintf(fidw2,'%d %d %s %s\n',nuser_id(i),nprod_id(i),date{i},Ct{i});
end
fclose(fidw2);

fidw3=fopen('review_id','w');
for i=1:61541
    fprintf(fidw3,'%d\n',i);
end
fclose(fidw3);