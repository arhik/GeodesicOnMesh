using GeodesicOnMesh
using SparseArrays
using LinearAlgebra
using LinearAlgebra: dot, cross

meshdata = readObj("/home/arhik/bunny.obj")
mesh = buildMesh(meshdata)
vpos = mesh.vertices[1].position
normalizeMesh!(mesh)
vafterpos = mesh.vertices[1].position
n = length(mesh.vertices)
sm = spzeros(n, n)

lp = buildLaplacian(mesh, sm)
solM = ldlt(lp)

sm = spzeros(n, n)
lp = buildAreaMatrix(mesh, sm)
solA = cholesky(lp)
u = zeros(n)
u[1000] = 1.0
u = solA\u
nf = length(mesh.faces)
gradients = zeros(nf, 3)
computeFaceGradients(mesh, gradients, u)

integratedDivs = rand(n);
computeIntegratedDivergence(mesh, integratedDivs, gradients)


