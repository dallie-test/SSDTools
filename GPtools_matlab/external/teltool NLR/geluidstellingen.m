function [O1 O2 O3 O4] = geluidstellingen(I1,I2,I3,I4,I5,I6)

%FUNCTIE:
%Voert, naar keuze, tellingen uit van woningen, personen, gehinderden en/of slaapverstoorden.
%Dit op basis van een opgegeven geluidbelastingsrekenresultaat , woningbestand
%en personenbestand en, indien gewenst, dosis-effectrelatie.
%
%Eigenschappen:
%- Contourgeneratie geschiedt conform berekingsvoorschrift van Lden en Lnight 
%  (NLR-CR-2001-372-PT-1 Appendix A, NLR, december 2001).
%- Geteld wordt op en binnen een contour.
%- Aandeel gehinderden of slaapverstoorden wordt uit de dosis-effectrelatie bepaald 
%  op basis van de gemiddelde contourwaarde tussen twee contouren.
%- Er vindt geen verificatie vooraf plaats van het bestaan van opgegeven invoerbestanden.
%
%
%AANROEP:
%[O1 O2 O3 O4] = geluidstellingen(I1,I2,I3,I4,I5,I6)
%
%
%INPUT:
%I1:	1-dimensionale (string)vector met geluidbelastingsbestand (directory en bestandsnaam)
%       (*.mat in geval van binary MAT-file of anders dan *.mat ingeval van ENVIRA-rekengrid). 
%*****	[DEZE FUNCTIONALITEIT IS NOG NIET OPGENOMEN; nu alleen envira. Bij *.mat zou eerst nog 
%       'result' tbv contourgenerator weggeschreven moeten worden.]
%
%       Voorbeeld: I1 = 'C:\Tellingen\result_Lden.dat';
%
%I2:	2-dimensionale vector met contourwaarden: [dB1 dB2 ..dBn] of [dB1:stap:dBn], default stap=1.
%
%       Voorbeeld: I2 = [49:65];
%
%I3:	2-dimensionale (cell)vector met woningbestand en personenbestand (directory & bestandsnaam)
%       (*.mat ingeval van binary MAT-file of anders dan *.mat ingeval van tekstbestand). 
%       Indien een bestand niet gebruikt wordt, hoeft geen bestaand bestand opgegeven te worden. 
%       Een woning- of personenbestand bevat 3 kolommen. De 1e kolom bevat het aantal woningen/personen en 
%       de twee volgende kolommen de bijbehorende x en y coordinaten.
%       Bij een tekstbestand dienen de kolommen gescheiden te zijn door een ":".
%
%       Voorbeeld: I3 = [cellstr('C:\Tellingen\woningbestand.txt'); cellstr('C:\Tellingen\personenbestand.txt')];
%
%I4:	vector [a1 a2 a3 a4], met waarde {0,1}.Igv ai=0 zijn geen tellingen gewenst; Igv. ai=1 
%       zijn wel tellingen gewenst. De indices 1 t/m 4 staan respectievelijk voor Lden woningen,
%       Lnight woningen, Lden ernstig gehinderden en Lnight slaapverstoorden.
%
%       Voorbeeld: I4 = [0 0 1 0]; voor alleen telling Lden ernstig gehinderden.
%
%I5:	optionele input: 2-dimensionale (cell)vector met respectievelijk
%       de dosis-effectrelatie voor ernstig gehinderden (Lden) en ernstig slaapverstoorden (Lnight). 
%
%       In de opgegeven dosis-effectrelatie dient het geluidbelastingsniveau met de variabele 
%       'mean_L' aangegeven te worden. De opgegeven dosiseffectrelatie moet een factor opleveren,
%       niet een percentage.
%
%       De default formule voor I5 is :
%       I5 = [cellstr('1-1./(1+exp(-8.1101+(0.1333.*mean_L)))');cellstr('1-1./(1+exp(-6.642+(0.1046*mean_L)))')]
%       Voor Lden is dit formule uit het GES-onderzoek 2002, geldig tussen 39 en 65 dB. Extrapolatie naar hogere 
%       of lagere geluidbelasting van de curve is mogelijk, maar wordt niet door de onderzoeksresultaten ondersteund.
%       Voor Lnight is dit formule uit het GES-onderzoek 2002, geldig tussen 29 en 57 dB. Extrapolatie naar hogere 
%       of lagere geluidbelasting van de curve is mogelijk, maar wordt niet door de onderzoeksresultaten ondersteund.
%
%       Voorbeeld: I5 = [cellstr('1-1./(1+exp(-8.1101+(0.1333.*mean_L)))');cellstr('1-1./(1+exp(-6.642+(0.1046*mean_L)))')]
%       Bijzonder geval: bij opgeven van ['1';'1'] zijn de resultaten het aantal personen i.p.v. 
%       het aantal gehinderden of slaapverstoorden
%
%I6:	optionele input: 1-dimensionale (string)vector met contourenbestand (directory en bestandsnaam)
%       waarin de contouren in een tape2-format wordt weggeschreven. 
%       Bij een leeg dataveld {[]} wordt geen bestand aangemaakt.
%       LET OP: als gebruik gemaakt wordt van input I6 dient ook I5 opgegeven te worden! 
%
%       Voorbeeld:% I6 = 'C:\Temp\Tellingen\Contouren_Lden.tape2';
%
%
%
%OUTPUT:
%De output bestaat uit:
%A) een 4-dimensionle vector, bestaande uit:
%O1:	Scalar met aantal woningen per contourschil, Lden
%O2:	Scalar met aantal woningen per contourschil, Lnight
%O3:	Scalar met aantal gehinderden per contourschil, Lden
%O4:	Scalar met aantal slaapverstoorden per contourschil, Lnight
%
%Voor O1 t/m O4: Scalar = 0 bij alle contourwaarden indien de betreffende telling
%niet was gevraagd bij invoer.
%
%B) (optioneel) tape2-tekstbestand met ligging van contouren (opmaak per regel: contourpuntindex X Y contourwaarde)
%
%
%VOORWAARDEN:
%Voorwaarden voor de juiste werking:
%- Zorg dat de bestanden 'contour.exe' en 'cygwin1.dll' staan in de directory waarin script staat.
%- Zorg dat de map waaruit dit script wordt gedraaid niet 'read-only' is, omdat matlab in deze map 
%  (tussen)resultaten weg moet kunnen schrijven. 
%- Voer script uit vanuit directory waarin script staat.
%
%Aanbevelingen:
%- Voor een hoge rekensnelheid is het van groot belang dit script te draaien vanaf
%  een locale schijf (bijvoorbeeld de C-schijf). Ook zouden bronbestanden zoals woningbestanden en
%  geluidresultfiles op deze schijf gezet moeten worden.
%  Met dit script rekenen vanaf een netwerkschijf zal leiden tot een fors hogere rekentijd.

% ---------------------------------
% geluidstellingen.m
%
% versie 2.3: 04/06/2013 Ed Gordijn (AAS)
% wijzigingen t.o.v. 2.2
% - start_dir is nu pwd ipv de directory van deze functie
% - de functie hoeft niet langer aangeroepen te worden vanuit zijn eigen
%   directory
%
% versie 2.2: 06/12/2011 Ed Gordijn (AAS)
% wijzigingen t.o.v. 2.1
% - contour.exe is een nieuwe versie die meer dan 10 contouren aan kan.
% - functies aangepast aan deze nieuwe exe: make_tape2 en make_contour_input
%
% versie 2.2: 	20/02/2011 Ed Gordijn (AAS).
%       Wijzigingen in aanmaken tape2
%
% versie 2.1:   31/08/2011 geschreven door Mark Brouwer (AAS).
%Wijzigingen t.o.v versie 2.0
%- code delete("*.*") vervangen door delete("*"), om zo de 
%  tijdelijke extensieloze bestanden onder de /temp directory te kunnen
%  elimineren
%- maximale afstand tussen twee verbroken contourpunten is verhoogd tot
%  99999, om zo ook niet gesloten contouren te kunnen doorrekenen. Hierdoor
%  wordt een tussentijdse error voorkomen
%
% versie 2.0: 	21/09/2009 geschreven door Roel Hogenhuis (NLR).
%		Ontwikkeld in Matlab R2008b
%
% versie 3.0: 	20/01/2010 geschreven door Roel Hogenhuis (NLR).
%		Ontwikkeld in Matlab R2008b
% Wijzigingen to.v. versie 2.0: 
% TOEVOEGING:
% - Wanneer een contour buiten het grid valt wordt de contour gesloten over de gridrand. Er wordt een 
% waarschuwing gegeven dat dit de resultaten van de tellingen kan beinvloeden.
%
% versie 3.1    08/04/2011 geschreven door Sander Hebly (NLR)
%        Ontwikkeld in Matlab R2010a
%        Toegevoegd:   - wel sluiten contour bij I4 = [0 0 0 0]
%                      - waarschuwing bij geen contouren gevonden
%                      - waarschuwing bij tegelijkertijd Lden/Lnight tellen
%                      
% versie 3.2    12/11/2012 geschreven door Roel Hogenhuis (NLR)
%        Ontwikkeld in Matlab R2012a
%        Toegevoegd:   - sneller wegschrijven van tape2 bestanden in functie 'make_tape2'
%                      
% versie 3.3    12/02/2014 geschreven door Roel Hogenhuis (NLR)
%        Ontwikkeld in Matlab R2011a
%        Toegevoegd:   - nieuwe versie contour.exe waardoor meer dan 10 contouren per keer kunnen worden weggeschreven. Dit geeft een snelheidsverhoging.
%                      - de functie make_tape2 en make_contour_input_file zijn samengevoegd
% ---------------------------------
ver = '3.3'; % Versie


global wonmat_won wonmat_pers

if(isfield(wonmat_won,'bestand') == 0)
    wonmat_won.bestand  = '';
    wonmat_pers.bestand = '';
end

size_I2 = size(I2);
if(size_I2(1,1) < size_I2(1,2))
    I2 = I2';
end

% Bepaal de werk directory
% temp_dir = [pwd '\temp'];
% mkdir(temp_dir)
copyfile(I1,[pwd '\result'])

% Maak contouren voor de gevraagde contourwaarden
tape2bestand = '__temp__.tape2';
make_tape2(I2, tape2bestand)

[Xonder,Yonder] = read_enviraformat(I1);
relcoord = [Xonder Yonder];
n_contours = length(I2);

% geef waarschuwing al gelijktijdig Lden en Lnight tellingen worden gevraagd
if (I4(1)+I4(3) > 0) && (I4(2)+I4(4) > 0)
    disp('Waarschuwing: U vraagt gelijktijdig Lden en Lnight tellingen, terwijl maar 1 result per keer kan worden geteld')
end

if(I4(1) == 1)              % voer Lden woningtelling uit
    % laad woningbestand in als dat nog niet gedaan is (ook als een nieuw bestand geselecteerd is)
    woningbestand = char(I3(1,1));
    if(strcmp(woningbestand,wonmat_won.bestand) == 0)
        wonmat_won.bestand = woningbestand;
        if(woningbestand(end-3:end) == '.mat')
            wonmat_won.data = load(wonmat_won.bestand);
            wonmat_won.data = getfield(wonmat_won.data,char(fieldnames(wonmat_won.data)));
        else
            [wonmat_won.data] = read_woningbestand(wonmat_won.bestand);
        end
    end
    n_won_lden = woningtelling(relcoord, I1, tape2bestand);
else
    n_won_lden =  zeros(n_contours,1);
    n_won_lden = [n_won_lden I2];
end

if(I4(2) == 1)              % voer Lnight woningtelling uit
    % laad woningbestand in als dat nog niet gedaan is (ook als een nieuw bestand geselecteerd is)
    woningbestand = char(I3(1,1));
    if(strcmp(woningbestand,wonmat_won.bestand) == 0)
        wonmat_won.bestand = woningbestand;
        if(woningbestand(end-3:end) == '.mat')
            wonmat_won.data = load(wonmat_won.bestand);
            wonmat_won.data = getfield(wonmat_won.data,char(fieldnames(wonmat_won.data)));
        else
            [wonmat_won.data] = read_woningbestand(wonmat_won.bestand);
        end
    end
    n_won_ln = woningtelling(relcoord, I1, tape2bestand);
else
    n_won_ln = zeros(n_contours,1);
    n_won_ln = [n_won_ln I2];
end

if(I4(3) == 1)              % voer bepaling van Lden ernstig gehinderden uit
    % laad personenbestand in als dat nog niet gedaan is (ook als een nieuw bestand geselecteerd is)
    personenbestand = char(I3(2,1));
    if(strcmp(personenbestand,wonmat_pers.bestand) == 0)
        wonmat_pers.bestand = personenbestand;
        if(personenbestand(end-3:end) == '.mat')
            wonmat_pers.data = load(wonmat_pers.bestand);
            wonmat_pers.data = getfield(wonmat_pers.data,char(fieldnames(wonmat_pers.data)));
        else
            [wonmat_pers.data] = read_woningbestand(wonmat_pers.bestand);
        end
    end
    % bepaal dosiseffectrelatie
    if(nargin == 4)
        de_rel = '1-1./(1+exp(-8.1101+(0.1333.*mean_L)))';
    else
        de_rel = char(I5(1,1));
    end
    n_egh = personentel(relcoord,de_rel,I1,tape2bestand);
else
    n_egh = zeros(n_contours,1);
    n_egh = [n_egh I2];  
end

if(I4(4) == 1)              % voer Lnight slaapverstoringstelling uit
    % laad personenbestand in als dat nog niet gedaan is (ook als een nieuw bestand geselecteerd is)
    personenbestand = char(I3(2,1));
    if(strcmp(personenbestand,wonmat_pers.bestand) == 0)
        wonmat_pers.bestand = personenbestand;
        if(personenbestand(end-3:end) == '.mat')
            wonmat_pers.data = load(wonmat_pers.bestand);
            wonmat_pers.data = getfield(wonmat_pers.data,char(fieldnames(wonmat_pers.data)));
        else
            [wonmat_pers.data] = read_woningbestand(wonmat_pers.bestand);
        end
    end
    % bepaal dosiseffectrelatie
    if(nargin == 4)
        de_rel = '1-1./(1+exp(-6.642+(0.1046*mean_L)))'; 
    else
        de_rel = char(I5(2,1));
    end
    n_svs_ln = personentel(relcoord,de_rel, I1, tape2bestand);
else
    n_svs_ln = zeros(n_contours,1);
    n_svs_ln = [n_svs_ln I2];      
end

if(sum(I4) == 0)     % DWZ niet tellen: alleen contouren sluiten
    % maak een dummy wonmat structure
    wonmat_won.data = [0 0 0];
    wonmat_won.bestand = '';
    woningtelling(relcoord,I1, tape2bestand);
end

% indien gewenst tape2 file bewaren
if(nargin == 6)
    movefile(tape2bestand, I6)
else
    delete(tape2bestand)
end

% Opruimen tijdelijke bestanden
delete([pwd '\result']);

O1 = n_won_lden;
O2 = n_won_ln;
O3 = n_egh;
O4 = n_svs_ln;

%------------------------------------------------------------------------------------------------------------------
% Ondersteunende functies:
%------------------------------------------------------------------------------------------------------------------
function make_contour_input_file(contourwaarden, tape2bestand)
% make_contour_input_file makes the contour_input file

% Input
%   contourwaarden  vector with all desired contour values (with 1 column)
%   tape2bestand    filename for tape2 [optional] 
% ---------------------------------
% versie 2.1:   08/12/2011 vereenvoudigde versie, Ed Gordijn (AAS)
%       optionele parameter voor de naam van het tape2 bestand toegevoegd
%
% versie 2.0: 	10/05/2010 geschreven door Roel Hogenhuis (NLR).
%		Ontwikkeld in Matlab R2008b
%       Wijzigingen t.o.v. versie 1.0:
%       - Aangepast aan make_tape2 versie 2.0 (dus aangepast aan contour.exe die meer dan 10 contouren aankan)
%
% versie 1.0: 	29/04/2008 geschreven door Hafid Rachyd (NLR).
%		Ontwikkeld in Matlab 7.1
%
% ---------------------------------

%% Constanten definitie
refinement   = 4;
stepsize     = 100;

%% Optioneel tape2bestand
if(nargin == 1)
    tape2bestand = 'temp.tape2';
end

%% Maak het bestand
fid = fopen('contour_input','wt');

fprintf(fid,'outputfile %s\n'    ,tape2bestand);
fprintf(fid,'refinement %10.2f\n',refinement);
fprintf(fid,'stepsize %10.2f\n'  ,stepsize);
fprintf(fid,'contour %10.2f\n'   ,contourwaarden);

fclose(fid);

%------------------------------------------------------------------------------------------------------------------
function make_tape2(contourwaarden, tape2bestand)
% make_tape2 makes a tape2 file
%
% input:
%   contourwaarden  vector with all desired contour values (with 1 column)
%
% ---------------------------------
% versie 2.3:   09/06/2013 Ed Gordijn (AAS)
%       optionele parameter voor de naam van het tape2 bestand toegevoegd
%
% versie 2.1: 	08/12/2011 geschreven door Ed Gordijn (AAS).
%		Ontwikkeld in Matlab R2011b
%       - naam tape2 bestand gewijzigd, nu met een extentie omdat 'if exist'
%       onvoorspelbaar resultaat geeft voor files zonder extentie (vindt
%       bijvoorbeeld 'tape2.m'
%       - check op bin-grootte: maximaal 50 contouren (relevant bij
%       plotten)
%
% versie 2.0: 	10/05/2010 geschreven door Roel Hogenhuis (NLR).
%		Ontwikkeld in Matlab R2008b
%       Wijzigingen t.o.v. versie 1.0:
%       - Aangepast aan contour.exe die meer dan 10 contouren aankan.
%
% versie 1.0: 	02/10/2008 geschreven door Roel Hogenhuis (NLR).
%		Ontwikkeld in Matlab R2008b
%
% ---------------------------------
%% Constanten definitie
bin = 50; % contour.exe kan maximaal 50 contourwaarden aan

%% Optioneel tape2bestand
if(nargin == 1)
    tape2bestand = 'temp.tape2';
end

N = size(contourwaarden);
if(N(1,1) < N(1,2))
    contourwaarden = contourwaarden';
    N = size(contourwaarden);
end

% init loop
tape2data = [];
for i1 = 1:bin:N
    % make inputfile
    i2 = min(i1 + bin -1, N); % nooit groter dan N
    make_contour_input_file(contourwaarden(i1:i2), tape2bestand);
    
    % Verwijder reeds aanwezig tape2 bestand
    if exist([pwd '\' tape2bestand],'file')
        delete(tape2bestand)
    end

    % Run external program
    function_dir = fileparts(which('contour.exe'));
    dos([function_dir '\contour.exe']);
    
    % Read result
    tape2data = [tape2data; load(tape2bestand)];
end
%% Aanmaken tape2 file
if N > bin % bin.tape2 is van de laatste bin
    fid = fopen(tape2_bestand,'wt');
    fprintf(fid,'%6d%10.2f%10.2f%8.2f\n',tape2data');
    fclose(fid);
% else
%     % tape2 is reeds compleet
%     movefile(tape2bestand, 'tape2')
end

%% Opruimen temp file
delete('contour_input')

%------------------------------------------------------------------------------------------------------------------

function n_pers = personentel(relcoord,de_rel, I1, tape2bestand)

% personentel.m
%
% Personentellingen obv tape2 contouren
% gebruik makend van inpoly.m script
% Bepaling van aantal gehinderden/slaapverstoorden
%
% ---------------------------------
% versie 2.3:   09/06/2013 Ed Gordijn (AAS)
%       optionele parameter voor de naam van het tape2 bestand toegevoegd
%
% versie 2.0: 	20/01/2010 geschreven door Roel Hogenhuis (NLR).
%		Ontwikkeld in Matlab R2008b
% Wijzigingen to.v. versie 1.0: 
% TOEVOEGING:
% - Wanneer een contour buiten het grid valt wordt de contour gesloten over de gridrand. Er wordt een 
% waarschuwing gegeven dat dit de resultaten van de tellingen kan beinvloeden.
%
% ---------------------------------
% versie 1.0: 	05/06/2009 geschreven door Roel Hogenhuis (NLR).
%		Ontwikkeld in Matlab R2008b
% versie 1.1    08/04/2011 geschreven voor Sander Hebly (NLR)
%       Ontwikkeld in Matlab R2010a
%       Aanpassing: check of er contouren zijn, geef waarschuwing bij lege
%       tape2 en return n_pers = 0
% ---------------------------------

global wonmat_pers
wonmat_telling = wonmat_pers.data;

%% Optioneel tape2bestand
if(nargin == 3)
    tape2bestand = 'temp.tape2';
end

% 1. BESTANDEN INLEZEN
format long g
C   = load(tape2bestand); % kolom1:ID kolom2:X kolom3:Y kolom4:Value

% check of er contouren zijn
if numel(C) == 0
     disp('Er zijn geen contouren gevonden voor opgegeven contourwaarden')
     disp('Tellingen kunnen niet worden uitgevoerd')
     n_pers = 0;
     return
end

% 2. UITVOEREN PERSONENTELLING
[m,n]               = size(C);
indx                = find(C(:,1)==1); % beginrij voor contour
indxa               = [indx; m+1];
[mindxa, nindxa]    = size(indxa);
contourwaarden      = unique(C(:,4));
cw_size             = size(contourwaarden);
cont   = 1;
n_p_end   = 0;
for g=1:cw_size(1,1)
    if(cont == 1)    
        for j=1:(mindxa-1)
            if C(indxa(j),4)==contourwaarden(g)
                bg = indxa(j);     % begin van contourrij
                ed = indxa(j+1)-1; % einde van contourrij
                eval(['p' num2str(j) ' = C(bg:ed,:);']); % creeer deelvector p1,p2,...
                n_p_end = n_p_end +1;
            end
        end
        for j=1:(mindxa-1)
            if (cont == 1 && C(indxa(j),4)==contourwaarden(g))
                % check of contour nu wel gesloten is door te bepalen of het 1e en laatste punt gelijk zijn
                eval(['startpoint = p' num2str(j) '(1,2:3);'])
                eval(['endpoint   = p' num2str(j) '(end,2:3);'])
                test = sum(startpoint - endpoint);
                if(test ~= 0)              % sluit de contour
                    d = 150;       % maximale afstand tussen twee verbroken contourpunten. 
                    % Wanneer contourpunten binnen deze afstand van elkaar liggen, worde ze geacht tot dezelfde contour te behoren.
                    eps = 0;       % minimale afstand tussen opeenvolgende contourpunten. Wanneer contourpunten binnen deze afstand van elkaar liggen, worden ze als 1 contourpunt beschouwd.
                    BorderOption=1;
                    [x_onder,y_onder,x_boven,y_boven] = read_result(I1);
                    x_onder = x_onder - relcoord(1,1);
                    y_onder = y_onder - relcoord(1,2);
                    x_boven = x_boven - relcoord(1,1);
                    y_boven = y_boven - relcoord(1,2);
                    [ContourStructure]  = BuildContourStructureNew(C,d,eps,[x_onder,x_boven,y_onder,y_boven],BorderOption);
                    C = BuildContourMatrix(ContourStructure);

                    % test of contour op de rand ligt
                    x_min=round(min(C(:,2)));
                    y_min=round(min(C(:,3)));
                    x_max=round(max(C(:,2)));
                    y_max=round(max(C(:,3)));

                    if(x_min == x_onder || y_min == y_onder || x_max == x_boven || y_max == y_boven)
                        % bepaal contouren die op rand liggen
                        contours = unique(C(find(round(C(:,2)) == x_min | round(C(:,2)) == x_max | round(C(:,3)) == y_min | round(C(:,3)) == y_max),4));
                        n_cn     = size(contours);
                        n_cn     = n_cn(1,1);
                        for i=1:n_cn
                            disp(['Waarschuwing: De contour met waarde ' num2str(contours(i,1)) ' ligt op de rand van het rekengebied.'])
                            disp('Dit kan resulteren in verkeerde resultaten van de telling.')
                            disp(' ')
                        end
                    end
                    cont = 0;
                end
            end
        end
    clear test p*
    end
end

if(cont == 0)
    % schrijf gesloten tape2 weg
    fid3 = fopen(tape2bestand,'wt');
    fprintf(fid3,'%6d%10.2f%10.2f%8.2f\n',C');
    fclose(fid3);
end

clear p* m* i* g* j* bd eg cont

% start de daadwerkelijke telling
xref = relcoord(1,1);
yref = relcoord(1,2);
C(:,2) = C(:,2) + xref;
C(:,3) = C(:,3) + yref;

m              = size(C);
m              = m(1,1);
indx           = find(C(:,1)==1); % beginrij voor contour
indxa          = [indx; m+1];
mindxa         = size(indxa);
mindxa         = mindxa(1,1);
contourwaarden = unique(C(:,4));
contourwaarden = sort(contourwaarden);
cw_size        = size(contourwaarden);

n_pers = zeros(cw_size(1,1),1);
for g=1:cw_size(1,1)
    for j=1:(mindxa-1)
        if C(indxa(j),4)==contourwaarden(g)
            bg = indxa(j);     % begin van contourrij
            ed = indxa(j+1)-1; % einde van contourrij
            eval(['p' num2str(j) ' = C(bg:ed,:);']) % creeer deelvectoren p1,p2,...
        end
    end

    %looping for p1, p2, p3, etc.
    mw = size(wonmat_telling);
    mw = mw(1,1);
    wt = [wonmat_telling zeros(mw,1)];
    
    for j=1:(mindxa-1)
        if C(indxa(j),4)==contourwaarden(g)
            % check of contour nu wel gesloten is door te bepalen of het 1e en laatste punt gelijk zijn
            eval(['startpoint = p' num2str(j) '(1,2:3);'])
            eval(['endpoint   = p' num2str(j) '(end,2:3);'])
            test = sum(startpoint - endpoint);
            if(test ~= 0 )
                error(['De contour met waarde ' num2str(contourwaarden(g))...
                    ' is niet gesloten. Reken met een groter grid of hogere contourwaarden om dit te voorkomen.'])
            end
            eval(['[wtel] = inpoly(wt(:,2:3), p' num2str(j) '(:,2:3));']); % looping voor personentelling per deelvector
            wt = wt + [zeros(mw,3) wtel]; % wt is matrix die uit een personenbestand matrix en een kolomvector met true/false (1,0) voor persoon binnen contour;
        end
    end

    % volgende algoritme checkt of de getelde personen wel bij de contouren
    % hoort. Oneven - wel bijhoren; even - niet !
    for i=1:mw
        if mod(wt(i,4),2)==0,
            wt(i,4)=0;
        else
            wt(i,4)=1;
        end
    end

    % tel aantal personen en verklein wonmat_telling voor volgende rekenstap
    perstel      = wt(:,1).*wt(:,4);
    n_pers(g,1)  = sum(perstel);
    test = find(wt(:,4) == 1);
    wonmat_telling = wonmat_telling(test,:);
    clear wt wtel test p*
end

% bereken aantal gehinderden uit aantal personen per schil

% bepaal inwoners per schil
size_n_pers = size(n_pers);
if(size_n_pers(1,1) ~= 1)
    pop_per_contour          = n_pers(1:end-1)-n_pers(2:end);
    pop_per_contour(end+1,1) = n_pers(end);
else
    pop_per_contour = n_pers;
end

% bereken gemiddelde geluidswaarde in schil; deze wordt in de dosis-efffectrelatie gebruikt
if(cw_size(1,1) ~= 1)
    mean_L          = ((contourwaarden(1:end-1)+contourwaarden(2:end))/2);
    mean_L(end+1,1) = contourwaarden(end);
else
    mean_L = contourwaarden;
end

eval(['perc_gh = ' de_rel ';'])

n_pers = [perc_gh.*pop_per_contour contourwaarden];

%------------------------------------------------------------------------------------------------------------------

function [x_onder,y_onder,x_boven,y_boven]=read_result(filenaam)

% read_enviraformat.m
%
%[x_onder,y_onder,x_boven,y_boven]=read_result(filenaam)
%
%Deze functie heeft als input een filenaam (inclusief directory) in %string formaat
%
% ---------------------------------
% versie 1.0: 	05/06/2009 geschreven door Roel Hogenhuis (NLR).
%		Ontwikkeld in Matlab R2008b
%
% ---------------------------------

%uitlezen van relevante headerinformatie
fid=fopen(filenaam);
 
for i=1:4, 
    fgetl(fid);
end
fgetl(fid);

for i=1:6
    fgetl(fid);
end

x_onder=fgetl(fid);
x_boven=fgetl(fid);
fgetl(fid);
fgetl(fid);
x_onder = str2num(x_onder(8:length(x_onder)));
x_boven = str2num(x_boven(8:length(x_boven)));
  
y_onder=fgetl(fid);
y_boven = fgetl(fid);
fgetl(fid);
fgetl(fid);
y_onder=str2num(y_onder(8:length(y_onder)));
y_boven = str2num(y_boven(8:length(y_boven)));

fclose(fid);

%------------------------------------------------------------------------------------------------------------------

function[Xonder,Yonder]=read_enviraformat(filenaam)

% read_enviraformat.m
%
%[grid,NX,NY,Xonder,Yonder,Xstap,Ystap,eenheid]=
%  read_enviraformat(filenaam)
%
%Deze functie heeft als input een filenaam (inclusief directory) in %string formaat
%
% ---------------------------------
% versie 1.0: 	05/06/2009 geschreven door Roel Hogenhuis (NLR).
%		Ontwikkeld in Matlab R2008b
%
% ---------------------------------

%uitlezen van relevante headerinformatie
 fid=fopen(filenaam);
 
 for i=1:4, fgetl(fid);, end;
 fgetl(fid);

 for i=1:6, fgetl(fid);, end;
 Xonder=fgetl(fid);, fgetl(fid);, fgetl(fid);, fgetl(fid);
 Xonder=str2num(Xonder(8:length(Xonder)));
  
 Yonder=fgetl(fid);, fgetl(fid);, fgetl(fid);, fgetl(fid);
 Yonder=str2num(Yonder(8:length(Yonder)));

fclose(fid);

%------------------------------------------------------------------------------------------------------------------

function [wonmat] = read_woningbestand(bestand)

% read_woningbestand.m
%
% functie om een wongingbestand in te lezen. De getallen worden in een matrix gezet.
%
% ---------------------------------
% versie 1.0: 	05/06/2009 geschreven door Roel Hogenhuis (NLR).
%		Ontwikkeld in Matlab R2008b
%
% ---------------------------------

fid=fopen(bestand,'rt');

out=textscan(fid,'%f%f%f', 'delimiter', ':');
fclose(fid);

wonmat_1 = cell2mat(out(1));
wonmat_2 = cell2mat(out(2));
wonmat_3 = cell2mat(out(3));

wonmat = [wonmat_1 wonmat_2 wonmat_3];

%------------------------------------------------------------------------------------------------------------------

function n_won = woningtelling(relcoord, I1, tape2bestand)

% woningtelling.m
%
% Woningtellingen obv tape2 contouren
% gebruik makend van inpoly.m script
% 
% ---------------------------------
% versie 2.3:   09/06/2013 Ed Gordijn (AAS)
%       optionele parameter voor de naam van het tape2 bestand toegevoegd
%
% ---------------------------------
% versie 2.0: 	20/01/2010 geschreven door Roel Hogenhuis (NLR).
%		Ontwikkeld in Matlab R2008b
%
% Wijzigingen to.v. versie 1.0: 
% TOEVOEGING:
% - Wanneer een contour buiten het grid valt wordt de contour gesloten over de gridrand. Er wordt een 
% waarschuwing gegeven dat dit de resultaten van de tellingen kan beinvloeden.
%
% ---------------------------------
% versie 1.0: 	05/06/2009 geschreven door Roel Hogenhuis (NLR).
%		Ontwikkeld in Matlab R2008b
% versie 1.1    08/04/2011 geschreven voor Sander Hebly (NLR)
%       Ontwikkeld in Matlab R2010a
%       Aanpassing: check of er contouren zijn, geef waarschuwing bij lege
%       tape2 en return n_won = 0
% ---------------------------------

global wonmat_won
wonmat_telling = wonmat_won.data;

%% Optioneel tape2bestand
if(nargin == 2)
    tape2bestand = 'temp.tape2';
end

% 1. BESTANDEN INLEZEN

tape2location = [pwd '\tape2'];

format long g
C   = load(tape2bestand); % kolom1:ID kolom2:X kolom3:Y kolom4:Value

% check of er contouren zijn
if numel(C) == 0
     disp('Er zijn geen contouren gevonden voor opgegeven contourwaarden')
     disp('Tellingen kunnen niet worden uitgevoerd')
     n_won = 0;
     return
end

% 2. UITVOEREN WONINGTELLING

[m,n]               = size(C);
indx                = find(C(:,1)==1); % beginrij voor contour
indxa               = [indx; m+1];
[mindxa, nindxa]    = size(indxa);
contourwaarden      = unique(C(:,4));
cw_size             = size(contourwaarden);
cont   = 1;
n_p_end   = 0;
for g=1:cw_size(1,1)
    if(cont == 1)    
        for j=1:(mindxa-1)
            if C(indxa(j),4)==contourwaarden(g)
                bg = indxa(j);     % begin van contourrij
                ed = indxa(j+1)-1; % einde van contourrij
                eval(['p' num2str(j) ' = C(bg:ed,:);']); % creeer deelvector p1,p2,...
                n_p_end = n_p_end +1;
            end
        end
        for j=1:(mindxa-1)
            if (cont == 1 && C(indxa(j),4)==contourwaarden(g))
                % check of contour nu wel gesloten is door te bepalen of het 1e en laatste punt gelijk zijn
                eval(['startpoint = p' num2str(j) '(1,2:3);'])
                eval(['endpoint   = p' num2str(j) '(end,2:3);'])
                test = sum(startpoint - endpoint);
                if(test ~= 0)              % sluit de contour
                    d = 150;       % maximale afstand tussen twee verbroken contourpunten. 
		    % Wanneer contourpunten binnen deze afstand van elkaar liggen, worde ze geacht tot dezelfde contour te behoren.
                    eps = 0;       % minimale afstand tussen opeenvolgende contourpunten. Wanneer contourpunten binnen deze afstand van elkaar liggen, worden ze als 1 contourpunt beschouwd.
                    BorderOption=1;
                    [x_onder,y_onder,x_boven,y_boven] = read_result(I1);
                    x_onder = x_onder - relcoord(1,1);
                    y_onder = y_onder - relcoord(1,2);
                    x_boven = x_boven - relcoord(1,1);
                    y_boven = y_boven - relcoord(1,2);
                    [ContourStructure]  = BuildContourStructureNew(C,d,eps,[x_onder,x_boven,y_onder,y_boven],BorderOption);
                    C = BuildContourMatrix(ContourStructure);

                    % test of contour op de rand ligt
                    x_min=round(min(C(:,2)));
                    y_min=round(min(C(:,3)));
                    x_max=round(max(C(:,2)));
                    y_max=round(max(C(:,3)));

                    if(x_min == x_onder || y_min == y_onder || x_max == x_boven || y_max == y_boven)
                        % bepaal contouren die op rand liggen
                        contours = unique(C(find(round(C(:,2)) == x_min | round(C(:,2)) == x_max | round(C(:,3)) == y_min | round(C(:,3)) == y_max),4));
                        n_cn     = size(contours);
                        n_cn     = n_cn(1,1);
                        for i=1:n_cn
                            disp(['Waarschuwing: De contour met waarde ' num2str(contours(i,1)) ' ligt op de rand van het rekengebied.'])
                            disp('Dit kan resulteren in verkeerde resultaten van de telling.')
                            disp(' ')
                        end
                    end
                    cont = 0;
                end
            end
        end
    clear test p*
    end
end

if(cont == 0)
    % schrijf gesloten tape2 weg
    fid3 = fopen('tape2','wt');
    fprintf(fid3,'%6d%10.2f%10.2f%8.2f\n',C');
    fclose(fid3);
end

clear p* m* i* g* j* bd eg cont

% start de daadwerkelijke telling, tenzij woningbestand dummy is
if isequal(wonmat_telling,[0 0 0])
    return
end

xref = relcoord(1,1);
yref = relcoord(1,2);
C(:,2) = C(:,2) + xref;
C(:,3) = C(:,3) + yref;

m              = size(C);
m              = m(1,1);
indx           = find(C(:,1)==1); % beginrij voor contour
indxa          = [indx; m+1];
mindxa         = size(indxa);
mindxa         = mindxa(1,1);
contourwaarden = unique(C(:,4));
contourwaarden = sort(contourwaarden);
cw_size        = size(contourwaarden);

n_won = zeros(cw_size(1,1),1);
for g=1:cw_size(1,1)
    for j=1:(mindxa-1)
        if C(indxa(j),4)==contourwaarden(g)
            bg = indxa(j);     % begin van contourrij
            ed = indxa(j+1)-1; % einde van contourrij
            eval(['p' num2str(j) ' = C(bg:ed,:);']) % creeer deelvectoren p1,p2,...
        end
    end

    %looping for p1, p2, p3, etc.
    mw = size(wonmat_telling);
    mw = mw(1,1);
    wt = [wonmat_telling zeros(mw,1)];
    
    for j=1:(mindxa-1)
        if C(indxa(j),4)==contourwaarden(g)
            % check of contour nu wel gesloten is door te bepalen of het 1e en laatste punt gelijk zijn
            eval(['startpoint = p' num2str(j) '(1,2:3);'])
            eval(['endpoint   = p' num2str(j) '(end,2:3);'])
            test = sum(startpoint - endpoint);
            if(test ~= 0 )
                error(['De contour met waarde ' num2str(contourwaarden(g))...
                    ' is niet gesloten. Reken met een groter grid of hogere contourwaarden om dit te voorkomen.'])
            end
            eval(['[wtel] = inpoly(wt(:,2:3), p' num2str(j) '(:,2:3));']); % looping voor personentelling per deelvector
            wt = wt + [zeros(mw,3) wtel]; % wt is matrix die uit een personenbestand matrix en een kolomvector met true/false (1,0) voor persoon binnen contour;
        end
    end

    % volgende algoritme checkt of de getelde personen wel bij de contouren
    % hoort. Oneven - wel bijhoren; even - niet !
    for i=1:mw
        if mod(wt(i,4),2)==0,
            wt(i,4)=0;
        else
            wt(i,4)=1;
        end
    end

    % tel aantal woningen en verklein wonmat_telling voor volgende rekenstap
    wontel     = wt(:,1).*wt(:,4);
    n_won(g,1) = sum(wontel);
    test = find(wt(:,4) == 1);
    wonmat_telling = wonmat_telling(test,:);
    clear wt wtel p*
end

% bepaal woningen per schil
size_n_pers = size(n_won);
if(size_n_pers(1,1) ~= 1)
    won_per_contour          = n_won(1:end-1)-n_won(2:end);
    won_per_contour(end+1,1) = n_won(end);
else
    won_per_contour = n_won;
end

n_won = [won_per_contour contourwaarden];

%------------------------------------------------------------------------------------------------------------------

function [in,on] = inpoly(p,node,cnect)

% Point-in-polygon testing.
%
% Determine whether a series of points lie within the bounds of a polygon
% in the 2D plane. General non-convex, multiply-connected polygonal
% regions can be handled.
%
% STANDARD CALL:
%
%   in = inpoly(p,node);
%
% Inputs:
%   p   : The points to be tested as an Nx2 array [x1 y1; x2 y2; etc]. 
%   node: The vertices of the polygon as an Mx2 array [X1 Y1; X2 Y2; etc].
%         This assumes that the vertices are specified in consecutive 
%         order.
%
% Output:
%   in  : An Nx2 logical array with IN(i) = TRUE if P(i,:) lies within the 
%         region.
%
% EXTENDED CALL:
%
%   [in,on] = inpoly(p,node,cnect);
%
% Inputs:
%   cnect: An Mx2 array of connections between polygon vertices
%          [n1 n2; n3 n4; etc]. 
%
% Output:
%   on  : An Nx2 logical array with ON(i) = TRUE if P(i,:) lies on a
%         boundary of the region. A small tolerance is used to deal with
%         numerical precision.
%
% Example:
%
%   polydemo;       % Will run a few examples
%
% See also inpolygon

% The algorithm is based on the crossing number test, which counts the
% number of times a line that extends from each point past the right-most 
% region of the polygon intersects with a wall segment. Points with odd
% counts are inside. A simple implementation of this method requires each
% wall to be checked for each point, resulting in an O(N*M) operation 
% count.
%
% This implementation does better in 2 ways:
%
%   1. The test points are sorted and partitioned according to their
%      y-value into a series of "bins". This allows us to only check the 
%      points that have a better chance of intersecting a given wall, 
%      rather than looping through the whole set.
% 
%   2. The intersection test is simplified by first checking against the
%      bounding box for a given wall segment. Checking against the bbox is
%      an inexpensive alternative to the full intersection test and allows
%      us to take a number of shortcuts, minimising the number of times the
%      full test needs to be done.
%
%   Darren Engwirda: 2005-2007
%   Email          : d_engwirda@hotmail.com
%   Last updated   : 13/04/2007 with MATLAB 7.0
%
% Problems or suggestions? Email me.


% ERROR CHECKING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin<3
    cnect = [];
    if nargin<2
        error('Insufficient inputs');
    end
end

% Build cnect if not passed
nnode = size(node,1);
if isempty(cnect)
    cnect = [(1:nnode-1)' (2:nnode)'; nnode 1];
end

if size(p,2)~=2
    error('P must be an Nx2 array.');
end
if size(node,2)~=2
    error('NODE must be an Mx2 array.');
end
if size(cnect,2)~=2 || size(cnect,1)~=nnode
    error('CNECT must be an Mx2 array.');
end
if max(cnect(:))>nnode || any(cnect(:)<1)
    error('Invalid CNECT.');
end

% PRE-PROCESSING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Choose the direction with the biggest range as the "y-coordinate" for the
% test. This should make the partitions work for long and skinny problems 
% wrt either the x or y planes.
if (max(p(:,1))-min(p(:,1)))>(max(p(:,2))-min(p(:,2)))
    % Flip co-ords
    p    = p(:,[2,1]);
    node = node(:,[2,1]);
end

% Forms walls - [x1,y1,x2,y2]
wall = [node(cnect(:,1),:), node(cnect(:,2),:)];

% Constants
n     = size(p,1);
nw    = size(wall,1);
normw = norm(wall(:),'inf');
tol   = eps^0.75*normw;

% Sort test points by y-value
[y,i] = sort(p(:,2));
x     = p(i,1);

% SETUP THE BINS
% Partition the test points into a series of "bins"
% based on their y-value
nbin = ceil(n/100);                 % Number of bins (scale with number of points)
ibin = [1,n*(1:nbin-1)/nbin];       % Indexes into p for bin walls
ibin = round(ibin);
ybin = [y(ibin); y(n)];             % Bin wall values
half = round(nbin/2);

% MAIN LOOP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cn  = false(n,1);   % Because we're dealing with mod(cn,2) we don't have
                    % to actually count the intersections, we can just flip
                    % a logical at each intersection (faster!)
on  = cn;            
lim = normw+tol;        
for k = 1:nw        % Loop through walls
    
    % Current wall
    x1 = wall(k,1); y1 = wall(k,2);
    x2 = wall(k,3); y2 = wall(k,4);
    
    % Sort by x-value
    if x1>x2
        xmin = x2;
        xmax = x1;
    else
        xmin = x1;
        xmax = x2;
    end
    
    % Sort by y-value
    if y1>y2
        ymin = y2;
        ymax = y1;
    else
        ymin = y1;
        ymax = y2;
    end
    
    % DEAL WITH THE BINS
    % Loop through bins to find a "good" starting index
    if nbin==1
        start = 1;
    else
        if ymin<y(1)            % Lower than everything: start at 1
            start = 1;
        elseif ymin>y(n)        % Higher than everything: start at last
            start = n;
        else                    % Inside: find appropriate bin
            % Decide which half of the 
            % bins we check
            if ymin<=ybin(half)
                start = 1;
            else
                start = half;
            end
            % Loop through bins
            for j = start:nbin
                if ymin<=ybin(j+1)
                    start = ibin(j);
                    break
                end
            end            
        end
    end
    
    % Loop through points
    for j = start:n
        % Check the bounding-box for the wall before doing the intersection
        % test. Take shortcuts wherever possible!
        
        Y = y(j);   % Do the array look-up once & make a temp scalar
        if Y<=ymax
            if Y>=ymin
                X = x(j);   % Do the array look-up once & make a temp scalar
                if X>=xmin
                    if X<=xmax
                        
                        % Check if we're "on" the wall
                        on(j) = on(j) || (abs((y2-Y)*(x1-X)-(y1-Y)*(x2-X))<tol);
                        
                        % Do the actual (expensive) intersection test
                        if Y<ymax   % Deal with points exactly at vertices
                            % Check crossing
                            ub = ((x2-x1)*(y1-Y)-(y2-y1)*(x1-X))/((X-lim)*(y2-y1));
                            if (ub>-tol)&&(ub<(1+tol))
                                cn(j) = ~cn(j);
                            end
                        end
                        
                    end
                elseif Y<ymax   % Deal with points exactly at vertices
                    % Has to cross wall
                    cn(j) = ~cn(j);
                end
            end
        else
            % Due to the sorting, no points with >y 
            % value need to be checked
            break       
        end
    end
    
end

% Re-index to take care of the sorting
cn(i) = cn;
on(i) = on;
in    = cn | on;

%------------------------------------------------------------------------------------------------------------------

function [BorderContourParts,DiscardedContourPartsNew] = CheckForBorderContourParts(DiscardedContourParts,Border,d)
        
BorderContourParts = struct([]);
BorderContourParts(1).Points = [];
BorderContourParts(1).Level = [];

DiscardedContourPartsNew = struct([]);
DiscardedContourPartsNew(1).Points = [];
DiscardedContourPartsNew(1).Level = [];

LineSegment1 = [Border(1),Border(3);Border(1),Border(4)];
LineSegment2 = [Border(1),Border(4);Border(2),Border(4)];
LineSegment3 = [Border(2),Border(4);Border(2),Border(3)];
LineSegment4 = [Border(2),Border(3);Border(1),Border(3)];

i = 1;
j = 1;
for k = 1:length(DiscardedContourParts)
    OnBorder = false;
    Point = DiscardedContourParts(k).Points(1,:);
    if DistancePointToLineSegment(Point,LineSegment1) <= d || DistancePointToLineSegment(Point,LineSegment2) <= d || DistancePointToLineSegment(Point,LineSegment3) <= d  || DistancePointToLineSegment(Point,LineSegment4) <= d
        Point = DiscardedContourParts(k).Points(end,:);
        if DistancePointToLineSegment(Point,LineSegment1) <= d || DistancePointToLineSegment(Point,LineSegment2) <= d || DistancePointToLineSegment(Point,LineSegment3) <= d  || DistancePointToLineSegment(Point,LineSegment4) <= d
            OnBorder = true;
        end
    end
    if OnBorder == true
        BorderContourParts(i).Points = DiscardedContourParts(k).Points;
        BorderContourParts(i).Level = DiscardedContourParts(k).Level;
        i = i + 1;
    else
        DiscardedContourPartsNew(j).Points = DiscardedContourParts(k).Points;
        DiscardedContourPartsNew(j).Level = DiscardedContourParts(k).Level;
        j = j + 1;
    end
end

if isempty(BorderContourParts(1).Points)
    BorderContourParts = [];
end
if isempty(DiscardedContourPartsNew(1).Points)
    DiscardedContourPartsNew = [];
end

%------------------------------------------------------------------------------------------------------------------

function [NewContourClosingDistance,NewContourClosingCornerPoints] = DistanceAlongBorder(Point1,Point2,Border,d)

BorderPoints = [Border(1),Border(3); Border(1),Border(4); Border(2),Border(4); Border(2),Border(3)];
MaxDistance = Border(2) - Border(1) + Border(4) - Border(3);

% Check op welke zijden van de border de punten liggen
BorderEdge = [];
LineSegment1 = [Border(1),Border(3);Border(1),Border(4)];
LineSegment2 = [Border(1),Border(4);Border(2),Border(4)];
LineSegment3 = [Border(2),Border(4);Border(2),Border(3)];
LineSegment4 = [Border(2),Border(3);Border(1),Border(3)];

if DistancePointToLineSegment(Point1,LineSegment1) <= d
    BorderEdge(1) = 1;
end
if DistancePointToLineSegment(Point1,LineSegment2) <= d
    BorderEdge(1) = 2;
end
if DistancePointToLineSegment(Point1,LineSegment3) <= d
    BorderEdge(1) = 3;
end
if DistancePointToLineSegment(Point1,LineSegment4) <= d
    BorderEdge(1) = 4;
end

if DistancePointToLineSegment(Point2,LineSegment1) <= d
    BorderEdge(2) = 1;
end
if DistancePointToLineSegment(Point2,LineSegment2) <= d
    BorderEdge(2) = 2;
end
if DistancePointToLineSegment(Point2,LineSegment3) <= d
    BorderEdge(2) = 3;
end
if DistancePointToLineSegment(Point2,LineSegment4) <= d
    BorderEdge(2) = 4;
end

if isempty(BorderEdge)
    NewContourClosingDistance = [];
    NewContourClosingCornerPoints = [];
else
    AbsBorderEdge = abs(BorderEdge(1) - BorderEdge(2));
    SpecialCase = 0;
    if  AbsBorderEdge == 3 
        AbsBorderEdge = 1;
        SpecialCase = 1;
    end
    if AbsBorderEdge == 0
        NewContourClosingDistance = sum(abs(Point1 - Point2));
        NewContourClosingCornerPoints = [];
    end
    if AbsBorderEdge == 1
        NewContourClosingDistance = sum(abs(Point1 - Point2));
        if SpecialCase
            Index = 1;
        else
            Index = max(BorderEdge(1),BorderEdge(2));
        end
        NewContourClosingCornerPoints = BorderPoints(Index,:); 
        if norm(NewContourClosingCornerPoints - Point1) == 0 || norm(NewContourClosingCornerPoints - Point2) == 0
            NewContourClosingCornerPoints = [];
        end
    end
    if AbsBorderEdge == 2 
        Index1 = BorderEdge(1)+1;
        if Index1 == 5
            Index1 = 1;
        end
        Index2 = BorderEdge(2);
        Points = [Point1;BorderPoints(Index1,:);BorderPoints(Index2,:);Point2];
        NewContourClosingDistance = sum(sum(abs(diff(Points))));
        if NewContourClosingDistance > MaxDistance
            Index1 = BorderEdge(1);
            Index2 = BorderEdge(2)+1;
            if Index2 == 5
                Index2 = 1;
            end
            Points = [Point1;BorderPoints(Index1,:);BorderPoints(Index2,:);Point2];
            NewContourClosingDistance = sum(sum(abs(diff(Points))));
        end
        NewContourClosingCornerPoints = Points(2:3,:);
        if norm(NewContourClosingCornerPoints(1,:) - Point1) == 0 || norm(NewContourClosingCornerPoints(1,:) - Point2) == 0
            NewContourClosingCornerPoints(1,:) = [];
        end
        if norm(NewContourClosingCornerPoints(end,:) - Point1) == 0 || norm(NewContourClosingCornerPoints(end,:) - Point2) == 0
            NewContourClosingCornerPoints(end,:) = [];
        end
    end
end
NewContourClosingCornerPoints = flipud(NewContourClosingCornerPoints);

%------------------------------------------------------------------------------------------------------------------

function d = DistancePointToLineSegment(Point,LineSegment)

if length(Point) == 2
    Point = [Point,0];
end
if size(LineSegment,1) == 2
    LineSegment = [LineSegment,[0;0]];
end

v1 = LineSegment(1,:) - Point;
v2 = LineSegment(2,:) - LineSegment(1,:);
lambda = -dot(v1,v2)/(sum(v2.^2));

if lambda <= 0 
    d = norm(LineSegment(1,:) - Point);
elseif lambda <= 1
    d = norm(cross(v2,v1))/norm(v2);
else
    d = norm(LineSegment(2,:) - Point);
end

%------------------------------------------------------------------------------------------------------------------

function [ContourStructure, DiscardedContourParts]  = BuildContourStructureNew(C,d,eps,Border,BorderOption)

% FUNCTION
% This function builds a structure ContourStructure that contains the contours from a matrix C that 
% may contain a randomly shuffled set of complete contours, incomplete contours, or disconnected contour parts
% When possible it connects contour parts of the same level that are within distance d from each other into closed contours.
% The constructed closed contours are put into the structure ContourStructure
% the constructed contour parts that cannot be closed are put into DiscardedContourParts
%
% INPUT:
% C:    Matrix of size (n x 4), containing all contours vertically stacked
%       where n = sum(n_j), where n_j denotes the number of contour points
%       of contour j.
%       The first column C(:,1) of C contains contour point numbers
%       The second and third column C(:,2:3) of C contains the 2D horizontal
%       position of the contour points
%       The fourth column c(:,4) of C contains the noise levels belonging to
%       the contours
%
% d:    The maximum distance between disconnected contour parts
%
% eps:  The minimum distance between two consecutive contour points
%
% Border: the axies limits of the border: [xmin,xmax,ymin,ymax]
%
% BorderOption: 0 or 1. If BorderOption = 0, the border contour is immediately closed along
%                       the border if the closing distance along the border is smaller than 
%                       the distance along the border to another border contour with the same level. 
%                       If BorderOption = 1, all border contours with the same level are  
%                       connected. 
%                       BorderOption only affects “BorderContourParts”; these are contour parts that 
%                       begin and end within a distance d of the border.
%                       BorderOption only has an effect when small and isolated contour parts exist.
%                       In that case BorderOption=0 threats the small contour parts as islands and
%                       BorderOption = 1 will try to connect these parts to other contour parts.
%
% OUTPUT:
% ContourStructure:     A structure array of length N, where N denotes the number of
%                       countours,Struct containing the following data fields:
%                       Points: The contour points
%                       Level:  The contour level
%
% USAGE:
% Without using the border:
% [ContourStructure, DiscardedContourParts]  = BuildContourStructureNew(C,d,eps)
% 
% With using the border:
% [ContourStructure, DiscardedContourParts]  = BuildContourStructureNew(C,d,eps,Border)
% or
% [ContourStructure, DiscardedContourParts]  = BuildContourStructureNew(C,d,eps,Border,BorderOption)
% without BorderOption the default BorderOption = 0 is used
%
% ---------------------------------
% versie 1.0: 	20/01/2010 geschreven door Edwin Bloem (NLR).
%		Ontwikkeld in Matlab R2008b
%
% LET OP:
%	Functie BuildContourStructure kijkt wel hoe verschillende contour delen het best kunnen worden verbonden, 
% 	maar houdt momenteel geen rekening met dichtbij gelegen (dichter bij dan d) contourdelen met dezelfde contourwaarde  
% 	die bij verschillende contouren horen. Dat wil zeggen, zodra de functie een contourdeel tegenkomt met 
% 	dezelfde contourwaarde binnen een afstand d, dan wordt dit contourdeel gebruikt om te verlengen.
% ---------------------------------


NumberOfPoints = size(C,1);
StartIndices = find(C(:,1) == 1);
EndIndices = [StartIndices(2:end)-1;NumberOfPoints];
NumberOfContourParts = length(StartIndices);
ContourParts = struct([]);

for i = 1:NumberOfContourParts
    ContourParts(i).Points = C(StartIndices(i):EndIndices(i),2:3);
    ContourParts(i).Level = C(StartIndices(i),4);
end

ContourStructure = struct([]);
DiscardedContourParts = struct([]);
ContourParts = SortContours(ContourParts);

% if ~isempty(ContourParts)
%     NewContour = ContourParts(1);
%     ContourParts(1) = [];
% end

NewContour = struct([]);

i = 1; 
j = 1;
k = 1;

while ~isempty(ContourParts)
    if i <= length(ContourParts)
        % Check if the current contour part is closed
        if ContourParts(i).Points(1,:) == ContourParts(i).Points(end,:) 
            % The current contour part is closed
            % Put the closed contour that was found in the ContourStructure
            ContourStructure(j).Points = ContourParts(i).Points;
            ContourStructure(j).Level = ContourParts(i).Level;
            j = j + 1;
            ContourParts(i) = [];
        elseif isempty(NewContour)
            % The current contour part is not closed and NewContour is empty
            NewContour = ContourParts(1);
            ContourParts(1) = [];
            i = 1;
        elseif ContourParts(i).Level == NewContour.Level
            % The current contour part is not closed, NewContour is not empty
            % and the level of the current contour part equals the level of NewContour
            % Check if NewContour can be extended with the current contour part
            % and, if this is the case, extend it.
            % To this end find the best way to fit the current contour part
            % with NewContour
            distance(1) = norm(NewContour.Points(end,:) - ContourParts(i).Points(1,:));
            distance(2) = norm(NewContour.Points(end,:) - ContourParts(i).Points(end,:));
            distance(3) = norm(NewContour.Points(1,:) - ContourParts(i).Points(1,:));
            distance(4) = norm(NewContour.Points(1,:) - ContourParts(i).Points(end,:));
            d_min = min(distance);
            index_d_min = find(distance == d_min,1);
            if d_min < d
                if d_min <= eps 
                    if index_d_min <= 2
                        NewContour.Points(end,:) = [];
                    else
                        NewContour.Points(1,:) = [];
                    end
                end
                if index_d_min == 1
                    % The best way to fit the current contour part with NewContour
                    % is to add the points of the current contour part
                    % below the points that are already in NewContour
                    NewContour.Points = [NewContour.Points;ContourParts(i).Points];
                elseif index_d_min == 2
                    % The best way to fit the current contour part with NewContour
                    % is to add the points of the current contour part in
                    % reversed order below the points that are already in NewContour
                     NewContour.Points = [NewContour.Points;flipud(ContourParts(i).Points)];
                elseif index_d_min == 3
                    % The best way to fit the current contour part with NewContour
                    % is to add the points of the current contour part in
                    % reversed order before the points that are already in NewContour
                     NewContour.Points = [flipud(ContourParts(i).Points);NewContour.Points];
                elseif index_d_min == 4
                    % The best way to fit the current contour part with NewContour
                    % is to add the points of the current contour part before the 
                    % points that are already in NewContour
                     NewContour.Points = [ContourParts(i).Points;NewContour.Points];
                end
                ContourParts(i) = [];
                i = 1;   
            else
                i = i + 1;
            end   
        else
            % All contour parts with the same level have been checked
            % Check if the resulting NewContour can be closed
            if norm(NewContour.Points(end,:) - NewContour.Points(1,:)) < d 
                % Check if the first and the last point are too close to each other
                if norm(NewContour.Points(end,:) - NewContour.Points(1,:)) <= eps
                    % Discard last point of NewContour
                    NewContour.Points(end,:) = [];
                end
                % Close NewContour
                NewContour.Points = [NewContour.Points;NewContour.Points(1,:)];
                % Put NewContour in the ContourStructure
                ContourStructure(j).Points = NewContour.Points;
                ContourStructure(j).Level = NewContour.Level;
                j = j + 1;
            else
                % Put NewContour in the DiscardedContourParts
                DiscardedContourParts(k).Points = NewContour.Points;
                DiscardedContourParts(k).Level = NewContour.Level;
                k = k + 1;
            end

            NewContour = struct([]);
            i = 1;
        end
    else
        % All contour parts through all levels have been checked
        % Check if the resulting NewContour can be closed
        if norm(NewContour.Points(end,:) - NewContour.Points(1,:)) < d 
            % Check if the first and the last point are too close to each other
            if norm(NewContour.Points(end,:) - NewContour.Points(1,:)) <= eps
                % Discard last point of NewContour
                NewContour.Points(end,:) = [];
            end
            % Close NewContour
            NewContour.Points = [NewContour.Points;NewContour.Points(1,:)];
            % Put NewContour in the ContourStructure
            ContourStructure(j).Points = NewContour.Points;
            ContourStructure(j).Level = NewContour.Level;
            j = j + 1;
        else
            % Put NewContour in the DiscardedContourParts
            DiscardedContourParts(k).Points = NewContour.Points;
            DiscardedContourParts(k).Level = NewContour.Level;
            k = k + 1;
        end

        NewContour = struct([]);
        i = 1;
    end
end

 % Check if the last NewContour can be closed
if ~isempty(NewContour)
if norm(NewContour.Points(end,:) - NewContour.Points(1,:)) < d 
    % Check if the first and the last point are too close to each other
    if norm(NewContour.Points(end,:) - NewContour.Points(1,:)) <= eps
        % Discard last point of NewContour
        NewContour.Points(end,:) = [];
    end
    % Close NewContour
    NewContour.Points = [NewContour.Points;NewContour.Points(1,:)];
    % Put NewContour in the ContourStructure
    ContourStructure(j).Points = NewContour.Points;
    ContourStructure(j).Level = NewContour.Level;
else
    % Put NewContour in the DiscardedContourParts
    DiscardedContourParts(k).Points = NewContour.Points;
    DiscardedContourParts(k).Level = NewContour.Level;
    end
end

% If border is given, check if discarded countours can be closed by using the border

  
if nargin >= 4
    if nargin == 4
        BorderOption = 0;
    end
    CornerPoints = struct([]);
    CornerPoints(1).Points = [];
    if ~isempty(DiscardedContourParts)
        DiscardedContourParts = SortContours(DiscardedContourParts);
        [BorderContourParts,DiscardedContourParts] = CheckForBorderContourParts(DiscardedContourParts,Border,d);       
        NewContour = struct([]);
        while ~isempty(BorderContourParts)
            if isempty(NewContour)
                NewContour = BorderContourParts(1);
                [NewContourClosingDistance,NewContourClosingCornerPoints] = DistanceAlongBorder(NewContour.Points(1,:),NewContour.Points(end,:),Border,d);
                BorderContourParts(1) = [];
%                i = 1;
%            elseif BorderContourParts(i).Level == NewContour.Level
            elseif BorderContourParts(1).Level == NewContour.Level
                % Find nearest contour part with distance calulated along the border
                LengthBorderContourParts = length(BorderContourParts);
                MinDAlongBorder = Inf;
                j = 1;
                while j <= LengthBorderContourParts && NewContour.Level == BorderContourParts(j).Level
                    [DistAlongBorder(1),CornerPoints(1).Points] = DistanceAlongBorder(NewContour.Points(1,:),BorderContourParts(j).Points(1,:),Border,d);
                    [DistAlongBorder(2),CornerPoints(2).Points] = DistanceAlongBorder(NewContour.Points(1,:),BorderContourParts(j).Points(end,:),Border,d);
                    [DistAlongBorder(3),CornerPoints(3).Points] = DistanceAlongBorder(NewContour.Points(end,:),BorderContourParts(j).Points(1,:),Border,d);
                    [DistAlongBorder(4),CornerPoints(4).Points] = DistanceAlongBorder(NewContour.Points(end,:),BorderContourParts(j).Points(end,:),Border,d);
                    [DAlongBorder,DistAlongBorderCase] = min(DistAlongBorder);
                    if DAlongBorder < MinDAlongBorder
                        MinDAlongBorder = DAlongBorder;
                        MinCornerPoints = CornerPoints(DistAlongBorderCase).Points;
                        MinDalongBorderCase = DistAlongBorderCase;
                        MinDAlongBorderIndex = j;
                    end
                    j = j + 1;
                end
                if MinDAlongBorder < NewContourClosingDistance || BorderOption == 1
                    % Extend NewContour
                    if MinDalongBorderCase == 1
                        NewContour.Points = [flipud(BorderContourParts(MinDAlongBorderIndex).Points);MinCornerPoints;NewContour.Points];
                    end
                    if MinDalongBorderCase == 2
                        NewContour.Points = [BorderContourParts(MinDAlongBorderIndex).Points;MinCornerPoints;NewContour.Points];
                    end
                    if MinDalongBorderCase == 3
                        NewContour.Points = [NewContour.Points;MinCornerPoints;BorderContourParts(MinDAlongBorderIndex).Points];
                    end
                    if MinDalongBorderCase == 4
                        NewContour.Points = [NewContour.Points;MinCornerPoints;flipud(BorderContourParts(MinDAlongBorderIndex).Points)];
                    end
                    [NewContourClosingDistance,NewContourClosingCornerPoints] = DistanceAlongBorder(NewContour.Points(1,:),NewContour.Points(end,:),Border,d);
                    BorderContourParts(MinDAlongBorderIndex) = [];
%                    i = 1;
                else
                    % Close NewContour along Border
                    NewContour.Points = [NewContour.Points;NewContourClosingCornerPoints;NewContour.Points(1,:)];
                    % Put NewContour in the ContourStructure
                    ContourStructure(end+1).Points = NewContour.Points;
                    ContourStructure(end).Level = NewContour.Level;
                    % Reset NewContour
                    NewContour = struct([]);
                end
            else 
            % All contour parts with the same level have been checked
            % Close NewContour along Border 
                NewContour.Points = [NewContour.Points;NewContourClosingCornerPoints;NewContour.Points(1,:)];
                % Put NewContour in the ContourStructure
                ContourStructure(end+1).Points = NewContour.Points;
                ContourStructure(end).Level = NewContour.Level;
                % Reset NewContour
                NewContour = struct([]);
            end
        end
         % Close last NewContour along the border
        if ~isempty(NewContour)
            [NewContourClosingDistance,NewContourClosingCornerPoints] = DistanceAlongBorder(NewContour.Points(1,:),NewContour.Points(end,:),Border,d);
            NewContour.Points = [NewContour.Points;NewContourClosingCornerPoints;NewContour.Points(1,:)];
            % Put NewContour in the ContourStructure
            ContourStructure(end+1).Points = NewContour.Points;
            ContourStructure(end).Level = NewContour.Level;
        end
    end    
end

ContourStructure = SortContours(ContourStructure);

%------------------------------------------------------------------------------------------------------------------

function ContourMatrix = BuildContourMatrix(ContourStructure)

% BuildContourMatrix
%
% Deze functie heeft als input ContourStructure en zet deze om naar het formaat van de eerder ingelezen matrix C.
%
% ---------------------------------
% versie 1.0: 	21/09/2009 geschreven door Edwin Bloem (NLR).
%		Ontwikkeld in Matlab R2008b
%
% ---------------------------------

k = 0;
for i = 1:length(ContourStructure)
    k = k + size(ContourStructure(i).Points,1);
end

ContourMatrix = zeros(k,4);

k = 1;
for i = 1:length(ContourStructure)
    L = size(ContourStructure(i).Points,1);
    ContourMatrix(k:k+L-1,:) = [(1:1:L)',ContourStructure(i).Points,ContourStructure(i).Level*ones(L,1)];
    k = k + L;
end

%------------------------------------------------------------------------------------------------------------------

function SortedContoursStructure = SortContours(ContoursStructure)

% SortContours
%
%
% ---------------------------------
% versie 1.0: 	21/09/2009 geschreven door Edwin Bloem (NLR).
%		Ontwikkeld in Matlab R2008b
%
% ---------------------------------

[SortedLevels, Ind] = sort([ContoursStructure.Level]);

SortedContoursStructure = ContoursStructure(Ind);

%------------------------------------------------------------------------------------------------------------------
