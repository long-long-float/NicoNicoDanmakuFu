enchant()

BEAR_IMG = 'chara1.png'
MAP_IMG = 'map1.png'
ASSETS = [BEAR_IMG, MAP_IMG]

game = null
timer = null
life = null

Function::property = (prop, desc) ->
    Object.defineProperty @prototype, prop, desc

rand = (min, max) ->
    unless max?
        max = min
        min = 0
    min = Math.floor(min)
    max = Math.floor(max)
    min + Math.floor(Math.random() * max) % (max - min)

add = (inst) ->
    game.currentScene.addChild(inst)

remove = (inst) ->
    game.currentScene.removeChild(inst)

padding = (num) ->
    ('00' + num).substr(-2)

class NicoLabel extends Label
    constructor: (x, y, color = '#ffffff', fontSize = 20) ->
        super
        @x = x
        @y = y
        @color = color
        @font = "bold #{fontSize}px Arial"

        add(@)

class CountLabel extends NicoLabel
    constructor: (x, y) ->
        super(x, y)

        @_count = 0

        @label = ''

    @property 'count',
        get: -> @_count
        set: (c) ->
            @_count = c
            @text = "#{@label}#{@_count}"

class ComboLabel extends NicoLabel
    comboNum = 0

    lastComboFrame = 0

    constructor: (x, y) ->
        super(x, y, '#fff100')
        
        comboNum = 0 if game.frame - lastComboFrame > game.fps
        comboNum++

        @text = "Combo #{comboNum}"

        timer.addTime(comboNum * 10)

        lastComboFrame = game.frame

        @MAX_AGE = 30

    onenterframe: ->
        @y -= 1
        @opacity = 1.0 - (@age / @MAX_AGE)

        remove(@) if @age > @MAX_AGE

class TimerLabel extends NicoLabel
    constructor: (x, y) ->
        super(x, y)

        @count = 0
        @update()

    update: ->
        @text = @getTime()

    onenterframe: ->
        if game.frame % game.fps == 0
            @count++
            @update()

    addTime: (time) ->
        @count += time
        @count = 0 if @count < 0
        @update()

    getMinute: ->
        Math.floor(@count / 60)

    getSecond: ->
        @count % 60

    getTime: ->
        "#{padding(@getMinute())}:#{padding(@getSecond())}"

MessageType = {
    Normal : {
        color : '#ffffff'
        ontouch : -> timer.addTime(-10)
    }
    Illegal : {
        color : '#ff0000'
        ontouch : (msg) ->
            new ComboLabel(msg.x, msg.y)
        onleave : -> life.count -= 1
    }
}
class Message extends NicoLabel
    constructor: (x, y, text, @msgType) ->
        super(x, y, @msgType.color, 40)
        @text = text
        #適当
        @width = 500

    ontouchstart: (e) ->
        @msgType.ontouch?(@)
        remove(@)

    leave: ->
        @msgType.onleave?(@)
        remove(@)

class StreamMessage extends Message
    constructor: (text, msgType) ->
        super(game.width, 0, text, msgType)
        @vx = -rand(2, 10)
        @y = rand(game.height - 50)

    onenterframe: ->
        @x += @vx
        @leave() if @x + @width < 0

window.onload = ->
    game = new Game(500, 400)
    game.fps = 30
    game.preload(ASSETS)

    game.onload = ->
        scene = game.rootScene
        scene.backgroundColor = '#0f0f0f'

        FLOOR_SIZE = 16
        for x in [0...game.width / FLOOR_SIZE]
            for y in [0...game.height / FLOOR_SIZE]
                grass = new Sprite(FLOOR_SIZE, FLOOR_SIZE)
                grass.image = game.assets[MAP_IMG]
                grass.frame = 1
                grass.x = x * FLOOR_SIZE
                grass.y = y * FLOOR_SIZE
                add(grass)

        bear = new Sprite(32, 32)
        bear.image = game.assets[BEAR_IMG]
        bear.x = game.width / 2
        bear.y = game.height / 2
        add(bear)

        timer = new TimerLabel(0, 0)

        life = new CountLabel(100, 0)
        life.label = 'Life : '
        life.count = 1
        
        gameover = false
        scene.onenterframe = ->
            if game.frame % game.fps == 0
                for i in [0..timer.getMinute() + 1]
                    if rand(10) == 0
                        new StreamMessage('mmmmmmmmmmmm', MessageType.Illegal)
                    else
                        new StreamMessage('wwwwwwwwwwww', MessageType.Normal)
            if life.count == 0 and not gameover
                #game.end(timer.count, "再生時間 #{timer.getTime()}")
                alert "ゲームオーバー\n再生時間 #{timer.getTime()}"
                gameover = true

    game.start()