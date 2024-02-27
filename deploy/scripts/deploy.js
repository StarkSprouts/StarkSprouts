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

  const promises = seedTypes.map(async (seedType) => {
    const args = [account.address, "SeedToken", seedType, dojo_address];
    return await _deployContract(args);
  });

  const addresses = await Promise.all(promises);
  return addresses;
};

// /// Deploy all seed contracts
// /// Returns an array of deployed contract addresses
// const deploySeeds = async (dojo_address) => {
//   const seedTypes = [
//     "Bell",
//     "Bulba",
//     "Cactus",
//     "Chamomile",
//     "Fern",
//     "Lily",
//     "Mushroom",
//     "Rose",
//     "Salvia",
//     "Spiral",
//     "Sprout",
//     "Violet",
//     "Zigzag",
//   ];

//   let addresses = [];
//   seedTypes.forEach(async (seedType) => {
//     const args = [account.address, "SeedToken", seedType, dojo_address];
//     addresses.push(await _deployContract(args));
//   });

//   return addresses;
// };

/// Deploy world and set sozo auth
const deployWorld = async () => {
  const { worldAddress, actionsAddress } = await _buildAndMigrateToSozo();
  // const { worldAddress, actionsAddress } = {
  //   worldAddress:
  //     "0x27fe4929ded46d12f37385e890f0189b7c5c08f2539c44c62b3996c547639df",
  //   actionsAddress:
  //     "0x144c185ad836266f64d00161d172a6f25fec82ffcfe97ba231399486d6192b3",
  // };

  console.log("Authorizing...\n");

  const makeAuthCommand = (model) => {
    return `sozo ${profile}auth writer ${model} ${actionsAddress} --world ${worldAddress} --rpc-url ${NODE_URL} --account-address ${account.address} --private-key ${PRIVATE_KEY} --wait`;
  };

  const authorizeModel = async (model) => {
    console.log(`Authorizing ${model}...\n`);
    try {
      const { stdout } = await execAsync(makeAuthCommand(model));
      // await provider.waitForTransaction(stdout.split(":")[1].trim());
      console.log("Auth transaction complete!\n");
    } catch (error) {
      console.error(`exec error: ${error}`);
    }
  };

  const runAuthorizations = async () => {
    await authorizeModel("GardenCell");
    await authorizeModel("PlayerStats");
    await authorizeModel("TokenLookups");
  };

  await runAuthorizations();

  return { worldAddress, actionsAddress };
};

// const deployWorld = async () => {
//   const models = ["GardenCell", "PlayerStats", "TokenLookups"];
//   const { worldAddress, actionsAddress } = await _buildAndMigrateToSozo();

//   const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));
//   const execPromise = (command) =>
//     new Promise((resolve, reject) => {
//       exec(command, (error, stdout, stderr) => {
//         if (error) {
//           reject(error);
//         } else {
//           resolve(stdout);
//         }
//       });
//     });

//   console.log("Authorizing sozo...\n");
//   for (const model of models) {
//     // const command = `sozo auth writer ${model} ${actionsAddress} --world ${worldAddress}`;
//     const command = `sozo ${profile}auth writer ${model} ${actionsAddress} --world ${worldAddress} --rpc-url ${NODE_URL} --account-address ${account.address} --private-key ${PRIVATE_KEY}`;

//     try {
//       const stdout = await execPromise(command);
//       console.log(stdout);
//       console.log("Waiting 1 second for auth to process...");
//       await sleep(1000); // This pauses for 1 second before continuing the loop
//     } catch (error) {
//       console.error(`exec error: ${error}`);
//     }
//   }
//   return { worldAddress, actionsAddress };
// };

/// Set token lookups
const setTokenLookups = async (
  worldAddress,
  actionsAddress,
  seed_addresses
) => {
  /// run sozo execute
  const command = `sozo ${profile}execute ${actionsAddress} set_token_lookups --calldata ${seed_addresses.length},${seed_addresses} --rpc-url ${NODE_URL} --account-address ${account.address} --private-key ${PRIVATE_KEY} --wait`;

  exec(command, (error, stdout) => {
    if (error) {
      console.error(`exec error: ${error}`);
      return;
    }
    console.log(stdout);
  });
};

/// Internals ///

/// Deploy a seed contract with specific constructor arguments
/// Returns the deployed contract address
const _deployContract = async (constructorCalldata) => {
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
/// Returns the world and actions contract addresses
const _buildAndMigrateToSozo = async () => {
  const command = `cd contracts && sozo build && sozo ${profile} migrate`;
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

      resolve({ worldAddress, actionsAddress }); // Resolve the promise with worldAddress
    });
  });
};

// going to need a function to deploy world, then deploy all seeds, then call set_token_lookups

// Deploy all seed contracts
const main = async () => {
  try {
    // await deploySeeds();

    // let { worldAddress, actionsAddress } = await deployWorld();
    /// need to wait for txn to mint for this txn
    const { worldAddress, actionsAddress } = {
      worldAddress:
        "0x27fe4929ded46d12f37385e890f0189b7c5c08f2539c44c62b3996c547639df",
      actionsAddress:
        "0x144c185ad836266f64d00161d172a6f25fec82ffcfe97ba231399486d6192b3",
    };
    await setTokenLookups(worldAddress, actionsAddress, [
      "1",
      "2",
      "3",
      "4",
      "5",
      "6",
      "7",
      "8",
      "9",
      "10",
      "11",
      "12",
      "13",
    ]);
  } catch (error) {
    console.error(`Operation failed! Reason: ${error.message}`);
  }
};

main();
