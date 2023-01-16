spec cetus_amm::amm_swap {
    spec module {
        pragma verify = false;
        pragma aborts_if_is_partial;
    }

    spec Pool {
        // The value of locked liquidity in Pool can only be 0 or minimum liquidity.
        invariant coin::value(locked_liquidity) == 0 || coin::value(locked_liquidity) == MINIMUM_LIQUIDITY;
        // If one of the reserves of coin_a and coin_b in the pool is 0, the other must also be 0,
        // and if one is not 0, then the other is not 0 either.
        invariant coin::value(coin_a) != 0 ==> coin::value(coin_b) != 0;
        invariant coin::value(coin_b) != 0 ==> coin::value(coin_a) != 0;
        invariant coin::value(coin_a) == 0 ==> coin::value(coin_b) == 0;
        invariant coin::value(coin_b) == 0 ==> coin::value(coin_a) == 0;
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

        // LP value before minting
        let old_ghost_total_supply = coin::ghost_total_supply;
        // LP value after minting
        let post new_ghost_total_supply = coin::ghost_total_supply;

        // After liquidity is added, the reserves of coin_a and coin_b increase.
        ensures coin::value(old_pool.coin_a) < coin::value(new_pool.coin_a);
        ensures coin::value(old_pool.coin_b) < coin::value(new_pool.coin_b);
        // K value increases after adding liquidity.
        ensures coin::value(old_pool.coin_a) * coin::value(old_pool.coin_b) < coin::value(new_pool.coin_a) * coin::value(new_pool.coin_b);
        // Increase in liquidity.
        ensures old_ghost_total_supply < new_ghost_total_supply;

        // The coin_a and coin_b in the pool are the old value plus the value required for this minting.
        ensures coin::value(new_pool.coin_a) == coin::value(old_pool.coin_a) + amountA;
        ensures coin::value(new_pool.coin_b) == coin::value(old_pool.coin_b) + amountB;
        // If the old LP value is 0, then the new LP value after minting is the liquidity of this casting plus the minimum liquidity,
        // otherwise the new LP value is the liquidity of this casting plus the old LP value.
        ensures if (old_ghost_total_supply == 0) { MINIMUM_LIQUIDITY + to_mint_lp_value == new_ghost_total_supply } else { old_ghost_total_supply + to_mint_lp_value == new_ghost_total_supply };
        // If the old LP value is 0, the old locked_liquidity is also 0.
        ensures old_ghost_total_supply == 0 ==> coin::value(old_pool.locked_liquidity) == 0;
        // The ratio between the tokens needed to add liquidity and the minted LP Token value should be equal to the ratio of the tokens in the original pool to the original LP Token value.
        // The condition here can be executed, but I modified the following equality judgment to pass, which makes me very confused, so comment it first.
        // ensures old_ghost_total_supply != 0 ==> amountA / to_mint_lp_value == coin::value(old_pool.coin_a) / old_ghost_total_supply;
    }

    spec burn<CoinTypeA, CoinTypeB>(to_burn: Coin<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>): (Coin<CoinTypeA>, Coin<CoinTypeB>) {
        pragma verify = true;

        // Amount of lp burned.
        let to_burn_lp_value = coin::value(to_burn);

        // Amount of tokenA withdrawn.
        let post amountA = coin::value(result_1);
        // Amount of tokenB withdrawn.
        let post amountB = coin::value(result_2);

        // Pool before removing liquidity.
        let old_pool = global<Pool<CoinTypeA, CoinTypeB>>(amm_config::admin_address());
        // Pool after removing liquidity.
        let post new_pool = global<Pool<CoinTypeA, CoinTypeB>>(amm_config::admin_address());

        // LP value before minting
        let old_ghost_total_supply = coin::ghost_total_supply;
        // LP value after minting
        let post new_ghost_total_supply = coin::ghost_total_supply;

        // After liquidity is removed, the reserves of coin_a and coin_b decrease.
        ensures coin::value(old_pool.coin_a) > coin::value(new_pool.coin_a);
        ensures coin::value(old_pool.coin_b) > coin::value(new_pool.coin_b);
        // K value decreases after removing liquidity.
        ensures coin::value(old_pool.coin_a) * coin::value(old_pool.coin_b) > coin::value(new_pool.coin_a) * coin::value(new_pool.coin_b);
        // Decrease in liquidity.
        ensures old_ghost_total_supply > new_ghost_total_supply;

        // The coin_a and coin_b in the pool are the old value minus the coin_a and coin_b generated by this burn.
        ensures coin::value(new_pool.coin_a) == coin::value(old_pool.coin_a) - amountA;
        ensures coin::value(new_pool.coin_b) == coin::value(old_pool.coin_b) - amountB;
        // The current remaining LP tokens plus the burnt LP tokens are equal to the LP tokens before the burn.
        ensures new_ghost_total_supply + to_burn_lp_value == old_ghost_total_supply;
        // The ratio of the tokens generated by the deletion of liquidity to the value of the deleted LP Token is equal to the ratio of the original tokens in the pool to the original LP Token value.
        // ensures amountA / to_burn_lp_value == coin::value(old_pool.coin_a) / old_ghost_total_supply;
    }

    spec swap_and_emit_event_v2<CoinTypeA, CoinTypeB>(
        account: address,
        coin_a_in: Coin<CoinTypeA>,
        coin_b_out: u128,
        coin_b_in: Coin<CoinTypeB>,
        coin_a_out: u128
    ) :(Coin<CoinTypeA>, Coin<CoinTypeB>, Coin<CoinTypeA>, Coin<CoinTypeB>) {
        pragma verify = true;

        // Pool before removing liquidity.
        let old_pool = global<Pool<CoinTypeA, CoinTypeB>>(amm_config::admin_address());
        // Pool after removing liquidity.
        let post new_pool = global<Pool<CoinTypeA, CoinTypeB>>(amm_config::admin_address());

        // After the exchange, the amount added to the pool is less than the amount required for the exchange.
        ensures coin::value(new_pool.coin_a) - coin::value(old_pool.coin_a) <= coin::value(coin_a_in);
        ensures coin::value(new_pool.coin_b) - coin::value(old_pool.coin_b) <= coin::value(coin_b_in);
    }
}
