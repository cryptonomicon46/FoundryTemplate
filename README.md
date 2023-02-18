Installation:
curl https://sh.rustup.rs -sSf | sh

Initialize a new project:

forge init hello_foundry --no-git
forge build
forge test

(base) $ forge build
[⠢] Compiling...
[⠢] Compiling 20 files with 0.8.16a
[⠆] Solc 0.8.16 finished in 1.93s
Compiler run successful

Running 2 tests for test/Counter.t.sol:CounterTest
[PASS] testIncrement() (gas: 28334)
[PASS] testSetNumber(uint256) (runs: 256, μ: 27709, ~: 28409)

Test result: ok. 2 passed; 0 failed; finished in 9.39ms

Adding dependencies

forge install transmissions11/solmate --no-git
tree lib -L 1
lib
├── forge-std
└── solmate

Add console2.log to forge tests
import "forge-std/Test.sol";
// or directly import it
import "forge-std/console2.sol";

For log output:
forge test -vv
or
for a full trace of every function call
forge test -vvvv

Forge test reference
https://book.getfoundry.sh/reference/forge/forge-test
-v
--verbosity
Verbosity of the EVM.

    Pass multiple times to increase the verbosity (e.g. -v, -vv, -vvv).

    Verbosity levels:
    - 2: Print logs for all tests
    - 3: Print execution traces for failing tests
    - 4: Print execution traces for all tests, and setup traces for failing tests
    - 5: Print execution and setup traces for all tests

List tests
forge test --list --json --match-test "testIncrement" | tail -n 1 | json_pp

Only run selected tests tests
forge test --match-path test/Counter.t.sol --match-contract CounterTest --match-test "testIncrement*"
forge test --match-path test/ContractB.t.sol --match-contract ContractBTest --match-test "testNumberis42*"

Debug tests
forge test --debug "testIncrement()"
