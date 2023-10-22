% UTILS MATLAB utilities and common functions/std for devlopment.
% Version 1.0.0 22-Oct-2023
% 
% Signal Processing functions
%   perf                   - computes RMSE, MSE, and SNR between two signals.
%   db2mag                 - decibel to magnitude (V) conversion.
%   db2pow                 - decibel to power (W) conversion.
%   mag2db                 - magnitude to decibel conversion.
%   pow2db                 - power to decibel conversion.
%   acn                    - additive colored noise with decibel specified contamination.
%   sigplot                - simplified signal plotting convenience function.
%
% Developer functions
%   nav                    - simplified folder navigation function with shortcuts.
%   optparse               - optional arguments parsing with default values. "name=value" language substitute.
%   pkworkspace            - packages a MATLAB workspace into a struct (helpful for debugging hard-to-catch errors.)