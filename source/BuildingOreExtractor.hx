package;

class BuildingOreExtractor extends BuildingBase
{
    var efficiencyMultiplier:Float;
    var powerDraw:Int;
    var buildingRank:Int;
    var price:Float;

    static public var basePrice:Float = 100;

    static public function basePurchase(pX:Float, pY:Float, pStatManager:StatManager, tileType:Int):BuildingOreExtractor
    {
        if ((tileType == 1) || tileType == 2)
        {
            return null;
        }

        if (pStatManager.purchased(basePrice))
        {
            var efficiency:Float;
            switch (tileType)
            {
                case 3:
                    //GRASS
                    efficiency = 0.75;
                case 4:
                    //HILLS
                    efficiency = 1.0;
                case 6:
                    //HILLS
                    efficiency = 1.0;
                case 5:
                    //MOUNTAINS
                    efficiency = 1.5;
                case 7:
                    //DESERT
                    efficiency = 0.5;
                default:
                    //Illegal to build in water tiles
                    return null;
            }
            return new BuildingOreExtractor(pX, pY, pStatManager, efficiency);
        }
        
        return null;
    }

    public function new (x:Float, y:Float, pStatManager:StatManager, efficiency:Float)
    {
        super(x, y, pStatManager);
        buildingName = "Ore Extractor";
        loadGraphic(AssetPaths.oreextractor1__png, false, 8, 8);
        buildingRank = 1;
        efficiencyMultiplier = efficiency;
        powerDraw = 5;
        price = BuildingOreExtractor.basePrice;
        updateProductionStatistics();
    }

    // call this before upgrading
    public function preUpdateProductionStatistics()
    {        
        var oreToProduce:Int = Std.int(efficiencyMultiplier * (buildingRank * 10));
        statManager.addOreProduction(-oreToProduce);
        statManager.addPowerDraw(-powerDraw);
    }

    public function updateProductionStatistics()
    {
        var oreToProduce:Int = Std.int(efficiencyMultiplier * (buildingRank * 10));
        statManager.addOreProduction(oreToProduce);
        statManager.addPowerDraw(powerDraw);
    }

    public override function upgrade():Bool
    {
        var upgradeTest:Int = buildingRank + 1;
        if (upgradeTest > 4)
        {
            return false;
        }

        var canPurchase:Bool = statManager.purchased(price * ((buildingRank + 1) * 2));

        switch (upgradeTest)
        {
            case 2:
            {
                loadGraphic(AssetPaths.oreextractor2__png, false, 16, 16);
            }
            case 3:
            {
                loadGraphic(AssetPaths.oreextractor3__png, false, 16, 16);
            }
            case 4:
            {
                loadGraphic(AssetPaths.oreextractor4__png, false, 16, 16);
            }
            default:
            {
                return false;
            }
        }

        if (canPurchase)
        {
            preUpdateProductionStatistics();
            buildingRank += 1;
            powerDraw *= buildingRank;
            updateProductionStatistics();

            //-- also upgrade sprite

            return true;
        }

        return false;
    }

    public override function bulldoze()
    {
        preUpdateProductionStatistics();
        statManager.addCash(price / 2);
        super.bulldoze();
        return;
    }
}