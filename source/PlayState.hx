package;

import flixel.math.FlxPoint;
import flixel.addons.text.FlxTypeText;
import flixel.util.FlxTimer;
import flixel.tile.FlxTile;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.util.FlxFSM.FlxFSMStack;
import flixel.system.debug.interaction.tools.Pointer.GraphicCursorCross;
import flixel.addons.util.FlxFSM.FlxFSMState;
import flixel.group.FlxGroup;
import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.tile.FlxTilemap;
import flixel.text.FlxText;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;

// FlxState is like a scene in other game engines
// Only one state is active at a time, just like a Unity scene or whatever

class PlayState extends FlxState
{

	var player:Player;
	var map:FlxOgmo3Loader;
	var walls:FlxTilemap;
	public var statManager:StatManager;
	var stateTimer:FlxTimer;

	public var playField:FlxGroup;

	public var buildings:FlxTypedGroup<BuildingBase>;


	var readoutText:FlxText;
	var boonsText:FlxText;
	var oreText:FlxText;
	var metalText:FlxText;
	var badgesText:FlxText;
	var buildingText:FlxText;

	var oreTradeText:FlxText;
	var metalTradeText:FlxText;
	var badgesTradeText:FlxText;

	var powerSprite:FlxSprite;

	var powerText:FlxText;
	var hud:FlxGroup;

	var totalHeight:Int = 240;
	var totalWidth:Int = 320;

	public var cursorOnTile:Int = 0;

	public var readoutCam:FlxCamera;

	public var cursorOnBuilding:BuildingBase;
	public var cursorOnBuildingX:Float;
	public var cursorOnBuildingY:Float;


	override public function create()
	{
		// stat manager setup
		statManager = new StatManager();
		//-- starting boons
		//wip: should be 1000
		statManager.addCash(30000);
		//-- make sure we register playstate for HUD updating
		statManager.playState = this;

		stateTimer = new FlxTimer();
		playField = new FlxGroup();

		// map/wall/room loader
		map = new FlxOgmo3Loader(AssetPaths.turnBasedRPG__ogmo, AssetPaths.room_001__json);
		walls = map.loadTilemap(AssetPaths.tileatlas__png, "walls");
		walls.follow();
		walls.setTileProperties(0, FlxObject.ANY);
		walls.setTileProperties(1, FlxObject.ANY);
		walls.setTileProperties(2, FlxObject.ANY);
		walls.setTileProperties(3, FlxObject.ANY);
		walls.setTileProperties(4, FlxObject.ANY);
		walls.setTileProperties(5, FlxObject.ANY);
		walls.setTileProperties(6, FlxObject.ANY);
		walls.setTileProperties(7, FlxObject.ANY);
		playField.add(walls);

		//building loader
		buildings = new FlxTypedGroup<BuildingBase>();
		playField.add(buildings);

		//player loader
		player = new Player();
		player.playState = this;
		map.loadEntities(placeEntities, "entities");
		playField.add(player.buildSprite);
		playField.add(player);
		playField.add(player.colSprite2);

		var fieldCam = createCamera(0, -40, Std.int(FlxG.width), Std.int(FlxG.height), 0xFF000000, 1.0);
		readoutCam = createCamera(0, FlxG.height - 40, Std.int(FlxG.width), 80, 0xE1416900, 1.0);

		readoutCam.focusOn(new FlxPoint(0, -300));

		playField.camera = fieldCam;
		// follow character
		playField.camera.follow(player, TOPDOWN, 1);
		playField.camera.zoom = 2.0;
		add(playField);
		FlxG.cameras.reset(fieldCam);
		FlxG.cameras.add(readoutCam);
		createHUD(readoutCam);
		super.create();
		stateTimer.start(5, statManager.tickUpdate, 0);

		if (FlxG.sound.music == null)
		{
			FlxG.sound.playMusic(AssetPaths.buildmode__ogg, 1, true);
		}
		
		updateHUDAllText();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		FlxG.overlap(player.colSprite2, buildings, hoverCursorBuildings);
		walls.overlapsWithCallback(player.colSprite, hoverCursor);

		if ((player.colSprite2.x != cursorOnBuildingX) || (player.colSprite2.y != cursorOnBuildingY))
		{
			cursorOnBuilding = null;
			updateHUDBuildingText("");
		}
	}
	
	function placeEntities(entity:EntityData)
	{
		var x = entity.x;
		var y = entity.y;

		switch (entity.name)
		{
			case "player":
			{
				player.setPosition(x, y);
				player.colSprite.setPosition(x, y - 16);
				player.colSprite2.setPosition(x + 16, y);
				player.buildSprite.setPosition(x + 8, y - 8);
			}
		}
	}

	function createCamera(X:Int, Y:Int, W:Int, H:Int, C:Int, Z:Float):FlxCamera
	{
		var camera:FlxCamera = new FlxCamera(X,Y , W, H, Z);
		camera.bgColor = C;
		return camera;	
	}

	function createHUD(readoutCamera:FlxCamera)
	{
		hud = new FlxGroup();

		readoutText = new FlxText(-300, -339, 240, "Not Real Text", 12, true);
		boonsText = new FlxText(-300, -323, 240, "cash text here", 12, true);
		oreText = new FlxText(-300, -307, 240, "ore text here", 12, true);
		metalText = new FlxText(-300, -291, 240, "metal text here", 12, true);
		badgesText = new FlxText(-100, -307, 240, "badge text here", 12, true);

		oreTradeText = new FlxText(-300, -639, 240, "Ore Trade Text", 12, true);
		metalTradeText = new FlxText(-300, -623, 240, "Metal Trade Text", 12, true);
		badgesTradeText = new FlxText(-300, -607, 240, "Badge Trade Text", 12, true);

		buildingText = new FlxText(100, -339, 240, "", 12, true);

		powerText = new FlxText(-100, -339, 240, "power text here", 12, true);
		powerSprite = new FlxSprite(-120, -339);
		powerSprite.loadGraphic(AssetPaths.hudcityunpowered__png, false, 8, 8);

		hud.add(readoutText);
		hud.add(boonsText);
		hud.add(oreText);
		hud.add(powerText);
		hud.add(metalText);
		hud.add(badgesText);

		hud.add(buildingText);

		hud.add(oreTradeText);
		hud.add(metalTradeText);
		hud.add(badgesTradeText);

		hud.add(powerSprite);

		hud.camera = readoutCamera;
		add(hud);
	}

	public function updateHUDAllText()
	{
		updateHUDCashText();
		updateHUDOreText();
		updateHUDPowerText();
		updateHUDMetalText();
		updateHUDBadgeText();

		updateHUDOreTradeText();
		updateHUDMetalTradeText();
		updateHUDBadgeTradeText();

		updateHUDCityPoweredSprite();
	}

	public function updateHUDCashText()
	{
		boonsText.text = "boons: " + Std.string(statManager.getCashAmount());
	}

	public function updateHUDOreText()
	{
		var additionSign:String = "";
		if (statManager.getOreProducedAmount() >= 0)
		{
			additionSign = "+";
		}

		oreText.text = "ore: " + Std.string(statManager.getOreAmount()) + " / " + additionSign + Std.string(statManager.getOreProducedAmount() + " / -"  + Std.string(statManager.getOreTradeAmount()));
	}

	public function updateHUDMetalText()
	{
		var additionSign:String = "";
		if (statManager.getMetalProducedAmount() >= 0)
		{
			additionSign = "+";
		}

		metalText.text = "metal: " + Std.string(statManager.getMetalAmount()) + " / " + additionSign + Std.string(statManager.getMetalProducedAmount()  + " / -"  + Std.string(statManager.getMetalTradeAmount()));
	}

	public function updateHUDBadgeText()
	{
		var additionSign:String = "";
		if (statManager.getBadgesProducedAmount() >= 0)
		{
			additionSign = "+";
		}

		badgesText.text = "badges: " + Std.string(statManager.getBadgesAmount()) + " / " + additionSign + Std.string(statManager.getBadgesProducedAmount()  + " / -"  + Std.string(statManager.getBadgeTradeAmount()));
	}

	public function updateHUDPowerText()
	{
		powerText.text = "power: " + Std.string(statManager.getPowerConsumption()) + " / " + Std.string(statManager.getPowerAmount());
	}

	public function updateHUDCityPoweredSprite()
	{
		if (statManager.isCityPowered())
		{
			powerSprite.loadGraphic(AssetPaths.hudcitypowered__png, false, 8, 8);
		}
		else
		{
			powerSprite.loadGraphic(AssetPaths.hudcityunpowered__png, false, 8, 8);
		}
	}

	public function updateHUDOreTradeText()
	{
		oreTradeText.text = "ore trade: " + Std.string(statManager.getOreTradeAmount()) + " / " + Std.string(statManager.getOreTradeAmountMax());
	}

	public function updateHUDMetalTradeText()
	{
		metalTradeText.text = "metal trade: " + Std.string(statManager.getMetalTradeAmount()) + " / " + Std.string(statManager.getMetalTradeAmountMax());
	}

	public function updateHUDBadgeTradeText()
	{
		badgesTradeText.text = "badge trade: " + Std.string(statManager.getBadgeTradeAmount()) + " / " + Std.string(statManager.getBadgesTradeAmountMax());
	}

	public function updateHUDBuildingText(buildingName:String)
	{
		buildingText.text = buildingName;
	}

	function hoverCursor(tile:FlxObject, player:FlxObject):Bool
	{
		var realTile = cast (tile,  FlxTile);
		readoutText.text = getTileName(realTile.index);
		cursorOnTile = realTile.index;
		return true;
	}

	function hoverCursorBuildings(player:FlxObject, building:FlxObject):Bool
	{
		cursorOnBuilding = cast (building, BuildingBase);
		updateHUDBuildingText(cursorOnBuilding.buildingName);
		cursorOnBuildingX = player.x;
		cursorOnBuildingY = player.y;
		return true;
	}

	function getTileName(tileIndex:Int):String
	{
		switch (tileIndex)
		{
			case 1:
				return "Shallow water";
			case 2:
				return "Sea";
			case 3:
				return "Grass";
			case 4:
				return "Hills";
			case 5:
				return "Mountains";
			case 6:
				return "Hills";
			case 7:
				return "Desert";
			default:
				return "VOID";
		}
	}
}
