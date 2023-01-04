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
        amount_b_min: u128) {
        pragma verify = true;

        let total_supply = get_total_supply<amm_swap::PoolLiquidityCoin<CoinTypeA, CoinTypeB>>();
    }

    spec fun get_total_supply<CoinType>(): u128 {
      use std::option;
      use aptos_framework::optional_aggregator;
      use aptos_std::type_info;

      let coin_address = type_info::type_of<CoinType>().account_address;

      let maybe_supply = global<coin::CoinInfo<CoinType>>(coin_address).supply;
      let supply = option::borrow(maybe_supply);
      let value = optional_aggregator::read(supply);
      value
    }
}
