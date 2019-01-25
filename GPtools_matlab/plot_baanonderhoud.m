% debug
dbstop if error

%extern
addpath('lib')
addpath('external\SVG')

% Scenario's
Scenario.Name = {
    'GP2017'
    'Onderhoud Kaagbaan'   
                 };
% directories
svgt_dir       = [pwd '\sjablonen\'];
out_dir        = [pwd '\..\results\Hybride US0624\svg\'];

%% baangebruik - etmaal
period      = 'D|E|N';
aantal_rwys = 7;
sjabloon    = [svgt_dir 'MER_FigBaangebruik2.svgt'];

for s=1:numel(Scenario.Name)
    scenario     = Scenario.Name{s};
    scenario_dir = [scenario '\'];
    prognose_dir   = [pwd '\..\prognose\Verschil traffic\' scenario_dir];
    
    traffic{s} = [prognose_dir 'traffic 1971-2015 - years.txt'];
    
    if s > 1
        % Tov ongestoord
        output_file = [out_dir Scenario.Name{1} '_' scenario ' baangebruik etmaal.svg'];
        GPfig_baangebruik(traffic([1,s]), period, aantal_rwys, sjabloon, output_file);
        
        if s > 2
            % Tov regulier onderhoud
            output_file = [out_dir Scenario.Name{1} '_' scenario 'a baangebruik etmaal.svg'];
            GPfig_baangebruik(traffic([2,s]), period, aantal_rwys, sjabloon, output_file);
        end
    end
%     all_dat = [all_dat; dat];
    
end

period      = 'N';
aantal_rwys = 7;
sjabloon    = [svgt_dir 'MER_FigBaangebruik2_nacht.svgt'];

for s=1:numel(Scenario.Name)
    scenario     = Scenario.Name{s};
    scenario_dir = [scenario '\'];
    prognose_dir   = [pwd '\..\prognose\Verschil traffic\' scenario_dir];
    
    traffic{s} = [prognose_dir 'traffic 1971-2015 - years.txt'];
    
    if s > 1
        % Tov ongestoord
        output_file = [out_dir Scenario.Name{1} '_' scenario ' baangebruik nacht.svg'];
        GPfig_baangebruik(traffic([1,s]), period, aantal_rwys, sjabloon, output_file);
        
        if s > 2
            % Tov regulier onderhoud
            output_file = [out_dir Scenario.Name{1} '_' scenario 'a baangebruik nacht.svg'];
            GPfig_baangebruik(traffic([2,s]), period, aantal_rwys, sjabloon, output_file);
        end
    end
%     all_dat = [all_dat; dat];
    
end

return;

% %% baangebruik - etmaal
% period      = 'D|E|N';
% aantal_rwys = 7;
% sjabloon    = [svgt_dir 'MER_FigBaangebruik_GO.svgt'];
% output_file = [out_dir 'GP2017 vs Baanonderhoud Kaagbaan etmaal.svg'];
% 
% GPfig_baangebruik(traffic, period, aantal_rwys, sjabloon, output_file);
% 
% %% baangebruik - nacht
% period      = 'N';
% aantal_rwys = 7;
% sjabloon    = [svgt_dir 'MER_FigBaangebruik_15k_GO.svgt'];
% output_file = [out_dir 'GP2017 vs Baanonderhoud Kaagbaan nacht.svg'];
% 
% GPfig_baangebruik(traffic, period, aantal_rwys, sjabloon, output_file);
% 
% %% Klaar
% toc;