function dark = integrateDarkFrame(path)
% path must have trailing \

files = dir(path);

darkPreallocated = false;
filesProcessed = 0;

for k = 1:length(files)
    
    name = files(k).name;
    dirStat = files(k).isdir;
    
    % remove the . and .. names
    if (~dirStat && (strcmp(name(end-3:end), 'tiff') || strcmp(name(end-2:end), 'tif')))
        
        % increment the number of files processed
        filesProcessed = filesProcessed + 1;
        
        % get the data as a double
        temp = double(read(Tiff(strcat(path, name))));
        
        % check if we already preallocated the array
        if (darkPreallocated)
            
            % if so, add this image to the array
            dark = dark + temp;
            
        else
            
            % if not, preallocate the dark array and add this first image
            % to it
            [m, n, l] = size(temp);
            dark = zeros(m, n, l);
            dark = dark + temp;
            
            % save that we preallocated the dark array
            darkPreallocated = true;
            
        end
    end
end

% divide the dark by the number of files (to average it)
dark = dark / filesProcessed;