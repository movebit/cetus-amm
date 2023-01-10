spec cetus_amm::amm_router {
    spec module {
        pragma verify = false;
        pragma aborts_if_is_partial;
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
