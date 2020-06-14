package;

class BuildingPowerPlant extends BuildingBase
{
    var efficiencyMultiplier:Float;
    var buildingRank:Int;
    var price:Float;

    static public var basePrice:Float = 300;

    static public function basePurchase(pX:Float, pY:Float, pStatManager:StatManager, tileType:Int):BuildingPowerPlant
    {
        if ((tileType == 1) || tileType == 2)
        {
            return null;
        }

        if (pStatManager.purchased(basePrice))
        {
            return new BuildingPowerPlant(pX, pY, pStatManager);
        }
        
        return null;
    }


    public function new (x:Float, y:Float, pStatManager:StatManager)
    {
        super(x, y, pStatManager);
        buildingName = "Power Plant";
        loadGraphic(AssetPaths.powerstation1__png, false, 8, 8);
        buildingRank = 1;
        efficiencyMultiplier = 1.0;
        price = BuildingPowerPlant.basePrice;
        updateProductionStatistics();
    }

    // call this before upgrading
    public function preUpdateProductionStatistics()
    {        
        var powerToProduce:Int = Std.int(efficiencyMultiplier * (buildingRank * 20));
        statManager.addPowerProduction(-powerToProduce);
    }
    
    public function updateProductionStatistics()
    {
        var powerToProduce:Int = Std.int(efficiencyMultiplier * (buildingRank * 20));
        statManager.addPowerProduction(powerToProduce);
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
            updateProductionStatistics();

            //-- also upgrade sprite
            switch (upgradeTest)
            {
                case 2:
                {
                    loadGraphic(AssetPaths.powerstation2__png, false, 16, 16);
                }
                case 3:
                {
                    loadGraphic(AssetPaths.powerstation3__png, false, 16, 16);
                }
                case 4:
                {
                    loadGraphic(AssetPaths.powerstation4__png, false, 16, 16);
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