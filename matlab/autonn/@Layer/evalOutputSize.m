function sz = evalOutputSize(obj, varargin)
% SZ = OBJ.EVALOUTPUTSIZE('INPUT1', SZ1, 'INPUT2', SZ2, ...)
% Computes the output size of a Layer, given input names and respective
% sizes. Note that the size is computed by compiling and evaluating a
% network, which always outputs reliable sizes but can be computationally
% expensive.

% NOTE: The upside of compiling a dummy network is that there's no need to
% specify size calculations for all layers by hand. This is especially
% useful for many Matlab native functions, and flexible enough for
% user-defined custom layers to be supported with no extra work.

% Copyright (C) 2016 Joao F. Henriques.
% All rights reserved.
%
% This file is part of the VLFeat library and is made available under
% the terms of the BSD license (see the COPYING file).


  assert(iscellstr(varargin(1:2:end)), 'Expected a list of input names and their sizes.') ;

  inputNames = cellfun(@(o) o.name, obj.find('Input'), 'UniformOutput',false) ;
  inputs = cell(1, 2 * numel(inputNames)) ;

  for i = 1:numel(inputNames)
    % find the user-supplied name that matches this network input
    match = find(strcmp(inputNames{i}, varargin(1:2:end))) ;
    assert(~isempty(match), ['Input not found: ''' varargin{i} '''.']) ;
    
    % add it to the list, along with its initial value
    inputSz = varargin{2 * match} ;
    inputs{2 * i} = zeros(inputSz, 'single') ;
    inputs{2 * i - 1} = inputNames{i} ;
  end
  
  % note any user-supplied names that do not exist in the network yet are
  % ignored (i.e., when building a network, and that part hasn't been
  % defined, or hasn't been connected to this Layer yet).
  
  % compile and evaluate network
  net = Net(obj, 'sequentialNames',false, 'shortCircuit',false, 'forwardOnly',true) ;
  net.setInputs(inputs{:}) ;
  net.eval('forward') ;
  
  % retrieve value of last variable, which must correspond to this layer
  sz = size(net.getValue(numel(net.vars) - 1)) ;

end
