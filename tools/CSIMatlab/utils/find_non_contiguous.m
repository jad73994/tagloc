function idx=find_non_contiguous(idx)
d=diff(idx);
idx=idx([1,find(d>1)+1]);
end