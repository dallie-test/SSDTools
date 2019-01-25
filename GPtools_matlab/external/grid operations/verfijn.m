%verfijn increases the resolution of a certain grid.
%
% Created by: Ramon van Schaik
% Created for: Schiphol Group A/CAP/EC
% Date: 2010  Last update: 2010
% File name: verfijn.m
%
% Input:
% - input_grid: input grid. Inputgrid moet ook vierkant zijn voor dit
% algorithme. Moet in theorie niet, hiervoor kan het algorithme nog worden
% aangepast.
% - k: factor waarmee de resolutie verfijnd moet worden! 
%
% Output:
% - verfijn: grid with a higher resolution

function [ verfijn,A] = verfijn(input_grid,k)
%% begin met uitrekenen formule's op de pagina

% % ///  Hack, maak het grid vierkant
%     s = size(input_grid);
%     if s(2) - s(1) > 0
%         input_grid = [input_grid; zeros(s(2) - s(1), s(2))];
%     elseif s(1) - s(2) > 0
%         input_grid = [input_grid, zeros(s(1), s(1) - s(2))];  
%     end
% % \\\

%c werkt in xrichting
c = diff(input_grid,1,2);

%tbv eq A.2.10
c = [c 2*c(:,size(c,2))-c(:,size(c,2)-1)];
c = [c 2*c(:,size(c,2))-c(:,size(c,2)-1)];

%tbv eq A.2.9
c = [2*c(:,1)-c(:,2) c];
c = [2*c(:,1)-c(:,2) c];

%nu d in y richting
d = diff(input_grid);

%tbv eq A.2.13
d = [d;2*d(size(d,1),:)-d(size(d,1)-1,:)];
d = [d;2*d(size(d,1),:)-d(size(d,1)-1,:)];

%tbv eq A.2.12
d = [2*d(1,:)-d(2,:);d];
d = [2*d(1,:)-d(2,:);d];

wx = abs(diff(c,1,2));
wxd = (wx(:,3:size(wx,2))+wx(:,1:size(wx,2)-2));
wy = abs(diff(d));
wyd = (wy(3:size(wy,1),:)+wy(1:size(wy,1)-2,:));

%matlab heeft last van roundoff errors. Hopelijk is deze correctiein veel gevallen
%goed
wyd(abs(wyd)<0.1^10)=0;
wxd(abs(wxd)<0.1^10)=0;

fx = (wx(:,3:size(wx,2)).*c(:,2:size(c,2)-2)+wx(:,1:size(wx,2)-2).*c(:,3:size(c,2)-1))./wxd;
%vervolgens conditie toepassen dat noemer geen nul mag zijn
c1=c(:,2:size(c,2)-2);
c2=c(:,3:size(c,2)-1);
fx(wxd==0)=(c1(wxd==0)+c2(wxd==0))/2;

fy = (wy(3:size(wy,1),:).*d(2:size(d,1)-2,:)+wy(1:size(wy,1)-2,:).*d(3:size(d,1)-1,:))./wyd;
%ook hier conditie toepassen
d1 = d(2:size(d,1)-2,:);
d2 = d(3:size(d,1)-1,:);
fy(wyd==0)=(d1(wyd==0)+d2(wyd==0))/2;

%dubbele afgeleide, geconstrueerd uit d
e = diff(d,1,2);

%tbv eq A.2.16
e = [e 2*e(:,size(e,2))-e(:,size(e,2)-1)];
e = [e 2*e(:,size(e,2))-e(:,size(e,2)-1)];

%tbv eq A.2.17
e = [2*e(:,1)-e(:,2) e];
e = [2*e(:,1)-e(:,2) e];

%bovenste deel A.2.14
fxy = wx(:,3:size(wx,2)).*(wy(3:size(wy,1),:).*e(2:length(e)-2,2:length(e)-2)+wy(1:size(wy,1)-2,:).*e(3:length(e)-1,2:length(e)-2));
%onderste deel A.2.14
fxy = fxy + wx(:,1:size(wx,2)-2).*(wy(3:size(wy,1),:).*e(2:length(e)-2,3:length(e)-1)+wy(1:size(wy,1)-2,:).*e(3:length(e)-1,3:length(e)-1));
%breuk uit beide delen, en dan is de bitch bijna klaar
fxy = fxy./wxd./wyd;

%ook hier weer conditie toepassen
cond = (wxd==0) | (wyd==0);
e00 = e(2:length(e)-2,2:length(e)-2);
e01 = e(3:length(e)-1,2:length(e)-2);
e10 = e(2:length(e)-2,3:length(e)-1);
e11 = e(3:length(e)-1,3:length(e)-1);
fxy(cond)=(e00(cond)+e01(cond)+e10(cond)+e11(cond))/4;

%% nu zijn alle variabelen van A.2 uitgerekend

%matrix opstellen voor vegen
xpower = [0:3 0:3 0:3 0:3];
ypower = [zeros(1,4) ones(1,4) 2*ones(1,4) 3*ones(1,4)];

%voor derrivative naar x en y
xpowerx = [0 0:2 0 0:2 0 0:2 0 0:2];
ypowery = [zeros(1,4) zeros(1,4) ones(1,4) 2*ones(1,4)];
%scalar na derrivatives
scalx=xpower;
scaly=ypower;
scalxy = xpower.*ypower;

xy = [0 0
    0 1
    1 0
    1 1];

xy=xy;

xymat = ones(16);

%vergelijkingen onder (a)
xymat(1:4,:) = (xy(1:4,1)*ones(1,16)).^(ones(4,1)*xpower).*(xy(1:4,2)*ones(1,16)).^(ones(4,1)*ypower);
%vergelijkingen onder (b)
xymat(5:8,:) = (xy(1:4,1)*ones(1,16)).^(ones(4,1)*xpowerx).*(xy(1:4,2)*ones(1,16)).^(ones(4,1)*ypower).*(ones(4,1)*scalx);
%vergelijkingen onder (c)
xymat(9:12,:) = (xy(1:4,1)*ones(1,16)).^(ones(4,1)*xpower).*(xy(1:4,2)*ones(1,16)).^(ones(4,1)*ypowery).*(ones(4,1)*scaly);
%vergelijkingen onder (d)
xymat(13:16,:) = (xy(1:4,1)*ones(1,16)).^(ones(4,1)*xpowerx).*(xy(1:4,2)*ones(1,16)).^(ones(4,1)*ypowery).*(ones(4,1)*scalxy);

%% initialiseer A-matrix. 
%De A_ab verschilt per netwerkvierkant waar je
% inzit. Daarom is gekozen voor een matrix A waarbij een kolom
% correspondeert met een netwerkvierkant en een rij met een entry in A_ab
A = zeros(16,(size(input_grid,1)-1)*(size(input_grid,2)-1));

%enkele waarden kunnen al op voorhand worden bepaald
%f bepaalt a00, afsnijden omdat we de laatste kolom en rij niet nodig hebben
A(1,:) = reshape(input_grid(1:size(input_grid,1)-1,1:size(input_grid,2)-1)',1,(size(input_grid,1)-1)*(size(input_grid,2)-1))./xymat(1,1); %bepaald 1

%fx bepaalt a10
A(2,:) = reshape(fx(1:size(fx,1)-1,1:size(fx,2)-1)',1,(size(fx,1)-1)*(size(fx,2)-1))./xymat(5,2); %bepaald 2

%fy bepaalt a01
A(5,:) = reshape(fy(1:size(fy,1)-1,1:size(fy,2)-1)',1,(size(fy,1)-1)*(size(fy,2)-1))./xymat(9,5); %bepaald 5

%fxy bepaalt a11
A(6,:) = reshape(fxy(1:size(fxy,1)-1,1:size(fxy,2)-1)',1,(size(fxy,1)-1)*(size(fxy,2)-1))./xymat(13,6); %bepaald 6

%% voor a20 en a30 gebruiken we rij 2 en 6
%het zijn nu twee vergelijkingen met twee onbekenden, dus een soort van
%[a1 a2][x]=[z1]
%[b1 b2][y]=[z2]
%dit lossen we expliciet op. let op: f# staat voor het antwoord op rij
%behorende bij variabele #
f3 = reshape(input_grid(1:size(input_grid,1)-1,2:size(input_grid,2))',1,(size(input_grid,1)-1)*(size(input_grid,2)-1)) - xymat(3,:)*A; %antwoorden voor rij 3, var 3
f4 = reshape(fx(1:size(fx,1)-1,2:size(fx,2))',1,(size(fx,1)-1)*(size(fx,2)-1)) - xymat(7,:)*A; %antwoorden voor rij 7, var 4

a1 = xymat(3,3);
a2 = xymat(7,3);
b1 = xymat(3,4);
b2 = xymat(7,4);

A(3:4,:)= tsys(a1,a2,b1,b2,f3',f4');

%var 3 en 4 zijn nu ook bepaald
%op naar var 10 en 14 in rij 6 en 14
f10 = reshape(fx(2:size(fx,1),1:size(fx,2)-1)',1,(size(fx,1)-1)*(size(fx,2)-1)) - xymat(6,:)*A;
f14 = reshape(fxy(2:size(fxy,1),1:size(fxy,2)-1)',1,(size(fxy,1)-1)*(size(fxy,2)-1)) - xymat(14,:)*A;

a1 = xymat(6,10);
a2 = xymat(14,10);
b1 = xymat(6,14);
b2 = xymat(14,14);
A([10;14],:)= tsys(a1,a2,b1,b2,f10',f14');

%nu var 9 en 13 in rij 2 en 10
f9 = reshape(input_grid(2:size(input_grid,1),1:size(input_grid,2)-1)',1,(size(input_grid,1)-1)*(size(input_grid,2)-1)) - xymat(2,:)*A; %antwoorden voor rij 2, var 9
f13 = reshape(fy(2:size(fy,1),1:size(fy,2)-1)',1,(size(fy,1)-1)*(size(fy,2)-1)) - xymat(10,:)*A; %antwoorden voor rij 10, var 13

a1 = xymat(2,9);
a2 = xymat(10,9);
b1 = xymat(2,13);
b2 = xymat(10,13);
A([9;13],:)= tsys(a1,a2,b1,b2,f9',f13');

%tot slot van de enkele paartjes nog var 7 en 8 in rij 11 en 15
f7 = reshape(fy(1:size(fy,1)-1,2:size(fy,2))',1,(size(fy,1)-1)*(size(fy,2)-1)) - xymat(11,:)*A; 
f8 = reshape(fxy(1:size(fxy,1)-1,2:size(fxy,2))',1,(size(fxy,1)-1)*(size(fxy,2)-1)) - xymat(15,:)*A; 

a1 = xymat(11,7);
a2 = xymat(15,7);
b1 = xymat(11,8);
b2 = xymat(15,8);
A([7;8],:)= tsys(a1,a2,b1,b2,f7',f8');

%% alle paartjes van 2 nu uitgerekend
%nu beginnen we met de jetser van 4. We moeten hiervoor var 11, 12, 15 en 
%16 uitrekenen in rij 4, 8, 12 en 16
f11 = reshape(input_grid(2:size(input_grid,1),2:size(input_grid,2))',1,(size(input_grid,1)-1)*(size(input_grid,2)-1)) - xymat(4,:)*A; %antwoorden voor rij 4, var 11
f12 = reshape(fx(2:size(fx,1),2:size(fx,2))',1,(size(fx,1)-1)*(size(fx,2)-1)) - xymat(8,:)*A; %antwoorden voor rij 8, var 12
f15 = reshape(fy(2:size(fy,1),2:size(fy,2))',1,(size(fy,1)-1)*(size(fy,2)-1)) - xymat(12,:)*A; %antwoorden voor rij 12, var 15
f16 = reshape(fxy(2:size(fxy,1),2:size(fxy,2))',1,(size(fxy,1)-1)*(size(fxy,2)-1)) - xymat(16,:)*A; %antwoorden voor rij 16, var 16
a1 = xymat(4,11); b1=xymat(4,12); c1=xymat(4,15); d1=xymat(4,16);
a2 = xymat(8,11); b2=xymat(8,12); c2=xymat(8,15); d2=xymat(8,16);
a3 = xymat(12,11); b3=xymat(12,12); c3=xymat(12,15); d3=xymat(12,16);
a4 = xymat(16,11); b4=xymat(16,12); c4=xymat(16,15); d4=xymat(16,16);
Avier = [a1 b1 c1 d1
    a2 b2 c2 d2
    a3 b3 c3 d3
    a4 b4 c4 d4];
yvier = [f11 f12 f15 f16]';
AvierT = Avier';

% nu passen we cramer's rule toe. Dit wil zeggen dat xi = det(Ai)/det(A)
%waarbij det(Ai) de determinant is van de matrix A waarbij de i-de kolom is
%vervangen door antwoordenvector (of matrix in ons geval want we willen
%meerdere  gevallen in een keer behandelen). 

A(16,:) = -(f11*det(AvierT(1:3,2:4)) - f12*det(AvierT(1:3,[1;3;4])) + f15*det(AvierT(1:3,[1;2;4])) - f16*det(AvierT(1:3,[1;2;3])))/det(Avier); %Waarom de minus er aan het begin moet staan is tot op heden een raadsel.

%4e uitegrekend, nu op naar de derde. Hiervoor shiften we eerste de matrix.

Avier = [a1 b1 d1 c1
    a2 b2 d2 c2
    a3 b3 d3 c3
    a4 b4 d4 c4];
AvierT = Avier';

%de volgende regel is een kopie van A(16,:)=... want we hebben de matrix
%geshift dus we kunnen de operatie gewoon herhalen. Dit gaan we nog 2 keer
%doen
A(15,:) = -(f11*det(AvierT(1:3,2:4)) - f12*det(AvierT(1:3,[1;3;4])) + f15*det(AvierT(1:3,[1;2;4])) - f16*det(AvierT(1:3,[1;2;3])))/det(Avier); %Waarom de minus er aan het begin moet staan is tot op heden een raadsel.

%3e ding
Avier = [a1 d1 c1 b1
    a2 d2 c2 b2
    a3 d3 c3 b3
    a4 d4 c4 b4];
AvierT = Avier';
A(12,:) = -(f11*det(AvierT(1:3,2:4)) - f12*det(AvierT(1:3,[1;3;4])) + f15*det(AvierT(1:3,[1;2;4])) - f16*det(AvierT(1:3,[1;2;3])))/det(Avier); %Waarom de minus er aan het begin moet staan is tot op heden een raadsel.

%4e ding
Avier = [d1 b1 c1 a1
    d2 b2 c2 a2
    d3 b3 c3 a3
    d4 b4 c4 a4];
AvierT = Avier';
A(11,:) = -(f11*det(AvierT(1:3,2:4)) - f12*det(AvierT(1:3,[1;3;4])) + f15*det(AvierT(1:3,[1;2;4])) - f16*det(AvierT(1:3,[1;2;3])))/det(Avier); %Waarom de minus er aan het begin moet staan is tot op heden een raadsel.

%% alle vier de jetsers uitgerekend, matrix A is nu compleet

% i=1;
% j=1;
% zmat = [f(i,j) f(i+1,j) f(i,j+1) f(i+1,j+1) fx(i,j) fx(i+1,j) fx(i,j+1) fx(i+1,j+1) fy(i,j) fy(i+1,j) fy(i,j+1) fy(i+1,j+1) fxy(i,j) fxy(i+1,j) fxy(i,j+1) fxy(i+1,j+1)]';
% %deze loop is slechts ter verifercatie, bij voorkeur uitschakelen
% for i=1:(size(f,1)-1)
%     for j=1:(size(f,2)-1)
%         %welke antwoorden?
%         zmat = [f(i,j) f(i+1,j) f(i,j+1) f(i+1,j+1) fx(i,j) fx(i+1,j) fx(i,j+1) fx(i+1,j+1) fy(i,j) fy(i+1,j) fy(i,j+1) fy(i+1,j+1) fxy(i,j) fxy(i+1,j) fxy(i,j+1) fxy(i+1,j+1)]';
%         C = rref([xymat zmat],0.00000001);
%         if (i==1) && (j==1)
%             B = C(:,17);
%         else
%             B = [B C(:,17)];
%     end
% end

%welke gridwaarden gaat x en y na verfijning aannemen?
xts = [0:1/k:(1-1/k)]';
xts = [[ones(length(xts),1)] xts xts.^2 xts.^3];

%bigxy wordt van A.2.3 alle mogelijke combi's
bigxy = zeros(k^2,16);
for i=1:k
    for j=1:k
        bigxy(j+k*(i-1),:) = reshape(xts(i,:)'*xts(j,:),1,16);
    end
end

%% deze operatie verenigt A en bigxy, hierna nog reshapen voor volgorde
verfijn = bigxy*A;

verfijn = reshape(verfijn,k,k*size(verfijn,2));
verfijn = reshape(verfijn',(size(input_grid,1)-1)*k,(size(input_grid,2)-1)*k);

%% twee van de vier buitentste randen van z moeten nog extra gedaan worden
Ah = A(:,(length(input_grid)-2)*(length(input_grid)-1)+1:end);
Av = A(:,length(input_grid)-1:(length(input_grid)-1):end);

xtsy = repmat(1.^[0:3],4,1);

%bigxy wordt van A.2.3 alle mogelijke combi's
bigxy = zeros(k^2,16);
for i=1:k
    for j=1:k
        bigxy(j+k*(i-1),:) = reshape((ones(4,1)*xts(j,:))',1,16);
    end
end

bigxy = bigxy(1:k,:);

borderx = bigxy*Ah;
borderx = borderx(:);

%bigxy wordt van A.2.3 alle mogelijke combi's

Av = Av([1 5 9 13 2 6 10 14 3 7 11 15 4 8 12 16],:);

bordery = bigxy*Av;
bordery = bordery(:);

%% tot slot grid op volgorde zetten en randen toevoegen
allk = repmat(0:length(input_grid)-1:k*(length(input_grid)-1)-1,1,length(input_grid)-1);
addthis = repmat([1:length(input_grid)-1],k,1); addthis = reshape(addthis,1,numel(addthis));

verfijn = verfijn(:,allk+addthis);

verfijn = [verfijn borderx
      bordery' input_grid(end,end)]';

% % ///  Hack, maak het vierkant grid weer rechthoekig
%     verfijn = verfijn(1:1+(s(1)-1)*k, 1:1+(s(2)-1)*k);
% % \\\


end

function [ tsys ] = tsys(a1,a2,b1,b2,z1,z2)
%tsys solves multiple systems of the same A but with multiple answers z1
%and z2. These two can therefore be vectors

tsys = [(z2-b2*z1/b1)/(a2-b2*a1/b1) (a2*z1/a1-z2)/(a2*b1/a1-b2)]';

end