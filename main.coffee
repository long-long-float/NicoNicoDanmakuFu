enchant()

BEAR_IMG = 'chara1.png'
ASSETS = [BEAR_IMG]

game = null

rand = (max) ->
    Math.floor(Math.random() * max)

add = (inst) ->
    game.currentScene.addChild(inst)

remove = (inst) ->
    game.currentScene.removeChild(inst)

class Message extends Label
    constructor: (x, y, text) ->
        super(text)
        @x = x
        @y = y
        @color = '#ffffff'
        @font = 'bold 24px Arial'

        add(@)

    ontouchstart: (e) ->
        remove(@)

class StreamMessage extends Message
    constructor: (text, @vx) ->
        super(game.width, rand(game.height), text)

    onenterframe: ->
        @x += @vx
        remove(@) if @x + @width < 0

window.onload = ->
    game = new Game(500, 500)
    game.fps = 30
    game.preload(ASSETS)

    game.onload = ->
        scene = game.rootScene
        scene.backgroundColor = '#0f0f0f'

        scene.onenterframe = ->
            if game.frame % game.fps == 0
                for i in [1..10]
                    new StreamMessage('wwwwwwwwwwww', -rand(10))

    game.start()