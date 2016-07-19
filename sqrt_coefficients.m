% x is in range [1 2)
% try to find out coefficients

global c0_sqrt1;
global c1_sqrt1;
global c0_sqrt2;
global c1_sqrt2;

min_val = 0;
mid_val = 0;
max_val = 0;
num_segments = 64 % numeber of segments
%for table 1 where x ranges between 1 and 2 [1 2)
N_S = 2^18; % number of values in each segment
for i = 1:num_segments
    min_val = ((i-1)*N_S);
    max_val = (i*N_S)-1;
    %mid_val = round((min_val+max_val)/2);
    %display(dec2bin(min_val));
    
    xe_min = bitor(min_val,(2^24));
    %xe_mid = bitor(mid_val,(2^24));
    xe_max = bitor(max_val,(2^24));
    %display(dec2bin(xe_min));
    % conversion from binary to decimal
    
    xe_min = dec2bin(xe_min);
    %xe_mid = dec2bin(xe_mid);
    xe_max = dec2bin(xe_max);
    %display(xe_min);
    dec_min = str2num(xe_min(1));
        for k = 2 : 25    % Note that the 1st char is the decimal dot !
            %display(Fr_bin);
            dec_min = dec_min + 2^(1-k) * str2num( xe_min(k) ) ;
        end
    dec_max = str2num(xe_max(1));
        for k = 2 : 25    % Note that the 1st char is the decimal dot !
            %display(Fr_bin);
            dec_max = dec_max + 2^(1-k) * str2num( xe_max(k) ) ;
        end
                      
    syms c0 c1 
    eqn1 = c0 + c1*dec_min == sqrt(dec_min);
    eqn2 = c0 + c1*dec_max == sqrt(dec_max);
    soln = solve([eqn1 eqn2],[c0 c1]);
    c0_sqrt1(i) = soln.c0;
    c1_sqrt1(i) = soln.c1;
    plot_min((2*i)-1) = sqrt(dec_min);
    plot_min(2*i) = sqrt(dec_max);
end

%for table 2 where x ranges between 2 and 4 [2 4)
% for MSB 10 that is 2. something
num_segments = 32;
N_S = 2^19; % number of values in each segment
for i = 1:num_segments
    min_val = ((i-1)*N_S);
    max_val = (i*N_S)-1;
    %display(dec2bin(min_val));
    
    xe_min = bitor(min_val,(2^25));
    xe_max = bitor(max_val,(2^25));
    %display(dec2bin(xe_min));
    % conversion from binary to decimal
    
    xe_min = dec2bin(xe_min);
    %xe_mid = dec2bin(xe_mid);
    xe_max = dec2bin(xe_max);
    %display(xe_min);
    dec_min = str2num(xe_min(1));
        for k = 2 : 26    % Note that the 1st char is the decimal dot !
            %display(Fr_bin);
            dec_min = dec_min + 2^(1-k) * str2num( xe_min(k) ) ;
        end
    dec_max = str2num(xe_max(1));
        for k = 2 : 26    % Note that the 1st char is the decimal dot !
            %display(Fr_bin);
            dec_max = dec_max + 2^(1-k) * str2num( xe_max(k) ) ;
        end
                      
    syms c0 c1 
    eqn1 = c0 + c1*dec_min == sqrt(dec_min);
    eqn2 = c0 + c1*dec_max == sqrt(dec_max);
    soln = solve([eqn1 eqn2],[c0 c1]);
    c0_sqrt2(i) = soln.c0;
    c1_sqrt2(i) = soln.c1;
    plot_min((2*i)-1) = sqrt(dec_min);
    plot_min(2*i) = sqrt(dec_max);
end

% for MSB 11 that is 3. something
num_segments = 32;
N_S = 2^19; % number of values in each segment
for i = 1:num_segments
    min_val = ((i-1)*N_S);
    max_val = (i*N_S)-1;
    %display(dec2bin(min_val));
    
    xe_min = bitor(min_val,(2^25));
    xe_max = bitor(max_val,(2^25));
    %display(dec2bin(xe_min));
    xe_min = bitor(xe_min,(2^24));
    xe_max = bitor(xe_max,(2^24));
    
    %display(dec2bin(xe_min));
    % conversion from binary to decimal
    
    xe_min = dec2bin(xe_min);
    %xe_mid = dec2bin(xe_mid);
    xe_max = dec2bin(xe_max);
    %display(xe_min);
    dec_min = str2num(xe_min(1));
        for k = 2 : 26    % Note that the 1st char is the decimal dot !
            %display(Fr_bin);
            dec_min = dec_min + 2^(1-k) * str2num( xe_min(k) ) ;
        end
    dec_max = str2num(xe_max(1));
        for k = 2 : 26    % Note that the 1st char is the decimal dot !
            %display(Fr_bin);
            dec_max = dec_max + 2^(1-k) * str2num( xe_max(k) ) ;
        end
                      
    syms c0 c1 
    eqn1 = c0 + c1*dec_min == sqrt(dec_min);
    eqn2 = c0 + c1*dec_max == sqrt(dec_max);
    soln = solve([eqn1 eqn2],[c0 c1]);
    c0_sqrt2(i+32) = soln.c0;
    c1_sqrt2(i+32) = soln.c1;
    plot_min(64+((2*i)-1)) = sqrt(dec_min);
    plot_min(64+(2*i)) = sqrt(dec_max);
end

%display(dec2bin(val(2)));
%display(dec2bin(xe_min(2)));
%display(max_val);
plot(plot_min);