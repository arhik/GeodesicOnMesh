# Half Edge looks central
# Make sure we understand it properly
# TODO cover Types.h

# Course 
# Split every edge into half edge
# Each halfedge knows about its twin
# It know next halfedge
# Knows vertex it comes from (outgoing halfedge)
# it knows the face it belongs to
# it Edge it belongs to.

# All other mesh elements just store one reference to half edge.

# Vertex will have reference to one halfedge
# Edge will have one reference to halfedge
# Face will have reference to one half edge.


# TODO 
function cotan(he::HalfEdge)
	if he.onBoundary
		return 0.0
	end
	p0 = he.vertex.position
	p1 = he.next.vertex.position
	p2 = he.next.next.vertex.position

	v1 = p2 .- p1
	v2 = p2 .- p0

	return dot(v1, v2)/norm(cross(v1, v2)); # TODO should check norm
end


