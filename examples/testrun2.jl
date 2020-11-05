using GeodesicOnMesh
using SparseArrays
using LinearAlgebra
using LinearAlgebra: dot, cross

meshdata = readObj("/home/arhik/bunny.obj")
mesh = buildMesh(meshdata)
normalizeMesh!(mesh)
setup(mesh)
computeGeodesics(mesh, 1000)


