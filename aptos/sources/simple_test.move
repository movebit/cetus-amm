module cetus_amm::simple_test {
  use std::signer;

  struct Pool has store, key {
    num: u64
  }

  public fun foo(account: &signer) acquires Pool {
    let x = 100;
    let y = 100;
    let n = add(x, y);
    let pool = borrow_global_mut<Pool>(signer::address_of(account));
    pool.num = pool.num + n;
  }

  fun add (x: u64, y: u64): u64 {
    let z = (x + y) * 100;
    z
  }
}
