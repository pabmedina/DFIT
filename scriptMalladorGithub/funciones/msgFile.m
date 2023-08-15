function msgFile(msg)
% Function re-writes or creates file with error and warning messages

fileName = 'messageFile.txt';
fid = fopen(fileName);

if fid < 0
    fid = fopen(fileName, 'a+');
    fprintf(fid,'%% %% %% File with error and warning messages %% %% %%\n');
    fprintf(fid, '\n%s\n', msg);
else
    fid = fopen(fileName, 'a+');
    fprintf(fid, '\n%s\n', msg);
end

fclose(fid);

end