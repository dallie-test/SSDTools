
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