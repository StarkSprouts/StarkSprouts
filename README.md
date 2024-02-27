# StarkSprouts

StarkSprouts is an on-chain gardening simulator. The ultimate goal is to maximize garden yield while preventing plant death and ensuring timely harvesting.

Created at Starknet Hacker House Denver 2024


## Local Dojo Deployment 

1. ``` cd contracts ```
2. ``` katana --disable-fee --invoke-max-steps 100000000 ```
3. ``` sozo build ```
4. ``` sozo migrate ```

## Local Frontend Deployment 

1. ``` cd react-threejs ```
2. ``` bun install ```
3. ``` bun dev ```

## Dojo Contract Notes 

The actions of our world are defined here:

<img width="703" alt="Screenshot 2024-02-27 at 1 57 56 PM" src="https://github.com/StarkSprouts/StarkSprouts/assets/96356887/60d1efac-52c4-4163-b19c-825916bb7397">

With these tests we assume that the game logic is working as expected on the contract side, unfortuntately we ran out of time to fully implement them into the client during the Hacker House. 

<img width="1329" alt="Screenshot 2024-02-27 at 11 56 45 AM" src="https://github.com/StarkSprouts/StarkSprouts/assets/96356887/81f46aeb-e9d4-4310-aa24-a8e3f49881f3">

Along with our deployment script to deploy the world and other necessary assets/steps to katana/slot

<img width="1215" alt="Screenshot 2024-02-27 at 12 04 05 PM" src="https://github.com/StarkSprouts/StarkSprouts/assets/96356887/9864db83-3528-4211-863a-a8ac80490841">



   
