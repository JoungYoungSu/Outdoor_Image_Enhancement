% 단일 영상 레티닉스(SSR: Single-scale retinex) 이용 
% 1~n까지 ret값을 모두 더하고 평균. 단일과 달리 회차마다 정규화scalefactor가 붙음

function  R = ssr_retinex(ret_I)

%-----------변수-------------
sigma=10; %imgaussfilt의 kernel
scalefactor=20;
s1 = 0.01; s2 = 0.99; % lower/upper percentage cutoff: 5~95%
%-----------------------------

[x,y] = size(ret_I);
reR = zeros(x,y);
ret=zeros(x,y);

for n = 1:3
    if n == 1 %1은 본인 자신 & 평균할 필요 X
        reR = imgaussfilt(ret_I, sigma); %조명 성분
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

R=mat2gray(ret);