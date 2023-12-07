-- Script property of Wicky

--=================================
--		 MAIN SCRIPT
--=================================

local opacity = 0.03 --透明度

local BeatBarObjPool = nil
local _ArrowTexture = nil
local _ArrowSprite = nil

local function KeepBeatBar()
	if BeatBarObjPool then
		local parentTransform = BeatBarObjPool.transform
		for i = 0, parentTransform.childCount - 1 do
			local childTransform = parentTransform:GetChild(i)
			local childGameObject = childTransform.gameObject
			local meshRenderer = childGameObject:GetComponent(typeof(WGLUnityEngine.MeshRenderer))
			meshRenderer.sortingOrder = 10
		end
	end
end

local _padSpriteObj = nil

function ArrowPath_onloaded(WickyCanvas)

	BeatBarObjPool = WGLGameObject.Find("BeatBarObjectPool")

	_ArrowTexture = UTIL:LoadTexture("G_ArrowSprite.png")
	_ArrowSprite = UTIL:CreateSprite(_ArrowTexture)
	local padSprite = WGLGameObject.Instantiate(LaneSpritePrefab)
	padSprite:SetColor(1, 1, 1, opacity)
	padSprite:SetLanePosition(3)
	padSprite:SetSortingLayer(2)
	local padSpriteObj = padSprite.gameObject
	padSpriteObj.transform.localScale = WGLVector3(7, 0.8, 0)
	padSpriteObj.transform.localPosition = WGLVector3(0, 0, 5)
	local padSpriteComp = padSpriteObj:GetComponent(typeof(WGLUnityEngine.SpriteRenderer))
	padSpriteComp.sprite = _ArrowSprite
	_padSpriteObj = padSpriteObj

end

local function Pad_PlayAnimation()
	_padSpriteObj.transform.localPosition = _padSpriteObj.transform.localPosition - WGLVector3(0, 0, 0.01)
	if _padSpriteObj.transform.localPosition.z <= 2.12 then
		_padSpriteObj.transform.localPosition = WGLVector3(0, 0, 5)
	end
end

function ArrowPath_update()
	KeepBeatBar()
	Pad_PlayAnimation(0)
end