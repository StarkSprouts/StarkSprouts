const { Account, json, RpcProvider } = require("starknet");
const { config } = require("dotenv");
const { readFileSync } = require("fs");
const { exec } = require("child_process");
const util = require("util");
const execAsync = util.promisify(require("child_process").exec);
const env = config({ path: "deploy/.env" }).parsed;

/**
 * This script must be run from the root directory of the repo.
 */
const ENVIRONMENT = env.ENVIRONMENT;
const NODE_URL = ENVIRONMENT == "LOCAL" ? env.LOCAL_RPC_URL : env.LIVE_RPC_URL; // RPC URL
const WALLET_ADDRESS = env.KATANA_WALLET_ADDRESS;
const PRIVATE_KEY = env.KATANA_PRIVATE_KEY;
const SIERA_PATH = "./token/target/dev/token_Seed.contract_class.json";
const CASM_PATH = "./token/target/dev/token_Seed.compiled_contract_class.json";
const provider = new RpcProvider({ nodeUrl: NODE_URL });
const account = new Account(provider, WALLET_ADDRESS, PRIVATE_KEY);
const profile = ENVIRONMENT == "LOCAL" ? `` : `--profile slot `;

/// Main ///

/// Deploy seed contracts
const deploySeeds = async (dojo_address) => {
  const seedTypes = [
    "Bell",
    "Bulba",
    "Cactus",
    "Chamomile",
    "Fern",
    "Lily",
    "Mushroom",
    "Rose",
    "Salvia",
    "Spiral",
    "Sprout",
    "Violet",
    "Zigzag",
  ];

  /// Deploy a contract
  const _deployContract = async (constructorCalldata) => {
    const contract = JSON.parse(readFileSync(SIERA_PATH).toString("ascii"));
    const casm = JSON.parse(readFileSync(CASM_PATH).toString("ascii"));
    console.log(`Deploying ${constructorCalldata[2]} contract...\n`);

    const deployResponse = await account.declareAndDeploy({
      contract,
      casm,
      constructorCalldata,
    });

    await provider.waitForTransaction(deployResponse.deploy.transaction_hash);
    console.log(
      `${constructorCalldata[2]} deployed to: ${deployResponse.deploy.contract_address}\n`
    );

    return deployResponse.deploy.contract_address;
  };

  console.log("Deploying seed contracts...\n");
  const addresses = [];
  for (const seedType of seedTypes) {
    const args = [account.address, "SeedToken", seedType, dojo_address];
    const address = await _deployContract(args);
    addresses.push(address);
  }

  return addresses;
};

/// Deploy world and set sozo auth
const deployWorld = async () => {
  /// Build and migrate to sozo
  const _buildAndMigrateToSozo = async () => {
    const command = `cd contracts && sozo build && sozo ${profile} migrate`;
    // Use a promise to handle the asynchronous execution
    console.log("Building and migrating to sozo...\n");
    return new Promise((resolve, reject) => {
      exec(command, (error, stdout) => {
        if (error) {
          console.error(`exec error: ${error}`);
          reject(error); // Reject the promise on error
          return;
        }

        // Simplify regex search by using a single function
        const extractAddress = (regex) => {
          const match = stdout.match(regex);
          return match ? match[1] : null;
        };

        // Extract world and actions addresses
        const worldAddress = extractAddress(
          /Successfully migrated World at address (\w+)/
        );
        const actionsAddress =
          extractAddress(
            /stark_sprouts::systems::actions::actions\s*>\s*Contract address:\s*(\w+)/
            // /stark_sprouts::systems::actions::actions\s*>\s*Contract address:\s*(0x[a-fA-F0-9]{63})/
          ) ||
          extractAddress(
            /stark_sprouts::systems::actions::actions\s*>\s*Already deployed:\s*(\w+)/
          );

        // Log results
        console.log(
          worldAddress
            ? `World address: ${worldAddress}\n`
            : "World address not found.\n"
        );
        console.log(
          actionsAddress
            ? `Actions address: ${actionsAddress}\n`
            : "Actions address not found.\n"
        );

        resolve({ worldAddress, actionsAddress }); // Resolve the promise with worldAddress
      });
    });
  };

  /// Authorize all models
  const _runAuthorizations = async () => {
    /// Create auth cli commands
    const _makeAuthCommand = (model) => {
      return `sozo ${profile}auth writer ${model} ${actionsAddress} --world ${worldAddress} --rpc-url ${NODE_URL} --account-address ${account.address} --private-key ${PRIVATE_KEY} --wait`;
    };

    /// Authorize a model
    const _authorizeModel = async (model) => {
      console.log(`Authorizing ${model}...\n`);
      try {
        await execAsync(_makeAuthCommand(model));
        console.log("Auth transaction complete!\n");
      } catch (error) {
        console.error(`exec error: ${error}`);
      }
    };

    /// Run all authorizations
    await _authorizeModel("GardenCell");
    await _authorizeModel("PlayerStats");
    await _authorizeModel("TokenLookups");
  };

  console.log("Deploying world...\n");
  const { worldAddress, actionsAddress } = await _buildAndMigrateToSozo();

  console.log("Authorizing...\n");
  await _runAuthorizations();

  return { worldAddress, actionsAddress };
};

/// Set token lookups
const setTokenLookups = async (actionsAddress, seed_addresses) => {
  const command = `sozo ${profile}execute ${actionsAddress} set_token_lookups --calldata ${seed_addresses.length},${seed_addresses} --rpc-url ${NODE_URL} --account-address ${account.address} --private-key ${PRIVATE_KEY} --wait`;

  console.log("Setting token lookups...\n");
  exec(command, (error, stdout) => {
    if (error) {
      console.error(`exec error: ${error}`);
      return;
    }
    console.log("Token lookups set!\n");
  });
};

/// Full deployment
const main = async () => {
  try {
    /// Deploy world and set sozo auth
    let { worldAddress, actionsAddress } = await deployWorld();
    /// Deploy seed contracts
    let seeds = await deploySeeds(worldAddress);
    /// Set seed lookups in world
    await setTokenLookups(actionsAddress, seeds);
  } catch (error) {
    console.error(`Operation failed! Reason: ${error.message}`);
  }
};

main();
