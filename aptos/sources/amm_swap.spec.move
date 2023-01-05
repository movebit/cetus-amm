spec cetus_amm::amm_swap {
    spec module {
        pragma verify = false;
        pragma aborts_if_is_partial;

        global total_supply: u128 = 0;
    }

    spec mint<CoinTypeA, CoinTypeB>(
        coinA: Coin<CoinTypeA>,
        coinB: Coin<CoinTypeB>): Coin<PoolLiquidityCoin<CoinTypeA, CoinTypeB>> {
        pragma verify = true;

        update total_supply = total_supply + coin::value(result);
    }

    spec burn<CoinTypeA, CoinTypeB>(to_burn: Coin<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>): (Coin<CoinTypeA>, Coin<CoinTypeB>) {
        pragma verify = true;

        update total_supply = total_supply - coin::value(to_burn);
    }
}
