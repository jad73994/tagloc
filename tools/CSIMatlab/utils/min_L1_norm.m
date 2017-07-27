function h=min_L1_norm(X,w_init,Y,lambda,max_iter)
n=size(X,1);
gamma=n/2/norm(X'*X);
not_converged=true;
w=w_init;
iter=1;
while not_converged
    w_next=soft_thresholding(w-2*gamma/n*X'*(X*w-Y),lambda*gamma);
    err=sum((X*w_next-Y).^2+lambda*sum(abs(w_next)));
    err_prev=sum((X*w-Y).^2+lambda*sum(abs(w)));
    %disp(err_prev-err);
    if(abs(err_prev-err)<0.01 || iter>max_iter)
        h=w_next;
        not_converged=false;
    else
        w=w_next;
        iter=iter+1;
    end
end
end

function A= soft_thresholding(A,l)
    idx1=(abs(A)<l);
    idx2=(abs(A)>=l);
    A(idx1)=0;
    A(idx2)=A(idx2)./abs(A(idx2)).*(abs(A(idx2))-l);
end