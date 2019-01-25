%Count the number of houses or people inside the given contours.
%
% Created by: Ramon van Schaik
% Created for: Schiphol Group A/CAP/EC
% Date: 2010  Last update: 2010
% File name: contourtel.m
%
% Input:
% - z: een grid serie grids, waarbij de eerste twee dimensies griddimensies
% zijn en de derde dimensie het jaar is.
% - cw: een serie contourwaardes, waarbij de laatste als catch-all contour
% wordt ingesteld en alles daarboven er ook bij hoort.
% - output: een gecategoriseerd woningen- en geluidsbestand (verkregen via
% de m-file indexdata).
% - N: een lijst per netwerkvierkant hoeveel inwoners 't heeft (verkregen
% via indexdata).
% - Nentries: een lijst per netwerkvierkant hoeveel entries 't heeft, om de
% samenstelling van de lijst met woningen/personen op de rand te versnellen
% (verkregen via indexdata).
%LET OP: N, Nentries en Noutput kunnen verkregen worden uit de bestanden
%woningen.mat en personen.mat
%
% Output:
% - alltelgehinderden: het aantal woningen of personen binnen een
% contourvorm. Indien er meerdere grids opgegeven zijn geeft hij een array
% per grid, waardoor het totaal dus tweedimensionaal wordt.
% - errorflag: true when some of the contours are open

function [alltelgehinderden,errorflag] = contourtel(z,cw,output,N,Nentries)

%% Booting
alltelgehinderden = zeros(size(z,3),length(cw));



for year = 1:size(z,3) %in geval van meteodata wordt er over verschillende matrix 
    %% verfijn
    telgehinderden = [zeros(1,length(cw))];
    zf = verfijn(flipud(z(:,:,year)),4); %flipud omdat de matrix dan direct rechtgezet wordt
    %% eigen contourbepaling
    %nog niet gereed, zet contouren nog niet op juiste volgorde
    %cont; 

    %% matlabs contourbepaling
    if length(cw)==1
        C = contourc(zf,[cw cw]);
    else
        C = contourc(zf,[cw]);
    end
    C=C';
    matc = [];

    einde=false;
    nc=0;
    beginc = [];

    %de volgende loop maakt van de lijst die contourc geeft een lijst in een
    %ander format, namelijk een nx2 matrix met alle punten, een array beginc
    %met de beginnen van de eilandjes en een punt nc die bijhoudt hoeveel
    %eilandjes er zijn

    while einde==false
        nc = nc+1; %weer een eilandje meer
        if nc==1
            beginc = [1 C(1,1)];
        else
            beginc = [beginc; [beginc(nc-1)+n  C(1,1)]]; %lengtes n-2 contouren + lengte n-1 contour + 1
        end
        n = C(1,2); %deze nu pas updaten!
        matc = [matc;C(2:n+1,:)];
        if size(C,1)==n+1
            einde=true;
        else
            C = C(n+2:end,:);
        end
    end

    for contindex = 1:length(cw)
        if contindex < length(cw) 
            nclocal = find(beginc(:,2)-cw(contindex),1)-1;
        else
            nclocal = length(beginc);
        end
    end
    
    %Dit stuk gebruiken om de contouren te plotten. Vergeet niet hold
    %on aan te zetten
%     
%     for contindex = 1:length(cw)    
%         for i=1:1%nclocal
%             if ((i<nclocal) || (contindex < length(cw))) %is het niet het laatste contoureiland van de laatste contour?
%                 %plotten eiland
%                 plot(125*matc(beginc(i):beginc(i+1)-1,1),125*matc(beginc(i):beginc(i+1)-1,2),'k.');
%     
%             else  %is het wel het laatste contoureiland van de laatste contour?
%                 plot(matc(beginc(i):end,1),matc(beginc(i):end,2),'k.');
%             end
%         end
%     end
    
    
    %nog even omzetten van gridcoordinaten naar coordinaten van het RDstelsel
    
    matc(:,2) = 125*(matc(:,2)-1) + 455000; %ycoordinaat
    matc(:,1) = 125*(matc(:,1)-1) + 84000; %xcoordinaat
    
    
    %% per contourwaarde de volgende loop
    for contindex = 1:length(cw)   
        %% indelen in vakjes
        if contindex ~= length(cw)
            goed = (cw(contindex)<=zf) & (zf<cw(contindex+1)); %goed als een netwerkvierkant geteld dient te worden
        else
            goed = cw(contindex)<=zf; %dito
        end
        onder = zf<cw(contindex); %onder als een netwerkvierkant er compleet onder ligt
        semiboven = zf>cw(contindex); %semiboven als een netwerkvierkant boven de gehele contourwaarde ligt
        if contindex ~= length(cw)
            boven = zf>cw(contindex+1); %boven als het netwerkvierkant geheel boven de contourband ligt
        end
        %kijken of alle vier de hoekpunten op of  onder het contourniveau zitten.
        %Als boven, dan nemen we deze mee om uit de matrix N te lezen hoeveel
        %mensen er wonen. Als onder, dan kunnen we deze punten compleet vergeten.
        %Als geen van beide dan loopt er een contourlijn door het vierkantje en
        %moet het alsnog handmatig gecontroleerd worden.
        goed = goed(1:end-1,1:end-1) & goed(1:end-1,2:end) & goed(2:end,1:end-1) & goed(2:end,2:end);
        onder = onder(1:end-1,1:end-1) & onder(1:end-1,2:end) & onder(2:end,1:end-1) & onder(2:end,2:end);

        if contindex ~= length(cw)
            boven = boven(1:end-1,1:end-1) & boven(1:end-1,2:end) & boven(2:end,1:end-1) & boven(2:end,2:end);
        end
        semiboven = semiboven(1:end-1,1:end-1) & semiboven(1:end-1,2:end) & semiboven(2:end,1:end-1) & semiboven(2:end,2:end);
        tussen = (onder==false & semiboven==false);
        if contindex~=length(cw) 
            goed = (boven==false & onder==false & tussen==false); %De vector goed moet ook de vierkantjes omvatten die de grens vormen tussen contour contindex en contour contindex+1. Het teveelgetelde wordt in de volgende stap er afgetrokken.
        end

        %% bestand samenstellen voor inpoly
        %hier worden de woningen/personen die in een vakje met een contourlijn
        %vielen in een lijst gezet, zodat die zometeen geprocessed kan worden door
        %inpoly.
        tussenhinder = zeros(sum(Nentries(tussen)),3);
        nindex = 1;
        for i=1:size(N,1)
            for j=1:size(N,2)
                if (tussen(i,j) && Nentries(i,j)>0)
                    tussenhinder(nindex:nindex+Nentries(i,j)-1,:) = output{i}{j};
                    nindex = nindex + Nentries(i,j);
                end

            end
        end
        %% tellen
        %hier gebeurt het werkelijke tellen in twee delen.  Eerst worden de
        %vierkantjes geprocessed en daarna de punten die bij een tussenvierkantje
        %hoorde.
        telgehinderden(contindex) = sum(N(goed));

        binnen = zeros(size(tussenhinder,1),1);

        %afscannen contourindices
        if contindex < length(cw) 
            nclocal = find(beginc(:,2)-cw(contindex),1)-1;
        else
            nclocal = size(beginc,1);
        end

        for i=1:nclocal
            if ((i<nclocal) || (contindex < length(cw))) %is het niet het laatste contoureiland van de laatste contour?
                binnen = binnen + 1*inpoly(tussenhinder(:,2:3),[matc(beginc(i,1):beginc(i+1,1)-1,1) matc(beginc(i,1):beginc(i+1,1)-1,2)]);
            else  %is het wel het laatste contoureiland van de laatste contour?
                binnen = binnen + 1*inpoly(tussenhinder(:,2:3),[matc(beginc(i,1):end,1) matc(beginc(i,1):end,2)]);

            end
        end

        %verwijder gebruikte contouren
        beginc = beginc(nclocal+1:end,:);    


        %dit is even tricky om te begrijpen. Is binnen nul? Dan zit ie niet
        %in een eilandje. Is binnen 1? Dat zit ie in een eilandje. Is binnen
        % 2? Dan zit ie in een meertje op het eilandje (en dus onder het
        %contourniveau). M.a.w., alle odd (oneven) binnens mag je meetellen.
        binnen = mod(binnen,2)==1;

        %even terug naar de vorige contourwaarde. Hiervan moeten we nog het
        %teveelgetelde deel aftrekken
        if contindex>1
            telgehinderden(contindex-1) = telgehinderden(contindex-1) - tussenhinder(:,1)' * binnen;
        end

        %nu afhandeling binnen deze loop van telgehinderden huidige contourwaarde
        telgehinderden(contindex) = tussenhinder(:,1)' * binnen + telgehinderden(contindex); 

    end
    alltelgehinderden(year,:) = telgehinderden;
end


if max([max(z(:,end)) max(z(:,1)) max(z(1,:)) max(z(end,:))])>min(cw)
    errorflag = true;
else
    errorflag = false;
end

%% voor plotten twee contouren
%volgend script plot de contouren (matlab en NLR) en plot tevens de huizen
%die op het randje vallen.

%plot(matc(:,1),matc(:,2),'.b');
%scatter(tussenhinder(:,2),tussenhinder(:,3),'g');
