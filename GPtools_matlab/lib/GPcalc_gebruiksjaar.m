function [JaarInfo] = GPcalc_gebruiksjaar(Jaar)
% Bereken de start- en einddatum en het aantal dagen van de seizoenen in het gebruiksjaar
%
% Input
%    Jaar      Gebruiksjaar (numerieke waarde)
%
% Output
%    JaarInfo  Struct met info per seizoen
%
% geldig tussen 1900 en 2099

JaarInfo.jaar = Jaar;

% zomer
JaarInfo.zomer.begin  = StartSeizoen('zomer',  Jaar);
JaarInfo.zomer.eind   = StartSeizoen('winter', Jaar) - 1;  % 1 dag eerder

% winter
JaarInfo.winter.begin = StartSeizoen('winter', Jaar - 1);  % vorig jaar
JaarInfo.winter.eind  = JaarInfo.zomer.begin - 1;          % 1 dag eerder

% aantal dagen/weken
JaarInfo.winter.dagen = JaarInfo.winter.eind - JaarInfo.winter.begin + 1;
JaarInfo.zomer.dagen  = JaarInfo.zomer.eind - JaarInfo.zomer.begin + 1; 
JaarInfo.winter.weken = JaarInfo.winter.dagen / 7;
JaarInfo.zomer.weken  = JaarInfo.zomer.dagen  / 7;

% info naar het scherm
fprintf('\n\n');

fprintf('Gebruiksjaar: %4.0f\n\n', Jaar);
fprintf('seizoen         begin         eind    dagen    weken\n');
fprintf('-------- ------------ ------------ -------- --------\n');

fprintf('%-8s ','winter');
fprintf('%12s ', datestr(JaarInfo.winter.begin, 'dd-mm-yyyy'));
fprintf('%12s ', datestr(JaarInfo.winter.eind, 'dd-mm-yyyy'));
fprintf('%8.0f ', JaarInfo.winter.dagen);
fprintf('%8.0f\n', JaarInfo.winter.weken);

fprintf('%-8s ','zomer');
fprintf('%12s ', datestr(JaarInfo.zomer.begin, 'dd-mm-yyyy'));
fprintf('%12s ', datestr(JaarInfo.zomer.eind, 'dd-mm-yyyy'));
fprintf('%8.0f ', JaarInfo.zomer.dagen);
fprintf('%8.0f\n', JaarInfo.zomer.weken);
fprintf('-------- ------------ ------------ -------- --------\n');
