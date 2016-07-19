% Test Gaussian noise generator

% Copyright (C) 2014, Guangxi Liu <guangxi.liu@opencores.org>
%
% This source file may be used and distributed without restriction provided
% that this copyright statement is not removed from the file and that any
% derivative work contains the original copyright notice and the associated
% disclaimer.
%
% This source file is free software; you can redistribute it and/or modify it
% under the terms of the GNU Lesser General Public License as published by
% the Free Software Foundation; either version 2.1 of the License,
% or (at your option) any later version.
%
% This source is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
% or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public
% License for more details.
%
% You should have received a copy of the GNU Lesser General Public License
% along with this source; if not, download it from
% http://www.opencores.org/lgpl.shtml


clc;    clear;

tic;

N = 1000000;
%N = 1000;
Seed = 1;

z = seed_gen(1);
display(z);
r1 = tausworthe_gen(z, N);
r1_32 = typecast(r1,'uint32');
%display(dec2hex(r1(1)));
%display(dec2hex(r1_32(1)));
Seed = 34562;
z = seed_gen(2);
r2 = tausworthe_gen(z, N);

r2_32 = typecast(r2,'uint32');
r2_16 = bitand(r2_32,65535);

%display(dec2hex(r2_32(10)));
%display(dec2hex(r2_16(10)));

r4 = bitand(r2_32,4294901760);
r5 = uint64(bitshift(r4,-16));
r1_64 = uint64(r1_32);
r6 = r1_64*(2^16);
u0 = bitor(r6,r5);
%{
display(dec2hex(r1_64(10)));
display(dec2hex(r6(10)));
display(dec2hex(r5(10)));
display(dec2hex(u1(10)));
bytepack = uint64(r1_32);
%display(dec2bin(bytepack(10)));
bytepack = bitsll(r1_32,fi(16));
%display(dec2bin(bytepack(10)));

r6 = bitor(uint64(bytepack),uint64(r5));

%display(dec2hex(r2_32(10)));
%display(dec2hex(r4(10)));
%display(dec2hex(r5(10)));
%display(dec2hex(r1_32(10)));
%display(dec2hex(bytepack(10)));
%display(dec2hex(r6(10)));
%}
%conversion from binary to decimal
for k = 1 : N
    Fr_dec(k) = 0;
    Fr_bin = dec2bin(u0(k),48);
    for i = 1 : 48    % Note that the 1st char is the decimal dot !
        %display(Fr_bin);
        Fr_dec(k) = Fr_dec(k) + 2^(-i) * str2num( Fr_bin(i) ) ;   
    end
end
    
e = -2*log(Fr_dec);
for k = 1 : N
    
    Fr_dec(k) = 0;
    Fr_bin = dec2bin(r2_16(k),16);
    for i = 1 : 16    % Note that the 1st char is the decimal dot !
        %display(Fr_bin);
        Fr_dec(k) = Fr_dec(k) + 2^(-i) * str2num( Fr_bin(i) ) ;   
    end 
end

g0 = sin(2*pi*Fr_dec);
g1 = cos(2*pi*Fr_dec);
f = sqrt(e);
for n = 1:N
    x0(n) = f(n)*g0(n);
    x1(n) = f(n)*g1(n);
end

display(typecast(r6(10),'double'));
display(typecast(r2(10),'double'));

%val1 = sqrt(-2 * log(double(r6))) .* sin(2 * pi * double(r2_16));
%val2 = sqrt(-2 * log(double(r6))) .* cos(2 * pi * double(r2_16));
%hist([val1,val2], N);
%h = kstest2(x0,x1);
%display(h);
%norm = normpdf(x1,0,1);
%display(r1_32);
%display(r2_32(20));
%display(r2_16(20));
hist([x0,x1], N);

toc;

