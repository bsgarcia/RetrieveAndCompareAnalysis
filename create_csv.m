function create_csv(data, colnames, filename)
    fileID = fopen(filename,'w');
    fprintf(fileID,...
        [repmat('%12s, ', [1, length(colnames)]), '\n'],colnames{:});
fprintf(fileID,...
    [repmat('%12.8f, ', [1, length(colnames)]), '\n'],data{:});
fclose(fileID);
end

