load('total_feature.mat');
[nt,~]=size(total_feature);
perm=randperm(nt);
total_feature_perm = total_feature(perm,:);
total_feature_perm(:,12:14)=[];
true_data=total_feature_perm;
false_data=total_feature_perm;
true_data(total_feature_perm(:,end)==0,:)=[];
false_data(total_feature_perm(:,end)==1,:)=[];
[false_size,~]=size(false_data);
train_size=floor(false_size*0.7);
test_szie=floor(false_size*0.7);
raw_train_data=[true_data(1:train_size,:);false_data(1:train_size,:)];
test_data=[true_data(train_size+1:train_size+2443,:);false_data(train_size+1:end,:)];

perm2=randperm(train_size*2);
train_data = raw_train_data(perm2,:);
 
input_train_data=train_data(:,1:end-1);
input_train_label=train_data(:,end);
prediction_data=test_data(:,1:end-1);
prediction_label=test_data(:,end);

nb=NaiveBayes.fit(input_train_data,input_train_label);

predict_label1=predict(nb,prediction_data);

training_accuracy1=length(find(predict_label1==prediction_label))/length(prediction_label);
fprintf('nb:accurace=%f\n',training_accuracy1);
option=statset('MaxIter',100000);
svmModel=svmtrain(input_train_data,input_train_label,'kernel_function','linear', 'options' ,option,'tolkkt',0.01);
predict_label2=svmclassify(svmModel,prediction_data);
training_accuracy2=length(find(predict_label2==prediction_label))/length(prediction_label);
fprintf('svm:accurace=%f\n',training_accuracy2);

tt=sum(predict_label2+prediction_label==2);
tf=sum(predict_label2==0);
ft=sum(prediction_label==0);
p=tt/tf;
r=tt/ft;
f1=2*p*r/(p+r);
fprintf('nb:precision=%f,recll=%f,f1scores=%f\n',p,r,f1);
tt=sum(predict_label1+prediction_label==2);
tf=sum(predict_label1==0);
ft=sum(prediction_label==0);
p=tt/tf;
r=tt/ft;
f1=2*p*r/(p+r);
fprintf('nb:precision=%f,recll=%f,f1scores=%f\n',p,r,f1);
