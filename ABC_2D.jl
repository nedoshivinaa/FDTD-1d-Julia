Hx[n,1:xSteps-1,2:ySteps] = Hx[n-1,1:xSteps-1,2:ySteps] + (1/mu0)*(Ez[n,1:xSteps-1,2:ySteps] - Ez[n,1:xSteps-1,1:ySteps-1])/dy
Hy[n-1,2:xSteps,1:ySteps-1] = Hy[n,2:xSteps,1:ySteps-1] + (1/mu0)*(Ez[n,2:xSteps,1:ySteps-1] - Ez[n,1:xSteps-1,1:ySteps-1])
Ez[n,2:xSteps,2:ySteps] = Ez[n-1,2:xSteps,2:ySteps] + (1/eps0)*((Hy[n,2:xSteps,2:ySteps] - Hy[n,1:xSteps-1,2:ySteps])/dx - (Hy[n,2:xSteps,2:xSteps] - Hx[n-1,2:xSteps,1:ySteps-1])/dy)
