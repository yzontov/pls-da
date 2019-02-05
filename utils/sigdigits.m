function n = sigdigits(x)
% SIGDIGITS returns number of significant digits after decimal point in a decimal fraction.
% Is used to generate SPRINTF parameter string
if( ~isnumeric(x) || ~isfinite(x) || isa(x,'uint64') )
    error('Need any finite numeric type except uint64');
end

str = sprintf('%f', x);
n = find(str(3:end) ~= '0', 1, 'last' );

end