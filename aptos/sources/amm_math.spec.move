spec cetus_amm::amm_math {
    spec module {
        pragma verify = false;
        pragma aborts_if_is_partial;
    }

    spec safe_compare_mul_u128(a1: u128, b1: u128, a2: u128, b2: u128): u8 {
        pragma opaque;

        let left = a1 * b1;
        let right = a2 * b2;

        ensures [abstract] left == right ==> result == 0;
        ensures [abstract] left < right ==> result == 1;
        ensures [abstract] left > right ==> result == 2;
    }
}
