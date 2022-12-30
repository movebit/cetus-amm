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

        // Old pool.
        let old_pool = global<amm_swap::Pool<CoinTypeA, CoinTypeB>>(amm_config::admin_address());
        // New pool.
        let post new_pool = global<amm_swap::Pool<CoinTypeA, CoinTypeB>>(amm_config::admin_address());

        ensures coin::value(old_pool.coin_a) <= coin::value(new_pool.coin_a);
        ensures coin::value(old_pool.coin_b) <= coin::value(new_pool.coin_b);
        ensures coin::value(old_pool.coin_a) * coin::value(old_pool.coin_b) <= coin::value(new_pool.coin_a) * coin::value(new_pool.coin_b);
    }

    spec remove_liquidity_internal<CoinTypeA, CoinTypeB>(
        account: &signer,
        liquidity: u128,
        amount_a_min: u128,
        amount_b_min: u128
    ) {
        pragma verify = true;

        // Old pool.
        let old_pool = global<amm_swap::Pool<CoinTypeA, CoinTypeB>>(amm_config::admin_address());
        // New pool.
        let post new_pool = global<amm_swap::Pool<CoinTypeA, CoinTypeB>>(amm_config::admin_address());

        ensures coin::value(old_pool.coin_a) >= coin::value(new_pool.coin_a);
        ensures coin::value(old_pool.coin_b) >= coin::value(new_pool.coin_b);
        ensures coin::value(old_pool.coin_a) * coin::value(old_pool.coin_b) >= coin::value(new_pool.coin_a) * coin::value(new_pool.coin_b);
    }

    spec swap_exact_coin_for_coin<CoinTypeA, CoinTypeB>(
        account: &signer,
        amount_a_in: u128,
        amount_b_out_min: u128,
    ) {
        pragma verify = true;

        // Old pool.
        let old_pool = global<amm_swap::Pool<CoinTypeA, CoinTypeB>>(amm_config::admin_address());
        // New pool.
        let post new_pool = global<amm_swap::Pool<CoinTypeA, CoinTypeB>>(amm_config::admin_address());

        // true: <Pool<CoinTypeA, CoinTypeB>>; false: <Pool<CoinTypeB, CoinTypeA>>
        let is_forward = amm_swap::get_pool_direction<CoinTypeA, CoinTypeB>();
        ensures !is_forward ==> coin::value(old_pool.coin_a) >= coin::value(new_pool.coin_a);
        // ensures coin::value(old_pool.coin_a) * coin::value(old_pool.coin_b) <= coin::value(new_pool.coin_a) * coin::value(new_pool.coin_b);
    }
}
