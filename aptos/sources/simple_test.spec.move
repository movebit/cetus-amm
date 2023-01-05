spec cetus_amm::simple_test {
    spec module {
        pragma verify = false;
        pragma aborts_if_is_partial;

        global ghost_num: u128 = 0;
    }

    spec add (x: u64, y: u64): u64 {
        pragma verify = true;

        // Error: The error message is at the bottom of the file.
        update ghost_num = ghost_num + result;
    }
}


// error: undeclared `simple_test::result`
// 13          update ghost_num = ghost_num + result;
//                                            ^^^^^^

// {
//   "Error": "Move compilation failed: extended checks failed"
// }
