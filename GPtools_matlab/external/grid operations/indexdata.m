%indexdata categorizes a large data file spread over a grid, laying the
%foundation for a faster calculation speed in upcoming procedures.
%(currently not used by ENCIRO, but it can be a usefull file to generate a
%new woningen.mat and huizen.mat)
%
% Created by: Ramon van Schaik
% Created for: Schiphol Group A/CAP/EC
% Date: 2010  Last update: 2010
% File name: indexdata.m
%
% Input:
%
% Output:
% - N = matrix with number of entities per network square
% - Nentries = matrix with number of entries per network square
% - output = database of entries

%let op! in alle gevallen dient het punt (1,1) toegewezen te worden aan het
%meest zuidwestelijke punt. In de matrix komt dit dus linksboven te staan,
%dit kan verwarrend zijn!

%% initialisatie gegevens
k = 4; %<INPUT> % factor, should coincide with the factor used in 'verfijn'
A = 'D:\Documents and Settings\Schaik_R\Desktop\OCdata\personenbestand.txt'; %<INPUT>

%grid dimensions, deze dimensies komen uit de geluidsgrids. Er is dus
%wellicht meer data aanwezig in het databestand maar deze wordt derhalve
%als irrelevant beschouwd
xlow = 84000;
xstep = 500;
xn = 142;
xnn = xn*k; %aantal stappen na verfijning
xhigh = xlow + xstep*xn;
xtstep = xstep / k;
ylow = 455000;
ystep = 500;
yn = 142;
ynn = yn*k;
yhigh = ylow + ystep*yn;
ytstep = ystep / k;

for i=1:xnn
    for j=1:ynn
        output{i}{j} = [];
    end
end

N = zeros(ynn,xnn);
Nentries = zeros(ynn,xnn);

%% initialiseer bestand
disp('begin bestandsinitialisatie');
fid=fopen(A,'rt');
out=textscan(fid,'%f%f%f', 'delimiter', ':');
fclose(fid);
data = cell2mat(out(1));
x = cell2mat(out(2));
y = cell2mat(out(3));
disp('einde bestandsinitialisatie, begin indexatie');

%% Indexeren entries en bijhouden totalen

for i=1:length(data)
    if (xlow<x(i)) && (x(i)<xhigh) && (ylow<y(i)) && (y(i)<yhigh) %irrelevante data filteren
        xvak = ceil((x(i)-xlow)/(xhigh-xlow)*xnn); %div bestaat niet in matlab
        yvak = ceil((y(i)-ylow)/(yhigh-ylow)*ynn);
        output{yvak}{xvak} = [output{yvak}{xvak};[data(i) x(i) y(i)]]; %getransponeerd als fix om de data juist te krijgen
        N(yvak,xvak)=N(yvak,xvak)+data(i);
        Nentries(yvak,xvak) = Nentries(yvak,xvak)+1;
    end
    
    if i==floor(i/250000)*250000
        disp([num2str(i/length(data)*100) '%']);
    end
end


%% testspace
%indexdata = [data x y];

