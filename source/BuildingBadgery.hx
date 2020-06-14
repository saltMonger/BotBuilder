package;

class BuildingBadgery extends BuildingBase
{
    var efficiencyMultiplier:Float;
    var powerDraw:Int;
    var buildingRank:Int;
    var price:Float;

    static public var basePrice:Float = 3000;

    static public function basePurchase(pX:Float, pY:Float, pStatManager:StatManager, tileType:Int):BuildingBadgery
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
                    efficiency = 0.5;
                case 4:
                    //HILLS
                    efficiency = 1.5;
                case 6:
                    //HILLS
                    efficiency = 1.5;
                case 5:
                    //MOUNTAINS
                    efficiency = 1.0;
                case 7:
                    //DESERT
                    efficiency = 0.75;
                default:
                    //Illegal to build in water tiles
                    return null;
            }
            return new BuildingBadgery(pX, pY, pStatManager, efficiency);
        }
        
        return null;
    }

    public function new (x:Float, y:Float, pStatManager:StatManager, efficiency:Float)
    {
        super(x, y, pStatManager);
        buildingName = "Badgery";
        loadGraphic(AssetPaths.badgery1__png, false, 8, 8);
        buildingRank = 1;
        efficiencyMultiplier = efficiency;
        powerDraw = 50;
        price = BuildingBadgery.basePrice;
        updateProductionStatistics();
    }

    // call this before upgrading
    public function preUpdateProductionStatistics()
    {        
        var consumeEff = calcEfficiencyScale(efficiencyMultiplier);
        var badgesToProduce:Int = Std.int(efficiencyMultiplier * (buildingRank * 2));
        var metalToConsume:Int = Std.int(consumeEff * (buildingRank * 10));
        statManager.addMetalProduction(metalToConsume); // we want positive movement to balance out metal consumption
        statManager.addBadgeProduction(-badgesToProduce);
        statManager.addPowerDraw(-powerDraw);
    }

    public function updateProductionStatistics()
    {
        var consumeEff = calcEfficiencyScale(efficiencyMultiplier);
        var badgesToProduce:Int = Std.int(efficiencyMultiplier * (buildingRank * 2));
        var metalToConsume:Int = Std.int(consumeEff * (buildingRank * 10));
        statManager.addMetalProduction(-metalToConsume); // we want negative movement to balance out metal consumption
        statManager.addBadgeProduction(badgesToProduce);
        statManager.addPowerDraw(powerDraw);
    }

    public override function upgrade():Bool
    {
        var upgradeTest:Int = buildingRank + 1;
        if (upgradeTest > 3)
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
                    loadGraphic(AssetPaths.badgery2__png, false, 16, 16);
                }
                case 3:
                {
                    loadGraphic(AssetPaths.badgery3__png, false, 16, 16);
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