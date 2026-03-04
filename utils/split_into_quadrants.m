% 입력 영상의 쿼드 트리 영역(Area) 분할
function c = split_into_quadrants(Area)

[Ah, Aw, ~]=size(Area); 
    
% 홀수인 경우 사이즈 증가
if rem(Ah,2)==1
    Area(Ah+1,:,:)=NaN;
end
if rem(Aw,2)==1 
    Area(:,Aw+1,:)=NaN;
end

[Ah, Aw, ~]=size(Area);

% 쿼드 트리 영역(Area) 분할
A1 = Area(1:Ah/2,1:Aw/2,:);
A2 = Area(1:Ah/2,Aw/2+1:end,:);
A3 = Area(Ah/2+1:end,1:Aw/2,:);
A4 = Area(Ah/2+1:end,Aw/2+1:end,:);

% 셀에 분할한 영역 입력
c = {A1, A2, A3, A4};

end