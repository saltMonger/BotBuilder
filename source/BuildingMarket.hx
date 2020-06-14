package;

class BuildingMarket extends BuildingBase
{
    var efficiencyMultiplier:Float;
    var powerDraw:Int;
    var buildingRank:Int;
    var price:Float;

    static public var basePrice:Float = 300;

    static public function basePurchase(pX:Float, pY:Float, pStatManager:StatManager, tileType:Int):BuildingMarket
    {
        if ((tileType == 1) || tileType == 2)
        {
            return null;
        }
    
        if (pStatManager.purchased(basePrice))
        {
            return new BuildingMarket(pX, pY, pStatManager);
        }
        
        return null;
    }

    public function new (x:Float, y:Float, pStatManager:StatManager)
    {
        super(x, y, pStatManager);
        buildingName = "Market";
        loadGraphic(AssetPaths.market1__png, false, 8, 8);
        buildingRank = 1;
        efficiencyMultiplier = 1.0;
        powerDraw = 10;
        price = BuildingMarket.basePrice;
        updateProductionStatistics();
    }

    // call this before upgrading
    public function preUpdateProductionStatistics()
    {        
        var oreToSellMax:Int = Std.int(efficiencyMultiplier * (buildingRank * 20));
        var metalToSellMax:Int = Std.int(efficiencyMultiplier * (buildingRank * 10));
        var badgesToSellMax:Int = Std.int(efficiencyMultiplier * (buildingRank * 5));
        statManager.addOreTradeMax(-oreToSellMax);
        statManager.addMetalTradeMax(-metalToSellMax);
        statManager.addBadgeTradeMax(-badgesToSellMax);
        statManager.addPowerDraw(-powerDraw);
    }

    public function updateProductionStatistics()
    {
        var oreToSellMax:Int = Std.int(efficiencyMultiplier * (buildingRank * 20));
        var metalToSellMax:Int = Std.int(efficiencyMultiplier * (buildingRank * 10));
        var badgesToSellMax:Int = Std.int(efficiencyMultiplier * (buildingRank * 5));
        statManager.addOreTradeMax(oreToSellMax);
        statManager.addMetalTradeMax(metalToSellMax);
        statManager.addBadgeTradeMax(badgesToSellMax);
        statManager.addPowerDraw(powerDraw);
    }

    public override function upgrade():Bool
    {
        var upgradeTest:Int = buildingRank + 1;
        trace(upgradeTest);
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
                    loadGraphic(AssetPaths.market2__png, false, 16, 16);
                }
                case 3:
                {
                    loadGraphic(AssetPaths.market3__png, false, 16, 16);
                }
                case 4:
                {
                    loadGraphic(AssetPaths.market4__png, false, 16, 16);
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