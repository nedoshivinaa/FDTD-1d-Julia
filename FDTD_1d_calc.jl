# using NPZ
using JLD

tic()
c = 299792458
frequence = 2.4e9
wavelength = c/frequence
dz = wavelength/100
dt = dz/c
nlength = 0:dz:10*wavelength
maxlength = 0:dz:20*wavelength
mu0 = 4*pi*10.0^-7
eps0 = 1/(mu0*c*c)
cord = length(maxlength)
dTime = 2000

sigma  = zeros(cord)
epsilon = ones(cord)
mu = ones(cord)
Ca = zeros(cord)
Cb = zeros(cord)
Da = zeros(cord)
Db = zeros(cord);

mid=nlength[round(Int,(length(nlength))/2)]
x = linspace(0,nlength[end],length(nlength))#linspace(0, length, subdivNum)

Nu, delta = mid, 0.01
G=(1/sqrt(2*pi*delta.*delta))*exp(-((x-Nu).*(x-Nu))/(2*delta))
F=100*sin(50*(x-Nu))./(50*(x-Nu)).*sin(2*pi/wavelength*x)
#F[100]=100
for i = 1300:1305
    sigma[i]=1e-11
    epsilon[i]=4.7
    mu[i]=12.6
end

for i = 1:cord
    Ca[i] = (1-((sigma[i].*dt)./(2*eps0*epsilon[i])))/(1+((sigma[i].*dt)./(2*eps0*epsilon[i])))
    Cb[i] = (dt/(eps0*dz*epsilon[i]))/(1+((sigma[i].*dt)./(2*eps0*epsilon[i])))
    Da[i] = (1-sigma[i].*dt./2mu[i])/(1+sigma[i].*dt./(2*mu0*mu[i]))
    Db[i] = (dt/(mu[i]*mu0*dz))/(1+sigma[i].*dt./(2*mu0*mu[i]))
end

Ex=zeros(dTime,cord)
Hy=zeros(dTime,cord)
#for i = 201:800
#    Ex[1,i-200]=G[i]
#    Hy[1,i-200]=1/120pi*G[i]
#end
k=0
a=1
for n = 2:dTime
    Ex[n,1] = Ex[n-1,2] + ((c*dt-dz)/(c*dt+dz))*(Ex[n,2]-Ex[n-1,1])
    for i = 2:cord
        Ex[n,i] = Ca[i]*Ex[n-1,i] - Cb[i]*(Hy[n-1,i]-Hy[n-1,i-1])
    end
    if n>1 && n<999
        k=100*sin(50*x[n]-50*Nu)./(50*(x[n]-Nu)).*sin(2*pi/wavelength*x[n])
        Ex[n,500:501]=k
        Ex[500,500:501]=0
    end
    for i = 1:cord-1
        Hy[n,i] = Da[i]*Hy[n-1,i] - Db[i]*(Ex[n,i+1]-Ex[n,i])
    end
    Hy[n,500:501]=1/120pi*k
    Hy[500,500:501]=0
    Hy[n,cord] = Hy[n-1,cord-1] + ((c*dt-dz)/(c*dt+dz))*(Hy[n,cord-1]-Hy[n-1,cord])
end
# npzwrite("data.npz", Dict("Ex" => Ex, "Hy" => Hy, "dt" => dt, "dz" => dz, "sigma" => sigma, "epsilon" => epsilon, "mu" => mu, "G" => G, "x" => x, "length" => maxlength[end], "dTime" => dTime))
# npzwrite("data.npz", Dict("c" => c))
save("data.jld", "Ex", Ex, "Hy", Hy, "dt", dt, "dz", dz, "sigma", sigma, "epsilon", epsilon, "mu", mu, "G", G, "F", F, "x", x, "length", maxlength[end], "dTime", dTime)
toc()
