clear
close all

% author : r05229011

% error estimate practice

format long

% problem 1
% if f(x) = (e^x-1)/x with x = 0.00275
% consider 	(a) the decimal format with five significant digits
%			(b) true value and relative error

fprintf ('Problem A\n');
f = @(x) (exp(x) - 1) ./ x;
x = 0.00275;

EstimateValue = roundn (f(x), -5)
TrueValue = f(x)
RelativeError = (EstimateValue - TrueValue) / TrueValue * 100


% problem 2
% calculate the value and estimate the truncation error for cos(x) = the first three terms of Taylor series with x = pi/3
% the estimate of the first three terms of Taylor, format with six significant digits

fprintf ('Problem B\n');
x = pi / 3;

cosx = cos(x)
TaylorCosX = 1 - roundn (x.^2/factorial(2), -6) + roundn (x.^4/factorial (4), -6)
TruncationError = TaylorCosX - cosx
