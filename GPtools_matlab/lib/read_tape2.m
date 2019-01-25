function [tape2c]=read_tape2(Tape2_file, Xonder, Yonder)
% Lees een tape2 bestand

% Input
%   Tape2_file     In te lezen tape2-bestand 
%   Xonder         Xonder van het grid (optioneel)
%   Yonder         Yonder van het grid (optioneel)
%
% Output
%    tape2c        contourpuntenmatrix in dezelfde vorm als die van contourc


    % Defaults
    if (nargin==1)
        Xonder = 0;
        Yonder = 0;
    end

    % Lees de file
    dat = importdata(Tape2_file);
    
    % Loop langs de (sub-)contouren
    index = find(dat(:,1)==1);                 % sub-contouren
    n     = [dat(index(2:end)-1); dat(end,1)]; % aantal contourpunten
    
    tape2c = [];
    i = 1;
    while i <= length(index)
        dBi = dat(index(i),4);                 % contour dB(A)-waarde
        ni = n(i);                             % aantal contourpunten
        
                                               % de coordinaten
        x = dat(index(i):index(i)+ni-1,2) + Xonder;
        y = dat(index(i):index(i)+ni-1,3) + Yonder;
        
% ///// fix voor contour.exe        
        % check of de contour gesloten is
        isopen = max(abs(x(1) - x(end)), abs(y(1) - y(end))) > 5;
        if isopen
            disp(['Warning, contour ', num2str(dBi), ' is niet gesloten (read_tape2.m)'])
            
            % Misschien aansluitend aan de volgende contour?
            if dBi == dat(index(i+1),4);
                n2 = n(i+1);
                x2 = flipud(dat(index(i+1):index(i+1)+n2-1,2) + Xonder);
                y2 = flipud(dat(index(i+1):index(i+1)+n2-1,3) + Yonder);
                
                if max(abs(x(1) - x2(end)), abs(y(1) - y2(end))) < 5;
                    disp('     ... toepassen tape2-fix')
                    ni = ni + n2;
                    x = [x; x2];
                    y = [y; y2];
                    i = i + 1;
                elseif  max(abs(x2(1) - x(end)), abs(y2(1) - y(end))) < 5
                    disp('     ... toepassen tape2-fix')
                    ni = ni + n2;
                    x = [x2; x];
                    y = [y2; y];
                    i = i + 1;                    
                end
            end
        end
% \\\\\ fix voor contour.exe

        tape2c = [tape2c, [dBi,ni]' [x, y]'];
        
        i = i + 1;
    end    