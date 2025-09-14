function I = J_ApproxMI(w,R,Pc)

% Set dimensions
M = size(R,1); % number of classes
N = size(R,2); % data dimension

% Compute marginalized covariance matrix
Rx = zeros(N,N);
for n1 = 1:1:M,
    Rx = Rx + Pc(n1)*reshape(R(n1,:,:),N,N);
end

% Normalize variance of x
wv = w'*Rx*w;
w = w./sqrt(wv);

% Compute gaussian mutual information
Ig = 1/2*log((w'*Rx*w));
for n1 = 1:1:M,
    Ig = Ig - 1/2*Pc(n1)*log(w'*reshape(R(n1,:,:),N,N)*w);
end

% Compute estimate of negentropy
J = 0;
for n1 = 1:1:M,
    J = J + Pc(n1)*(w'*reshape(R(n1,:,:),N,N)*w)^2;
end
J = (J - 1)^2;
J = 9/48*J;

% Compute estimate of mutual information with correction by negentropy
I = Ig - J;