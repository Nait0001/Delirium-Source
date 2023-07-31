local pastFrameName = nil
local pastDadFrameName = nil

function onCreatePost()
    updatePerson()
end

function goodNoteHit(id, direction, noteType, isSustainNote)
    if isSustainNote == false and getProperty('boyfriend.visible') then
        updateColorPerson()
        if pastFrameName ~= nil then
            setProperty('boyfriendTrail.animation.frameName', pastFrameName)
            setProperty('boyfriendTrail.offset.x', pastFrameX)
            setProperty('boyfriendTrail.offset.y', pastFrameY)
            setProperty('boyfriendTrail.alpha', 1)
            doTweenAlpha('boyfriendTrailAlpha', 'boyfriendTrail', 0, 0.4)
            cancelTimer('framingnt')
        end
        pastFrameName = getProperty('boyfriend.animation.frameName')
        pastFrameX = getProperty('boyfriend.offset.x')
        pastFrameY = getProperty('boyfriend.offset.y')
        runTimer('framingnt', 0.05, 1)
    end
end

function opponentNoteHit(id, direction, noteType, isSustainNote)
    if isSustainNote == false and getProperty('dad.visible') then
        updateColorPerson()
        if pastDadFrameName ~= nil then
            setProperty('dadTrail.animation.frameName', pastDadFrameName)
            setProperty('dadTrail.offset.x', pastDadFrameX)
            setProperty('dadTrail.offset.y', pastDadFrameY)
            setProperty('dadTrail.alpha', 1)
            doTweenAlpha('dadTrailAlpha', 'dadTrail', 0, 0.4)
            cancelTimer('framingntDad')
        end
        pastDadFrameName = getProperty('dad.animation.frameName')
        pastDadFrameX = getProperty('dad.offset.x')
        pastDadFrameY = getProperty('dad.offset.y')
        runTimer('framingntDad', 0.03, 1)
    end
end

function onEvent(n,v1,v2)
    if (n == 'Change Character') then
        updatePerson()
    end
end

function onTimerCompleted(tag)
    if tag == 'framingnt' then
        pastFrameName = nil
    end

    if tag == 'framingntDad' then
        pastDadFrameName = nil
    end
end

function updateColorPerson()
    setProperty('boyfriendTrail.color',getProperty('boyfriend.color'))
    setProperty('dadTrail.color',getProperty('dad.color'))
end

function updatePerson()
    removeLuaSprite('boyfriendTrail')
    removeLuaSprite('dadTrail')

    makeAnimatedLuaSprite('boyfriendTrail', getProperty('boyfriend.imageFile'),getProperty('boyfriend.x'),getProperty('boyfriend.y'))
    addLuaSprite('boyfriendTrail', false)
    setProperty('boyfriendTrail.scale.x',getProperty('boyfriend.scale.x'))
	setProperty('boyfriendTrail.scale.y',getProperty('boyfriend.scale.y'))
	setProperty('boyfriendTrail.flipX', getProperty('boyfriend.flipX'))
	setProperty('boyfriendTrail.alpha', 0)
    setObjectOrder('boyfriendTrail',  getObjectOrder('boyfriendTrail')+1)

    makeAnimatedLuaSprite('dadTrail', getProperty('dad.imageFile'),getProperty('dad.x'),getProperty('dad.y'))
    addLuaSprite('dadTrail', false)
    setProperty('dadTrail.scale.x',getProperty('dad.scale.x'))
	setProperty('dadTrail.scale.y',getProperty('dad.scale.y'))
	setProperty('dadTrail.flipX', getProperty('dad.flipX'))
	setProperty('dadTrail.alpha', 0)
    setObjectOrder('dadTrail',  getObjectOrder('dadTrail')+1)
end