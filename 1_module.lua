--著者: Wicky

WGLUnityEngine = CS.UnityEngine
WGLGameObject = WGLUnityEngine.GameObject
WGLVector2 = WGLUnityEngine.Vector2
WGLVector3 = WGLUnityEngine.Vector3
WGLColor = WGLUnityEngine.Color
WGLTime = WGLUnityEngine.Time
WGLMaterial = WGLUnityEngine.Material
WGLInput = WGLUnityEngine.Input
WGLResources = WGLUnityEngine.Resources

function ColorRGB(r, g, b)
	return WGLColor(r / 255, g / 255, b / 255)
end

function ColorRGBA(r, g, b, a)
	return WGLColor(r / 255, g / 255, b / 255, a)
end

function getAssetBundleFolderPath(platform)
	if (platform == 1) then
		return "bundles/Windows/"
	end
	if (platform == 2) then
		return "bundles/MacOS/"
	end
	if (platform == 3) then
		return "bundles/Android/"
	end
	if (platform == 4) then
		return "bundles/iOS/"
	end

	return "bundles/Other/"
end
