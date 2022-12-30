spec cetus_amm::amm_swap {
    spec module {
        pragma verify = false;
        pragma aborts_if_is_partial;
    }

    spec mint<CoinTypeA, CoinTypeB>(
        coinA: Coin<CoinTypeA>,
        coinB: Coin<CoinTypeB>): Coin<PoolLiquidityCoin<CoinTypeA, CoinTypeB>> {
        pragma verify = true;

        // Get deposited amounts.
        let amountA = coin::value(coinA);
        let amountB = coin::value(coinB);

        let post to_mint_lp_value = coin::value(result);

        // Old pool.
        let old_pool = global<Pool<CoinTypeA, CoinTypeB>>(amm_config::admin_address());
        // New pool
        let post new_pool = global<Pool<CoinTypeA, CoinTypeB>>(amm_config::admin_address());

        ensures coin::value(new_pool.coin_a) == coin::value(old_pool.coin_a) + amountA;
        ensures coin::value(new_pool.coin_b) == coin::value(old_pool.coin_b) + amountB;
        ensures new_pool.total_supply > old_pool.total_supply;
        // ensures old_pool.total_supply == 0 ==> MINIMUM_LIQUIDITY + to_mint_lp_value == new_pool.total_supply;
        // ensures old_pool.total_supply > 0 ==> old_pool.total_supply + to_mint_lp_value == new_pool.total_supply;
        // ensures amountA * coin::value(new_pool.coin_b) == amountB * coin::value(new_pool.coin_a);
    }

    spec burn<CoinTypeA, CoinTypeB>(to_burn: Coin<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>): (Coin<CoinTypeA>, Coin<CoinTypeB>) {
        pragma verify = true;

        // Amount of lp burned.
        let to_burn_lp_value = coin::value(to_burn);

        // Amount of tokenA withdrawn.
        let post amountA = coin::value(result_1);
        // Amount of tokenB withdrawn.
        let post amountB = coin::value(result_2);

        // Old pool.
        let old_pool = global<Pool<CoinTypeA, CoinTypeB>>(amm_config::admin_address());
        // New pool.
        let post new_pool = global<Pool<CoinTypeA, CoinTypeB>>(amm_config::admin_address());

        ensures coin::value(new_pool.coin_a) == coin::value(old_pool.coin_a) - amountA;
        ensures coin::value(new_pool.coin_b) == coin::value(old_pool.coin_b) - amountB;
        ensures new_pool.total_supply < old_pool.total_supply;
        ensures new_pool.total_supply + to_burn_lp_value == old_pool.total_supply;
    }
}
