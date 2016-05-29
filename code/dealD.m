function dealD(all,str)

name{1}='mxPH';
name{2}='mnO2';
name{3}='Cl';
name{4}='NO3';
name{5}='NH4';
name{6}='oPO4';
name{7}='PO4';
name{8}='Chla';
name{9}='a1';
name{10}='a2';
name{11}='a3';
name{12}='a4';
name{13}='a5';
name{14}='a6';
name{15}='a7';

for i=1:length(all)
    for j=4:18
        sh(i,j-3) = str2double(all{i,j});
    end
end

%  绘制直方图，如mxPH，用qq图检验其分布是否为正态分布。
for i=1:15
  fig=figure();
  hist(sh(:,i));   
  xlabel(name{i});
  ylabel('Value');
  saveas(fig,['./figure/hist_',name{i},'.jpg']);
  fig= figure();
  qqplot(sh(:,i));
  xlabel(name{i});
  ylabel('Value');
  saveas(fig,['./figure/qq_',name{i},'.jpg']);
end

%  绘制盒图，对离群值进行识别
for i=1:15
   fig= figure();
    boxplot(sh(:,1));
    ylabel(name{i})
    saveas(fig,['./figure/box_',name{i},'.jpg']);
end

name1{1}='Season';
name1{2}='River Size';
name1{3}='River Speed';

for i=1:3
    ta=tabulate(all(:,i));
    for  k=1:7 
        fig=figure();
        for j=1:length(ta)
            aa=ta{j,1};
            alll=find(strcmp(all(:,i),aa));
            if j==1
                allla(1,:)=sh(alll,k+8)';
                n(1,1)=length(sh(alll,k+8));
            else
                allla=[allla, sh(alll,k+8)'];
                n(1,j)=length(sh(alll,k+8));
            end
        end
        for j=1:length(ta)
            if j==1
                G=zeros(1,n(1,1));
                str=[name1{i},'    0:',ta{j,1},'; '];
            else
                G=[G zeros(1,n(1,j))+j-1];
                str=[str,num2str(j-1),':',ta{j,1},'; '];
            end
        end
         boxplot(allla,G);     
         xlabel(str);
         ylabel(name{k+8});
         saveas(fig,['./figure/box_',name{k+8},'_',name1{i},'.jpg']);
         clear allla;
    end
end
    

    
end