mutable struct Vertex
    he
	position # Vector3D
	phi::Float64
	index::Int
  function Vertex()
    new(nothing, [], -1.0, -1)
  end
end

mutable struct Edge
    he
	index::Int
    function Edge()
        new(nothing, -1)
    end
end


mutable struct Face
	he
	index
    function Face() 
        new(nothing, -1)
    end
end

mutable struct HalfEdge
    next::Union{Nothing, HalfEdge}
    twin::Union{Nothing, HalfEdge}
    vertex::Union{Nothing, Vertex}
    edge::Union{Nothing, Edge}
    face::Union{Nothing, Face}
	uv
	normal
	onBoundary::Bool
    function HalfEdge()
        new(nothing, nothing, nothing, nothing, nothing, nothing, nothing, false)
    end
end

struct Index
	position
	uv
	normal
end

struct MeshData
	positions
	uvs
	normals
	indices
end

mutable struct Mesh
    halfEdges
    vertices
    uvs
    normals
    edges
    faces
    boundaries
    sparseM
    sparseA
    function Mesh()
        new([], [], [], [], [], [], [], nothing, nothing)
    end
end

