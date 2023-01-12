module cetus_amm::test_a {
  struct Num has store, key {
    number: u64
  }

  spec module {
    pragma verify = true;
  }

  fun init() acquires Num {
    let r = borrow_global_mut<Num>(@0x1);
    if (r.number < 99) {
      r.number = r.number + 1;
    };
  }

  spec init {
    // ensures global<Num>(@0x1).number == old(global<Num>(@0x1).number) + 1;

    invariant global<Num>(@0x1).number < 100;
  }
}
