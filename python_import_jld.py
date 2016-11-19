import h5py
filename="data.jld"
f = h5py.File(filename, 'r')
data= f["Ex"][()]
f.close()
