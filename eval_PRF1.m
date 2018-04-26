daegmmscores=load('scores.txt');
daegmmgt=load('gt.txt');
daegmmgt=1-daegmmgt;
daegmmgt(1:end-8141*2)=[];
daegmmscores(1:end-8141*2)=[];
daegmmscores=(daegmmscores-min(daegmmscores))/(max(daegmmscores)-min(daegmmscores));
daegmmscores(daegmmscores>0.4)=1;
daegmmscores(daegmmscores<=0.4)=0;

tt=sum(daegmmscores+daegmmgt==2);
tf=sum(daegmmscores==1);
ft=sum(daegmmgt==1);
p=tt/tf;
r=tt/ft;
f1=2*p*r/(p+r);
fprintf('DAEGMM:precision=%f,recll=%f,f1scores=%f\n',p,r,f1);
