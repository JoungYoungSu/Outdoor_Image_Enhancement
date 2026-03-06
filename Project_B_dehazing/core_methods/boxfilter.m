%   BOXFILTER   O(1) time box filtering: 박스 안 모든 화소들 다 더하기 함수
%   imDst(x, y)=sum(sum(grayimage(x-r:x+r,y-r:y+r))); 와 동일
%   하지만, 마스크가 안되는 영역도 정의하였음.

function imDst = boxfilter(grayimage, r)

[hei, wid] = size(grayimage);
imDst = zeros(size(grayimage));

%I(세로)축 다 더하기 
imCum = cumsum(grayimage, 1); %누적합 계산 함수(1이면 세로축, 2면 가로축): 예, A=1:5, CUMSUM(A)=1,3,6,10,15
%빼기/더하기로 마스크 내 Y세로축 값들 구하기
imDst(1:r+1, :) = imCum(1+r:2*r+1, :);%검은색일 수 있는 전체 영상의 j열(세로축 결과)
imDst(r+2:hei-r, :) = imCum(2*r+2:hei, :) - imCum(1:hei-2*r-1, :);%검은색이 존재하지 않는 j열:중복 빼기
imDst(hei-r+1:hei, :) = repmat(imCum(hei, :), [r, 1]) - imCum(hei-2*r:hei-r-1, :);%각 위치-r(위)만이 남게(r+1)위치 빼기

%cumulative sum over X axis
imCum = cumsum(imDst, 2); %앞에서 이미 구한 i열들을 합을 가로로 더해서 다 합함
imDst(:, 1:r+1) = imCum(:, 1+r:2*r+1);
imDst(:, r+2:wid-r) = imCum(:, 2*r+2:wid) - imCum(:, 1:wid-2*r-1);%중복값들을 빼주기
imDst(:, wid-r+1:wid) = repmat(imCum(:, wid), [1, r]) - imCum(:, wid-2*r:wid-r-1);%마지막 줄도 중복 빼기

end