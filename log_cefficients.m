% x is in range [1 2)
% try to find out coefficients

global log_values;
global c0_log;
global c1_log;
global c2_log;

min_val = 0;
mid_val = 0;
max_val = 0;
num_segments = 256 % numeber of segments
N_S = 2^39; % number of values in each segment
for i = 1:num_segments
    min_val = ((i-1)*N_S);
    max_val = (i*N_S)-1;
    mid_val = round((min_val+max_val)/2);
    %val(i) = min_val;
    xe_min = bitor(min_val,(2^47));
    xe_mid = bitor(mid_val,(2^47));
    xe_max = bitor(max_val,(2^47));
    %display(length(xe_min));
    % conversion from binary to decimal
    xe_min = dec2bin(xe_min);
    xe_mid = dec2bin(xe_mid);
    xe_max = dec2bin(xe_max);
    
    dec_min = str2num(xe_min(1));
        for k = 2 : 48    % Note that the 1st char is the decimal dot !
            %display(Fr_bin);
            dec_min = dec_min + 2^(1-k) * str2num( xe_min(k) ) ;
        end
    dec_mid = str2num(xe_mid(1));
        for k = 2 : 48    % Note that the 1st char is the decimal dot !
            %display(Fr_bin);
            dec_mid = dec_mid + 2^(1-k) * str2num( xe_mid(k) ) ;
        end
    dec_max = str2num(xe_mid(1));
        for k = 2 : 48    % Note that the 1st char is the decimal dot !
            %display(Fr_bin);
            dec_max = dec_max + 2^(1-k) * str2num( xe_max(k) ) ;
        end
        
        
        
    syms c0 c1 c2
    eqn1 = c0 + c1*dec_min + c2*dec_min*dec_min == -log(dec_min);
    eqn2 = c0 + c1*dec_mid + c2*dec_mid*dec_mid == -log(dec_mid);
    eqn3 = c0 + c1*dec_max + c2*dec_max*dec_max == -log(dec_max);
    soln = solve([eqn1 eqn2 eqn3],[c0 c1 c2]);
    c0_log(i) = soln.c0;
    c1_log(i) = soln.c1;
    c2_log(i) = soln.c2;
    plot_min(i) = -log(dec_min)*2;
    plot_min(i+1) = -log(dec_max)*2;
    
    %display(dec2bin(xe_min));
    %{
    %x_min = log_values(min_val);
    %x_mid = log_values(mid_val);
    %x_max = log_values(max_val);
    syms c0,c1,c2
    eqn1 = c0 + c1*x_min + c2*x_min*x_min == -log(x_min);
    eqn2 = c0 + c1*x_mid + c2*x_mid*x_mid == -log(x_mid);
    eqn3 = c0 + c1*x_max + c2*x_max*x_max == -log(x_max);
    soln = solve([eqn1 eqn2 eqn3],[c0 c1 c2]);
    c_0(i) = soln.c0;
    c_1(i) = soln.c1;
    c_2(i) = soln.c2;
    %}
end
%display(dec2bin(val(2)));
%display(dec2bin(xe_min(2)));
%display(max_val);
plot(plot_min);