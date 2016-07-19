% this file is to plot output from modelsim
 fileIO = fopen('output_gng.txt','r');
 i=1;
 while (~feof(fileIO))
     f = fgetl(fileIO);
     x0 = f(1:16);
     x1 = f(18:33);
     x0_dec(i) = bin2dec(x0);
     x1_dec(i) = bin2dec(x1);
     i = i+1;
     %bin2dec(f)
     display(x1);
 end
 hist([x0_dec,x1_dec], i);
 display(i);