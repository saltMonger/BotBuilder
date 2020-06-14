package;

import flixel.util.FlxTimer;

class StatManager
{
    public var playState:PlayState;

    var powerBeingProduced:Int;
    var powerDraw:Int;

    var oreProduction:Int;
    var metalProduction:Int;
    var badgesProduction:Int;

    var oreTrade:Int;
    var metalTrade:Int;
    var badgeTrade:Int;

    var oreTradeMax:Int;
    var metalTradeMax:Int;
    var badgeTradeMax:Int;

    var cash:Float;

    var ore:Int;
    var metal:Int;
    var badges:Int;
    var goldBadges:Int;

    public var cityPowered:Bool = false;
    public var cityCashed:Bool = false;

    public function new()
    {
        powerBeingProduced = 0;
        powerDraw = 0;

        oreProduction = 0;
        metalProduction = 0;
        badgesProduction = 0;

        oreTrade = 0;
        metalTrade = 0;
        badgeTrade = 0;

        oreTradeMax = 0;
        metalTradeMax = 0;
        badgeTradeMax = 0;

        cash = 0;

        ore = 0;
        metal = 0;
        badges = 0;
        goldBadges = 0;
    }

    public function addPowerDraw(power:Int)
    {
        powerDraw += power;
    }

    public function addPowerProduction(power:Int)
    {
        powerBeingProduced += power;
    }

    public function addCash(cashToAdd:Float)
    {
        cash += cashToAdd;
    }

    public function addOreProduction(oreToProduce:Int)
    {
        oreProduction += oreToProduce;
    }

    public function addMetalProduction(metalToProduce:Int)
    {
        metalProduction += metalToProduce;
    }

    public function addBadgeProduction(badgesToProduce:Int)
    {
        badgesProduction += badgesToProduce;
    }

    //-- TRADE METHODS

    public function addOreTrade(oreToTrade:Int)
    {
        oreTrade += oreToTrade;

        if (oreTrade < 0)
        {
            oreTrade = 0;
        }
        
        if (oreTrade > oreTradeMax)
        {
            oreTrade = oreTradeMax;
        }
    }
    
    public function addMetalTrade(metalToTrade:Int)
    {
        metalTrade += metalToTrade;

        if (metalTrade < 0)
            {
                metalTrade = 0;
            }
            
            if (metalTrade > metalTradeMax)
            {
                metalTrade = metalTradeMax;
            }
    }
        
    public function addBadgeTrade(badgesToTrade:Int)
    {
        badgeTrade += badgesToTrade;

        if (badgeTrade < 0)
        {
            badgeTrade = 0;
        }
        
        if (badgeTrade > badgeTradeMax)
        {
            badgeTrade = badgeTradeMax;
        }
    }

    public function addOreTradeMax(oreMaxAdded:Int)
    {
        oreTradeMax += oreMaxAdded;
    }
    
    public function addMetalTradeMax(metalMaxAdded:Int)
    {
        metalTradeMax += metalMaxAdded;
    }
        
    public function addBadgeTradeMax(badgeMaxAdded:Int)
    {
        badgeTradeMax += badgeMaxAdded;
    }

    //-- TRADE METHODS

    public function oreConsumed(oreToConsume:Int):Bool
    {
        var canConsume:Bool = (ore > oreToConsume);
        if (canConsume)
        {
            ore -= oreToConsume;
            return true;
        }
        return false;
    }

    public function isCityPowered():Bool
    {
        return (powerDraw <= powerBeingProduced);
    }

    public function purchased(purchaseCost:Float):Bool
    {
        var canPurchase:Bool = (cash >= purchaseCost);

        if (canPurchase)
        {
            cash -= purchaseCost;
            return true;
        }

        return false;
    }

    public function canAddOreTrade(tradeAmount:Int):Bool
    {
        var oreModifyAmount:Int = oreTrade;
        oreModifyAmount += tradeAmount;
        if ((oreModifyAmount <= oreTradeMax) && oreModifyAmount >= 0)
        {
            addOreTrade(tradeAmount);
            return true;
        }
        return false;
    }

    public function canAddMetalTrade(tradeAmount:Int):Bool
    {
        var metalModifyAmount:Int = metalTrade;
        metalModifyAmount += tradeAmount;
        if ((metalModifyAmount <= metalTradeMax) && metalModifyAmount >= 0)
        {
            addMetalTrade(tradeAmount);
            return true;
        }
        return false;
    }

    public function canAddBadgesTrade(tradeAmount:Int):Bool
    {
        var badgeModifyAmount:Int = badgeTrade;
        badgeModifyAmount += tradeAmount;
        if ((badgeModifyAmount <= badgeTradeMax) && badgeModifyAmount >= 0)
        {
            addBadgeTrade(tradeAmount);
            return true;
        }
        return false;
    }

    // UI GETTER METHODS
    public function getCashAmount():Float
    {
        return cash;
    }

    public function getOreAmount():Float
    {
        return ore;
    }

    public function getOreProducedAmount():Float
    {
        return oreProduction;
    }

    public function getMetalAmount():Int
    {
        return metal;
    }

    public function getMetalProducedAmount():Int
    {
        return metalProduction;
    }

    public function getBadgesAmount():Int
    {
        return badges;
    }

    public function getBadgesProducedAmount():Int
    {
        return badgesProduction;
    }

    public function getPowerAmount():Float
    {
        return powerBeingProduced;
    }

    public function getPowerConsumption():Float
    {
        return powerDraw;
    }


    public function getOreTradeAmount():Int
    {
        return oreTrade;
    }

    public function getOreTradeAmountMax():Int
    {
        return oreTradeMax;
    }

    public function getMetalTradeAmount():Int
    {
        return metalTrade;
    }

    public function getMetalTradeAmountMax():Int
    {
        return metalTradeMax;
    }

    public function getBadgeTradeAmount():Int
    {
        return badgeTrade;
    }

    public function getBadgesTradeAmountMax():Int
    {
        return badgeTradeMax;
    }
    // UI GETTER METHODS

    public function tickUpdate(timer:FlxTimer)
    {
        trace("tick is updating");
        cityCashed = (cash > 0);
        cityPowered = isCityPowered();

        if (cityPowered)
        {
            ore += oreProduction;
            if (ore < 0)
            {
                ore = 0;
            }

            // need positive ore production, or negative ore production and positive ore to produce metal
            if ((ore) > 0)
            {
                if ((metal + metalProduction) < 0)
                {
                    metal = 0;
                }
                else 
                {
                    metal += metalProduction;
                }
            }

            if ((metal) > 0)
            {
                if ((badges + badgesProduction) < 0)
                {
                    badges = 0;
                }
                else
                {
                    badges += badgesProduction;
                }
            }
        }

        // money generation is fine

        if ((ore - oreTrade) > 0)
        {
            ore -= oreTrade;
            cash += (oreTrade * 2);
        }

        if ((metal - metalTrade) > 0)
        {
            metal -= metalTrade;
            cash += (metalTrade * 6);
        }

        if ((badges - badgeTrade) > 0)
        {
            badges -= badgeTrade;
            cash += (badgeTrade * 20);
        }
        playState.updateHUDAllText();
    }
}