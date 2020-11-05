module GeodesicOnMesh

using SparseArrays
using LinearAlgebra
using LinearAlgebra: dot, cross
include("Types.jl")
include("HalfEdge.jl")
include("Vertex.jl")
include("Edge.jl")
include("Face.jl")
include("Mesh.jl")
include("MeshIO.jl")

export readObj, buildMesh, normalizeMesh!,  buildLaplacian, buildAreaMatrix, computeTimeStep, computeFaceGradients, computeIntegratedDivergence, setup, computeGeodesics, normalize

end # module
