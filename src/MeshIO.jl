
function readObj(path::String)
    meshData = MeshData([], [], [], [])
    f = open(path)
    while(!eof(f))
        line = readline(f)
        s = split(line, " ")
        if s[1] == "v"
            vec = [Meta.parse(i) for i in s[2:end]]
            push!(meshData.positions, vec)
        elseif s[1] == "vt"
            vec = [Meta.parse(i) for i in s[2:end]]
            push!(meshData.uvs, vec)
        elseif s[1] == "vn"
            vec = [Meta.parse(i) for i in s[2:end]]
            push!(meshData.normals, vec)
        elseif s[1] == "f"
            if contains(line, "//")
                faceidxs = []
                for i in s[2:end]
                    (p, n) = [Meta.parse(j) for j in split(i, "//")]
                    push!(faceidxs, (p, n))
                end
                push!(meshData.indices, [Index(p, -1, n) for (p, n) in faceidxs])
            elseif contains(line, "/")
                faceidxs = []
                for i in s[2:end]
                    (p, u, n) = [Meta.parse(j) for j in split(i, "/")]
                    push!(faceidxs, (p, u, n))
                end
                push!(meshData.indices, [Index(idx...) for idx in faceidxs])
            else 
                indices = [Index(Meta.parse(i), -1, -1) for i in s[2:end]]
                push!(meshData.indices, indices)
            end
        end
    end
    return meshData
end
            
# Dummy Vertex 
# TODO remove


# mutable struct Vertex
	# he pointer
	# position 3D vector
	# phi distance
	# index among total number of vertices
	# isIsolated() const 
	# dualArea() const # returns area of barycentric dual cell associated with the vertex
	# onBoundary const
#	he # can be simple vector or itertools::PeekIter
#	position # this is clear 3D vector
#	phi::Float64
#	int::UInt64
#	function Vertex()
#		new(PeekIter(HalfEdge[]), nothing, -1.0, 0)
#	end
# end

function isIsolated(v::Vertex)
	# use peek strategy here.
	if peek(v.he) != nothing
		return false
	end
	return true
end


using IterTools: PeekIter, peekiter

# WiP
function buildMesh(meshdata::MeshData)
    mesh = Mesh()
    edgeCount = Dict{Tuple{Int, Int}, Int}()
    existingHalfEdges = Dict{Tuple{Int, Int}, HalfEdge}()
    indexToVertex = Dict{Int, Vertex}()
    hasFlipEdge = Dict{HalfEdge, Bool}()

    for (i, pos) in enumerate(meshdata.positions)
        vertex = Vertex()
        vertex.position = pos
    	push!(mesh.vertices, vertex)
    	indexToVertex[i] = vertex
    end

    # uvs = peekiter(meshdata.uvs) # TODO not necessary but gaurds assignment
    for uv in meshdata.uvs # TODO enumerate is not necessary
    	push!(mesh.uvs, uv)
    end

    # normals = peekiter(meshdata.uvs)
    for normal in meshdata.normals # TODO enumerate is not necesarry
    	push!(mesh.normals, normal)
    end

	faceIndex = 0
	degenerateFaces = false

	function isDegenerate(indices)
		if length(indices) < 3
			@error "Degenerate Face at index $faceIndex found!"
		end
		return length(indices)
	end

    # Walking through each face indices
	for indices in meshdata.indices
        # Checks and returns number of indices
		n = isDegenerate(indices)
        newFace = Face()
        push!(mesh.faces, newFace)
		halfEdges = []
	
        # Walking through each index of a face
		for i in 1:n
            halfEdge = HalfEdge()
			push!(halfEdges, halfEdge) # Think of this as local
			push!(mesh.halfEdges, halfEdge) # Think of this as global
		end

		for i in 1:n
			# Vertex indices a and b
            a = Int(indices[i].position)
            b = Int(indices[i%n + 1].position)

			# Set Halfedge attributes
            halfEdges[i].next = halfEdges[i%n + 1]
            halfEdges[i].vertex = indexToVertex[a]

			uv = indices[i].uv
			if uv >= 0
                halfEdges[i].uv = meshdata.uvs[uv]
			else
                halfEdges[i].uv = zeros(UInt64, 3) 
			end

			normal = indices[i].normal
			if normal >= 0
                halfEdges[i].normal = meshdata.normals[normal]
			else
                halfEdges[i].normal = zeros(UInt64, 3)
			end

            halfEdges[i].onBoundary = false;

			hasFlipEdge[halfEdges[i]] = false

            indexToVertex[a].he = halfEdges[i]
			
            halfEdges[i].face  = newFace
			newFace.he = halfEdges[i]

			# for unique keys
            key = a > b ? (b, a) : (a, b)
            
            if key in keys(existingHalfEdges)
				halfEdges[i].twin = existingHalfEdges[key]
				halfEdges[i].twin.twin = halfEdges[i]
				halfEdges[i].edge = halfEdges[i].twin.edge
				hasFlipEdge[halfEdges[i]] = true
				hasFlipEdge[halfEdges[i].twin] = true;
			else
				edge = Edge()
				halfEdges[i].edge = edge
                halfEdges[i].edge.he = halfEdges[i]
				push!(mesh.edges, edge)
				edgeCount[key] = 0;
			end

			existingHalfEdges[key] = halfEdges[i]

            edgeCount[key] += 1

			if edgeCount[key] > 2
                @error "Error: edge ($a, $b) is non manifold count: $edgeCount[(a, b)]" 
		    	return false
			end
		end
		faceIndex += 1
	end

	if (degenerateFaces)
		return false
    end

	for currentHE in mesh.halfEdges
		if(!hasFlipEdge[currentHE])
			newFace = Face()
			push!(mesh.faces, newFace)
            firstrun = true
            he = currentHE
            boundaryCycle = []

            while(firstrun || he != currentHE)
                firstrun = false
                
                newHE = HalfEdge()
                newHE.onBoundary = true
                push!(mesh.halfEdges, newHE)
                he.twin = newHE

                nextHE = he.next

                while(hasFlipEdge[nextHE])
                    nextHE = nextHE.twin.next
                end

                newHE.twin = he
                newHE.vertex = nextHE.vertex
                newHE.edge = he.edge
                newHE.face = newFace
                newHE.uv = nextHE.uv

                newFace.he = newHE
                push!(boundaryCycle, newHE)
                he = nextHE
            end

            bn = length(boundaryCycle)

            for i in 1:bn
                boundaryCycle[i].next = boundaryCycle[(i+bn-2)%bn + 1]
                hasFlipEdge[boundaryCycle[i]] = true
                hasFlipEdge[boundaryCycle[i].twin] = true
            end
            push!(mesh.boundaries, boundaryCycle...)
        end
    end
    return mesh
end

# TODO tasks
# Check isolated vertices
# Check non manifold vertices
# return true
#
