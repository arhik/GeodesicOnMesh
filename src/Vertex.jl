# Vertex

function isIsolated(v::Vertex)
	v.he == nothing
end

function dualArea(v::Vertex)
	area = 0.0
	he = v.he
	firstrun = true
	while(firstrun || he != v.he)
		firstrun = false
		area += faceArea(he.face)
		he = he.twin.next
	end
	return area/3
end

function onBoundary(v::Vertex)
	he = v.he
	firstrun = true
	while(firstrun || he != v.he)
		firstrun = false
		if he.onBoundary
			return true
		end
		he = he.twin.next
	end
	return false
end
