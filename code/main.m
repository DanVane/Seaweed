close all;
clear variables;
clc;
warning off; %#ok<WNOFF>

%data=textscan(fid,'%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s');
%fclose(fid);

[season,size,speed,mxPH,mnO2,Cl,NO3,NH4,oPO4,PO4,Chla,a1,a2,a3,a4,a5,a6,a7] = textread('./Analysis.txt','%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s');

bia = cell(1,1);
biao = [season ,size,speed];
shu = [mxPH,mnO2,Cl,NO3,NH4,oPO4,PO4,Chla,a1,a2,a3,a4,a5,a6,a7];
all =[biao,shu];

freSeason=tabulate(all(:,1));
freSize=tabulate(all(:,2));
freSpeed=tabulate(all(:,3));

info{1,1}='Info';
info{2,1}='mxPH';
info{3,1}='mnO2';
info{4,1}='Cl';
info{5,1}='NO3';
info{6,1}='NH4';
info{7,1}='oPO4';
info{8,1}='PO4';
info{9,1}='Chla';
info{10,1}='a1';
info{11,1}='a2';
info{12,1}='a3';
info{13,1}='a4';
info{14,1}='a5';
info{15,1}='a6';
info{16,1}='a7';
info{1,2}='min';
info{1,3}='q1';
info{1,4}='median';
info{1,5}='mean';
info{1,6}='q3';
info{1,7}='max';
info{1,8}='NA';

%给出最大、最小、均值、中位数、四分位数及缺失值的个数。
[ii,j]= find(strcmp(all, 'XXXXXXX'));
for i=1:15
    s= find(j==(i+3));
    s=ii(s,:);
    que=length(s);
    for k=1:length(all)
        sss{k,1}=all{k,i+3};
    end
    sss(s,:)=[];
    for t=1:length(sss)
        sh(t,1)=str2double(sss{t,1});
    end
    maxsh=max(sh);
    minsh=min(sh);
    meansh = mean(sh);
    mediansh=median(sh);
    q1sh=prctile(sh,25);
    q3sh=prctile(sh,75);
    info{i+1,2}=minsh;
    info{i+1,3}=q1sh;
    info{i+1,4}=mediansh;
    info{i+1,5}=meansh;
    info{i+1,6}=q3sh;
    info{i+1,7}=maxsh;
    info{i+1,8}=que;
end

%    将缺失部分剔除
sho = zeros(1,18);
[i,j]= find(strcmp(all, 'XXXXXXX'));
A=[i,j];
d=[i];
tab = tabulate(A(:,2));
n=length(tab);
tab= int8(tab(:,1:2));
for i = 1:n
    sho(1,tab(i,1))= tab(i,2);
end
all1 =all;  %原始数据集
nm=all(d,:);  %存在缺失数据的数据集
all1(d,:)=[];   %已删除缺失数据后的数据集

%    用最高频率值来填补缺失值
dim=numel(all)/length(all);
freout=cell(dim,1);
for ic = 1:dim%列数
    for ir = 1:length(all)%行数
        temp(ir) = length(find(strcmp(all(:,ic),all(ir,ic))));
    end
    [~, id] = max(temp,[],1);
    freout(ic) = all(id(1,1),ic);
end
all2 = all;

for ir = 1:length(A)
    position =A(ir,:);
    all2{position(1),position(2)}=freout(position(2),1);    %用最高频率值填补缺失值后的数据集
end


%    通过属性的相关关系来填补缺失值
for ir=1:length(all1)
    for ic=1:15
        shu1(ir,ic)=str2num(all1{ir,ic+3});
    end
end

relationship=corrcoef(shu1);
[~,index]=sort(relationship,2);
index=index(:,14);

for ir=1:length(index)
    c1=shu1(:,ir);
    c2=shu1(:,index(ir));
    c2=[ones(length(c2),1),c2];
    [b,~,~,~,~]=regress(c1,c2);
    pra{ir}=b;
end

all3=all;
for ir = 1:length(A)
    position =A(ir,:);
    all3{position(1),position(2)}=num2str(pra{1,position(2)-3}(1,1)+pra{1,position(2)-3}(2,1)*str2num(all3{position(1),index(position(2)-3)+4}));    %用属性相关关系填补缺失值后的数据集
end

%    通过数据对象之间的相似性来填补缺失值
all4 = all;
idd=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18];
tab=tabulate(A(:,1));
tab= int16(tab(:,1:2));
for ir=1:length(tab)
    num=tab(ir,2);
    if num==0
        continue;
    end
    id=find(A(:,1)==ir);
    id=A(id,2);
    id=id-3;
    value = shu(ir,:);
    for i=1:length(id)
        value{:,id(i)}='0.00000';
    end
    shu2 = shu1;
    shu2(:,id) = 0;
    for ic=1:length(value)
        va(ir,ic)=str2num(value{1,ic});
    end
    dist =pdist2(shu2,va);
    [~,in] = sort(dist);
    in=in(1:10,1);
    all4{position(1),position(2)}=num2str(mean(shu1(in,position(2)-3)));
end

save('./OmitedData.mat','all1');
save('./FreData.mat','all2');
save('./LinearData.mat','all3');
save('./ObjectData.mat','all4');

dealD(all1,'将缺失部分剔除');
dealD(all2,'用最高频率值来填补缺失值');
dealD(all3,'通过属性的相关关系来填补缺失值');
dealD(all4,'  通过数据对象之间的相似性来填补缺失值');
