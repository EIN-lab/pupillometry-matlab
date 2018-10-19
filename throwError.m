function ME = throwError(err, varargin)

% Check all the input arguments
pNames = {'name', 'value'};
pValues = {'', 0};
params = cell2struct(pValues, pNames, 2);

% Parse function input arguments
params = utils.parsepropval2(params, varargin{:});

% Work out if we want to return the exception or throw it internally, and
% initialise the output argument if necessary
doReturnME = nargout > 0;
if doReturnME
    varargout{1} = [];
end

switch err
    case 1
        % Create the MException object
        ME = MException('pupilMeasurement:doFit:NoCircle', ['No ', ...
            'circular structure for radius %0.3f in first frame. Did you ', ...
            'draw the diameter from edge to edge and/or click seed ', ...
            'points in the black part of the pupil?'], params.value);
    otherwise
        ME = MException('Unexpected error!');
end

if ~isempty(ME)
    if doReturnME
        varargout{1} = ME;
        return
    else
        throwAsCaller(ME)
    end
end

end
