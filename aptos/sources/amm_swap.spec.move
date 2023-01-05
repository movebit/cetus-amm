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

        // LP token for this minting.
        let post to_mint_lp_value = coin::value(result);

        // Pool before minting.
        let old_pool = global<Pool<CoinTypeA, CoinTypeB>>(amm_config::admin_address());
        // Pool after minting.
        let post new_pool = global<Pool<CoinTypeA, CoinTypeB>>(amm_config::admin_address());

        let old_ghost_total_supply = coin::ghost_total_supply;

        let post new_ghost_total_supply = coin::ghost_total_supply;

        // The coin_a and coin_b in the pool are the old value plus the value required for this minting.
        // ensures coin::value(new_pool.coin_a) == coin::value(old_pool.coin_a) + amountA;
        // ensures coin::value(new_pool.coin_b) == coin::value(old_pool.coin_b) + amountB;
        // If the old LP value is 0, then the new LP value after minting is the liquidity of this casting plus the minimum liquidity,
        // otherwise the new LP value is the liquidity of this casting plus the old LP value.
        ensures if (old_ghost_total_supply == 0) { MINIMUM_LIQUIDITY + to_mint_lp_value == new_ghost_total_supply } else { old_ghost_total_supply + to_mint_lp_value == new_ghost_total_supply };
        // If the old LP value is 0, the old locked_liquidity is also 0.
        ensures old_ghost_total_supply == 0 ==> coin::value(old_pool.locked_liquidity) == 0;
    }
}
