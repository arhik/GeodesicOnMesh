# Comment section
#

function readMesh(file::String)
    readObj(file)
end

function buildLaplacian(mesh::Mesh, sparseM)
    for v in mesh.vertices
        # if v.index == 1
        #     @show v.he.vertex.position
        # end
        sumCoefficients = 0.0
        firstrun = true
        he = v.he
        while (firstrun || v.he != he)
            firstrun = false
            # if v.index == 1
            #     @show cotan(he)
            #     @show cotan(he.twin)
            # end
            coefficient = 0.5*(cotan(he) + cotan(he.twin))
            
            sumCoefficients += coefficient
            sparseM[v.index, he.twin.vertex.index] += coefficient
            he = he.twin.next
        end
        sparseM[v.index, v.index] = -sumCoefficients
    end
    mesh.sparseM = sparseM
end


function buildAreaMatrix(mesh::Mesh, sparseM)
    for v in mesh.vertices
        sparseM[v.index, v.index] = dualArea(v)
    end
    mesh.sparseA = sparseM
end

function computeTimeStep(mesh::Mesh)
    avgLength = 0.0;
    n = length(mesh.edges)
    for e in mesh.edges
        avgLength += edgeLength(e)
    end
    avgLength /= n
    # @show avgLength
    return avgLength^2
end

function computeFaceGradients(mesh::Mesh, gradients, u)
    for f in mesh.faces
        if !isBoundary(f)
            gradient = zeros(3)
            fnormal = faceNormal(f)
            normalize!(fnormal)
            firstrun = true
            he = f.he
            while firstrun || he != f.he
                firstrun = false
                ui = u[he.next.next.vertex.index]
                ei = he.next.vertex.position .- he.vertex.position
                gradient += ui*cross(fnormal, ei)
                he = he.next
            end
            # if f.index == 1
            #     @show faceArea(f)
            # end
            gradient ./= (2.0*faceArea(f))
            # @show gradient
            normalize!(gradient)
            # @show gradient
            gradients[f.index, :] .= -gradient
        end
    end
end

function computeIntegratedDivergence(mesh::Mesh, integratedDivs, gradients)
    for v in mesh.vertices
        integratedDiv = 0.0
        p = v.position
        he = v.he
        firstrun = true
        while firstrun || he != v.he
            firstrun = false
            if(!he.onBoundary)
                gradient = gradients[he.face.index, :]
                
                p1 = he.next.vertex.position
                p2 = he.next.next.vertex.position

                e1 = p1 .- p
                e2 = p2 .- p
                ei = p2 .- p1

                θ1 = acos(dot(-e2, -ei)/(norm(e2)*norm(ei)))
                cot1 = 1/tan(θ1)

                θ2 = acos(dot(-e1, ei)/(norm(e1)*norm(ei)))
                cot2 = 1/tan(θ2)
                
                integratedDiv += dot(e1, gradient)*cot1 + dot(e2, gradient)*cot2
            end
            he = he.twin.next
        end
        integratedDivs[v.index] = 0.5*integratedDiv
    end
end

function setup(mesh::Mesh)
    n = length(mesh.vertices)
    L = spzeros(n, n)
    buildLaplacian(mesh, L)
    sparseM = ldlt(L)
    @assert issuccess(sparseM) == true
    A = spzeros(n, n)
    buildAreaMatrix(mesh, A)

    t = computeTimeStep(mesh)
    sparseA = cholesky(A .- t.*L)
    mesh.sparseA = sparseA
    mesh.sparseM = sparseM
end

function computeGeodesics(mesh, vIdx)
    n = length(mesh.vertices)
    
    # Set random point on mesh to 1
    δ = zeros(n)
    δ[vIdx] = 1.0

    u = mesh.sparseA \ sparse(δ)

    # @show u
    # 2. Evaluate Face Gradients
    gradients = zeros(length(mesh.faces), 3)
    computeFaceGradients(mesh, gradients, u)
    # 3. Solve poisson equation
    integratedDivs = zeros(n)
    computeIntegratedDivergence(mesh, integratedDivs, gradients)
    phis = mesh.sparseM\integratedDivs
    minPhi = minimum(phis)
    maxPhi = maximum(phis)

    range = maxPhi - minPhi

    for v in mesh.vertices
        v.phi = 1 - (phis[v.index] - minPhi)/range
    end
end


function normalizeMesh!(mesh)
    # Compute center of mass
    cm = zeros(3)
    for v in mesh.vertices
        cm .+= v.position
    end

    cm ./= length(mesh.vertices)
    #
    # translate to origin
    for v in mesh.vertices
        v.position .-= cm
    end
    
    # determine radius
    rMax = 0.0
    for v in mesh.vertices
        rMax = max(rMax, norm(v.position))
    end
    #
    # rescale to unit sphere
    for v in mesh.vertices
        v.position ./= rMax
    end
end

    





