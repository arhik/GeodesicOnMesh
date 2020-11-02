mutable struct Face
	he
	index
    function Face() 
        new(nothing, -1)
    end
end


function isBoundary(f::Face)
	return f.he.onBoundary
end

function normal(f::Face)
	a = he.vertex.position
	b = he.next.vertex.position
	c = he.next.next.vertex.position

	v1 = b .- a
	v2 = c .- a

	return cross(v1, v2)
end

function area(f::Face)
 	if(isBoundary(f))
 		return 0
 	end
 	return 0.5*norm(normal(f))
end



	
