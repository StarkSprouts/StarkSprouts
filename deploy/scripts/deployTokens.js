const { Account, json, RpcProvider } = require("starknet");
const { config } = require("dotenv");
const { readFileSync } = require("fs");
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

    for (const args of constructorArgsList) {
      await deployContract(args);
    }
  } catch (error) {
    console.error(`Operation failed! Reason: ${error.message}`);
  }
};

main();
