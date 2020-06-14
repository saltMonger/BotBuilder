package;

import flixel.FlxSprite;

class BuildingBase extends FlxSprite
{
    var energyConsumedPerTick:Int;

    var statManager:StatManager;
    
    public var buildingName:String;

    public function new(x:Float, y:Float, pStatManager:StatManager)
    {
        super(x, y);
        statManager = pStatManager;
    }

    public function upgrade():Bool
    {
        //-- just vector up
        return true;
    }

    public function bulldoze()
    {
        //-- just vector up
        return;
    }

    public function calcEfficiencyScale(efficiencyMultiplier:Float):Float
    {
        var consumeEff:Float = efficiencyMultiplier;
        if (efficiencyMultiplier > 1)
        {
            consumeEff = 1 / efficiencyMultiplier;
        }
        else if (efficiencyMultiplier < 1)
        {
            consumeEff = (1 - efficiencyMultiplier);
            consumeEff = 1 - (consumeEff / 2);
            consumeEff = 1 / consumeEff;
        }
        return consumeEff;
    }
}