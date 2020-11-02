# TODO needs HalfEdge defined
# TODO needs Vertex defined

function edgeLength(e::Edge, halfedge::HalfEdge)
    a = position(e, halfedge)
    b = position(e, halfedge, flip=true)
	return norm(b .- a)
end

function edgeLength(e::Edge)
    a = e.he.vertex.position
    b = e.he.twin.vertex.position
    return norm(b.-a)
end
