function [SVG] = graph2svg(Plot, SVGtag)
% Maak een plot op basis van het opgegeven sjabloon
%
% Input
%   SVGtag             Text uit het SVG sjabloon van de te plotten contouren
%
% Output
%   SVG                Te maken SVG-bestand

% Conversie van numerieke velden
NumFields = {'width', 'height','radius', 'angle', 'dB', 'range', 'gap', 'label_offset','label_xoffset','label_yoffset', 'label_rotation', 'decimals', 'bar_width', 'bin_size', 'size', 'grid_lines'};
s=ParseTag(SVGtag, NumFields);

% Optionele velden
if ~isfield(s, 'label_rotation')
    s.label_rotation = 0;
end

% -------------------------------------------------------------------------
% plot_area
if strcmp(s.object, 'plot_area')
  %achtergrond
  p =    sprintf('\t\t<!-- Plot-area -->\n');
  if strcmp(s.type, 'circle')
    p = [p sprintf('\t\t<circle cx="%06.2f" cy="%06.2f" r="%06.2f" style="%s" />',s.radius,s.radius,s.radius,s.fill_style)];
  else
    p = [p sprintf('\t\t<rect width="%06.2f" height="%06.2f" x="0.0" y="0.0" style="%s" />',s.width,s.height,s.fill_style)];
  end
end

% -------------------------------------------------------------------------
% x_axis/y_axis  
if sum(strcmp(s.object, {'x_axis' 'y_axis'}))

    %bereken positie van de as/labels
    if strcmp(s.type, 'categories')
        % min = 0;
        % max = length(Plot.(s.values));
        
        nd  = length(Plot.(s.values));        % aantal labels
        fxd = (0.5:1:nd-0.5)/nd;              % label positie op de as
        
        if isfield(s, 'grid_lines')           
            ng  = length(s.grid_lines) + 2;   % aantal gridlines (inclusief de randen)
            fxg = [0, s.grid_lines, 1];       % positie van de gridlines (waarden tussen 0 en 1)
        else
            ng  = nd + 1;   
            fxg = (0:1:nd)/nd;
        end      
    else
        % Bereik van de as
        xmin   = s.range(1);
        xmax   = s.range(end);

        %TODO check voor ng = 0
        nd  = length(s.range);                % aantal labels
        if strcmp(s.type, 'log')
            fxd = (log10(s.range) - log10(xmin))/(log10(xmax) - log10(xmin)); % label positie op de as
        else
            fxd = (s.range - xmin)/(xmax - xmin); % label positie op de as
        end
        
        if isfield(s, 'grid_lines')           
            ng  = length(s.grid_lines) +2;    % aantal gridlines (inclusief de randen)
            if strcmp(s.type, 'log')
                fxg = (log10(s.grid_lines) - log10(xmin))/(log10(xmax) - log10(xmin));  
            else
                fxg = (s.grid_lines - xmin)/(xmax - xmin);
            end
            fxg = [0, fxg, 1];                % waarden tussen 0 en 1
        else
            ng  = nd;  
            fxg = fxd;                        
        end
        
        if strcmp(s.type, 'categories')
            fxd = log10(fxd);
            fxg = log10(fxg);
        end
    end
    
    %gridlines binnen het plotframe tekenen
    if strcmp(Plot.(s.id).plot_area.frame_style, 'none')
        frame_stroke_width = 0;
    else
        frame_style = ParseTag(Plot.(s.id).plot_area.frame_style, 'stroke_width');
        if isfield(frame_style, 'stroke_width')
            frame_stroke_width = frame_style.stroke_width;
        else
            frame_stroke_width = 0;
        end
    end

    if ~strcmp(s.type, 'polar')
        switch s.position
            case 'left'
                x1(1:ng) = 0;
                x2(1:ng) = Plot.(s.id).plot_area.width;
                y1       = Plot.(s.id).plot_area.height * (1-fxg);
                y2       = y1;
                dx_frame = frame_stroke_width;
                dy_frame = 0;

                xd(1:nd) = 0 + s.label_offset;
                yd       = Plot.(s.id).plot_area.height * (1-fxd); 
            case 'right'
                x1(1:ng) = 0;
                x2(1:ng) = Plot.(s.id).plot_area.width;
                y1       = Plot.(s.id).plot_area.height * (1-fxg);
                y2       = y1;
                dx_frame = frame_stroke_width;
                dy_frame = 0;

                xd(1:nd) = Plot.(s.id).plot_area.width + s.label_offset;
                yd       = Plot.(s.id).plot_area.height * (1-fxd);
            case 'top'
                x1       = Plot.(s.id).plot_area.width * fxg;
                x2       = x1;
                y1(1:ng) = 0;
                y2(1:ng) = Plot.(s.id).plot_area.height;
                dx_frame = 0;
                dy_frame = frame_stroke_width;

                xd       = Plot.(s.id).plot_area.width  * fxd;
                yd(1:nd) = 0 + s.label_offset;
            case 'bottom'
                x1       = Plot.(s.id).plot_area.width * fxg;
                x2       = x1;
                y1(1:ng) = Plot.(s.id).plot_area.height;
                y2(1:ng) = 0;
                dx_frame = 0;
                dy_frame = frame_stroke_width;

                xd       = Plot.(s.id).plot_area.width  * fxd;
                yd(1:nd) = Plot.(s.id).plot_area.height + s.label_offset;     
        end
    else
        % polair figuur
        if isfield(s, 'gap')
            gap = s.gap;
        else
            gap = 0;
        end
        
        x1(1:ng) = Plot.(s.id).plot_area.radius;
        y1       = (Plot.(s.id).plot_area.radius - gap) * (1-fxg);
        dx_frame = frame_stroke_width;
        dy_frame = 0;

        xd(1:nd) = Plot.(s.id).plot_area.radius + s.label_offset;
        yd       = (Plot.(s.id).plot_area.radius - gap) * (1-fxd); 

        rg = gap + (Plot.(s.id).plot_area.radius - gap) * fxg;
end
    
    p = '';
    %grid lines
    if ~strcmp(s.grid_style, 'none') % fix voor svg2pdf; "stroke:none" gaat niet altijd goed
        p = [p sprintf('\t\t<!-- Grid-lines -->\n')];
        p = [p sprintf('\t\t<g style="fill:none;%s">\n',s.grid_style)];
        
        if strcmp(s.type, 'polar')
            p = [p sprintf('\t\t\t<g transform="translate(%06.2f %06.2f)">\n', Plot.(s.id).plot_area.radius, Plot.(s.id).plot_area.radius)];
            if strcmp(s.object, 'x_axis')
                for i=1:ng-1 %(eerste en laatste zijn identiek)
                    p = [p sprintf('\t\t\t\t<line transform="rotate(%05.1f)" x1="0" x2="0" y1="-%06.2f" y2="0"/>\n', s.range(i),  Plot.(s.id).plot_area.radius)];
                end
            else
                p = [p sprintf('\t\t\t\t<circle cx="0" cy="0" r="%06.2f" />\n', rg)];
            end
            p = [p sprintf('\t\t\t</g>\n')];
        else
            for i=2:ng-1 %(eerste en laatste niet plotten)
                p = [p sprintf('\t\t\t<line x1="%06.2f" x2="%06.2f" y1="%06.2f" y2="%06.2f"/>\n', x1(i)+dx_frame, x2(i)-dx_frame, y1(i)+dy_frame, y2(i)-dy_frame)];
            end
        end
        p = [p sprintf('\t\t</g>\n\n')];
    end
    
    %kader
    p = [p sprintf('\t\t<!-- Plot-area-frame -->\n')];
    if strcmp(Plot.(s.id).plot_area.type, 'circle')
        p = [p sprintf('\t\t<circle cx="%06.2f" cy="%06.2f" r="%06.2f" style="fill:none;%s" />\n\n',Plot.(s.id).plot_area.radius, ...
                                                                                                    Plot.(s.id).plot_area.radius, ...
                                                                                                    Plot.(s.id).plot_area.radius, ...
                                                                                                    Plot.(s.id).plot_area.frame_style)];
    else
        p = [p sprintf('\t\t<rect width="%06.2f" height="%06.2f" x="0.0" y="0.0" style="fill:none;%s" />\n\n',Plot.(s.id).plot_area.width, ...
                                                                                                              Plot.(s.id).plot_area.height, ...
                                                                                                              Plot.(s.id).plot_area.frame_style)];
    end

    % as onder een hoek?
    if strcmp(s.type, 'polar') && isfield(s, 'angle')
            angle = s.angle;
            x0 = Plot.(s.id).plot_area.radius;
            y0 = Plot.(s.id).plot_area.radius;
    else
        angle = 0;
        x0 = 0;
        y0 = 0;
    end
    p = [p sprintf('\t\t<!-- %s -->\n', s.object)];
    p = [p sprintf('\t\t<g transform="rotate(%03.0f, %03.0f, %03.0f)">\n', angle, x0, y0)];
    
    % teken de as
    p = [p sprintf('\t\t\t<line x1="%06.2f" x2="%06.2f" y1="%06.2f" y2="%06.2f" style="%s"/>\n\n',x1(1), x1(end), y1(1), y1(end), s.line_style)];

    %labels
    p = [p sprintf('\t\t\t<!-- labels -->\n')];
    p = [p sprintf('\t\t\t<g style="%s">\n',s.label_style)];

    %fontsize
    label_style = ParseTag(s.label_style);
    if isfield(label_style, 'font_size')
        font_size = str2double(regexp(label_style.font_size, '^[0-9.]*', 'match'));
        if strcmp(label_style.font_size(end-1:end), 'pt') % omrekenen naar 'px'
            font_size = font_size * 1.25;
        end
    else
        font_size = 10;
    end
    if strcmp(s.type, 'polar')
        n1 = 2;
    else
        n1 = 1;
    end
    for i=n1:nd
        if strcmp(s.type, 'categories')
            label = Plot.(s.values){i};
        else
            label = [Duizendtallen(s.range(i), s.decimals, s.decimal_sign, s.thousands_seperator), s.label_postfix];
        end
        p = [p sprintf('\t\t\t\t<g transform="translate(%06.2f,%06.2f) rotate(%03.0f)"><text x="0" y="%06.2f">%s</text></g>\n',xd(i), yd(i), s.label_rotation, font_size*.27, label)]; 
    end
    p = [p sprintf('\t\t\t</g>\n')];
    p = [p sprintf('\t\t</g>')];
end

% -------------------------------------------------------------------------
% bar plot
if strfind(s.object, 'bar_plot') == 1
    
    % Bereik van de Y-as
    y1   = Plot.(s.id).y_axis.range(1);                 % eerste punt
    yref = Plot.(s.id).y_axis.range(end);               % laatste punt is het referentiepunt in de svg
    ymin = min(Plot.(s.id).y_axis.range);               % minimumwaarde y-as
    ydir = y1 ~= ymin;                                  % aflopende y-as?

    nx   = size(Plot.(s.values),2);                     % aantal categorieen
    fx = (0.5:1:nx-0.5)/nx;                             % positie op de categorie x-as

    if strcmp(s.type, 'hilo')
        nbar    = 2;                                    % twee staafjes maar... 
        nbar1   = 2;                                    %                      alleen de tweede plotten
        values  = [Plot.(s.values);
                   Plot.(s.values2) - Plot.(s.values)]; % maximum relatief t.o.v. de minimumwaarde
    else
        nbar    = size(Plot.(s.values),1);              % aantal te stapelen staafjes
        nbar1   = 1;
        values  = Plot.(s.values);
    end
     
    fh  = (values - ymin)./abs(yref - y1);              % hoogte van de staaf
    fy  = (yref - cumsum(values,1))./(yref - y1);       % stapelhoogte (top)
    
    %maak afmetingen gelijk aan fh
    fx = repmat(fx,          nbar,  1);   % bug in R2006a????
    w  = repmat(s.bar_width, nbar, nx);

    switch Plot.(s.id).y_axis.position
        case {'bottom', 'top'}
            x = Plot.(s.id).plot_area.width  * (1-fy);
            y = Plot.(s.id).plot_area.height * (1-fx);
            h = Plot.(s.id).plot_area.width  * fh;
            rotate = 90 - ydir * 180;
            
        case {'left', 'right'}
            x = Plot.(s.id).plot_area.width  * fx;
            y = Plot.(s.id).plot_area.height * fy;
            h = Plot.(s.id).plot_area.height * fh;
            rotate = ydir * 180;
    end
    
    xd = x + s.label_xoffset;
    yd = y + s.label_yoffset;
    
    p = sprintf('\t\t<!-- bar_plot -->\n');
    for i=nbar1:nbar
        [Scol Stransp] = SVGrgb(s.stroke, i);
        [Fcol Ftransp] = SVGrgb(s.fill,   i);
        
        p = [p sprintf('\t\t<g style="%s;stroke:%s;fill:%s;stroke-opacity:%4.2f;fill-opacity:%4.2f">\n', s.style, Scol, Fcol, Stransp, Ftransp)];
        
        for j=1:nx
            p = [p sprintf('\t\t\t<g transform="translate(%06.2f,%06.2f) rotate(%1.0f)"> <rect x="%06.2f"  y= "0" width="%06.2f" height="%06.2f"/> </g>\n',x(i,j), y(i,j), rotate, -w(i,j)/2, w(i,j), h(i,j))];
        end
        p = [p sprintf('\t\t</g>\n')];
    end
    p = [p sprintf('\n')];

    %data labels
    p = [p sprintf('\t\t<!-- data labels -->\n')];
    
    %fontsize
    label_style = ParseTag(s.label_style);
    if isfield(label_style, 'font_size')
        font_size = str2double(regexp(label_style.font_size, '^[0-9.]*', 'match'));
        if strcmp(label_style.font_size(end-1:end), 'pt') % omrekenen naar 'px'
            font_size = font_size * 1.25;
        end
    else
        font_size = 10;
    end
    
    for i=1:nbar
        p = [p sprintf('\t\t<g style="%s">\n',s.label_style)];

        for j=1:nx
            label = [Duizendtallen(values(i,j), s.decimals, s.decimal_sign, s.thousands_seperator), s.label_postfix];
            p = [p sprintf('\t\t\t<g transform="translate(%06.2f,%06.2f) rotate(%03.0f)"><text x="0" y="%06.2f">%s</text></g>\n',xd(i,j), yd(i,j), s.label_rotation, font_size*.27, label)]; 
        end
        p = [p sprintf('\t\t</g>\n')];
    end

end

% -------------------------------------------------------------------------
% polar bar plot
% TODO integreren met bar plot?

if strfind(s.object, 'polar_bar_plot')
    
    nx   = size(Plot.(s.values),2);                     % aantal categorieen
    
    % Hoeken
    fa = str2double(Plot.(s.angles));

    % Midden van de plot
    plot_area = Plot.(s.id).plot_area.radius;
    x0 = plot_area;
    y0 = plot_area;
    
    % Gat in het middel van de plot
    if isfield(Plot.(s.id).y_axis, 'gap')
        gap=Plot.(s.id).y_axis.gap;
    else
        gap=0;
    end
    plot_area = plot_area - gap;
    
    % Bereik van de Y-as
    y1   = Plot.(s.id).y_axis.range(1);                 % eerste punt
    yref = Plot.(s.id).y_axis.range(end);               % laatste punt is het referentiepunt in de svg
    ymin = min(Plot.(s.id).y_axis.range);               % minimumwaarde y-as

    nbar    = size(Plot.(s.values),1);                  % aantal te stapelen staafjes
    nbar1   = 1;
    values  = Plot.(s.values);
     
    fh  = (values - ymin)./abs(yref - y1);              % hoogte van de staaf
    fy  = (yref - cumsum(values,1))./(yref - y1);       % stapelhoogte (top)
    
    %maak afmetingen gelijk aan fh
    fa = repmat(fa, 1, nbar)';
    w  = repmat(s.bar_width, nbar, nx);

    x = x0 + plot_area*(1-fy).*sin(fa.*(pi/180));
    y = y0 - plot_area*(1-fy).*cos(fa.*(pi/180));
    h = plot_area * fh;
    rotate = fa;
    
    xd = x + s.label_xoffset;
    yd = y + s.label_yoffset;
  
    p = sprintf('\t\t<!-- polar_bar_plot -->\n');
    for i=nbar1:nbar
        [Scol Stransp] = SVGrgb(s.stroke, i);
        [Fcol Ftransp] = SVGrgb(s.fill,   i);
        
        p = [p sprintf('\t\t<g style="%s;stroke:%s;fill:%s;stroke-opacity:%4.2f;fill-opacity:%4.2f">\n', s.style, Scol, Fcol, Stransp, Ftransp)];
        
        for j=1:nx
            p = [p sprintf('\t\t\t<g transform="translate(%06.2f,%06.2f) rotate(%1.0f)"> <rect x="%06.2f"  y= "%06.2f" width="%06.2f" height="%06.2f"/> </g>\n',x(i,j), y(i,j), rotate(i,j), -w(i,j)/2, -gap, w(i,j), h(i,j))];
        end
        p = [p sprintf('\t\t</g>\n')];
    end
    p = [p sprintf('\n')];
    
%TODO data labels zijn nu 1 op 1 overgenomen van bar_plot
    %data labels
    p = [p sprintf('\t\t<!-- data labels -->\n')];
    
    %fontsize
    label_style = ParseTag(s.label_style);
    if isfield(label_style, 'font_size')
        font_size = str2double(regexp(label_style.font_size, '^[0-9.]*', 'match'));
        if strcmp(label_style.font_size(end-1:end), 'pt') % omrekenen naar 'px'
            font_size = font_size * 1.25;
        end
    else
        font_size = 10;
    end
    
    for i=1:nbar
        p = [p sprintf('\t\t<g style="%s">\n',s.label_style)];

        for j=1:nx
            label = [Duizendtallen(values(i,j), s.decimals, s.decimal_sign, s.thousands_seperator), s.label_postfix];
            p = [p sprintf('\t\t\t<g transform="translate(%06.2f,%06.2f) rotate(%03.0f)"><text x="0" y="%06.2f">%s</text></g>\n',xd(i,j), yd(i,j), s.label_rotation, font_size*.27, label)]; 
        end
        p = [p sprintf('\t\t</g>\n')];
    end

end

% -------------------------------------------------------------------------
% xy plot
if strfind(s.object, 'xy_plot')
    
    %bereken positie van de X-waarden
    if strcmp(Plot.(s.id).x_axis.type, 'categories')
        nx  = length(Plot.(Plot.(s.id).x_axis.values));  % aantal labels
        fx  = (0.5:1:nx-0.5)/nx;                         % X-positie
    else
        Xmin = Plot.(s.id).x_axis.range(1);
        Xmax = Plot.(s.id).x_axis.range(end);
        nx  = length(Plot.(s.x_values));                 % aantal labels
        
        if strcmp(Plot.(s.id).x_axis.type, 'log')
            fx = (log10(Plot.(s.x_values)) - log10(Xmin))/(log10(Xmax) - log10(Xmin)); % X-positie;
        else
            fx = (Plot.(s.x_values) - Xmin)/(Xmax - Xmin); % X-positie
        end
    end
  
    %bereik van de Y-as
    Ymin   = Plot.(s.id).y_axis.range(1);
    Ymax   = Plot.(s.id).y_axis.range(end);
    
    %bereken positie van de Y-waarden en dupliceer X-waarden bij 'hilo' of 'area'
    switch s.type
        case 'hilo'
            values = [Plot.(s.y_values); Plot.(s.y_values2)];           % minimum- en maximumwaarde
            fx     = [fx;                fx];                
        case 'area'
            values = [Plot.(s.y_values2), Plot.(s.y_values)(end:-1:1)]; % maximum- gevolgd door minimumwaarde
            fx     = [fx,                 fx(end:-1:1)];
            nx     = 2*nx;
        otherwise
            values = Plot.(s.y_values);
    end
    
    if strcmp(Plot.(s.id).y_axis.type, 'log')
        fy = (log10(values) - log10(Ymin))./(log10(Ymax) - log10(Ymin));
    else
        fy = (values - Ymin)./(Ymax - Ymin);
    end
        
    switch Plot.(s.id).y_axis.position
        case {'bottom', 'top'}
            x = Plot.(s.id).plot_area.width  * fy;
            y = Plot.(s.id).plot_area.height * (1-fx);
        case {'left', 'right'}
            x = Plot.(s.id).plot_area.width  * fx;
            y = Plot.(s.id).plot_area.height * (1-fy);
    end
    
    % Positie van het data label
    xd = x + s.label_xoffset;
    yd = y + s.label_yoffset;
    
    % Uitvoer naar SVG
    p =    sprintf('\t\t<!-- xy_plot -->\n');
    if strcmp(s.type, 'area')
        p = [p sprintf('\t\t<g style="%s;marker:url(#%s)">\n', s.style, s.marker)];
    else
        p = [p sprintf('\t\t<g style="fill:none;%s;marker:url(#%s)">\n', s.style, s.marker)];
    end
    
    if strcmp(s.type, 'hilo')
        for i=1:nx
            p = [p sprintf('\t\t\t<line x1="%06.2f" y1="%06.2f" x2="%06.2f" y2="%06.2f"/>\n', x(1,i),y(1,i),x(2,i),y(2,i))];
        end
    else
        p = [p sprintf('\t\t<polyline points="')];
        for i=1:nx
            p = [p sprintf('%06.2f,%06.2f ',x(i),y(i))];
        end
        p = [p sprintf('"\n\t\t/>\n')];
    end
    p = [p sprintf('\t\t</g>\n\n')];
    
    %data labels
    p = [p sprintf('\t\t<!-- data labels -->\n')];
    p = [p sprintf('\t\t<g style="%s">\n',s.label_style)];
    
    %fontsize
    label_style = ParseTag(s.label_style);
    if isfield(label_style, 'font_size')
        font_size = str2double(regexp(label_style.font_size, '^[0-9.]*', 'match'));
        if strcmp(label_style.font_size(end-1:end), 'pt') % omrekenen naar 'px'
            font_size = font_size * 1.25;
        end
    else
        font_size = 10;
    end

    for i=1:size(values,1)
        for j=1:size(values,2)
            label = [Duizendtallen(values(i,j), s.decimals, s.decimal_sign, s.thousands_seperator), s.label_postfix];
            p = [p sprintf('\t\t\t<g transform="translate(%06.2f,%06.2f) rotate(%03.0f)"><text x="0" y="%06.2f">%s</text></g>\n',xd(i,j), yd(i,j), s.label_rotation, font_size*.27, label)]; 
        end
    end
    p = [p sprintf('\t\t</g>\n')];

end

% -------------------------------------------------------------------------
% density plot
if strfind(s.object, 'density_plot')
    
    %bereken positie van de X-waarden
    if strcmp(Plot.(s.id).x_axis.type, 'categories')
        nx  = length(Plot.(Plot.(s.id).x_axis.values));  % aantal labels
        fx  = (0.5:1:nx-0.5)/nx;                         % X-positie
    else
        Xmin = Plot.(s.id).x_axis.range(1);
        Xmax = Plot.(s.id).x_axis.range(end);
        nx  = length(Plot.(s.x_values));                 % aantal labels
        fx   = (Plot.(s.x_values) - Xmin)/(Xmax - Xmin); % X-positie
    end
  
    %bereik van de Y-as
    Ymin   = Plot.(s.id).y_axis.range(1);
    Ymax   = Plot.(s.id).y_axis.range(end);
    
    % Bereken positie van de Y-waarden
    fy = (Plot.(s.y_values) - Ymin)./(Ymax - Ymin);
        
    switch Plot.(s.id).y_axis.position
        case {'bottom', 'top'}
            x = Plot.(s.id).plot_area.width  * fy;
            y = Plot.(s.id).plot_area.height * (1-fx);
        case {'left', 'right'}
            x = Plot.(s.id).plot_area.width  * fx;
            y = Plot.(s.id).plot_area.height * (1-fy);
    end
    
    % Afronden; plot geen overlappende punten
    xr = round(x/s.bin_size)*s.bin_size;
    yr = round(y/s.bin_size)*s.bin_size;
    
    % Filter; alleen unieke punten
    key = xr * 1000 + yr;
    [v, f] = unique(key);
    xf = xr(f);
    yf = yr(f);
    nf = numel(xf);
        
    % Imiteer transparantie
    nv = log(histc(key(:),v));
    nv = nv/max(nv);
     
    % sorteer op nv 
    [nv, iv] = sort(nv);
    xf = xf(iv);
    yf = yf(iv);
 
    % Symbol, default een square met de afmetingen van de bin
    if ~isfield(s, 'symbol')
        s.symbol = 'square';
    end
    
    if ~isfield(s, 'size')
        s.size = s.bin_size;
    end
    
    % Uitvoer naar SVG
    p =    sprintf('\t\t<!-- density_plot -->\n');
       
    for i=1:nf
        [Scol, Stransp] = SVGrgb(s.stroke, nv(i));
        [Fcol, Ftransp] = SVGrgb(s.fill,   nv(i));

        p = [p sprintf('\t\t<g style="stroke:%s;fill:%s;stroke-opacity:%4.2f;fill-opacity:%4.2f">\n', Scol, Fcol, Stransp, Ftransp)];
        if strcmp(s.symbol, 'circle') 
            p = [p sprintf('\t\t\t<circle cx="%06.2f" cy="%06.2f" r="%4.2f"/>\n',xf(i),yf(i),s.size/2)];
        elseif strcmp(s.symbol, 'square')
            p = [p sprintf('\t\t\t<rect x="%4.2f" y="%4.2f" width="%4.2f" height="%4.2f"/>\n',xf(i)-s.size/2,yf(i)-s.size/2,s.size,s.size)];
        end
            
        p = [p sprintf('\t\t</g>\n')];
    end
    p = [p sprintf('\n')];

end

SVG = p;
