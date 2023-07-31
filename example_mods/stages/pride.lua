function onCreate()
	AAAmiddleScroll = getPropertyFromClass('ClientPrefs','middleScroll')
	setPropertyFromClass('ClientPrefs','middleScroll', true)

	makeLuaSprite('bg','',-300,50)
	makeGraphic('bg',1480,1020,'808080')
	addLuaSprite('bg')
end

function onCreatePost()

	setPropertyFromClass('ClientPrefs','middleScroll', AAAmiddleScroll)
	setProperty('boyfriend.visible', false)
end