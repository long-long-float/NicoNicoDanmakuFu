enchant()

BEAR_IMG = 'chara1.png'
ASSETS = []#[BEAR_IMG]

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

class CountLabel extends Label
    constructor: (x, y) ->
        super
        @x = x
        @y = y
        @color = '#ffffff'
        @font = 'bold 20px Arial'

        @_count = 0

        @label = ''

    @property 'count',
        get: -> @_count
        set: (c) ->
            @_count = c
            @text = "#{@label}#{@_count}"


class TimerLabel extends Label
    constructor: (x, y) ->
        super
        @x = x
        @y = y
        @color = '#ffffff'
        @font = 'bold 20px Arial'

        @count = 0
        @update()

    update: ->
        @text = "#{padding(Math.floor(@count / 60))}:#{padding(@count % 60)}"

    onenterframe: ->
        if game.frame % game.fps == 0
            @count++
            @update()

    addTime: (time) ->
        @count += time
        @count = 0 if @count < 0
        @update()

MessageType = {
    Normal : {
        color : '#ffffff'
        ontouch : -> timer.addTime(-10)
    }
    Illegal : {
        color : '#ff0000'
        #ontouch : -> timer.addTime(30)
        onleave : -> life.count -= 1
    }
}
class Message extends Label

    constructor: (x, y, text, @msg_type) ->
        super(text)
        @x = x
        @y = y

        @color = @msg_type.color
        @font = 'bold 40px Arial'
        #適当
        @width = 500

        add(@)

    ontouchstart: (e) ->
        @msg_type.ontouch?(@)
        remove(@)

    leave: ->
        @msg_type.onleave?(@)
        remove(@)

class StreamMessage extends Message
    constructor: (text, msg_type) ->
        super(game.width, 0, text, msg_type)
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

        scene.addChild(timer = new TimerLabel(0, 0))

        life = new CountLabel(100, 0)
        life.label = 'Life : '
        life.count = 10
        scene.addChild(life)
        
        scene.onenterframe = ->
            if game.frame % game.fps == 0
                for i in [1..5]
                    if rand(10) == 0
                        new StreamMessage('mmmmmmmmmmmm', MessageType.Illegal)
                    else
                        new StreamMessage('wwwwwwwwwwww', MessageType.Normal)

    game.start()