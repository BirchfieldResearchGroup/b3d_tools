classdef b3d
    %B3D Class to hold 3d electric field data from *.b3d file format
    %   Includes functionality for reading and writing classes
    
    properties
        comment
        time_0
        time_units
        lat
        lon
        grid_dim
        time
        ex
        ey
    end
    
    methods
        function obj = b3d(fname)
            obj.comment = "Default empty 2x2 grid with 3 time points";
            obj.time_0 = 0;
            obj.time_units = 0;
            obj.lat = [30.5, 30.5, 31.0, 31.0]';
            obj.lon = [-84.5, -85.0, -84.5, -85]';
            obj.grid_dim = [2, 2];
            obj.time = [0, 1000, 2000]';
            obj.ex = zeros(3, 4);
            obj.ey = zeros(3, 4);
            if nargin == 1
                obj = obj.read_b3d_file(fname);
            end
        end
        
        function obj = read_b3d_file(obj, fname)
            fid = fopen(fname, "r");
            key = fread(fid, 1, "uint32", 0, "l");
            if key ~= 34280
                error("B3D file key does not check out");
            end
            version = fread(fid, 1, "uint32", 0, "l");
            if version == 4
                nmeta = fread(fid, 1, "uint32", 0, "l");
                meta = strings(nmeta, 1);
                for imeta = 1:nmeta
                    this_meta = '';
                    while 1
                        this_char = fread(fid, 1, "char*1", 0, "l");
                        if this_char == 0
                            break;
                        end
                        this_meta(length(this_meta) + 1) = this_char; 
                    end
                    meta(imeta) = string(this_meta);
                end
                obj.comment = "No comment";
                if nmeta >= 1
                    obj.comment = meta(1);
                    if nmeta >= 2
                        try
                            obj.grid_dim = str2num(meta(2)); %#ok<ST2NM>
                        catch
                        end
                    end
                end
                float_channels = fread(fid, 1, "uint32", 0, "l");
                byte_channels = fread(fid, 1, "uint32", 0, "l");
                loc_format = fread(fid, 1, "uint32", 0, "l");
                if float_channels < 2
                    error("Only B3D files with at least 2 float "...
                        + "channels are supported");
                elseif loc_format ~= 1
                    error("Only location format 1 is supported");
                end
                n = fread(fid, 1, "uint32", 0, "l");
                loc_data = fread(fid, [3 n], "float64", 0, "l");
                obj.lat = loc_data(2, :)';
                obj.lon = loc_data(1, :)';
                obj.time_0 = fread(fid, 1, "uint32", 0, "l"); 
                obj.time_units = fread(fid, 1, "uint32", 0, "l");
                fread(fid, 1, "uint32", 0, "l"); % Time offset ignored
                dt = fread(fid, 1, "uint32", 0, "l");
                nt = fread(fid, 1, "uint32", 0, "l");
                if dt ~= 0
                    error("Only B3D files with variable time points" ...
                        + " are supported");
                end
                obj.time = fread(fid, nt, "uint32", 0, "l");
                efstart = ftell(fid);
                skip = (float_channels-1)*4+byte_channels;
                raw_ex = fread(fid, n*nt, "float32", skip, "l");
                fseek(fid, efstart+4, -1);
                raw_ey = fread(fid, n*nt, "float32", skip, "l");
                obj.ex = reshape(raw_ex, n, nt)';
                obj.ey = reshape(raw_ey, n, nt)';
            else
                error("Only version 2 of B3D format is supported");
            end

            fclose(fid);
        end
        
        function write_b3d_file(obj, fname)
            fid = fopen(fname, "w");
            n = length(obj.lat);
            nt = length(obj.time);
            if length(obj.lon) ~= n
                error("Lat and lon must be the same length")
            end
            if size(obj.ex, 1) ~= nt || size(obj.ex, 2) ~= n
                error("Ex must be nt x n in size")
            end
            if size(obj.ey, 1) ~= nt || size(obj.ey, 2) ~= n
                error("Ey must be nt x n in size")
            end
            fwrite(fid, [34280 4 2], "uint32", 0, "l");
            meta = char(obj.comment + sprintf('\0') + ...
                num2str(obj.grid_dim) + sprintf('\0'));
            fwrite(fid, meta, 'char*1', 0, "l");
            fwrite(fid, [2 0 1 n], "uint32", 0, "l");
            location_data = reshape([obj.lon, obj.lat, zeros(n,1)]',3*n,1);
            fwrite(fid, location_data, "float64", 0, "l");
            consts = [obj.time_0 obj.time_units 0 0 nt];
            fwrite(fid, consts, "uint32", 0, "l");
            fwrite(fid, obj.time, "uint32", 0, "l");
            efield_data = permute(cat(3, obj.ex', obj.ey'), [3, 1, 2]);
            fwrite(fid, efield_data(:), "float32", 0, "l");
            fclose(fid);
        end
    end
end

