% woningenbestand
bestand = 'To70 - woningen 2015.txt';
output  = 'To70 - woningen 2015.mat';

fid=fopen(bestand,'r');
out=textscan(fid,'%f%f%f', 'delimiter', ':');
fclose(fid);

nw = cell2mat(out(1));
xw = cell2mat(out(2));
yw = cell2mat(out(3));

woningen2015 = [nw xw yw];
save(output, 'woningen2015');

% personenbestand
bestand = 'To70 - personen 2015.txt';
output  = 'To70 - personen 2015.mat';

fid=fopen(bestand,'r');
out=textscan(fid,'%f%f%f', 'delimiter', ':');
fclose(fid);

np = cell2mat(out(1));
xp = cell2mat(out(2));
yp = cell2mat(out(3));

personen2015 = [np xp yp];

save(output, 'personen2015');
