function overlap = overlapping(A, B)

% x y w h

A = [A(:,1) A(:,2) A(:,3)+A(:,1)-1 A(:,4)+A(:,2)-1];
B = [B(:,1) B(:,2) B(:,3)+B(:,1)-1 B(:,4)+B(:,2)-1];

n = size(A,1);
m = size(B,1);

intersection = rectint(A,B);
areaA = abs(A(:,3).*A(:,4));
areaB = abs(B(:,3).*B(:,4));

overlap= zeros(n,m);
for i = 1:n
    for j = 1:m
        % Union of bounding boxes:
        ua = (areaA(i)+areaB(j)-intersection(i,j));
        
        % PASCAL measure:
        overlap(i,j) = intersection(i,j) / ua;
    end
end

return

n = size(A,1);
m = size(B,1);
overlap= zeros(n,m);

for i = 1:n
    Ai = A(i,:);
    areaA = (Ai(3)-Ai(1)+1)*(Ai(4)-Ai(2)+1);
    for j = 1:m
        Bj = B(j,:);
        areaB = (Bj(3)-Bj(1)+1)*(Bj(4)-Bj(2)+1);
        
        intAB = [max(Ai(1),Bj(1)) ; max(Ai(2),Bj(2)) ; min(Ai(3),Bj(3)) ; min(Ai(4),Bj(4))];
        w = (intAB(3)-intAB(1)+1);
        h = (intAB(4)-intAB(2)+1);
        if min(w,h)<=0 
            areaAB = 0;
        else
            areaAB = w*h;
        end
        
        overlap(i,j) = areaAB / (areaA + areaB - areaAB);
        
        if areaA<0; pepe; end
        if areaB<0; pepe; end
    end
end