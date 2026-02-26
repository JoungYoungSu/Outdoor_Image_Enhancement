%mean color

clear all;

STR1='D:\대학원\'; % A파일 경로
STR4='D:\대학원\'; % A파일 경로8
STR3='졸업\'; 
filenames     = {'(b)'};%개개인인 경우
numFiles = size(filenames, 2); 

for fileIndex =1:numFiles
STR2 = char(filenames(fileIndex)); %개개인 경우
%STR2=int2str(fileIndex); %연속적인 경우
inB=strcat(STR1,STR3,STR2,'.tiff'); %잡음 B 
im = imread(inB);
[height, width,~]=size(im);
imsize = width * height;

r=im(:,:,1);   
g=im(:,:,2); 
b=im(:,:,3); 

ys_hist=0:1:255;
hist_r=zeros(256,1);
hist_g=zeros(256,1);
hist_b=zeros(256,1);

for i=1:256
   hist_r(i)=sum(sum(r==ys_hist(i)));
   hist_g(i)=sum(sum(g==ys_hist(i)));
   hist_b(i)=sum(sum(b==ys_hist(i)));
end

figure
stem(ys_hist,hist_r,'r','Marker','none');%stem: 축을 따라 줄기로 표현한다./none: 마커없음
hold on
stem(ys_hist,hist_g,'g','Marker','none');
stem(ys_hist,hist_b,'b','Marker','none');
AXIS_Y_MIN=min([min(hist_r) min(hist_g) min(hist_b)]);
AXIS_Y_MAX=max([max(hist_r) max(hist_g) max(hist_b)]);
axis([min(ys_hist) max(ys_hist) AXIS_Y_MIN AXIS_Y_MAX])

xlabel('8bit scale pixel value') 
ylabel('Number of pixels') 

legend('R chnnel','G chnnel','B chnnel')

%saveName=strcat(STR4,'histogram',STR2); % 추출할 사진명 
%saveas(gcf,sprintf('%s.tiff',saveName));% 사진 추출
end