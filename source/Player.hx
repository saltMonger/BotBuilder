package;

import flixel.system.FlxSound;
import haxe.io.Float32Array;
import lime.text.Font;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.FlxSprite;

enum PlayerMode
{
    CURSOR;
    BUILD;
    ROAD;
    MANAGE;
    DESTROY;
}

enum BuildingSelect
{
    ORE;
    REFINERY;
    BADGE;
    POWER;
    HOUSE;
    MARKET;
}

class Player extends FlxSprite
{
    static inline var SPEED:Float = 200;

    public var playerMode:PlayerMode;
    public var buildingSelect:BuildingSelect;

    //-- weird global ref...
    public var playState:PlayState;

    public var colSprite:FlxSprite;
    public var colSprite2:FlxSprite;
    public var buildSprite:FlxSprite;

    var upgradePressedTimes:Int;
    var destroyPressedTimes:Int;

    var isWinner:Bool = false;

    var errorSound:FlxSound;

    public function new(pX:Float = 0, pY:Float = 0)
    {
        super(pX, pY);
        loadGraphic(AssetPaths.pointer__png, false, 16, 16);
        drag.x = drag.y = 1600;
        playerMode = PlayerMode.CURSOR;
        buildingSelect = BuildingSelect.ORE;
        colSprite = new FlxSprite(pX, pY);
        colSprite2 = new FlxSprite(pX, pY);
        buildSprite = new FlxSprite(pX, pY);
        colSprite.makeGraphic(1, 1, 0xFF0000FF);
        colSprite2.makeGraphic(1, 1, 0x0000FFFF);
        buildSprite.loadGraphic(AssetPaths.oreextractorhover__png, false, 16, 16);
        buildSprite.alpha = 0;
        colSprite.drag.x = colSprite.drag.y = 1600;
        upgradePressedTimes = 0;
        destroyPressedTimes = 0;
        errorSound = FlxG.sound.load(AssetPaths.botberror__ogg);
    }

    function updateMovement()
    {
        var up:Bool = false;
        var down:Bool = false;
        var left:Bool = false;
        var right:Bool = false;
        var fast:Bool = FlxG.keys.anyPressed([SHIFT]);

        if (fast)
        {
            up = FlxG.keys.anyPressed([UP,W]);
            down = FlxG.keys.anyPressed([DOWN, S]);
            left = FlxG.keys.anyPressed([LEFT, A]);
            right = FlxG.keys.anyPressed([RIGHT, D]);
        }
        else
            {
            up = FlxG.keys.anyJustPressed([UP,W]);
            down = FlxG.keys.anyJustPressed([DOWN, S]);
            left = FlxG.keys.anyJustPressed([LEFT, A]);
            right = FlxG.keys.anyJustPressed([RIGHT, D]);
        }

        // cancel opposing directions
        if (up && down)
        {
            up = down = false;
        }
        
        if (right && left) 
        {
            right = left = false;
        }

        if (up)
        {
            y -= 16;
            colSprite.y -= 16;
            colSprite2.y -= 16;
            buildSprite.y -= 16;
        }
        else if (down)
        {
            y += 16;
            colSprite.y += 16;
            colSprite2.y += 16;
            buildSprite.y += 16;
        }

        if (right)
        {
            x += 16;
            colSprite.x += 16;
            colSprite2.x += 16;
            buildSprite.x += 16;
        }
        else if (left)
        {
            x -= 16;
            colSprite.x -= 16;
            colSprite2.x -= 16;
            buildSprite.x -= 16;
        }
    }

    function updateGameMode()
    {
        var buildKey:Bool; 
        var roadKey:Bool;
        var manageKey:Bool;
        var cursorKey:Bool = false;
        var destroyKey:Bool;
        buildKey = FlxG.keys.anyJustPressed([B]);
        //roadKey = FlxG.keys.anyJustPressed([R]);
        manageKey = FlxG.keys.anyJustPressed([M, TAB]);
        destroyKey = FlxG.keys.anyJustPressed([T]);

        if (playerMode != PlayerMode.CURSOR)
        {
            cursorKey = FlxG.keys.anyJustPressed([ESCAPE]);
        }

        if (buildKey)
        {
            playerMode = PlayerMode.BUILD;
            loadGraphic(AssetPaths.pointerbuildmode__png, false, 16, 16);
            buildSprite.alpha = 1.0;
        }
        // else if (roadKey)
        // {
        //     buildSprite.alpha = 0;
        //     playerMode = PlayerMode.ROAD;
        //     loadGraphic(AssetPaths.pointerroadmode__png, false, 16, 16);
        // }
        else if (cursorKey)
        {
            playerMode = PlayerMode.CURSOR;
            if (playState.statManager.getBadgesAmount() >= 1000)
            {
                loadGraphic(AssetPaths.pointerwin__png, false, 16, 16);
            }
            else
            {
                loadGraphic(AssetPaths.pointer__png, false, 16, 16);
            }
            buildSprite.alpha = 0;
        }
        else if (manageKey)
        {
            playerMode = PlayerMode.MANAGE;
            loadGraphic(AssetPaths.pointermanagemode__png, false, 16, 16);
            playState.readoutCam.focusOn(new FlxPoint(0, -600));
            buildSprite.alpha = 0;
        }
        else if (destroyKey)
        {
            playerMode = PlayerMode.DESTROY;
            loadGraphic(AssetPaths.pointerdestroymode__png, false, 16, 16);
            playState.playField.remove(buildSprite);
            buildSprite.alpha = 0;
        }
    }

    function doManageMode()
    {
        var returnToCursor:Bool = FlxG.keys.anyJustPressed([ESCAPE, TAB]);

        var zeroTradeOre:Bool = FlxG.keys.anyJustPressed([U]);
        var negativeTradeOre:Bool = FlxG.keys.anyJustPressed([I]);
        var positiveTradeOre:Bool = FlxG.keys.anyJustPressed([O]);
        var maxTradeOre:Bool = FlxG.keys.anyJustPressed([P]);

        var zeroTradeMetal:Bool = FlxG.keys.anyJustPressed([J]);
        var negativeTradeMetal:Bool = FlxG.keys.anyJustPressed([K]);
        var positiveTradeMetal:Bool = FlxG.keys.anyJustPressed([L]);
        var maxTradeMetal:Bool = FlxG.keys.anyJustPressed([SEMICOLON]);

        var zeroTradeBadges:Bool = FlxG.keys.anyJustPressed([M]);
        var negativeTradeBadges:Bool = FlxG.keys.anyJustPressed([COMMA]);
        var positiveTradeBadges:Bool = FlxG.keys.anyJustPressed([PERIOD]);
        var maxTradeBadges:Bool = FlxG.keys.anyJustPressed([SLASH]);

        if (returnToCursor)
        {
            playerMode = PlayerMode.CURSOR;
            loadGraphic(AssetPaths.pointer__png, false, 16, 16);
            playState.readoutCam.focusOn(new FlxPoint(0, -300));
            return;
        }

        //-- ore trade
        if (zeroTradeOre)
        {
            playState.statManager.addOreTrade(Std.int(-10000000000));
        }
        else if (negativeTradeOre)
        {
            playState.statManager.addOreTrade(-10);
        }
        else if (positiveTradeOre)
        {
            playState.statManager.addOreTrade(10);
        }
        else if (maxTradeOre)
        {
            playState.statManager.addOreTrade(Std.int(10000000000));
        }

        if (zeroTradeMetal)
        {
            playState.statManager.addMetalTrade(Std.int(-10000000000));
        }
        else if (negativeTradeMetal)
        {
            playState.statManager.addMetalTrade(-5);
        }
        else if (positiveTradeMetal)
        {
            playState.statManager.addMetalTrade(5);
        }
        else if (maxTradeMetal)
        {
            playState.statManager.addMetalTrade(Std.int(10000000000));
        }

        if (zeroTradeBadges)
        {
            playState.statManager.addBadgeTrade(Std.int(-10000000000));
        }
        else if (negativeTradeBadges)
        {
            playState.statManager.addBadgeTrade(-1);
        }
        else if (positiveTradeBadges)
        {
            playState.statManager.addBadgeTrade(1);
        }
        else if (maxTradeBadges)
        {
            playState.statManager.addBadgeTrade(Std.int(10000000000));
        }

        playState.updateHUDBadgeTradeText();
        playState.updateHUDOreTradeText();
        playState.updateHUDMetalTradeText();
    }

    function doBuildingBuild()
    {
        var buildingBuildPressed:Bool;
        buildingBuildPressed = FlxG.keys.anyJustPressed([SPACE, Z]);

        var switchOreExtractor:Bool = FlxG.keys.anyJustPressed([ONE]);
        var switchRefinery:Bool = FlxG.keys.anyJustPressed([TWO]);
        var switchBadgery:Bool = FlxG.keys.anyJustPressed([THREE]);
        var switchPowerStation:Bool = FlxG.keys.anyJustPressed([FOUR]);
        var switchHouse:Bool = false; //FlxG.keys.anyJustPressed([FIVE]);
        var switchMarket:Bool = FlxG.keys.anyJustPressed([FIVE]);

        if (playState.cursorOnBuilding != null)
        {
            buildSprite.alpha = 0;
            return;
        }

        buildSprite.alpha = 1.0;

        if (switchOreExtractor)
        {
            buildingSelect = BuildingSelect.ORE;
            buildSprite.loadGraphic(AssetPaths.oreextractorhover__png, false, 16, 16);
        }
        else if (switchRefinery)
        {
            buildingSelect = BuildingSelect.REFINERY;
            buildSprite.loadGraphic(AssetPaths.refineryhover__png, false, 16, 16);
        }
        else if (switchBadgery)
        {
            buildingSelect = BuildingSelect.BADGE;
            buildSprite.loadGraphic(AssetPaths.badgeryhover__png, false, 16, 16);
        }
        else if (switchPowerStation)
        {
            buildingSelect = BuildingSelect.POWER;
            buildSprite.loadGraphic(AssetPaths.powerstationhover__png, false, 16, 16);
        }
        else if (switchHouse)
        {
            buildingSelect = BuildingSelect.HOUSE;
        }
        else if (switchMarket)
        {
            buildingSelect = BuildingSelect.MARKET;
            buildSprite.loadGraphic(AssetPaths.markethover__png, false, 16, 16);
        }

        if (buildingBuildPressed)
        {
            //wip: update to be a palette or use build mode
            var building:BuildingBase;

            var pX:Float;
            var pY:Float;

            pX = x + 8;
            pY = y - 8;

            switch (buildingSelect)
            {
                case BuildingSelect.ORE:
                {
                    building = BuildingOreExtractor.basePurchase(pX, pY, playState.statManager, playState.cursorOnTile);
                }
                case BuildingSelect.REFINERY:
                {
                    building = BuildingRefinery.basePurchase(pX, pY, playState.statManager, playState.cursorOnTile);
                }
                case BuildingSelect.BADGE:
                {
                    building = BuildingBadgery.basePurchase(pX, pY, playState.statManager, playState.cursorOnTile);
                }
                case BuildingSelect.POWER:
                {
                    building = BuildingPowerPlant.basePurchase(pX, pY, playState.statManager, playState.cursorOnTile);
                }
                case BuildingSelect.HOUSE:
                {
                    building = BuildingOreExtractor.basePurchase(pX, pY, playState.statManager, playState.cursorOnTile);
                }
                case BuildingSelect.MARKET:
                {
                    building = BuildingMarket.basePurchase(pX, pY, playState.statManager, playState.cursorOnTile);
                }
            }

            if (building == null)
            {
                errorSound.play();
            }
            else
            {
                playState.buildings.add(building);
            }
        }
        playState.updateHUDCashText();
        playState.updateHUDOreText();
    }

    function doUpgrade()
    {
        var upgradePressed:Bool;
        upgradePressed = FlxG.keys.anyJustPressed([SPACE, Z]);

        if (playState.cursorOnBuilding == null)
        {
            return;
        }

        if (upgradePressed)
        {
            if (upgradePressedTimes == 0)
            {
                upgradePressedTimes += 1;
            }
            else if (upgradePressedTimes == 1)
            {
                upgradePressedTimes = 0;
                var upgraded = playState.cursorOnBuilding.upgrade();

                if (!upgraded)
                {
                    errorSound.play();
                }
            }
        }
    }

    function doDestroyMode()
    {
        var destroyBuildPressed:Bool;
        destroyBuildPressed = FlxG.keys.anyJustPressed([SPACE, Z]);

        if (playState.cursorOnBuilding == null)
        {
            return;
        }

        if (destroyBuildPressed)
        {
            if (destroyPressedTimes == 0)
            {
                destroyPressedTimes += 1;
            }
            else if (destroyPressedTimes == 1)
            {
                destroyPressedTimes = 0;
                playState.cursorOnBuilding.bulldoze();
                playState.buildings.remove(playState.cursorOnBuilding);
                playState.cursorOnBuilding = null;
                playState.updateHUDAllText();
                playState.updateHUDBuildingText("");
            }
        }
    }    

    function doRoadBuild()
    {
        var roadBuildPressed:Bool;
        roadBuildPressed = FlxG.keys.anyJustPressed([SPACE, Z]);

        if (roadBuildPressed)
        {
            if (!playState.statManager.purchased(10))
            {
                // add feedback later
                return;
            }

            var road:BuildingRoad;
            road = new BuildingRoad(x + 8, y - 8, playState.statManager);
            playState.buildings.add(road);
            playState.updateHUDCashText();
        }
    }


    override function update(elapsed:Float) 
    {
        updateMovement();

        if (playerMode != PlayerMode.MANAGE)
        {
            updateGameMode();
        }
        else
        {
            doManageMode();
        }
        
        if (playerMode == PlayerMode.ROAD)
        {
            doRoadBuild();
        }

        if (playerMode == PlayerMode.BUILD)
        {
            doBuildingBuild();
        }

        if (playerMode == PlayerMode.CURSOR)
        {
            doUpgrade();
        }

        if (playerMode == PlayerMode.DESTROY)
        {
            doDestroyMode();
        }

        super.update(elapsed);    
    }
}