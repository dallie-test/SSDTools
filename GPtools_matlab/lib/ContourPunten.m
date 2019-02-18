function [XY] = ContourPunten(Grid, dB, Methode, Tape2File)
% Bereken contourpunten
%
% input
%  Grid        Grid struct, zie read_envira
%  dB          Array met contourwaarden
%  Methode     (Optioneel) Het contouralgoritme: matlab of tape2
%  Tape2File   (Optioneel) Filename Tape2file, alleen in combinatie
%                          met methode tape2
%
% output
%  XY          Array met per contourwaarde de coordinaten: [dB, n; XY{dBi:dBn}]

    % Default methode
    if (nargin==2)
        Methode = 'matlab';
    end
    
    % TODO: Gebruik persistent variabele voor het bewaren van voorgaande
    % resultaten
    %
    % tf = isequal(A, B, ...)

    if strcmp(Methode, 'matlab')
        % Info uit de header
        Xonder = Grid.hdr.Xonder;
        Yonder = Grid.hdr.Yonder;

        % Verfijn grid
        grd = verfijn(Grid.dat, 4);

        Xvector = Xonder+(0:size(grd,2)-1).*125;
        Yvector = Yonder+(size(grd,1)-1:-1:0).*125;

        % Forceer sluitende contouren
        grd(1:end,1)   = -99;
        grd(1:end,end) = -99;
        grd(1,  1:end) = -99;
        grd(end,1:end) = -99;

        if length(dB) == 1
            contouren = contourc(Xvector, Yvector, grd, [dB, dB]);
        else
            contouren = contourc(Xvector, Yvector, grd, dB);
        end
    elseif (strcmp(Methode, 'tape2'))
        write_enviraformat('grid.dat', Grid);
        
        % Maak tape2 en lees vervolgens het bestand     
        geluidstellingen('grid.dat', dB, '', [0,0,0,0], '', 'tape2.temp');
        contouren = read_tape2([pwd '\tape2.temp'], Grid.hdr.Xonder, Grid.hdr.Yonder);
        
        % Opruimen tijdelijke bestanden
        if(nargin == 4)
            movefile('tape2.temp', Tape2File);
            % Maak een header file (voor To70)
            Grid.hdr.tekst = {Tape2File, '', ''};
            write_tape2_hdr(Grid.hdr, dB, [Tape2File '_hdr']);
        else
            delete('tape2.temp')
        end
        delete('grid.dat')
    else
        disp('ContourPunten: Onbekende methode')
    end
    
    % Maak Contour struct   
    XY = cell(length(dB),1);
    
    i = 1;
    while i <= length(contouren)
        contour_dBA = contouren(1,i);       % contourwaarde
        n = contouren(2,i);                 % aantal punten
        
        c = (dB == contour_dBA);
        XY{c} = [XY{c} contouren(:,i:i+n)]; % deze sub-contour

        i = i+n+1;
    end
    
