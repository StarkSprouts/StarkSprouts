use starknet::ContractAddress;

#[starknet::interface]
trait ISeed<TContractState> {
    /// Reads
    fn get_dojo_address(self: @TContractState) -> ContractAddress;
    /// Writes
    fn initializer(ref self: TContractState);
    fn set_dojo_address(ref self: TContractState, dojo_address: ContractAddress);
    fn mint_seeds(ref self: TContractState, player: ContractAddress, amount: u256);
    fn burn_seeds(ref self: TContractState, player: ContractAddress, amount: u256);
}

#[starknet::contract]
mod Seed {
    use super::{ISeed, ISeedDispatcher, ISeedDispatcherTrait};

    use starknet::{ContractAddress, ClassHash, get_caller_address, get_contract_address};
    use openzeppelin::{
        access::ownable::OwnableComponent,
        upgrades::{UpgradeableComponent, interface::IUpgradeable},
        token::erc20::{ERC20Component, interface::IERC20Metadata}
    };

    /// Components

    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);
    component!(path: UpgradeableComponent, storage: upgradeable, event: UpgradeableEvent);
    component!(path: ERC20Component, storage: erc20, event: ERC20Event);

    /// (Ownable)
    #[abi(embed_v0)]
    impl OwnableImpl = OwnableComponent::OwnableImpl<ContractState>;
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;
    /// (Upgradeable)
    impl UpgradeableInternalImpl = UpgradeableComponent::InternalImpl<ContractState>;
    /// (ERC20)
    #[abi(embed_v0)]
    impl ERC20Impl = ERC20Component::ERC20Impl<ContractState>;
    #[abi(embed_v0)]
    impl SafeAllowanceImpl = ERC20Component::SafeAllowanceImpl<ContractState>;
    impl ERC20InternalImpl = ERC20Component::InternalImpl<ContractState>;

    /// Contract

    #[storage]
    struct Storage {
        /// Dojo world address 
        dojo_address: ContractAddress,
        /// Component storage.
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
        #[substorage(v0)]
        upgradeable: UpgradeableComponent::Storage,
        #[substorage(v0)]
        erc20: ERC20Component::Storage,
    }

    /// Constructor
    #[constructor]
    fn constructor(
        ref self: ContractState,
        owner: ContractAddress,
        name: felt252,
        symbol: felt252,
        dojo_address: ContractAddress
    ) {
        self.erc20.initializer(name, symbol);
        self.ownable.initializer(owner);
        self.dojo_address.write(dojo_address);
    }

    /// Events
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        OwnableEvent: OwnableComponent::Event,
        #[flat]
        UpgradeableEvent: UpgradeableComponent::Event,
        #[flat]
        ERC20Event: ERC20Component::Event,
    }

    /// External Functions
    #[external(v0)]
    impl UpgradeableImpl of IUpgradeable<ContractState> {
        /// Write

        /// Upgrade the contract to the new implementation hash.
        /// @dev Only callable by the contract owner.
        /// @dev Calls the new implementation's initializer function.
        fn upgrade(ref self: ContractState, new_class_hash: ClassHash) {
            self.ownable.assert_only_owner();
            self.upgradeable._upgrade(new_class_hash);
            ISeedDispatcher { contract_address: get_contract_address() }.initializer();
        }
    }

    /// @dev Re-define OpenZeppelin's ERC20Metadata interface to
    /// return 0 for decimals.
    #[external(v0)]
    impl ERC20MetadataImpl of IERC20Metadata<ContractState> {
        fn decimals(self: @ContractState) -> u8 {
            0
        }

        fn name(self: @ContractState) -> felt252 {
            self.erc20.name()
        }

        fn symbol(self: @ContractState) -> felt252 {
            self.erc20.symbol()
        }
    }

    #[external(v0)]
    impl SeedImpl of super::ISeed<ContractState> {
        /// Reads ///

        /// Get the dojo world address
        fn get_dojo_address(self: @ContractState) -> ContractAddress {
            self.dojo_address.read()
        }

        /// Writes ///

        /// Empty function for interface definition.
        /// @dev Useful for future contract upgrades. This function is 
        /// called by the upgrade function; allowing future upgrades to
        /// perform any necessary initialization in the 1 `upgrade()` txn.
        fn initializer(ref self: ContractState) {}

        /// Set the dojo world address if caller is owner
        fn set_dojo_address(ref self: ContractState, dojo_address: ContractAddress) {
            self.ownable.assert_only_owner();
            self.dojo_address.write(dojo_address);
        }

        /// Mint seeds to a user
        fn mint_seeds(ref self: ContractState, player: ContractAddress, amount: u256) {
            self.assert_caller_is_dojo_world();
            self.erc20._mint(player, amount);
        }

        /// Burn seeds from a user
        fn burn_seeds(ref self: ContractState, player: ContractAddress, amount: u256) {
            self.assert_caller_is_dojo_world();
            self.erc20._burn(player, amount);
        }
    }

    /// Internal Functions
    #[generate_trait]
    impl SeedInternals of SeedInternalsTrait { /// verify caller is dojo address
        fn assert_caller_is_dojo_world(self: @ContractState) {
            assert(
                get_caller_address() == self.dojo_address.read(), 'Caller is not the dojo world'
            );
        }
    }
}

#[cfg(test)]
mod tests {
    use super::{Seed, ISeed, ISeedDispatcher, ISeedDispatcherTrait};
    use starknet::{
        ContractAddress, get_contract_address, contract_address_const,
        testing::{set_contract_address, set_caller_address}
    };
    // use openzeppelin::{
    //     access::ownable::OwnableComponent,
    //     upgrades::{UpgradeableComponent, interface::IUpgradeable},
    //     token::erc20::{ERC20Component, interface::IERC20Metadata}
    // };
    use openzeppelin::{
        token::erc20::{ERC20Component, ERC20ABIDispatcher, ERC20ABIDispatcherTrait},
        access::ownable::{
            OwnableComponent, interface::{IOwnableDispatcher, IOwnableDispatcherTrait}
        },
    };


    use core::traits::TryInto;
    // use super::MockContract;
    // use super::counter::{ICounterDispatcher, ICounterDispatcherTrait};
    use starknet::deploy_syscall;
    use starknet::SyscallResultTrait;

    fn deploy() -> (ISeedDispatcher, ERC20ABIDispatcher, IOwnableDispatcher) {
        let owner: ContractAddress = contract_address_const::<'owner'>();
        let dojo_address: ContractAddress = contract_address_const::<'dojo_address'>();

        let (address, _) = deploy_syscall(
            Seed::TEST_CLASS_HASH.try_into().unwrap(),
            0,
            array!['owner', 'Bell', 'SSS', 'dojo'].span(),
            false
        )
            .unwrap_syscall();
        (
            ISeedDispatcher { contract_address: address },
            ERC20ABIDispatcher { contract_address: address },
            IOwnableDispatcher { contract_address: address }
        )
    }

    #[test]
    #[available_gas(1000000)]
    fn test_constructor() {
        let (seed, erc20, ownable) = deploy();

        assert(erc20.name() == 'Bell', 'wrong name');
        assert(erc20.symbol() == 'SSS', 'wrong symbol');
        assert(seed.get_dojo_address() == contract_address_const::<'dojo'>(), 'wrong dojo address');
        assert(ownable.owner() == contract_address_const::<'owner'>(), 'wrong owner');
    }

    #[test]
    #[available_gas(1000000)]
    fn test_set_dojo_address() {
        let (seed, _, ownable) = deploy();
        let new_addr = contract_address_const::<'dojodojo'>();
        set_contract_address(contract_address_const::<'owner'>());
        seed.set_dojo_address(new_addr);
        assert(seed.get_dojo_address() == new_addr, 'wrong dojo address');
    }

    #[test]
    #[available_gas(1000000)]
    #[should_panic()]
    fn test_set_dojo_address_non_owner() {
        let (seed, _, ownable) = deploy();
        let new_addr = contract_address_const::<'dojodojo'>();
        set_contract_address(contract_address_const::<'not owner'>());
        seed.set_dojo_address(new_addr);
    }

    #[test]
    #[available_gas(1000000)]
    fn test_mint_seeds() {
        let (seed, erc20, _) = deploy();
        let player = contract_address_const::<'player'>();
        set_contract_address(contract_address_const::<'dojo'>());
        seed.mint_seeds(player, 100);
        assert(erc20.balance_of(player) == 100, 'wrong balance');
    }

    #[test]
    #[available_gas(1000000)]
    #[should_panic()]
    fn test_mint_seeds_non_dojo() {
        let (seed, erc20, _) = deploy();
        let player = contract_address_const::<'player'>();
        set_contract_address(contract_address_const::<'no dojo'>());
        seed.mint_seeds(player, 100);
    }

    #[test]
    #[available_gas(2000000)]
    fn test_burn_seeds() {
        let (seed, erc20, _) = deploy();
        let player = contract_address_const::<'player'>();
        set_contract_address(contract_address_const::<'dojo'>());
        seed.mint_seeds(player, 100);
        assert(erc20.balance_of(player) == 100, 'wrong balance');
        seed.burn_seeds(player, 50);
        assert(erc20.balance_of(player) == 50, 'wrong balance');
    }
    #[test]
    #[available_gas(2000000)]
    #[should_panic()]
    fn test_burn_seeds_non_dojo() {
        let (seed, erc20, _) = deploy();
        let player = contract_address_const::<'player'>();
        set_contract_address(contract_address_const::<'dojo'>());
        seed.mint_seeds(player, 100);
        assert(erc20.balance_of(player) == 100, 'wrong balance');
        set_contract_address(contract_address_const::<'no dojo'>());
        seed.burn_seeds(player, 50);
    }
}

