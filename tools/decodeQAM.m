function [ bits ] = decodeQAM( subcarrier_config, symf, QAMsize,scale)
%DECODEQAM Summary of this function goes here
%   Detailed explanation goes here

    [x y] = size(symf);
    
    bits = [];
    if(QAMsize == 1)
       bits = symf(subcarrier_config==1) < 0;
       return
    end

    if(QAMsize == 2)
       index = 1;
       for m = 1:1:y
          if(subcarrier_config(m)==1)
            r = real(symf(m))*scale;
            q = imag(symf(m))*scale;
%             figure(8)
%             hold on
%                 plot(r,q,'*');
%             hold off
            
            bits(index)   = r > 0;
            
            bits(index+1) = q > 0;
            
            index = index+QAMsize;
          end
       end
    end
      
    if(QAMsize == 4)
       index = 1;
       for m = 1:1:y
          if(subcarrier_config(m)==1)
            r = real(symf(m))*scale;
            q = imag(symf(m))*scale;
            
            bits(index)   = r > 0;
            bits(index+1) = abs(r) < 2;
            
            bits(index+2) = q > 0;
            bits(index+3) = abs(q) < 2;
            
            index = index+QAMsize;
          end
       end
    end
    
    
    if(QAMsize == 6)
       index = 1;
       for m = 1:1:y
          if(subcarrier_config(m)==1)
            r = real(symf(m))*scale;
            q = imag(symf(m))*scale;
            
            bits(index)   = abs(4-abs(r)) > 2;
            bits(index+1) = abs(r) > 4;
            bits(index+2) = r < 0;
            
            bits(index+3) = abs(4-abs(q)) > 2;
            bits(index+4) = abs(q) > 4;
            bits(index+5) = q < 0;
            
            index = index+QAMsize;
          end
       end
    end
    
    if(QAMsize == 8)
       index = 1;
       for m = 1:1:y
          if(subcarrier_config(m)==1)
            r = real(symf(m))*scale;
            q = imag(symf(m))*scale;
            
            bits(index)   = abs(8-abs(r)) > 2 && abs(8-abs(r)) < 6;
            bits(index+1) = abs(8-abs(r)) < 4;
            bits(index+2) = abs(r) < 8;
            bits(index+3) = r < 0;
            
            bits(index+4) = abs(8-abs(q)) > 2 && abs(8-abs(q)) < 6;
            bits(index+5) = abs(8-abs(q)) < 4;
            bits(index+6) = abs(q) < 8;
            bits(index+7) = q < 0;
            
            index = index+QAMsize;
          end
       end
    end
    
    
end

