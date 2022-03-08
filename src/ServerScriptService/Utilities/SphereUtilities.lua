local SphereUtilities = {}

--returns the distance between 2 points in 3d space (r)
SphereUtilities.getDistance = function(point1,point2)
	
	local x1 = point1.X - point2.X
	local y1 = point1.Y - point2.Y
	local z1 = point1.Z - point2.Z
	
	local dist = math.sqrt(x1^2 + y1^2 + z1^2)
	return dist
	
end

--returns the angle a point is away from the x axis (theta)
SphereUtilities.getXZ = function(point1,point2)
	
	local x1 = point1.X - point2.X
	local y1 = point1.Y - point2.Y
	local z1 = point1.Z - point2.Z
	
	local angle = math.acos(y1/SphereUtilities.getDistance(point1,point2))
	return angle
	
end

--returns the angle a point is away from the y axis (phi)
SphereUtilities.getXY = function(point1,point2)
	
	local x1 = point1.X - point2.X
	local y1 = point1.Y - point2.Y
	local z1 = point1.Z - point2.Z
	
	local angle
	if x1 > 0 then
		angle = math.atan(z1/x1)
	elseif x1 < 0 and z1 >= 0 then
		angle = math.atan(z1/x1) + math.pi
	elseif x1 < 0 and z1 < 0 then
		angle = math.atan(z1/x1) - math.pi
	elseif x1 == 0 and z1 > 0 then
		angle = math.pi/2 * (1)
	elseif x1 == 0 and z1 < 0 then
		angle = math.pi/2 * (-1)
	else
		angle = 0
	end

	return angle
	
end

--returns rectangular coordinates from spherical inputs, relative to (0,0,0) on coordinate plane
SphereUtilities.sphereToRect = function(r,phi,theta)
	
	local x1 = r*math.cos(phi)*math.sin(theta)
	local z1 = r*math.sin(phi)*math.sin(theta)
	local y1 = r*math.cos(theta)
	
	local sphereVector = Vector3.new(x1,y1,z1)
	return sphereVector
	
end

--returns rectangular coordinates from spherical inputs, relative to a provided reference point (x,y,z)
SphereUtilities.sphereToRect2 = function(r,phi,theta,reference)
	
	local x1 = r*math.cos(phi)*math.sin(theta) + reference.X
	local z1 = r*math.sin(phi)*math.sin(theta) + reference.Z
	local y1 = r*math.cos(theta) + reference.Y

	local sphereVector = Vector3.new(x1,y1,z1)
	return sphereVector
	
end

return SphereUtilities