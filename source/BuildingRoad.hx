package;

class BuildingRoad extends BuildingBase
{
    var price:Float;
    public function new(x:Float, y:Float, pStatManager:StatManager)
    {
        super(x, y, pStatManager);
        loadGraphic(AssetPaths.buildingroad__png, false, 8, 8);
        buildingName = "Road";
        price = 10;
        energyConsumedPerTick = 0;
    }

    override public function update(elapsed:Float)
    {

    }

    
    public override function bulldoze()
    {
        statManager.addCash(price / 2);
        super.bulldoze();
        return;
    }
}