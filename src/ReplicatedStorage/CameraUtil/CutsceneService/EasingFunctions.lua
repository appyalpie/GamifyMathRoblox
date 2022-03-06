-- From: https://github.com/EmmanuelOga/easing

-- Info: https://developer.roblox.com/en-us/api-reference/enum/EasingStyle

-- t = elapsed time
-- b = begin
-- c = change, ending value - beginning value
-- d = duration
-- a = amplitud
-- p = period

local s = 1.70158
local pow = math.pow
local sin = math.sin
local cos = math.cos
local pi = math.pi
local sqrt = math.sqrt
local abs = math.abs
local asin = math.asin

local function Linear(t, b, c, d)
	return t / d
end

local function InQuad(t, b, c, d)
	return c * pow(t / d, 2) + b
end

local function OutQuad(t, b, c, d)
	t = t / d
	return -c * t * (t - 2) + b
end

local function InOutQuad(t, b, c, d)
	t = t / d * 2
	if t < 1 then
		return c / 2 * pow(t, 2) + b
	else
		return -c / 2 * ((t - 1) * (t - 3) - 1) + b
	end
end

local function OutInQuad(t, b, c, d)
	if t < d / 2 then
		return OutQuad(t * 2, b, c / 2, d)
	else
		return InQuad((t * 2) - d, b + c / 2, c / 2, d)
	end
end

local function InCubic(t, b, c, d)
	return c * pow(t / d, 3) + b
end

local function OutCubic(t, b, c, d)
	return c * (pow(t / d - 1, 3) + 1) + b
end

local function InOutCubic(t, b, c, d)
	t = t / d * 2
	if t < 1 then
		return c / 2 * t * t * t + b
	else
		t = t - 2
		return c / 2 * (t * t * t + 2) + b
	end
end

local function OutInCubic(t, b, c, d)
	if t < d / 2 then
		return OutCubic(t * 2, b, c / 2, d)
	else
		return InCubic((t * 2) - d, b + c / 2, c / 2, d)
	end
end

local function InQuart(t, b, c, d)
	return c * pow(t / d, 4) + b
end

local function OutQuart(t, b, c, d)
	return -c * (pow(t / d - 1, 4) - 1) + b
end

local function InOutQuart(t, b, c, d)
	t = t / d * 2
	if t < 1 then
		return c / 2 * pow(t, 4) + b
	else
		t = t - 2
		return -c / 2 * (pow(t, 4) - 2) + b
	end
end

local function OutInQuart(t, b, c, d)
	if t < d / 2 then
		return OutQuart(t * 2, b, c / 2, d)
	else
		return InQuart((t * 2) - d, b + c / 2, c / 2, d)
	end
end

local function InQuint(t, b, c, d)
	return c * pow(t / d, 5) + b
end

local function OutQuint(t, b, c, d)
	return c * (pow(t / d - 1, 5) + 1) + b
end

local function InOutQuint(t, b, c, d)
	t = t / d * 2
	if t < 1 then
		return c / 2 * pow(t, 5) + b
	else
		return c / 2 * (pow(t - 2, 5) + 2) + b
	end
end

local function OutInQuint(t, b, c, d)
	if t < d / 2 then
		return OutQuint(t * 2, b, c / 2, d)
	else
		return InQuint((t * 2) - d, b + c / 2, c / 2, d)
	end
end

local function InSine(t, b, c, d)
	return -c * cos(t / d * (pi / 2)) + c + b
end

local function OutSine(t, b, c, d)
	return c * sin(t / d * (pi / 2)) + b
end

local function InOutSine(t, b, c, d)
	return -c / 2 * (cos(pi * t / d) - 1) + b
end

local function OutInSine(t, b, c, d)
	if t < d / 2 then
		return OutSine(t * 2, b, c / 2, d)
	else
		return InSine((t * 2) -d, b + c / 2, c / 2, d)
	end
end

local function InExpo(t, b, c, d)
	if t == 0 then
		return b
	else
		return c * pow(2, 10 * (t / d - 1)) + b - c * 0.001
	end
end

local function OutExpo(t, b, c, d)
	if t == d then
		return b + c
	else
		return c * 1.001 * (-pow(2, -10 * t / d) + 1) + b
	end
end

local function InOutExpo(t, b, c, d)
	if t == 0 then return b end
	if t == d then return b + c end
	t = t / d * 2
	if t < 1 then
		return c / 2 * pow(2, 10 * (t - 1)) + b - c * 0.0005
	else
		t = t - 1
		return c / 2 * 1.0005 * (-pow(2, -10 * t) + 2) + b
	end
end

local function OutInExpo(t, b, c, d)
	if t < d / 2 then
		return OutExpo(t * 2, b, c / 2, d)
	else
		return InExpo((t * 2) - d, b + c / 2, c / 2, d)
	end
end

local function InCirc(t, b, c, d)
	return(-c * (sqrt(1 - pow(t / d, 2)) - 1) + b)
end

local function OutCirc(t, b, c, d)
	return(c * sqrt(1 - pow(t / d - 1, 2)) + b)
end

local function InOutCirc(t, b, c, d)
	t = t / d * 2
	if t < 1 then
		return -c / 2 * (sqrt(1 - t * t) - 1) + b
	else
		t = t - 2
		return c / 2 * (sqrt(1 - t * t) + 1) + b
	end
end

local function OutInCirc(t, b, c, d)
	if t < d / 2 then
		return OutCirc(t * 2, b, c / 2, d)
	else
		return InCirc((t * 2) - d, b + c / 2, c / 2, d)
	end
end

local function InElastic(t, b, c, d, a, p)
	if t == 0 then return b end
	t = t / d
	if t == 1 then return b + c end
	if not p then p = d * 0.3 end
	local s
	if not a or a < abs(c) then
		a = c
		s = p / 4
	else
		s = p / (2 * pi) * asin(c/a)
	end
	t = t - 1
	return -(a * pow(2, 10 * t) * sin((t * d - s) * (2 * pi) / p)) + b
end

local function OutElastic(t, b, c, d, a, p)
	if t == 0 then return b end
	t = t / d
	if t == 1 then return b + c end
	if not p then p = d * 0.3 end
	local s
	if not a or a < abs(c) then
		a = c
		s = p / 4
	else
		s = p / (2 * pi) * asin(c/a)
	end
	return a * pow(2, -10 * t) * sin((t * d - s) * (2 * pi) / p) + c + b
end

local function InOutElastic(t, b, c, d, a, p)
	if t == 0 then return b end
	t = t / d * 2
	if t == 2 then return b + c end
	if not p then p = d * (0.3 * 1.5) end
	if not a then a = 0 end
	local s
	if not a or a < abs(c) then
		a = c
		s = p / 4
	else
		s = p / (2 * pi) * asin(c / a)
	end
	if t < 1 then
		t = t - 1
		return -0.5 * (a * pow(2, 10 * t) * sin((t * d - s) * (2 * pi) / p)) + b
	else
		t = t - 1
		return a * pow(2, -10 * t) * sin((t * d - s) * (2 * pi) / p ) * 0.5 + c + b
	end
end

local function OutInElastic(t, b, c, d, a, p)
	if t < d / 2 then
		return OutElastic(t * 2, b, c / 2, d, a, p)
	else
		return InElastic((t * 2) - d, b + c / 2, c / 2, d, a, p)
	end
end

local function InBack(t, b, c, d)
	t = t / d
	return c * t * t * ((s + 1) * t - s) + b
end

local function OutBack(t, b, c, d)
	t = t / d - 1
	return c * (t * t * ((s + 1) * t + s) + 1) + b
end

local function InOutBack(t, b, c, d)
	t = t / d * 2
	if t < 1 then
		return c / 2 * (t * t * ((s + 1) * t - s)) + b
	else
		t = t - 2
		return c / 2 * (t * t * ((s + 1) * t + s) + 2) + b
	end
end

local function OutInBack(t, b, c, d)
	if t < d / 2 then
		return OutBack(t * 2, b, c / 2, d)
	else
		return InBack((t * 2) - d, b + c / 2, c / 2, d)
	end
end

local function OutBounce(t, b, c, d)
	t = t / d
	if t < 1 / 2.75 then
		return c * (7.5625 * t * t) + b
	elseif t < 2 / 2.75 then
		t = t - (1.5 / 2.75)
		return c * (7.5625 * t * t + 0.75) + b
	elseif t < 2.5 / 2.75 then
		t = t - (2.25 / 2.75)
		return c * (7.5625 * t * t + 0.9375) + b
	else
		t = t - (2.625 / 2.75)
		return c * (7.5625 * t * t + 0.984375) + b
	end
end

local function InBounce(t, b, c, d)
	return c - OutBounce(d - t, 0, c, d) + b
end

local function InOutBounce(t, b, c, d)
	if t < d / 2 then
		return InBounce(t * 2, 0, c, d) * 0.5 + b
	else
		return OutBounce(t * 2 - d, 0, c, d) * 0.5 + c * .5 + b
	end
end

local function OutInBounce(t, b, c, d)
	if t < d / 2 then
		return OutBounce(t * 2, b, c / 2, d)
	else
		return InBounce((t * 2) - d, b + c / 2, c / 2, d)
	end
end

return {
	Linear = Linear,
	InQuad = InQuad,
	OutQuad = OutQuad,
	InOutQuad = InOutQuad,
	OutInQuad = OutInQuad,
	InCubic  = InCubic ,
	OutCubic = OutCubic,
	InOutCubic = InOutCubic,
	OutInCubic = OutInCubic,
	InQuart = InQuart,
	OutQuart = OutQuart,
	InOutQuart = InOutQuart,
	OutInQuart = OutInQuart,
	InQuint = InQuint,
	OutQuint = OutQuint,
	InOutQuint = InOutQuint,
	OutInQuint = OutInQuint,
	InSine = InSine,
	OutSine = OutSine,
	InOutSine = InOutSine,
	OutInSine = OutInSine,
	InExponential = InExpo,
	OutExponential = OutExpo,
	InOutExponential = InOutExpo,
	OutInExponential = OutInExpo,
	InCircular = InCirc,
	OutCircular = OutCirc,
	InOutCircular = InOutCirc,
	OutInCircular = OutInCirc,
	InElastic = InElastic,
	OutElastic = OutElastic,
	InOutElastic = InOutElastic,
	OutInElastic = OutInElastic,
	InBack = InBack,
	OutBack = OutBack,
	InOutBack = InOutBack,
	OutInBack = OutInBack,
	InBounce = InBounce,
	OutBounce = OutBounce,
	InOutBounce = InOutBounce,
	OutInBounce = OutInBounce,
}