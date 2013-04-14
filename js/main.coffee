enchant()

BEAR_IMG = 'chara1.png'
MAP_IMG = 'map1.png'
ASSETS = [BEAR_IMG]

canvasContext = null

TextSize = {
    Medium : {
        charWidth : 6
        fontSize : 20
    }
    Large : {
        charWidth : 11
        fontSize : 40
    }
}

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
    d = max - min
    min + Math.floor(Math.random() * d) % d

add = (inst) ->
    game.currentScene.addChild(inst)

remove = (inst) ->
    inst.onremove?()
    game.currentScene.removeChild(inst)

padding = (num) ->
    ('00' + num).substr(-2)

class Bear extends Sprite
    constructor: ->
        super(32, 32)
        @image = game.assets[BEAR_IMG]
        @x = game.width / 2
        @y = game.height / 2

        @vx = rand(-2, 2)
        @vy = rand(-2, 2)

        add(@)

    onenterframe: ->
        @x += @vx
        @y += @vy

        @vx = -@vx unless 0 <= @x and @x < game.width
        @vy = -@vy unless 0 <= @y and @y < game.height

class NicoLabel extends Label
    constructor: (x, y, color = '#ffffff', @textSize = TextSize.Medium) ->
        super
        @x = x
        @y = y
        @color = color
        @font = "bold #{@textSize.fontSize}px Arial"

        add(@)

    setText: (txt) ->
        @text = txt
        canvasContext.font = @font
        @width = canvasContext.measureText(@text).width;

class CountLabel extends NicoLabel
    constructor: (x, y) ->
        super(x, y)

        @_count = 0

        @label = ''

    @property 'count',
        get: -> @_count
        set: (c) ->
            @_count = c
            @setText("#{@label}#{@_count}")

class ComboLabel extends NicoLabel
    comboNum = 0

    lastComboFrame = 0

    constructor: (x, y) ->
        super(x, y, '#fff100')
        
        comboNum = 0 if game.frame - lastComboFrame > game.fps
        comboNum++

        @setText("Combo #{comboNum}")

        #timer.addTime(comboNum * 10)
        timer.addTime(10)

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
        @setText(@getTime())

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
        ontouch : (msg, e) -> new ComboLabel(e.x, e.y)
        onleave : -> life.count -= 1
    }
}
class Message extends NicoLabel
    constructor: (x, y, text, @msgType) ->
        super(x, y, @msgType.color, TextSize.Large)
        @setText(text)

    ontouchstart: (e) ->
        @msgType.ontouch?(@, e)
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

class ShitaMessage extends Message
    MAX_INDEX = 4
    _index = 0

    constructor: (text, msgType) ->
        super(0, 0, text, msgType)
        @x = (game.width - @width) / 2
        @y = game.height / 5 * (MAX_INDEX - _index)

        _index = (_index + 1) % (MAX_INDEX + 1)

    onenterframe: ->
        @leave() if @age > game.fps * 5

    onremove: ->
        _index = MAX_INDEX if --_index < 0

window.onload = ->
    canvasContext = document.getElementById('dummyCanvas').getContext('2d')

    game = new Game(500, 400)
    game.fps = 30
    game.preload(ASSETS)

    game.onload = ->
        scene = game.rootScene
        scene.backgroundColor = '#0f0f0f'

        scene.backgroundColor = '#00ff00'

        new Bear for i in [1..10]

        timer = new TimerLabel(0, 0)

        life = new CountLabel(100, 0)
        life.label = 'Life : '
        life.count = 1
        
        gameover = false
        probabilities = [
            [5, -> new StreamMessage('wwwwwwwwwwww', MessageType.Normal)]
            [3, -> new StreamMessage('mmmmmmmmmmmm', MessageType.Illegal)]
            [1, -> new ShitaMessage('熊大人気ｗｗｗ', MessageType.Normal)]
            [1, -> new ShitaMessage('爆発汁', MessageType.Illegal)]
        ]
        scene.onenterframe = ->
            if game.frame % game.fps == 0
                for i in [0..Math.min(timer.getMinute() + 1, 5)]
                    sum = 0
                    sum += p[0] for p in probabilities
                    r = rand(sum) + 1
                    sum = 0
                    for p in  probabilities
                        sum += p[0]
                        if r <= sum
                            p[1]()
                            break

            if life.count == 0 and not gameover
                #game.end(timer.count, "再生時間 #{timer.getTime()}")
                alert "ゲームオーバー\n再生時間 #{timer.getTime()}"
                gameover = true

    game.start()