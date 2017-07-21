function xyz=ascii2xyz(varargin)
%ASCII2XYZ- convert ARC ASCII text file to xyz
%
%   ASCII2XYZ reads in a raster text file in 
%       ARC ASCII format and converts values to 
%       a matrix of x, y, a z values. No data 
%       values are ommited from the output matrix.
%
%   INPUTS: 
%       None required, but you can avoid invoking 
%       uigetfile by supplying a filename as an input (see
%       example below).
%
%   OUTPUTS: 
%       XYZ- m x 3 matrix where column one are X-values,
%       column two are Y-values and column 3 are Z-values. 
%       X and Y positions are always given relative to the 
%       pixel center (see note of ASCII file format below).
%
%   ARC ASCII TEXT FILE FORMAT:
%   
%       Contains a header with 6 properties and values.
%       An example of the header is provided below. 
%
%             ncols	 1762
%             nrows	 351
%             xllcenter	291213.190
%             yllcenter	129300.900
%             cellsize	10.000
%             NODATA_value	-9999.000
%
%       Where ncols is the number of columns, nrows is the number of
%       rows, xllcorner is the x location (pixel center) of the lower-left
%       corner of the grid, yllcorner is the y location (pixel center) of 
%       the lower-left corner of the grid.  Alternately, the corner of the 
%       lower left pixel in the grid is used if the header specifies
%       (xllcorner and yllcorner). Cellsize is the grid spacing, and 
%       NODATA_value is the value that signifies no data (equivalent 
%       to NaN in ML). The header is followed by a matrix (size = nrows 
%       x ncols) of Z-values. 
%
%   EXAMPLES AND SYNTAX:
%
%       xyz=ascii2xyz; - with no inputs, the user will be prompted to
%           select an ARC ASCII Grid Text file.  
%
%       xyz=ascii2xyz('foo.txt'); - the specified file will be loaded.
%      
%   
% SEE ALSO arcgridread (mapping toolbox)
%          arcgridwrite (File Exchange) 
%
% Andrew Stevens, 10/16/2008
% astevens@usgs.gov

%process optional input arg.
if nargin>0;
    fname=varargin{1};
    if exist(fname,'file')==0
        error('File not found, check the file name and try again.');
    end
else
    [filename, pathname] = uigetfile( ...
        {'*.txt','TXT Files (*.txt)'; ...
        '*.asc','ASC Files (*.asc)';...
        '*.*',  'All Files (*.*)'}, ...
        'Pick a file');
    fname=fullfile(pathname,filename);
end

fid=fopen(fname,'r');

%read header
format='%s %f';
hdr=cell(6,2);
try
    for i=1:6;
        [hdr(i,1),hdr{i,2}]=...
            strread(fgetl(fid),format);
    end
    
    %try to determine from header if the file uses
    %the corner of the grid or the pixel center. If 
    if findstr(hdr{3,1},'center')~=0
        offset=0;     
    elseif findstr(hdr{3,1},'corner')~=0
        offset=hdr{5,2}/2;
    else %in case the header is poorly formatted
        ansr=questdlg({'Is the grid referenced to the pixel center';...
            'or to the corner of the grid?'}, ...
            'Spatial Reference?', ...
            'Center', 'Corner', 'Center');
        if strcmpi(ansr,'center')
            offset=0;
        else
            offset=hdr{5,2}/2;
        end
    end
        
catch %#ok
    fclose(fid)
    errorstr.identifier='myToolbox:ascii2xyz:badHeader';
    errorstr.message=['Error reading header information.',...
        ' See required format in the help section.']
    error(errorstr)
end

%vector of x, y, and z positions
xv=(hdr{3,2}:hdr{5,2}:hdr{3,2}+...
    ((hdr{1,2}-1)*hdr{5,2}))+offset;
yv=(fliplr(hdr{4,2}:hdr{5,2}:hdr{4,2}+...
    ((hdr{2,2}-1)*hdr{5,2})))+offset;

xvec=repmat(xv,[1 hdr{2,2}])';
yvec=cell2mat(cellfun(@(x)(repmat(x,[hdr{1,2} 1])),...
    num2cell(yv),'uni',0));

%read data
zvec=fscanf(fid,'%f',hdr{1,2}*hdr{2,2});

fclose(fid);

%get rid of values with no data
xyz=[xvec(zvec~=hdr{6,2}),...
    yvec(zvec~=hdr{6,2}),...
    zvec(zvec~=hdr{6,2})];


  
    