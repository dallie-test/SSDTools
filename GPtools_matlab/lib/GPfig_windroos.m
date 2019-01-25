function GPfig_windroos(KNMIdata, DagenOfJaren, Sjabloon, OutputFile)
% Maak een figuur, windroos, met windsnelheid, -richting en frequntie
%
% input
%   KNMIdata     zie: ...
%   DagenOfJaren YYYYMMDD: vector met dagen die in de KNMIdata worden geselecteerd
%                YYYYMM:   of een vector met een combinatie van jaar en maand
%                YYYY:     of een vector met kalenderjaren
%   Sjabloon     SVG sjabloon
%   OutputFile   SVG output

%% Inlezen data en selectie van de periode

    % Inlezen data
    knmi = read_knmi(KNMIdata);
   
    % Selectie op basis van dagen of kalenderjaren
    if max(DagenOfJaren) > 999999
        % dit zijn dus dagen in het format YYYYMMDD
        i = ismember(knmi.YYYYMMDD, DagenOfJaren);
    elseif max(DagenOfJaren) > 9999
        % selecteer op maanden: format YYYYMMDD --> YYYYMM
        i = ismember(floor(knmi.YYYYMMDD/100), DagenOfJaren);
    else
        % selecteer op kalenderjaren: format YYYYMMDD --> YYYY
        i = ismember(floor(knmi.YYYYMMDD/10000), DagenOfJaren);
    end
    FF = knmi.FF(i);
    DD = knmi.DD(i);
    samples = length(FF);

%% Conversie en classificatie
    
    % Converteer 0.1 m/s naar knots
    kts = FF * 0.194384449;
    
    % Windsnelheid classificeren
    DD(DD==0) = 990; % windrichting onbepaald
    plot.variable = 100 * sum(DD == 990)/samples;
    
    c = [-inf,5,10,15,20,25,+inf];
    for i = 1:length(c)-1
        class(kts > c(i) & kts <= c(i+1),1) = i;
    end

%% Aggregeren op windrichting
    step=30;
    cdir = step:step:360;
    plot.winddir = cellstr(num2str(cdir(:)));
    for d=1:numel(cdir) % windrichting (0 is windstil)
        if cdir(d) < 360
            index1 = step*round(DD/step) == cdir(d);
        else
            index1 = step*round(DD/step) == cdir(d) | step*round(DD/step) == 0;
        end
        for s = 1:length(c)-1 % windsnelheid in klassen
            index2 = class == s;
            plot.percentage(s,d) = 100 * sum(index1 & index2)/samples;  
        end
    end  

%% Output naar SVG
    plot2svg(plot, Sjabloon, OutputFile);
 
end
