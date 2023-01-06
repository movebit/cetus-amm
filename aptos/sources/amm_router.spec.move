spec cetus_amm::amm_router {
    spec module {
        pragma verify = false;
        pragma aborts_if_is_partial;
    }

    spec add_liquidity_internal<CoinTypeA, CoinTypeB>(
        account: &signer,
        amount_a_desired: u128,
        amount_b_desired: u128,
        amount_a_min: u128,
        amount_b_min: u128
    ) {
        pragma verify = true;

        // Pool before adding liquidity.
        let old_pool = global<amm_swap::Pool<CoinTypeA, CoinTypeB>>(amm_config::admin_address());
        // Pool after adding liquidity.
        let post new_pool = global<amm_swap::Pool<CoinTypeA, CoinTypeB>>(amm_config::admin_address());

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
    }

    spec remove_liquidity_internal<CoinTypeA, CoinTypeB>(
        account: &signer,
        liquidity: u128,
        amount_a_min: u128,
        amount_b_min: u128
    ) {
        pragma verify = true;

        // Pool before removing liquidity.
        let old_pool = global<amm_swap::Pool<CoinTypeA, CoinTypeB>>(amm_config::admin_address());
        // Pool after removing liquidity.
        let post new_pool = global<amm_swap::Pool<CoinTypeA, CoinTypeB>>(amm_config::admin_address());

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
    }

    spec swap_exact_coin_for_coin<CoinTypeA, CoinTypeB>(
        account: &signer,
        amount_a_in: u128,
        amount_b_out_min: u128,
    ) {
        pragma verify = true;

        // The pool before swap.
        let old_pool = global<amm_swap::Pool<CoinTypeA, CoinTypeB>>(amm_config::admin_address());
        // The pool after swap.
        let post new_pool = global<amm_swap::Pool<CoinTypeA, CoinTypeB>>(amm_config::admin_address());

        // is_forward:  true: <Pool<CoinTypeA, CoinTypeB>>; false: <Pool<CoinTypeB, CoinTypeA>>
        let is_forward = amm_swap::get_pool_direction<CoinTypeA, CoinTypeB>();
        // If it is coin_a swap coin_b, then the reserve of coin_b decreases after the exchange, otherwise the reserve of coin_a decreases.
        ensures if (is_forward) { coin::value(old_pool.coin_b) >= coin::value(new_pool.coin_b) } else { coin::value(old_pool.coin_a) >= coin::value(new_pool.coin_a) };
    }
}
