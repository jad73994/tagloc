function [ coded_signal,r ] = QAM( input_signal, QAMsize )
%QAM Summary of this function goes here
%   Detailed explanation goes here
    if(QAMsize==1)
        coded_signal = -2*input_signal+1;
        r = 1;
        return
    end
    
    if(QAMsize==2)
        int_signal = input_signal;
        [x y] = size(int_signal);
        r = 1/sqrt(2);
        q = 1/sqrt(2);
        for m = 1:2:y
            real_val = (2*int_signal(m)-1)*r;
            imag_val = (2*int_signal(m+1)-1)*q;
            coded_signal((m+1)/2)= real_val+imag_val*1i;           
        end
        return
    end
    
    if(QAMsize==4)
        int_signal = input_signal;
        [x y] = size(int_signal);
        r = 1/sqrt(10);
        q = 1/sqrt(10);
        for m = 1:4:y
            real_val = ((2*int_signal(m)-1)*(3-2*int_signal(m+1)))*r;
            imag_val = ((2*int_signal(m+2)-1)*(3-2*int_signal(m+3)))*q;
            coded_signal((m+QAMsize-1)/QAMsize)= real_val+imag_val*1i;           
        end
        return
    end
    
    
    if(QAMsize==6)
        int_signal = input_signal;
        [x y] = size(int_signal);
        r = 1/sqrt(42);
        q = 1/sqrt(42);
        for m = 1:6:y
            real_sign = -2*int_signal(m+2)+1;
            real_val = (3+2*int_signal(m+1)+2*int_signal(m)*(2*int_signal(m+1)-1))*r;
            
            imag_sign = -2*int_signal(m+5)+1;
            imag_val = (3+2*int_signal(m+4)+2*int_signal(m+3)*(2*int_signal(m+4)-1))*q;
            
            coded_signal((m+QAMsize-1)/QAMsize)= real_sign*real_val+imag_sign*imag_val*1i;           
        end
        return
    end
    
    if(QAMsize==8)
        int_signal = input_signal;
        [x y] = size(int_signal);
        r = 1/sqrt(170);
        q = 1/sqrt(170);
        for m = 1:8:y
            real_sign = -2*int_signal(m+3)+1;
            
            real_val = (8+(-2*int_signal(m+2)+1)*(4+(-2*int_signal(m+1)+1)*(3-2*int_signal(m))))*r;
            
            imag_sign = -2*int_signal(m+7)+1;
            
            imag_val = (8+(-2*int_signal(m+6)+1)*(4+(-2*int_signal(m+5)+1)*(3-2*int_signal(m+4))))*q;
            
            
            coded_signal((m+QAMsize-1)/QAMsize)= real_sign*real_val+imag_sign*imag_val*1i;           
        end
        return
    end
        
end

