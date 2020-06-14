package;

class BuildingRefinery extends BuildingBase
{
    var efficiencyMultiplier:Float;
    var powerDraw:Int;
    var buildingRank:Int;
    var price:Float;

    static public var basePrice:Float = 1000;

    static public function basePurchase(pX:Float, pY:Float, pStatManager:StatManager, tileType:Int):BuildingRefinery
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
                    efficiency = 1.0;
                case 4:
                    //HILLS
                    efficiency = 0.75;
                case 6:
                    //HILLS
                    efficiency = 0.75;
                case 5:
                    //MOUNTAINS
                    efficiency = 0.5;
                case 7:
                    //DESERT
                    efficiency = 1.5;
                default:
                    //Illegal to build in sea tiles
                    efficiency = 0;
            }

            return new BuildingRefinery(pX, pY, pStatManager, efficiency);
        }
        
        return null;
    }

    public function new (x:Float, y:Float, pStatManager:StatManager, efficiency:Float)
    {
        super(x, y, pStatManager);
        buildingName = "Refinery";
        loadGraphic(AssetPaths.refinery1__png, false, 8, 8);
        buildingRank = 1;
        efficiencyMultiplier = efficiency;
        powerDraw = 15;
        price = BuildingRefinery.basePrice;
        updateProductionStatistics();
    }

    // call this before upgrading
    public function preUpdateProductionStatistics()
    {        
        var consumeEff = calcEfficiencyScale(efficiencyMultiplier);
        var metalToProduce:Int = Std.int(efficiencyMultiplier * (buildingRank * 5));
        var oreToConsume:Int = Std.int(consumeEff * (buildingRank * 20));
        statManager.addOreProduction(oreToConsume); // we want positive movement to balance out ore consumption
        statManager.addMetalProduction(-metalToProduce);
        statManager.addPowerDraw(-powerDraw);
    }

    public function updateProductionStatistics()
    {
        var consumeEff = calcEfficiencyScale(efficiencyMultiplier);
        var metalToProduce:Int = Std.int(efficiencyMultiplier * (buildingRank * 5));
        var oreToConsume:Int = Std.int(consumeEff * (buildingRank * 20));
        statManager.addOreProduction(-oreToConsume); // we want positive movement to balance out ore consumption
        statManager.addMetalProduction(metalToProduce);
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

        if (canPurchase)
        {
            preUpdateProductionStatistics();
            buildingRank += 1;
            powerDraw *= buildingRank;
            updateProductionStatistics();

            //-- also upgrade sprite
            switch (upgradeTest)
            {
                case 2:
                {
                    loadGraphic(AssetPaths.refinery2__png, false, 16, 16);
                }
                case 3:
                {
                    loadGraphic(AssetPaths.refinery3__png, false, 16, 16);
                }
                case 4:
                {
                    loadGraphic(AssetPaths.refinery4__png, false, 16, 16);
                }
                default:
                {
                    return false;
                }
            }
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