const { Account, json, RpcProvider } = require("starknet");
const { config } = require("dotenv");
const { readFileSync } = require("fs");
const { exec } = require("child_process");
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

// Deploy a seed contract with specific constructor arguments
const deployContract = async (constructorCalldata) => {
  const contract = json.parse(readFileSync(SIERA_PATH).toString("ascii"));
  const casm = json.parse(readFileSync(CASM_PATH).toString("ascii"));
  console.log(`Deploying ${constructorCalldata[2]} contract...`);

  const deployResponse = await account.declareAndDeploy({
    contract,
    casm,
    constructorCalldata,
  });

  await provider.waitForTransaction(deployResponse.deploy.transaction_hash);
  console.log(
    `Contract deployed at address: ${deployResponse.deploy.contract_address}`
  );

  return deployResponse.deploy.contract_address;
};

/// Build sozo packages and migrate to katana
/// todo: need to add sozo auth
const buildAndMigrateToSozo = async () => {
  const command = "cd contracts && sozo build && sozo migrate";
  console.log("\nBuilding and migrating to sozo...\n");

  // Use a promise to handle the asynchronous execution
  return new Promise((resolve, reject) => {
    /// move addresses up here with let ...
    /// dont return until end, need to do auth before
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
          : "World address not found."
      );
      console.log(
        actionsAddress
          ? `Actions address: ${actionsAddress}\n`
          : "Actions address not found."
      );

      resolve(worldAddress); // Resolve the promise with worldAddress
    });
  });
};

/// Set token lookups
const setTokenLookups = async (worldAddress, tokenAddresses) => {
  /// run sozo execute
};

// going to need a function to deploy world, then deploy all seeds, then call set_token_lookups

// Deploy all seed contracts
const main = async () => {
  try {
    const constructorArgsList = [
      [account.address, "SeedToken", "Bell", "dojo_address"],
      [account.address, "SeedToken", "Bulba", "dojo_address"],
      [account.address, "SeedToken", "Cactus", "dojo_address"],
      [account.address, "SeedToken", "Chamomile", "dojo_address"],
      [account.address, "SeedToken", "Fern", "dojo_address"],
      [account.address, "SeedToken", "Lily", "dojo_address"],
      [account.address, "SeedToken", "Mushroom", "dojo_address"],
      [account.address, "SeedToken", "Rose", "dojo_address"],
      [account.address, "SeedToken", "Salvia", "dojo_address"],
      [account.address, "SeedToken", "Spiral", "dojo_address"],
      [account.address, "SeedToken", "Sprout", "dojo_address"],
      [account.address, "SeedToken", "Violet", "dojo_address"],
      [account.address, "SeedToken", "Zigzag", "dojo_address"],
    ];

    await buildAndMigrateToSozo();

    // for (const args of constructorArgsList) {
    //   await deployContract(args);
    // }
  } catch (error) {
    console.error(`Operation failed! Reason: ${error.message}`);
  }
};

main();
