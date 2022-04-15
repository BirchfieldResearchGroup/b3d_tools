% Create a manually-created B3D object -- see B3D format document for what all these variables mean
b = b3d();
b.comment = "Creating a manual b3d object for testing";
b.lat = [36.5, 36.5, 34.0, 34.0, 31.5, 31.5]';
b.lon = [-84.5, -88.0, -84.5, -88.0, -84.5, -88.0]';
b.grid_dim = [3, 2];
b.time = linspace(0, 900, 10)'; 
b.ex = zeros(10, 6);
b.ey = zeros(10, 6);
for t=1:10
    for i=1:3
        for j=1:2
            b.ex(t, (i-1)*2+j) = t*1000 + i*10+j; % Random equation for x e-field
            b.ey(t, (i-1)*2+j) = -t*1000 - i*10-j; % Random equation fo y e-field
        end
    end
end

% Save B3D object as file
b.write_b3d_file("example6by10.b3d");

% Read B3D object
b2 = b3d("example6by10.b3d");

% Double the magnitude of the electric field and save again
n = length(b2.lat);
nt = length(b2.time);
for t=1:nt
    for i=1:n
        b2.ex(t, i) = b2.ex(t, i)*2;
        b2.ey(t, i) = b2.ey(t, i)*2;
    end
end
b2.write_b3d_file("example6by10_doubled.b3d")
clear i j n nt t

disp("Done!")