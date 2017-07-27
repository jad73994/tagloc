function h= create_dummy_channel(src,dst,f)
    h = exp(-1j*2*pi/(3e8/f)*norm(dst-src));
end