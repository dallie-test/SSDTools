%compute value for specific coordinates for a refined grid.
%
% Created by: Wouter Dalmeijer
% Created for: Schiphol Group A/CAP/EC
% Date: 2017  Last update: 2017
% File name: interpoleer_direct.m
%
% Input:
% A         - Matrix of model coefficients from verfijn.m
% Xi, Yi    - Vector inputs for meant for interpolation. Can be individual
%             grid points or outer grid values.
% X, Y      - Vector inputs of outer grid values of the grid to be
%             interpolated
% grid      - switch to indicate if Xi and Yi are grid inputs or vector of
%             individual coordinates. OPTIONS: 'on' or 'off'
% Output:
% interp    - interpolated values, grid or vector

function [interp] = interpoleer_direct(A,Xi,Yi,X,Y,grid)

if strcmp(grid,'on')
    X_test = zeros(length(Xi)*length(Yi),1);
    Y_test = zeros(length(Xi)*length(Yi),1);
    index = 1;
    for ii = 1:length(Xi)
        for jj = 1:length(Yi)
            X_test(index) = Xi(ii);
            Y_test(index) = Yi(jj);
            index = index + 1;
        end
    end
elseif strcmp(grid,'off')
    X_test = Xi;
    Y_test = Yi;
end

% check in which square the datapoint lies, but smartly
Z = zeros(length(X_test),1);
for ll = 1:length(X_test)
    % check x coordinate
    for j = 1:(length(X)-1)
        if X(j) <= X_test(ll) && X_test(ll) < X(j+1)
            x = j;
        end
    end   
    % check y coordinate
    for i = 1:(length(Y)-1)
        if Y(i) <= Y_test(ll) && Y_test(ll) < Y(i+1)
            y = i;
        end
    end
    square  = zeros(1,(length(Y)-1)*(length(X)-1));
    square((y-1)*(length(X)-1)+x) = 1;

    % generate xy matrix
    y_norm = (X_test(ll)-X(x))/(X(x+1)-X(x));
    x_norm = (Y_test(ll)-Y(y))/(Y(y+1)-Y(y));

    bigxy = [1 y_norm y_norm^2 y_norm^3 ...
    x_norm x_norm*y_norm x_norm*y_norm^2 x_norm*y_norm.^3 ...
    x_norm^2 x_norm^2*y_norm x_norm^2*y_norm^2 x_norm^2*y_norm^3 ...
    x_norm^3 x_norm^3*y_norm x_norm^3*y_norm^2 x_norm^3*y_norm^3];

    % pick the right element of A
    A_sorted = A*square';

    % now multiply
    Z(ll) = bigxy*A_sorted;
end

if strcmp(grid,'on')
    % back to grid
    interp = zeros(length(Xi),length(Yi));
    index = 1;
    for ii = 1:length(Xi)
        for jj = 1:length(Yi)
            interp(jj,ii) = Z(index);
            index=index+1;
        end
    end
elseif strcmp(grid,'off')
    interp = Z;
end
