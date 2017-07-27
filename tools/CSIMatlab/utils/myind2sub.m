function out = myind2sub(L, d, ix)

sz = repmat(L, [1 d]); %// dimension array for a d-dimension array L long on each side
c = cell([1 d]);  %// dynamically sized varargout
[c{:}] = ind2sub(sz, ix);
out = [c{:}];