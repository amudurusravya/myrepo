%cosine function approximation using minimax approach
global c_1;
global c_0;

i=0;
n = 0;
Fr_dec = 0;
for n = 0 : 16384
    display(n);
    for i = 1 : 14    
        Fr_bin = dec2bin(n,14);
        %display(Fr_bin);
        Fr_dec = Fr_dec + 2^(-i) * str2num( Fr_bin(i) ) ;   
    end
    Fraction(n+1) = Fr_dec;
    Fr_dec = 0;
end

%Plot(Fraction);

for n=1:128
    %{  
    %my implementation
    Fr_min = ((n-1)*128)+1;
    Fr_max = n*128;
    x_min = Fraction(Fr_min);
    x_max = Fraction(Fr_max);
    %}
    Fr_min = ((n-1)*128)+1;
    x_min = Fraction(Fr_min);
    x_max = (1-2^-14)-x_min;
    
    y_min = cos(x_min*pi/2);
    y_max = cos(x_max*pi/2);
    %k(i) = y_min;
    %i = i+1;
    syms c1 c0
    eqn1 = (c1*x_min)+c0 == y_min;
    eqn2 = (c1*x_max)+c0 == y_max;
    sol = solve([eqn1 eqn2],[c1 c0]);
    c_1(n) = sol.c1;
    c_0(n) = sol.c0;
    k(n) = y_max;
    %k(n+1) = y_max;
end
%{
for n=1:32
    k(n) = cos(n*pi/2);
end
plot(k);
%}
plot(c_1);