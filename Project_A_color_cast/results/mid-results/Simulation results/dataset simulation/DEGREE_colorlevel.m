%화이트 밸런스 밀도 정하기

STR4='D:\대학원\안개영상\PF\test\컬러캐스트\데이터세트\'; % A파일 경로
STR5='D:\대학원\안개영상\PF\test\컬러캐스트\데이터세트\'; % A파일 경로
%filenames     = {'balloons' };%개개인인 경우
STR3='일반'; 
%numFiles = size(filenames, 2); 
E_atm=zeros(61,1);

for fileIndex =1:79%numFiles
%STR2 = char(filenames(fileIndex)); %개개인 경우
STR2=int2str(fileIndex); %연속적인 경우
inB=strcat(STR4,STR3,'\',STR3,' (',STR2,')','.tiff'); %잡음 B 
i = imread(inB);
im = double(i)/255;
[x,y,z]=size(im);
if z==1, im(:,:,2)=im(:,:,1);im(:,:,3)=im(:,:,1);end
    
%-------------1. RGB 영상에서 대기광 추정------------------------
Area=im;n=1;
%imshow(Area);

while(n<=9)&&(nnz(Area)/3>100)
stand1(1,n)=std(Area(:),'omitnan');
[Ah, Aw, ~]=size(Area);

if rem(Ah,2)==1, Area(Ah+1,:,:)=NaN;[Ah, Aw, ~]=size(Area);end
if rem(Aw,2)==1, Area(:,Aw+1,:)=NaN;[Ah, Aw, ~]=size(Area);end

A1=Area(1:Ah/2,1:Aw/2,:);
A2=Area(Ah/2+1:end,1:Aw/2,:);
A3=Area(1:Ah/2,Aw/2+1:end,:);
A4=Area(Ah/2+1:end,Aw/2+1:end,:);

A=zeros((Ah/2)*(Aw/2),3);
A(:,:,1)=reshape(A1, (Ah/2)*(Aw/2), 3);
A(:,:,2)=reshape(A2, (Ah/2)*(Aw/2), 3);
A(:,:,3)=reshape(A3, (Ah/2)*(Aw/2), 3);
A(:,:,4)=reshape(A4, (Ah/2)*(Aw/2), 3);

for int=1:4
h=A(:,:,int);hl=h(:);
score(int,:)=abs(mean(hl,'omitnan')-std(hl,'omitnan')); %평균은 크고, 분산은 작아야함
end

%figure;imshow([A1 A3;A2 A4]);

c1{1}=A1;c1{2}=A2;c1{3}=A3;c1{4}=A4;
Area=c1{score==max(score)};
index(n,1)=find(score==max(score),1);

n=n+1;
end
[Ah, Aw, ~]=size(Area);
stand1(1,n)=std(Area(:),'omitnan');
pass=stand1(1,3);

%-----------2. LAB 색공간 변환 & 화이트 밸런스------------------------
cform=makecform('srgb2lab');
LAB=applycform(i, cform); %1. 전체 영상
LAB = double(LAB)/255;
a = LAB(:,:,2)-0.5;
b = LAB(:,:,3)-0.5;

ALAB=applycform(uint8(Area.*255), cform);
ALAB = double(ALAB)/255;
ALAB(:,:,2) =ALAB(:,:,2)-0.5;
ALAB(:,:,3) =ALAB(:,:,3)-0.5;

atm=reshape(ALAB,Ah* Aw,3); %Area의 대기광 L, A, B 모두 출력함
atm=sum(atm)/(Ah* Aw);
%E_atm(fileIndex,1)=abs(sqrt(sum(atm.^2))-sqrt(sum(atm(:,1).^2)));
E_atm(fileIndex,1)=sqrt(atm(:,2).^2+atm(:,3).^2);

if (E_atm(fileIndex,1)<0.04)&&(pass>=0.09)&&(E_atm(fileIndex,1)>0.02)
Cname=strcat(STR5,'no','\','no',' (',STR2,')','.tiff'); 
imwrite(i,sprintf('%s.tiff',Cname));
end %분산 높은 것 제외


if E_atm(fileIndex,1)>0.1, level=1;
     Cname=strcat(STR5,'1','\','1',' (',STR2,')','.tiff'); 
    imwrite(i,sprintf('%s.tiff',Cname));
elseif (E_atm(fileIndex,1)>=0.04)&&(E_atm(fileIndex,1)<0.1)
     Cname=strcat(STR5,'2','\','2',' (',STR2,')','.tiff'); 
    imwrite(i,sprintf('%s.tiff',Cname));
elseif (E_atm(fileIndex,1)>=0.02)&&(E_atm(fileIndex,1)<0.04)%0.7
    Cname=strcat(STR5,'3','\','3',' (',STR2,')','.tiff'); 
    imwrite(i,sprintf('%s.tiff',Cname));
elseif (E_atm(fileIndex,1)<0.02)
    Cname=strcat(STR5,'4','\','4',' (',STR2,')','.tiff'); 
    imwrite(i,sprintf('%s.tiff',Cname));
end

end

figure, plot(1:numel(E_atm), E_atm(1:numel(E_atm),1),'.r'),hold on
xlim([1 numel(E_atm)]); %ylim([0 0.16]);
plot(1:numel(E_atm), 0.1.*ones(1,numel(E_atm)),'--k'), hold on
plot(1:numel(E_atm), 0.1.*ones(1,numel(E_atm)),'--k'), hold off
title('Chroma of colorcast image');
xlabel('Dataset');
ylabel('chroma');

Cname=strcat(STR5, 'random'); % 추출할 사진명 
saveas(gcf,sprintf('%s.tiff',Cname));% 사진 추출

E_atm2=sort(E_atm);
figure, plot(1:numel(E_atm2), E_atm2(1:numel(E_atm2),1),'.r'),hold on
xlim([1 numel(E_atm2)]); %ylim([0 0.16]);
plot(1:numel(E_atm2), 0.1.*ones(1,numel(E_atm2)),'--k'), hold off
title('Chroma of colorcast image');
xlabel('Dataset');
ylabel('chroma');
       
Cname=strcat(STR5, 'sort'); % 추출할 사진명 
saveas(gcf,sprintf('%s.tiff',Cname));% 사진 추출


