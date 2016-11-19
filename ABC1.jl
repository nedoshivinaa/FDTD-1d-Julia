using JLD

tic()
c = 299792458 #Скорость света
frequence = 2.4e9 #Частота
wavelength = c/frequence #Длина волны
dz = wavelength/100 #Шаг дискретизации
dt = dz/c #Магическое соотношение
nlength = Int(round(10*wavelength/dz)) #Длина пространства для начального распределения. Массив с разбиением dz
mu0 = 4*pi*10.0^-7 #Магнитная проницаемость
eps0 = 1/(mu0*c*c) #Диэлектрическая проницаемость
xSteps = 2*nlength #Количество пространственных шагов (Длина пространства = xSteps * dz)
timeSteps = 3000 #Количество временных шагов (Продолжительность = timeSteps * dt)

sigma  = zeros(xSteps) #Заполнение нолями массивов
epsilon = ones(xSteps)
mu = ones(xSteps)
Ca = zeros(xSteps)
Cb = zeros(xSteps)
Da = zeros(xSteps)
Db = zeros(xSteps);

x = linspace(0,wavelength*10,nlength)

Nu, delta = wavelength*5, 0.01 #Переменные ню и дельта для начального распределения Гаусса
G=(1/sqrt(2*pi*delta.*delta))*exp(-((x-Nu).*(x-Nu))/(2*delta)) #Начальное распределение Гаусса
#F=100*sin(50*(x-Nu))./(50*(x-Nu)).*sin(2*pi/wavelength*x) #Функция sin(x)/x. Переделать (!)
#F[100]=100 #Так как в F sin(0)/0 --  неопределенность

# for i = 900:1000 #Объект  в пространстве с иными значениями sigma, epsilon, mu. По умолчанию -- вакуум
#     sigma[i]=1e-11
#     epsilon[i]=4.7
#     mu[i]=12.6
# end
sigma[900:1000]=1e-11
epsilon[900:1000]=4.7
mu[900:1000]=12.6

# for i = 1:xSteps #Расчет коэффициентов
#    Ca[i] = (1-((sigma[i].*dt)./(2*eps0*epsilon[i])))/(1+((sigma[i].*dt)./(2*eps0*epsilon[i])))
#    Cb[i] = (dt/(eps0*dz*epsilon[i]))/(1+((sigma[i].*dt)./(2*eps0*epsilon[i])))
#    Da[i] = (1-sigma[i].*dt./2mu[i])/(1+sigma[i].*dt./(2*mu0*mu[i]))
#    Db[i] = (dt/(mu[i]*mu0*dz))/(1+sigma[i].*dt./(2*mu0*mu[i]))
# end

Ca=(1-((sigma*dt)./(2*eps0*epsilon)))./(1+((sigma*dt)./(2*eps0*epsilon)))
Cb = (dt./(eps0*dz*epsilon))./(1+((sigma*dt)./(2*eps0*epsilon)))
Da = (1-sigma*dt./2mu)./(1+sigma*dt./(2*mu0*mu))
Db = (dt./(mu*mu0*dz))./(1+sigma*dt./(2*mu0*mu))

Ex=zeros(timeSteps,xSteps) #Заполнение нолями Ex и Hy во всём пространстве-времени
Hy=zeros(timeSteps,xSteps)
# for i = 1:800 #В начальный момент времени задается распределение Гаусса
#     Ex[1,i]=G[i]
#     Hy[1,i]=1/120pi*G[i] #Так как значения Ex и Hy отличаются в 1/120pi, нужно домножить на это значение.
# end
Ex[1,1:800]=G[1:800]
Hy[1,1:800]=1/120pi*G[1:800]

for n = 2:timeSteps #Расчет
    Ex[n,1] = Ex[n-1,2] + ((c*dt-dz)/(c*dt+dz))*(Ex[n,2]-Ex[n-1,1]) #Левая граница в настоящий момент времени. Граничные условия ABC

    # for i = 2:xSteps #Расчет Ex в данный момент времени по всему пространству. Зависит от Hy в прошлый половинный момент времени
    #     Ex[n,i] = Ca[i]*Ex[n-1,i] - Cb[i]*(Hy[n-1,i]-Hy[n-1,i-1])
    # end
    Ex[n,2:xSteps] = Ca[2:xSteps].*Ex[n-1,2:xSteps] - Cb[2:xSteps].*(Hy[n-1,2:xSteps]-Hy[n-1,1:xSteps-1]) #Расчет Ex в данный момент времени по всему пространству. Зависит от Hy в прошлый половинный момент времени

    # for i = 1:xSteps-1
    #     Hy[n,i] = Da[i]*Hy[n-1,i] - Db[i]*(Ex[n,i+1]-Ex[n,i]) #Расчет Hy в данный момент времени по всему пространству
    # end
    Hy[n,1:xSteps-1] = Da[1:xSteps-1].*Hy[n-1,1:xSteps-1] - Db[1:xSteps-1].*(Ex[n,2:xSteps]-Ex[n,1:xSteps-1]) #Расчет Hy в данный момент времени по всему пространству

    Hy[n,xSteps] = Hy[n-1,xSteps-1] + ((c*dt-dz)/(c*dt+dz))*(Hy[n,xSteps-1]-Hy[n-1,xSteps]) #Правая граница в настоящий момент времени. Граничные условия -- ABC
end

save("data.jld", "Ex", Ex, "Hy", Hy, "dt", dt, "dz", dz, "G", G, "x", x, "xSteps", xSteps, "timeSteps", timeSteps)
toc()
