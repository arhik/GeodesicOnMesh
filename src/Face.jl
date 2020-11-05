

function isBoundary(f::Face)
	return f.he.onBoundary
end

function faceNormal(f::Face)
	a = f.he.vertex.position
	b = f.he.next.vertex.position
	c = f.he.next.next.vertex.position

	v1 = b .- a
	v2 = c .- a

	return cross(v1, v2)
end

function faceArea(f::Face)
 	if(isBoundary(f))
 		return 0
 	end
 	return 0.5*norm(faceNormal(f))
end



	
