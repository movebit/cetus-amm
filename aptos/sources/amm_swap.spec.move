spec cetus_amm::amm_swap {
    spec module {
        pragma verify = false;
        pragma aborts_if_is_partial;

        global ghost_total_supply: u128 = 0;
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

        let liquidity = if (ghost_total_supply == 0) {
            // Error: The error message is at the bottom of the file.
            sqrt(amountA * amountB)
        } else {
            // Error: The error message is at the bottom of the file.
            min(amountA * ghost_total_supply / old_pool.coin_a, amountB * ghost_total_supply / old_pool.coin_b)
        };
        update ghost_total_supply = ghost_total_supply + liquidity;

        let old_ghost_total_supply = ghost_total_supply;

        let post new_ghost_total_supply = ghost_total_supply;

        // If the old LP value is 0, then the new LP value after minting is the liquidity of this casting plus the minimum liquidity,
        // otherwise the new LP value is the liquidity of this casting plus the old LP value.
        ensures if (old_ghost_total_supply == 0) { MINIMUM_LIQUIDITY + to_mint_lp_value == new_ghost_total_supply } else { old_ghost_total_supply + to_mint_lp_value == new_ghost_total_supply };
        // If the old LP value is 0, the old locked_liquidity is also 0.
        ensures old_ghost_total_supply == 0 ==> coin::value(old_pool.locked_liquidity) == 0;
    }

    spec burn<CoinTypeA, CoinTypeB>(to_burn: Coin<PoolLiquidityCoin<CoinTypeA, CoinTypeB>>): (Coin<CoinTypeA>, Coin<CoinTypeB>) {
        pragma verify = true;

        update ghost_total_supply = ghost_total_supply - coin::value(to_burn);
    }
}

// error: calling impure function `amm_math::sqrt` is not allowed
//    /Users/yoyoping/Documents/workspace/block-chain/move/aptos/cetus-amm/aptos/sources/amm_swap.spec.move:27:13
//
// 28              sqrt(amountA * amountB)
//                 ^^^^^^^^^^^^^^^^^^^^^^^
//
//    = impure function `amm_math::sqrt(u128): u128`

// error: no matching declaration of `/`
//     /Users/yoyoping/Documents/workspace/block-chain/move/aptos/cetus-amm/aptos/sources/amm_swap.spec.move:29:17
//
// 31              min(amountA * ghost_total_supply / old_pool.coin_a, amountB * ghost_total_supply / old_pool.coin_b)
//                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
//
//    = outruled candidate `/(num, num): num` (expected `num` but found `coin::Coin<#0>` for argument 2)

// error: no matching declaration of `/`
//     /Users/yoyoping/Documents/workspace/block-chain/move/aptos/cetus-amm/aptos/sources/amm_swap.spec.move:29:65
//
// 31              min(amountA * ghost_total_supply / old_pool.coin_a, amountB * ghost_total_supply / old_pool.coin_b)
//                                                                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
//
//    = outruled candidate `/(num, num): num` (expected `num` but found `coin::Coin<#1>` for argument 2)

// {
//   "Error": "Move Prover failed: exiting with model building errors"
// }
