%에어라이트 영역 잡음 확인
%전체 비교: 4(21), 4(27), 4(29), 
%제안하는+잡음: 4(41)

clear all;

STR5='D:\대학원\안개영상\PF\졸업\'; % A파일 경로
STR4='D:\대학원\안개영상\원본\'; % A파일 경로
%STR4='D:\대학원\잡음영상\영상처리 사진2\'; % A파일 경로
%STR4='D:\대학원\안개영상\원본\'; % A파일 경로
%STR5='D:\대학원\졸업\과정\'; % A파일 경로
%filenames     = {'aerial8'};%개개인인 경우
STR3='total'; 
%numFiles = size(filenames, 2); 

for fileIndex =1:444
%STR2 = char(filenames(fileIndex)); %개개인 경우
STR2=int2str(fileIndex); %연속적인 경우
inB=strcat(STR4,STR3,'\','일반 (',STR2,')','.tiff'); %잡음 B 

tic
i = imread(inB);
im = double(i)/255;
[x,y,z]=size(im);
if z==1, im(:,:,2)=im(:,:,1);im(:,:,3)=im(:,:,1);end

%-------------1. RGB 영상에서 대기광 추정------------------------
Area=im;n=1;
%imshow(Area);

while(n<=9)&&(nnz(Area)/3>100)    
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

%saveName=strcat(STR5,int2str(n),'_',STR2); 
%imwrite(Area,sprintf('%s.tiff',saveName));

n=n+1;

end
[Ah, Aw, ~]=size(Area);
stand1(1,n)=std(Area(:),'omitnan');
npass=stand1(1,3);

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
E_atm=sqrt(atm(:,2).^2+atm(:,3).^2);%채도 측정방법:E
if (E_atm<0.04)&&(npass>=0.09), E_atm=0;end %분산 높은 것 제외

if E_atm>0.1, level=1;
elseif (E_atm>=0.04)&&(E_atm<0.1),level=0.8;
elseif (E_atm>=0.02)&&(E_atm<0.04),level=0.6;
else level=0;
end

a = a-level*atm(:,2); %화이트 밸런스
b = b-level*atm(:,3);

%-----------------------3. 투과율 T 추정--------------------------

a1=-0.0391; a2=0.9180; a3=-1.8072;%파라미터 추정 결과
D=a1+a2.*LAB(:,:,1)+a3.*sqrt(a.^2+b.^2);
refineD =JYS_fastguidedfilter_color(im, D, 7, 10^-3, 7/4); 

t = exp(-1*refineD);

[th, tw] = size(t);
for ti=1:x
    for tj=1:y
        if t(ti,tj)<0.05, t(ti,tj)=0.05;
        elseif t(ti,tj)>1, t(ti,tj)=1;     
        end
    end
end

%--------------------------4. 디헤이징-------------------------------
J = zeros(x, y);LAB2=zeros(x, y);
J = LAB(:,:,1)-atm(1);
J = J./t;
J = J+atm(1);

%-----------변수-------------
sigma=10; %imgaussfilt의 kernel
scalefactor=20;
s1 = 0.01; s2 = 0.99; % lower/upper percentage cutoff: 5~95%
%-----------------------------

%1)R1=R1: J의 RETINEX 결과 2) R1=I 결과: RETINEX와 J의 혼합 3) R1=J 결과: J의 RETINEX와 J의 혼합(가시성 보존)
J_ave=sum(sum(J))/numel(J);

if J_ave>0.6, R1=double(J);
else %0.2.*double(J)+0.8.*R1; 예시: 도시; 200(가중), 배 14(어둠)

L=J; %1. im: 원 영상의 RETINEX/ J: 출력 영상의 RETINEX
L = double(L*255+ 1) ; %8bit 변환 후 log 계산을 위해 1을 더함.

ret_I=L;reR=zeros(x,y);ret=zeros(x,y);

% 멀티스케일 레티닉스: 1~n까지 ret값을 모두 더하고 평균; 단일과 달리 회차마다 정규화scalefactor가 붙음
for n = 1:3
    if n == 1 %1은 본인 자신 & 평균할 필요 X
        reR = imgaussfilt(L, sigma); %조명 성분
        ret = (log(ret_I) - log(reR))./3; % 출력: 로그 계산후, 가중치 w=1/nscale=1/3;
    else
        if rem(x,4)~=0, reR(x+rem(x,4),:)=0;end
        if rem(y,4)~=0, reR(:,y+rem(y,4))=0;end
        reR = imresize(imgaussfilt(imresize(ret_I, 1/(scalefactor^(n - 1))), sigma), scalefactor^(n - 1));
        reR=reR(1:x,1:y);
        ret = 0.5.*(ret + (log(ret_I) - log(reR))./3); %평균
    end
end
    
ret = real(ret);
ret = exp(ret) - 1; %exp 계산하고, 1 빼기.

% [0 1] 범위로 만들기
ret = (ret - min(ret(:)))./(max(ret(:)) - min(ret(:)));

% 범위 제한: s1이하는 s1, s2이상은 s2로 
[count, bins] = imhist(ret, 256); 
cumhist = cumsum(count)./numel(ret(:));% cumsum: A의 누적합을 반환: 몇 %인지 확인 가능, 같은 크기 행렬

if isempty(find(cumhist < s1, 1, 'last')) && ~isempty(find(cumhist > s2, 1, 'first')) %95%이상인 것만 존재한다
    xr = [0, bins(find(cumhist > s2, 1, 'first'))];
elseif ~isempty(find(cumhist < s1, 1, 'last')) && isempty(find(cumhist > s2, 1, 'first'))%5%이하인 것만 존재한다
    xr = [bins(find(cumhist < s1, 1, 'last')), 255];
elseif isempty(find(cumhist < s1, 1, 'last')) && isempty(find(cumhist > s2, 1, 'first'))%둘 다 비었다
    xr = [0, 255];
else
    xr = bins([find(cumhist < s1, 1, 'last'), find(cumhist > s2, 1, 'first')]);
end
ret(ret < xr(1)) = xr(1); %5%보다 작으면 5%
ret(ret > xr(2)) = xr(2); %95%보다 크면 95%

ret = 255.*(ret - min(ret(:)))./max(ret(:));% 다시 원래 bit로 돌리기(0~255)

R1=mat2gray(ret);

if J_ave<0.35,R1=0.2.*double(J)+0.8.*R1;
else R1=0.6.*double(J)+0.4.*R1; %0.5(밝기 증가)~0.7(자연스럽)이 적당  
end
end


LAB(:,:,2)=a+0.5; %원래 컬러 캐스트 결과보기
LAB(:,:,3)=b+0.5;
LAB=uint8(LAB.*255);
cform_lab2srgb = makecform('lab2srgb');
rgb = applycform(LAB, cform_lab2srgb);

dehazing=zeros(x,y,z);
dehazing(:,:,1)=J;
dehazing(:,:,2)=a+0.5;  
dehazing(:,:,3)=b+0.5;
dehazing=uint8(dehazing.*255);
R_BEFORE = applycform(dehazing, cform_lab2srgb);

%dehazing=zeros(x,y,z);
%dehazing(:,:,1)=mat2gray(ret);
%dehazing(:,:,2)=a+0.5; %밝기 상승으로 인한 채도 저하 방지: 데이터 세트로 평가
%dehazing(:,:,3)=b+0.5;
%dehazing=uint8(dehazing.*255);
%result1 = applycform(dehazing, cform_lab2srgb);

dehazing=zeros(x,y,z);
dehazing(:,:,1)=R1;
dehazing(:,:,2)=a+0.5; %밝기 상승으로 인한 채도 저하 방지: 데이터 세트로 평가
dehazing(:,:,3)=b+0.5;
dehazing=uint8(dehazing.*255);
result = applycform(dehazing, cform_lab2srgb);

%figure; imshow([i, rgb, R_BEFORE, result]);

%-------------5. 디헤이징 이후 표준편차 계산------------------------
C = double(result)/255;

if z==1, C(:,:,2)=C (:,:,1);C (:,:,3)=C (:,:,1);end
n=1;Area2=C;

while(n<=nnz(index(:,1))) 
stand2(1,n)=std(Area2(:),'omitnan');

[Ah, Aw, ~]=size(Area2);

if rem(Ah,2)==1, Area2(Ah+1,:,:)=NaN;[Ah, Aw, ~]=size(Area2);end
if rem(Aw,2)==1, Area2(:,Aw+1,:)=NaN;[Ah, Aw, ~]=size(Area2);end

A1=Area2(1:Ah/2,1:Aw/2,:);
A2=Area2(Ah/2+1:end,1:Aw/2,:);
A3=Area2(1:Ah/2,Aw/2+1:end,:);
A4=Area2(Ah/2+1:end,Aw/2+1:end,:);

%figure;imshow([A1 A3;A2 A4]);

c2{1}=A1;c2{2}=A2;c2{3}=A3;c2{4}=A4;
Area2=c2{index(n,1)};

n=n+1;
end
[Ah, Aw, ~]=size(Area2);
stand2(1,n)=std(Area2(:),'omitnan');

TH=stand2(1,n)-stand1(1,n);
pass=stand2(1,3);

%--------------표준편차 기반 잡음 제거 알고리즘------------------------
Output_filter=C;    
F=zeros(size(C));
position_filter=C; 
   if pass<0.09 %분산이 0.1 미만인 경우 하늘 영역 존재 : 0.1 이상은 하늘 영역 X%-> 색차가 크면 화이트 밸런스..? 
   N=1;
    
    for channel=1:z
      for i=1+N:x-N 
      for j=1+N:y-N  
          Result=0;%초기화
          
          % 1-1. 잡음 밀도 가중치 부여
           M=C(i-N:i+N,j-N:j+N,channel); 
           M2=im(i-N:i+N,j-N:j+N,channel); 

           if std(M2(:))<0.01

              if TH<=0.03, k=1.5;
              elseif (TH>0.03)&&(TH<=0.06),k=0.8;
              else N=1; k=0; %-->수정
              end %N크기 설정
           
           change=M(:);M_line=sort(change); 
           average=sum(change)/numel(change);
           minus=(change-average);Sig=sqrt(sum(sum(minus.^2))/numel(M));
           median=change((numel(change)+1)/2);
           
           %1-3. 오차범위를 통한 잡음 판단
           T1=k*Sig;%임계값

           if (M(N+1,N+1)>average-T1)&&(M(N+1,N+1)<average+T1),F=1;       %오차치 안에 존재
           else  F=2; %중앙 화소가 로컬 영역의 범위를 벗어남-> 제외 후 덜 잡음요소로 대체
           end
           
           %2. F에 따른 잡음제거
           if F==1
              Result=M(N+1,N+1);
           else
              for p=1:2*N+1
              for q=1:2*N+1
              W1(p,q)=exp(-0.05*(((p-(N+1))^2+(q-(N+1))^2))/sqrt(average+T1));
              F1_plus(p,q)=M(p,q)*W1(p,q);
              end
              end
              Result=sum(F1_plus(:))/sum(W1(:));   
              Result=Result+(Result-average)*(Sig-average)/average;
              position_filter(i,j,1)= 1; %위치 띄우기!!
              position_filter(i,j,2)= 1;
           end
           
           Output_filter(i,j,channel)= Result;
           end  
      end
      end
    end
   end

   %figure; imshow([im.*255, rgb, R_BEFORE, result, Output_filter.*255]);  
   %figure; imshow([result, Output_filter.*255]);  

   %saveName=strcat(STR5,'결과\',STR3,'\',STR2); 
   %imwrite(Output_filter,sprintf('%s.tiff',saveName));
   
   %saveName=strcat(STR5,STR2,'\','rgb'); 
   %imwrite(rgb,sprintf('%s.tiff',saveName));
   %saveName=strcat(STR5,STR2,'\','R_BEFORE',STR2); 
   %imwrite(R_BEFORE,sprintf('%s.tiff',saveName));
   %saveName=strcat(STR5,STR2,'\','result',STR2); 
   %imwrite(result,sprintf('%s.tiff',saveName));
   %saveName=strcat(STR5,STR2,'\','Output_filter',STR2); 
   %imwrite(Output_filter,sprintf('%s.tiff',saveName));
   T(fileIndex)=toc;

end
T_ave=sum(T)/fileIndex;

%I1=rgb2gray(im);I2=rgb2gray(C);I3=rgb2gray(Output_filter);
%edge1 = edge(I1,'Canny');edge2 = edge(I2,'Canny');edge3 = edge(I3,'Canny');
%edge1=23*JYS_edge(I1);edge2=2*JYS_edge(I2);edge3=2*JYS_edge(I3);
%figure,imshow([I1 I2 I3;  edge1 edge2 edge3]);
   
%figure,imshow([im C Output_filter])

